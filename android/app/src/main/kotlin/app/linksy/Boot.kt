package app.linksy

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// Settings › Start When the Phone Starts (mobile#23): after a restart, Linksy
/// comes back in the background, with its quiet notification and no screen,
/// so computers see the phone without the app being opened. Android sends
/// nothing to an app that was force-stopped, until it's opened again.
class Boot : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in ACTIONS || !wanted(context)) return
        Logs.add("Started with the phone")
        KeepAlive.boot(context)
    }

    companion object {
        private val ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            // Some makers' fast boot.
            "android.intent.action.QUICKBOOT_POWERON",
        )

        /// The user's choice, else on once a computer is paired (the app keeps
        /// `has_computer` up to date).
        fun wanted(context: Context): Boolean {
            val prefs = context.getSharedPreferences("linksy", Context.MODE_PRIVATE)
            return when (prefs.getString("app.start_at_boot", null)) {
                "on" -> true
                "off" -> false
                else -> prefs.getString("app.has_computer", null) == "yes"
            }
        }
    }
}
