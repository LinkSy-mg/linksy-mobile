package app.linksy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/// Keeps Linksy running with the screen off, with a quiet notification that
/// says why: while a computer locks itself when this phone leaves (its
/// heartbeats must keep coming, docs/protocol.md §4.5), or while a computer browses
/// this phone's files. And while files are on their way, in the status bar with
/// their progress, the CPU and Wi-Fi held on so the transfer doesn't drop. Holds
/// the CPU awake only for heartbeats and transfers.
///
/// Started with the phone ([Boot]), it also runs Linksy itself, with no
/// screen, and stays for as long as the user wants that.
class KeepAlive : Service() {
    private var wake: PowerManager.WakeLock? = null
    private var wifi: WifiManager.WifiLock? = null
    private var multicast: WifiManager.MulticastLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val booting = intent?.getBooleanExtra(EXTRA_BOOT, false) == true
        val text = intent?.getStringExtra(EXTRA_TEXT)
            ?: Lang.str(this, if (held) R.string.keep_alive_boot else R.string.keep_alive_default)
        val progress = intent?.takeIf { it.hasExtra(EXTRA_PROGRESS) }?.getIntExtra(EXTRA_PROGRESS, -1)
        val note = notification(intent?.getStringExtra(EXTRA_TITLE) ?: "Linksy", text, progress)
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIFICATION, note, ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
        } else {
            startForeground(NOTIFICATION, note)
        }
        pending = maxOf(0, pending - 1)
        if (booting) {
            // mDNS for computers to find it, as the app holds while on screen.
            if (multicast == null) {
                multicast = (applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager)
                    .createMulticastLock("linksy:boot").apply { setReferenceCounted(false); acquire() }
            }
            Bridge.startInBackground(this)
        }
        if (pending == 0 && stopWanted) {
            stopWanted = false
            stopSelf()
            return START_NOT_STICKY
        }
        val awake = intent?.getBooleanExtra(EXTRA_AWAKE, false) == true
        if (awake && wake == null) {
            wake = (getSystemService(Context.POWER_SERVICE) as PowerManager)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "linksy:heartbeats")
                .apply { setReferenceCounted(false); acquire() }
        } else if (!awake) {
            release()
        }
        if (progress != null && wifi == null) {
            @Suppress("DEPRECATION")
            wifi = (applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager)
                .createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "linksy:transfer")
                .apply { setReferenceCounted(false); acquire() }
        } else if (progress == null) {
            releaseWifi()
        }
        return START_NOT_STICKY
    }

    private fun release() {
        wake?.takeIf { it.isHeld }?.release()
        wake = null
    }

    private fun releaseWifi() {
        wifi?.takeIf { it.isHeld }?.release()
        wifi = null
    }

    override fun onDestroy() {
        release()
        releaseWifi()
        multicast?.takeIf { it.isHeld }?.release()
        multicast = null
        super.onDestroy()
    }

    /// [progress]: files on their way (a percentage, or -1 before they start), shown
    /// in the status bar; else the quiet one, folded away.
    private fun notification(title: String, text: String, progress: Int?): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = if (progress != null) TRANSFERS else CHANNEL
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(
                if (progress != null) {
                    NotificationChannel(TRANSFERS, Lang.str(this, R.string.channel_transfers), NotificationManager.IMPORTANCE_LOW)
                } else {
                    NotificationChannel(CHANNEL, Lang.str(this, R.string.channel_staying), NotificationManager.IMPORTANCE_MIN)
                },
            )
        }
        val open = PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
        @Suppress("DEPRECATION")
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, channel) else Notification.Builder(this)
        if (progress != null) {
            builder.setProgress(100, progress.coerceIn(0, 100), progress < 0).setOnlyAlertOnce(true)
            if (Build.VERSION.SDK_INT >= 31) builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }
        return builder
            .setSmallIcon(R.drawable.ic_stat_linksy)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setContentIntent(open)
            .build()
    }

    companion object {
        private const val CHANNEL = "connected"
        private const val TRANSFERS = "transfers"
        private const val NOTIFICATION = 8
        private const val EXTRA_TEXT = "text"
        private const val EXTRA_AWAKE = "awake"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_PROGRESS = "progress"
        private const val EXTRA_BOOT = "boot"

        /// Started with the phone: the service stays, quiet, when nothing else
        /// needs it, since it's what keeps Linksy running (until the user turns
        /// Start When the Phone Starts off).
        private var held = false

        /// Starts Android hasn't reached [onStartCommand] for yet, and a stop
        /// that waits for them: stopped before it's in the foreground, Android
        /// ends the app. A small file can start and finish that fast.
        private var pending = 0
        private var stopWanted = false

        /// Starts or updates it; [awake] keeps the CPU on (heartbeats, transfers),
        /// [progress] is files on their way.
        fun start(context: Context, text: String, awake: Boolean, title: String? = null, progress: Int? = null) {
            val intent = Intent(context, KeepAlive::class.java).putExtra(EXTRA_TEXT, text).putExtra(EXTRA_AWAKE, awake)
            title?.let { intent.putExtra(EXTRA_TITLE, it) }
            progress?.let { intent.putExtra(EXTRA_PROGRESS, it) }
            // Refused from the background on Android 12 and later (a transfer accepted
            // there): it carries on while Android lets it.
            stopWanted = false
            runCatching {
                if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent) else context.startService(intent)
                pending++
            }
        }

        fun stop(context: Context) {
            if (held && Boot.wanted(context)) {
                start(context, Lang.str(context, R.string.keep_alive_boot), awake = false)
                return
            }
            held = false
            if (pending > 0) stopWanted = true else context.stopService(Intent(context, KeepAlive::class.java))
        }

        /// From [Boot]: in the foreground first (a receiver may start this
        /// type, connectedDevice, on Android 15), then Linksy behind it.
        fun boot(context: Context) {
            held = true
            stopWanted = false
            val intent = Intent(context, KeepAlive::class.java).putExtra(EXTRA_BOOT, true)
            runCatching {
                if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent) else context.startService(intent)
                pending++
            }.onFailure { Logs.add("Couldn't start with the phone: $it") }
        }
    }
}
