package app.linksy

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import kotlin.math.roundToInt

/// The phone's volumes, ringer, Do Not Disturb and flashlight, for a computer
/// (docs/protocol.md §4.24).
class Controls(context: Context, private val changed: () -> Unit) {
    private val app = context.applicationContext
    private val audio = app.getSystemService(AudioManager::class.java)
    private val notices = app.getSystemService(NotificationManager::class.java)
    private val cameras = app.getSystemService(CameraManager::class.java)
    private val main = Handler(Looper.getMainLooper())

    /// The camera with a flash, null on a phone without one.
    private val torch: String? = runCatching {
        cameras.cameraIdList.firstOrNull {
            cameras.getCameraCharacteristics(it).get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        }
    }.getOrNull()
    private var torchOn = false

    private val torchWatch = object : CameraManager.TorchCallback() {
        override fun onTorchModeChanged(id: String, on: Boolean) {
            if (id != torch || on == torchOn) return
            torchOn = on
            changed()
        }
    }

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = changed()
    }
    private var watching = false

    fun watch(on: Boolean) {
        if (on == watching) return
        watching = on
        if (on) {
            val filter = IntentFilter().apply {
                addAction(VOLUME_CHANGED)
                addAction(AudioManager.RINGER_MODE_CHANGED_ACTION)
                addAction(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
            }
            app.registerReceiver(receiver, filter, null, main, Context.RECEIVER_NOT_EXPORTED.takeIf { android.os.Build.VERSION.SDK_INT >= 33 } ?: 0)
            if (torch != null) cameras.registerTorchCallback(torchWatch, main)
        } else {
            runCatching { app.unregisterReceiver(receiver) }
            if (torch != null) cameras.unregisterTorchCallback(torchWatch)
        }
    }

    private fun level(stream: Int) =
        audio.getStreamVolume(stream).toDouble() / audio.getStreamMaxVolume(stream).coerceAtLeast(1)

    val dndAccess get() = notices.isNotificationPolicyAccessGranted

    fun read(): Map<String, Any> = buildMap {
        put("media", level(AudioManager.STREAM_MUSIC))
        put("ringtone", level(AudioManager.STREAM_RING))
        put("alarm", level(AudioManager.STREAM_ALARM))
        put(
            "ringer",
            when (audio.ringerMode) {
                AudioManager.RINGER_MODE_SILENT -> "silent"
                AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                else -> "normal"
            },
        )
        put(
            "dnd",
            when (notices.currentInterruptionFilter) {
                NotificationManager.INTERRUPTION_FILTER_PRIORITY -> "priority"
                NotificationManager.INTERRUPTION_FILTER_ALARMS -> "alarms"
                NotificationManager.INTERRUPTION_FILTER_NONE -> "silence"
                else -> "off"
            },
        )
        put("dnd_access", dndAccess)
        if (torch != null) put("flashlight", torchOn)
    }

    private fun setLevel(stream: Int, level: Double) {
        val top = audio.getStreamMaxVolume(stream)
        audio.setStreamVolume(stream, (level.coerceIn(0.0, 1.0) * top).roundToInt(), 0)
    }

    /// Applies what [change] holds. What couldn't be done comes back, each with
    /// `dnd`, `flashlight` or `denied` for why.
    fun apply(change: Map<*, *>): Map<String, String> {
        val refused = mutableMapOf<String, String>()
        fun attempt(what: String, why: String = "denied", go: () -> Unit) {
            runCatching(go).onFailure { refused[what] = why }
        }
        (change["media"] as? Number)?.let { l -> attempt("media") { setLevel(AudioManager.STREAM_MUSIC, l.toDouble()) } }
        (change["ringtone"] as? Number)?.let { l -> attempt("ringtone") { setLevel(AudioManager.STREAM_RING, l.toDouble()) } }
        (change["alarm"] as? Number)?.let { l -> attempt("alarm") { setLevel(AudioManager.STREAM_ALARM, l.toDouble()) } }
        when (change["ringer"]) {
            "normal" -> attempt("ringer") { audio.ringerMode = AudioManager.RINGER_MODE_NORMAL }
            "vibrate" -> attempt("ringer") { audio.ringerMode = AudioManager.RINGER_MODE_VIBRATE }
            "silent" -> attempt("ringer", "dnd") { audio.ringerMode = AudioManager.RINGER_MODE_SILENT }
        }
        val filter = when (change["dnd"]) {
            "off" -> NotificationManager.INTERRUPTION_FILTER_ALL
            "priority" -> NotificationManager.INTERRUPTION_FILTER_PRIORITY
            "alarms" -> NotificationManager.INTERRUPTION_FILTER_ALARMS
            "silence" -> NotificationManager.INTERRUPTION_FILTER_NONE
            else -> null
        }
        if (filter != null) {
            if (dndAccess) attempt("dnd") { notices.setInterruptionFilter(filter) } else refused["dnd"] = "dnd"
        }
        (change["flashlight"] as? Boolean)?.let { on ->
            val id = torch
            if (id == null) refused["flashlight"] = "flashlight"
            else attempt("flashlight", "flashlight") { cameras.setTorchMode(id, on) }
        }
        return refused
    }

    private companion object {
        /// Not in the SDK, and sent on every platform: a stream's volume moved.
        const val VOLUME_CHANGED = "android.media.VOLUME_CHANGED_ACTION"
    }
}

/// A computer's own notifications here: only shown (docs/protocol.md §4.25).
object ComputerNotices {
    private const val CHANNEL = "from_computer"

    fun post(context: Context, computer: String, key: String, app: String, title: String, body: String, at: Long) {
        val manager = context.getSystemService(NotificationManager::class.java)
        if (android.os.Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(
                android.app.NotificationChannel(
                    CHANNEL,
                    Lang.str(context, R.string.channel_from_computer),
                    NotificationManager.IMPORTANCE_DEFAULT,
                ),
            )
        }
        @Suppress("DEPRECATION")
        val builder = if (android.os.Build.VERSION.SDK_INT >= 26) {
            android.app.Notification.Builder(context, CHANNEL)
        } else {
            android.app.Notification.Builder(context)
        }
        val note = builder
            .setSmallIcon(R.drawable.ic_stat_linksy)
            .setContentTitle(title.take(200))
            .setContentText(body.take(1000))
            .setStyle(android.app.Notification.BigTextStyle().bigText(body.take(1000)))
            .setSubText("$computer · ${app.take(80)}")
            .apply { if (at > 0) setWhen(at).setShowWhen(true) }
            .setAutoCancel(true)
            .build()
        // The same key replaces the earlier one.
        runCatching { manager.notify("$computer/$key", 1, note) }
    }
}
