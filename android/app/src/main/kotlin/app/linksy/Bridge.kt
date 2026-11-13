package app.linksy

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import app.linksy.files.FileServer
import app.linksy.files.GalleryServer
import app.linksy.files.NativeFiles
import app.linksy.files.NativeGallery
import app.linksy.media.NativeSession
import app.linksy.media.ShareService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/// Dart's way to Android ("app.linksy/platform") for one Flutter engine,
/// whether or not [MainActivity] shows it. Started at boot, the engine runs
/// with no activity: calls that need one (pickers, permission dialogs, the
/// window) come back empty until the app is opened.
class Bridge(context: Context, val engine: FlutterEngine) {
    private val app: Context = context.applicationContext
    private val main = Handler(Looper.getMainLooper())
    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "app.linksy/platform")

    /// The activity on screen, for the calls only it can answer.
    var activity: MainActivity? = null

    private fun post(block: () -> Unit) {
        main.post(block)
    }

    private val ring by lazy { RingPlayer(app) }
    private var calls: CallWatcher? = null
    private var batteryReceiver: BroadcastReceiver? = null
    private var networks: NetworkWatcher? = null
    /// Display input goes out in order, off the UI thread (writes can wait).
    private val inputWriter = Executors.newSingleThreadExecutor()

    init {
        networks = NetworkWatcher(app) { channel.invokeMethod("networkChanged", it) }.apply { start() }
        ShareService.rotationListener = { session, degrees ->
            post { channel.invokeMethod("screenRotation", mapOf("session" to session, "degrees" to degrees)) }
        }
        watchBattery()
        Logs.sink = { line -> post { channel.invokeMethod("log", line) } }
        PhoneNotifications.posted = { n -> post { channel.invokeMethod("phoneNotification", n) } }
        PhoneNotifications.removed = { key, kept ->
            post { channel.invokeMethod("phoneNotificationGone", mapOf("key" to key, "kept" to kept)) }
        }
        ShareService.webcamListener = { session, state ->
            post { channel.invokeMethod("webcamChanged", mapOf("session" to session, "state" to state.toString())) }
        }
        TransferNotice.answer = { transfer, accept ->
            post { channel.invokeMethod("transferAnswer", mapOf("transfer" to transfer, "accept" to accept)) }
        }
        DirectHost.step = { device, step -> post { channel.invokeMethod("directStep", step + ("device" to device)) } }
        Push.subscribe()
        Updater.onStatus = { status -> post { channel.invokeMethod("updateStatus", status) } }
        AppInstaller.onStatus = { name, status ->
            post { channel.invokeMethod("appInstall", mapOf("package" to name, "status" to status)) }
        }
        ComputerMedia.onAction = { action, position ->
            post { channel.invokeMethod("mediaAction", mapOf("action" to action, "position_ms" to position)) }
        }
        channel.setMethodCallHandler { call, result ->
            if (!handle(call, result)) activity?.handle(call, result) ?: result.notImplemented()
        }
    }

    /// Lets go of what this engine held (the engine itself is the caller's).
    fun dispose() {
        networks?.stop()
        networks = null
        TransferNotice.answer = null
        PhoneNotifications.posted = null
        PhoneNotifications.removed = null
        DirectHost.step = null
        ShareService.webcamListener = null
        batteryReceiver?.let { runCatching { app.unregisterReceiver(it) } }
        batteryReceiver = null
        ring.stop()
        calls?.stop()
        calls = null
        inputWriter.shutdown()
        channel.setMethodCallHandler(null)
    }

    /// The calls any engine can answer; false for the rest.
    private fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        when (call.method) {
            "deviceName" -> result.success(deviceName())
            "appVersion" -> result.success(
                app.packageManager.getPackageInfo(app.packageName, 0).let {
                    @Suppress("DEPRECATION")
                    "${it.versionName} (${if (Build.VERSION.SDK_INT >= 28) it.longVersionCode else it.versionCode.toLong()})"
                },
            )
            "pictures" -> result.success(Pictures.all(app))
            "removePicture" -> {
                Pictures.remove(app, call.argument<String>("device")!!)
                result.success(null)
            }
            "folder" -> result.success(folderName(call.argument<String>("kind")!!))
            "forgetFolder" -> {
                val kind = call.argument<String>("kind")!!
                prefs().getString("folder.$kind", null)?.let { letGoOf(it, kind) }
                prefs().edit().remove("folder.$kind").apply()
                result.success(null)
            }
            "shareFiles" -> {
                val on = call.argument<Boolean>("on") == true
                // All files: `/` is the phone's storage, once Android allows it.
                val all = call.argument<Boolean>("all") == true && allFilesState() == "allowed"
                val server = fileServer(app)
                server.root = folder("files")
                server.everything = if (all) android.os.Environment.getExternalStorageDirectory() else null
                NativeFiles.sharing(on && (all || folder("files") != null))
                result.success(null)
            }
            "allFilesState" -> result.success(allFilesState())
            "notificationAccess" -> result.success(PhoneNotifications.allowed(app))
            "mirrorNotifications" -> {
                PhoneNotifications.on = call.argument<Boolean>("on") == true
                result.success(null)
            }
            "replyNotification" -> result.success(
                PhoneNotifications.reply(call.argument<String>("key")!!, call.argument<String>("text")!!),
            )
            "notificationAction" -> result.success(
                PhoneNotifications.act(call.argument<String>("key")!!, call.argument<String>("action")!!),
            )
            "dismissNotification" -> result.success(PhoneNotifications.dismiss(call.argument<String>("key")!!))
            "inboxHistory" -> InboxStore.page(
                app, call.argument<String>("app")!!, call.argument<String>("conversation")!!,
                call.argument<Number>("before")!!.toLong(), call.argument<Int>("limit")!!,
            ) { messages, more ->
                val page = mapOf("messages" to messages.map { it.json().toString() }, "more" to more)
                post { result.success(page) }
            }
            "forgetInbox" -> {
                InboxStore.forget(app)
                result.success(null)
            }
            "phoneMaker" -> result.success(mapOf("maker" to Build.MANUFACTURER, "sdk" to Build.VERSION.SDK_INT))
            "directHost" -> result.success(DirectHost.supported(app))
            "deviceReport" -> result.success(deviceReport())
            // Idle with no activity at all: started with the phone, or swiped away.
            "memory" -> result.success(memory() + if (activity == null) ", without its screen" else "")
            "directWanted" -> {
                DirectHost.want(app, call.argument<String>("device")!!, directGroup(call))
                result.success(null)
            }
            "directJoin" -> {
                val group = directGroup(call)
                if (group != null) DirectHost.join(app, call.argument<String>("device")!!, group)
                result.success(null)
            }
            "directListening" -> {
                DirectHost.listening(call.argument<String>("device")!!, call.argument<String>("address")!!)
                result.success(null)
            }
            "directLinked" -> {
                DirectHost.linked(call.argument<String>("device")!!)
                result.success(null)
            }
            "directEnded" -> {
                DirectHost.ended(call.argument<String>("device")!!)
                result.success(null)
            }
            "keepAlive" -> {
                if (call.argument<Boolean>("on") == true) {
                    KeepAlive.start(
                        app,
                        call.argument<String>("text") ?: Lang.str(app, R.string.keep_alive_default),
                        call.argument<Boolean>("awake") == true,
                        call.argument<String>("title"),
                        call.argument<Int>("progress"),
                    )
                } else {
                    KeepAlive.stop(app)
                }
                result.success(null)
            }
            "watchCalls" -> {
                calls?.stop()
                calls = null
                if (call.argument<Boolean>("on") == true) {
                    calls = CallWatcher(app) { state -> channel.invokeMethod("callState", state) }.apply { start() }
                }
                result.success(null)
            }
            "photoBatch" -> {
                val tree = folder("photos") ?: run { result.success(null); return true }
                val since = (call.argument<Number>("since") ?: 0).toLong()
                Thread {
                    val batch = runCatching { PhotoScanner.batch(app, tree, since) }.getOrNull()
                    post { result.success(batch) }
                }.start()
            }
            "shareProtections" -> result.success(shareProtections())
            "abi" -> result.success(Updater.abi())
            "updatesAllowed" -> result.success(Updater.allowed(app))
            "allowUpdates" -> {
                Updater.allow(app)
                result.success(null)
            }
            "installUpdate" -> {
                Updater.install(app, call.argument<String>("path")!!, call.argument<String>("sha256")!!)
                result.success(null)
            }
            "pictureJpeg" -> {
                val path = call.argument<String>("path")!!
                Thread { Clip.pictureJpeg(path).let { post { result.success(it) } } }.start()
            }
            "clipboardFile" -> result.success(Clip.put(app, call.argument<String>("path")!!))
            "locate" -> Locator.fix(app) { result.success(it) }
            "prefs" -> result.success(
                prefs().all.filterKeys { it.startsWith("app.") }.mapKeys { it.key.removePrefix("app.") },
            )
            "setPref" -> {
                val key = "app." + call.argument<String>("key")!!
                val value = call.argument<String>("value")
                prefs().edit().apply { if (value == null) remove(key) else putString(key, value) }.apply()
                result.success(null)
            }
            "shareTargets" -> {
                @Suppress("UNCHECKED_CAST")
                val devices = call.arguments as List<Map<String, String?>>
                Thread { ShareShortcuts.update(app, devices) }.start()
                result.success(null)
            }
            "sharedTo" -> {
                ShareShortcuts.used(app, call.arguments as String)
                result.success(null)
            }
            "battery" -> result.success(battery(null))
            "noticeTransfer" -> {
                TransferNotice.post(
                    app, call.argument<String>("transfer")!!,
                    call.argument<String>("title")!!, call.argument<String>("body") ?: "",
                )
                result.success(null)
            }
            "noticeArrived" -> {
                ArrivedNotice.post(
                    app, call.argument<String>("id")!!,
                    call.argument<String>("title")!!, call.argument<String>("body") ?: "",
                )
                result.success(null)
            }
            "noticeTurnOn" -> {
                ArrivedNotice.post(
                    app, call.argument<String>("id")!!,
                    call.argument<String>("title")!!, call.argument<String>("body") ?: "",
                    mapOf(
                        MainActivity.EXTRA_TURN_ON to call.argument<String>("feature")!!,
                        MainActivity.EXTRA_TURN_ON_NAME to call.argument<String>("name")!!,
                    ),
                )
                result.success(null)
            }
            "cancelNotice" -> {
                TransferNotice.cancel(app, call.argument<String>("transfer")!!)
                result.success(null)
            }
            "publishDownloads" -> {
                val paths = call.argument<List<String>>("paths").orEmpty()
                val root = java.io.File(app.getExternalFilesDir(null), "Received")
                Thread {
                    val moved = Downloads.publish(app, root, paths, folder("received"))
                    post { result.success(moved) }
                }.start()
            }
            "phoneApps" -> Thread {
                val apps = runCatching { Apps.list(app) }.getOrDefault(emptyList())
                post { result.success(apps) }
            }.start()
            "phoneAlbums" -> Thread {
                val albums = runCatching { PhoneMedia.albums(app) }.getOrDefault(emptyList())
                post { result.success(albums) }
            }.start()
            "phoneMedia" -> {
                val album = call.argument<String>("album")
                val before = call.argument<Number>("before")?.toLong()
                val limit = call.argument<Int>("limit") ?: 200
                Thread {
                    val items = runCatching {
                        PhoneMedia.items(app, album, before, limit)
                    }.getOrDefault(emptyList())
                    post { result.success(items) }
                }.start()
            }
            "phoneThumb" -> {
                val id = call.argument<Number>("id")!!.toLong()
                val video = call.argument<Boolean>("video") == true
                Thread {
                    val bytes = PhoneMedia.thumb(app, id, video, 256)
                    post { result.success(bytes) }
                }.start()
            }
            "controlsRead" -> result.success(controls().read())
            "controlsSet" -> result.success(controls().apply(call.arguments as Map<*, *>))
            "controlsWatch" -> {
                controls().watch(call.arguments as Boolean)
                result.success(null)
            }
            "dndAccess" -> result.success(controls().dndAccess)
            "computerNotice" -> {
                ComputerNotices.post(
                    app,
                    call.argument<String>("computer")!!,
                    call.argument<String>("key")!!,
                    call.argument<String>("app") ?: "",
                    call.argument<String>("title") ?: "",
                    call.argument<String>("body") ?: "",
                    (call.argument<Number>("at"))?.toLong() ?: 0L,
                )
                result.success(null)
            }
            "snapNotice" -> {
                val open = android.app.PendingIntent.getActivity(
                    app,
                    1,
                    Intent(app, SnapActivity::class.java)
                        .putExtra(ShareTarget.EXTRA_DEVICE, call.argument<String>("device"))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT,
                )
                ArrivedNotice.post(app, "snap", call.argument<String>("title")!!, "", emptyMap(), open)
                result.success(null)
            }
            "shrinkPicture" -> {
                val from = call.arguments as String
                Thread {
                    val path = runCatching {
                        val options = android.graphics.BitmapFactory.Options().apply { inSampleSize = 2 }
                        val picture = android.graphics.BitmapFactory.decodeFile(from, options)!!
                        val to = java.io.File(app.cacheDir, "snap-clipboard.jpg")
                        to.outputStream().use { picture.compress(android.graphics.Bitmap.CompressFormat.JPEG, 85, it) }
                        to.path
                    }.getOrNull()
                    post { result.success(path) }
                }.start()
            }
            "usbPlugged" -> {
                val battery = app.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                result.success(
                    battery?.getIntExtra(android.os.BatteryManager.EXTRA_PLUGGED, 0) ==
                        android.os.BatteryManager.BATTERY_PLUGGED_USB,
                )
            }
            "phoneModel" -> result.success(
                mapOf("maker" to android.os.Build.MANUFACTURER, "model" to android.os.Build.MODEL),
            )
            "connectionFacts" -> result.success(connectionFacts())
            "thumbOf" -> {
                val ref = call.argument<String>("ref")!!
                Thread {
                    val bytes = PhoneMedia.thumbOf(app, ref, 256)
                    post { result.success(bytes) }
                }.start()
            }
            "appIcon" -> {
                val name = call.argument<String>("package")!!
                Thread {
                    val bytes = Apps.iconOf(app, name)
                    post { result.success(bytes) }
                }.start()
            }
            "preflightFacts" -> {
                @Suppress("UNCHECKED_CAST")
                val probes = call.argument<List<Map<String, Any?>>>("probes").orEmpty()
                Thread {
                    val facts = mapOf(
                        "free" to Apps.free(app),
                        "direct" to Apps.direct(app),
                        "can_install" to Updater.allowed(app),
                        "apps" to Apps.compare(app, probes),
                    )
                    post { result.success(facts) }
                }.start()
            }
            "deleteFiles" -> {
                for (path in call.argument<List<String>>("paths").orEmpty()) {
                    val file = java.io.File(path)
                    file.delete()
                    file.parentFile?.takeIf { it.list()?.isEmpty() == true }?.delete()
                }
                result.success(null)
            }
            "publishLeftovers" -> {
                val keep = call.argument<List<String>>("keep").orEmpty()
                val root = java.io.File(app.getExternalFilesDir(null), "Received")
                Thread {
                    val moved = runCatching {
                        Downloads.publishLeftovers(app, root, keep, folder("received"))
                    }.getOrDefault(emptyList())
                    post { result.success(moved) }
                }.start()
            }
            "pushToken" -> Push.token { token -> post { result.success(token) } }
            "openUrl" -> result.success(openUrl(call.argument<String>("url")!!))
            "mediaNotice" -> {
                @Suppress("UNCHECKED_CAST")
                ComputerMedia.show(app, call.arguments as Map<String, Any?>?)
                result.success(null)
            }
            "startRing" -> {
                ring.start()
                result.success(null)
            }
            "stopRing" -> {
                ring.stop()

                result.success(null)
            }
            // True once per install: whether to show the permissions sheet.
            // Photos for the computers' Gallery (§4.18): the requests
            // reach the server only while Android allows it.
            "shareGallery" -> {
                val allowed = galleryServer(app).allowed()
                NativeGallery.sharing(allowed && call.argument<Boolean>("on") == true)
                result.success(allowed)
            }
            "firstPermissionsVisit" -> {
                val prefs = app.getSharedPreferences("permissions", Context.MODE_PRIVATE)
                val first = !prefs.getBoolean("sheet_shown", false)
                if (first) prefs.edit().putBoolean("sheet_shown", true).apply()
                result.success(first)
            }
            "permissions" -> result.success(
                mapOf(
                    "notifications" to (Build.VERSION.SDK_INT < 33 || granted(Manifest.permission.POST_NOTIFICATIONS)),
                    "camera" to granted(Manifest.permission.CAMERA),
                ),
            )
            "activeShares" -> result.success(ShareService.active.values.toList())
            // Where the node and history live, and where received files go.
            "paths" -> result.success(
                mapOf("support" to app.filesDir.path, "external" to app.getExternalFilesDir(null)?.path),
            )
            "displayInput" -> {
                val session = call.argument<String>("session")!!
                val frames = call.argument<ByteArray>("frames")!!
                inputWriter.execute { NativeSession.write(session, frames) }
                result.success(null)
            }
            "webcamState" -> result.success(
                ShareService.webcams[call.argument<String>("session")!!]?.state()?.toString(),
            )
            "webcamSet" -> {
                ShareService.webcams[call.argument<String>("session")!!]
                    ?.set(org.json.JSONObject(call.argument<String>("controls")!!))
                result.success(null)
            }
            "stopShare" -> {
                ShareService.stop(app, call.argument<String>("session")!!)
                result.success(null)
            }            else -> return false
        }
        return true
    }

    fun prefs() = app.getSharedPreferences("linksy", Context.MODE_PRIVATE)

    /// A folder the user picked for Linksy (`files` to share, `photos` to back
    /// up, `received` to save into), if Android still grants it.
    fun folder(kind: String): android.net.Uri? {
        val uri = prefs().getString("folder.$kind", null)?.let(android.net.Uri::parse) ?: return null
        return uri.takeIf { u -> app.contentResolver.persistedUriPermissions.any { it.uri == u && it.isReadPermission } }
    }

    /// Gives Android's grant for [uri] back, unless another kind still uses it.
    fun letGoOf(uri: String, kind: String) {
        val stillUsed = listOf("files", "photos", "received").any { it != kind && prefs().getString("folder.$it", null) == uri }
        if (!stillUsed) runCatching {
            app.contentResolver.releasePersistableUriPermission(
                android.net.Uri.parse(uri),
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
        }
    }

    fun folderName(kind: String): String? {
        val tree = folder(kind) ?: return null
        val doc = android.provider.DocumentsContract.buildDocumentUriUsingTree(
            tree, android.provider.DocumentsContract.getTreeDocumentId(tree),
        )
        return runCatching {
            app.contentResolver.query(doc, arrayOf(android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
        }.getOrNull() ?: tree.lastPathSegment?.substringAfterLast(':')
    }

    private var controlsHere: Controls? = null

    private fun controls() = controlsHere ?: Controls(app) {
        channel.invokeMethod("controlsChanged", null)
    }.also { controlsHere = it }

    /// Android 15's screen share protections, which some phones (realme…)
    /// extend to the status bar and the notification shade: they come out
    /// black on the computer. "on", "off", "unknown" (the setting can't be
    /// read), or null before Android 15.
    private fun shareProtections(): String? {
        if (Build.VERSION.SDK_INT < 35) return null
        return try {
            when (Settings.Global.getInt(app.contentResolver, "disable_screen_share_protections_for_apps_and_notifications", 0)) {
                0 -> "on"
                else -> "off"
            }
        } catch (_: Exception) {
            "unknown"
        }
    }

    /// All files access (Android 11+): `allowed`, `denied`, or `unsupported` before
    /// Android 11, where it doesn't exist.
    fun allFilesState(): String = when {
        Build.VERSION.SDK_INT < 30 -> "unsupported"
        android.os.Environment.isExternalStorageManager() -> "allowed"
        else -> "denied"
    }

    /// What can keep this phone from its computers, for the Connection Doctor.
    private fun connectionFacts(): Map<String, Boolean> {
        val net = app.getSystemService(android.net.ConnectivityManager::class.java)
        val power = app.getSystemService(android.os.PowerManager::class.java)
        @Suppress("DEPRECATION")
        val all = net.allNetworks.mapNotNull { net.getNetworkCapabilities(it) }
        return mapOf(
            "wifi" to all.any {
                it.hasTransport(android.net.NetworkCapabilities.TRANSPORT_WIFI) ||
                    it.hasTransport(android.net.NetworkCapabilities.TRANSPORT_ETHERNET)
            },
            "vpn" to all.any { it.hasTransport(android.net.NetworkCapabilities.TRANSPORT_VPN) },
            "batteryFree" to power.isIgnoringBatteryOptimizations(app.packageName),
            "powerSave" to power.isPowerSaveMode,
            "dataSaver" to (net.restrictBackgroundStatus == android.net.ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED),
        )
    }

    /// Battery changes go to Dart, which tells paired computers (docs/protocol.md
    /// §4.5: on connecting, every 5 points, plugging in or out).
    private fun watchBattery() {
        if (batteryReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                battery(intent)?.let { channel.invokeMethod("batteryChanged", it) }
            }
        }
        batteryReceiver = receiver
        // A system broadcast: no export flag needed, and no permission.
        app.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    /// Level in percent and whether it's charging; the sticky broadcast when
    /// [intent] is null.
    private fun battery(intent: Intent?): Map<String, Any>? {
        val i = intent ?: app.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)) ?: return null
        val level = i.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = i.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        if (level < 0 || scale <= 0) return null
        val status = i.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val charging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        return mapOf("level" to (level * 100 / scale).coerceIn(0, 100), "charging" to charging)
    }

    /// What Linksy takes of the phone's memory (mobile#3), as `dumpsys meminfo`
    /// sums it: all of it (PSS), then its parts, in MB.
    fun memory(): String {
        val info = android.os.Debug.MemoryInfo()
        android.os.Debug.getMemoryInfo(info)
        fun mb(stat: String) = ((info.getMemoryStat(stat)?.toIntOrNull() ?: 0) + 512) / 1024
        val total = (info.totalPss + 512) / 1024
        return "$total MB (Java ${mb("summary.java-heap")}, native ${mb("summary.native-heap")}, " +
            "code ${mb("summary.code")}, graphics ${mb("summary.graphics")}, " +
            "stack ${mb("summary.stack")}, other ${mb("summary.private-other")}, " +
            "system ${mb("summary.system")})"
    }

    /// Settings › Logs: what this phone is and what its Wi-Fi can do, as label → value.
    /// Nothing that identifies the user (no network name, no addresses).
    private fun deviceReport(): Map<String, String> {
        val wifi = app.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val power = app.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
        val p2p = app.getSystemService(android.net.wifi.p2p.WifiP2pManager::class.java)
        @Suppress("DEPRECATION")
        val link = wifi.connectionInfo
        val yes = { b: Boolean -> if (b) "yes" else "no" }
        return linkedMapOf(
            "Device" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "Memory now" to memory(),
            "Android" to "${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
            "CPU" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "?"),
            "Wi-Fi" to if (!wifi.isWifiEnabled) "off"
                // The network's id is hidden from apps now; a frequency means connected
                else if (link == null || link.frequency <= 0) "on, not connected"
                else "${link.frequency} MHz, ${link.linkSpeed} Mbps",
            "5 GHz" to yes(wifi.is5GHzBandSupported),
            "6 GHz" to if (Build.VERSION.SDK_INT >= 30) yes(wifi.is6GHzBandSupported) else "?",
            "Wi-Fi Direct" to yes(DirectHost.supported(app)),
            "Fast search" to if (Build.VERSION.SDK_INT >= 33 && p2p != null) yes(p2p.isChannelConstrainedDiscoverySupported) else "no",
            "Nearby devices" to if (granted(DirectHost.permission())) "allowed" else "not allowed",
            "Battery limits" to if (power.isIgnoringBatteryOptimizations(app.packageName)) "off" else "on",
            "Starts with the phone" to if (Boot.wanted(app)) "yes" else "no",
        )
    }

    /// A direct link's group (phone to phone) from a call's `ssid`, `passphrase`, `frequency`.
    private fun directGroup(call: MethodCall): DirectHost.Group? {
        val ssid = call.argument<String>("ssid") ?: return null
        val passphrase = call.argument<String>("passphrase") ?: return null
        return DirectHost.Group(ssid, passphrase, call.argument<Int>("frequency"))
    }

    private fun granted(permission: String) =
        app.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /// A link a computer sent, in the browser. Web links only.
    private fun openUrl(url: String): Boolean {
        val uri = android.net.Uri.parse(url.trim())
        if (uri.scheme?.lowercase() !in setOf("http", "https")) return false
        val view = Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE)
        return try {
            activity?.startActivity(view) ?: app.startActivity(view.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: android.content.ActivityNotFoundException) {
            false
        }
    }

    /// The name the user gave this phone, else its model ("Pixel 9").
    private fun deviceName(): String {
        val given = Settings.Global.getString(app.contentResolver, Settings.Global.DEVICE_NAME)
        return given?.takeIf { it.isNotBlank() } ?: Build.MODEL
    }

    companion object {
        /// The engine started without the app (at boot), kept for the app to show
        /// once it's opened.
        var background: Bridge? = null
            private set

        /// Starts Linksy with no screen: the engine runs Dart's main() as when
        /// the app opens, and stays until the process ends.
        fun startInBackground(context: Context): Bridge {
            background?.let { return it }
            val engine = FlutterEngine(context.applicationContext)
            val bridge = Bridge(context, engine)
            background = bridge
            engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            return bridge
        }

        private var files: FileServer? = null

        /// One file server per process, whatever happens to the activity.
        fun fileServer(context: Context): FileServer =
            files ?: FileServer(context.applicationContext).also { files = it; it.start() }

        private var gallery: GalleryServer? = null

        fun galleryServer(context: Context): GalleryServer =
            gallery ?: GalleryServer(context.applicationContext).also { gallery = it; it.start() }
    }
}
