package app.linksy

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.os.BatteryManager
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import app.linksy.files.FileServer
import app.linksy.files.NativeFiles
import app.linksy.media.DisplayReceiver
import app.linksy.media.NativeSession
import app.linksy.media.QrScanner
import app.linksy.media.ShareService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var multicastLock: WifiManager.MulticastLock? = null

    /// A `linksy://pair?…` link that opened the app, until Dart asks for it.
    private var pendingLink: String? = null
    /// Something shared to Linksy from another app (text or file copies),
    /// until Dart asks for it.
    private var pendingShare: Map<String, Any>? = null

    private val ring by lazy { RingPlayer(applicationContext) }
    private var calls: CallWatcher? = null
    /// Waiting on the photo picker: which device, and Dart's reply.
    private var pendingPicture: Pair<String, MethodChannel.Result>? = null
    /// Waiting on Android's folder picker: which folder, and Dart's reply.
    private var pendingFolder: Pair<String, MethodChannel.Result>? = null
    private var batteryReceiver: BroadcastReceiver? = null

    /// Waiting on the system's screen capture prompt: the session and Dart's reply.
    private var pendingCapture: Pair<String, MethodChannel.Result>? = null
    /// Dart's replies waiting on Android's permission dialogs, by request code.
    private val pendingPermissions = mutableMapOf<Int, MethodChannel.Result>()

    private var engine: FlutterEngine? = null
    /// Second-display sessions on screen, by session.
    private val displays = mutableMapOf<String, DisplayReceiver>()
    /// Display input goes out in order, off the UI thread (writes can wait).
    private val inputWriter = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engine = flutterEngine
        networks?.stop()
        networks = NetworkWatcher(this) { channel?.invokeMethod("networkChanged", null) }.apply { start() }
        pendingLink = linkFrom(intent)
        takeShared(intent)
        watchBattery()
        Logs.sink = { line -> runOnUiThread { channel?.invokeMethod("log", line) } }
        ShareService.webcamListener = { session, state ->
            runOnUiThread { channel?.invokeMethod("webcamChanged", mapOf("session" to session, "state" to state.toString())) }
        }
        TransferNotice.answer = { transfer, accept ->
            runOnUiThread { channel?.invokeMethod("transferAnswer", mapOf("transfer" to transfer, "accept" to accept)) }
        }
        DirectHost.step = { device, step ->
            channel?.invokeMethod("directStep", step + ("device" to device))
        }
        Push.subscribe()
        Updater.onStatus = { status -> channel?.invokeMethod("updateStatus", status) }
        ComputerMedia.onAction = { action, position ->
            runOnUiThread { channel?.invokeMethod("mediaAction", mapOf("action" to action, "position_ms" to position)) }
        }
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.linksy/platform").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "deviceName" -> result.success(deviceName())
                    "appVersion" -> result.success(
                        packageManager.getPackageInfo(packageName, 0).let {
                            @Suppress("DEPRECATION")
                            "${it.versionName} (${if (Build.VERSION.SDK_INT >= 28) it.longVersionCode else it.versionCode.toLong()})"
                        },
                    )
                    "takeLink" -> {
                        result.success(pendingLink)
                        pendingLink = null
                    }
                    "pictures" -> result.success(Pictures.all(this@MainActivity))
                    "pickPicture" -> pickPicture(call.argument<String>("device")!!, result)
                    "removePicture" -> {
                        Pictures.remove(this@MainActivity, call.argument<String>("device")!!)
                        result.success(null)
                    }
                    "pickFolder" -> pickFolder(call.argument<String>("kind")!!, result)
                    "folder" -> result.success(folderName(call.argument<String>("kind")!!))
                    "shareFiles" -> {
                        val on = call.argument<Boolean>("on") == true
                        fileServer(this@MainActivity).root = folder("files")
                        NativeFiles.sharing(on && folder("files") != null)
                        result.success(null)
                    }
                    "directHost" -> result.success(DirectHost.supported(this@MainActivity))
                    "deviceReport" -> result.success(deviceReport())
                    "directWanted" -> {
                        DirectHost.want(this@MainActivity, call.argument<String>("device")!!, directGroup(call))
                        result.success(null)
                    }
                    "directJoin" -> {
                        val group = directGroup(call)
                        if (group != null) DirectHost.join(this@MainActivity, call.argument<String>("device")!!, group)
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
                                this@MainActivity,
                                call.argument<String>("text") ?: Lang.str(this@MainActivity, R.string.keep_alive_default),
                                call.argument<Boolean>("awake") == true,
                                call.argument<String>("title"),
                                call.argument<Int>("progress"),
                            )
                        } else {
                            KeepAlive.stop(this@MainActivity)
                        }
                        result.success(null)
                    }
                    "watchCalls" -> {
                        calls?.stop()
                        calls = null
                        if (call.argument<Boolean>("on") == true) {
                            calls = CallWatcher(applicationContext) { state -> channel?.invokeMethod("callState", state) }.apply { start() }
                        }
                        result.success(null)
                    }
                    "photoBatch" -> {
                        val tree = folder("photos") ?: return@setMethodCallHandler result.success(null)
                        val since = (call.argument<Number>("since") ?: 0).toLong()
                        Thread {
                            val batch = runCatching { PhotoScanner.batch(applicationContext, tree, since) }.getOrNull()
                            runOnUiThread { result.success(batch) }
                        }.start()
                    }
                    "volumeSteps" -> {
                        stepping = call.argument<Boolean>("on") == true
                        result.success(null)
                    }
                    "presentation" -> {
                        presenting = call.argument<Boolean>("on") == true
                        updateScreenOn()
                        result.success(null)
                    }
                    "keepScreenOn" -> {
                        val session = call.argument<String>("session")!!
                        if (call.argument<Boolean>("on") == true) screenOn += session else screenOn -= session
                        updateScreenOn()
                        result.success(null)
                    }
                    "screenSize" -> result.success(screenSize())
                    "shareProtections" -> result.success(shareProtections())
                    "developerOptions" -> result.success(openDeveloperOptions())
                    "abi" -> result.success(Updater.abi())
                    "updatesAllowed" -> result.success(Updater.allowed(this@MainActivity))
                    "allowUpdates" -> {
                        Updater.allow(this@MainActivity)
                        result.success(null)
                    }
                    "installUpdate" -> {
                        Updater.install(this@MainActivity, call.argument<String>("path")!!, call.argument<String>("sha256")!!)
                        result.success(null)
                    }
                    "pictureJpeg" -> {
                        val path = call.argument<String>("path")!!
                        Thread { Clip.pictureJpeg(path).let { runOnUiThread { result.success(it) } } }.start()
                    }
                    "clipboardFile" -> result.success(Clip.put(this@MainActivity, call.argument<String>("path")!!))
                    "locate" -> Locator.fix(this@MainActivity) { result.success(it) }
                    "usbPort" -> result.success(UsbBridge.current?.port ?: openUsb(null))
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
                        Thread { ShareShortcuts.update(applicationContext, devices) }.start()
                        result.success(null)
                    }
                    "sharedTo" -> {
                        ShareShortcuts.used(applicationContext, call.arguments as String)
                        result.success(null)
                    }
                    "takeShare" -> {
                        result.success(pendingShare)
                        pendingShare = null
                    }
                    "battery" -> result.success(battery(null))
                    "noticeTransfer" -> {
                        TransferNotice.post(
                            this@MainActivity, call.argument<String>("transfer")!!,
                            call.argument<String>("title")!!, call.argument<String>("body") ?: "",
                        )
                        result.success(null)
                    }
                    "cancelNotice" -> {
                        TransferNotice.cancel(this@MainActivity, call.argument<String>("transfer")!!)
                        result.success(null)
                    }
                    "publishDownloads" -> {
                        val paths = call.argument<List<String>>("paths").orEmpty()
                        val root = java.io.File(getExternalFilesDir(null), "Received")
                        Thread {
                            val moved = Downloads.publish(applicationContext, root, paths)
                            runOnUiThread { result.success(moved) }
                        }.start()
                    }
                    "pushToken" -> Push.token { token -> runOnUiThread { result.success(token) } }
                    "openUrl" -> result.success(openUrl(call.argument<String>("url")!!))
                    "mediaNotice" -> {
                        @Suppress("UNCHECKED_CAST")
                        ComputerMedia.show(applicationContext, call.arguments as Map<String, Any?>?)
                        result.success(null)
                    }
                    "startRing" -> {
                        ring.start()
                        result.success(null)
                    }
                    "stopRing" -> {
                        ring.stop()
        calls?.stop()
                        result.success(null)
                    }
                    "requestScreenCapture" -> requestScreenCapture(call.argument<String>("session")!!, result)
                    "requestCamera" -> requestPermission(Manifest.permission.CAMERA, REQUEST_CAMERA, result)
                    "requestPermission" -> when (call.argument<String>("name")) {
                        "camera" -> requestPermission(Manifest.permission.CAMERA, REQUEST_CAMERA, result)
                        "microphone" -> requestPermission(Manifest.permission.RECORD_AUDIO, REQUEST_MICROPHONE, result)
                        "location" -> requestPermission(Manifest.permission.ACCESS_FINE_LOCATION, REQUEST_LOCATION, result)
                        "nearby" -> requestPermission(DirectHost.permission(), REQUEST_NEARBY, result)
                        "notifications" -> if (Build.VERSION.SDK_INT >= 33) {
                            requestPermission(Manifest.permission.POST_NOTIFICATIONS, REQUEST_NOTIFICATIONS, result)
                        } else {
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                    // True once per install: whether to show the permissions sheet.
                    "firstPermissionsVisit" -> {
                        val prefs = getSharedPreferences("permissions", MODE_PRIVATE)
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
                    "startShare" -> {
                        ShareService.start(
                            this@MainActivity,
                            call.argument<String>("session")!!,
                            call.argument<String>("kind")!!,
                            call.argument<String>("peer") ?: Lang.str(this@MainActivity, R.string.your_computer),
                            call.argument<String>("peerId") ?: "",
                        )
                        result.success(null)
                    }
                    "activeShares" -> result.success(ShareService.active.values.toList())
                    // Where the node and history live, and where received files go.
                    "paths" -> result.success(
                        mapOf("support" to filesDir.path, "external" to getExternalFilesDir(null)?.path),
                    )
                    "pickFiles" -> pickFiles(result)
                    "pickMedia" -> pickMedia(result)
                    "openFile" -> result.success(openFile(call.argument<String>("path")!!))
                    "startScanner" -> result.success(startScanner())
                    "stopScanner" -> {
                        scanner?.stop()
                        scanner = null
                        result.success(null)
                    }
                    "scannerTorch" -> {
                        scanner?.setTorch(call.argument<Boolean>("on") == true)
                        result.success(null)
                    }
                    "startDisplay" -> result.success(startDisplay(call.argument<String>("session")!!))
                    "stopDisplay" -> {
                        displays.remove(call.argument<String>("session")!!)?.stop()
                        result.success(null)
                    }
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
                    "webcamPreview" -> result.success(
                        webcamPreview(call.argument<String>("session")!!, call.argument<Boolean>("on") == true),
                    )
                    "switchCamera" -> {
                        ShareService.switchCamera(this@MainActivity, call.argument<String>("session")!!)
                        result.success(null)
                    }
                    "stopShare" -> {
                        ShareService.stop(this@MainActivity, call.argument<String>("session")!!)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        // After the channel: a bridge opened now reaches Dart.
        watchUsb()
        openUsb(intent?.takeIf { it.action == android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED })
    }

    /// Presentation remote: the volume keys change slides instead of volume.
    private var presenting = false
    private var stepping = false

    /// Sessions that keep the screen on: a second display, a computer's
    /// screen watched (docs/protocol.md §4.8: the timeout ended them).
    private val screenOn = mutableSetOf<String>()

    private fun updateScreenOn() {
        val flag = android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        if (presenting || screenOn.isNotEmpty()) window.addFlags(flag) else window.clearFlags(flag)
    }

    /// Android 15's screen share protections, which some phones (realme…)
    /// extend to the status bar and the notification shade: they come out
    /// black on the computer. "on", "off", "unknown" (the setting can't be
    /// read), or null before Android 15.
    private fun shareProtections(): String? {
        if (Build.VERSION.SDK_INT < 35) return null
        return try {
            when (Settings.Global.getInt(contentResolver, "disable_screen_share_protections_for_apps_and_notifications", 0)) {
                0 -> "on"
                else -> "off"
            }
        } catch (_: Exception) {
            "unknown"
        }
    }

    /// Developer options if they're on, else About phone (tap Build number
    /// seven times there).
    private fun openDeveloperOptions(): Boolean {
        val on = Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0
        val action = if (on) Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS else Settings.ACTION_DEVICE_INFO_SETTINGS
        return runCatching { startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }.isSuccess
    }

    /// The screen in landscape, long side first, in pixels.
    private fun screenSize(): Map<String, Int> {
        val (w, h) = if (Build.VERSION.SDK_INT >= 30) {
            windowManager.maximumWindowMetrics.bounds.let { it.width() to it.height() }
        } else {
            val m = android.util.DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(m)
            m.widthPixels to m.heightPixels
        }
        return mapOf("width" to maxOf(w, h), "height" to minOf(w, h))
    }

    /// A Linksy computer on the USB cable (§4.11): opens the bridge and
    /// tells Dart its port, so the node dials the computer through it.
    private fun openUsb(intent: Intent?): Int? {
        val accessory = intent?.let {
            @Suppress("DEPRECATION")
            if (Build.VERSION.SDK_INT >= 33) it.getParcelableExtra(android.hardware.usb.UsbManager.EXTRA_ACCESSORY, android.hardware.usb.UsbAccessory::class.java)
            else it.getParcelableExtra(android.hardware.usb.UsbManager.EXTRA_ACCESSORY)
        }
        val before = UsbBridge.current
        val port = if (accessory != null) UsbBridge.open(this, accessory) else UsbBridge.openAttached(this)
        if (port != null && UsbBridge.current !== before) {
            channel?.invokeMethod("usbPort", port)
            // The step people get stuck on: show Linksy, now on the cable.
            if (!resumed) runCatching {
                startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_NEW_TASK))
            }
        }
        return port
    }

    private var usbReceiver: BroadcastReceiver? = null
    private var resumed = false
    private val usbPoll = android.os.Handler(android.os.Looper.getMainLooper())
    private val usbTick = object : Runnable {
        override fun run() {
            if (UsbBridge.current == null) openUsb(null)
            if (resumed) usbPoll.postDelayed(this, 1500)
        }
    }

    /// Some phones (realme/ColorOS) never deliver USB_ACCESSORY_ATTACHED or
    /// show the "open with" prompt, but list the accessory: watch for it
    /// while the app runs, and hear the permission answer and unplugging.
    private fun watchUsb() {
        if (usbReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    UsbBridge.ACTION_PERMISSION -> {
                        val granted = intent.getBooleanExtra(android.hardware.usb.UsbManager.EXTRA_PERMISSION_GRANTED, false)
                        UsbBridge.answered(granted)
                        UsbBridge.say("permission ${if (granted) "granted" else "refused"}")
                        if (granted) openUsb(intent)
                    }
                    android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED -> openUsb(intent)
                    android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_DETACHED -> UsbBridge.detached()
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(UsbBridge.ACTION_PERMISSION)
            addAction(android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED)
            addAction(android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_DETACHED)
        }
        // Not exported: the permission answer comes from the system's PendingIntent.
        if (Build.VERSION.SDK_INT >= 33) registerReceiver(receiver, filter, RECEIVER_NOT_EXPORTED)
        else registerReceiver(receiver, filter)
        usbReceiver = receiver
    }

    override fun onResume() {
        super.onResume()
        resumed = true
        usbPoll.removeCallbacks(usbTick)
        usbPoll.post(usbTick)
        // A direct link's permission is asked only while Linksy is in front
        DirectHost.ask = { permission, answer ->
            pendingDirect?.invoke(false)
            pendingDirect = answer
            requestPermissions(arrayOf(permission), REQUEST_DIRECT)
        }
    }

    /// The answer to the direct link's permission dialog.
    private var pendingDirect: ((Boolean) -> Unit)? = null

    override fun onPause() {
        resumed = false
        DirectHost.ask = null
        usbPoll.removeCallbacks(usbTick)
        super.onPause()
    }

    override fun dispatchKeyEvent(event: android.view.KeyEvent): Boolean {
        val code = event.keyCode
        if (presenting && (code == android.view.KeyEvent.KEYCODE_VOLUME_UP || code == android.view.KeyEvent.KEYCODE_VOLUME_DOWN)) {
            if (event.action == android.view.KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                channel?.invokeMethod("volumeKey", if (code == android.view.KeyEvent.KEYCODE_VOLUME_UP) "up" else "down")
            }
            return true
        }
        if (stepping && (code == android.view.KeyEvent.KEYCODE_VOLUME_UP || code == android.view.KeyEvent.KEYCODE_VOLUME_DOWN)) {
            if (event.action == android.view.KeyEvent.ACTION_DOWN) {
                channel?.invokeMethod("volumeKey", if (code == android.view.KeyEvent.KEYCODE_VOLUME_UP) "up" else "down")
            }
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        takeShared(intent)
        if (intent.action == android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED) openUsb(intent)
        intent.getStringExtra(ShareService.EXTRA_WEBCAM)?.let { channel?.invokeMethod("openWebcam", it) }
        val link = linkFrom(intent) ?: return
        channel?.invokeMethod("link", link) ?: run { pendingLink = link }
    }

    private fun prefs() = getSharedPreferences("linksy", MODE_PRIVATE)

    /// A folder the user picked for Linksy (`files` to share, `photos` to back
    /// up), if Android still grants it.
    private fun folder(kind: String): android.net.Uri? {
        val uri = prefs().getString("folder.$kind", null)?.let(android.net.Uri::parse) ?: return null
        return uri.takeIf { u -> contentResolver.persistedUriPermissions.any { it.uri == u && it.isReadPermission } }
    }

    private fun folderName(kind: String): String? {
        val tree = folder(kind) ?: return null
        val doc = android.provider.DocumentsContract.buildDocumentUriUsingTree(
            tree, android.provider.DocumentsContract.getTreeDocumentId(tree),
        )
        return runCatching {
            contentResolver.query(doc, arrayOf(android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
        }.getOrNull() ?: tree.lastPathSegment?.substringAfterLast(':')
    }

    /// Android's photo picker (no permission), or the document picker on
    /// phones without it.
    private fun pickPicture(device: String, result: MethodChannel.Result) {
        pendingPicture?.second?.success(null)
        pendingPicture = device to result
        val intent = if (Build.VERSION.SDK_INT >= 33) {
            Intent(android.provider.MediaStore.ACTION_PICK_IMAGES)
        } else {
            Intent(Intent.ACTION_GET_CONTENT).setType("image/*").addCategory(Intent.CATEGORY_OPENABLE)
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_PICTURE)
    }

    /// Android's folder picker; the grant is kept across restarts.
    private fun pickFolder(kind: String, result: MethodChannel.Result) {
        pendingFolder?.second?.success(null)
        pendingFolder = kind to result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )
        if (kind == "photos" && Build.VERSION.SDK_INT >= 26) {
            intent.putExtra(
                android.provider.DocumentsContract.EXTRA_INITIAL_URI,
                android.provider.DocumentsContract.buildDocumentUri("com.android.externalstorage.documents", "primary:DCIM"),
            )
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_FOLDER)
    }

    /// "Share → Linksy", handed over by [ShareTarget] (files already copied).
    private fun takeShared(intent: Intent?) {
        if (intent?.action != ShareTarget.ACTION_SHARED) return
        // Handled once, even if the activity is recreated with this intent.
        setIntent(Intent(Intent.ACTION_MAIN))
        val files = intent.getStringArrayExtra(ShareTarget.EXTRA_FILES)?.toList().orEmpty()
        val text = intent.getStringExtra(ShareTarget.EXTRA_TEXT)
        val device = intent.getStringExtra(ShareTarget.EXTRA_DEVICE)
        val to = if (device != null) mapOf("device" to device) else emptyMap()
        when {
            files.isNotEmpty() -> deliverShare(mapOf("files" to files) + to)
            !text.isNullOrBlank() -> deliverShare(mapOf("text" to text) + to)
        }
    }

    private fun deliverShare(share: Map<String, Any>) {
        val c = channel
        if (c == null) pendingShare = share else c.invokeMethod("share", share)
    }

    /// Battery changes go to Dart, which tells paired computers (docs/protocol.md
    /// §4.5: on connecting, every 5 points, plugging in or out).
    private fun watchBattery() {
        if (batteryReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                battery(intent)?.let { channel?.invokeMethod("batteryChanged", it) }
            }
        }
        batteryReceiver = receiver
        // A system broadcast: no export flag needed, and no permission.
        registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    /// Level in percent and whether it's charging; the sticky broadcast when
    /// [intent] is null.
    private fun battery(intent: Intent?): Map<String, Any>? {
        val i = intent ?: registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)) ?: return null
        val level = i.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = i.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        if (level < 0 || scale <= 0) return null
        val status = i.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val charging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        return mapOf("level" to (level * 100 / scale).coerceIn(0, 100), "charging" to charging)
    }

    // mDNS presence needs multicast, which Android filters out unless an app
    // holds a lock. Hold it only while the app is on screen.
    override fun onStart() {
        super.onStart()
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("linksy").apply {
            setReferenceCounted(false)
            acquire()
        }
    }

    override fun onStop() {
        multicastLock?.takeIf { it.isHeld }?.release()
        multicastLock = null
        super.onStop()
    }

    /// Webcam previews on screen, by session.
    private val previews = mutableMapOf<String, io.flutter.view.TextureRegistry.SurfaceProducer>()

    /// Shows a running webcam in a Flutter texture (its id), or stops.
    private fun webcamPreview(session: String, on: Boolean): Long? {
        val camera = ShareService.webcams[session]
        if (!on || camera == null) {
            camera?.setPreview(null)
            previews.remove(session)?.release()
            return null
        }
        previews[session]?.let { return it.id() }
        val producer = engine?.renderer?.createSurfaceProducer() ?: return null
        producer.setSize(camera.size.width, camera.size.height)
        producer.setCallback(object : io.flutter.view.TextureRegistry.SurfaceProducer.Callback {
            // The texture gets a new surface when the app comes back.
            override fun onSurfaceAvailable() {
                camera.setPreview(producer.surface)
            }

            override fun onSurfaceCleanup() {
                camera.setPreview(null)
            }
        })
        camera.setPreview(producer.surface)
        previews[session] = producer
        return producer.id()
    }

    /// Decodes a second-display session into a new Flutter texture; returns
    /// its id for Dart's `Texture` widget.
    private fun startDisplay(session: String): Long? {
        val producer = engine?.renderer?.createSurfaceProducer() ?: return null
        displays[session] = DisplayReceiver(
            session, producer,
            onSize = { w, h ->
                runOnUiThread { channel?.invokeMethod("displaySize", mapOf("session" to session, "width" to w, "height" to h)) }
            },
            onEnded = { runOnUiThread { channel?.invokeMethod("displayEnded", session) } },
        )
        return producer.id()
    }

    /// Network changes, for the core (§4.13).
    private var networks: NetworkWatcher? = null

    override fun onDestroy() {
        networks?.stop()
        networks = null
        TransferNotice.answer = null
        DirectHost.step = null
        ShareService.webcamListener = null
        previews.keys.toList().forEach { webcamPreview(it, false) }
        batteryReceiver?.let { runCatching { unregisterReceiver(it) } }
        batteryReceiver = null
        usbReceiver?.let { runCatching { unregisterReceiver(it) } }
        usbReceiver = null
        usbPoll.removeCallbacks(usbTick)
        ring.stop()
        scanner?.stop()
        displays.values.forEach { it.stop() }
        displays.clear()
        inputWriter.shutdown()
        super.onDestroy()
    }

    /// Android's own "start recording or casting?" prompt. The consent is kept
    /// for the session until the share service starts.
    private fun requestScreenCapture(session: String, result: MethodChannel.Result) {
        askNotifications()
        pendingCapture?.second?.success(false)
        pendingCapture = session to result
        val manager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        // The whole screen only: Android 14+ otherwise preselects "A single
        // app", which leaves the status bar, notifications and quick settings
        // black on the computer.
        val intent = if (Build.VERSION.SDK_INT >= 34) {
            manager.createScreenCaptureIntent(android.media.projection.MediaProjectionConfig.createConfigForDefaultDisplay())
        } else {
            manager.createScreenCaptureIntent()
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_CAPTURE)
    }

    /// Settings › Logs: what this phone is and what its Wi-Fi can do, as label → value.
    /// Nothing that identifies the user (no network name, no addresses).
    private fun deviceReport(): Map<String, String> {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val power = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
        val p2p = getSystemService(android.net.wifi.p2p.WifiP2pManager::class.java)
        @Suppress("DEPRECATION")
        val link = wifi.connectionInfo
        val yes = { b: Boolean -> if (b) "yes" else "no" }
        return linkedMapOf(
            "Device" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "Android" to "${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
            "CPU" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "?"),
            "Wi-Fi" to if (!wifi.isWifiEnabled) "off"
                // The network's id is hidden from apps now; a frequency means connected
                else if (link == null || link.frequency <= 0) "on, not connected"
                else "${link.frequency} MHz, ${link.linkSpeed} Mbps",
            "5 GHz" to yes(wifi.is5GHzBandSupported),
            "6 GHz" to if (Build.VERSION.SDK_INT >= 30) yes(wifi.is6GHzBandSupported) else "?",
            "Wi-Fi Direct" to yes(DirectHost.supported(this)),
            "Fast search" to if (Build.VERSION.SDK_INT >= 33 && p2p != null) yes(p2p.isChannelConstrainedDiscoverySupported) else "no",
            "Nearby devices" to if (granted(DirectHost.permission())) "allowed" else "not allowed",
            "Battery limits" to if (power.isIgnoringBatteryOptimizations(packageName)) "off" else "on",
        )
    }

    /// A direct link's group (phone to phone) from a call's `ssid`, `passphrase`, `frequency`.
    private fun directGroup(call: MethodCall): DirectHost.Group? {
        val ssid = call.argument<String>("ssid") ?: return null
        val passphrase = call.argument<String>("passphrase") ?: return null
        return DirectHost.Group(ssid, passphrase, call.argument<Int>("frequency"))
    }

    private fun granted(permission: String) =
        checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /// Android's own permission dialog. Once the user has refused and Android
    /// stops showing it, opens Linksy's app settings instead, where it can
    /// still be turned on. Replies true only if granted now.
    private fun requestPermission(permission: String, code: Int, result: MethodChannel.Result) {
        // Android 12+ shows the location dialog only when coarse is asked too;
        // either is enough for one fix.
        val also = if (permission == Manifest.permission.ACCESS_FINE_LOCATION) Manifest.permission.ACCESS_COARSE_LOCATION else null
        if (granted(permission) || (also != null && granted(also))) {
            result.success(true)
            return
        }
        val prefs = getSharedPreferences("permissions", MODE_PRIVATE)
        if (prefs.getBoolean(permission, false) && !shouldShowRequestPermissionRationale(permission)) {
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, android.net.Uri.fromParts("package", packageName, null)),
            )
            result.success(false)
            return
        }
        prefs.edit().putBoolean(permission, true).apply()
        pendingPermissions.remove(code)?.success(false)
        pendingPermissions[code] = result
        requestPermissions(listOfNotNull(permission, also).toTypedArray(), code)
    }

    /// The sharing notification (and its Stop button) needs this on Android
    /// 13+; asked in passing, without waiting for the answer.
    private fun askNotifications() {
        if (Build.VERSION.SDK_INT >= 33 && !granted(Manifest.permission.POST_NOTIFICATIONS) &&
            !pendingPermissions.containsKey(REQUEST_NOTIFICATIONS)
        ) {
            getSharedPreferences("permissions", MODE_PRIVATE).edit()
                .putBoolean(Manifest.permission.POST_NOTIFICATIONS, true).apply()
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
        }
    }

    private var scanner: QrScanner? = null
    private var pendingPick: MethodChannel.Result? = null

    /// The pairing QR scanner, previewed into a new Flutter texture.
    private fun startScanner(): Map<String, Any>? {
        scanner?.stop()
        val producer = engine?.renderer?.createSurfaceProducer() ?: return null
        val s = QrScanner(
            this, producer,
            onCode = { text -> runOnUiThread { channel?.invokeMethod("qrCode", text) } },
            onError = { message -> runOnUiThread { channel?.invokeMethod("scannerError", message) } },
        )
        scanner = s
        return mapOf("texture" to producer.id(), "width" to s.size.width, "height" to s.size.height, "rotation" to s.rotation)
    }

    /// Android's document picker. The node sends from paths, so the picks are
    /// copied into the app's cache first (docs/protocol.md §7: no reader API yet).
    private fun pickFiles(result: MethodChannel.Result) {
        pendingPick?.success(emptyList<String>())
        pendingPick = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("*/*")
            .putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_PICK)
    }

    /// Android's photo picker: the gallery, many photos and videos at once,
    /// no storage permission. Phones without it get the document picker
    /// limited to photos and videos. Copied like [pickFiles].
    private fun pickMedia(result: MethodChannel.Result) {
        pendingPick?.success(emptyList<String>())
        pendingPick = result
        val picker = Build.VERSION.SDK_INT >= 33 ||
            (Build.VERSION.SDK_INT >= 30 && android.os.ext.SdkExtensions.getExtensionVersion(Build.VERSION_CODES.R) >= 2)
        val intent = if (picker) {
            Intent(android.provider.MediaStore.ACTION_PICK_IMAGES)
                .putExtra(android.provider.MediaStore.EXTRA_PICK_IMAGES_MAX, android.provider.MediaStore.getPickImagesMaxLimit())
        } else {
            Intent(Intent.ACTION_OPEN_DOCUMENT)
                .addCategory(Intent.CATEGORY_OPENABLE)
                .setType("*/*")
                .putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("image/*", "video/*"))
                .putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_PICK)
    }

    /// A link a computer sent, in the browser. Web links only.
    private fun openUrl(url: String): Boolean {
        val uri = android.net.Uri.parse(url.trim())
        if (uri.scheme?.lowercase() !in setOf("http", "https")) return false
        return try {
            startActivity(Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE))
            true
        } catch (e: android.content.ActivityNotFoundException) {
            false
        }
    }

    /// Opens a received file in another app: "done", "missing" or "noApp".
    private fun openFile(path: String): String {
        if (path.startsWith("content://")) {
            val uri = android.net.Uri.parse(path)
            val type = contentResolver.getType(uri) ?: return "missing"
            val view = Intent(Intent.ACTION_VIEW).setDataAndType(uri, type).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            return try {
                startActivity(Intent.createChooser(view, null).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
                "done"
            } catch (e: android.content.ActivityNotFoundException) {
                "noApp"
            }
        }
        val file = java.io.File(path)
        if (!file.isFile) return "missing"
        val root = java.io.File(getExternalFilesDir(null), "Received").canonicalPath
        val relative = file.canonicalPath.removePrefix(root).trimStart('/')
        val uri = android.net.Uri.Builder().scheme("content").authority(ReceivedFiles.authority(this))
            .encodedPath("/" + relative.split('/').joinToString("/") { android.net.Uri.encode(it) }).build()
        val view = Intent(Intent.ACTION_VIEW).setDataAndType(uri, ReceivedFiles.mime(file.name))
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        return try {
            startActivity(Intent.createChooser(view, null).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
            "done"
        } catch (e: android.content.ActivityNotFoundException) {
            "noApp"
        }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_PICTURE) {
            val (device, result) = pendingPicture ?: return
            pendingPicture = null
            val uri = data?.data
            if (resultCode != RESULT_OK || uri == null) return result.success(null)
            Thread {
                val path = Pictures.save(applicationContext, device, uri)
                runOnUiThread { result.success(path) }
            }.start()
            return
        }
        if (requestCode == REQUEST_FOLDER) {
            val (kind, result) = pendingFolder ?: return
            pendingFolder = null
            val uri = data?.data
            if (resultCode != RESULT_OK || uri == null) return result.success(null)
            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                (if (kind == "files") Intent.FLAG_GRANT_WRITE_URI_PERMISSION else 0)
            runCatching { contentResolver.takePersistableUriPermission(uri, flags) }
            // Let go of the folder this replaces.
            prefs().getString("folder.$kind", null)?.takeIf { it != uri.toString() }?.let { old ->
                val stillUsed = listOf("files", "photos").any { it != kind && prefs().getString("folder.$it", null) == old }
                if (!stillUsed) runCatching {
                    contentResolver.releasePersistableUriPermission(
                        android.net.Uri.parse(old),
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                    )
                }
            }
            prefs().edit().putString("folder.$kind", uri.toString()).apply()
            if (kind == "files") fileServer(this).root = uri
            return result.success(folderName(kind))
        }
        if (requestCode == REQUEST_PICK) {
            val result = pendingPick ?: return
            pendingPick = null
            val uris = buildList {
                data?.clipData?.let { clip -> for (i in 0 until clip.itemCount) add(clip.getItemAt(i).uri) }
                if (isEmpty()) data?.data?.let(::add)
            }
            if (resultCode != RESULT_OK || uris.isEmpty()) return result.success(emptyList<String>())
            Thread { val paths = ShareTarget.copyUris(this, uris, "picked"); runOnUiThread { result.success(paths) } }.start()
            return
        }
        if (requestCode != REQUEST_CAPTURE) return
        val (session, result) = pendingCapture ?: return
        pendingCapture = null
        if (resultCode == RESULT_OK && data != null) {
            ShareService.consents[session] = resultCode to data
            result.success(true)
        } else {
            result.success(false)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_DIRECT) {
            pendingDirect?.invoke(grantResults.any { it == PackageManager.PERMISSION_GRANTED })
            pendingDirect = null
        }
        pendingPermissions.remove(requestCode)
            ?.success(grantResults.any { it == PackageManager.PERMISSION_GRANTED })
    }

    private fun linkFrom(intent: Intent?): String? =
        intent?.data?.takeIf { it.scheme == "linksy" && it.host == "pair" }?.toString()

    /// The name the user gave this phone, else its model ("Pixel 9").
    private fun deviceName(): String {
        val given = Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME)
        return given?.takeIf { it.isNotBlank() } ?: Build.MODEL
    }

    private companion object {
        const val REQUEST_CAPTURE = 41
        const val REQUEST_CAMERA = 42
        const val REQUEST_NOTIFICATIONS = 43
        const val REQUEST_MICROPHONE = 48
        const val REQUEST_LOCATION = 49
        const val REQUEST_DIRECT = 50
        const val REQUEST_NEARBY = 51
        const val REQUEST_PICK = 44
        const val REQUEST_FOLDER = 45
        const val REQUEST_PICTURE = 46

        private var files: FileServer? = null

        /// One file server per process, whatever happens to the activity.
        fun fileServer(context: Context): FileServer =
            files ?: FileServer(context.applicationContext).also { files = it; it.start() }
    }
}
