import 'dart:convert';
import 'dart:io';

/// One row in a device's timeline: files, clipboard text or a ping, either
/// way. The core keeps no history, so the app does (`docs/protocol.md` §6).
class Activity {
  Activity({
    required this.id,
    required this.deviceId,
    required this.kind,
    required this.incoming,
    required this.time,
    required this.status,
    this.names = const [],
    this.sizes = const [],
    this.total = 0,
    this.bytes = 0,
    this.saved = const [],
    this.text,
    this.reason,
    this.thumbs = const [],
    this.packages = const {},
  });

  /// Transfer id for files, otherwise a local id.
  final String id;
  final String deviceId;
  final ActivityKind kind;
  final bool incoming;
  final DateTime time;
  ActivityStatus status;

  /// File names offered or sent.
  final List<String> names;

  /// Each file's size, in [names]' order, when known (they go one after
  /// another, so this tells which file is on its way).
  List<int> sizes;
  int total;
  int bytes;
  List<String> saved;

  /// Up to a few of the photos sent, for showing them later.
  final List<String> thumbs;

  /// The apps among [names]: name to package.
  final Map<String, String> packages;

  /// What to picture it with: what was sent, or where it was saved.
  List<String> get pictures => thumbs.isNotEmpty ? thumbs : saved;

  /// Clipboard text, ping title or link. Clipboard text is never written to disk:
  /// it may be a password.
  final String? text;
  String? reason;

  /// Bytes per second, smoothed. Only meaningful while [status] is active.
  double speed = 0;

  bool get isLive =>
      status == ActivityStatus.waiting || status == ActivityStatus.active;

  Map<String, Object?> toJson() => {
    'id': id,
    'device': deviceId,
    'kind': kind.name,
    'incoming': incoming,
    'time': time.millisecondsSinceEpoch,
    // A transfer still going when the app stops did not finish.
    'status': (isLive ? ActivityStatus.failed : status).name,
    'names': names,
    'sizes': sizes,
    'total': total,
    'bytes': bytes,
    'saved': saved,
    if (thumbs.isNotEmpty) 'thumbs': thumbs,
    if (packages.isNotEmpty) 'packages': packages,
    // Links are kept; clipboard text never is (it may be a password).
    if (kind == ActivityKind.ping ||
        kind == ActivityKind.link ||
        kind == ActivityKind.locate)
      'text': text,
    'reason': isLive ? 'Interrupted' : reason,
  };

  static Activity fromJson(Map<String, Object?> j) => Activity(
    id: j['id'] as String,
    deviceId: j['device'] as String,
    kind: ActivityKind.values.byName(j['kind'] as String),
    incoming: j['incoming'] as bool,
    time: DateTime.fromMillisecondsSinceEpoch(j['time'] as int),
    status: ActivityStatus.values.byName(j['status'] as String),
    names: (j['names'] as List).cast<String>(),
    sizes: (j['sizes'] as List?)?.cast<int>() ?? const [],
    total: j['total'] as int,
    bytes: j['bytes'] as int,
    saved: (j['saved'] as List).cast<String>(),
    text: j['text'] as String?,
    reason: j['reason'] as String?,
    thumbs: (j['thumbs'] as List?)?.cast<String>() ?? const [],
    packages: (j['packages'] as Map?)?.cast<String, String>() ?? const {},
  );
}

enum ActivityKind {
  files,
  clipboard,
  ping,

  /// A device watched this phone's screen.
  screen,

  /// A device used this phone's camera as a webcam.
  camera,

  /// A device watched and controlled this phone's screen.
  control,

  /// This phone was a device's second display.
  display,

  /// A web link: opened on the computer ("Open on PC"), or sent to this phone.
  link,

  /// "Find my phone" / "Find my computer".
  ring,

  /// This phone was a computer's touchpad and keyboard.
  remote,

  /// This phone watched (or drove) a computer's screen.
  watch,

  /// A device used this phone as its microphone.
  microphone,

  /// A computer asked where this phone is ([Activity.text]: said or why not).
  locate,
}

enum ActivityStatus { waiting, active, done, declined, failed }

/// Newest first, capped like the desktop's history.
class ActivityStore {
  ActivityStore(this.file);

  final File? file;
  static const maxEntries = 500;

  Future<List<Activity>> load() async {
    final f = file;
    if (f == null || !await f.exists()) return [];
    try {
      final list = jsonDecode(await f.readAsString()) as List;
      return [
        for (final j in list) Activity.fromJson(j as Map<String, Object?>),
      ];
    } on Object {
      // A history that can't be read is not worth failing the app over.
      return [];
    }
  }

  Future<void> save(List<Activity> entries) async {
    final f = file;
    if (f == null) return;
    final kept = entries.take(maxEntries).map((a) => a.toJson()).toList();
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode(kept));
    await tmp.rename(f.path);
  }
}
