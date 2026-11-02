package app.linksy

import android.content.Context
import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbManager
import android.os.ParcelFileDescriptor
import android.os.SystemClock
import android.system.Os
import android.system.OsConstants
import java.io.FileInputStream
import java.io.FileOutputStream

/// The USB cable to a computer (docs/protocol.md §4.11): the computer switched the
/// phone into accessory mode, and Linksy's own QUIC packets cross the cable.
/// Android's part stays here (permission, `openAccessory`, reading and writing
/// the accessory); the framing is linksy-core's `cable::phone_bridge`
/// ([NativeCable]), which speaks version 2 (hello, keepalives, close) when the
/// computer does. The two meet on a socket pair that keeps each write whole, so
/// a USB transfer is still one write. A UDP socket on 127.0.0.1 stands in for
/// the computer: the node dials it like any address.
///
/// Only this class reads the accessory, 16 KB at a time (a smaller read drops
/// the rest of a USB request). Closing it here also wakes a read still waiting,
/// so the accessory is let go and can be opened again: when the cable goes,
/// when the bridge closes (the computer said nothing for 5 s), or for another.
class UsbBridge private constructor(
    private val accessory: UsbAccessory,
    private val file: ParcelFileDescriptor,
    private val mine: ParcelFileDescriptor,
) {
    /// Where the node dials the computer through the cable.
    var port = -1
        private set

    private val opened = SystemClock.elapsedRealtime()
    @Volatile private var closed = false
    private val counts = Counts()

    companion object {
        /// The bridge for the cable plugged in now, if any.
        @Volatile var current: UsbBridge? = null
            private set

        fun isLinksy(accessory: UsbAccessory) =
            accessory.manufacturer == "Linksy" && accessory.model == "Linksy"

        /// Asked for and not answered yet: one dialog at a time.
        @Volatile private var asking: UsbAccessory? = null
        /// Refused: not asked again until it's plugged in again.
        @Volatile private var refused: UsbAccessory? = null

        const val ACTION_PERMISSION = "app.linksy.USB_PERMISSION"

        /// The accessory's reads, as linksy-core reads it.
        private const val READ = 16_384
        /// Reads and writes logged one by one after each opening; then a
        /// summary every few seconds.
        private const val DETAILED = 40
        private const val SUMMARY_MS = 5_000L

        /// Each step once on the Logs page, though the app checks every 1.5 s.
        @Volatile private var said: String? = null

        fun say(line: String) {
            if (line == said) return
            said = line
            Logs.add("USB cable: $line")
        }

        /// Opens [accessory]; returns the bridge's port, or null. Without
        /// permission (no "open with" prompt was shown or answered, as on
        /// realme/ColorOS) it asks, and [ACTION_PERMISSION] comes back.
        fun open(context: Context, accessory: UsbAccessory): Int? {
            if (!isLinksy(accessory)) return null
            current?.let {
                if (it.accessory == accessory) return it.port
                it.close("another accessory")
            }
            val manager = context.getSystemService(Context.USB_SERVICE) as UsbManager
            if (!manager.hasPermission(accessory)) {
                if (asking != accessory && refused != accessory) {
                    asking = accessory
                    say("asking permission")
                    val intent = android.content.Intent(ACTION_PERMISSION).setPackage(context.packageName)
                    val flags = if (android.os.Build.VERSION.SDK_INT >= 31) android.app.PendingIntent.FLAG_MUTABLE else 0
                    manager.requestPermission(accessory, android.app.PendingIntent.getBroadcast(context, 0, intent, flags))
                }
                return null
            }
            asking = null
            val file = runCatching { manager.openAccessory(accessory) }
                .onFailure { say("open failed ($it)") }
                .getOrNull()
            if (file == null) {
                say("Android didn't open it")
                return null
            }
            val pair = runCatching { ParcelFileDescriptor.createReliableSocketPair() }
                .onFailure { say("no socket pair ($it)") }
                .getOrNull()
            if (pair == null) {
                file.close()
                return null
            }
            val (mine, theirs) = pair
            // Room for a whole batch of packets in one write.
            for (end in pair) runCatching {
                Os.setsockoptInt(end.fileDescriptor, OsConstants.SOL_SOCKET, OsConstants.SO_SNDBUF, 1 shl 20)
            }
            val bridge = UsbBridge(accessory, file, mine)
            val port = runCatching { NativeCable.bridge(theirs.detachFd(), accessory.version) }
                .onFailure { say("bridge failed ($it)") }
                .getOrDefault(-1)
            if (port <= 0) {
                say("no bridge")
                bridge.close(null)
                return null
            }
            bridge.port = port
            say("bridge on 127.0.0.1:$port (version ${accessory.version})")
            current = bridge
            bridge.start()
            return port
        }

        /// The permission dialog was answered.
        fun answered(granted: Boolean) {
            if (!granted) refused = asking
            asking = null
        }

        /// An accessory already attached (the app opened by other means, or
        /// Android never sent the intent). Also notices a cable that went
        /// without a detach broadcast (the app wasn't listening).
        fun openAttached(context: Context): Int? {
            val manager = context.getSystemService(Context.USB_SERVICE) as UsbManager
            val attached = manager.accessoryList.orEmpty()
            current?.let { if (it.accessory !in attached) it.close("no longer attached") }
            val accessory = attached.firstOrNull(::isLinksy) ?: return null
            return open(context, accessory)
        }

        /// The cable came out.
        fun detached() {
            say("unplugged")
            asking = null
            refused = null
            current?.close(null)
        }
    }

    private fun start() {
        Thread(::fromComputer, "linksy-usb-in").start()
        Thread(::toComputer, "linksy-usb-out").start()
    }

    /// The computer's transfers, each handed to the bridge whole.
    private fun fromComputer() {
        val buf = ByteArray(READ)
        val reads = FileInputStream(file.fileDescriptor)
        val bridge = FileOutputStream(mine.fileDescriptor)
        val why = try {
            while (!closed) {
                val n = reads.read(buf, 0, READ)
                if (n < 0) break
                counts.heard(n)
                if (counts.reads <= DETAILED) log("read #${counts.reads}: $n bytes, ${frames(buf, n)}")
                if (n > 0) bridge.write(buf, 0, n)
                summary()
            }
            "the accessory ended"
        } catch (e: java.io.IOException) {
            "reading stopped ($e)"
        }
        close(why)
    }

    /// The bridge's writes, each one USB transfer to the computer.
    private fun toComputer() {
        val buf = ByteArray(1 shl 17)
        val bridge = FileInputStream(mine.fileDescriptor)
        val writes = FileOutputStream(file.fileDescriptor)
        val why = try {
            var end: String? = null
            while (!closed && end == null) {
                val n = bridge.read(buf)
                if (n < 0) break
                val t = SystemClock.elapsedRealtime()
                writes.write(buf, 0, n)
                counts.sent(n)
                val took = SystemClock.elapsedRealtime() - t
                if (counts.writes <= DETAILED) log("write #${counts.writes}: $n bytes in $took ms, ${frames(buf, n)}")
                // Its last word: it heard nothing from the computer for 5 s.
                if (n == 5 && buf[2].toInt() == 4) end = "the bridge closed (nothing from the computer)"
                summary()
            }
            end ?: "the bridge ended"
        } catch (e: java.io.IOException) {
            "writing stopped ($e)"
        }
        close(why)
    }

    /// Stops both ways and lets the accessory go; [why] goes to the Logs page.
    fun close(why: String?) {
        synchronized(this) {
            if (closed) return
            closed = true
        }
        if (current === this) current = null
        if (why != null) log("$why after ${counts.describe()}")
        // Also wakes a read still waiting on either.
        runCatching { file.close() }
        runCatching { mine.close() }
    }

    private fun log(line: String) =
        Logs.add("USB cable +${SystemClock.elapsedRealtime() - opened} ms: $line")

    private fun summary() {
        val now = SystemClock.elapsedRealtime()
        if (counts.reads <= DETAILED && counts.writes <= DETAILED) return
        if (now - counts.summed < SUMMARY_MS) return
        counts.summed = now
        log(counts.describe())
    }

    private class Counts {
        @Volatile var reads = 0
        @Volatile var writes = 0
        @Volatile var bytesIn = 0L
        @Volatile var bytesOut = 0L
        @Volatile var summed = 0L

        @Synchronized fun heard(n: Int) {
            reads++
            bytesIn += n
        }

        @Synchronized fun sent(n: Int) {
            writes++
            bytesOut += n
        }

        fun describe() = "$reads reads ($bytesIn bytes), $writes writes ($bytesOut bytes)"
    }

    /// What a transfer holds, for the log: linksy-core's frames (a 2-byte
    /// length and a packet, or 0, a kind and a payload), as far as they're whole.
    private fun frames(b: ByteArray, n: Int): String {
        fun u16(i: Int) = ((b[i].toInt() and 0xff) shl 8) or (b[i + 1].toInt() and 0xff)
        val out = mutableListOf<String>()
        var i = 0
        while (i + 2 <= n && out.size < 8) {
            val len = u16(i)
            if (len > 0) {
                out += if (i + 2 + len <= n) "data $len" else "data $len (continues)"
                i += 2 + len
                continue
            }
            if (i + 5 > n) break
            val size = u16(i + 3)
            out += when (b[i + 2].toInt()) {
                1 -> "hello v${if (size > 0 && i + 5 < n) b[i + 5] else '?'}"
                2 -> "ping"
                3 -> "pong"
                4 -> "close"
                5 -> "pad"
                else -> "kind ${b[i + 2]}"
            }
            i += 5 + size
        }
        if (i < n && out.size == 8) out += "…"
        else if (i < n) out += "${n - i} bytes left"
        return out.joinToString().ifEmpty { "nothing" }
    }
}
