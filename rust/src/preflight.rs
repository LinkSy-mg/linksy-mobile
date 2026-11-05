//! Preflights from other devices (docs/protocol.md §4.22): what only the app
//! knows (room counting the staging copy, Wi-Fi, installs, the apps asked
//! about) comes from Dart. With nobody listening, or no answer in time, the
//! core answers on its own.

use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};

use linksy_core::{AppState, DirectReady, Node, PreflightAnswer, PreflightCall};

use crate::api::node::rt;
use crate::frb_generated::StreamSink;

fn calls() -> &'static Mutex<HashMap<u64, PreflightCall>> {
    static CALLS: OnceLock<Mutex<HashMap<u64, PreflightCall>>> = OnceLock::new();
    CALLS.get_or_init(Default::default)
}

fn sink() -> &'static Mutex<Option<StreamSink<String>>> {
    static SINK: OnceLock<Mutex<Option<StreamSink<String>>>> = OnceLock::new();
    SINK.get_or_init(Default::default)
}

pub(crate) fn listen(new: StreamSink<String>) {
    *sink().lock().unwrap() = Some(new);
}

pub(crate) fn collect(node: &Node) {
    let Some(mut incoming) = node.incoming_preflight() else { return };
    rt().spawn(async move {
        static NEXT: AtomicU64 = AtomicU64::new(1);
        while let Some(call) = incoming.recv().await {
            let n = NEXT.fetch_add(1, Ordering::Relaxed);
            let message = serde_json::json!({
                "call": n,
                "from": call.from,
                "bytes": call.bytes,
                "files": call.files,
                "apps": call.apps,
            })
            .to_string();
            calls().lock().unwrap().insert(n, call);
            let told = sink().lock().unwrap().as_ref().is_some_and(|s| s.add(message).is_ok());
            // Nobody there: dropped, the core answers now.
            if !told {
                calls().lock().unwrap().remove(&n);
            }
        }
    });
}

#[derive(serde::Deserialize)]
struct Answer {
    #[serde(default)]
    free: Option<u64>,
    #[serde(default)]
    direct: Option<DirectReady>,
    #[serde(default)]
    can_install: Option<bool>,
    #[serde(default)]
    apps: Vec<AppState>,
}

pub(crate) fn answer(call: u64, json: &str) -> Result<(), String> {
    let answer: Answer = serde_json::from_str(json).map_err(|e| format!("invalid:{e}"))?;
    // Gone already means the core has answered.
    if let Some(call) = calls().lock().unwrap().remove(&call) {
        call.answer(PreflightAnswer {
            free: answer.free,
            direct: answer.direct,
            can_install: answer.can_install,
            apps: answer.apps,
        });
    }
    Ok(())
}
