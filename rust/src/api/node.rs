//! `linksy_core::Node` for Dart. Values cross as JSON in the core's own serde
//! shapes (the same as the desktop IPC), so the Dart side parses one format
//! and this file stays thin. Errors cross as `kind` or `kind:message`, for
//! the app to word with the device's name.

use std::future::Future;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::sync::OnceLock;

use flutter_rust_bridge::frb;
use linksy_core::{Battery, CallState, Config, DeviceKind, Error, Fingerprint, MediaCommand, Node, SessionKind, Settings, Uuid};
use linksy_core::{Event, Link, TerminalOpen};
use tokio::runtime::Runtime;
use tokio::sync::broadcast::error::RecvError;

use crate::frb_generated::StreamSink;

/// The core spawns its tasks on tokio; it gets a runtime of its own.
pub(crate) fn rt() -> &'static Runtime {
    static RT: OnceLock<Runtime> = OnceLock::new();
    RT.get_or_init(|| {
        tokio::runtime::Builder::new_multi_thread()
            .worker_threads(2)
            .thread_name("linksy")
            .enable_all()
            .build()
            .expect("tokio runtime")
    })
}

async fn run<T: Send + 'static>(f: impl Future<Output = Result<T, Error>> + Send + 'static) -> Result<T, String> {
    rt().spawn(f).await.map_err(|e| format!("other:{e}"))?.map_err(kind)
}

fn kind(e: Error) -> String {
    match e {
        Error::Unreachable => "unreachable".into(),
        Error::Declined => "declined".into(),
        Error::Timeout => "timeout".into(),
        Error::NotPaired => "not_paired".into(),
        Error::Unsupported => "unsupported".into(),
        Error::NotFromAway => "not_from_away".into(),
        // A terminal turned down (§4.15): `refused:code:3`, `refused:locked:`.
        Error::Refused { reason, tries_left } => {
            format!("refused:{reason}:{}", tries_left.map(|t| t.to_string()).unwrap_or_default())
        }
        Error::Invalid(m) => format!("invalid:{m}"),
        Error::NotFound(m) => format!("invalid:{m}"),
        other => format!("other:{other}"),
    }
}

fn fingerprint(id: &str) -> Result<Fingerprint, String> {
    id.parse().map_err(|_| "invalid:That isn't a Linksy device id.".to_string())
}

fn json<T: serde::Serialize>(v: &T) -> String {
    serde_json::to_string(v).unwrap_or_default()
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    // That sets up logging at trace level: mDNS alone floods logcat.
    log::set_max_level(log::LevelFilter::Info);
    #[cfg(target_os = "android")]
    {
        use tracing_subscriber::filter::LevelFilter;
        use tracing_subscriber::prelude::*;
        let _ = tracing_subscriber::registry()
            .with(paranoid_android::layer("linksy").with_filter(LevelFilter::INFO))
            .try_init();
    }
}

#[frb(opaque)]
pub struct LinksyNode {
    node: Node,
}

/// Starts this phone's node. Identity, paired devices and settings live in
/// `data_dir` (app-private). Prefers the desktop's port 47200 and mDNS; falls
/// back to a free port, then to no discovery, rather than not starting.
/// The node this process runs, for code that isn't called from Dart (media
/// sessions reporting the camera's state).
static RUNNING: std::sync::Mutex<Option<Node>> = std::sync::Mutex::new(None);

pub(crate) fn running() -> Option<Node> {
    RUNNING.lock().unwrap().clone()
}

/// `features`: what this phone can do (docs/protocol.md §4.10). `away`: reach paired
/// computers over the internet through `relay` (§4.13).
pub async fn start_node(
    data_dir: String,
    download_dir: String,
    name: String,
    features: Vec<String>,
    away: bool,
    relay: Option<String>,
) -> Result<LinksyNode, String> {
    // Android may recreate the activity, which runs the app's main() again in
    // the same process: hand back the node that's already running instead of
    // starting a second one on another port.
    if let Some(node) = RUNNING.lock().unwrap().clone() {
        return Ok(LinksyNode { node });
    }
    let mut last = String::new();
    for (port, discovery) in [(47200, true), (0, true), (47200, false), (0, false)] {
        let mut config = Config::new(PathBuf::from(&data_dir), PathBuf::from(&download_dir), name.clone());
        config.kind = DeviceKind::Phone;
        config.port = port;
        config.discovery = discovery;
        config.features = features.clone();
        config.away = away;
        config.relay = relay.clone();
        match run(Node::start(config)).await {
            Ok(node) => {
                crate::sessions::collect(&node);
                crate::files::collect(&node);
                crate::heartbeats::run(&node);
                *RUNNING.lock().unwrap() = Some(node.clone());
                return Ok(LinksyNode { node });
            }
            Err(e) => {
                tracing::warn!(port, discovery, error = %e, "node didn't start, trying the next way");
                last = e;
            }
        }
    }
    Err(last)
}

