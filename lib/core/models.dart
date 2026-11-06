/// Plain data shapes shared by the UI and the node backend. They mirror the
/// structs in `linksy_core` (see `docs/protocol.md` §5 in linksy-desktop) so the Rust
/// bridge can map onto them one to one.
library;

import 'dart:typed_data';

import '../ui/l10n.dart';

enum DeviceKind {
  desktop,
  laptop,
  phone,
  tablet;

  static DeviceKind parse(String value) => DeviceKind.values.firstWhere(
    (k) => k.name == value,
    orElse: () => DeviceKind.desktop,
  );
}

class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.kind,
    required this.os,
    this.features = const [],
  });

  /// SHA-256 of the device certificate, 64 lowercase hex chars.
  final String id;
  final String name;
  final DeviceKind kind;

  /// `linux`, `android`, `macos`, `windows`, …
  final String os;

  /// What it can do for others (docs/protocol.md §4.10). Empty: it didn't say (an
  /// older version), so assume what it always could.
  final List<String> features;

  /// Whether it says it can do [feature]; true when it says nothing.
  bool can(String feature) => features.isEmpty || features.contains(feature);

  /// First 4 bytes of the id, `XXXX-XXXX`.
  String get shortId => shortDeviceId(id);

  /// "Linux laptop", "Android phone".
  String get description => tr.modelDescription(osLabel(os), switch (kind) {
    DeviceKind.desktop => tr.modelKindDesktop,
    DeviceKind.laptop => tr.modelKindLaptop,
    DeviceKind.phone => tr.modelKindPhone,
    DeviceKind.tablet => tr.modelKindTablet,
  });

  DeviceInfo copyWith({String? name}) => DeviceInfo(
    id: id,
    name: name ?? this.name,
    kind: kind,
    os: os,
    features: features,
  );
}

String shortDeviceId(String id) {
  if (id.length < 8) return id.toUpperCase();
  final head = id.substring(0, 8).toUpperCase();
  return '${head.substring(0, 4)}-${head.substring(4)}';
}

String osLabel(String os) => switch (os) {
  'linux' => 'Linux',
  'android' => 'Android',
  'macos' => 'macOS',
  'windows' => 'Windows',
  'ios' => 'iOS',
  _ => os.isEmpty ? tr.modelOsUnknown : os[0].toUpperCase() + os.substring(1),
};

enum Presence { connected, nearby, notNearby }

class DeviceView {
  const DeviceView({
    required this.device,
    required this.trusted,
    required this.connected,
    required this.nearby,
    this.battery,
    this.usb = false,
    this.away = false,
    this.awayAll = false,
    this.awayUntil,
    this.direct = false,
  });

  final DeviceInfo device;
  final bool trusted;
  final bool connected;
  final bool nearby;

  /// What the device last said about its battery, if it has one.
  final Battery? battery;

  /// Connected through the USB cable (docs/protocol.md §4.11).
  final bool usb;

  /// Connected away from home, over the internet (§4.13).
  final bool away;

  /// Everything is allowed from away for it, not only the small things.
  final bool awayAll;

  /// Until when it may connect from away: a week after it was last on the
  /// same network or cable.
  final DateTime? awayUntil;

  /// A direct link (Wi-Fi Direct, §4.17) to it is up.
  final bool direct;

  Presence get presence => connected
      ? Presence.connected
      : nearby
      ? Presence.nearby
      : Presence.notNearby;
}

/// A device's battery (docs/protocol.md §4.5, `battery`).
class Battery {
  const Battery({required this.level, required this.charging});

  /// Percent, 0–100.
  final int level;
  final bool charging;

  @override
  bool operator ==(Object other) =>
      other is Battery && other.level == level && other.charging == charging;

  @override
  int get hashCode => Object.hash(level, charging);
}

class NodeSettings {
  const NodeSettings({
    required this.name,
    required this.downloadDir,
    required this.stayConnected,
    required this.autoAccept,
    this.away = true,
    this.relay,
  });

