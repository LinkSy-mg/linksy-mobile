package app.linksy.media

import android.media.MediaCodec
import android.media.MediaCodecInfo.CodecCapabilities
import android.media.MediaCodecInfo.CodecProfileLevel
import android.media.MediaFormat
import android.os.Build
import android.os.SystemClock
import android.view.Surface
import app.linksy.Logs
import kotlin.math.roundToInt

/// Hardware H.264 the way linksy-desktop decodes it (docs/protocol.md §4.8): Annex-B,
/// Constrained Baseline, a keyframe at least every 2 s, SPS/PPS before every
/// keyframe. Frames come in through [inputSurface], drawn at [width]×[height];
/// each encoded unit goes to the session. [onEnded] runs once if the session goes
/// away. What it does goes to the Logs page, under [label] ("Screen", "Webcam").
class H264Encoder(
    wantWidth: Int,
    wantHeight: Int,
    bitrate: Int,
    fps: Int,
    private val label: String,
    private val session: String,
    private val onEnded: () -> Unit,
) {
    private val codec: MediaCodec
    /// The size it encodes: the one asked for, or smaller in the same shape when
    /// the encoder can't take it.
    val width: Int
    val height: Int
    val inputSurface: Surface
    @Volatile private var running = true
    private val drain: Thread

    // For the log: what came out, and since when.
    private val began = SystemClock.elapsedRealtime()
    private var frames = 0
    private var keyframes = 0
    private var sent = 0L

    init {
        val (opened, size) = open(wantWidth to wantHeight, bitrate, fps)
        codec = opened
        width = size.first
        height = size.second
        inputSurface = codec.createInputSurface()
        codec.start()
        drain = Thread(::drainLoop, "linksy-encoder").apply { start() }
    }

    /// The phone's default H.264 encoder (its hardware one) at [want], or at the
    /// largest size of that shape its capabilities allow; if it refuses even that,
    /// Android's software encoder. Some refuse a size their capabilities allow: a
    /// Qualcomm encoder on Android 11 and a portrait 864×1920 (releases#6).
    private fun open(want: Pair<Int, Int>, bitrate: Int, fps: Int): Pair<MediaCodec, Pair<Int, Int>> {
        val tried = mutableSetOf<String>()
        var failure: Exception? = null
        for (name in listOf<String?>(null) + SOFTWARE) {
            val candidate = runCatching {
                if (name == null) MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC) else MediaCodec.createByCodecName(name)
            }.getOrNull() ?: continue
            if (!tried.add(candidate.name)) {
                candidate.release()
                continue
            }
            val caps = runCatching { candidate.codecInfo.getCapabilitiesForType(MediaFormat.MIMETYPE_VIDEO_AVC).videoCapabilities }.getOrNull()
            val size = fit(want, caps)
            try {
                configure(candidate, size, bitrate, fps)
                if (size != want) Logs.add("$label encoder: ${want.first}×${want.second} is more than it takes, ${size.first}×${size.second} instead")
                return candidate to size
            } catch (e: Exception) {
                failure = e
                candidate.release()
            }
        }
        throw failure ?: IllegalStateException("no H.264 encoder")
    }

    private fun configure(codec: MediaCodec, size: Pair<Int, Int>, bitrate: Int, fps: Int) {
        val (width, height) = size
        fun format(profile: Int) = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, CodecCapabilities.COLOR_FormatSurface)
            setInteger(MediaFormat.KEY_BIT_RATE, bitrate)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
            setInteger(MediaFormat.KEY_PROFILE, profile)
            // A still screen produces no frames; repeat the last one so the
            // viewer keeps getting pictures (and keyframes).
            setLong(MediaFormat.KEY_REPEAT_PREVIOUS_FRAME_AFTER, 100_000L)
            // Screens refresh at 60 Hz or more; the desktop expects up to 30.
            if (Build.VERSION.SDK_INT >= 29) setFloat(MediaFormat.KEY_MAX_FPS_TO_ENCODER, fps.toFloat())
            // As little delay as the codec allows (docs/protocol.md §4.8, webcam
            // latency): realtime, one frame in flight, no B-frames.
            setInteger(MediaFormat.KEY_PRIORITY, 0)
            if (Build.VERSION.SDK_INT >= 29) setInteger(MediaFormat.KEY_MAX_B_FRAMES, 0)
            if (Build.VERSION.SDK_INT >= 30) {
                setInteger(MediaFormat.KEY_LATENCY, 1)
                setInteger(MediaFormat.KEY_LOW_LATENCY, 1)
            }
        }
        val profiles = buildList {
            if (Build.VERSION.SDK_INT >= 27) add(CodecProfileLevel.AVCProfileConstrainedBaseline)
            add(CodecProfileLevel.AVCProfileBaseline)
        }
        for ((i, profile) in profiles.withIndex()) {
            val name = if (profile == CodecProfileLevel.AVCProfileBaseline) "baseline" else "constrained baseline"
            try {
                codec.configure(format(profile), null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
                Logs.add("$label encoder: ${describe(codec)}, $width×$height, ${bitrate / 1000} kbit/s, $fps fps, $name")
                return
            } catch (e: Exception) {
                Logs.add("$label encoder: ${describe(codec)} refused $width×$height $name ($e)")
                if (i == profiles.lastIndex) throw e
                codec.reset()
            }
        }
    }

    /// The codec's name, and whether it's the phone's hardware.
    private fun describe(codec: MediaCodec): String {
        val name = runCatching { codec.name }.getOrDefault("?")
        if (Build.VERSION.SDK_INT < 29) return name
        return name + if (codec.codecInfo.isHardwareAccelerated) " (hardware)" else " (software)"
    }

    private fun drainLoop() {
        val info = MediaCodec.BufferInfo()
        var config = ByteArray(0)
        var waited = false
        try {
            while (running) {
                val index = codec.dequeueOutputBuffer(info, 10_000)
                if (frames == 0 && !waited && SystemClock.elapsedRealtime() - began > 3_000) {
                    waited = true
                    Logs.add("$label encoder: no frame after 3 s, nothing reaches its input")
                }
                if (index < 0) continue
                val buffer = codec.getOutputBuffer(index)
                val bytes = ByteArray(info.size)
                buffer?.position(info.offset)
                buffer?.get(bytes, 0, info.size)
                codec.releaseOutputBuffer(index, false)
                if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                    config = bytes
                    continue
                }
                val key = info.flags and MediaCodec.BUFFER_FLAG_KEY_FRAME != 0
                val frame = if (key && config.isNotEmpty() && !startsWithSps(bytes)) config + bytes else bytes
                // An access unit delimiter first: the computer can end each
                // frame on it, without waiting for the next one (§4.8).
                val out = if (frame.isEmpty() || startsWithAud(frame)) frame else AUD + frame
                if (out.isEmpty()) continue
                if (frames == 0) Logs.add("$label encoder: first frame after ${SystemClock.elapsedRealtime() - began} ms")
                frames++
                if (key) keyframes++
                sent += out.size
                if (!NativeSession.write(session, out)) {
                    Logs.add("$label encoder: the stream closed after $frames frames")
                    running = false
                    onEnded()
                }
            }
        } catch (e: Exception) {
            if (running) {
                Logs.add("$label encoder stopped after $frames frames: $e")
                running = false
                onEnded()
            }
        }
    }

    /// A new target bitrate, live (stream quality).
    fun setBitrate(bitsPerSecond: Int) {
        runCatching {
            codec.setParameters(android.os.Bundle().apply { putInt(MediaCodec.PARAMETER_KEY_VIDEO_BITRATE, bitsPerSecond) })
        }
    }

    /// A keyframe now (the picture changed completely: another camera).
    fun keyframe() {
        runCatching {
            codec.setParameters(android.os.Bundle().apply { putInt(MediaCodec.PARAMETER_KEY_REQUEST_SYNC_FRAME, 0) })
        }
    }

    fun stop() {
        running = false
        drain.join(500)
        Logs.add("$label encoder: done, $frames frames ($keyframes keyframes), ${sent / 1024} KB")
        runCatching { codec.stop() }
        runCatching { codec.release() }
        inputSurface.release()
    }

    companion object {
        /// Android's own software encoders, newest first: the fallback when the
        /// phone's encoder refuses.
        private val SOFTWARE = listOf("c2.android.avc.encoder", "OMX.google.h264.encoder")

        /// [want], or the largest size of the same shape [caps] allow: the width a
        /// multiple of 16, stepping down, the height even.
        fun fit(want: Pair<Int, Int>, caps: android.media.MediaCodecInfo.VideoCapabilities?): Pair<Int, Int> {
            val (w, h) = want
            if (caps == null || caps.isSizeSupported(w, h)) return want
            var width = w / 16 * 16
            while (width >= 16) {
                val height = ((width.toDouble() * h / w) / 2).roundToInt() * 2
                if (caps.isSizeSupported(width, height)) return width to height
                width -= 16
            }
            return want
        }

        /// What the phone's default H.264 encoder can do, for picking sizes.
        fun capabilities(): android.media.MediaCodecInfo.VideoCapabilities? = runCatching {
            val codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
            try {
                codec.codecInfo.getCapabilitiesForType(MediaFormat.MIMETYPE_VIDEO_AVC).videoCapabilities
            } finally {
                codec.release()
            }
        }.getOrNull()

        /// Whether the encoder already put SPS (NAL type 7) in front.
        private val AUD = byteArrayOf(0, 0, 0, 1, 0x09, 0xF0.toByte())

        private fun startsWithAud(b: ByteArray): Boolean {
            val at = when {
                b.size > 4 && b[0].toInt() == 0 && b[1].toInt() == 0 && b[2].toInt() == 0 && b[3].toInt() == 1 -> 4
                b.size > 3 && b[0].toInt() == 0 && b[1].toInt() == 0 && b[2].toInt() == 1 -> 3
                else -> return false
            }
            return b[at].toInt() and 0x1f == 9
        }

        private fun startsWithSps(b: ByteArray): Boolean {
            val start = when {
                b.size > 4 && b[0].toInt() == 0 && b[1].toInt() == 0 && b[2].toInt() == 0 && b[3].toInt() == 1 -> 4
                b.size > 3 && b[0].toInt() == 0 && b[1].toInt() == 0 && b[2].toInt() == 1 -> 3
                else -> return false
            }
            return b[start].toInt() and 0x1f == 7
        }
    }
}
