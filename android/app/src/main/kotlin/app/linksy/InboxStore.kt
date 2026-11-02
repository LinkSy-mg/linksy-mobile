package app.linksy

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.Executors

/// What the notification listener saw of each conversation, per app and
/// conversation name, for a computer that scrolls back (docs/protocol.md §4.5,
/// `inbox_history`). Only Linksy's own files hold it: the newest [KEEP]
/// messages of the [CONVERSATIONS] most recent conversations. Android lets no
/// app read another's messages, so this is all there is.
object InboxStore {
    private const val KEEP = 300
    private const val CONVERSATIONS = 300

    /// One message, as `notification_posted`'s `messages` carry it.
    data class Message(val sender: String?, val text: String, val time: Long, val mine: Boolean) {
        fun json(): JSONObject = JSONObject().apply {
            if (!mine && sender != null) put("sender", sender)
            put("text", text)
            put("time", time)
            if (mine) put("mine", true)
        }

        companion object {
            fun from(j: JSONObject) = Message(
                sender = j.optString("sender").takeIf { j.has("sender") && it.isNotEmpty() },
                text = j.optString("text"),
                time = j.optLong("time"),
                mine = j.optBoolean("mine"),
            )
        }
    }

    /// Reads and writes one at a time, off the main thread.
    private val io = Executors.newSingleThreadExecutor { Thread(it, "linksy-inbox").apply { isDaemon = true } }

    private fun dir(context: Context) = File(context.filesDir, "inbox").apply { mkdirs() }

    private fun file(context: Context, app: String, conversation: String): File {
        val hash = MessageDigest.getInstance("SHA-256").digest("$app\u0000$conversation".toByteArray())
        return File(dir(context), hash.take(12).joinToString("") { "%02x".format(it) } + ".json")
    }

    private fun read(f: File): List<Message> = runCatching {
        val messages = JSONObject(f.readText()).getJSONArray("messages")
        List(messages.length()) { Message.from(messages.getJSONObject(it)) }
    }.getOrDefault(emptyList())

    /// Adds what a notification shows of a conversation; the ones already kept
    /// stay as they are.
    fun add(context: Context, app: String, conversation: String, messages: List<Message>) {
        if (messages.isEmpty()) return
        io.execute {
            runCatching {
                val f = file(context, app, conversation)
                val kept = read(f)
                val seen = kept.mapTo(HashSet()) { listOf(it.time, it.mine, it.sender, it.text) }
                val new = messages.filter { seen.add(listOf(it.time, it.mine, it.sender, it.text)) }
                if (new.isEmpty()) return@runCatching
                val all = (kept + new).sortedBy { it.time }.takeLast(KEEP)
                f.writeText(
                    JSONObject().put("app", app).put("conversation", conversation)
                        .put("messages", JSONArray().apply { all.forEach { put(it.json()) } }).toString(),
                )
                // The oldest conversations go once there are too many.
                dir(context).listFiles().orEmpty().sortedByDescending { it.lastModified() }
                    .drop(CONVERSATIONS).forEach { it.delete() }
            }
        }
    }

    /// The messages older than [beforeMs], oldest first, at most [limit]; and
    /// whether there are older ones still. [done] runs off the main thread.
    fun page(context: Context, app: String, conversation: String, beforeMs: Long, limit: Int, done: (List<Message>, Boolean) -> Unit) {
        io.execute {
            val older = read(file(context, app, conversation)).filter { it.time < beforeMs }
            val page = older.takeLast(limit.coerceIn(1, 200))
            done(page, older.size > page.size)
        }
    }

    /// Everything, when the user turns notifications on the computers off.
    fun forget(context: Context) {
        io.execute { dir(context).listFiles().orEmpty().forEach { it.delete() } }
    }
}
