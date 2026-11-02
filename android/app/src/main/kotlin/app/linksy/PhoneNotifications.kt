package app.linksy

import android.app.Notification
import android.app.NotificationManager
import android.app.Person
import android.app.RemoteInput
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Base64
import java.io.ByteArrayOutputStream

/// This phone's notifications on its computers (docs/protocol.md §4.5): each new
/// or changed one goes to Dart as `notification_posted` (key, app, app_name,
/// title, body, can_reply, actions, icon, and for the computer's Messages page
/// category, conversation, sender, group, time, picture), and its key when it
/// goes away. What
/// the computer sends back is answered here: a reply through the notification's
/// RemoteInput, a button by firing its action, a dismissal by cancelling it.
///
/// Android binds this once the user allows Notification access; nothing is sent
/// unless mirroring is also on ([on], Settings › With your computers). Skips
/// Linksy's own, ongoing ones (music, navigation, downloads), group summaries
/// and silent ones. Nothing is kept.
class PhoneNotifications : NotificationListenerService() {
    companion object {
        @Volatile private var instance: PhoneNotifications? = null

        /// Mirroring is on (the app's switch, and Dart is listening).
        @Volatile var on = false

        /// A new or changed notification, in the core's shape.
        @Volatile var posted: ((Map<String, Any?>) -> Unit)? = null

        /// The key of one that went away.
        @Volatile var removed: ((String) -> Unit)? = null

        /// The app's launcher icon and a person's picture, 96 px: plenty for a
        /// computer's notification.
        private const val ICON = 96
        /// A picture's base64, at most (§4.5).
        private const val MAX_PICTURE = 64 * 1024
        private const val MAX_TITLE = 256
        private const val MAX_BODY = 4000

        /// Whether Android lets Linksy read notifications.
        fun allowed(context: Context): Boolean {
            val me = ComponentName(context, PhoneNotifications::class.java)
            if (Build.VERSION.SDK_INT >= 27) {
                return context.getSystemService(NotificationManager::class.java).isNotificationListenerAccessGranted(me)
            }
            val enabled = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners").orEmpty()
            return enabled.split(':').any { ComponentName.unflattenFromString(it) == me }
        }

        /// Android's page that allows it: Linksy's own switch where Android has one.
        fun settingsIntent(context: Context): Intent {
            if (Build.VERSION.SDK_INT >= 30) {
                return Intent(Settings.ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS).putExtra(
                    Settings.EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME,
                    ComponentName(context, PhoneNotifications::class.java).flattenToString(),
                )
            }
            return Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        }

        fun reply(key: String, text: String) = instance?.replyTo(key, text) == true
        fun act(key: String, action: String) = instance?.fire(key, action) == true
        fun dismiss(key: String) = instance?.let { runCatching { it.cancelNotification(key) }.isSuccess } == true
    }

    /// What went to the computers, so only those are taken back.
    private val sent = mutableSetOf<String>()
    private val icons = mutableMapOf<String, String?>()

    override fun onListenerConnected() {
        instance = this
    }

    override fun onListenerDisconnected() {
        if (instance === this) instance = null
    }

    override fun onDestroy() {
        if (instance === this) instance = null
        super.onDestroy()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification, rankingMap: RankingMap?) {
        if (!on) return
        val sink = posted ?: return
        val described = runCatching { describe(sbn, rankingMap) }.getOrNull()
        if (described == null) {
            // Changed into one that isn't sent (now ongoing, now silent).
            if (sent.remove(sbn.key)) removed?.invoke(sbn.key)
            return
        }
        sent += sbn.key
        sink(described)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) = onNotificationPosted(sbn, null)

    override fun onNotificationRemoved(sbn: StatusBarNotification, rankingMap: RankingMap?) {
        if (sent.remove(sbn.key)) removed?.invoke(sbn.key)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) = onNotificationRemoved(sbn, null)

