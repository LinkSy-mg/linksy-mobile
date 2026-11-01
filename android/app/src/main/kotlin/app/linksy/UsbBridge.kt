package app.linksy

import android.content.Context
import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbManager
import android.util.Log

/// The USB cable to a computer (docs/protocol.md §4.11): the computer switched the
/// phone into accessory mode, and Linksy's own QUIC packets cross the cable.
/// Android's part stays here (permission, `openAccessory`); the framing is
/// linksy-core's `cable::phone_bridge` ([NativeCable]), which reads the
/// accessory 16 KB at a time (a smaller read drops the rest of a USB request)
/// and speaks version 2 (hello, keepalives, close) when the computer does. A
/// UDP socket on 127.0.0.1 stands in for the computer: the node dials it like
/// any address. The bridge ends by itself when the cable goes.
class UsbBridge private constructor(
    private val accessory: UsbAccessory,
    /// Where the node dials the computer through the cable.
    val port: Int,
) {
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

        /// Opens [accessory]; returns the bridge's port, or null. Without
        /// permission (no "open with" prompt was shown or answered, as on
        /// realme/ColorOS) it asks, and [ACTION_PERMISSION] comes back.
        fun open(context: Context, accessory: UsbAccessory): Int? {
            if (!isLinksy(accessory)) return null
            current?.let { if (it.accessory == accessory) return it.port }
            val manager = context.getSystemService(Context.USB_SERVICE) as UsbManager
            if (!manager.hasPermission(accessory)) {
                if (asking != accessory && refused != accessory) {
                    asking = accessory
                    Log.i("linksy", "usb cable: asking permission")
                    val intent = android.content.Intent(ACTION_PERMISSION).setPackage(context.packageName)
                    val flags = if (android.os.Build.VERSION.SDK_INT >= 31) android.app.PendingIntent.FLAG_MUTABLE else 0
                    manager.requestPermission(accessory, android.app.PendingIntent.getBroadcast(context, 0, intent, flags))
                }
                return null
            }
            asking = null
            val fd = runCatching { manager.openAccessory(accessory) }
                .onFailure { Log.w("linksy", "usb cable: open failed ($it)") }
                .getOrNull()
            if (fd == null) {
                Log.w("linksy", "usb cable: openAccessory gave nothing")
                return null
            }
            val port = runCatching { NativeCable.bridge(fd.detachFd(), accessory.version) }
                .onFailure { Log.w("linksy", "usb cable: bridge failed ($it)") }
                .getOrDefault(-1)
            if (port <= 0) return null
            Log.i("linksy", "usb cable: bridge on 127.0.0.1:$port (version ${accessory.version})")
            return UsbBridge(accessory, port).also { current = it }.port
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
            current?.let { if (it.accessory !in attached) current = null }
            val accessory = attached.firstOrNull(::isLinksy) ?: return null
            return open(context, accessory)
        }

        /// The cable came out.
        fun detached() {
            asking = null
            refused = null
            current = null
        }
    }
}
