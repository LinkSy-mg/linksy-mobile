package app.linksy.files

import android.Manifest
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import app.linksy.Lang
import app.linksy.R
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File

/// Shows this phone's photos and videos to a computer's Gallery (docs/protocol.md
/// §4.18): its albums, a page of items at a time newest first, a thumbnail each,
/// and the ones it asks for as a transfer. Straight from MediaStore, with
/// Android's photo permission or All files access; nothing is copied until a
/// computer asks for one.
class GalleryServer(private val context: Context) {
    private val resolver: ContentResolver get() = context.contentResolver

    private val files: Uri = MediaStore.Files.getContentUri("external")

    /// Photos and videos, nothing else MediaStore lists.
    private val media = "${MediaStore.Files.FileColumns.MEDIA_TYPE} IN (" +
        "${MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE},${MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO})"

    /// When it was taken; when that's unknown, when it came.
    private val taken = "COALESCE(${MediaStore.MediaColumns.DATE_TAKEN}, ${MediaStore.MediaColumns.DATE_ADDED} * 1000)"

    fun start(workers: Int = 4) {
        repeat(workers) { n -> Thread({ loop() }, "linksy-gallery-$n").apply { isDaemon = true; start() } }
        watch()
    }

    /// Whether Android lets Linksy read the photos.
    fun allowed(): Boolean {
        fun granted(p: String) = context.checkSelfPermission(p) == PackageManager.PERMISSION_GRANTED
        if (Build.VERSION.SDK_INT >= 30 && Environment.isExternalStorageManager()) return true
        return if (Build.VERSION.SDK_INT >= 33) {
            granted(Manifest.permission.READ_MEDIA_IMAGES) || granted(Manifest.permission.READ_MEDIA_VIDEO)
        } else {
            granted(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
    }

    /// Photos taken, screenshots, deletions: the computers reload their first page.
    private fun watch() {
        val observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean) {
                NativeGallery.changed()
            }
        }
        for (uri in listOf(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, MediaStore.Video.Media.EXTERNAL_CONTENT_URI)) {
            runCatching { resolver.registerContentObserver(uri, true, observer) }
        }
    }

    private fun loop() {
        while (true) {
            val raw = NativeGallery.next() ?: return
            val request = runCatching { JSONObject(raw) }.getOrNull() ?: continue
            val id = request.getLong("call")
            try {
                handle(id, request)
            } catch (e: Exception) {
                Log.w("linksy", "gallery request failed", e)
                error(id, e.message ?: "That didn't work on the phone.")
            }
        }
    }

    private fun handle(id: Long, r: JSONObject) {
        if (!allowed()) return error(id, "Linksy isn't allowed to see this phone's photos.")
        when (r.getString("op")) {
            "albums" -> reply(id, JSONObject().put("type", "gallery_albums").put("albums", albums()))
            "items" -> {
                val limit = r.optInt("limit", 120).coerceIn(1, 500)
                val album = r.optString("album").takeIf { r.has("album") && it.isNotEmpty() }
                val before = r.optJSONObject("before")
                val (items, more) = items(album, before?.optLong("taken_ms"), before?.optString("id"), limit)
                reply(id, JSONObject().put("type", "gallery_items").put("items", items).put("more", more))
            }
            "thumb" -> {
                val jpeg = thumb(r.getString("id"), r.optInt("size", 256).coerceIn(32, 1024))
                    ?: return error(id, "That photo isn't there anymore.")
                NativeGallery.reply(id, JSONObject().put("type", "gallery_data").put("length", jpeg.size).toString(), jpeg)
            }
            "send" -> {
                val ids = r.getJSONArray("ids").let { a -> List(a.length()) { a.getString(it) } }
                val transfer = r.getString("transfer")
                val to = r.getString("from_id")
                reply(id, JSONObject().put("type", "gallery_ok"))
                val paths = ids.mapNotNull { path(it, transfer) }
                if (paths.isNotEmpty()) NativeGallery.send(to, transfer, paths.toTypedArray())
            }
            else -> error(id, "This phone can't do that yet.")
        }
    }

    // MediaStore.

