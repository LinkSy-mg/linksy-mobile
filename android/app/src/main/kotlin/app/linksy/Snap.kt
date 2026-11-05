package app.linksy

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.service.quicksettings.TileService
import android.widget.Toast

/// "Snap to Computer": the phone's camera app, then the picture goes on to the
/// app's one window, as a share does. It stays in the phone's pictures too.
class SnapActivity : Activity() {
    private var photo: Uri? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Taken back up after Android closed this for the camera's memory.
        photo = savedInstanceState?.getString(KEY_PHOTO)?.let(Uri::parse)
        if (savedInstanceState != null) return
        if (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            open()
        } else {
            requestPermissions(arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA)
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        photo?.let { outState.putString(KEY_PHOTO, it.toString()) }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) open() else finish()
    }

    private fun open() {
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, "Snap-${System.currentTimeMillis()}.jpg")
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            if (Build.VERSION.SDK_INT >= 29) {
                put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/Linksy")
            }
        }
        val uri = runCatching {
            contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
        }.getOrNull()
        if (uri == null) return failed()
        photo = uri
        val camera = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            .putExtra(MediaStore.EXTRA_OUTPUT, uri)
            .addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        try {
            startActivityForResult(camera, REQUEST_PHOTO)
        } catch (_: ActivityNotFoundException) {
            drop()
            failed()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val uri = photo
        if (requestCode != REQUEST_PHOTO || uri == null) return finish()
        if (resultCode != RESULT_OK) {
            drop()
            return finish()
        }
        Thread {
            val paths = ShareTarget.copyUris(this, listOf(uri), "snaps")
            runOnUiThread {
                startActivity(
                    Intent(this, MainActivity::class.java)
                        .setAction(ShareTarget.ACTION_SHARED)
                        .putExtra(ShareTarget.EXTRA_FILES, paths.toTypedArray())
                        .putExtra(ShareTarget.EXTRA_QUICK, true)
                        .apply { intent.getStringExtra(ShareTarget.EXTRA_DEVICE)?.let { putExtra(ShareTarget.EXTRA_DEVICE, it) } }
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP),
                )
                finish()
            }
        }.start()
    }

    /// Nothing was taken: no empty picture left behind.
    private fun drop() {
        photo?.let { runCatching { contentResolver.delete(it, null, null) } }
        photo = null
    }

    private fun failed() {
        Toast.makeText(this, R.string.snap_no_camera, Toast.LENGTH_LONG).show()
        finish()
    }

    private companion object {
        const val REQUEST_CAMERA = 1
        const val REQUEST_PHOTO = 2
        const val KEY_PHOTO = "photo"
    }
}

/// The Quick Settings tile for it.
class SnapTile : TileService() {
    override fun onClick() {
        super.onClick()
        val snap = Intent(this, SnapActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= 34) {
            startActivityAndCollapse(
                PendingIntent.getActivity(this, 0, snap, PendingIntent.FLAG_IMMUTABLE),
            )
        } else {
            @Suppress("DEPRECATION", "StartActivityAndCollapseDeprecated")
            startActivityAndCollapse(snap)
        }
    }
}
