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
/// title, body, can_reply, actions, icon, and for the computer's Inbox
/// category, conversation, sender, group, time, picture, the conversation's
/// latest messages, mine, a mail's subject), and its key when it goes away.
/// What the computer sends back is answered here: a reply through the
/// notification's RemoteInput, a button by firing its action, a dismissal by
/// cancelling it.
///
/// Android binds this once the user allows Notification access; nothing is sent
/// unless mirroring is also on ([on], Settings › With your computers). Skips
/// Linksy's own, ongoing ones (music, navigation, downloads), group summaries
/// and silent ones. A conversation's messages are kept in [InboxStore], and its
/// reply for a day after its notification goes.
class PhoneNotifications : NotificationListenerService() {
    companion object {
        @Volatile private var instance: PhoneNotifications? = null

        /// Mirroring is on (the app's switch, and Dart is listening).
        @Volatile var on = false

        /// A new or changed notification, in the core's shape.
        @Volatile var posted: ((Map<String, Any?>) -> Unit)? = null

        /// The key of one that went away, and whether its conversation can
        /// still be answered (its reply is kept).
        @Volatile var removed: ((String, Boolean) -> Unit)? = null

        /// The app's launcher icon and a person's picture, 96 px: plenty for a
        /// computer's notification.
        private const val ICON = 96
        /// A picture's base64, at most (§4.5).
        private const val MAX_PICTURE = 64 * 1024
        private const val MAX_TITLE = 256
        private const val MAX_BODY = 4000
        /// A conversation's latest messages sent with each of its notifications.
        private const val LATEST = 25
        /// How long a gone conversation's reply is kept.
        private const val KEEP_REPLY_MS = 24 * 60 * 60 * 1000L

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

    /// A chat's name by key, for when its newest messages are all the user's.
    private val names = object : LinkedHashMap<String, String>(16, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, String>) = size > 500
    }

