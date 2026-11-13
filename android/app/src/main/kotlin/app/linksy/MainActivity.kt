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
import app.linksy.files.GalleryServer
import app.linksy.files.NativeFiles
import app.linksy.files.NativeGallery
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

    /// A computer's ask whose notification started the app.
    private var pendingTurnOn: Map<String, String>? = null
    /// Something shared to Linksy from another app (text or file copies),
    /// until Dart asks for it.
    private var pendingShare: Map<String, Any>? = null
    private var pendingSendFolder: MethodChannel.Result? = null

    /// Waiting on the photo picker: which device, and Dart's reply.
    private var pendingPicture: Pair<String, MethodChannel.Result>? = null
    private var pendingNotificationAccess: MethodChannel.Result? = null
    /// Waiting on Android's folder picker: which folder, and Dart's reply.
    private var pendingFolder: Pair<String, MethodChannel.Result>? = null

    /// Waiting on the system's screen capture prompt: the session and Dart's reply.
    private var pendingCapture: Pair<String, MethodChannel.Result>? = null
    /// Dart's replies waiting on Android's permission dialogs, by request code.
    private val pendingPermissions = mutableMapOf<Int, MethodChannel.Result>()

    private var engine: FlutterEngine? = null
    private var bridge: Bridge? = null
    /// Second-display sessions on screen, by session.
    private val displays = mutableMapOf<String, DisplayReceiver>()

    /// The engine Linksy started with at boot, if it did: the app shows it
    /// instead of starting a second one.
    override fun provideFlutterEngine(context: Context): FlutterEngine? = Bridge.background?.engine

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engine = flutterEngine
        val running = Bridge.background?.takeIf { it.engine === flutterEngine }
        pendingLink = linkFrom(intent)
        pendingTurnOn = turnOnFrom(intent)
        // Before the channel: Dart asks for it once it has started.
        if (running == null) takeShared(intent)
        val b = (running ?: Bridge(this, flutterEngine)).also { it.activity = this }
        bridge = b
        channel = b.channel
        if (running != null) {
            // Dart started long ago and asked already: hand these over now.
            takeShared(intent)
            pendingLink?.let { b.channel.invokeMethod("link", it) }
            pendingLink = null
            if (pendingTurnOn != null) b.channel.invokeMethod("turnOn", null)
            b.channel.invokeMethod("shown", null)
        }
        // After the channel: a bridge opened now reaches Dart.
        watchUsb()
        openUsb(intent?.takeIf { it.action == android.hardware.usb.UsbManager.ACTION_USB_ACCESSORY_ATTACHED })
    }

    /// The calls only an activity can answer: dialogs, pickers, the window.
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "takeLink" -> {
                result.success(pendingLink)
                pendingLink = null
            }
            "takeTurnOn" -> {
                result.success(pendingTurnOn)
                pendingTurnOn = null
            }
            "pickPicture" -> pickPicture(call.argument<String>("device")!!, result)
            "pickFolder" -> pickFolder(call.argument<String>("kind")!!, result)
            "askNotificationAccess" -> {
                // Android's page; the answer comes back with the user.
                pendingNotificationAccess?.success(PhoneNotifications.allowed(this@MainActivity))
                pendingNotificationAccess = result
                val opened = runCatching {
                    startActivityForResult(PhoneNotifications.settingsIntent(this@MainActivity), REQUEST_NOTIFICATION_ACCESS)
                }.recoverCatching {
                    startActivityForResult(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS), REQUEST_NOTIFICATION_ACCESS)
                }
                if (opened.isFailure) {
                    pendingNotificationAccess = null
                    result.success(PhoneNotifications.allowed(this@MainActivity))
                }
            }
            "openAppInfo" -> {
                runCatching {
                    startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, android.net.Uri.parse("package:$packageName")))
                }
                result.success(null)
            }
            "allowAllFiles" -> {
                // Android's own page for it; the app hears back on resume.
                runCatching {
                    startActivity(Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION, android.net.Uri.parse("package:$packageName")))
                }.onFailure { runCatching { startActivity(Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)) } }
                result.success(null)
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
            "dimScreen" -> {
                dimScreen(call.argument<Double>("level"))
                result.success(null)
            }
            "screenSize" -> result.success(screenSize())
            "developerOptions" -> result.success(openDeveloperOptions())
            "usbPort" -> result.success(UsbBridge.current?.port ?: openUsb(null))
            "takeShare" -> {
                result.success(pendingShare)
                pendingShare = null
            }
            "toBackground" -> result.success(moveTaskToBack(true))
            "openMap" -> {
                val lat = call.argument<Double>("lat")!!
                val lon = call.argument<Double>("lon")!!
                val uri = android.net.Uri.parse("geo:$lat,$lon?q=$lat,$lon")
                result.success(runCatching { startActivity(Intent(Intent.ACTION_VIEW, uri)) }.isSuccess)
            }
            "pickSendFolder" -> {
                pendingSendFolder?.success(null)
                pendingSendFolder = result
                startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE), REQUEST_SEND_FOLDER)
            }
            "openDndAccess" -> {
                runCatching { startActivity(Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)) }
                result.success(null)
            }
            "snap" -> {
                startActivity(
                    Intent(this@MainActivity, SnapActivity::class.java)
                        .putExtra(ShareTarget.EXTRA_DEVICE, call.arguments as String?),
                )
                result.success(null)
            }
            "fullScreen" -> {
                if (android.os.Build.VERSION.SDK_INT >= 28) {
                    window.attributes = window.attributes.apply {
                        layoutInDisplayCutoutMode = if (call.arguments as Boolean) {
                            android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                        } else {
                            android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT
                        }
                    }
                }
                result.success(null)
            }
            "highRefresh" -> {
                highRefresh(call.arguments as Boolean)
                result.success(null)
            }
            "openSystem" -> {
                val action = when (call.arguments as String) {
                    "wifi" -> android.provider.Settings.ACTION_WIFI_SETTINGS
                    "vpn" -> android.provider.Settings.ACTION_VPN_SETTINGS
                    "saver" -> android.provider.Settings.ACTION_BATTERY_SAVER_SETTINGS
                    "data" -> android.provider.Settings.ACTION_DATA_USAGE_SETTINGS
                    else -> android.provider.Settings.ACTION_SETTINGS
                }
                runCatching { startActivity(Intent(action)) }
                result.success(null)
            }
            "openApp" -> {
                val name = call.argument<String>("package")!!
                packageManager.getLaunchIntentForPackage(name)?.let { startActivity(it) }
                result.success(null)
            }
            "installApps" -> {
                @Suppress("UNCHECKED_CAST")
                AppInstaller.install(this@MainActivity, call.argument<List<Map<String, Any?>>>("apps").orEmpty())
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
                "photos" -> requestPermission(
                    if (Build.VERSION.SDK_INT >= 33) Manifest.permission.READ_MEDIA_IMAGES else Manifest.permission.READ_EXTERNAL_STORAGE,
                    REQUEST_PHOTOS, result,
                )
                else -> result.notImplemented()
            }
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
            "webcamPreview" -> result.success(
                webcamPreview(call.argument<String>("session")!!, call.argument<Boolean>("on") == true),
            )
            "switchCamera" -> {
                ShareService.switchCamera(this@MainActivity, call.argument<String>("session")!!)
                result.success(null)
            }
            else -> result.notImplemented()
        }
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

    /// The deck, untouched a while (docs/protocol.md §4.20): this window at
    /// [level] of full brightness, never brighter than the user's own when
    /// it's set by hand; null gives the screen back to the phone.
    private fun dimScreen(level: Double?) {
        val attrs = window.attributes
        attrs.screenBrightness = if (level == null) {
            android.view.WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        } else {
            val manual = runCatching {
                Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE) ==
                    Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
            }.getOrDefault(false)
            val own = if (manual) {
                runCatching { Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS) / 255f }.getOrNull()
            } else null
            minOf(level.toFloat(), own ?: 1f).coerceAtLeast(0.01f)
        }
        window.attributes = attrs
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
        // Kept here until taken: when Android restarts this activity, Flutter
        // isn't listening yet and this call goes nowhere.
        turnOnFrom(intent)?.let { ask ->
            pendingTurnOn = ask
            channel?.invokeMethod("turnOn", null)
        }
        val link = linkFrom(intent) ?: return
        channel?.invokeMethod("link", link) ?: run { pendingLink = link }
    }

    /// The computer's name and the feature from a tapped ask, once: the
    /// activity may be recreated with this intent.
    private fun turnOnFrom(intent: Intent?): Map<String, String>? {
        val feature = intent?.getStringExtra(EXTRA_TURN_ON) ?: return null
        val name = intent.getStringExtra(EXTRA_TURN_ON_NAME).orEmpty()
        intent.removeExtra(EXTRA_TURN_ON)
        return mapOf("feature" to feature, "name" to name)
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


    /// The display's fastest mode at its size while a screen is shown, so
    /// frames aren't held back by a panel left at 60 Hz or lower.
    private fun highRefresh(on: Boolean) {
        @Suppress("DEPRECATION")
        val screen = (if (android.os.Build.VERSION.SDK_INT >= 30) display else windowManager.defaultDisplay)
            ?: return
        val now = screen.mode
        val best = screen.supportedModes
            .filter { it.physicalWidth == now.physicalWidth && it.physicalHeight == now.physicalHeight }
            .maxByOrNull { it.refreshRate } ?: return
        window.attributes = window.attributes.apply { preferredDisplayModeId = if (on) best.modeId else 0 }
    }

    /// "Share → Linksy", handed over by [ShareTarget] (files already copied).
    private fun takeShared(intent: Intent?) {
        if (intent?.action != ShareTarget.ACTION_SHARED) return
        // Handled once, even if the activity is recreated with this intent.
        setIntent(Intent(Intent.ACTION_MAIN))
        val files = intent.getStringArrayExtra(ShareTarget.EXTRA_FILES)?.toList().orEmpty()
        val text = intent.getStringExtra(ShareTarget.EXTRA_TEXT)
        val device = intent.getStringExtra(ShareTarget.EXTRA_DEVICE)
        val to = buildMap<String, Any> {
            if (device != null) put("device", device)
            if (intent.getBooleanExtra(ShareTarget.EXTRA_QUICK, false)) put("quick", true)
        }
        when {
            files.isNotEmpty() -> deliverShare(mapOf("files" to files) + to)
            !text.isNullOrBlank() -> deliverShare(mapOf("text" to text) + to)
        }
    }

    private fun deliverShare(share: Map<String, Any>) {
        val c = channel
        if (c == null) pendingShare = share else c.invokeMethod("share", share)
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


    override fun onDestroy() {
        previews.keys.toList().forEach { webcamPreview(it, false) }
        usbReceiver?.let { runCatching { unregisterReceiver(it) } }
        usbReceiver = null
        usbPoll.removeCallbacks(usbTick)
        scanner?.stop()
        displays.values.forEach { it.stop() }
        displays.clear()
        // A boot-started engine stays, and Linksy with it; the app's own goes.
        bridge?.let { b ->
            b.activity = null
            if (b !== Bridge.background) b.dispose()
        }
        bridge = null
        channel = null
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

    private fun granted(permission: String) =
        checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /// Android's own permission dialog. Once the user has refused and Android
    /// stops showing it, opens Linksy's app settings instead, where it can
    /// still be turned on. Replies true only if granted now.
    private fun requestPermission(permission: String, code: Int, result: MethodChannel.Result) {
        // Android 12+ shows the location dialog only when coarse is asked too;
        // either is enough for one fix.
        val also = when (permission) {
            Manifest.permission.ACCESS_FINE_LOCATION -> Manifest.permission.ACCESS_COARSE_LOCATION
            // Videos come with photos in the same dialog.
            Manifest.permission.READ_MEDIA_IMAGES -> Manifest.permission.READ_MEDIA_VIDEO
            else -> null
        }
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
        if (requestCode == REQUEST_NOTIFICATION_ACCESS) {
            pendingNotificationAccess?.success(PhoneNotifications.allowed(this))
            pendingNotificationAccess = null
            return
        }
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
        if (requestCode == REQUEST_SEND_FOLDER) {
            val result = pendingSendFolder ?: return
            pendingSendFolder = null
            val tree = data?.data
            if (resultCode != RESULT_OK || tree == null) return result.success(null)
            Thread {
                val path = ShareTarget.copyTree(applicationContext, tree, "picked")
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
                (if (kind != "photos") Intent.FLAG_GRANT_WRITE_URI_PERMISSION else 0)
            runCatching { contentResolver.takePersistableUriPermission(uri, flags) }
            // Let go of the folder this replaces.
            bridge!!.prefs().getString("folder.$kind", null)?.takeIf { it != uri.toString() }?.let { bridge!!.letGoOf(it, kind) }
            bridge!!.prefs().edit().putString("folder.$kind", uri.toString()).apply()
            if (kind == "files") Bridge.fileServer(this).root = uri
            return result.success(bridge?.folderName(kind))
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

    companion object {
        const val EXTRA_TURN_ON = "app.linksy.turn_on"
        const val EXTRA_TURN_ON_NAME = "app.linksy.turn_on_name"
        const val REQUEST_CAPTURE = 41
        const val REQUEST_CAMERA = 42
        const val REQUEST_NOTIFICATIONS = 43
        const val REQUEST_MICROPHONE = 48
        const val REQUEST_LOCATION = 49
        const val REQUEST_DIRECT = 50
        const val REQUEST_NEARBY = 51
        const val REQUEST_PICK = 44
        const val REQUEST_FOLDER = 45
        const val REQUEST_SEND_FOLDER = 54
        const val REQUEST_PICTURE = 46
        const val REQUEST_NOTIFICATION_ACCESS = 52
        const val REQUEST_PHOTOS = 53
    }
}