  final String name;
  final String downloadDir;
  final bool stayConnected;
  final bool autoAccept;

  /// Reach paired computers away from home, over the internet (§4.13).
  final bool away;

  /// A relay the user hosts (`https://relay.example.com`) instead of the one
  /// the service lists (§4.12). Null: Linksy's own.
  final String? relay;

  static const _keep = Object();

  /// [relay] may be set to null to go back to Linksy's own relay.
  NodeSettings copyWith({
    String? name,
    String? downloadDir,
    bool? stayConnected,
    bool? autoAccept,
    bool? away,
    Object? relay = _keep,
  }) => NodeSettings(
    name: name ?? this.name,
    downloadDir: downloadDir ?? this.downloadDir,
    stayConnected: stayConnected ?? this.stayConnected,
    autoAccept: autoAccept ?? this.autoAccept,
    away: away ?? this.away,
    relay: identical(relay, _keep) ? this.relay : relay as String?,
  );
}

class OfferedFile {
  const OfferedFile({required this.path, required this.size});

  /// Relative, `/`-separated.
  final String path;
  final int size;

  String get name => path.split('/').last;
}

/// Events from the node, same names as the desktop IPC.
sealed class LinksyEvent {
  const LinksyEvent();
}

class DeviceFound extends LinksyEvent {
  const DeviceFound(this.device);
  final DeviceInfo device;
}

class DeviceLost extends LinksyEvent {
  const DeviceLost(this.id);
  final String id;
}

class DeviceUpdated extends LinksyEvent {
  const DeviceUpdated(this.device);
  final DeviceInfo device;
}

class Connected extends LinksyEvent {
  const Connected(this.id);
  final String id;
}

class Disconnected extends LinksyEvent {
  const Disconnected(this.id);
  final String id;
}

class PairingRequest extends LinksyEvent {
  const PairingRequest({
    required this.request,
    required this.device,
    required this.code,
    required this.incoming,
    this.older = false,
  });

  final String request;
  final DeviceInfo device;

  /// Six digits, from the TLS exporter (§4.3).
  final String code;
  final bool incoming;

  /// The other device predates commit and reveal (§4.3, §4.4): pairing works,
  /// but updating it makes the code even safer.
  final bool older;
}

class Paired extends LinksyEvent {
  const Paired(this.device);
  final DeviceInfo device;
}

class PairingFailed extends LinksyEvent {
  const PairingFailed({this.device, required this.reason});
  final DeviceInfo? device;
  final String reason;
}

class TransferRequest extends LinksyEvent {
  const TransferRequest({
    required this.transfer,
    required this.from,
    required this.files,
    required this.total,
    this.apps = const [],
  });

  final String transfer;
  final DeviceInfo from;
  final List<OfferedFile> files;
  final int total;

  /// The apps among [files], when they say what they are (§4.22).
  final List<AppInfo> apps;

  /// What isn't an app's APK.
  Iterable<OfferedFile> get plainFiles =>
      files.where((f) => !apps.any((a) => f.path.startsWith('${a.dir}/')));
}

/// The way a transfer goes (§4.22), on both ends.
class TransferRouted extends LinksyEvent {
  const TransferRouted({
    required this.transfer,
    required this.route,
    this.settingUpDirect = false,
    this.whyNotDirect,
  });

  final String transfer;

  /// `usb`, `direct`, `lan` or `away`.
  final String route;

  /// It's waiting for a direct link, up to 45 s.
  final bool settingUpDirect;

  /// A link was tried and failed, and it goes the usual way.
  final String? whyNotDirect;
}

/// Where a device says it is, or why not (§4.14).
class LocationReceived extends LinksyEvent {
  const LocationReceived({
    required this.from,
    this.lat,
    this.lon,
    this.refused,
  });

  final DeviceInfo from;
  final double? lat;
  final double? lon;
  final String? refused;
}

/// How installing an app went, for the user to read.
class AppInstalled extends LinksyEvent {
  const AppInstalled({
    required this.label,
    required this.from,
    required this.status,
  });

