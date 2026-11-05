package app.linksy

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Log
import java.io.File

/// Received files go to Downloads/Linksy (Android 10+), where the Files app
/// and every other app find them, or to the folder the user chose in Settings.
/// MediaStore needs no permission for files an app adds itself, and the chosen
/// folder is a grant from Android's folder picker. Folders keep their shape:
/// Downloads/Linksy/Photos/a.jpg.
object Downloads {
    /// Moves each received file (under [root]) into [folder], else Downloads,
    /// and returns where it went (`content://` URIs); a file that couldn't
    /// move keeps its path. A folder that's gone falls back to Downloads, and
    /// older Android, with none, keeps them all where they are.
    fun publish(context: Context, root: File, paths: List<String>, folder: Uri? = null): List<String> {
        if (folder == null && Build.VERSION.SDK_INT < 29) return paths
        return paths.map { path ->
            val file = File(path)
            runCatching {
                val relative = file.parentFile?.canonicalPath?.removePrefix(root.canonicalPath)?.trim('/').orEmpty()
                val uri = folder?.let { tree ->
                    runCatching { intoFolder(context, tree, relative, file) }
                        .onFailure { Log.w("linksy", "couldn't move ${file.name} to the chosen folder", it) }
                        .getOrNull()
                } ?: if (Build.VERSION.SDK_INT >= 29) intoDownloads(context, relative, file) else return@map path
                file.delete()
                // Empty folders left behind in the app's folder go too.
                var dir = file.parentFile
                while (dir != null && dir.canonicalPath != root.canonicalPath && dir.list()?.isEmpty() == true) {
                    dir.delete()
                    dir = dir.parentFile
                }
                uri.toString()
            }.onFailure { Log.w("linksy", "couldn't move ${file.name} to Downloads", it) }.getOrDefault(path)
        }
    }

    private fun intoDownloads(context: Context, relative: String, file: File): Uri {
        val resolver = context.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, file.name)
            put(MediaStore.Downloads.MIME_TYPE, ReceivedFiles.mime(file.name))
            put(
                MediaStore.Downloads.RELATIVE_PATH,
                listOf(Environment.DIRECTORY_DOWNLOADS, "Linksy", relative).filter { it.isNotEmpty() }.joinToString("/"),
            )
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)!!
        try {
            resolver.openOutputStream(uri)!!.use { out -> file.inputStream().use { it.copyTo(out) } }
            resolver.update(uri, ContentValues().apply { put(MediaStore.Downloads.IS_PENDING, 0) }, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
        return uri
    }

    private fun intoFolder(context: Context, tree: Uri, relative: String, file: File): Uri {
        val resolver = context.contentResolver
        var parent = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        for (name in relative.split('/').filter { it.isNotEmpty() }) {
            parent = subfolder(context, tree, parent, name)
                ?: DocumentsContract.createDocument(resolver, parent, DocumentsContract.Document.MIME_TYPE_DIR, name)!!
        }
        val uri = DocumentsContract.createDocument(resolver, parent, ReceivedFiles.mime(file.name), file.name)!!
        try {
            resolver.openOutputStream(uri)!!.use { out -> file.inputStream().use { it.copyTo(out) } }
        } catch (e: Exception) {
            runCatching { DocumentsContract.deleteDocument(resolver, uri) }
            throw e
        }
        return uri
    }

    private fun subfolder(context: Context, tree: Uri, parent: Uri, name: String): Uri? {
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
        )
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, DocumentsContract.getDocumentId(parent))
        context.contentResolver.query(children, columns, null, null, null)?.use { c ->
            while (c.moveToNext()) {
                if (c.getString(1) == name && c.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR) {
                    return DocumentsContract.buildDocumentUriUsingTree(tree, c.getString(0))
                }
            }
        }
        return null
    }
}
