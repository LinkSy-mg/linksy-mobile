import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../core/linksy_node.dart';
import 'app_log.dart';
import '../core/models.dart';
import '../core/service_info.dart';
import 'app_update.dart';
import '../ui/format.dart';
import '../ui/l10n.dart';
import '../ui/motion.dart';
import 'activity.dart';
import 'platform.dart';
import 'terminals.dart';

/// App state on top of a [LinksyNode]: the device list, settings and every
/// device's activity. Consent prompts and notices go out on [prompts] for the
/// UI to show.
class LinksyController extends ChangeNotifier with WidgetsBindingObserver {
  LinksyController(
    this.node,
    this._store, {
    this.service,
    Directory? dir,
    AppUpdate? updates,
  }) : updates = updates ?? AppUpdate(null, null),
       _peerPictures = dir == null
           ? null
           : Directory('${dir.path}/peer_pictures'),
       log = AppLog(dir == null ? null : File('${dir.path}/logs.txt'));

  final LinksyNode node;
  final ActivityStore _store;

  /// Settings › Logs: what happened lately, on this phone only.
  final AppLog log;

  /// Terminals on computers (§4.15), by device, kept while the app runs.
  late final terminals = Terminals(node);

  /// Linksy's service information (§4.12): notices, newer versions.
  final ServiceInfoStore? service;
  ServiceInfo? serviceInfo;

  /// Update Now: a newer Linksy for Android, downloaded and installed on a tap.
  final AppUpdate updates;

  /// Pictures computers sent of themselves (§4.5 `picture`), by device.
  final Directory? _peerPictures;
  final Map<String, String> _received = {};

  /// Computers this phone has told its picture since they connected.
  final _toldPicture = <String>{};
  String? _ownPictureData;

  /// Computers whose clipboard comes here as it changes, while connected.
  final _clipWatching = <String>{};
  StreamSubscription<int>? _usbSub;
  StreamSubscription<String>? _logSub;

  List<DeviceView> devices = const [];
  NodeSettings? settings;
  final List<Activity> _activity = [];
  final _prompts = StreamController<LinksyEvent>.broadcast();
  StreamSubscription<LinksyEvent>? _sub;
  final _lastSample = <String, (DateTime, int)>{};
  Timer? _saveTimer;

  /// What this phone is sharing right now (its screen or camera), by session.
  final Map<String, SessionStarted> sharing = {};

  /// Second-display sessions showing on this phone, by session.
  final Map<String, SessionStarted> displays = {};

  /// Who is making this phone ring right now ("Find my phone").
  DeviceInfo? ringingFrom;
  Timer? _ringTimer;

  /// When each device last sent `ring_stop` with nothing ringing: a `ring`
  /// right behind it arrived out of order and is already over (§4.5).
  final _strayRingStops = <String, DateTime>{};

  /// Devices this phone is making ring ("Find my computer"), each until
  /// stopped or for [ringFor].
  final Map<String, Timer> _finding = {};

  bool isFinding(String deviceId) => _finding.containsKey(deviceId);

  /// This phone's battery, and what each computer was last told.
  Battery? _battery;
  final _toldBattery = <String, Battery>{};
  StreamSubscription<Battery>? _batterySub;

  /// Small settings kept by Android: `pause_calls`, `stay_running`,
  /// `share_files`, `photos.<device>`, `photos_since.<device>`…
  Map<String, String> prefs = {};

  /// Each computer's players, the newest state it sent while watched.
  final Map<String, MediaState> media = {};
  final Map<String, int> _mediaWatchers = {};

  /// Each computer's volume, while its players are watched (desktop 0.9.8).
  final Map<String, VolumeState> volume = {};

  /// Computers that lock themselves when this phone leaves.
  final Map<String, int> lockWatchers = {};

  /// Remote (touchpad and keyboard) sessions, by device.
  final Map<String, String> remotes = {};

  /// Each paired device's picture (a file path), chosen on this phone.
  Map<String, String> pictures = {};

  /// Bumped when a picture changes, so images reload.
  int pictureVersion = 0;

  /// Folders picked in Android's picker: shared with computers, backed up.
  String? filesFolder;
  String? photosFolder;

  /// Photo imports going out: transfer → (device, newest photo time, more).
  final Map<String, (String, int, bool)> _imports = {};
  bool _importing = false;
  Timer? _importTimer;
  StreamSubscription<String>? _callSub;
  StreamSubscription<(String, bool)>? _answerSub;
  StreamSubscription<(String, Map<String, Object?>)>? _directSub;
  StreamSubscription<void>? _networkSub;
  StreamSubscription<(String, int?)>? _mediaActionSub;

  bool get pauseOnCalls => prefs['pause_calls'] != 'off';
  bool get locatable => prefs['locate'] == 'on';

  /// The app's language (a code from `languages`), or null for the phone's.
  String? get languageCode => prefs['language'];

  /// The language the app shows; the app rebuilds when it changes.
  final locale = ValueNotifier<Locale>(resolveLocale(null));

  Future<void> setLanguage(String code) async {
    locale.value = resolveLocale(code);
    useLocale(locale.value);
    await _setPref('language', code);
  }

  /// Light, dark, or as the phone is (the default).
  final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  static ThemeMode themeFrom(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _setPref('theme', mode == ThemeMode.system ? null : mode.name);
  }

  /// How fast Linksy's animations run ([Motion.speeds], 0 is off).
  Future<void> setMotionSpeed(double speed) async {
    Motion.setSpeed(speed);
    await _setPref('motion', speed == 1 ? null : '$speed');
  }

  /// The first-run setup (language, then what Linksy may do) is done.
  bool get onboarded => prefs['onboarded'] == '1';

  Future<void> finishOnboarding() => _setPref('onboarded', '1');

  /// This phone's screen in landscape, for "Second display".
  (int, int)? screenSize;

  /// Android 15's screen share protections (see [LinksyPlatform]); on some
  /// phones they black out the status bar and the notification shade.
  String? shareProtections;

  /// Whether to say so under a screen share's banner.
  bool get warnShareProtections =>
      (shareProtections == 'on' || shareProtections == 'unknown') &&
      prefs['share_hint'] != 'dismissed';

  Future<void> dismissShareHint() => _setPref('share_hint', 'dismissed');

  Future<void> _readShareProtections() async {
    final now = await LinksyPlatform.shareProtections();
    if (now == shareProtections) return;
    shareProtections = now;
    notifyListeners();
  }

  String? get ownPicture => prefs['own_picture'];
  bool watchesClipboard(String id) => prefs['clip_watch.$id'] == 'on';

  /// The picture to show for [id]: the one chosen here, else its own.
  String? pictureOf(String id) => pictures[id] ?? _received[id];

  /// Service notices not dismissed yet, the newest first.
  List<ServiceNotice> get notices => [
    for (final n in serviceInfo?.notices ?? const <ServiceNotice>[])
      if (prefs['notice.${n.id}'] == null) n,
  ];

  /// The service says this app is too old to keep connecting.
  bool get outdated => serviceInfo?.outdated ?? false;
  bool get stayRunning => prefs['stay_running'] == 'on';
  bool get sharingFiles => prefs['share_files'] == 'on';
  bool backsUpPhotos(String id) => prefs['photos.$id'] == 'on';
  bool photosDeclined(String id) => prefs['photos_declined.$id'] == '1';
  DateTime? photosBackedUp(String id) => switch (prefs['photos_at.$id']) {
    final ms? => DateTime.fromMillisecondsSinceEpoch(int.parse(ms)),
    null => null,
  };

  /// How long a ring lasts at most (§4.5).
  static const ringFor = Duration(seconds: 30);

  /// Pairing and transfer requests, failures, and things received.
  Stream<LinksyEvent> get prompts => _prompts.stream;

  List<DeviceView> get paired =>
      devices.where((d) => d.trusted).toList()..sort(_byPresenceThenName);

  List<DeviceView> get unpaired =>
      devices.where((d) => !d.trusted && d.nearby).toList()
        ..sort(_byPresenceThenName);