    private fun query(projection: Array<String>, selection: String, args: Array<String>, order: String, limit: Int?) =
        if (Build.VERSION.SDK_INT >= 30) {
            resolver.query(
                files, projection,
                Bundle().apply {
                    putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection)
                    putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, args)
                    putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, order)
                    limit?.let { putInt(ContentResolver.QUERY_ARG_LIMIT, it) }
                },
                null,
            )
        } else {
            resolver.query(files, projection, selection, args, order + (limit?.let { " LIMIT $it" } ?: ""))
        }

    /// Each folder photos or videos are in, the fullest first.
    private fun albums(): JSONArray {
        val counts = linkedMapOf<String, Pair<String, Int>>()
        query(
            arrayOf(MediaStore.MediaColumns.BUCKET_ID, MediaStore.MediaColumns.BUCKET_DISPLAY_NAME),
            media, emptyArray(), "$taken DESC", null,
        )?.use { c ->
            while (c.moveToNext()) {
                val bucket = c.getString(0) ?: continue
                // Photos right in the storage, in no folder.
                val name = c.getString(1)?.takeIf { it.isNotBlank() } ?: Lang.str(context, R.string.phone_storage)
                counts[bucket] = name to (counts[bucket]?.second ?: 0) + 1
            }
        }
        return JSONArray().apply {
            counts.entries.sortedByDescending { it.value.second }.forEach { (bucket, v) ->
                put(JSONObject().put("id", bucket).put("name", v.first).put("count", v.second))
            }
        }
    }

    /// A page of items, newest first, older than ([beforeMs], [beforeId]).
    private fun items(album: String?, beforeMs: Long?, beforeId: String?, limit: Int): Pair<JSONArray, Boolean> {
        val where = StringBuilder(media)
        val args = mutableListOf<String>()
        album?.let {
            where.append(" AND ${MediaStore.MediaColumns.BUCKET_ID} = ?")
            args += it
        }
        // As numbers in the SQL itself: a bound argument is text, and SQLite
        // finds every number smaller than any text.
        if (beforeMs != null) {
            val last = beforeId?.toLongOrNull() ?: 0
            where.append(" AND ($taken < $beforeMs OR ($taken = $beforeMs AND ${MediaStore.MediaColumns._ID} < $last))")
        }
        val out = JSONArray()
        var more = false
        query(
            arrayOf(
                MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DISPLAY_NAME, MediaStore.Files.FileColumns.MEDIA_TYPE,
                MediaStore.MediaColumns.DATE_TAKEN, MediaStore.MediaColumns.DATE_ADDED, MediaStore.MediaColumns.SIZE,
                MediaStore.MediaColumns.DURATION,
            ),
            where.toString(), args.toTypedArray(), "$taken DESC, ${MediaStore.MediaColumns._ID} DESC", limit + 1,
        )?.use { c ->
            while (c.moveToNext()) {
                if (out.length() == limit) {
                    more = true
                    break
                }
                val video = c.getInt(2) == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                val ms = if (!c.isNull(3)) c.getLong(3) else c.getLong(4) * 1000
                out.put(
                    JSONObject()
                        .put("id", c.getLong(0).toString())
                        .put("name", c.getString(1) ?: "")
                        .put("taken_ms", ms)
                        .put("size", c.getLong(5))
                        .apply {
                            if (video) {
                                put("video", true)
                                if (!c.isNull(6)) put("duration_ms", c.getLong(6))
                            }
                        },
                )
            }
        }
        return out to more
    }

    /// The item's own uri (an image's or a video's), its name and its path.
    private fun find(id: String): Triple<Uri, String, String?>? {
        val n = id.toLongOrNull() ?: return null
        return query(
            arrayOf(MediaStore.Files.FileColumns.MEDIA_TYPE, MediaStore.MediaColumns.DISPLAY_NAME, MediaStore.MediaColumns.DATA),
            "${MediaStore.MediaColumns._ID} = ? AND $media", arrayOf(n.toString()), MediaStore.MediaColumns._ID, 1,
        )?.use { c ->
            if (!c.moveToFirst()) return null
            val base = if (c.getInt(0) == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
            Triple(ContentUris.withAppendedId(base, n), c.getString(1) ?: "$id.jpg", c.getString(2))
        }
    }

    /// A JPEG [size] px on its longer side, at most 256 KiB.
    private fun thumb(id: String, size: Int): ByteArray? {
        val (uri) = find(id) ?: return null
        val bitmap = if (Build.VERSION.SDK_INT >= 29) {
            resolver.loadThumbnail(uri, Size(size, size), null)
        } else {
            @Suppress("DEPRECATION")
            MediaStore.Images.Thumbnails.getThumbnail(resolver, id.toLong(), MediaStore.Images.Thumbnails.MINI_KIND, null)
        } ?: return null
        val longer = maxOf(bitmap.width, bitmap.height)
        val fitted = if (longer > size) {
            Bitmap.createScaledBitmap(bitmap, bitmap.width * size / longer, bitmap.height * size / longer, true)
        } else bitmap
        for (quality in listOf(85, 70, 55, 40)) {
            val out = ByteArrayOutputStream()
            fitted.compress(Bitmap.CompressFormat.JPEG, quality, out)
            if (out.size() <= 256 * 1024) return out.toByteArray()
        }
        return null
    }

    /// Where the transfer reads it: its own file when Linksy may read it,
    /// else a copy in the cache (gone a day later).
    private fun path(id: String, transfer: String): String? {
        val (uri, name, data) = find(id) ?: return null
        data?.let { File(it) }?.takeIf { it.canRead() }?.let { return it.path }
        val dir = File(context.cacheDir, "gallery/$transfer").apply { mkdirs() }
        File(context.cacheDir, "gallery").listFiles().orEmpty()
            .filter { System.currentTimeMillis() - it.lastModified() > 24 * 3600 * 1000L }
            .forEach { it.deleteRecursively() }
        val copy = File(dir, name.replace('/', '_'))
        return runCatching {
            resolver.openInputStream(uri)!!.use { input -> copy.outputStream().use { input.copyTo(it) } }
            copy.path
        }.getOrNull()
    }

    // Answers.

    private fun reply(id: Long, json: JSONObject) = NativeGallery.reply(id, json.toString(), null)

    private fun error(id: Long, message: String) =
        reply(id, JSONObject().put("type", "gallery_error").put("message", message))
}
