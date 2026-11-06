package app.linksy.media

import android.annotation.SuppressLint
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import androidx.annotation.RequiresApi
import app.linksy.Logs

/// What the phone's apps play, through the screen's own projection (docs/protocol.md
/// §4.8 `sound`): raw 16-bit little-endian PCM, 48 kHz stereo, 10 ms at a time, written
/// as read. Apps that don't allow capture are silent.
@RequiresApi(Build.VERSION_CODES.Q)
class SoundShare(
    private val projection: MediaProjection,
    private val session: String,
    private val onEnded: () -> Unit,
) : Share {
    @Volatile private var running = true
    private val thread = Thread(::run, "linksy-sound").apply { start() }

    @SuppressLint("MissingPermission") // Asked before the session is accepted.
    private fun run() {
        val record = runCatching { open() }.getOrElse {
            Logs.add("Sound: couldn't capture it ($it)")
            onEnded()
            return
        }
        val chunk = ByteArray(CHUNK)
        try {
            record.startRecording()
            while (running) {
                var filled = 0
                while (running && filled < CHUNK) {
                    val n = record.read(chunk, filled, CHUNK - filled)
                    if (n <= 0) break
                    filled += n
                }
                if (!running || filled < CHUNK) break
                if (!NativeSession.write(session, chunk.copyOf())) break
            }
        } catch (e: Exception) {
            Logs.add("Sound stopped: $e")
        } finally {
            runCatching { record.stop() }
            record.release()
        }
        if (running) onEnded()
    }

    @SuppressLint("MissingPermission")
    private fun open(): AudioRecord {
        val capture = AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .build()
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(RATE)
            .setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
            .build()
        val min = AudioRecord.getMinBufferSize(RATE, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT)
        return AudioRecord.Builder()
            .setAudioPlaybackCaptureConfig(capture)
            .setAudioFormat(format)
            // No more than 100 ms waiting, where Android lets it be that small.
            .setBufferSizeInBytes(maxOf(min, CHUNK * 10))
            .build()
    }

    override fun stop() {
        running = false
        thread.join(500)
    }

    private companion object {
        const val RATE = 48_000

        /// 10 ms of 16-bit stereo at 48 kHz.
        const val CHUNK = 1920
    }
}
