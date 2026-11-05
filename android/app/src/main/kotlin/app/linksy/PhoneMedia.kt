package app.linksy

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Size
import java.io.ByteArrayOutputStream

/// This phone's photos and videos for the phone-to-phone picker, newest first.
/// The same permission as the Gallery (READ_MEDIA_IMAGES and _VIDEO).
object PhoneMedia {
    private val files: Uri = MediaStore.Files.getContentUri("external")
    private val media = "${MediaStore.Files.FileColumns.MEDIA_TYPE} IN (" +
        "${MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE},${MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO})"
    private val taken = "COALESCE(${MediaStore.MediaColumns.DATE_TAKEN}, ${MediaStore.MediaColumns.DATE_ADDED} * 1000)"

    fun albums(context: Context): List<Map<String, Any?>> {
        val seen = LinkedHashMap<String, String>()
        context.contentResolver.query(
            files,
            arrayOf(MediaStore.MediaColumns.BUCKET_ID, MediaStore.MediaColumns.BUCKET_DISPLAY_NAME),
            media, null, "$taken DESC",
        )?.use { c ->
            while (c.moveToNext()) {
                val id = c.getString(0) ?: continue
                seen.putIfAbsent(id, c.getString(1) ?: "")
            }
        }
        return seen.map { (id, name) -> mapOf("id" to id, "name" to name) }
    }

    /// A page of what's older than [beforeMs].
    fun items(context: Context, album: String?, beforeMs: Long?, limit: Int): List<Map<String, Any?>> {
        val where = StringBuilder(media)
        val args = mutableListOf<String>()
        if (album != null) {
            where.append(" AND ${MediaStore.MediaColumns.BUCKET_ID} = ?")
            args += album
        }
        if (beforeMs != null) where.append(" AND $taken < $beforeMs")
        val projection = arrayOf(
            MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.SIZE, MediaStore.MediaColumns.DATE_TAKEN, MediaStore.MediaColumns.DATE_ADDED,
            MediaStore.Files.FileColumns.MEDIA_TYPE,
        )
        val out = mutableListOf<Map<String, Any?>>()
        query(context, projection, where.toString(), args.toTypedArray(), limit)?.use { c ->
            while (c.moveToNext() && out.size < limit) {
                out += mapOf(
                    "id" to c.getLong(0),
                    "path" to c.getString(1),
                    "name" to c.getString(2),
                    "size" to c.getLong(3),
                    "taken" to if (c.isNull(4)) c.getLong(5) * 1000 else c.getLong(4),
                    "video" to (c.getInt(6) == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO),
                )
            }
        }
        return out
    }

    private fun query(
        context: Context,
        projection: Array<String>,
        selection: String,
        args: Array<String>,
        limit: Int,
    ): Cursor? {
        val order = "$taken DESC, ${MediaStore.MediaColumns._ID} DESC"
        if (Build.VERSION.SDK_INT < 30) {
            return context.contentResolver.query(files, projection, selection, args, "$order LIMIT $limit")
        }
        val bundle = Bundle().apply {
            putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection)
            putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, args)
            putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, order)
            putInt(ContentResolver.QUERY_ARG_LIMIT, limit)
        }
        return context.contentResolver.query(files, projection, bundle, null)
    }

    /// A small JPEG of a file by its path or `content://` URI, on Android 10 and up.
    fun thumbOf(context: Context, ref: String, size: Int): ByteArray? = runCatching {
        if (Build.VERSION.SDK_INT < 29) return null
        val want = Size(size, size)
        val bitmap = when {
            ref.startsWith("content://") -> context.contentResolver.loadThumbnail(Uri.parse(ref), want, null)
            ref.substringAfterLast('.').lowercase() in setOf("mp4", "mov", "mkv", "webm") ->
                android.media.ThumbnailUtils.createVideoThumbnail(java.io.File(ref), want, null)
            else -> android.media.ThumbnailUtils.createImageThumbnail(java.io.File(ref), want, null)
        }
        ByteArrayOutputStream().also { bitmap.compress(Bitmap.CompressFormat.JPEG, 80, it) }.toByteArray()
    }.getOrNull()

    /// A small JPEG for the grid.
    fun thumb(context: Context, id: Long, video: Boolean, size: Int): ByteArray? = runCatching {
        val base = if (video) MediaStore.Video.Media.EXTERNAL_CONTENT_URI else MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val uri = ContentUris.withAppendedId(base, id)
        val bitmap = if (Build.VERSION.SDK_INT >= 29) {
            context.contentResolver.loadThumbnail(uri, Size(size, size), null)
        } else {
            @Suppress("DEPRECATION")
            MediaStore.Images.Thumbnails.getThumbnail(
                context.contentResolver, id, MediaStore.Images.Thumbnails.MINI_KIND, null,
            ) ?: return null
        }
        ByteArrayOutputStream().also { bitmap.compress(Bitmap.CompressFormat.JPEG, 80, it) }.toByteArray()
    }.getOrNull()
}
