package app.linksy.files

import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.util.Log
import android.webkit.MimeTypeMap
import org.json.JSONArray
import app.linksy.Lang
import app.linksy.R
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer

/// Answers a computer browsing this phone (docs/protocol.md §4.9) from the one folder
/// the user chose in Android's picker: `/` is that folder, and the picker's grant
/// is all it uses. Or, with All files access ([everything]), from the phone's
/// whole shared storage, as plain files.
class FileServer(private val context: Context) {
    @Volatile var root: Uri? = null

    /// The phone's shared storage, when the user chose All files and Android
    /// allows it (MANAGE_EXTERNAL_STORAGE); [root] is left aside meanwhile.
    @Volatile var everything: File? = null

    private val resolver get() = context.contentResolver

    fun start(workers: Int = 3) {
        repeat(workers) { n -> Thread({ loop() }, "linksy-files-$n").apply { isDaemon = true; start() } }
    }

    private fun loop() {
        while (true) {
            val raw = NativeFiles.next() ?: return
            val request = runCatching { JSONObject(raw) }.getOrNull() ?: continue
            val id = request.getLong("id")
            try {
                handle(id, request)
            } catch (e: Exception) {
                Log.w("linksy", "file request failed", e)
                error(id, e.message ?: "That didn't work on the phone.")
            }
        }
    }

    private fun handle(id: Long, r: JSONObject) {
        everything?.let { return handlePlain(id, r, it) }
        val tree = root ?: return error(id, "No folder is shared.")
        val path = r.optString("path", "/")
        when (r.getString("op")) {
            // The shared folder's name, for "Pixel 9 (Documents)" on the computer.
            "info" -> reply(id, JSONObject().put("type", "fs_info").put("name", find(tree, "/")?.name ?: ""))
            "list" -> {
                val doc = find(tree, path) ?: return notFound(id, path)
                if (!doc.dir) return error(id, "That's a file, not a folder.")
                val entries = JSONArray()
                children(tree, doc.id).forEach { entries.put(it.json()) }
                reply(id, JSONObject().put("type", "fs_entries").put("entries", entries))
            }
            "stat" -> {
                val doc = find(tree, path) ?: return notFound(id, path)
                reply(id, JSONObject().put("type", "fs_entry").put("entry", doc.json()))
            }
            "read" -> {
                val doc = find(tree, path) ?: return notFound(id, path)
                val offset = r.getLong("offset")
                val length = r.getLong("length").coerceAtMost(4L shl 20).toInt()
                val bytes = resolver.openFileDescriptor(uri(tree, doc.id), "r")!!.use { pfd ->
                    FileInputStream(pfd.fileDescriptor).channel.use { ch ->
                        ch.position(offset)
                        val buf = ByteBuffer.allocate(length)
                        while (buf.hasRemaining() && ch.read(buf) > 0) Unit
                        buf.array().copyOf(buf.position())
                    }
                }
                NativeFiles.reply(id, JSONObject().put("type", "fs_data").put("length", bytes.size).toString(), bytes)
            }
            "write" -> {
                val body = NativeFiles.body(id) ?: return error(id, "The data didn't arrive.")
                val existing = find(tree, path)
                val docId = existing?.id ?: create(tree, path, dir = false) ?: return error(id, "Couldn't create ${name(path)}.")
                val offset = r.getLong("offset")
                resolver.openFileDescriptor(uri(tree, docId), "rw")!!.use { pfd ->
                    FileOutputStream(pfd.fileDescriptor).channel.use { ch ->
                        ch.position(offset)
                        ch.write(ByteBuffer.wrap(body))
                        if (r.optBoolean("truncate")) ch.truncate(offset + body.size)
                    }
                }
                ok(id)
            }
            "mkdir" -> if (find(tree, path) != null || create(tree, path, dir = true) != null) ok(id) else error(id, "Couldn't create the folder.")
            "delete" -> {
                val doc = find(tree, path) ?: return notFound(id, path)
                if (path.trim('/').isEmpty()) return error(id, "The shared folder itself can't be deleted.")
                DocumentsContract.deleteDocument(resolver, uri(tree, doc.id))
                forget(path)
                ok(id)
            }
            "rename" -> {
                val to = r.getString("to")
                val doc = find(tree, path) ?: return notFound(id, path)
                if (parent(path) == parent(to)) {
                    DocumentsContract.renameDocument(resolver, uri(tree, doc.id), name(to))
                        ?: return error(id, "Couldn't rename it.")
                } else {
                    val from = find(tree, parent(path)) ?: return notFound(id, parent(path))
                    val into = find(tree, parent(to)) ?: return notFound(id, parent(to))
                    val moved = DocumentsContract.moveDocument(resolver, uri(tree, doc.id), uri(tree, from.id), uri(tree, into.id))
                        ?: return error(id, "Couldn't move it.")
                    if (name(to) != name(path)) DocumentsContract.renameDocument(resolver, moved, name(to))
                }
                forget(path)
                ok(id)
            }
            else -> error(id, "This phone can't do that yet.")
        }
    }

