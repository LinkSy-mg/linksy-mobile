package app.linksy

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.Drawable
import android.net.wifi.WifiManager
import android.os.Build
import android.os.StatFs
import java.io.ByteArrayOutputStream
import java.io.File
import java.security.MessageDigest

/// This phone's apps, for sending to another phone and for answering one that
/// asks (docs/protocol.md §4.22). Launchable apps are visible through the
/// manifest's `<queries>`, so there's no QUERY_ALL_PACKAGES to explain. An
/// app's files are read where Android keeps them: nothing is copied.
object Apps {
    private const val MAX_ICON = 16 * 1024

    /// What can travel: launchable apps the user installed, not Linksy.
    fun list(context: Context): List<Map<String, Any?>> {
        val pm = context.packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        @Suppress("DEPRECATION")
        val found = pm.queryIntentActivities(launcher, 0).map { it.activityInfo.packageName }.toSet()
        return found.filter { it != context.packageName }.mapNotNull { name ->
            runCatching { describe(pm, name) }.getOrNull()
        }.sortedBy { (it["label"] as String).lowercase() }
    }

    private fun describe(pm: PackageManager, name: String): Map<String, Any?>? {
        val info = packageInfo(pm, name) ?: return null
        val app = info.applicationInfo ?: return null
        if (app.flags and ApplicationInfo.FLAG_SYSTEM != 0) return null
        val apks = listOfNotNull(app.sourceDir) + (app.splitSourceDirs?.toList() ?: emptyList())
        return mapOf(
            "package" to name,
            "label" to pm.getApplicationLabel(app).toString(),
            "version_code" to versionCode(info),
            "version_name" to info.versionName,
            "signer" to signer(info),
            "apks" to apks,
            "size" to apks.sumOf { File(it).length() },
            "icon" to icon(pm.getApplicationIcon(app)),
        )
    }

    private fun packageInfo(pm: PackageManager, name: String): PackageInfo? = runCatching {
        @Suppress("DEPRECATION")
        pm.getPackageInfo(
            name,
            if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES,
        )
    }.getOrNull()

    @Suppress("DEPRECATION")
    fun versionCode(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()

    /// SHA-256 of the certificate it's signed with, in hex: the current one when
    /// the developer rotated keys.
    @Suppress("DEPRECATION")
    fun signer(info: PackageInfo): String? {
        val cert = if (Build.VERSION.SDK_INT >= 28) {
            val signing = info.signingInfo ?: return null
            if (signing.hasMultipleSigners()) signing.apkContentsSigners.firstOrNull()
            else signing.signingCertificateHistory.lastOrNull()
        } else {
            info.signatures?.firstOrNull()
        } ?: return null
        return MessageDigest.getInstance("SHA-256").digest(cert.toByteArray())
            .joinToString("") { "%02x".format(it) }
    }

    /// An installed app's icon; null when it isn't here.
    fun iconOf(context: Context, name: String): ByteArray? = runCatching {
        icon(context.packageManager.getApplicationIcon(name))
    }.getOrNull()

    /// A PNG of 96 px, smaller if that doesn't fit in what an offer allows.
    private fun icon(drawable: Drawable): ByteArray? {
        for (size in intArrayOf(96, 72, 48, 32)) {
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            draw(drawable, Canvas(bitmap), size)
            val out = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            bitmap.recycle()
            if (out.size() <= MAX_ICON) return out.toByteArray()
        }
        return null
    }

    /// Without the launcher's mask where it can be left out, which on some phones
    /// is a circle: Linksy gives apps its own shape, on both phones. An adaptive
    /// icon's layers have a third of their size as margin for that mask.
    private fun draw(drawable: Drawable, canvas: Canvas, size: Int) {
        if (Build.VERSION.SDK_INT >= 26 && drawable is AdaptiveIconDrawable) {
            val edge = size / 4
            for (layer in listOfNotNull(drawable.background, drawable.foreground)) {
                layer.setBounds(-edge, -edge, size + edge, size + edge)
                layer.draw(canvas)
            }
        } else {
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)
        }
    }

    /// How this phone's copy of each probed app compares with the one to be sent.
    fun compare(context: Context, probes: List<Map<String, Any?>>): List<Map<String, Any?>> {
        val pm = context.packageManager
        return probes.map { probe ->
            val name = probe["package"] as String
            val info = packageInfo(pm, name)
                ?: return@map mapOf<String, Any?>("package" to name, "have" to "none")
            val wanted = (probe["version_code"] as Number).toLong()
            val mine = versionCode(info)
            val theirs = probe["signer"] as String?
            val have = when {
                theirs != null && signer(info) != theirs -> "other_signer"
                mine == wanted -> "same"
                mine < wanted -> "older"
                else -> "newer"
            }
            mapOf("package" to name, "have" to have, "version_code" to mine)
        }
    }

    /// What can be taken at once. Received files are staged, then copied out,
    /// so both copies exist together: half of what's free.
    fun free(context: Context): Long {
        val dir = context.getExternalFilesDir(null) ?: context.filesDir
        return StatFs(dir.path).availableBytes / 2
    }

    /// Whether a direct link could come up now (§4.17).
    fun direct(context: Context): String {
        if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI_DIRECT)) return "unsupported"
        val needs = if (Build.VERSION.SDK_INT >= 33) Manifest.permission.NEARBY_WIFI_DEVICES
        else Manifest.permission.ACCESS_FINE_LOCATION
        if (context.checkSelfPermission(needs) != PackageManager.PERMISSION_GRANTED) return "no_permission"
        val wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        return if (wifi.isWifiEnabled) "ready" else "wifi_off"
    }
}
