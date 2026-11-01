package app.linksy

/// The Rust side of the USB cable (rust/src/cable.rs, linksy-core's
/// `cable::phone_bridge`).
object NativeCable {
    init {
        System.loadLibrary("linksy_bridge")
    }

    /// Hands [fd] (detached, now Rust's) to the bridge; its port, or -1.
    /// [version] is the accessory's version string: "2" and up turns on the
    /// framing's hello and keepalives.
    external fun bridge(fd: Int, version: String?): Int
}