    // All files: the same answers from plain files under [base].

    private fun handlePlain(id: Long, r: JSONObject, base: File) {
        val top = base.canonicalFile
        // Never above the shared storage, whatever the path says.
        fun at(path: String): File? =
            File(top, normalize(path).trimStart('/')).canonicalFile.takeIf { it == top || it.path.startsWith(top.path + "/") }
        fun entry(f: File) = JSONObject().put("name", f.name).put("dir", f.isDirectory)
            .put("size", if (f.isDirectory) 0 else f.length()).put("modified_ms", f.lastModified())
        val path = r.optString("path", "/")
        when (r.getString("op")) {
            "info" -> reply(id, JSONObject().put("type", "fs_info").put("name", Lang.str(context, R.string.all_files)))
            "list" -> {
                val dir = at(path)?.takeIf { it.exists() } ?: return notFound(id, path)
                if (!dir.isDirectory) return error(id, "That's a file, not a folder.")
                val entries = JSONArray()
                dir.listFiles().orEmpty().forEach { entries.put(entry(it)) }
                reply(id, JSONObject().put("type", "fs_entries").put("entries", entries))
            }
            "stat" -> {
                val f = at(path)?.takeIf { it.exists() } ?: return notFound(id, path)
                reply(id, JSONObject().put("type", "fs_entry").put("entry", entry(f)))
            }
            "read" -> {
                val f = at(path)?.takeIf { it.isFile } ?: return notFound(id, path)
                val offset = r.getLong("offset")
                val length = r.getLong("length").coerceAtMost(4L shl 20).toInt()
                val bytes = java.io.RandomAccessFile(f, "r").use { file ->
                    file.seek(offset)
                    val buf = ByteArray(length)
                    var got = 0
                    while (got < length) {
                        val n = file.read(buf, got, length - got)
                        if (n <= 0) break
                        got += n
                    }
                    buf.copyOf(got)
                }
                NativeFiles.reply(id, JSONObject().put("type", "fs_data").put("length", bytes.size).toString(), bytes)
            }
            "write" -> {
                val body = NativeFiles.body(id) ?: return error(id, "The data didn't arrive.")
                val f = at(path) ?: return error(id, "Couldn't create ${name(path)}.")
                val offset = r.getLong("offset")
                java.io.RandomAccessFile(f, "rw").use { file ->
                    file.seek(offset)
                    file.write(body)
                    if (r.optBoolean("truncate")) file.setLength(offset + body.size)
                }
                ok(id)
            }
            "mkdir" -> if (at(path)?.let { it.isDirectory || it.mkdirs() } == true) ok(id) else error(id, "Couldn't create the folder.")
            "delete" -> {
                val f = at(path)?.takeIf { it.exists() } ?: return notFound(id, path)
                if (f == top) return error(id, "The shared folder itself can't be deleted.")
                if (f.deleteRecursively()) ok(id) else error(id, "Couldn't delete it.")
            }
            "rename" -> {
                val f = at(path)?.takeIf { it.exists() } ?: return notFound(id, path)
                val to = at(r.getString("to")) ?: return error(id, "Couldn't move it.")
                if (f.renameTo(to)) ok(id) else error(id, "Couldn't move it.")
            }
            else -> error(id, "This phone can't do that yet.")
        }
    }