  final String label;
  final String from;

  /// `installed`, `cancelled`, `mismatch`, `other_signer` or `failed:…`.
  final String status;
}

/// Apps arrived, after their transfer's [TransferComplete]: to install.
class AppsReceived extends LinksyEvent {
  const AppsReceived({
    required this.transfer,
    required this.from,
    required this.apps,
  });

  final String transfer;
  final DeviceInfo from;
  final List<ReceivedApp> apps;
}

class TransferStarted extends LinksyEvent {
  const TransferStarted(
    this.transfer, {
    this.peer,
    this.incoming = false,
    this.files = const [],
    this.total = 0,
    this.apps = const [],
  });

  /// The apps among [files].
  final List<AppInfo> apps;

  final String transfer;

  /// Who it's with, so a transfer the app didn't start (auto-accepted
  /// incoming files) still lands in that device's timeline.
  final DeviceInfo? peer;
  final bool incoming;
  final List<OfferedFile> files;
  final int total;
}

class TransferProgress extends LinksyEvent {
  const TransferProgress({
    required this.transfer,
    required this.bytes,
    required this.total,
  });

  final String transfer;
  final int bytes;
  final int total;
}

class TransferComplete extends LinksyEvent {
  const TransferComplete({required this.transfer, required this.saved});
  final String transfer;

  /// Final paths of received files; empty for outgoing transfers.
  final List<String> saved;
}

class TransferFailed extends LinksyEvent {
  const TransferFailed({required this.transfer, required this.reason});
  final String transfer;
  final String reason;
}

class SettingsChanged extends LinksyEvent {
  const SettingsChanged(this.settings);
  final NodeSettings settings;
}

class NotificationReceived extends LinksyEvent {
  const NotificationReceived({
    required this.from,
    required this.title,
    required this.body,
  });

  final DeviceInfo from;
  final String title;
  final String body;
}

class ClipboardReceived extends LinksyEvent {
  const ClipboardReceived({required this.from, required this.text});
  final DeviceInfo from;
  final String text;
}

/// What a media session shares (docs/protocol.md §4.8).
enum SessionKind {
  /// The receiver shares its screen with the requester.
  screen,

  /// Like [screen], and the requester also controls it.
  control,

  /// The requester shares a virtual monitor the receiver shows full screen.
  display,

  /// The receiver shares its camera, used as a webcam.
  camera,

  /// This phone drives the computer's pointer and keyboard (touchpad,
  /// keyboard, presentation remote); no video.
  input,

  /// The receiver shares its microphone: raw 48 kHz mono PCM.
  microphone,

  /// The receiver shares what its apps play, with its screen: raw 48 kHz
  /// stereo PCM.
  sound;

  static SessionKind? parse(String value) =>
      SessionKind.values.where((k) => k.name == value).firstOrNull;
}

/// Ask the user whether [from] may start a session ([request] is its id).
class SessionRequest extends LinksyEvent {
  const SessionRequest({
    required this.request,
    required this.from,
    required this.kind,
  });

  final String request;
  final DeviceInfo from;
  final SessionKind kind;
}

class SessionStarted extends LinksyEvent {
  const SessionStarted({
    required this.session,
    required this.peer,
    required this.kind,
    required this.sharing,
  });

  final String session;
  final DeviceInfo peer;
  final SessionKind kind;

  /// This phone is the one sharing (its screen or camera).
  final bool sharing;
}

class SessionEnded extends LinksyEvent {
  const SessionEnded(this.session);
  final String session;
}

/// A paired device asks this phone to open a web link (`http`/`https`).
class OpenUrlReceived extends LinksyEvent {
  const OpenUrlReceived({required this.from, required this.url});
  final DeviceInfo from;
  final String url;
}

/// A paired device reported its battery.
class BatteryReported extends LinksyEvent {
  const BatteryReported({required this.from, required this.battery});
  final DeviceInfo from;
  final Battery battery;
}