    private fun describe(sbn: StatusBarNotification, rankingMap: RankingMap?): Map<String, Any?>? {
        val n = sbn.notification
        if (sbn.packageName == packageName || sbn.isOngoing || !sbn.isClearable) return null
        if (n.flags and Notification.FLAG_GROUP_SUMMARY != 0) return null
        if (n.category in setOf(Notification.CATEGORY_TRANSPORT, Notification.CATEGORY_NAVIGATION, Notification.CATEGORY_PROGRESS, Notification.CATEGORY_SERVICE)) return null
        val ranking = Ranking()
        if (rankingMap?.getRanking(sbn.key, ranking) == true && ranking.importance <= NotificationManager.IMPORTANCE_LOW) return null

        val extras = n.extras
        var title = (extras.getCharSequence(Notification.EXTRA_TITLE_BIG) ?: extras.getCharSequence(Notification.EXTRA_TITLE))?.toString().orEmpty()
        var body = (extras.getCharSequence(Notification.EXTRA_BIG_TEXT) ?: extras.getCharSequence(Notification.EXTRA_TEXT))?.toString().orEmpty()
        // A conversation (the computer's Messages page): its newest message
        // alone, who wrote it, and the chat it's in.
        val chat = conversation(extras)
        if (chat != null) {
            title = chat.name ?: title
            body = chat.text
        }
        if (title.isBlank() && body.isBlank()) return null
        val conversation = title.takeIf { chat != null && it.isNotBlank() }
        val app = appInfo(sbn)
        val appName = app?.let { runCatching { packageManager.getApplicationLabel(it).toString() }.getOrNull() } ?: sbn.packageName
        // Android 15 hides the text of some (one-time codes, on some phones
        // every message) from listeners it doesn't trust: the app's name then.
        if (title.isBlank()) title = appName

        val actions = n.actions.orEmpty()
        val canReply = actions.any { a -> a.remoteInputs.orEmpty().any { it.allowFreeFormInput } }
        val buttons = actions.withIndex()
            .filter { (_, a) -> a.remoteInputs.isNullOrEmpty() && !a.title.isNullOrBlank() }
            .map { (i, a) -> mapOf("id" to i.toString(), "label" to a.title.toString()) }

        // A group's own picture, or the person's in a chat with one.
        val picture = if (chat?.group == true) {
            picture(n.getLargeIcon()) ?: picture(chat.face)
        } else {
            picture(chat?.face) ?: picture(n.getLargeIcon())
        }

        return buildMap {
            put("key", sbn.key)
            put("app", sbn.packageName)
            put("app_name", appName)
            put("title", title.take(MAX_TITLE))
            put("body", body.take(MAX_BODY))
            put("can_reply", canReply)
            put("actions", buttons)
            put("icon", icon(sbn.packageName, app))
            n.category?.let { put("category", it) }
            put("time", chat?.time ?: sbn.postTime)
            if (chat != null) {
                conversation?.let { put("conversation", it.take(MAX_TITLE)) }
                chat.sender?.let { put("sender", it.take(MAX_TITLE)) }
                put("group", chat.group)
            }
            picture?.let { put("picture", it) }
        }
    }

    /// A MessagingStyle notification's chat: its [name] (the group's, else the
    /// other person's), the newest message's [sender], [text] and [time], and
    /// the [face] of whoever wrote it.
    private class Chat(
        val name: String?,
        val group: Boolean,
        val sender: String?,
        val text: String,
        val time: Long?,
        val face: Icon?,
    )

    private fun conversation(extras: Bundle): Chat? {
        @Suppress("DEPRECATION")
        val messages = extras.getParcelableArray(Notification.EXTRA_MESSAGES)?.filterIsInstance<Bundle>()
        val last = messages?.lastOrNull() ?: return null
        val text = last.getCharSequence("text")?.toString() ?: return null
        // A message without a sender is the user's own (a reply).
        val me = if (Build.VERSION.SDK_INT >= 28) {
            @Suppress("DEPRECATION")
            (extras.getParcelable(Notification.EXTRA_MESSAGING_PERSON) as? Person)?.name?.toString()
        } else null
        val title = extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString()?.takeIf { it.isNotBlank() }
        val group = if (extras.containsKey(Notification.EXTRA_IS_GROUP_CONVERSATION)) {
            extras.getBoolean(Notification.EXTRA_IS_GROUP_CONVERSATION)
        } else {
            title != null
        }
        // In a chat with one person, the newest message they wrote names it.
        val other = messages.asReversed().firstNotNullOfOrNull { senderOf(it)?.first }
        return Chat(
            name = title ?: if (!group) other else null,
            group = group,
            sender = (senderOf(last)?.first ?: me ?: extras.getCharSequence("android.selfDisplayName")?.toString())?.takeIf { it.isNotBlank() },
            text = text,
            time = last.getLong("time").takeIf { it > 0 },
            face = senderOf(last)?.second,
        )
    }

