//! The USB cable's phone end (docs/protocol.md §4.11): Kotlin opens the accessory and
//! hands its file over; the core's bridge speaks the framing (version 2 when the
//! computer announces it) and gives back the local port the node dials.

#[cfg(target_os = "android")]
mod jni_api {
    use std::os::fd::FromRawFd;

    use jni::JNIEnv;
    use jni::objects::{JClass, JString};
    use jni::sys::jint;

    /// Takes `fd` (from `ParcelFileDescriptor.detachFd()`, now owned here); the bridge's
    /// port, or -1.
    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_NativeCable_bridge(mut env: JNIEnv, _this: JClass, fd: jint, version: JString) -> jint {
        let version: String = if version.is_null() { String::new() } else { env.get_string(&version).map(Into::into).unwrap_or_default() };
        // SAFETY: Kotlin detached the descriptor and never touches it again.
        let accessory = unsafe { std::fs::File::from_raw_fd(fd) };
        match linksy_core::cable::phone_bridge(accessory, &version) {
            Ok(port) => {
                tracing::info!(port, version = %version, "usb cable: bridge up");
                port as jint
            }
            Err(e) => {
                tracing::warn!(error = %e, "usb cable: no bridge");
                -1
            }
        }
    }
}