/// A paired device wants this phone to ring so it can be found ([on]), or
/// to stop.
class RingRequested extends LinksyEvent {
  const RingRequested({required this.from, required this.on});
  final DeviceInfo from;
  final bool on;
}

/// One of a device's media players (docs/protocol.md §4.5, `media_state`).
class MediaPlayer {
  const MediaPlayer({
    required this.id,
    required this.app,
    this.title = '',
    this.artist = '',
    this.album = '',
    required this.playing,
    this.positionMs,
    this.lengthMs,
    this.canNext = false,
    this.canPrevious = false,
    this.canSeek = false,
    this.art,
  });

  final String id;
  final String app;
  final String title;
  final String artist;
  final String album;
  final bool playing;
  final int? positionMs;
  final int? lengthMs;
  final bool canNext;
  final bool canPrevious;
  final bool canSeek;

  /// Cover art, base64 JPEG or PNG.
  final String? art;
}

/// Everything a device plays; a later [seq] replaces an earlier one.
class MediaState {
  const MediaState({required this.seq, required this.players});
  final int seq;
  final List<MediaPlayer> players;
}

/// A computer's players changed (while this phone watches them).
class MediaStateReceived extends LinksyEvent {
  const MediaStateReceived({required this.from, required this.state});
  final DeviceInfo from;
  final MediaState state;
}

/// A computer's system volume: [level] from 0 to 1, and [muted].
class VolumeState {
  const VolumeState({
    required this.seq,
    required this.level,
    required this.muted,
  });
  final int seq;
  final double level;
  final bool muted;
}

/// A computer's volume changed (while this phone watches it).
class VolumeStateReceived extends LinksyEvent {
  const VolumeStateReceived({required this.from, required this.state});
  final DeviceInfo from;
  final VolumeState state;
}

/// A computer wants (or no longer wants) a heartbeat every [everyS] seconds,
/// to lock itself when this phone leaves.
class HeartbeatWatchChanged extends LinksyEvent {
  const HeartbeatWatchChanged({
    required this.from,
    required this.on,
    required this.everyS,
  });
  final DeviceInfo from;
  final bool on;
  final int everyS;
}

/// A big transfer wants a direct link (docs/protocol.md §4.17) with [id],
/// which this phone hosts: its Wi-Fi Direct part starts. [group] (`ssid`,
/// `passphrase`) when [id] is another phone: make a group with it.
class DirectWanted extends LinksyEvent {
  const DirectWanted(this.id, {this.group});
  final String id;
  final Map<String, Object?>? group;
}

/// A step of a direct link from the other device (`listening`, `invite`,
/// `up`...), as its JSON.
class DirectStepReceived extends LinksyEvent {
  const DirectStepReceived({required this.from, required this.step});
  final DeviceInfo from;
  final Map<String, Object?> step;
}

/// The direct link with [id] is up: transfers go over it.
class DirectLinked extends LinksyEvent {
  const DirectLinked(this.id);
  final String id;
}

/// The direct link with [id] ended or didn't come up ([reason]).
class DirectEnded extends LinksyEvent {
  const DirectEnded({required this.id, this.reason});
  final String id;
  final String? reason;
}

/// A computer sent its picture (base64 JPEG or PNG) to show for it.
class PictureReceived extends LinksyEvent {
  const PictureReceived({required this.from, required this.image});
  final DeviceInfo from;
  final String image;
}

/// A computer scrolls back in a conversation (§4.5, `inbox_history`): the
/// messages this phone kept of it, older than [beforeMs], at most [limit].
class InboxHistoryRequested extends LinksyEvent {
  const InboxHistoryRequested({
    required this.from,
    required this.app,
    required this.conversation,
    required this.beforeMs,
    required this.limit,
  });
  final DeviceInfo from;
  final String app;
  final String conversation;
  final int beforeMs;
  final int limit;
}

