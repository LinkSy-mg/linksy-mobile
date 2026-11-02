package app.linksy.files

/// The Rust side of the gallery (rust/src/gallery.rs): requests from a
/// computer's Gallery, pulled one at a time.
object NativeGallery {
    init {
        System.loadLibrary("linksy_bridge")
    }

    /// The next request as JSON, blocking; null when the node is gone.
    external fun next(): String?

    /// The answer: `{"type":"gallery_items",…}` and so on, plus a thumbnail's bytes.
    external fun reply(id: Long, json: String, data: ByteArray?)

    /// Sends [paths] to the computer [to] as the transfer it chose.
    external fun send(to: String, transfer: String, paths: Array<String>)

    /// Whether requests reach [GalleryServer] at all (photo access).
    external fun sharing(on: Boolean)

    /// The photos changed; the computers hear it, at most every 2 s.
    external fun changed()
}
