package app.linksy.media

import android.content.Context
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaCodecInfo.VideoCapabilities
import android.media.projection.MediaProjection
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import android.view.Display
import android.view.WindowManager
import app.linksy.Logs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/// The phone's screen, mirrored into an encoder at its exact shape: the
/// desktop fits its window to the stream, so the video must not be
/// letterboxed here (docs/protocol.md §6, §7). Follows rotation by restarting the
/// encoder at the new shape; the new stream opens with SPS/PPS and a keyframe.
class ScreenShare(
    private val context: Context,
    val projection: MediaProjection,
    private val session: String,
    private val onEnded: () -> Unit,
) : Share {
    private val main = Handler(Looper.getMainLooper())
    private val caps = H264Encoder.capabilities()
    private val displays = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
    private var size: Pair<Int, Int>
    private var encoder: H264Encoder
    private val display: VirtualDisplay
    @Volatile private var stopped = false

    private val rotation = object : DisplayManager.DisplayListener {
        override fun onDisplayChanged(id: Int) {
            if (id != Display.DEFAULT_DISPLAY || stopped) return
            ShareService.tellRotation(session, degrees())
            val next = fit(screen(), caps)
            if (next != size) restart(next)
        }

        override fun onDisplayAdded(id: Int) {}
        override fun onDisplayRemoved(id: Int) {}
    }

    init {
        size = fit(screen(), caps)
        encoder = encoder(size)
        // Android 14 wants this before the virtual display exists.
        projection.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                if (!stopped) Logs.add("Screen: Android stopped the screen capture")
                onEnded()
            }
        }, main)
        // The encoder's own size: smaller than asked when it can't take that.
        display = projection.createVirtualDisplay(
            "linksy", encoder.width, encoder.height, density(),
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, encoder.inputSurface, null, null,
        ) ?: error("screen capture gave no display")
        displays.registerDisplayListener(rotation, main)
        ShareService.tellRotation(session, degrees())
    }

    private fun encoder(size: Pair<Int, Int>) =
        if (sixty(size)) {
            H264Encoder(size.first, size.second, bitrate = 14_000_000, fps = 60, label = "Screen", session = session, fast = true, onEnded = onEnded)
        } else {
            H264Encoder(size.first, size.second, bitrate = 6_000_000, fps = 30, label = "Screen", session = session, onEnded = onEnded)
        }

    /// This phone's encoder can do 60 at this size.
    private fun sixty(size: Pair<Int, Int>) =
        runCatching { caps?.areSizeAndRateSupported(size.first, size.second, 60.0) == true }.getOrDefault(false)

    /// The old encoder stops before the new one starts, so the stream never
    /// mixes frames from the two.
    private fun restart(next: Pair<Int, Int>) {
        display.surface = null
        encoder.stop()
        size = next
        encoder = encoder(next)
        display.resize(encoder.width, encoder.height, density())
        display.surface = encoder.inputSurface
    }

    override fun stop() {
        stopped = true
        displays.unregisterDisplayListener(rotation)
        display.release()
        encoder.stop()
        projection.stop()
    }

    /// How far the display is turned from the phone's natural way up.
    private fun degrees(): Int {
        @Suppress("DEPRECATION")
        return (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.rotation * 90
    }

    private fun metrics() = DisplayMetrics().also {
        @Suppress("DEPRECATION")
        (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.getRealMetrics(it)
    }

    private fun screen() = metrics().let { it.widthPixels to it.heightPixels }

    private fun density() = metrics().densityDpi

    companion object {
        /// The screen's exact shape within 1920×1080 (either way round): the
        /// width a multiple of 16, the height from the aspect ratio and even
        /// (H.264 needs even sizes; encoders pad internally and signal the
        /// crop), stepping down until the encoder takes it.
        fun fit(screen: Pair<Int, Int>, caps: VideoCapabilities?): Pair<Int, Int> {
            val (w, h) = screen
            val scale = min(1.0, min(1920.0 / max(w, h), 1080.0 / min(w, h)))
            var width = (w * scale).toInt() / 16 * 16
            while (width >= 16) {
                val height = ((width.toDouble() * h / w) / 2).roundToInt() * 2
                if (caps == null || caps.isSizeSupported(width, height)) return width to height
                width -= 16
            }
            return 16 to 16
        }
    }
}

/// Something being shared into a session.
interface Share {
    fun stop()
}