/// What a computer lets this phone's deck do (§4.19), in its [group]:
/// `Media`, `Sound`, `System`, `Network`, `Power` or `Commands`, in English
/// whatever the language ([name] is in the computer's).
class DeckAction {
  const DeckAction({
    required this.id,
    required this.name,
    required this.kind,
    this.group = '',
    this.confirm,
  });
  final String id;
  final String name;
  final DeckKind kind;
  final String group;

  /// The question to ask before running it ("Restart Office PC?"), in the
  /// computer's language.
  final String? confirm;
}

/// A tap runs a button, flips a toggle (its state says [DeckState.on]), and
/// a slider takes a value from 0 to 1 ([DeckState.value]).
enum DeckKind {
  button,
  toggle,
  slider;

  static DeckKind parse(String? s) => switch (s) {
    'toggle' => toggle,
    'slider' => slider,
    _ => button,
  };
}

/// An action's state now, for its tile.
class DeckState {
  const DeckState({required this.id, this.on, this.value, this.text});
  final String id;
  final bool? on;
  final double? value;

  /// What the tile shows besides, like the sound output's name.
  final String? text;
}

/// A computer's deck actions, on `deck_open` and whenever they change there.
class DeckActionsReceived extends LinksyEvent {
  const DeckActionsReceived({required this.from, required this.actions});
  final DeviceInfo from;
  final List<DeckAction> actions;
}

/// …and their state while the deck shows, when something changes.
class DeckStateReceived extends LinksyEvent {
  const DeckStateReceived({required this.from, required this.states});
  final DeviceInfo from;
  final List<DeckState> states;
}

/// The deck's layouts a computer keeps for this phone (§4.20), as it sent
/// them: on `deck_open`, and whenever they're saved there while it shows.
class DeckLayoutReceived extends LinksyEvent {
  const DeckLayoutReceived({required this.from, required this.layouts});
  final DeviceInfo from;
  final Map<String, Object?> layouts;
}

/// A computer answers one of this phone's notifications it shows (§4.5):
/// [text] goes back through the notification's own reply.
class NotificationReplyRequested extends LinksyEvent {
  const NotificationReplyRequested({
    required this.from,
    required this.key,
    required this.text,
  });
  final DeviceInfo from;
  final String key;
  final String text;
}

/// …presses one of its buttons ([action], the id this phone gave it).
class NotificationActionRequested extends LinksyEvent {
  const NotificationActionRequested({
    required this.from,
    required this.key,
    required this.action,
  });
  final DeviceInfo from;
  final String key;
  final String action;
}

/// …or was clicked or swiped away there: it goes here too.
class NotificationDismissRequested extends LinksyEvent {
  const NotificationDismissRequested({required this.from, required this.key});
  final DeviceInfo from;
  final String key;
}

/// A computer asks where this phone is, once (§4.14).
/// A computer asks to turn on what its tab needs here: `notifications` (its
/// Inbox) or `gallery` (its Gallery).
/// A computer wants this phone's `controls_state` while connected (§4.24).
class ControlsWatchRequested extends LinksyEvent {
  const ControlsWatchRequested({required this.from, required this.on});
  final DeviceInfo from;
  final bool on;
}

/// A computer changes some of this phone's controls: only what's in [change].
class ControlsSetRequested extends LinksyEvent {
  const ControlsSetRequested({required this.from, required this.change});
  final DeviceInfo from;
  final Map<String, Object?> change;
}

/// A computer's own notification, to show here (§4.25).
class ComputerNotificationReceived extends LinksyEvent {
  const ComputerNotificationReceived({
    required this.from,
    required this.key,
    required this.app,
    required this.title,
    required this.body,
    required this.atMs,
  });
  final DeviceInfo from;
  final String key;
  final String app;
  final String title;
  final String body;
  final int atMs;
}

/// A computer asks this phone to open its camera (§4.23).
class SnapRequested extends LinksyEvent {
  const SnapRequested(this.from);
  final DeviceInfo from;
}

/// A phone plugged into a computer by USB (§4.11).
class PluggedPhone {
  const PluggedPhone({
    required this.key,
    required this.manufacturer,
    required this.product,
    required this.state,
  });

