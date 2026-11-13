package app.linksy

import android.Manifest
import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.net.Inet4Address
import java.net.NetworkInterface

/// This phone's side of a direct link (docs/protocol.md §4.17): a Wi-Fi Direct group of
/// its own that a computer or another phone joins for big transfers, or another phone's
/// group that this one joins. The core relays the steps; this does the Wi-Fi part and
/// reports each step through [step]: `invite` (with `address`, `name`, and for a phone
/// `ssid`, `passphrase`, `frequency`), `connecting`, `up` (with `ip`), or `end` (with
/// `reason`). Joining, only for the app: `joining`, then `joined` once in the group.
/// One link at a time.
object DirectHost {
    /// A group made with a name and a passphrase (phone to phone). Never logged.
    class Group(val ssid: String, val passphrase: String, val frequency: Int?)

    /// Set by the app: (device id, step).
    @Volatile var step: ((String, Map<String, String>) -> Unit)? = null

    /// Set by the activity while it's in front: asks for [permission], then answers.
    @Volatile var ask: ((String, (Boolean) -> Unit) -> Unit)? = null

    private val main = Handler(Looper.getMainLooper())
    private var manager: WifiP2pManager? = null
    private var channel: WifiP2pManager.Channel? = null
    private var receiver: BroadcastReceiver? = null
    private var registeredOn: Context? = null

    /// The device the link is for, the computer's address once it listens, and how far it got.
    private var device: String? = null
    private var target: String? = null
    private var connecting = false
    private var up = false

    /// The core has the link (`DirectLinked`): from then on only `DirectEnded` ends it.
    private var linked = false

    /// The group this phone makes (hosting a phone), or joins (`joining`).
    private var group: Group? = null
    private var joining = false

    /// This phone's Wi-Fi frequency when it began joining, and the join's last state, for the log.
    private var ownMhz: Int? = null
    private var lastJoinState: String? = null