impl LinksyNode {
    /// This device, as `DeviceInfo` JSON.
    #[frb(sync)]
    pub fn info_json(&self) -> String {
        json(&self.node.info())
    }

    /// Every known device, as a JSON list of `DeviceView`.
    #[frb(sync)]
    pub fn devices_json(&self) -> String {
        json(&self.node.devices())
    }

    #[frb(sync)]
    pub fn settings_json(&self) -> String {
        json(&self.node.settings())
    }

    /// The port this node listens on, for "pair by address" from elsewhere.
    #[frb(sync)]
    pub fn port(&self) -> u16 {
        self.node.local_addr().map(|a| a.port()).unwrap_or(0)
    }

    /// This phone's networks changed (Android's network callback): links that no
    /// longer answer close at once, devices that stay connected are dialed again,
    /// and iroh looks for its paths again (docs/protocol.md §4.13).
    pub fn network_changed(&self) {
        let _rt = rt().enter();
        self.node.network_changed();
    }

    /// Every core event as JSON (`{"type": "...", ...}`), until the app stops
    /// listening.
    pub fn events(&self, sink: StreamSink<String>) {
        let mut rx = self.node.subscribe();
        rt().spawn(async move {
            loop {
                match rx.recv().await {
                    Ok(event) => {
                        if sink.add(json(&event)).is_err() {
                            break;
                        }
                    }
                    Err(RecvError::Lagged(n)) => tracing::warn!(n, "app fell behind on events"),
                    Err(RecvError::Closed) => break,
                }
            }
        });
    }

    pub async fn update_settings(&self, settings_json: String) -> Result<(), String> {
        let settings: Settings = serde_json::from_str(&settings_json).map_err(|e| format!("other:{e}"))?;
        let node = self.node.clone();
        run(async move { node.update_settings(settings).await.map(|_| ()) }).await
    }

