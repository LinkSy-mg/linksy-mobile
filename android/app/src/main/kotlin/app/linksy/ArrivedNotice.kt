package app.linksy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/// A ping or a link from a computer while Linksy isn't on screen, so it's
/// noticed: it buzzes, and a tap opens the app (where a link waits).
object ArrivedNotice {
    private const val CHANNEL = "arrived"

    fun post(context: Context, id: String, title: String, body: String) {
        val manager = context.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, Lang.str(context, R.string.channel_arrived), NotificationManager.IMPORTANCE_HIGH),
            )
        }
        val open = PendingIntent.getActivity(
            context, id.hashCode(), Intent(context, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE,
        )
        @Suppress("DEPRECATION")
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, CHANNEL) else Notification.Builder(context)
        val note = builder
            .setSmallIcon(R.drawable.ic_stat_linksy)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(open)
            .setAutoCancel(true)
            .build()
        runCatching { manager.notify(id.hashCode(), note) }
    }
}