    /// Who wrote a message: their name, and their picture where it has one.
    private fun senderOf(message: Bundle): Pair<String, Icon?>? {
        if (Build.VERSION.SDK_INT >= 28) {
            @Suppress("DEPRECATION")
            val person = message.getParcelable("sender_person") as? Person
            val name = person?.name?.toString()
            if (!name.isNullOrBlank()) return name to person.icon
        }
        val name = message.getCharSequence("sender")?.toString()
        return if (name.isNullOrBlank()) null else name to null
    }

    /// A person's or a chat's picture, 96 px: JPEG where it's opaque (a photo),
    /// PNG where it isn't (a round one). Nothing over 64 KiB.
    private fun picture(icon: Icon?): String? {
        val drawable = icon?.let { runCatching { it.loadDrawable(this) }.getOrNull() } ?: return null
        return runCatching {
            val bitmap = render(drawable)
            val pixels = IntArray(ICON * ICON).also { bitmap.getPixels(it, 0, ICON, 0, 0, ICON, ICON) }
            val opaque = pixels.all { it ushr 24 == 0xFF }
            val out = ByteArrayOutputStream()
            bitmap.compress(if (opaque) Bitmap.CompressFormat.JPEG else Bitmap.CompressFormat.PNG, if (opaque) 85 else 100, out)
            bitmap.recycle()
            Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP).takeIf { it.length <= MAX_PICTURE }
        }.getOrNull()
    }

    /// [drawable] filling a 96 px square, cut to the middle if it isn't one.
    private fun render(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(ICON, ICON, Bitmap.Config.ARGB_8888)
        val w = drawable.intrinsicWidth
        val h = drawable.intrinsicHeight
        if (w > 0 && h > 0 && w != h) {
            val scale = ICON.toFloat() / minOf(w, h)
            val sw = (w * scale).toInt()
            val sh = (h * scale).toInt()
            drawable.setBounds((ICON - sw) / 2, (ICON - sh) / 2, (ICON + sw) / 2, (ICON + sh) / 2)
        } else {
            drawable.setBounds(0, 0, ICON, ICON)
        }
        drawable.draw(Canvas(bitmap))
        return bitmap
    }

    /// The posting app, as the notification carries it (other apps may be
    /// invisible to Linksy since Android 11).
    private fun appInfo(sbn: StatusBarNotification): ApplicationInfo? {
        // Notification.EXTRA_BUILDER_APPLICATION_INFO, hidden in the SDK.
        @Suppress("DEPRECATION")
        val carried = (sbn.notification.extras.getParcelable("android.appInfo") as? ApplicationInfo)
            // A hidden one carries Android's own.
            ?.takeIf { it.packageName == sbn.packageName }
        return carried ?: runCatching { packageManager.getApplicationInfo(sbn.packageName, 0) }.getOrNull()
    }

    /// The app's icon as a small PNG in base64, once per app.
    private fun icon(app: String, info: ApplicationInfo?): String? = icons.getOrPut(app) {
        runCatching {
            val drawable = if (info != null) packageManager.getApplicationIcon(info) else packageManager.getApplicationIcon(app)
            val bitmap = render(drawable)
            val png = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, png)
            bitmap.recycle()
            Base64.encodeToString(png.toByteArray(), Base64.NO_WRAP)
        }.getOrNull()
    }

    private fun find(key: String): StatusBarNotification? =
        runCatching { getActiveNotifications(arrayOf(key)) }.getOrNull()?.firstOrNull()

    /// Answers through the notification's own reply, as if typed on the phone.
    private fun replyTo(key: String, text: String): Boolean {
        val sbn = find(key) ?: return false
        val action = sbn.notification.actions.orEmpty()
            .firstOrNull { a -> a.remoteInputs.orEmpty().any { it.allowFreeFormInput } } ?: return false
        val inputs = action.remoteInputs
        val results = Bundle().apply {
            for (input in inputs) if (input.allowFreeFormInput) putCharSequence(input.resultKey, text)
        }
        val intent = Intent()
        RemoteInput.addResultsToIntent(inputs, intent, results)
        if (Build.VERSION.SDK_INT >= 28) RemoteInput.setResultsSource(intent, RemoteInput.SOURCE_FREE_FORM_INPUT)
        return runCatching { action.actionIntent.send(this, 0, intent) }.isSuccess
    }

    /// Presses the button [action] (its index, as sent).
    private fun fire(key: String, action: String): Boolean {
        val sbn = find(key) ?: return false
        val button = action.toIntOrNull()?.let { sbn.notification.actions?.getOrNull(it) } ?: return false
        return runCatching { button.actionIntent.send() }.isSuccess
    }
}