  final String key;
  final String manufacturer;
  final String product;

  /// `plugged`, `switching`, `accessory` or `failed`.
  final String state;
}

/// What's plugged into a computer now, whenever that changes.
class UsbPlugged extends LinksyEvent {
  const UsbPlugged({required this.from, required this.phones});
  final DeviceInfo from;
  final List<PluggedPhone> phones;
}

class TurnOnRequested extends LinksyEvent {
  const TurnOnRequested({required this.from, required this.feature});
  final DeviceInfo from;
  final String feature;
}

class LocateRequested extends LinksyEvent {
  const LocateRequested(this.from);
  final DeviceInfo from;
}

/// A computer wants this phone's clipboard as it changes, or no longer.
class ClipboardWatchChanged extends LinksyEvent {
  const ClipboardWatchChanged({required this.from, required this.on});
  final DeviceInfo from;
  final bool on;
}

/// A computer put a file (an image…) on this phone's clipboard; it's saved
/// at [path].
class ClipboardFileReceived extends LinksyEvent {
  const ClipboardFileReceived({required this.from, required this.path});
  final DeviceInfo from;
  final String path;
}

/// A terminal still running on a computer, from `terminal_list` (§4.15).
class RemoteTerminal {
  const RemoteTerminal({
    required this.id,
    required this.title,
    required this.started,
  });
  final String id;

  /// The shell's window title ("claude — ~/Project").
  final String title;
  final DateTime started;
}

/// Why a computer turned a terminal down (`session_decline` reasons, §4.15).
enum TerminalRefusal {
  /// Terminal isn't allowed for this phone on the computer.
  off,

  /// Wrong code; see [TerminalRefused.triesLeft].
  code,

  /// Too many wrong codes: unlock it on the computer.
  locked,

  /// Asked from away, where it isn't allowed.
  away,

  /// The computer can't do terminals.
  unsupported,

  /// 8 terminals already run there for this phone.
  limit,

  /// Its user said no.
  declined,
}

/// A terminal open on a computer: its output as it comes, and what this
/// phone sends back (framed JSON on the session, §4.15).
abstract interface class TerminalChannel {
  /// The terminal's id on the computer, for `resume`.
  String get terminalId;

  /// Raw pseudo-terminal output (UTF-8 with escape sequences). Done when the
  /// shell exits or the stream drops.
  Stream<Uint8List> get output;

  /// Typed text, keys as xterm sequences (`term_input`).
  Future<bool> input(String data);

  /// The view's size changed (`term_resize`).
  Future<bool> resize(int cols, int rows);

  /// Ends the shell (`term_close`).
  Future<void> close();

  /// Leaves it running on the computer: ends the stream without
  /// `term_close`, to `resume` later.
  Future<void> detach();
}

// Phone to phone (docs/protocol.md §4.22).

/// How a send would go now (`plan_send`).
class SendPlan {
  const SendPlan({required this.route, this.direct = 'not', this.seconds});

  factory SendPlan.fromJson(Map<String, Object?> j) => SendPlan(
    route: j['route'] as String? ?? 'lan',
    direct: switch (j['direct']) {
      {'state': final String state} => state,
      _ => 'not',
    },
    seconds: j['seconds'] as int?,
  );

  /// `usb`, `direct`, `lan` or `away`, as things stand.
  final String route;

  /// A direct link: `up`, `will` come up first, or `not`.
  final String direct;

  /// A guess, from how fast each route has been to this device.
  final int? seconds;

  /// The way it would really go.
  String get goes => direct == 'not' ? route : 'direct';

  bool get overTheInternet => goes == 'away';
}

/// How the other phone's copy of an app compares with the one to be sent.
enum AppThere {
  /// Not installed there.
  none,

  /// The same version, from the same developer.
  same,

  /// Older there: sending it is an update.
  older,

  /// Newer there.
  newer,

  /// Installed there from another developer.
  otherSigner,

  /// Something a newer Linksy says, or no answer: don't know.
  unknown;

