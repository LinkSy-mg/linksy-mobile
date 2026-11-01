package app.linksy

import android.util.Log

/// Lines for the app's Logs page from Android's side (the video encoder, the
/// camera, the screen capture), so the log people share says what happened
/// there too. Always in logcat; on the page while the app is open.
object Logs {
    @Volatile var sink: ((String) -> Unit)? = null

    fun add(line: String) {
        Log.i("linksy", line)
        sink?.invoke(line)
    }
}
