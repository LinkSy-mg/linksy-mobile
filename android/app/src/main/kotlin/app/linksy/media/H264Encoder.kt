package app.linksy.media

import android.media.MediaCodec
import android.media.MediaCodecInfo.CodecCapabilities
import android.media.MediaCodecInfo.CodecProfileLevel
import android.media.MediaFormat
import android.os.Build
import android.os.SystemClock
import android.view.Surface
import app.linksy.Logs

/// Hardware H.264 the way linksy-desktop decodes it (docs/protocol.md §4.8): Annex-B,
/// Constrained Baseline, a keyframe at least every 2 s, SPS/PPS before every
/// keyframe. Frames come in through [inputSurface]; each encoded unit goes to
/// the session. [onEnded] runs once if the session goes away. What it does goes
/// to the Logs page, under [label] ("Screen", "Webcam").
class H264Encoder(
    width: Int,
    height: Int,
    bitrate: Int,
    fps: Int,
    private val label: String,
    private val session: String,
    private val onEnded: () -> Unit,
) {
    private val codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
    val inputSurface: Surface
    @Volatile private var running = true
    private val drain: Thread

    // For the log: what came out, and since when.
    private val began = SystemClock.elapsedRealtime()
    private var frames = 0
    private var keyframes = 0
    private var sent = 0L

    init {
        configure(width, height, bitrate, fps)
        inputSurface = codec.createInputSurface()
        codec.start()
        drain = Thread(::drainLoop, "linksy-encoder").apply { start() }
    }

    private fun configure(width: Int, height: Int, bitrate: Int, fps: Int) {
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
                Logs.add("$label encoder: ${describe()}, $width×$height, ${bitrate / 1000} kbit/s, $fps fps, $name")
                return
            } catch (e: Exception) {
                Logs.add("$label encoder: ${describe()} refused $width×$height $name ($e)")
                if (i == profiles.lastIndex) throw e
                codec.reset()
            }
        }
    }

    /// The codec's name, and whether it's the phone's hardware.
    private fun describe(): String {
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
