package app.linksy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.provider.OpenableColumns
import android.system.Os
import java.io.File

/// "Share → Linksy" lands here. Shared files are copied while this activity
/// still holds the read access the sharing app gave it, then the text or the
/// copies' paths go on to the app's one window, so a share never opens a
/// second copy of Linksy inside the sharing app.
class ShareTarget : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val shared = intent
        @Suppress("DEPRECATION")
        val uris = buildList {
            shared.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.let(::addAll)
            if (isEmpty()) shared.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let(::add)
            if (isEmpty()) shared.clipData?.let { clip ->
                for (i in 0 until clip.itemCount) clip.getItemAt(i).uri?.let(::add)
            }
        }
        // "Copy to Computer" over selected text: to a clipboard, with no fuss.
        val selected = shared.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        val text = selected ?: shared.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        // Picked as a device in the share sheet: straight to it.
        val device = ShareShortcuts.deviceOf(shared)
        if (uris.isEmpty()) {
            forward(device) {
                if (!text.isNullOrBlank()) putExtra(EXTRA_TEXT, text)
                if (selected != null) putExtra(EXTRA_QUICK, true)
            }
            return
        }
        Thread {
            val paths = copyUris(this, uris, "shared")
            runOnUiThread { forward(device) { putExtra(EXTRA_FILES, paths.toTypedArray()) } }
        }.start()
    }

    private fun forward(device: String?, fill: Intent.() -> Unit) {
        startActivity(
            Intent(this, MainActivity::class.java).setAction(ACTION_SHARED).apply(fill)
                .apply { if (device != null) putExtra(EXTRA_DEVICE, device) }.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP,
            ),
        )
        finish()
    }

    companion object {
        const val ACTION_SHARED = "app.linksy.SHARED"
        const val EXTRA_TEXT = "app.linksy.text"
        const val EXTRA_FILES = "app.linksy.files"
        const val EXTRA_DEVICE = "app.linksy.device"

        /// A snap or copied text: straight to the one computer there is, and
        /// back to what was on screen.
        const val EXTRA_QUICK = "app.linksy.quick"

        /// Hands content over to the node, which sends from paths: each file
        /// as a link, under its own name, to a descriptor kept open here, so
        /// nothing is copied first (a long video would need its own size free
        /// again, and the transfer waits for the copy). Content that isn't a
        /// plain file (some cloud documents) is copied into the cache instead.
        /// Each hand-over gets its own folder under [folder], so a transfer
        /// still waiting keeps its files; folders a day old go, with their
        /// descriptors. Unreadable ones are left out.
        /// A folder from Android's picker, copied with its name and everything in it,
        /// for the core to read as a path; null if it can't be read.
        fun copyTree(context: Context, tree: Uri, folder: String): String? = runCatching {
            val root = File(context.cacheDir, folder).apply { mkdirs() }
            sweep(root)
            val resolver = context.contentResolver
            val top = android.provider.DocumentsContract.getTreeDocumentId(tree)
            val name = resolver.query(
                android.provider.DocumentsContract.buildDocumentUriUsingTree(tree, top),
                arrayOf(android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null,
            )?.use { c -> if (c.moveToFirst()) c.getString(0) else null } ?: "folder"
            val into = File(File(root, "${System.currentTimeMillis()}"), name.replace('/', '_')).apply { mkdirs() }
            fun copy(id: String, dir: File) {
                val children = android.provider.DocumentsContract.buildChildDocumentsUriUsingTree(tree, id)
                val columns = arrayOf(
                    android.provider.DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    android.provider.DocumentsContract.Document.COLUMN_MIME_TYPE,
                )
                resolver.query(children, columns, null, null, null)?.use { c ->
                    while (c.moveToNext()) {
                        val child = File(dir, c.getString(1).replace('/', '_'))
                        if (c.getString(2) == android.provider.DocumentsContract.Document.MIME_TYPE_DIR) {
                            child.mkdirs()
                            copy(c.getString(0), child)
                        } else {
                            val uri = android.provider.DocumentsContract.buildDocumentUriUsingTree(tree, c.getString(0))
                            resolver.openInputStream(uri)!!.use { input -> child.outputStream().use { input.copyTo(it) } }
                        }
                    }
                }
            }
            copy(top, into)
            into.path
        }.getOrNull()

        fun copyUris(context: Context, uris: List<Uri>, folder: String): List<String> {
            val root = File(context.cacheDir, folder).apply { mkdirs() }
            sweep(root)
            val dir = File(root, "${System.currentTimeMillis()}").apply { mkdirs() }
            val kept = mutableListOf<ParcelFileDescriptor>()
            val resolver = context.contentResolver
            val paths = uris.mapIndexedNotNull { i, uri ->
                runCatching {
                    val name = resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                        ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
                        ?.replace('/', '_') ?: "file-$i"
                    val file = File(File(dir, "$i").apply { mkdirs() }, name)
                    val fd = runCatching { resolver.openFileDescriptor(uri, "r") }.getOrNull()
                    if (fd != null && fd.statSize >= 0) {
                        Os.symlink("/proc/self/fd/${fd.fd}", file.path)
                        kept += fd
                    } else {
                        fd?.close()
                        resolver.openInputStream(uri)!!.use { input -> file.outputStream().use { input.copyTo(it) } }
                    }
                    file.path
                }.getOrNull()
            }
            synchronized(open) { open[dir.path] = kept }
            return paths
        }

        /// Descriptors behind each hand-over folder, closed when it goes.
        private val open = mutableMapOf<String, List<ParcelFileDescriptor>>()

        private fun sweep(root: File) {
            val old = System.currentTimeMillis() - 24 * 60 * 60 * 1000L
            for (dir in root.listFiles().orEmpty()) {
                val made = dir.name.toLongOrNull()
                // From an older run (its links lead nowhere now), or a day old.
                val stale = synchronized(open) { dir.path !in open } || made == null || made < old
                if (!stale) continue
                synchronized(open) { open.remove(dir.path) }?.forEach { runCatching { it.close() } }
                dir.deleteRecursively()
            }
        }
    }
}
