package app.linksy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/// Push notifications from Firebase (project linksy-mg). Every install joins
/// the `all` topic, so announcements go out from the Firebase console without
/// a server. Messages with a notification part show by themselves while the
/// app is in the background; this shows them in the foreground, and shows
/// data-only messages (`title`, `body`, optional `url`) always.
class Push : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        Log.i("linksy", "push token refreshed")
        subscribe()
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val title = message.notification?.title ?: message.data["title"] ?: return
        val body = message.notification?.body ?: message.data["body"] ?: ""
        show(this, title, body, message.data["url"])
    }

    companion object {
        private const val CHANNEL = "news"
        const val TOPIC = "all"

        /// Joins the topic; called on every start (cheap, and repairs a
        /// subscription that failed offline).
        fun subscribe() {
            runCatching {
                FirebaseMessaging.getInstance().subscribeToTopic(TOPIC)
                    .addOnFailureListener { Log.w("linksy", "push topic subscribe failed", it) }
            }.onFailure { Log.w("linksy", "push unavailable", it) }
        }

        /// This install's token, for sending a test message to one phone.
        fun token(done: (String?) -> Unit) {
            runCatching {
                FirebaseMessaging.getInstance().token
                    .addOnSuccessListener { done(it) }
                    .addOnFailureListener { done(null) }
            }.onFailure { done(null) }
        }

        /// The payload's link, only when it is https: a push message is
        /// remote input, and a plain-http link can be rewritten in transit.
        fun safeLink(url: String?): String? =
            url?.takeIf { it.startsWith("https://", ignoreCase = true) }

        fun show(context: Context, title: String, body: String, url: String?) {
            val manager = context.getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= 26) {
                manager.createNotificationChannel(
                    NotificationChannel(CHANNEL, Lang.str(context, R.string.channel_news), NotificationManager.IMPORTANCE_DEFAULT),
                )
            }
            val open = safeLink(url)
                ?.let { Intent(Intent.ACTION_VIEW, android.net.Uri.parse(it)) }
                ?: Intent(context, MainActivity::class.java)
            val tap = PendingIntent.getActivity(
                context, title.hashCode(), open.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            val note = NotificationCompat.Builder(context, CHANNEL)
                .setSmallIcon(R.drawable.ic_stat_linksy)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setContentIntent(tap)
                .setAutoCancel(true)
                .build()
            runCatching { manager.notify(title.hashCode(), note) }
        }
    }
}