  DeviceView? device(String id) =>
      devices.where((d) => d.device.id == id).firstOrNull;

  List<Activity> activityFor(String deviceId) =>
      _activity.where((a) => a.deviceId == deviceId).toList();

  Activity? lastActivity(String deviceId) =>
      _activity.where((a) => a.deviceId == deviceId).firstOrNull;

  static int _byPresenceThenName(DeviceView a, DeviceView b) {
    final p = a.presence.index.compareTo(b.presence.index);
    return p != 0
        ? p
        : a.device.name.toLowerCase().compareTo(b.device.name.toLowerCase());
  }

  Future<void> start() async {
    _activity.addAll(await _store.load());
    _sub = node.events.listen(_onEvent);
    devices = await node.devices();
    settings = await node.settings();
    notifyListeners();
    _batterySub = LinksyPlatform.batteryChanges.listen(_onBattery);
    _callSub = LinksyPlatform.callStates.listen(_onCall);
    _answerSub = LinksyPlatform.transferAnswers.listen(
      (a) => respond(a.$1, accept: a.$2),
    );
    // Wi-Fi came or went, mobile data took over: the core checks its links.
    _networkSub = LinksyPlatform.networkChanges.listen((_) {
      log.add('Networks changed');
      node.networkChanged();
    });
    // The Wi-Fi part of a direct link did a step: the other device hears it,
    // except a joiner's own (`joining`, `joined`).
    _directSub = LinksyPlatform.directSteps.listen((s) {
      final (id, step) = s;
      final type = step['type'];
      _logDirect(id, switch (type) {
        'invite' when step['ssid'] != null =>
          'group made${step['frequency'] != null ? ', ${step['frequency']} MHz' : ''}, inviting',
        'invite' =>
          'inviting${step['name'] != null ? ' as ${step['name']}' : ''}',
        'connecting' => 'connecting to it',
        'up' => 'link up, this phone at ${step['ip']}',
        'joining' => 'joining its group',
        'joined' => 'in its group, this phone at ${step['ip']}',
        'end' => 'gave up: ${step['reason']}',
        _ => '$type',
      });
      // How far it got, for Transfers
      final stage = switch (type) {
        'connecting' || 'joining' => DirectStage.connect,
        'up' || 'joined' => DirectStage.link,
        _ => null,
      };
      if (stage != null && direct[id] != null && direct[id] != DirectStage.up) {
        direct[id] = stage;
        notifyListeners();
      }
      if (type == 'joining') return;
      if (type == 'joined') {
        _directJoined.add(id);
        _directDial(id);
        return;
      }
      _directSend(id, switch (type) {
        'up' => {...step, 'port': node.port},
        // Phone to phone: the group's credentials go along, nested
        'invite' when step['ssid'] != null => {
          'type': 'invite',
          'address': step['address'],
          'name': ?step['name'],
          'group': {
            'ssid': step['ssid'],
            'passphrase': step['passphrase'],
            if (step['frequency'] case final String f)
              'frequency': int.parse(f),
          },
        },
        _ => step,
      });
    });
    unawaited(
      log.load().then((_) async {
        log.add('Linksy ${await LinksyPlatform.appVersion() ?? ''} started');
      }),
    );
    unawaited(_loadPlatform());
    unawaited(_loadPeerPictures());
    serviceInfo = service?.cached();
    unawaited(
      service?.refresh().then((info) {
        if (info == null) return;
        serviceInfo = info;
        notifyListeners();
      }),
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(updates.start());
    _mediaActionSub = LinksyPlatform.mediaActions.listen(_onMediaAction);
    unawaited(
      LinksyPlatform.battery().then((b) {
        _battery ??= b;
        for (final v in devices) {
          if (v.connected || v.nearby) _tellBattery(v.device.id, always: true);
        }
      }),
    );
  }

  /// Back in the app: new photos may be waiting.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _importAll();
      // Back from Developer options, maybe.
      _readShareProtections();
    } else if (state == AppLifecycleState.hidden) {
      // Out of sight: decoded pictures go, they're read again on return.
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    }
  }

  /// Android-side settings and folders; not awaited by [start] (tests have
  /// no Android side).
  Future<void> _loadPlatform() async {
    prefs = await LinksyPlatform.prefs();
    locale.value = resolveLocale(languageCode);
    useLocale(locale.value);
    themeMode.value = themeFrom(prefs['theme']);
    // Shares that went on while the app's screen was recreated.
    for (final (session, kind, peerId) in await LinksyPlatform.activeShares()) {
      final peer = device(peerId)?.device;
      final k = SessionKind.parse(kind);
      if (peer == null || k == null || sharing.containsKey(session)) continue;
      sharing[session] = SessionStarted(
        session: session,
        peer: peer,
        kind: k,
        sharing: true,
      );
    }
    await _readShareProtections();
    screenSize = await LinksyPlatform.screenSize();
    pictures = await LinksyPlatform.pictures()
      ..remove(_self);
    filesFolder = await LinksyPlatform.folder('files');
    photosFolder = await LinksyPlatform.folder('photos');
    await LinksyPlatform.shareFiles(sharingFiles && filesFolder != null);
    await LinksyPlatform.watchCalls(pauseOnCalls);
    _updateKeepAlive();
    notifyListeners();
    addListener(_shareTargets);
    _shareTargets();
    _usbSub = LinksyPlatform.usbPorts.listen(_onUsb);
    _logSub = LinksyPlatform.logs.listen(log.add);
    final usb = await LinksyPlatform.usbPort();
    if (usb != null) _onUsb(usb);
    for (final v in devices) {
      if (v.connected) _onConnected(v.device.id);
    }
    _importAll();
    _importTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _importAll(),
    );
  }

  /// A small app setting (the terminal's text size…), kept by Android.
  Future<void> setPref(String key, String? value) => _setPref(key, value);

  Future<void> _setPref(String key, String? value) async {
    if (value == null) {
      prefs.remove(key);
    } else {
      prefs[key] = value;
    }
    notifyListeners();
    await LinksyPlatform.setPref(key, value);
  }

  Future<void> _loadPeerPictures() async {
    final dir = _peerPictures;
    if (dir == null || !dir.existsSync()) return;
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && name.endsWith('.img')) {
        _received[name.substring(0, name.length - 4)] = f.path;
      }
    }
    pictureVersion++;
    notifyListeners();
  }

  /// The key this phone's own picture is kept under, beside the devices'.
  static const _self = 'self';

  // Pictures (§4.5): this phone's goes to each computer once connected; a
  // computer's own shows unless one was chosen for it here.

  Future<bool> pickOwnPicture() async {
    final path = await LinksyPlatform.pickPicture(_self);
    if (path == null) return false;
    await FileImage(File(path)).evict();
    _ownPictureData = null;
    await _setPref('own_picture', path);
    pictureVersion++;
    _toldPicture.clear();
    for (final v in devices) {
      if (v.connected) _tellPicture(v.device.id);
    }
    return true;
  }

  Future<void> removeOwnPicture() async {
    _ownPictureData = null;
    await _setPref('own_picture', null);
    await LinksyPlatform.removePicture(_self);
    pictureVersion++;
    notifyListeners();
  }

  Future<void> _tellPicture(String id) async {
    final path = ownPicture;
    final v = device(id);
    if (path == null ||
        v == null ||
        !v.trusted ||
        !v.device.can('picture') ||
        !_toldPicture.add(id)) {
      return;
    }
    final data = _ownPictureData ??= await LinksyPlatform.pictureJpeg(path);
    if (data == null) return;
    try {
      await node.sendPicture(id, data);
    } on LinksyException {
      _toldPicture.remove(id);
    }
  }

  Future<void> _onPicture(DeviceInfo from, String image) async {
    final dir = _peerPictures;
    if (dir == null || image.isEmpty) return;
    try {
      final bytes = base64Decode(image);
      if (bytes.length > 192 * 1024) return;
      await dir.create(recursive: true);
      final file = File('${dir.path}/${from.id}.img');
      await file.writeAsBytes(bytes, flush: true);
      await FileImage(file).evict();
      _received[from.id] = file.path;
      pictureVersion++;
      notifyListeners();
    } on FormatException {
      // Not base64: ignore it.
    }
  }

  // Clipboard (§4.5): a computer's clipboard text as it changes, where its
  // desktop allows it (`clipboard_watch`).

  Future<void> setClipboardWatch(String id, bool on) async {
    await _setPref('clip_watch.$id', on ? 'on' : null);
    if (on) {
      _watchClipboard(id);
    } else if (_clipWatching.remove(id)) {
      await node.watchClipboard(id, on: false).catchError((Object _) {});
    }
  }

  void _watchClipboard(String id) {
    final v = device(id);
    if (v == null ||
        !v.connected ||
        !watchesClipboard(id) ||
        !v.device.features.contains('clipboard_watch') ||
        !_clipWatching.add(id)) {
      return;
    }
    node.watchClipboard(id, on: true).catchError((Object _) {
      _clipWatching.remove(id);
    });
  }

  /// One file (an image…) onto [id]'s clipboard, from the share sheet.
  Future<String?> sendToClipboard(String id, String path) async {
    final file = File(path);
    if (!file.existsSync() || file.lengthSync() > 10 * 1024 * 1024) {
      return tr.ctlClipboardFileTooBig;
    }
    try {
      final transfer = await node.sendClipboardFile(id, path);
      _add(
        Activity(
          id: transfer,
          deviceId: id,
          kind: ActivityKind.clipboard,
          incoming: false,
          time: DateTime.now(),
          status: ActivityStatus.waiting,
          names: [path.split('/').last],
          total: file.lengthSync(),
        ),
      );
      return null;
    } on LinksyException catch (e) {
      return e.message;
    }
  }

  Future<void> _onClipboardFile(DeviceInfo from, String path) async {
    final copied = await LinksyPlatform.clipboardFile(path);
    _add(
      Activity(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        deviceId: from.id,
        kind: ActivityKind.clipboard,
        incoming: true,
        time: DateTime.now(),
        status: copied ? ActivityStatus.done : ActivityStatus.failed,
        names: [path.split('/').last],
        saved: [path],
        reason: copied ? null : tr.ctlClipboardCopyFailed,
      ),
    );
  }

  // Locate (§4.14): one fix when a computer asks, only if allowed here.

  Future<bool> setLocatable(bool on) async {
    if (on && !await LinksyPlatform.requestPermission('location')) {
      return false;
    }
    await _setPref('locate', on ? 'on' : null);
    return true;
  }

  Future<void> _onLocate(DeviceInfo from) async {
    String? refused;
    if (!locatable) {
      refused = tr.ctlLocateOff;
    } else {
      final fix = await LinksyPlatform.locate();
      if (fix.error != null) {
        refused = fix.error;
      } else {
        await node
            .sendLocation(
              from.id,
              lat: fix.lat,
              lon: fix.lon,
              accuracyM: fix.accuracy,
              at: fix.at,
            )
            .catchError((Object _) {});
      }
    }
    if (refused != null) {
      await node.refuseLocation(from.id, refused).catchError((Object _) {});
    }
    _addLocal(
      from.id,
      ActivityKind.locate,
      incoming: true,
      status: refused == null ? ActivityStatus.done : ActivityStatus.declined,
      text: refused,
    );
  }

  // Away from home (§4.13).

  Future<String?> setAwayAll(String id, bool on) => _run(() async {
    await node.setAwayAll(id, on: on);
    await refresh();
  });

  Future<String?> connectAway(String id) => _run(() async {
    await node.connectAway(id);
    await refresh();
  });

  // Android's share sheet (#10): each paired device, the last one used first.

  String? _shareTargetsSent;

  void _shareTargets() {
    final last = <String, int>{};
    for (final (i, a) in _activity.indexed) {
      last.putIfAbsent(a.deviceId, () => i);
    }
    final paired = [
      for (final v in devices)
        if (v.trusted) v.device,
    ]..sort((a, b) => (last[a.id] ?? 1 << 30).compareTo(last[b.id] ?? 1 << 30));
    final targets = [
      for (final d in paired)
        {
          'id': d.id,
          'name': d.name,
          'initials': initials(d.name),
          'picture': pictureOf(d.id),
        },
    ];
    // Android limits how often these change: only when they do.
    final key = '${jsonEncode(targets)}#$pictureVersion';
    if (key == _shareTargetsSent) return;
    _shareTargetsSent = key;
    LinksyPlatform.shareTargets(targets);
  }

  // USB cable (§4.11): the bridge is up; dial the computer through it.

  int? _usbPort;
  final _usbNews = StreamController<UsbNews>.broadcast();

  /// What the cable did: dialing, a computer connected through it, or one
  /// that isn't paired to offer pairing with.
  Stream<UsbNews> get usbNews => _usbNews.stream;

  void _onUsb(int port) {
    if (port == _usbPort) return;
    _usbPort = port;
    unawaited(_dialCable(port));
  }

  /// Dials the computer on the cable, a few times: a cable can take a moment
  /// to carry anything. Pairing is offered only once a computer says it
  /// doesn't know this phone, or nobody answers at all (a phone already
  /// paired over Wi-Fi used to be offered pairing after one failed try).
  Future<void> _dialCable(int port, {int tries = 3}) async {
    final address = '127.0.0.1:$port';
    log.add('USB cable: dialing the computer');
    _usbNews.add(const UsbDialing());
    for (var attempt = 1; ; attempt++) {
      try {
        await node.connectAddress(address).timeout(const Duration(seconds: 6));
        log.add('USB cable: connected');
        await refresh();
        final view = devices.where((v) => v.connected && v.usb).firstOrNull;
        _usbNews.add(
          UsbConnected(
            view?.device.name ?? tr.ctlYourComputer,
            view?.device.id,
          ),
        );
        return;
      } on Object catch (e) {
        if (_usbPort != port) return;
        final notPaired = e is LinksyException && e.kind == 'not_paired';
        log.add('USB cable: try $attempt failed ($e)');
        if (notPaired || attempt >= tries) {
          // No paired computer answers: maybe one to pair (desktop 0.8.0
          // switches phones that aren't paired yet).
          _usbNews.add(UsbPairOffer(address));
          return;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      if (_usbPort != port) return;
    }
  }

  /// Pair with the computer on the cable, then connect through it.
  Future<String?> pairOverCable(String address) => _run(() async {
    await node.pairAddress(address);
    await node.connectAddress(address);
    await refresh();
  });

  /// A computer connected (again): what it should know straight away.
  void _onConnected(String id) {
    _watchForNotice(id);
    _tellBattery(id, always: true);
    _tellPicture(id);
    _watchClipboard(id);
    _importTo(id);
  }

  void dismissNotice(String id) => _setPref('notice.$id', '1');

  String _name(String id) => device(id)?.device.name ?? tr.ctlYourComputer;

  /// The quiet "stay connected" notification: while a computer locks when
  /// this phone leaves (CPU kept awake for heartbeats), or when the user
  /// wants Linksy to keep running in the background.
  void _updateKeepAlive() {
    final lockers = [for (final id in lockWatchers.keys) _name(id)];
    final moving = liveTransfers;
    if (moving.isNotEmpty) {
      // Files on their way, with their progress, and the CPU and Wi-Fi kept
      // on so nothing drops with the screen off.
      final total = moving.fold(0, (n, a) => n + a.total);
      final bytes = moving.fold(0, (n, a) => n + a.bytes);
      final waiting = moving.every((a) => a.status == ActivityStatus.waiting);
      final percent = waiting || total == 0 ? -1 : bytes * 100 ~/ total;
      final files = moving.fold(0, (n, a) => n + a.names.length);
      final key = '$files/$percent';
      final now = DateTime.now();
      if (key == _noticeKey ||
          _noticeKey != null &&
              now.difference(_noticeAt) < const Duration(seconds: 1)) {
        return;
      }
      _noticeKey = key;
      _noticeAt = now;
      LinksyPlatform.keepAlive(
        on: true,
        awake: true,
        title: tr.transfersBubble(files),
        text: percent < 0 ? tr.transfersWaiting : '$percent%',
        progress: percent,
      );
      return;
    }
    _noticeKey = null;
    if (lockers.isNotEmpty) {
      LinksyPlatform.keepAlive(
        on: true,
        awake: true,
        text: tr.ctlKeepingLocked(lockers.join(' ${tr.ctlAnd} ')),
      );
    } else if (stayRunning) {
      LinksyPlatform.keepAlive(on: true, text: tr.ctlStayingConnected);
    } else {
      LinksyPlatform.keepAlive(on: false);
    }
  }

  /// Direct links (docs/protocol.md §4.17) by device, as far as they got.
  final direct = <String, DirectStage>{};

  /// Wi-Fi Direct for big transfers. On unless turned off; off, the phone
  /// says no to every link (and doesn't offer them from the next start).
  bool get directOn => prefs['direct'] != 'off';

  /// Turning it on asks for the Nearby devices permission right away.
  Future<void> setDirectOn(bool on) async {
    await _setPref('direct', on ? null : 'off');
    if (on) {
      await LinksyPlatform.requestPermission('nearby');
    } else {
      for (final id in [...direct.keys]) {
        _directSend(id, {'type': 'end', 'reason': 'turned off on the phone'});
      }
    }
  }

  /// Phone to phone, joining: in the group, and where the host said it is.
  final _directJoined = <String>{};
  final _directUp = <String, String>{};

  /// Steps go out one after the other: the invite before `up`.
  Future<void> _directSent = Future.value();
  void _directSend(String id, Map<String, Object?> step) {
    _directSent = _directSent.then(
      (_) => node.directSend(id, step).catchError((Object _) {}),
    );
  }

  void _directDial(String id) {
    final address = _directUp[id];
    if (address == null || !_directJoined.contains(id)) return;
    _directUp.remove(id);
    final t = DateTime.now();
    _logDirect(id, 'connecting to Linksy at $address');
    node
        .directDial(id, address)
        .then((_) {
          final ms = DateTime.now().difference(t).inMilliseconds;
          _logDirect(id, 'connected over it in $ms ms');
        })
        .catchError((Object e) {
          _logDirect(id, "couldn't connect over it: $e");
          _directSend(id, {
            'type': 'end',
            'reason': "couldn't connect over it",
          });
        });
  }

  /// Direct links: when each started, for the timings in the log.
  final _directSince = <String, DateTime>{};

  void _logDirect(String id, String what) {
    final since = _directSince[id];
    final t = since == null
        ? ''
        : ' (+${(DateTime.now().difference(since).inMilliseconds / 1000).toStringAsFixed(1)} s)';
    log.add('Wi-Fi Direct, ${_who(id)}: $what$t');
  }

  String _who(String id) => device(id)?.device.name ?? id.substring(0, 8);

  /// Transfers in the log: who with, how big, since when.
  final _logged = <String, (String, int, DateTime)>{};

  void _logEvent(LinksyEvent e) {
    switch (e) {
      case Connected(:final id):
        final v = device(id);
        log.add(
          'Connected to ${_who(id)}'
          '${v == null
              ? ''
              : v.usb
              ? ' (USB)'
              : v.away
              ? ' (over the internet)'
              : ' (same Wi-Fi)'}',
        );
      case Disconnected(:final id):
        log.add('Disconnected from ${_who(id)}');
      case Paired(:final device):
        log.add('Paired with ${device.name}');
      case PairingFailed(:final device, :final reason):
        log.add('Pairing ${device?.name ?? ''} failed: $reason');
      case TransferRequest(:final from, :final files, :final total):
        log.add(
          '${from.name} offers ${files.length} file(s), ${formatBytes(total)}',
        );
      case TransferStarted(:final transfer, :final peer, :final incoming):
        final a = _activity.where((a) => a.id == transfer).firstOrNull;
        final name = peer?.name ?? (a == null ? '?' : _who(a.deviceId));
        final total = e.total > 0
            ? e.total
            : (a?.sizes.fold(0, (x, y) => x + y) ?? 0);
        _logged[transfer] = (name, total, DateTime.now());
        log.add(
          '${incoming ? 'Receiving from' : 'Sending to'} $name, ${formatBytes(total)}',
        );
      case TransferComplete(:final transfer):
        final (name, total, since) =
            _logged.remove(transfer) ?? ('?', 0, DateTime.now());
        final s = DateTime.now().difference(since).inMilliseconds / 1000;
        final speed = s > 0 && total > 0
            ? ', ${formatBytes(total ~/ s)}/s'
            : '';
        log.add('Transfer with $name done in ${s.toStringAsFixed(1)} s$speed');
      case TransferFailed(:final transfer, :final reason):
        final name = _logged.remove(transfer)?.$1 ?? '?';
        log.add('Transfer with $name failed: $reason');
      case DirectWanted(:final id, :final group):
        _directSince[id] = DateTime.now();
        _logDirect(
          id,
          !directOn
              ? 'asked, but turned off here'
              : group != null
              ? 'hosting a group for it (phone to phone)'
              : 'hosting, it joins (computer)',
        );
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'invite':
        _directSince[from.id] = DateTime.now();
        final group = step['group'];
        _logDirect(
          from.id,
          group is Map
              ? 'invited to its group'
                    '${group['frequency'] != null ? ', ${group['frequency']} MHz' : ''}'
              : 'invited, but this phone joins groups only',
        );
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'up':
        _logDirect(from.id, 'its Linksy is at ${step['ip']}:${step['port']}');
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'listening':
        _logDirect(from.id, 'it listens at ${step['address']}');
      case DirectLinked(:final id):
        _logDirect(id, 'linked, transfers go over it');
      case DirectEnded(:final id, :final reason):
        _logDirect(id, 'ended${reason == null ? '' : ': $reason'}');
        _directSince.remove(id);
      default:
        break;
    }
  }

  /// What the transfer notification last showed, and when.
  String? _noticeKey;
  DateTime _noticeAt = DateTime(0);

  Future<void> setStayRunning(bool on) async {
    await _setPref('stay_running', on ? 'on' : null);
    _updateKeepAlive();
  }

  // Calls (§4.5): paired computers that are around hear when a call rings,
  // goes on and ends, and pause what plays meanwhile.

  /// Two fingers on the touchpad scroll the other way.
  bool get scrollReversed => prefs['scroll_reverse'] == 'on';
  Future<void> setScrollReversed(bool on) =>
      _setPref('scroll_reverse', on ? 'on' : null);

  /// The number pad on the presentation remote.
  bool get slidesNumpad => prefs['slides_numpad'] == 'on';
  Future<void> setSlidesNumpad(bool on) =>
      _setPref('slides_numpad', on ? 'on' : null);

  Future<void> setPauseOnCalls(bool on) async {
    await _setPref('pause_calls', on ? null : 'off');
    await LinksyPlatform.watchCalls(on);
  }

  void _onCall(String state) {
    if (!pauseOnCalls) return;
    for (final v in devices) {
      if (v.trusted && _isComputer(v.device) && (v.connected || v.nearby)) {
        node.sendCallState(v.device.id, state).catchError((Object _) {});
      }
    }
  }

  // Files (§4.9): computers browse the one folder the user picked.

  Future<String?> pickFilesFolder() async {
    final name = await LinksyPlatform.pickFolder('files');
    if (name == null) return null;
    filesFolder = name;
    await setSharingFiles(true);
    return name;
  }

  Future<void> setSharingFiles(bool on) async {
    await _setPref('share_files', on ? 'on' : null);
    await LinksyPlatform.shareFiles(on && filesFolder != null);
  }

  // Media (§4.5): a computer's players, while a page or the media
  // notification shows them.

  void watchMedia(String id) {
    final n = (_mediaWatchers[id] ?? 0) + 1;
    _mediaWatchers[id] = n;
    if (n == 1) _watch(id, on: true);
  }

  void unwatchMedia(String id) {
    final n = (_mediaWatchers[id] ?? 1) - 1;
    if (n > 0) {
      _mediaWatchers[id] = n;
      return;
    }
    _mediaWatchers.remove(id);
    _watch(id, on: false);
  }

  /// The players, and the volume when the computer has one to share.
  void _watch(String id, {required bool on}) {
    node.watchMedia(id, on: on).catchError((Object _) {});
    if (device(id)?.device.features.contains('volume') ?? false) {
      node.watchVolume(id, on: on).catchError((Object _) {});
    }
  }

  /// The computer's volume: [level] from 0 to 1, [muted], or both. Shown
  /// straight away; the computer's answer follows.
  Future<String?> setVolume(String id, {double? level, bool? muted}) {
    if (volume[id] case final v?) {
      volume[id] = VolumeState(
        seq: v.seq,
        level: level ?? v.level,
        muted: muted ?? v.muted,
      );
      notifyListeners();
    }
    return _run(() => node.setVolume(id, level: level, muted: muted));
  }

  /// `play_pause`, `next`, `previous`, or `seek` to [positionMs].
  Future<String?> mediaCommand(
    String id,
    String player,
    String action, {
    int? positionMs,
  }) => _run(
    () => node.mediaCommand(id, player, {
      'action': action,
      'position_ms': ?positionMs,
    }),
  );

  /// The computers' music as a media notification, as KDE Connect does. On
  /// unless turned off.
  bool get mediaNotice => prefs['media_notice'] != 'off';

  Future<void> setMediaNotice(bool on) async {
    await _setPref('media_notice', on ? null : 'off');
    if (on) {
      for (final v in devices) {
        if (v.connected) _watchForNotice(v.device.id);
      }
    } else {
      _noticeWatching.forEach(unwatchMedia);
      _noticeWatching.clear();
    }
    _showMediaNotice();
  }

  /// Computers whose players the notification watches.
  final Set<String> _noticeWatching = {};

  /// The computer and player the notification shows.
  (String, String)? _noticed;
  Map<String, Object?>? _noticeShown;

  /// A computer connected: its players for the notification, and again for
  /// a page that watched them before it went away (watching lasts one
  /// connection).
  void _watchForNotice(String id) {
    final d = device(id)?.device;
    if (mediaNotice && d != null && _isComputer(d) && _noticeWatching.add(id)) {
      _mediaWatchers[id] = (_mediaWatchers[id] ?? 0) + 1;
    }
    if (_mediaWatchers.containsKey(id)) _watch(id, on: true);
  }

  /// One player at a time: what plays, keeping to the one shown; else the
  /// one shown; else the first.
  void _showMediaNotice() {
    final all = [
      if (mediaNotice)
        for (final id in _noticeWatching)
          for (final p in media[id]?.players ?? const <MediaPlayer>[]) (id, p),
    ];
    bool shown((String, MediaPlayer) e) => _noticed == (e.$1, e.$2.id);
    final pick =
        all.where((e) => e.$2.playing && shown(e)).firstOrNull ??
        all.where((e) => e.$2.playing).firstOrNull ??
        all.where(shown).firstOrNull ??
        all.firstOrNull;
    _noticed = pick == null ? null : (pick.$1, pick.$2.id);
    final player = pick == null
        ? null
        : <String, Object?>{
            'device': _name(pick.$1),
            'app': pick.$2.app,
            'title': pick.$2.title,
            'artist': pick.$2.artist,
            'album': pick.$2.album,
            'playing': pick.$2.playing,
            'position_ms': pick.$2.positionMs,
            'length_ms': pick.$2.lengthMs,
            'can_next': pick.$2.canNext,
            'can_previous': pick.$2.canPrevious,
            'can_seek': pick.$2.canSeek,
            'art': pick.$2.art,
          };
    if (mapEquals(player, _noticeShown)) return;
    _noticeShown = player;
    LinksyPlatform.mediaNotice(player);
  }

  void _onMediaAction((String, int?) a) {
    final (action, at) = a;
    if (_noticed case (final id, final player)) {
      mediaCommand(id, player, action, positionMs: at);
    }
  }

  // Remote (§4.8, `input`): this phone as the computer's touchpad and
  // keyboard.

  /// Asks the computer (its user allows it there); null when it's on.
  Future<String?> startRemote(String id) => _run(() async {
    final session = await node.startInput(id);
    remotes[id] = session;
    notifyListeners();
  });

  /// Input messages (`pointer_by`, `button`, `scroll`, `key`, `text`), each
  /// framed as u32 big-endian length + JSON. False once the computer ended it.
  Future<bool> remoteSend(String id, List<Map<String, Object>> messages) async {
    final session = remotes[id];
    if (session == null) return false;
    final out = BytesBuilder(copy: false);
    for (final m in messages) {
      final body = utf8.encode(jsonEncode(m));
      out
        ..add((ByteData(4)..setUint32(0, body.length)).buffer.asUint8List())
        ..add(body);
    }
    return node.sessionWrite(session, out.takeBytes());
  }

  Future<void> stopRemote(String id) async {
    final session = remotes.remove(id);
    notifyListeners();
    if (session != null) await node.endSession(session);
  }

  // Photo backup (§4.5, `import`): new photos from the picked folder go to
  // each computer that has it on, a batch at a time, while it's around.

  Future<bool> setPhotoBackup(String id, bool on) async {
    if (on && photosFolder == null) {
      photosFolder = await LinksyPlatform.pickFolder('photos');
      if (photosFolder == null) return false;
    }
    await _setPref('photos.$id', on ? 'on' : null);
    await _setPref('photos_declined.$id', null);
    // Only what's taken from now on; earlier photos aren't sent.
    if (on && prefs['photos_since.$id'] == null) {
      await _setPref(
        'photos_since.$id',
        '${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    if (on) _importTo(id);
    return true;
  }

  Future<String?> pickPhotosFolder() async {
    final name = await LinksyPlatform.pickFolder('photos');
    if (name != null) {
      photosFolder = name;
      notifyListeners();
      _importAll();
    }
    return name;
  }

  void _importAll() {
    for (final v in devices) {
      _importTo(v.device.id);
    }
  }

  Future<void> _importTo(String id) async {
    final v = device(id);
    if (_importing ||
        photosFolder == null ||
        v == null ||
        !v.trusted ||
        !(v.connected || v.nearby) ||
        !backsUpPhotos(id) ||
        photosDeclined(id)) {
      return;
    }
    _importing = true;
    try {
      final since = int.tryParse(prefs['photos_since.$id'] ?? '') ?? 0;
      final batch = await LinksyPlatform.photoBatch(since);
      if (batch == null || batch.count == 0) {
        _importing = false;
        return;
      }
      final transfer = await node.importFiles(id, batch.folders);
      _imports[transfer] = (id, batch.newest, batch.more);
    } on Object {
      _importing = false;
    }
  }

  void _importEnded(String transfer, {required bool ok, String reason = ''}) {
    final entry = _imports.remove(transfer);
    if (entry == null) return;
    final (id, newest, more) = entry;
    _importing = false;
    if (ok) {
      _setPref('photos_since.$id', '$newest');
      _setPref('photos_at.$id', '${DateTime.now().millisecondsSinceEpoch}');
      if (more) {
        _importTo(id);
        return;
      }
    } else if (reason.toLowerCase().contains('declin')) {
      // That computer doesn't take imports (turned off there).
      _setPref('photos_declined.$id', '1');
    }
    _importAll();
  }

  // Battery (docs/protocol.md §4.5): sent to paired computers on connecting, then
  // when it moves by 5 points or charging starts or stops. Each send may open
  // a connection, so no more often than that.

  bool _isComputer(DeviceInfo d) =>
      d.kind == DeviceKind.desktop || d.kind == DeviceKind.laptop;

  void _onBattery(Battery b) {
    _battery = b;
    for (final v in devices) {
      if (v.trusted && (v.connected || v.nearby)) _tellBattery(v.device.id);
    }
  }

  Future<void> _tellBattery(String id, {bool always = false}) async {
    final b = _battery;
    final v = device(id);
    if (b == null || v == null || !v.trusted || !_isComputer(v.device)) return;
    final told = _toldBattery[id];
    if (!always &&
        told != null &&
        told.charging == b.charging &&
        (told.level - b.level).abs() < 5) {
      return;
    }
    _toldBattery[id] = b;
    try {
      await node.sendBattery(id, b);
    } on LinksyException {
      // Not around after all: say it again next time it connects.
      _toldBattery.remove(id);
    }
  }

  Future<void> refresh() async {
    devices = await node.devices();
    notifyListeners();
  }

  void _onEvent(LinksyEvent e) {
    _logEvent(e);
    switch (e) {
      case Connected(:final id):
        refresh().then((_) => _onConnected(id));
      case Paired(:final device):
        refresh().then((_) => _tellBattery(device.id, always: true));
      case DeviceFound(:final device):
        // A paired computer came around: tell it the battery.
        refresh().then((_) {
          _tellBattery(device.id, always: true);
          _importTo(device.id);
        });
      case Disconnected(:final id):
        media.remove(id);
        volume.remove(id);
        _showMediaNotice();
        _toldPicture.remove(id);
        _clipWatching.remove(id);
        refresh();
      case PictureReceived(:final from, :final image):
        _onPicture(from, image);
      case LocateRequested(:final from):
        _onLocate(from);
      case ClipboardFileReceived(:final from, :final path):
        _onClipboardFile(from, path);
      case ClipboardWatchChanged():
        // Android doesn't let apps watch the clipboard in the background,
        // and this phone doesn't announce `clipboard_watch`.
        break;
      case DeviceLost() || DeviceUpdated():
        refresh();
      case MediaStateReceived(:final from, :final state):
        final known = media[from.id];
        if (known == null || state.seq >= known.seq) {
          media[from.id] = state;
          _showMediaNotice();
          notifyListeners();
        }
      case VolumeStateReceived(:final from, :final state):
        final known = volume[from.id];
        if (known == null || state.seq >= known.seq) {
          volume[from.id] = state;
          notifyListeners();
        }
      // Direct links (docs/protocol.md §4.17): this phone hosts (or joins
      // another phone's group), Android does the Wi-Fi part.
      // Up already: nothing to set up (only DirectEnded ends it)
      case DirectWanted(:final id) when direct[id] == DirectStage.up:
        break;
      case DirectWanted(:final id) when !directOn:
        _directSend(id, {'type': 'end', 'reason': 'turned off on the phone'});
      case DirectWanted(:final id, :final group):
        direct[id] = DirectStage.find;
        LinksyPlatform.directWanted(id, group: group);
        notifyListeners();
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'listening' && step['address'] is String:
        LinksyPlatform.directListening(from.id, step['address'] as String);
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'invite':
        final group = step['group'];
        if (!directOn || group is! Map) {
          // This phone joins groups only (a phone's); an older app's invite
          // without one goes the usual way
          _directSend(from.id, {
            'type': 'end',
            'reason': directOn
                ? 'this phone joins groups only'
                : 'turned off on the phone',
          });
        } else if (direct[from.id] == null) {
          direct[from.id] = DirectStage.find;
          LinksyPlatform.directJoin(from.id, group.cast<String, Object?>());
          notifyListeners();
        }
      // Each step comes on a stream of its own: `up` may overtake the invite
      case DirectStepReceived(:final from, :final step)
          when step['type'] == 'up':
        final ip = step['ip'];
        _directUp[from.id] = '$ip:${step['port']}';
        _directDial(from.id);
      case DirectLinked(:final id):
        direct[id] = DirectStage.up;
        LinksyPlatform.directLinked(id);
        notifyListeners();
      case DirectEnded(:final id):
        direct.remove(id);
        _directJoined.remove(id);
        _directUp.remove(id);
        LinksyPlatform.directEnded(id);
        notifyListeners();
      case DirectStepReceived():
        break;
      case HeartbeatWatchChanged(:final from, :final on):
        if (on) {
          lockWatchers[from.id] = e.everyS;
        } else {
          lockWatchers.remove(from.id);
        }
        _updateKeepAlive();
        notifyListeners();
      // A computer's screen this phone asked to see: shown like a second
      // display.
      case SessionStarted(:final session)
          when !e.sharing &&
              (e.kind == SessionKind.screen || e.kind == SessionKind.control):
        displays[session] = e;
        LinksyPlatform.keepScreenOn(session, on: true);
        _addSession(e);
      case SessionStarted(:final session, :final peer, kind: SessionKind.input):
        remotes[peer.id] = session;
        _addSession(e);
      case BatteryReported():
        // Also in the device list; read it again to show it.
        refresh();
      case OpenUrlReceived(:final from, :final url):
        _addLocal(from.id, ActivityKind.link, incoming: true, text: url);
      case RingRequested(:final from, on: true):
        final stray = _strayRingStops.remove(from.id);
        if (stray != null &&
            DateTime.now().difference(stray) < const Duration(seconds: 1)) {
          return;
        }
        _startRinging(from);
      case RingRequested(:final from, on: false):
        if (ringingFrom?.id == from.id) {
          stopRinging();
        } else {
          _strayRingStops[from.id] = DateTime.now();
        }
      case SettingsChanged(:final settings):
        this.settings = settings;
        notifyListeners();
      case TransferRequest(
        :final transfer,
        :final from,
        :final files,
        :final total,
      ):
        // Not on screen: Accept / Decline right in the notification.
        if (WidgetsBinding.instance.lifecycleState !=
            AppLifecycleState.resumed) {
          LinksyPlatform.noticeTransfer(
            transfer,
            tr.ctlTransferRequest(files.length, from.name),
            [
              if (files.length == 1) files.single.name,
              formatBytes(total),
            ].join(' · '),
          );
        }
        _add(
          Activity(
            id: transfer,
            deviceId: from.id,
            kind: ActivityKind.files,
            incoming: true,
            time: DateTime.now(),
            status: ActivityStatus.waiting,
            names: [for (final f in files) f.name],
            sizes: [for (final f in files) f.size],
            total: total,
          ),
        );
      case TransferStarted(
        :final transfer,
        :final peer,
        :final incoming,
        :final files,
        :final total,
      ):
        // Outgoing transfers start when offered: they wait for the other side
        // until bytes flow. Incoming ones start once accepted.
        if (_activity.any((a) => a.id == transfer)) {
          _update(transfer, (a) {
            if (incoming) a.status = ActivityStatus.active;
            // Sizes the sender couldn't read here: the core knows them.
            if (a.sizes.every((n) => n == 0)) {
              a.sizes = [for (final f in files) f.size];
            }
          });
        } else if (peer != null) {
          // Not started here (auto-accepted files): file it under the peer.
          _add(
            Activity(
              id: transfer,
              deviceId: peer.id,
              kind: ActivityKind.files,
              incoming: incoming,
              time: DateTime.now(),
              status: incoming ? ActivityStatus.active : ActivityStatus.waiting,
              names: [for (final f in files) f.name],
              sizes: [for (final f in files) f.size],
              total: total,
            ),
          );
        }
      case TransferProgress(:final transfer, :final bytes, :final total):
        _update(transfer, (a) {
          a
            ..status = ActivityStatus.active
            ..bytes = bytes
            ..total = total
            ..speed = _speed(transfer, bytes, a.speed);
        }, save: false);
      case TransferComplete(:final transfer)
          when _imports.containsKey(transfer):
        _update(transfer, (a) {
          a
            ..status = ActivityStatus.done
            ..bytes = a.total;
        });
        _importEnded(transfer, ok: true);
      case TransferFailed(:final transfer, :final reason)
          when _imports.containsKey(transfer):
        _update(transfer, (a) {
          a
            ..status = ActivityStatus.failed
            ..reason = reason;
        });
        _importEnded(transfer, ok: false, reason: reason);
      case TransferComplete(:final transfer, :final saved):
        LinksyPlatform.cancelNotice(transfer);
        _update(transfer, (a) {
          a
            ..status = ActivityStatus.done
            ..bytes = a.total
            ..saved = saved;
        });
        // Into Downloads/Linksy, where other apps find them. Not a file put
        // on the clipboard: no timeline entry was made for its transfer.
        if (saved.isNotEmpty && _activity.any((a) => a.id == transfer)) {
          LinksyPlatform.publishDownloads(saved).then((moved) {
            _update(transfer, (a) => a.saved = moved);
          });
        }
        _lastSample.remove(transfer);
      case TransferFailed(:final transfer, :final reason):
        LinksyPlatform.cancelNotice(transfer);
        _update(transfer, (a) {
          final declined = reason.toLowerCase().contains('declin');
          a
            ..status = declined
                ? ActivityStatus.declined
                : ActivityStatus.failed
            ..reason = reason;
        });
        _lastSample.remove(transfer);
      case ClipboardReceived(:final from, :final text):
        Clipboard.setData(ClipboardData(text: text));
        // Watched clipboards change often: one entry, kept current.
        final last = lastActivity(from.id);
        if (_clipWatching.contains(from.id) &&
            last != null &&
            last.kind == ActivityKind.clipboard &&
            last.incoming &&
            last.names.isEmpty) {
          _activity.remove(last);
        }
        _addLocal(from.id, ActivityKind.clipboard, incoming: true, text: text);
      case NotificationReceived(:final from, :final title):
        _addLocal(from.id, ActivityKind.ping, incoming: true, text: title);
      case SessionStarted(:final session, :final peer, :final kind)
          when e.sharing && kind != SessionKind.display:
        sharing[session] = e;
        LinksyPlatform.startShare(session, kind.name, peer.name, peer.id);
        _addSession(e);
      case SessionStarted(:final session, kind: SessionKind.display)
          when !e.sharing:
        displays[session] = e;
        LinksyPlatform.keepScreenOn(session, on: true);
        _addSession(e);
      case SessionEnded(:final session):
        if (remotes.containsValue(session)) {
          remotes.removeWhere((_, s) => s == session);
          notifyListeners();
        }
        // Whichever side ended it, the timeline says it's over.
        _update(session, (a) {
          if (a.isLive) a.status = ActivityStatus.done;
        });
        if (sharing.remove(session) != null) {
          LinksyPlatform.stopShare(session);
          _update(session, (a) => a.status = ActivityStatus.done);
        }
        if (displays.remove(session) != null) {
          LinksyPlatform.keepScreenOn(session, on: false);
          _update(session, (a) => a.status = ActivityStatus.done);
        }
      case PairingRequest() ||
          PairingFailed() ||
          SessionRequest() ||
          SessionStarted():
        break;
    }
    switch (e) {
      case PairingRequest() ||
          PairingFailed() ||
          SessionRequest() ||
          Paired() ||
          TransferRequest() ||
          NotificationReceived() ||
          ClipboardFileReceived() ||
          OpenUrlReceived():
        _prompts.add(e);
      // Each change of a watched clipboard would be a snack bar too many.
      case ClipboardReceived(:final from) when !_clipWatching.contains(from.id):
        _prompts.add(e);
      // The webcam's controls, when a computer starts using the camera.
      case SessionStarted(kind: SessionKind.camera) when e.sharing:
        _prompts.add(e);
      // The full-screen page for a second display or a computer's screen.
      case SessionStarted(:final kind)
          when !e.sharing && kind != SessionKind.input:
        _prompts.add(e);
      default:
        break;
    }
  }

  void _startRinging(DeviceInfo from) {
    final already = ringingFrom != null;
    ringingFrom = from;
    _ringTimer?.cancel();
    _ringTimer = Timer(ringFor, stopRinging);
    if (!already) {
      LinksyPlatform.startRing();
      _addLocal(from.id, ActivityKind.ring, incoming: true);
      // The full-screen "Found it".
      _prompts.add(RingRequested(from: from, on: true));
    }
    notifyListeners();
  }

  /// "Found it", `ring_stop`, or 30 seconds.
  void stopRinging() {
    _ringTimer?.cancel();
    _ringTimer = null;
    if (ringingFrom == null) return;
    ringingFrom = null;
    LinksyPlatform.stopRing();
    notifyListeners();
  }

  void _addSession(SessionStarted e) => _add(
    Activity(
      id: e.session,
      deviceId: e.peer.id,
      kind: switch (e.kind) {
        _ when !e.sharing && e.kind != SessionKind.display =>
          ActivityKind.watch,
        SessionKind.screen => ActivityKind.screen,
        SessionKind.camera => ActivityKind.camera,
        SessionKind.control => ActivityKind.control,
        SessionKind.display => ActivityKind.display,
        SessionKind.input => ActivityKind.remote,
        SessionKind.microphone => ActivityKind.microphone,
      },
      // Video coming in: a second display, or a computer's screen watched.
      incoming: !e.sharing && e.kind != SessionKind.input,
      time: DateTime.now(),
      status: ActivityStatus.active,
    ),
  );

  double _speed(String transfer, int bytes, double previous) {
    final now = DateTime.now();
    final last = _lastSample[transfer];
    _lastSample[transfer] = (now, bytes);
    if (last == null) return previous;
    final seconds = now.difference(last.$1).inMicroseconds / 1e6;
    if (seconds <= 0) return previous;
    final instant = (bytes - last.$2) / seconds;
    return previous == 0 ? instant : previous * 0.7 + instant * 0.3;
  }

  void _add(Activity a) {
    _activity.insert(0, a);
    if (_activity.length > ActivityStore.maxEntries) _activity.removeLast();
    _changed();
    if (a.kind == ActivityKind.files) _updateKeepAlive();
  }

  void _addLocal(
    String deviceId,
    ActivityKind kind, {
    required bool incoming,
    String? text,
    ActivityStatus status = ActivityStatus.done,
    String? reason,
  }) {
    _add(
      Activity(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        deviceId: deviceId,
        kind: kind,
        incoming: incoming,
        time: DateTime.now(),
        status: status,
        text: text,
        reason: reason,
      ),
    );
  }

  void _update(String id, void Function(Activity) change, {bool save = true}) {
    final a = _activity.where((a) => a.id == id).firstOrNull;
    if (a == null) return;
    final live = a.isLive;
    change(a);
    save ? _changed() : notifyListeners();
    if (a.kind == ActivityKind.files && (live || a.isLive)) _updateKeepAlive();
  }

  void _changed() {
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _store.save(_activity);
    });
  }

  // Actions. Each returns an error message to show, or null.

  static int _sizeOf(String path) {
    try {
      return File(path).lengthSync();
    } on FileSystemException {
      return 0;
    }
  }

  /// File transfers going now, on every device, newest first.
  List<Activity> get liveTransfers => [
    for (final a in _activity)
      if (a.kind == ActivityKind.files && a.isLive) a,
  ];

  /// File transfers that ended, on every device, newest first.
  List<Activity> get recentTransfers => [
    for (final a in _activity)
      if (a.kind == ActivityKind.files && !a.isLive) a,
  ].take(20).toList();

  Future<String?> sendFiles(String deviceId, List<String> paths) async {
    if (paths.isEmpty) return null;
    LinksyPlatform.sharedTo(deviceId);
    try {
      final transfer = await node.sendFiles(deviceId, paths);
      // Progress events can race the return; only add if not seen yet.
      if (_activity.every((a) => a.id != transfer)) {
        _add(
          Activity(
            id: transfer,
            deviceId: deviceId,
            kind: ActivityKind.files,
            incoming: false,
            time: DateTime.now(),
            status: ActivityStatus.waiting,
            names: [for (final p in paths) p.split('/').last],
            sizes: [for (final p in paths) _sizeOf(p)],
          ),
        );
      }
      return null;
    } on LinksyException catch (e) {
      return e.message;
    }
  }

  Future<String?> sendClipboard(String deviceId) async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isEmpty) return tr.ctlClipboardEmpty;
    if (utf8.encode(text).length > maxClipboardBytes) {
      return tr.ctlClipboardTooMuch;
    }
    return _run(() async {
      await node.sendClipboard(deviceId, text);
      _addLocal(deviceId, ActivityKind.clipboard, incoming: false, text: text);
    });
  }

  Future<String?> ping(String deviceId) => _run(() async {
    await node.notify(deviceId, tr.ctlPing, tr.ctlPingFrom(node.info.name));
    _addLocal(deviceId, ActivityKind.ping, incoming: false, text: tr.ctlPing);
  });

  /// "Find my computer": makes it ring until [stopFinding].
  Future<String?> find(String deviceId) => _run(() async {
    await node.ring(deviceId, on: true);
    _finding.remove(deviceId)?.cancel();
    _finding[deviceId] = Timer(ringFor, () {
      _finding.remove(deviceId);
      notifyListeners();
    });
    _addLocal(deviceId, ActivityKind.ring, incoming: false);
  });

  Future<String?> stopFinding(String deviceId) => _run(() async {
    _finding.remove(deviceId)?.cancel();
    notifyListeners();
    await node.ring(deviceId, on: false);
  });

  /// "Open on PC": the computer opens [url] in its browser.
  Future<String?> openUrl(String deviceId, String url) => _run(() async {
    await node.openUrl(deviceId, url);
    _addLocal(deviceId, ActivityKind.link, incoming: false, text: url);
  });

  /// Text shared from another app, to [deviceId]'s clipboard.
  Future<String?> sendText(String deviceId, String text) async {
    if (utf8.encode(text).length > maxClipboardBytes) {
      return tr.ctlTextTooMuch;
    }
    return _run(() async {
      await node.sendClipboard(deviceId, text);
      _addLocal(deviceId, ActivityKind.clipboard, incoming: false, text: text);
    });
  }

  Future<String?> cancel(String transfer) => _run(() => node.cancel(transfer));

  Future<String?> respond(String request, {required bool accept}) async {
    LinksyPlatform.cancelNotice(request);
    final error = await _run(() => node.respond(request, accept: accept));
    if (!accept) {
      _update(request, (a) {
        a
          ..status = ActivityStatus.declined
          ..reason = tr.ctlDeclined;
      });
    }
    return error;
  }

  /// Answers "X wants to see your screen / use your camera / …". Allowing
  /// also needs Android's own consent: screen capture (screen, control) or
  /// the camera permission. A second display needs nothing more.
  Future<String?> respondSession(
    SessionRequest request, {
    required bool accept,
  }) async {
    var allowed = accept;
    String? error;
    if (accept) {
      switch (request.kind) {
        case SessionKind.screen || SessionKind.control:
          allowed = await LinksyPlatform.requestScreenCapture(request.request);
          if (!allowed) {
            error = tr.ctlScreenPermission;
          }
        case SessionKind.camera:
          allowed = await LinksyPlatform.requestCamera();
          if (!allowed) {
            error = tr.ctlCameraPermission;
          }
        case SessionKind.microphone:
          allowed = await LinksyPlatform.requestPermission('microphone');
          if (!allowed) {
            error = tr.ctlMicrophonePermission;
          }
        case SessionKind.display:
          // The monitor in this phone's shape (§4.8).
          final size = await LinksyPlatform.screenSize();
          if (size != null) {
            await node.respondDisplay(
              request.request,
              accept: true,
              width: size.$1,
              height: size.$2,
            );
            return null;
          }
        case SessionKind.input:
          break;
      }
    }
    await node.respond(request.request, accept: allowed);
    return error;
  }

  /// Watch [id]'s screen ([control]: and use its mouse and keyboard). The
  /// screen opens full screen once its user picks what to share there.
  Future<String?> watchScreen(String id, {required bool control}) =>
      _run(() => node.startView(id, control: control));

  /// Choose Screen on a computer's screen viewer: ends [session] and asks
  /// [id] again, its user picking the screen anew (docs/protocol.md §4.8).
  Future<String?> chooseScreen(
    String session,
    String id, {
    required bool control,
  }) async {
    await stopDisplay(session);
    return _run(() => node.startView(id, control: control, choose: true));
  }

  /// Front ↔ back camera while this phone is a webcam.
  Future<void> switchCamera(String session) =>
      LinksyPlatform.switchCamera(session);

  /// Leaves a second display (back from its full-screen page).
  Future<void> stopDisplay(String session) async {
    await LinksyPlatform.keepScreenOn(session, on: false);
    await LinksyPlatform.stopDisplay(session);
    await node.endSession(session);
  }

  /// The Stop button: ends sharing into [session].
  Future<void> stopSharing(String session) async {
    await LinksyPlatform.stopShare(session);
    await node.endSession(session);
  }

  Future<String?> pair(String deviceId) =>
      _run(() => node.pairDevice(deviceId));

  Future<String?> pairAddress(String address) {
    final withPort = address.contains(RegExp(r':\d+$'))
        ? address
        : '$address:$defaultPort';
    return _run(() => node.pairAddress(withPort));
  }

  Future<String?> pairWithInvite(String uri) =>
      _run(() => node.pairWithInvite(uri));

  /// Choose [deviceId]'s picture from the phone's photos. False if cancelled.
  Future<bool> pickPicture(String deviceId) async {
    final path = await LinksyPlatform.pickPicture(deviceId);
    if (path == null) return false;
    await FileImage(File(path)).evict();
    pictures[deviceId] = path;
    pictureVersion++;
    notifyListeners();
    return true;
  }

  Future<void> removePicture(String deviceId) async {
    final path = pictures.remove(deviceId);
    if (path != null) await FileImage(File(path)).evict();
    pictureVersion++;
    notifyListeners();
    await LinksyPlatform.removePicture(deviceId);
  }

  Future<String?> forget(String deviceId) async {
    if (pictures.containsKey(deviceId)) await removePicture(deviceId);
    final error = await _run(() => node.forget(deviceId));
    _activity.removeWhere((a) => a.deviceId == deviceId);
    _changed();
    // The core announces no event for this: read the list again.
    await refresh();
    return error;
  }

  Future<String?> updateSettings(NodeSettings s) =>
      _run(() => node.updateSettings(s));

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on LinksyException catch (e) {
      return e.message;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _batterySub?.cancel();
    _callSub?.cancel();
    _answerSub?.cancel();
    _directSub?.cancel();
    _networkSub?.cancel();
    log.dispose();
    _mediaActionSub?.cancel();
    LinksyPlatform.mediaNotice(null);
    _usbSub?.cancel();
    _logSub?.cancel();
    updates.dispose();
    _usbNews.close();
    WidgetsBinding.instance.removeObserver(this);
    _importTimer?.cancel();
    _ringTimer?.cancel();
    for (final t in _finding.values) {
      t.cancel();
    }
    _saveTimer?.cancel();
    _store.save(_activity);
    _prompts.close();
    super.dispose();
  }
}

sealed class UsbNews {
  const UsbNews();
}

/// The bridge is up: dialing the computer through the cable.
class UsbDialing extends UsbNews {
  const UsbDialing();
}

/// Connected to [name] ([id], when it's listed) through the cable.
class UsbConnected extends UsbNews {
  const UsbConnected(this.name, this.id);
  final String name;
  final String? id;
}

/// Nothing paired answered at [address]: offer to pair through it.
class UsbPairOffer extends UsbNews {
  const UsbPairOffer(this.address);
  final String address;
}

/// How far a direct link got: finding the computer, connecting to it, the
/// link coming up over the new network, and up.
enum DirectStage { find, connect, link, up }
