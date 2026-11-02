//! Showing this phone's photos to a computer (docs/protocol.md §4.18). Android's
//! side (`app.linksy.files.GalleryServer`) answers through JNI, pulling one request
//! at a time as files do. Without photo access, requests are turned down here.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};
use std::time::{Duration, Instant};

use linksy_core::gallery::GalleryCall;
use linksy_core::{DeviceKind, GalleryAlbum, GalleryItem, Node, Uuid};
use tokio::sync::mpsc;

use crate::api::node::{rt, running};

static SHARING: AtomicBool = AtomicBool::new(false);

/// At most this often, the computers hear the photos changed.
const CHANGED_EVERY: Duration = Duration::from_secs(2);

struct Queue {
    tx: mpsc::UnboundedSender<u64>,
    rx: Mutex<mpsc::UnboundedReceiver<u64>>,
}

fn queue() -> &'static Queue {
    static Q: OnceLock<Queue> = OnceLock::new();
    Q.get_or_init(|| {
        let (tx, rx) = mpsc::unbounded_channel();
        Queue { tx, rx: Mutex::new(rx) }
    })
}

/// Requests waiting for Android's answer, by number.
fn calls() -> &'static Mutex<HashMap<u64, GalleryCall>> {
    static MAP: OnceLock<Mutex<HashMap<u64, GalleryCall>>> = OnceLock::new();
    MAP.get_or_init(Default::default)
}

/// Whether Linksy may read the phone's photos (Android's permission).
pub(crate) fn set_sharing(on: bool) {
    SHARING.store(on, Ordering::SeqCst);
}

/// Takes every gallery request this node gets, for its lifetime.
pub(crate) fn collect(node: &Node) {
    let Some(mut incoming) = node.incoming_gallery() else { return };
    rt().spawn(async move {
        static NEXT: AtomicU64 = AtomicU64::new(1);
        while let Some(call) = incoming.recv().await {
            if !SHARING.load(Ordering::SeqCst) {
                let _ = call.error("This phone doesn't share its photos. Allow Linksy to see them on the phone.").await;
                continue;
            }
            let n = NEXT.fetch_add(1, Ordering::Relaxed);
            calls().lock().unwrap().insert(n, call);
            let _ = queue().tx.send(n);
        }
    });
}

/// The next request as JSON (`{"call":n,"from":"…","from_id":"…","op":"items",…}`;
/// not `id`, which a thumbnail's request has already), blocking until there is one.
pub(crate) fn next() -> Option<String> {
    loop {
        let n = queue().rx.lock().unwrap().blocking_recv()?;
        let map = calls().lock().unwrap();
        let Some(call) = map.get(&n) else { continue };
        let mut j = serde_json::to_value(&call.request).ok()?;
        j["call"] = n.into();
        j["from"] = call.from.name.clone().into();
        j["from_id"] = call.from.id.to_string().into();
        return Some(j.to_string());
    }
}

/// What Android answers (JSON, the core's `GalleryReply` shape), then a thumbnail's
/// bytes.
pub(crate) fn reply(n: u64, json: &str, data: Vec<u8>) {
    let Some(call) = calls().lock().unwrap().remove(&n) else { return };
    let value: serde_json::Value = serde_json::from_str(json).unwrap_or_default();
    rt().spawn(async move {
        let result = match value["type"].as_str() {
            Some("gallery_albums") => {
                let albums: Vec<GalleryAlbum> = serde_json::from_value(value["albums"].clone()).unwrap_or_default();
                call.albums(albums).await
            }
            Some("gallery_items") => {
                let items: Vec<GalleryItem> = serde_json::from_value(value["items"].clone()).unwrap_or_default();
                call.items(items, value["more"].as_bool().unwrap_or(false)).await
            }
            Some("gallery_data") => call.thumb(&data).await,
            Some("gallery_ok") => call.ok().await,
            _ => call.error(value["message"].as_str().unwrap_or("That didn't work on the phone.")).await,
        };
        if let Err(e) = result {
            tracing::debug!(error = %e, "gallery answer didn't go out");
        }
    });
}

/// Sends the photos a computer asked for, as the transfer it chose.
pub(crate) fn send(to: &str, transfer: &str, paths: Vec<String>) {
    let (Some(node), Ok(to), Ok(transfer)) = (running(), to.parse(), Uuid::parse_str(transfer)) else { return };
    let paths = paths.into_iter().map(PathBuf::from).collect();
    rt().spawn(async move {
        if let Err(e) = node.send_gallery(&to, paths, transfer).await {
            tracing::warn!(error = %e, "photos a computer asked for didn't go");
        }
    });
}

/// The phone's photos changed: the connected computers hear it, at most every two
/// seconds, the last change never lost.
pub(crate) fn changed() {
    static LAST: Mutex<Option<Instant>> = Mutex::new(None);
    static WAITING: AtomicBool = AtomicBool::new(false);
    if !SHARING.load(Ordering::SeqCst) || WAITING.swap(true, Ordering::SeqCst) {
        return;
    }
    let wait = LAST.lock().unwrap().map_or(Duration::ZERO, |at| CHANGED_EVERY.saturating_sub(at.elapsed()));
    rt().spawn(async move {
        tokio::time::sleep(wait).await;
        WAITING.store(false, Ordering::SeqCst);
        *LAST.lock().unwrap() = Some(Instant::now());
        let Some(node) = running() else { return };
        for v in node.devices() {
            if v.trusted && v.connected && v.device.kind != DeviceKind::Phone && v.device.kind != DeviceKind::Tablet {
                let _ = node.gallery_changed(&v.device.id).await;
            }
        }
    });
}

#[cfg(target_os = "android")]
mod jni_api {
    use jni::JNIEnv;
    use jni::objects::{JByteArray, JClass, JObjectArray, JString};
    use jni::sys::{jboolean, jlong, jstring};

    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_files_NativeGallery_next(env: JNIEnv, _this: JClass) -> jstring {
        match super::next() {
            Some(s) => env.new_string(s).map(|s| s.into_raw()).unwrap_or(std::ptr::null_mut()),
            None => std::ptr::null_mut(),
        }
    }

    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_files_NativeGallery_reply(
        mut env: JNIEnv,
        _this: JClass,
        id: jlong,
        json: JString,
        data: JByteArray,
    ) {
        let json: String = env.get_string(&json).map(Into::into).unwrap_or_default();
        let data = if data.is_null() { Vec::new() } else { env.convert_byte_array(&data).unwrap_or_default() };
        super::reply(id as u64, &json, data);
    }

    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_files_NativeGallery_send(
        mut env: JNIEnv,
        _this: JClass,
        to: JString,
        transfer: JString,
        paths: JObjectArray,
    ) {
        let to: String = env.get_string(&to).map(Into::into).unwrap_or_default();
        let transfer: String = env.get_string(&transfer).map(Into::into).unwrap_or_default();
        let count = env.get_array_length(&paths).unwrap_or(0);
        let mut list = Vec::new();
        for i in 0..count {
            let Ok(item) = env.get_object_array_element(&paths, i) else { continue };
            let path: String = env.get_string(&JString::from(item)).map(Into::into).unwrap_or_default();
            list.push(path);
        }
        super::send(&to, &transfer, list);
    }

    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_files_NativeGallery_sharing(_env: JNIEnv, _this: JClass, on: jboolean) {
        super::set_sharing(on != 0);
    }

    #[unsafe(no_mangle)]
    pub extern "system" fn Java_app_linksy_files_NativeGallery_changed(_env: JNIEnv, _this: JClass) {
        super::changed();
    }
}