    // Documents, by path from the shared folder.

    private class Doc(val id: String, val name: String, val dir: Boolean, val size: Long, val modified: Long) {
        fun json(): JSONObject = JSONObject().put("name", name).put("dir", dir)
            .put("size", if (dir) 0 else size).put("modified_ms", modified)
    }

    /// Path → document id, so deep paths don't walk the tree every time.
    private val ids = java.util.concurrent.ConcurrentHashMap<String, String>()

    private fun forget(path: String) {
        val key = normalize(path)
        ids.keys.removeIf { it == key || it.startsWith("$key/") }
    }

    private fun normalize(path: String) = "/" + path.split('/').filter { it.isNotEmpty() }.joinToString("/")

    private fun uri(tree: Uri, docId: String) = DocumentsContract.buildDocumentUriUsingTree(tree, docId)

    private fun rootId(tree: Uri) = DocumentsContract.getTreeDocumentId(tree)

    private fun find(tree: Uri, path: String): Doc? {
        val key = normalize(path)
        ids[key]?.let { id -> query(tree, id)?.let { return it } }
        var doc = query(tree, rootId(tree))?.let { Doc(it.id, "", true, 0, it.modified) } ?: return null
        var at = ""
        for (part in key.split('/').filter { it.isNotEmpty() }) {
            at += "/$part"
            doc = children(tree, doc.id).firstOrNull { it.name == part } ?: return null
            ids[at] = doc.id
        }
        return doc
    }

    private val columns = arrayOf(
        Document.COLUMN_DOCUMENT_ID, Document.COLUMN_DISPLAY_NAME, Document.COLUMN_MIME_TYPE,
        Document.COLUMN_SIZE, Document.COLUMN_LAST_MODIFIED,
    )

    private fun doc(c: android.database.Cursor) = Doc(
        id = c.getString(0),
        name = c.getString(1) ?: "",
        dir = c.getString(2) == Document.MIME_TYPE_DIR,
        size = if (c.isNull(3)) 0 else c.getLong(3),
        modified = if (c.isNull(4)) 0 else c.getLong(4),
    )

    private fun query(tree: Uri, docId: String): Doc? =
        runCatching {
            resolver.query(uri(tree, docId), columns, null, null, null)?.use { c -> if (c.moveToFirst()) doc(c) else null }
        }.getOrNull()

    private fun children(tree: Uri, docId: String): List<Doc> {
        val uri = DocumentsContract.buildChildDocumentsUriUsingTree(tree, docId)
        return resolver.query(uri, columns, null, null, null)?.use { c ->
            buildList { while (c.moveToNext()) add(doc(c)) }
        }.orEmpty()
    }

    private fun create(tree: Uri, path: String, dir: Boolean): String? {
        val parent = find(tree, parent(path))?.takeIf { it.dir } ?: return null
        val name = name(path)
        val mime = if (dir) Document.MIME_TYPE_DIR else
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(name.substringAfterLast('.', "").lowercase())
                ?: "application/octet-stream"
        val created = DocumentsContract.createDocument(resolver, uri(tree, parent.id), mime, name) ?: return null
        val id = DocumentsContract.getDocumentId(created)
        ids[normalize(path)] = id
        return id
    }

    private fun parent(path: String) = normalize(path).substringBeforeLast('/').ifEmpty { "/" }

    private fun name(path: String) = normalize(path).substringAfterLast('/')

    // Answers.

    private fun reply(id: Long, json: JSONObject) = NativeFiles.reply(id, json.toString(), null)

    private fun ok(id: Long) = reply(id, JSONObject().put("type", "fs_ok"))

    private fun error(id: Long, message: String, notFound: Boolean = false) =
        reply(id, JSONObject().put("type", "fs_error").put("message", message).put("not_found", notFound))

    private fun notFound(id: Long, path: String) = error(id, "${normalize(path)} isn't there.", notFound = true)
}
