package app.linksy

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiManager
import android.os.Handler
import android.os.Looper
import android.os.SystemClock

/// Tells the app what this phone's networks are when they may have changed (docs/protocol.md
/// §4.13, "Switching networks"): Android doesn't let iroh see that by itself. Android calls
/// back for much that doesn't touch a link (a network's DNS or routes, mobile data's link
/// details, every network again on registering), so this only says what the networks are:
/// each one's kind and addresses, and which is the default. The app compares and tells the
/// core only when something a link could be using went away or came (`NetworkState`). At
/// most once a second: a burst becomes a snapshot at once and, if more came meanwhile, one
/// a second later.
class NetworkWatcher(context: Context, private val changed: (Map<String, Any?>) -> Unit) {
    private val connectivity = context.getSystemService(ConnectivityManager::class.java)
    private val wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
    private val main = Handler(Looper.getMainLooper())
    private var last = 0L
    private var pending = false

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) = poke()
        override fun onLost(network: Network) = poke()
        override fun onLinkPropertiesChanged(network: Network, properties: LinkProperties) = poke()
    }

    /// The default network moving (Wi-Fi to mobile data and back) changes no network's
    /// addresses, so the callback above may not hear it.
    private val default = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) = poke()
        override fun onLost(network: Network) = poke()
    }

    fun start() {
        // Every network, local Wi-Fi without internet too
        val request = NetworkRequest.Builder()
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        runCatching { connectivity?.registerNetworkCallback(request, callback) }
        runCatching { connectivity?.registerDefaultNetworkCallback(default) }
    }

    fun stop() {
        runCatching { connectivity?.unregisterNetworkCallback(callback) }
        runCatching { connectivity?.unregisterNetworkCallback(default) }
        main.removeCallbacksAndMessages(null)
    }

    private fun poke() {
        main.post(::schedule)
    }

    private fun schedule() {
        if (pending) return
        val wait = last + 1000 - SystemClock.elapsedRealtime()
        pending = true
        main.postDelayed({
            pending = false
            last = SystemClock.elapsedRealtime()
            runCatching { snapshot() }.onSuccess(changed)
        }, wait.coerceAtLeast(0))
    }

    /// `networks`: each with its `id`, `kind` (wifi, mobile, ethernet, vpn, other) and
    /// `addresses`; `default`: the default network's id; `wifiMhz`: the frequency this
    /// phone's Wi-Fi is on, when it's connected.
    @Suppress("DEPRECATION")
    private fun snapshot(): Map<String, Any?> {
        val cm = connectivity ?: return mapOf("networks" to emptyList<Any>())
        val networks = cm.allNetworks.mapNotNull { network ->
            val caps = cm.getNetworkCapabilities(network) ?: return@mapNotNull null
            val props = cm.getLinkProperties(network) ?: return@mapNotNull null
            mapOf(
                "id" to network.toString(),
                "kind" to when {
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "vpn"
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "mobile"
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                    else -> "other"
                },
                "addresses" to props.linkAddresses.map { it.address.hostAddress.orEmpty() }.sorted(),
            )
        }
        val frequency = wifi?.connectionInfo?.frequency?.takeIf { it in 2400..7125 }
        return mapOf(
            "networks" to networks,
            "default" to cm.activeNetwork?.toString(),
            "wifiMhz" to frequency,
        )
    }
}
