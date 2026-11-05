package app.linksy

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.io.File

/// Installs apps that came from another phone (docs/protocol.md §4.22): each in
/// one session, one after the other, and Android asks the user every time. What
/// arrived is checked against what the other phone said first; a description
/// is only a description. The APKs go afterwards, whatever the outcome.
object AppInstaller {
    /// Called with the package and `installed`, `cancelled`, `mismatch`,
    /// `other_signer` or `failed:<message>`; `done` with no package at the end.
    var onStatus: ((String?, String) -> Unit)? = null

    private data class Item(val package_: String, val versionCode: Long, val signer: String?, val apks: List<File>)

    private val queue = ArrayDeque<Item>()
    private var current: Item? = null

    /// [apps]: `{"package","version_code","signer","apks":[paths]}`.
    fun install(context: Context, apps: List<Map<String, Any?>>) {
        val app = context.applicationContext
        for (a in apps) {
            @Suppress("UNCHECKED_CAST")
            queue += Item(
                a["package"] as String,
                (a["version_code"] as Number).toLong(),
                a["signer"] as String?,
                (a["apks"] as List<String>).map(::File),
            )
        }
        if (current == null) next(app)
    }

    private fun next(context: Context) {
        val item = queue.removeFirstOrNull()
        current = item
        if (item == null) return report(null, "done")
        Thread {
            val refused = check(context, item)
            if (refused != null) return@Thread finish(context, refused)
            runCatching { commit(context, item) }.onFailure {
                Log.w("linksy", "${item.package_} not installed ($it)")
                finish(context, "failed:${it.message ?: it.javaClass.simpleName}")
            }
        }.start()
    }

    /// Why not to install it, or null.
    private fun check(context: Context, item: Item): String? {
        val pm = context.packageManager
        val base = item.apks.firstOrNull { it.name == "base.apk" } ?: item.apks.firstOrNull() ?: return "mismatch"
        @Suppress("DEPRECATION")
        val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val archive = pm.getPackageArchiveInfo(base.path, flags) ?: return "mismatch"
        if (archive.packageName != item.package_) return "mismatch"
        if (Apps.versionCode(archive) != item.versionCode) return "mismatch"
        val signer = Apps.signer(archive)
        if (item.signer != null && signer != item.signer) return "mismatch"
        val installed = runCatching {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(item.package_, flags)
        }.getOrNull()
        if (installed != null && Apps.signer(installed) != signer) return "other_signer"
        return null
    }

    private fun commit(context: Context, item: Item) {
        val installer = context.packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
            .apply { setAppPackageName(item.package_) }
        val id = installer.createSession(params)
        installer.openSession(id).use { session ->
            for (apk in item.apks) {
                session.openWrite(apk.name, 0, apk.length()).use { out ->
                    apk.inputStream().use { it.copyTo(out) }
                    session.fsync(out)
                }
            }
            val status = PendingIntent.getBroadcast(
                context, id, Intent(context, Status::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            session.commit(status.intentSender)
        }
    }

    private fun finish(context: Context, outcome: String) {
        val item = current ?: return
        for (apk in item.apks) apk.delete()
        item.apks.firstOrNull()?.parentFile?.takeIf { it.list()?.isEmpty() == true }?.delete()
        report(item.package_, outcome)
        next(context)
    }

    private fun report(name: String?, status: String) {
        android.os.Handler(android.os.Looper.getMainLooper()).post { onStatus?.invoke(name, status) }
    }

    /// The installer's answer: its own confirmation when it needs one, else on
    /// to the next app.
    class Status : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val app = context.applicationContext
            when (val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)) {
                PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                    @Suppress("DEPRECATION")
                    val confirm = (if (Build.VERSION.SDK_INT >= 33) intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                    else intent.getParcelableExtra(Intent.EXTRA_INTENT)) ?: return finish(app, "failed:no confirmation")
                    context.startActivity(confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                }
                PackageInstaller.STATUS_SUCCESS -> finish(app, "installed")
                PackageInstaller.STATUS_FAILURE_ABORTED -> finish(app, "cancelled")
                else -> {
                    val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: "status $status"
                    Log.w("linksy", "not installed: $message")
                    finish(app, "failed:$message")
                }
            }
        }
    }
}