    /// Conversations whose notification went, still answered for a day.
    private class Kept(val action: Notification.Action, val at: Long)
    private val kept = mutableMapOf<String, Kept>()

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
            if (sent.remove(sbn.key)) removed?.invoke(sbn.key, false)
            return
        }
        sent += sbn.key
        kept.remove(sbn.key)
        sink(described)
        // What it shows of the conversation, for the computer's earlier messages.
        val conversation = described["conversation"] as? String
        @Suppress("UNCHECKED_CAST")
        val messages = described["messages"] as? List<Map<String, Any?>>
        if (conversation != null && messages != null) {
            InboxStore.add(this, sbn.packageName, conversation, messages.map {
                InboxStore.Message(it["sender"] as? String, it["text"] as String, it["time"] as Long, it["mine"] == true)
            })
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) = onNotificationPosted(sbn, null)

    override fun onNotificationRemoved(sbn: StatusBarNotification, rankingMap: RankingMap?) {
        if (!sent.remove(sbn.key)) return
        // A conversation stays answerable from the computer for a while.
        val now = System.currentTimeMillis()
        kept.entries.removeIf { now - it.value.at > KEEP_REPLY_MS }
        val reply = replyAction(sbn.notification)
            ?.takeIf { sbn.notification.extras.containsKey(Notification.EXTRA_MESSAGES) }
        if (reply != null) kept[sbn.key] = Kept(reply, now)
        removed?.invoke(sbn.key, reply != null)
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
        // A conversation (the computer's Inbox): its newest message alone, who
        // wrote it, and the chat it's in, named for the other person in a chat
        // with one, never for the user.
        // Android 15 hides some (one-time codes, on some phones every message)
        // from listeners it doesn't trust, senders too: no conversation then,
        // or the user would seem to have written it.
        // (Ranking.hasSensitiveContent, Android 15; newer than the SDK built with.)
        val hidden = Build.VERSION.SDK_INT >= 35 && runCatching {
            Ranking::class.java.getMethod("hasSensitiveContent").invoke(ranking) == true
        }.getOrDefault(false)
        val chat = if (hidden) null else conversation(extras)
        var conversation: String? = null
        if (chat != null) {
            conversation = (chat.name ?: names[sbn.key])?.takeIf { it.isNotBlank() }
            conversation?.let { names[sbn.key] = it }
            title = conversation ?: title.takeIf { it != chat.me }.orEmpty()
            body = chat.text
        }
        // A mail: who wrote it in the title, its subject, its text in the body.
        var subject: String? = null
        if (chat == null && n.category == Notification.CATEGORY_EMAIL) {
            val from = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
            val bigTitle = extras.getCharSequence(Notification.EXTRA_TITLE_BIG)?.toString()
            val line = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            val big = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            subject = (bigTitle?.takeIf { it.isNotBlank() && it != from } ?: line)?.trim()?.takeIf { it.isNotEmpty() }
            if (from.isNotBlank()) title = from
            // The big text often starts with the subject line again.
            val text = big ?: line.orEmpty()
            body = subject?.let { text.removePrefix(it).trimStart().ifEmpty { null } } ?: text
        }
        if (title.isBlank() && body.isBlank()) return null
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
                if (chat.mine) put("mine", true) else chat.sender?.let { put("sender", it.take(MAX_TITLE)) }
                put("group", chat.group)
                if (chat.history.isNotEmpty()) {
                    put("messages", chat.history.map { m ->
                        buildMap {
                            if (!m.mine && m.sender != null) put("sender", m.sender.take(MAX_TITLE))
                            put("text", m.text.take(MAX_BODY))
                            put("time", m.time)
                            if (m.mine) put("mine", true)
                        }
                    })
                }
            }
            subject?.let { put("subject", it.take(1000)) }
            picture?.let { put("picture", it) }
        }
    }

    /// A MessagingStyle notification's chat: its [name] (the group's, else the
    /// other person's), the newest message's [sender] (none when it's [mine],
    /// the user's own), [text] and [time], the [face] of whoever wrote it, the
    /// latest messages ([history], oldest first) and the user's own name [me].
    private class Chat(
        val name: String?,
        val group: Boolean,
        val sender: String?,
        val mine: Boolean,
        val text: String,
        val time: Long?,
        val face: Icon?,
        val history: List<InboxStore.Message>,
        val me: String?,
    )

    private fun conversation(extras: Bundle): Chat? {
        @Suppress("DEPRECATION")
        val messages = extras.getParcelableArray(Notification.EXTRA_MESSAGES)?.filterIsInstance<Bundle>()
        val last = messages?.lastOrNull() ?: return null
        val text = last.getCharSequence("text")?.toString() ?: return null
        @Suppress("DEPRECATION")
        val earlier = extras.getParcelableArray(Notification.EXTRA_HISTORIC_MESSAGES)?.filterIsInstance<Bundle>().orEmpty()
        // The user, as the app names them ("You", "Vous").
        val user = if (Build.VERSION.SDK_INT >= 28) {
            @Suppress("DEPRECATION")
            extras.getParcelable(Notification.EXTRA_MESSAGING_PERSON) as? Person
        } else null
        val me = (user?.name ?: extras.getCharSequence("android.selfDisplayName"))?.toString()?.takeIf { it.isNotBlank() }
        val title = extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString()?.takeIf { it.isNotBlank() }
        val group = if (extras.containsKey(Notification.EXTRA_IS_GROUP_CONVERSATION)) {
            extras.getBoolean(Notification.EXTRA_IS_GROUP_CONVERSATION)
        } else {
            title != null
        }
        // Without a sender a message is the user's own; with one, it can still
        // be the user, named the way the app names them.
        fun mine(message: Bundle): Boolean {
            if (Build.VERSION.SDK_INT >= 28) {
                @Suppress("DEPRECATION")
                val person = message.getParcelable("sender_person") as? Person
                if (person != null) {
                    return user != null && (person.key != null && person.key == user.key ||
                        person.name?.toString() == user.name?.toString())
                }
            }
            val name = message.getCharSequence("sender")?.toString()
            return name.isNullOrBlank() || name == me
        }
        // In a chat with one person, the newest message they wrote names it.
        val other = messages.asReversed().firstOrNull { !mine(it) }?.let { senderOf(it)?.first }
        val history = (earlier + messages).mapNotNull { m ->
            val words = m.getCharSequence("text")?.toString()?.takeIf { it.isNotBlank() } ?: return@mapNotNull null
            val own = mine(m)
            InboxStore.Message(if (own) null else senderOf(m)?.first, words, m.getLong("time"), own)
        }.takeLast(LATEST)
        val lastMine = mine(last)
        return Chat(
            name = title ?: if (!group) other else null,
            group = group,
            sender = if (lastMine) null else senderOf(last)?.first,
            mine = lastMine,
            text = text,
            time = last.getLong("time").takeIf { it > 0 },
            face = if (lastMine) null else senderOf(last)?.second,
            history = history,
            me = me,
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

    /// A notification's reply: its first action that takes typed text.
    private fun replyAction(n: Notification): Notification.Action? =
        n.actions.orEmpty().firstOrNull { a -> a.remoteInputs.orEmpty().any { it.allowFreeFormInput } }

    /// Answers through the notification's own reply, as if typed on the phone;
    /// for a conversation whose notification went, through the reply kept.
    private fun replyTo(key: String, text: String): Boolean {
        val held = kept[key]?.takeIf { System.currentTimeMillis() - it.at < KEEP_REPLY_MS }
        val action = find(key)?.let { replyAction(it.notification) } ?: held?.action ?: run {
            kept.remove(key)
            return false
        }
        val inputs = action.remoteInputs
        val results = Bundle().apply {
            for (input in inputs) if (input.allowFreeFormInput) putCharSequence(input.resultKey, text)
        }
        val intent = Intent()
        RemoteInput.addResultsToIntent(inputs, intent, results)
        if (Build.VERSION.SDK_INT >= 28) RemoteInput.setResultsSource(intent, RemoteInput.SOURCE_FREE_FORM_INPUT)
        // The app cancelled it: nothing to answer with anymore.
        return runCatching { action.actionIntent.send(this, 0, intent) }.onFailure { kept.remove(key) }.isSuccess
    }

    /// Presses the button [action] (its index, as sent).
    private fun fire(key: String, action: String): Boolean {
        val sbn = find(key) ?: return false
        val button = action.toIntOrNull()?.let { sbn.notification.actions?.getOrNull(it) } ?: return false
        return runCatching { button.actionIntent.send() }.isSuccess
    }
}