    pub async fn pair_device(&self, id: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.pair_device(id).await.map(|_| ()) }).await
    }

    /// `ip:port` or `[ipv6]:port`.
    pub async fn pair_address(&self, address: String) -> Result<(), String> {
        let addr: SocketAddr = address
            .trim()
            .parse()
            .map_err(|_| "invalid:That address doesn't look right. Use the form 192.168.1.20:47200.".to_string())?;
        let node = self.node.clone();
        run(async move { node.pair(addr).await.map(|_| ()) }).await
    }

    /// A scanned `linksy://pair?…` link.
    pub async fn pair_with_invite(&self, uri: String) -> Result<(), String> {
        let node = self.node.clone();
        run(async move { node.pair_with_invite(&uri).await.map(|_| ()) }).await
    }

    /// Answer a pairing or transfer request. False if it already expired.
    #[frb(sync)]
    pub fn respond(&self, request: String, accept: bool) -> bool {
        Uuid::parse_str(&request).is_ok_and(|id| self.node.respond(id, accept))
    }

    /// Turns down a session this phone can't do at all (the desktop then says
    /// "can't" rather than "didn't allow it"). False if it already expired.
    #[frb(sync)]
    pub fn decline_unsupported(&self, request: String) -> bool {
        Uuid::parse_str(&request).is_ok_and(|id| self.node.decline_unsupported(id))
    }

    /// Returns the transfer id.
    pub async fn send_files(&self, id: String, paths: Vec<String>) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        let paths = paths.into_iter().map(PathBuf::from).collect();
        run(async move { node.send_files(&id, paths).await.map(|t| t.to_string()) }).await
    }

    #[frb(sync)]
    pub fn cancel(&self, transfer: String) -> bool {
        Uuid::parse_str(&transfer).is_ok_and(|id| self.node.cancel(id))
    }

    pub async fn send_clipboard(&self, id: String, text: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.send_clipboard(&id, &text).await }).await
    }

    pub async fn notify(&self, id: String, title: String, body: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.notify(&id, &title, &body).await }).await
    }

    /// "Open on PC": asks a computer to open an `http(s)` link in its browser.
    pub async fn open_url(&self, id: String, url: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.open_url(&id, &url).await }).await
    }

    /// This phone's battery, `level` in percent.
    pub async fn send_battery(&self, id: String, level: u8, charging: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.send_battery(&id, Battery { level, charging }).await }).await
    }

    /// "Find my computer": makes it ring (`on`), or stops it.
    pub async fn ring(&self, id: String, on: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.ring(&id, on).await }).await
    }

    /// Touchpad, keyboard and presentation remote: asks the computer for an
    /// `input` session (its user allows it there). Returns the session id to
    /// write framed input messages to.
    pub async fn start_input(&self, id: String) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        let session = run(async move { node.request_session(&id, SessionKind::Input).await }).await?;
        let session_id = session.id.to_string();
        crate::sessions::run(session);
        Ok(session_id)
    }

    /// Watch a computer's screen (`control`: and use its mouse and keyboard).
    /// Its user picks the screen there (`choose`: again, not the one picked last
    /// time). Returns the session id; the video arrives on it like a second display's.
    pub async fn start_view(&self, id: String, control: bool, choose: bool) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let kind = if control { SessionKind::Control } else { SessionKind::Screen };
        let node = self.node.clone();
        let session = run(async move {
            if choose { node.request_session_choosing(&id, kind).await } else { node.request_session(&id, kind).await }
        })
        .await?;
        let session_id = session.id.to_string();
        crate::sessions::run(session);
        Ok(session_id)
    }

    /// Writes to a session (framed input messages). False once it has ended.
    pub async fn session_write(&self, session: String, bytes: Vec<u8>) -> bool {
        crate::sessions::write_async(&session, bytes).await
    }

    /// Ask the computer for its players (`media_state` events) while `on`.
    pub async fn watch_media(&self, id: String, on: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.watch_media(&id, on).await }).await
    }

    /// `command_json` in the core's shape: `{"action":"play_pause"}`.
    pub async fn media_command(&self, id: String, player: String, command_json: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let command: MediaCommand = serde_json::from_str(&command_json).map_err(|e| format!("other:{e}"))?;
        let node = self.node.clone();
        run(async move { node.media_command(&id, &player, command).await }).await
    }

    /// Ask the computer for its volume (`volume_state` events) while `on`.
    pub async fn watch_volume(&self, id: String, on: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.watch_volume(&id, on).await }).await
    }

    /// The computer's volume: `level` from 0 to 1, `muted`, or both.
    pub async fn set_volume(&self, id: String, level: Option<f64>, muted: Option<bool>) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.set_volume(&id, level, muted).await }).await
    }

    /// A step of a direct link (docs/protocol.md §4.17), as JSON:
    /// `{"type":"invite","address":…}`, `{"type":"connecting"}`, `{"type":"up","ip":…,"port":…}`
    /// or `{"type":"end","reason":…}`.
    pub async fn direct_send(&self, id: String, step: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let step: linksy_core::DirectStep = serde_json::from_str(&step).map_err(|e| format!("other:{e}"))?;
        let node = self.node.clone();
        run(async move { node.direct_send(&id, step).await }).await
    }

    /// The joiner's last step, phone to phone: this phone joined the other's group and it
    /// said where it is (`up`), so connect to `addr` (`ip:port`) over it.
    pub async fn direct_dial(&self, id: String, addr: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let addr: SocketAddr = addr.parse().map_err(|e| format!("other:{e}"))?;
        let node = self.node.clone();
        run(async move { node.direct_dial(&id, addr).await }).await
    }

    /// Set up a direct link with a device now and wait for it (testing; big transfers do
    /// it by themselves).
    pub async fn direct_link(&self, id: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.direct_link(&id).await }).await
    }

    /// `ringing`, `active` or `idle`.
    pub async fn send_call_state(&self, id: String, state: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let state: CallState = serde_json::from_value(state.into()).map_err(|e| format!("other:{e}"))?;
        let node = self.node.clone();
        run(async move { node.send_call_state(&id, state, None).await }).await
    }

    /// Photo auto-import: offers files into the computer's picture library.
    pub async fn import_files(&self, id: String, paths: Vec<String>) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        let paths = paths.into_iter().map(PathBuf::from).collect();
        run(async move { node.import_files(&id, paths).await.map(|t| t.to_string()) }).await
    }

    /// Lets paired computers browse the folder Android shares (or not).
    #[frb(sync)]
    pub fn share_files(&self, on: bool) {
        crate::files::set_sharing(on);
    }

    /// Accepts a `display` request with this phone's landscape screen size,
    /// so the computer makes the monitor in its shape (docs/protocol.md §4.8).
    #[frb(sync)]
    pub fn respond_display(&self, request: String, accept: bool, width: u32, height: u32) -> bool {
        let size = (width > 0 && height > 0).then_some((width, height));
        Uuid::parse_str(&request).is_ok_and(|id| self.node.respond_session(id, accept, size))
    }

    /// This phone's own picture (base64 JPEG/PNG ≤ 128 KiB) to a computer.
    pub async fn send_picture(&self, id: String, image: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.send_picture(&id, &image).await }).await
    }

    /// Ask a computer to send its clipboard text as it changes (or stop).
    pub async fn watch_clipboard(&self, id: String, on: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.watch_clipboard(&id, on).await }).await
    }

    /// Puts a file (≤ 10 MiB) on a computer's clipboard; returns the transfer id.
    pub async fn send_clipboard_file(&self, id: String, path: String) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.send_clipboard_file(&id, PathBuf::from(path)).await.map(|t| t.to_string()) }).await
    }

    /// Answers `locate` with a position.
    pub async fn send_location(&self, id: String, lat: f64, lon: f64, accuracy_m: Option<f64>, at_ms: u64) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.send_location(&id, lat, lon, accuracy_m, at_ms).await }).await
    }

    /// Answers `locate` with why not.
    pub async fn refuse_location(&self, id: String, reason: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.refuse_location(&id, &reason).await }).await
    }

    /// Everything allowed from away for this device (screens, camera, files…).
    #[frb(sync)]
    pub fn set_away_all(&self, id: String, on: bool) -> Result<(), String> {
        let id = fingerprint(&id)?;
        self.node.set_away_all(&id, on).map_err(kind)
    }

    /// Connect over the internet now (away from home).
    pub async fn connect_away(&self, id: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        run(async move { node.connect_away(&id).await.map(|_| ()) }).await
    }

    /// How a device is connected: `usb`, `lan`, `away`, or empty.
    #[frb(sync)]
    pub fn link(&self, id: String) -> String {
        let Ok(id) = fingerprint(&id) else { return String::new() };
        match self.node.link(&id) {
            Some(Link::Usb) => "usb".into(),
            Some(Link::Lan) => "lan".into(),
            Some(Link::Away) => "away".into(),
            None => String::new(),
        }
    }

    /// Dials a paired computer at `addr` (the USB cable's bridge, §4.11).
    pub async fn connect_address(&self, address: String) -> Result<(), String> {
        let addr: SocketAddr = address.parse().map_err(|_| "invalid:bad address".to_string())?;
        let node = self.node.clone();
        run(async move { node.connect(addr).await.map(|_| ()) }).await
    }

    /// While Add Device is open, also announce this phone to strangers, for at most
    /// 5 minutes (docs/protocol.md §4.16, pairing mode). The core's pairing mode is
    /// its invite, as on the computer.
    #[frb(sync)]
    pub fn pairing_mode(&self, on: bool) {
        if !on {
            return self.node.cancel_invite();
        }
        if let Err(e) = self.node.create_invite() {
            tracing::warn!("no pairing mode: {e}");
        }
    }

    #[frb(sync)]
    pub fn forget(&self, id: String) -> Result<(), String> {
        let id = fingerprint(&id)?;
        self.node.forget(&id).map(|_| ()).map_err(kind)
    }

    /// Opens a terminal on a computer with the code its user set there, or
    /// reattaches to `resume` (docs/protocol.md §4.15). JSON `{"session","terminal"}`:
    /// the session carries the output ([`terminal_output`]) and takes framed
    /// `term_*` messages ([`session_write`]).
    pub async fn open_terminal(&self, id: String, code: String, cols: u16, rows: u16, resume: Option<String>) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        let (session, terminal) =
            run(async move { node.request_terminal(&id, TerminalOpen { code, cols, rows, resume }).await }).await?;
        let session_id = session.id.to_string();
        crate::sessions::run(session);
        Ok(serde_json::json!({ "session": session_id, "terminal": terminal }).to_string())
    }

    /// A terminal's output, chunk by chunk, until its stream ends (the shell
    /// exited, it was closed or ended on the computer, or the link dropped).
    pub fn terminal_output(&self, session: String, sink: StreamSink<Vec<u8>>) {
        let Some(mut incoming) = crate::sessions::take_incoming(&session) else { return };
        rt().spawn(async move {
            while let Some(bytes) = incoming.recv().await {
                if sink.add(bytes).is_err() {
                    break;
                }
            }
        });
    }

    /// The terminals running on a computer for this phone, as JSON
    /// `[{"id","title","started_ms"}]`: asks, then waits for its answer.
    pub async fn terminals(&self, id: String) -> Result<String, String> {
        let id = fingerprint(&id)?;
        let node = self.node.clone();
        let list = run(async move {
            let mut events = node.subscribe();
            node.list_terminals(&id).await?;
            let answer = async {
                loop {
                    match events.recv().await {
                        Ok(Event::Terminals { from, list }) if from.id == id => return Ok(list),
                        Ok(_) | Err(RecvError::Lagged(_)) => continue,
                        Err(RecvError::Closed) => return Err(Error::Unreachable),
                    }
                }
            };
            tokio::time::timeout(std::time::Duration::from_secs(5), answer).await.map_err(|_| Error::Timeout)?
        })
        .await?;
        Ok(json(&list))
    }

    /// Stops sharing into a session (the Stop button, or the encoder ended).
    #[frb(sync)]
    pub fn end_session(&self, session: String) {
        crate::sessions::end(&session);
    }

    pub async fn shutdown(&self) -> Result<(), String> {
        let node = self.node.clone();
        run(async move {
            node.shutdown().await;
            Ok(())
        })
        .await
    }
}