    /// Whether this phone can host one: Wi-Fi Direct, and Android 10+ (`requestDeviceInfo`).
    fun supported(context: Context) =
        Build.VERSION.SDK_INT >= 29 && context.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI_DIRECT)

    fun permission() =
        if (Build.VERSION.SDK_INT >= 33) Manifest.permission.NEARBY_WIFI_DEVICES else Manifest.permission.ACCESS_FINE_LOCATION

    /// `DirectWanted`: invite the computer with this phone's address and name, or with
    /// [group] (another phone), make that group first.
    fun want(context: Context, id: String, group: Group?) = prepare(context, id) { app -> begin(app, id, group) }

    /// An `invite` with a group, from the phone that hosts: join it.
    fun join(context: Context, id: String, group: Group) = prepare(context, id) { app -> joinGroup(app, id, group) }

    /// The checks both sides make, then [go].
    private fun prepare(context: Context, id: String, go: (Context) -> Unit) = main.post {
        val app = context.applicationContext
        // Under way or up with this computer already: never start over, which would drop
        // the group a transfer is going through
        if (device == id) return@post
        if (device != null) {
            report(id, "end", "reason" to "already linked to another device")
            return@post
        }
        if (!supported(app)) return@post report(id, "end", "reason" to "no Wi-Fi Direct on this phone")
        val wifi = app.getSystemService(Context.WIFI_SERVICE) as WifiManager
        if (!wifi.isWifiEnabled) return@post report(id, "end", "reason" to "Wi-Fi is off")
        val permission = permission()
        if (app.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            go(app)
            return@post
        }
        // Asked once, in front only: a refusal stays a refusal, the transfer goes the usual way
        val prefs = app.getSharedPreferences("permissions", Context.MODE_PRIVATE)
        val asking = ask
        if (asking == null || prefs.getBoolean(permission, false)) {
            return@post report(id, "end", "reason" to "no Wi-Fi Direct permission")
        }
        prefs.edit().putBoolean(permission, true).apply()
        asking(permission) { granted ->
            main.post { if (granted) go(app) else report(id, "end", "reason" to "no Wi-Fi Direct permission") }
        }
    }

    /// A fresh channel for the link with [id], and the receiver: null if there's no Wi-Fi Direct.
    private fun open(context: Context, id: String): Pair<WifiP2pManager, WifiP2pManager.Channel>? {
        stop()
        device = id
        val manager = context.getSystemService(WifiP2pManager::class.java) ?: return null
        // Only this link's own channel: an older one closing later must not end it
        var made: WifiP2pManager.Channel? = null
        val channel = manager.initialize(context, Looper.getMainLooper()) {
            if (made != null && this.channel === made) fail("Wi-Fi Direct stopped")
        }
        made = channel
        this.manager = manager
        this.channel = channel
        listen(context)
        return manager to channel
    }

    @SuppressLint("MissingPermission")
    private fun begin(context: Context, id: String, group: Group?) {
        val (manager, channel) = open(context, id) ?: return fail("no Wi-Fi Direct on this phone")
        if (group != null) return makeGroup(context, manager, channel, id, group)
        // Anything left over from before goes first
        manager.removeGroup(channel, null)
        manager.requestDeviceInfo(channel) { info ->
            // Android gives apps 02:00:00:00:00:00 for the address: the computer finds this
            // phone by its name then
            val address = info?.deviceAddress
            if (address == null || device != id) return@requestDeviceInfo fail("this phone's Wi-Fi Direct address is unknown")
            val name = info.deviceName?.takeIf { it.isNotBlank() }?.take(64)
            val invite = object : WifiP2pManager.ActionListener {
                override fun onSuccess() = report(
                    id, "invite", "address" to address.lowercase(), *listOfNotNull(name?.let { "name" to it }).toTypedArray(),
                )
                override fun onFailure(reason: Int) = fail("couldn't look for the computer (${why(reason)})")
            }
            // The social channels (1, 6, 11) only where Android can: the two find each
            // other in seconds instead of after a full scan
            if (Build.VERSION.SDK_INT >= 33 && manager.isChannelConstrainedDiscoverySupported) {
                manager.discoverPeersOnSocialChannels(channel, invite)
            } else {
                manager.discoverPeers(channel, invite)
            }
        }
    }

    /// Phone to phone, hosting: a group with the core's name and passphrase, on 5 GHz where
    /// the phone can. The invite (with its frequency) and `up` go out once it's made.
    @SuppressLint("MissingPermission")
    private fun makeGroup(context: Context, manager: WifiP2pManager, channel: WifiP2pManager.Channel, id: String, group: Group) {
        this.group = group
        val wifi = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        fun config(frequency: Int?) = WifiP2pConfig.Builder()
            .setNetworkName(group.ssid)
            .setPassphrase(group.passphrase)
            .apply {
                // A band or a frequency, never both
                if (frequency != null) {
                    setGroupOperatingFrequency(frequency)
                } else {
                    setGroupOperatingBand(
                        if (wifi.is5GHzBandSupported) WifiP2pConfig.GROUP_OWNER_BAND_5GHZ else WifiP2pConfig.GROUP_OWNER_BAND_AUTO,
                    )
                }
            }
            .enablePersistentMode(false)
            .build()
        // On the channel the computer's Wi-Fi is on, so its one chip doesn't hop between two.
        // A channel this phone may not host on (a DFS one): the band instead.
        fun make(frequency: Int?) {
            if (device != id) return
            manager.createGroup(channel, config(frequency), object : WifiP2pManager.ActionListener {
                override fun onSuccess() = checkGroup()
                override fun onFailure(reason: Int) {
                    if (frequency != null) make(null) else fail("couldn't make the group (${why(reason)})")
                }
            })
        }
        // Phone to phone the joiner rarely says its channel (the host starts it), and the 5 GHz
        // band alone lets Android pick one that may be neither phone's: then a phone whose chip
        // keeps Wi-Fi and Wi-Fi Direct on one channel never gets in, and gives no error (mobile
        // Linksy, a 410 MB send at 5180 MHz that "took too long"). This phone's own Wi-Fi channel
        // is the other phone's too on most networks, where both use the same router.
        @Suppress("DEPRECATION")
        val own = wifi.connectionInfo?.frequency?.takeIf { it in 2400..7125 }
        val create = { make(group.frequency ?: own) }
        // Anything left over from before goes first, then the group
        manager.removeGroup(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() = create()
            override fun onFailure(reason: Int) = create()
        })
    }

    /// Phone to phone, joining: the host's group by its name and passphrase, on its
    /// frequency when it said. Android 10+ joins without any prompt.
    @SuppressLint("MissingPermission")
    private fun joinGroup(context: Context, id: String, group: Group) {
        val (manager, channel) = open(context, id) ?: return fail("no Wi-Fi Direct on this phone")
        this.group = group
        joining = true
        val wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        @Suppress("DEPRECATION")
        ownMhz = wifi.connectionInfo?.frequency?.takeIf { it in 2400..7125 }
        // A band or a frequency, never both
        val config = WifiP2pConfig.Builder()
            .setNetworkName(group.ssid)
            .setPassphrase(group.passphrase)
            .apply { group.frequency?.let { setGroupOperatingFrequency(it) } }
            .build()
        manager.removeGroup(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() = connect(manager, channel, config, tries = 3)
            override fun onFailure(reason: Int) = connect(manager, channel, config, tries = 3)
        })
    }

    /// `listening`: connect once the computer shows up among the peers.
    fun listening(id: String, address: String) = main.post {
        if (device != id) return@post
        target = address.lowercase()
        lookForTarget()
    }

    @SuppressLint("MissingPermission")
    private fun lookForTarget() {
        val (manager, channel, address) = Triple(manager ?: return, channel ?: return, target ?: return)
        if (connecting) return
        manager.requestPeers(channel) { peers ->
            if (connecting || target != address) return@requestPeers
            if (peers.deviceList.none { it.deviceAddress.equals(address, ignoreCase = true) }) return@requestPeers
            connecting = true
            val config = WifiP2pConfig().apply {
                deviceAddress = address
                wps.setup = WpsInfo.PBC
                groupOwnerIntent = 15
            }
            connect(manager, channel, config, tries = 3)
        }
    }

    @SuppressLint("MissingPermission")
    private fun connect(manager: WifiP2pManager, channel: WifiP2pManager.Channel, config: WifiP2pConfig, tries: Int) {
        val id = device ?: return
        manager.connect(channel, config, object : WifiP2pManager.ActionListener {
            override fun onSuccess() = if (joining) {
                // Not sent on (the app keeps `joining` to itself): for the log, where a group on
                // another channel than this phone's Wi-Fi is the first thing to suspect.
                report(id, "joining", *listOfNotNull(ownMhz?.let { "wifi" to "$it" }).toTypedArray())
            } else {
                report(id, "connecting")
            }
            override fun onFailure(reason: Int) {
                // Busy for a moment (still discovering): again shortly
                if (tries > 1 && device == id) {
                    main.postDelayed({ connect(manager, channel, config, tries - 1) }, 1000)
                } else {
                    fail(if (joining) "couldn't join the group (${why(reason)})" else "couldn't connect to the computer (${why(reason)})")
                }
            }
        })
    }

    private fun listen(context: Context) {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> lookForTarget()
                    WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                        if (joining && !up) noteJoin(intent)
                        checkGroup()
                    }
                    WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION ->
                        if (intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, 0) == WifiP2pManager.WIFI_P2P_STATE_DISABLED) {
                            fail("Wi-Fi is off")
                        }
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
        }
        if (Build.VERSION.SDK_INT >= 33) context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        else context.registerReceiver(receiver, filter)
        this.receiver = receiver
        registeredOn = context
    }

    /// While joining, what Android says of the connection, to the log once per change: a join
    /// that fails says nothing else (its `connect` succeeded), it just never forms a group.
    @Suppress("DEPRECATION")
    private fun noteJoin(intent: Intent) {
        val info = intent.getParcelableExtra<android.net.NetworkInfo>(WifiP2pManager.EXTRA_NETWORK_INFO) ?: return
        val state = info.detailedState?.name?.lowercase() ?: return
        if (state == lastJoinState) return
        lastJoinState = state
        Logs.add("Wi-Fi Direct, joining: $state")
    }

    @SuppressLint("MissingPermission")
    private fun checkGroup() {
        val (manager, channel, id) = Triple(manager ?: return, channel ?: return, device ?: return)
        manager.requestConnectionInfo(channel) { info ->
            if (up || device != id || info == null || !info.groupFormed) return@requestConnectionInfo
            val group = group
            when {
                // In the other phone's group: the app dials once `up` says where it is
                // (that group, not one left over from before)
                joining -> if (!info.isGroupOwner) {
                    manager.requestGroupInfo(channel) { joined ->
                        if (up || device != id || joined?.networkName != group?.ssid) return@requestGroupInfo
                        up = true
                        whenAddressed(id, tries = 50)
                    }
                }
                // This phone's group, made for the other phone: the invite carries the
                // credentials and the frequency, `up` follows right away
                group != null -> if (info.isGroupOwner) {
                    val ip = info.groupOwnerAddress?.hostAddress ?: "192.168.49.1"
                    manager.requestGroupInfo(channel) { made ->
                        // The group made for it, not one left over from before
                        if (up || device != id || made?.networkName != group.ssid) return@requestGroupInfo
                        up = true
                        manager.requestDeviceInfo(channel) { me ->
                            if (device != id) return@requestDeviceInfo
                            val frequency = made?.frequency?.takeIf { it in 2400..7125 }
                            val name = me?.deviceName?.takeIf { it.isNotBlank() }?.take(64)
                            report(
                                id, "invite",
                                "address" to (me?.deviceAddress ?: "02:00:00:00:00:00").lowercase(),
                                "ssid" to group.ssid,
                                "passphrase" to group.passphrase,
                                *listOfNotNull(name?.let { "name" to it }, frequency?.let { "frequency" to "$it" }).toTypedArray(),
                            )
                            report(id, "up", "ip" to ip)
                        }
                    }
                }
                else -> {
                    val ip = if (info.isGroupOwner) info.groupOwnerAddress?.hostAddress else p2pAddress()
                    if (ip == null) return@requestConnectionInfo fail("no address on the direct link")
                    up = true
                    report(id, "up", "ip" to ip)
                }
            }
        }
    }

    /// In the group, but the owner hands out addresses (DHCP) a moment later: `joined`
    /// once this phone has one, so the first packets don't go nowhere.
    private fun whenAddressed(id: String, tries: Int) {
        if (device != id) return
        val ip = p2pAddress()
        when {
            ip != null -> report(id, "joined", "ip" to ip)
            tries > 1 -> main.postDelayed({ whenAddressed(id, tries - 1) }, 200)
            else -> fail("no address in the group")
        }
    }

    /// This phone's IPv4 address on its Wi-Fi Direct interface (`p2p…`), when it isn't the owner.
    private fun p2pAddress(): String? = runCatching {
        NetworkInterface.getNetworkInterfaces().toList()
            .filter { it.name.startsWith("p2p") && it.isUp }
            .flatMap { it.inetAddresses.toList() }
            .firstOrNull { it is Inet4Address }?.hostAddress
    }.getOrNull()

    /// `DirectLinked`: the computer is connected over it.
    fun linked(id: String) = main.post { if (device == id) linked = true }

    /// `DirectEnded`: drop the group and everything else.
    fun ended(id: String) = main.post { if (device == id) stop() }

    private fun fail(reason: String) {
        // A link that's up is the core's to end (it notices one that's gone)
        if (linked) return
        val id = device ?: return
        stop()
        report(id, "end", "reason" to reason)
    }

    /// Everything the link held, so nothing keeps Wi-Fi busy after it (a GO negotiation
    /// still pending slows the transfer that falls back to the router).
    private fun stop() {
        val (manager, channel) = manager to channel
        if (manager != null && channel != null) {
            manager.cancelConnect(channel, null)
            manager.removeGroup(channel, null)
            manager.stopPeerDiscovery(channel, null)
            // Once Android has had them; a new link gets a channel of its own
            if (Build.VERSION.SDK_INT >= 27) main.postDelayed({ channel.close() }, 3000)
        }
        receiver?.let { r -> runCatching { registeredOn?.unregisterReceiver(r) } }
        receiver = null
        registeredOn = null
        this.manager = null
        this.channel = null
        device = null
        target = null
        connecting = false
        up = false
        linked = false
        group = null
        joining = false
        ownMhz = null
        lastJoinState = null
    }

    private fun report(id: String, type: String, vararg extra: Pair<String, String>) {
        val step = this.step ?: return
        main.post { step(id, mapOf("type" to type) + extra) }
    }

    private fun why(reason: Int) = when (reason) {
        WifiP2pManager.P2P_UNSUPPORTED -> "unsupported"
        WifiP2pManager.BUSY -> "busy"
        else -> "error $reason"
    }
}