  static AppThere parse(String? value) => switch (value) {
    'none' => none,
    'same' => same,
    'older' => older,
    'newer' => newer,
    'other_signer' => otherSigner,
    _ => unknown,
  };
}

/// An app to compare with the other phone's copy.
class AppProbe {
  const AppProbe({
    required this.package,
    required this.versionCode,
    required this.signer,
  });

  final String package;
  final int versionCode;
  final String signer;

  Map<String, Object?> toJson() => {
    'package': package,
    'version_code': versionCode,
    'signer': signer,
  };
}

/// What the other phone says before a send.
class PreflightReply {
  const PreflightReply({
    this.free,
    this.auto = true,
    this.canInstall = true,
    this.direct,
    this.apps = const {},
  });

  factory PreflightReply.fromJson(Map<String, Object?> j) => PreflightReply(
    free: j['free'] as int?,
    auto: j['auto'] as bool? ?? true,
    canInstall: j['can_install'] as bool? ?? true,
    direct: j['direct'] as String?,
    apps: {
      for (final a in (j['apps'] as List? ?? const []).cast<Map>())
        a['package'] as String: AppThere.parse(a['have'] as String?),
    },
  );

  /// What it can take at once; null when it didn't say.
  final int? free;

  /// It takes this without asking.
  final bool auto;

  /// Linksy may install apps there.
  final bool canInstall;

  /// `ready`, `wifi_off`, `no_permission` or `unsupported`.
  final String? direct;

  /// By package.
  final Map<String, AppThere> apps;
}

/// An app among the files of an offer: only a description, Android checks
/// what it installs.
class AppInfo {
  const AppInfo({
    required this.package,
    required this.label,
    required this.versionCode,
    required this.dir,
    this.versionName,
    this.signer,
    this.icon,
  });

  factory AppInfo.fromJson(Map<String, Object?> j) => AppInfo(
    package: j['package'] as String,
    label: j['label'] as String? ?? '',
    versionCode: j['version_code'] as int? ?? 0,
    dir: j['dir'] as String? ?? '',
    versionName: j['version_name'] as String?,
    signer: j['signer'] as String?,
    icon: j['icon'] as String?,
  );

  final String package;
  final String label;
  final int versionCode;

  /// The folder of the offer holding its APKs.
  final String dir;
  final String? versionName;
  final String? signer;

  /// A small PNG, base64.
  final String? icon;
}

/// An app that arrived, with exactly the files of this transfer.
class ReceivedApp {
  const ReceivedApp({required this.info, required this.apks});

  factory ReceivedApp.fromJson(Map<String, Object?> j) => ReceivedApp(
    info: AppInfo.fromJson((j['info'] as Map).cast()),
    apks: (j['apks'] as List? ?? const []).cast<String>(),
  );

  final AppInfo info;
  final List<String> apks;
}

/// Another device asks before sending here.
class PreflightCall {
  const PreflightCall({required this.call, required this.probes});

  factory PreflightCall.fromJson(Map<String, Object?> j) => PreflightCall(
    call: j['call'] as int,
    probes: (j['apps'] as List? ?? const []).cast<Map<String, Object?>>(),
  );

  final int call;

  /// The apps it's about to send, `{package, version_code, signer}`.
  final List<Map<String, Object?>> probes;
}

/// An app that travels in a send: what the other phone shows and checks.
class AppBundle {
  const AppBundle({
    required this.package,
    required this.label,
    required this.versionCode,
    required this.versionName,
    required this.signer,
    required this.icon,
    required this.apks,
  });

  final String package;
  final String label;
  final int versionCode;
  final String versionName;
  final String signer;

  /// A small PNG, base64.
  final String? icon;

  /// Its files, base first.
  final List<String> apks;

  Map<String, Object?> toJson() => {
    'package': package,
    'label': label,
    'version_code': versionCode,
    'version_name': versionName,
    'signer': signer,
    'icon': icon,
    'apks': apks,
  };
}
