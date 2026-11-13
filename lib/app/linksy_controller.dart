import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../core/deck.dart';
import '../core/deck_layouts.dart';
import '../core/linksy_node.dart';
import 'app_log.dart';
import '../core/models.dart';
import '../core/service_info.dart';
import '../features/phones/selection.dart';
import 'app_update.dart';
import '../ui/format.dart';
import '../ui/l10n.dart';
import 'activity.dart';
import 'network_state.dart';
import 'platform.dart';
import 'resume.dart';
import 'terminals.dart';

/// The Inbox is on by default since 0.3.4; until then the switch was off
/// unless turned on, so no pref with Android's access already given means it
/// was turned off. What to write, once.
Map<String, String> inboxDefaultPrefs(
  Map<String, String> prefs, {
  required bool access,
}) => {
  if (prefs['inbox_default'] == null) ...{
    'inbox_default': 'done',
    if (prefs['phone_notifications'] == null && access)
      'phone_notifications': 'off',
  },
};

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
       _decks = dir == null ? null : Directory('${dir.path}/decks'),
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

  /// The deck layouts each computer sent last (§4.20), by device.
  final Directory? _decks;
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

  /// Where received files go, when it isn't Downloads › Linksy.
  String? saveFolder;

  /// Photo imports going out: transfer → (device, newest photo time, more).
  final Map<String, (String, int, bool)> _imports = {};
  bool _importing = false;
  Timer? _importTimer;
  StreamSubscription<String>? _callSub;
  StreamSubscription<Map<String, Object?>>? _noticeSub;
  StreamSubscription<(String, bool)>? _noticeGoneSub;
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

  /// Fewer animations, as when the phone's own are off; the app rebuilds
  /// when it changes.
  final reduceMotion = ValueNotifier<bool>(false);

  Future<void> setReduceMotion(bool on) async {
    reduceMotion.value = on;
    await _setPref('motion', on ? 'less' : null);
  }

  /// The first-run setup (language, then what Linksy may do) is done.
  bool get onboarded => prefs['onboarded'] == '1';

  Future<void> finishOnboarding() async {
    await _setPref('onboarded', '1');
    // The setup page just offered what the home card would.
    await _setPref('turn_on_card', 'done');
  }

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

  /// What's copied goes to connected computers while Linksy is open. Off
  /// until asked for: what's copied can be a password, and Android says so
  /// with a toast each time it's read.
  bool get sendsCopied => prefs['send_copied'] == 'on';

  /// The last text seen on either side, so it isn't sent back or sent twice.
  String? _lastCopied;

  Future<void> setSendsCopied(bool on) async {
    await setPref('send_copied', on ? 'on' : 'off');
    // What's there already isn't news.
    if (on) _lastCopied = await _copiedNow();
    notifyListeners();
  }

  Future<String> _copiedNow() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';

  Future<void> _sendCopied() async {
    if (!sendsCopied) return;
    // Android lets the app read it once it has the focus.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final text = await _copiedNow();
    final last = _lastCopied;
    _lastCopied = text;
    if (last == null || text.isEmpty || text == last) return;
    for (final v in devices) {
      if (v.trusted && v.reachable && _isComputer(v.device)) {
        await sendText(v.device.id, text);
      }
    }
  }

  /// A picture just taken, for [id]: as a file, and on its clipboard when it
  /// takes one, ready to paste.
  Future<String?> snap(String id, String path) async {
    final error = await sendFiles(id, [path]);
    if (error != null) return error;
    final view = device(id);
    final file = File(path);
    if (!(view?.device.features.contains('clipboard_file') ?? false) ||
        !file.existsSync()) {
      return null;
    }
    // At most 10 MiB on a clipboard: a smaller copy of a bigger one (§4.23).
    final copy = file.lengthSync() <= 10 * 1024 * 1024
        ? path
        : await LinksyPlatform.shrinkPicture(path);
    if (copy != null) await _run(() => node.sendClipboardFile(id, copy));
    return null;
  }

  // This phone's controls for a computer (§4.24).

  final _controlWatchers = <String>{};
  Timer? _controlsSoon;
  StreamSubscription<void>? _controlsSub;

  /// Android lets a computer change Do Not Disturb here.
  bool dndAccess = false;

  Future<void> _sendControls(Iterable<String> to) async {
    final state = await LinksyPlatform.controlsRead();
    if (state == null) return;
    final json = jsonEncode({
      'seq': DateTime.now().millisecondsSinceEpoch,
      ...state,
    });
    for (final id in to) {
      node.sendControlsState(id, json).catchError((Object _) {});
    }
  }

  /// At most four a second while a level moves.
  void _controlsMoved() {
    if (_controlWatchers.isEmpty || _controlsSoon != null) return;
    _controlsSoon = Timer(const Duration(milliseconds: 250), () {
      _controlsSoon = null;
      unawaited(_sendControls(_controlWatchers.toList()));
    });
  }

  Future<void> _watchControls(String id, {required bool on}) async {
    if (on) {
      _controlWatchers.add(id);
      await _sendControls([id]);
    } else {
      _controlWatchers.remove(id);
    }
    await LinksyPlatform.controlsWatch(on: _controlWatchers.isNotEmpty);
  }

  Future<void> _setControls(
    DeviceInfo from,
    Map<String, Object?> change,
  ) async {
    final refused = await LinksyPlatform.controlsSet(change);
    for (final MapEntry(key: what, value: why) in refused.entries) {
      await node
          .refuseControls(from.id, what, switch (why) {
            'dnd' => tr.controlsNoDnd,
            'flashlight' => tr.controlsNoFlashlight,
            _ => tr.controlsDenied,
          })
          .catchError((Object _) {});
    }
    _controlsMoved();
  }

  Future<void> refreshDndAccess() async {
    final now = await LinksyPlatform.dndAccess();
    if (now == dndAccess) return;
    dndAccess = now;
    notifyListeners();
    _controlsMoved();
  }

  // What's announced because of a choice here.

  /// This phone shows a computer's notifications (off until asked for).
  bool get computerNotifications => prefs['computer_notifications'] == 'on';

  Future<void> setComputerNotifications(bool on) async {
    await _setPref('computer_notifications', on ? 'on' : null);
    await _announce();
    notifyListeners();
  }

  /// A computer's snap: the camera is allowed here.
  bool _cameraAllowed = false;

  Future<void> _readCamera() async {
    final now = (await LinksyPlatform.permissions())?.camera ?? false;
    if (now == _cameraAllowed) return;
    _cameraAllowed = now;
    await _announce();
  }

  Future<void> _snapAsked(DeviceInfo from) async {
    await _readCamera();
    if (!_cameraAllowed) {
      await node.refuseSnap(from.id, tr.snapNoCamera).catchError((Object _) {});
    } else if (_onScreen) {
      await LinksyPlatform.snap(from.id);
    } else {
      await LinksyPlatform.snapNotice(from.id, tr.snapAsked(from.name));
    }
  }

  // The phone's sound with its screen (§4.8).

  /// Yes by itself while its screen is shared and the microphone permission
  /// (which Android wants for this) is there: the screen's projection is what
  /// it records through, so with no screen there's nothing to give.
  Future<void> _answerSound(SessionRequest request) async {
    bool sharingTo() => sharing.values.any(
      (s) =>
          s.peer.id == request.from.id &&
          (s.kind == SessionKind.screen || s.kind == SessionKind.control),
    );
    // It comes right after the screen, which may still be starting.
    for (var i = 0; i < 12 && !sharingTo(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    final yes =
        sharingTo() && await LinksyPlatform.requestPermission('microphone');
    await node.respond(request.request, accept: yes).catchError((Object _) {});
  }

  // Taps in landscape over the cable (§4.11).

  /// Only where taps from a computer land turned a quarter: Android may
  /// already turn them, which needs a look on a real phone.
  bool get turnsTaps => prefs['turn_taps'] == 'on';
  Future<void> setTurnsTaps(bool on) async {
    await _setPref('turn_taps', on ? 'on' : null);
    notifyListeners();
  }

  void _onRotation((String, int) turned) {
    final (session, degrees) = turned;
    final share = sharing[session];
    if (!turnsTaps || share == null || share.kind != SessionKind.control) {
      return;
    }
    node.sendScreenRotation(share.peer.id, degrees).catchError((Object _) {});
  }

  /// The computers saying what's plugged into them.
  final _plugged = <String, List<PluggedPhone>>{};
  bool _onUsbHost = false;
  (String, String) _model = ('', '');

  Future<void> _readUsbHost() async {
    final now = await LinksyPlatform.usbPlugged();
    if (_model.$1.isEmpty) _model = await LinksyPlatform.phoneModel();
    if (now == _onUsbHost) return;
    _onUsbHost = now;
    notifyListeners();
  }

  /// The plugged-in phone to ask [id] to use the cable for, if this one is
  /// plugged in and not on the cable yet (§4.11).
  String? usbOffer(String id) {
    if (!_onUsbHost || (device(id)?.usb ?? false)) return null;
    return usbKeyFor(_plugged[id] ?? const [], _model.$1, _model.$2);
  }

  Future<String?> connectUsb(String id, String key) =>
      _run(() => node.usbConnect(id, key));

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

  /// Start When the Phone Starts (mobile#23): the user's choice, else on once
  /// a computer is paired. Android reads both prefs at boot (Boot.kt).
  bool get startAtBoot => switch (prefs['start_at_boot']) {
    'on' => true,
    'off' => false,
    _ => _hasComputer,
  };

  bool get _hasComputer =>
      devices.any((v) => v.trusted && _isComputer(v.device));

  Future<void> setStartAtBoot(bool on) =>
      _setPref('start_at_boot', on ? 'on' : 'off');

  /// Keeps Android's copy of "a computer is paired" for the boot default.
  void _noteComputer() {
    final has = _hasComputer ? 'yes' : null;
    if (prefs['has_computer'] != has) unawaited(_setPref('has_computer', has));
  }

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
    _noticeSub = LinksyPlatform.phoneNotifications.listen(_onPhoneNotification);
    _preflightSub = node.preflightCalls.listen(_onPreflight);
    _installSub = LinksyPlatform.appInstalls.listen(_onAppInstall);
    _noticeGoneSub = LinksyPlatform.phoneNotificationsGone.listen(
      _onPhoneNotificationGone,
    );
    _answerSub = LinksyPlatform.transferAnswers.listen(
      (a) => respond(a.$1, accept: a.$2),
    );
    // Wi-Fi came or went, mobile data took over: the core checks its links.
    // Only then: it drops the ones that don't answer within 2 s, and Android
    // reports much that no link notices (NetworkState).
    _networkSub = LinksyPlatform.networkChanges.listen((snapshot) {
      final what = networks.update(snapshot);
      if (what == null) return;
      log.add('Networks changed: $what');
      _endLeftRemotes();
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
        for (final id in _computers) {
          _tellBattery(id, always: true);
        }
      }),
    );
  }

  // Phone to phone (docs/protocol.md §4.22).

  /// The way each transfer goes, while it does.
  StreamSubscription<PreflightCall>? _preflightSub;
  StreamSubscription<(String?, String)>? _installSub;

  final _routes = <String, TransferRouted>{};
  TransferRouted? routeOf(String transfer) => _routes[transfer];

  /// The apps among each transfer that's going on: their files don't belong
  /// in Downloads.
  final _transferApps = <String, List<AppInfo>>{};

  /// Apps that arrived, for the user to install or not.
  final pendingApps = <AppsReceived>[];

  /// Asked about already: one sheet each.
  final _offeredApps = <String>{};

  SendPlan? planSend(String id, int bytes) => node.planSend(id, bytes);
  Future<SendPlan?> prepareSend(String id, int bytes) =>
      node.prepareSend(id, bytes);
  Future<PreflightReply?> preflight(
    String id,
    int bytes,
    int files,
    List<AppProbe> probes,
  ) => node.preflight(id, bytes, files, probes);

  /// Everything chosen as one offer, so the other phone asks once: several
  /// only past what an offer holds, and those are asked about together.
  Future<String?> sendSelection(String deviceId, SendSelection chosen) async {
    final batches = sendBatches(chosen.paths);
    final apps = [for (final a in chosen.apps) a.bundle];
    final sizes = {
      for (final m in chosen.media) m.path: m.size,
      for (final f in chosen.files) f.path: f.size,
    };
    LinksyPlatform.sharedTo(deviceId);
    try {
      for (var i = 0; i < math.max(batches.length, 1); i++) {
        final paths = i < batches.length ? batches[i] : const <String>[];
        final with_ = i == 0 ? chosen.apps.toList() : const <PhoneApp>[];
        final transfer = await node.sendBundle(
          deviceId,
          paths,
          i == 0 ? apps : const [],
        );
        // Apps aren't offered again: their folders are named for the offer.
        if (i > 0 || apps.isEmpty) _sends[transfer] = (deviceId, paths);
        if (_activity.every((a) => a.id != transfer)) {
          _add(
            Activity(
              id: transfer,
              deviceId: deviceId,
              kind: ActivityKind.files,
              incoming: false,
              time: DateTime.now(),
              status: ActivityStatus.waiting,
              names: [
                for (final p in paths) p.split('/').last,
                for (final a in with_) a.label,
              ],
              sizes: [
                for (final p in paths) sizes[p] ?? 0,
                for (final a in with_) a.size,
              ],
              thumbs: [for (final m in chosen.media.take(3)) m.path],
              packages: {for (final a in with_) a.label: a.package},
            ),
          );
        }
      }
      return null;
    } on LinksyException catch (e) {
      return e.message;
    }
  }

  /// Android's photo permission, without turning on the Gallery for computers.
  Future<void> allowPhotos() async {
    await LinksyPlatform.requestPermission('photos');
    await _refreshGallery();
    notifyListeners();
  }

  /// A note goes to the clipboard there; a link opens there.
  Future<String?> sendNote(String deviceId, String text) {
    final note = text.trim();
    final uri = Uri.tryParse(note);
    final link =
        uri?.isScheme('https') == true || uri?.isScheme('http') == true;
    return link && !note.contains(' ')
        ? openUrl(deviceId, note)
        : sendText(deviceId, note);
  }

  /// Asks where it is; the answer comes as an event.
  Future<String?> locate(String deviceId) => _run(() async {
    await node.locate(deviceId);
    _addLocal(deviceId, ActivityKind.locate, incoming: false);
  });

  /// Answers another device: what only this phone knows, quickly.
  Future<void> _onPreflight(PreflightCall call) async {
    node.answerPreflight(
      call.call,
      await LinksyPlatform.preflightFacts(call.probes),
    );
  }

  /// [files] as a person reads them: an app is its name, not its APKs.
  (List<String>, List<int>) _offered(
    List<OfferedFile> files,
    List<AppInfo> apps,
  ) {
    bool inApp(OfferedFile f, AppInfo a) => f.path.startsWith('${a.dir}/');
    final plain = files.where((f) => !apps.any((a) => inApp(f, a)));
    return (
      [for (final f in plain) f.name, for (final a in apps) a.label],
      [
        for (final f in plain) f.size,
        for (final a in apps)
          files.where((f) => inApp(f, a)).fold(0, (n, f) => n + f.size),
      ],
    );
  }

  /// What's being installed, for saying how it went: its name and whose it was.
  final _installing = <String, (String, String)>{};

  void _onAppInstall((String?, String) outcome) {
    final (package, status) = outcome;
    final what = _installing.remove(package);
    if (what == null) return;
    _prompts.add(AppInstalled(label: what.$1, from: what.$2, status: status));
  }

  /// Shows what's waiting to be installed, once each.
  void _offerApps() {
    for (final e in pendingApps) {
      if (_offeredApps.add(e.transfer)) _prompts.add(e);
    }
  }

  /// The user answered: installs [apps] of [offer], or with none lets go of
  /// its files.
  Future<void> finishApps(AppsReceived offer, {required bool install}) async {
    pendingApps.remove(offer);
    notifyListeners();
    if (install) {
      for (final a in offer.apps) {
        _installing[a.info.package] = (a.info.label, offer.from.name);
      }
      await LinksyPlatform.installApps([
        for (final a in offer.apps)
          {
            'package': a.info.package,
            'version_code': a.info.versionCode,
            'signer': a.info.signer,
            'apks': a.apks,
          },
      ]);
    } else {
      await LinksyPlatform.deleteFiles([for (final a in offer.apps) ...a.apks]);
    }
  }

  /// Files the core finished while Flutter wasn't there to move them, as when
  /// Linksy was swiped away but kept running. Not while files are arriving:
  /// those are moved as they finish.
  Future<void> _moveLeftovers() async {
    if (_transferApps.isNotEmpty ||
        _activity.any((a) => a.incoming && a.status == ActivityStatus.active)) {
      return;
    }
    final moved = await LinksyPlatform.publishLeftovers([
      for (final a in _activity) ...a.saved,
      for (final e in pendingApps)
        for (final a in e.apps) ...a.apks,
    ]);
    if (moved.isNotEmpty) {
      log.add('Moved ${moved.length} file(s) that arrived with Linksy closed');
    }
  }

  /// Linksy is what the phone shows; else what comes in needs a notification.
  bool get _onScreen =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  /// Back in the app: new photos may be waiting, and maybe a new release.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _watchMemory(idle: false);
      _importAll();
      unawaited(_sendCopied());
      unawaited(_readCamera());
      unawaited(refreshDndAccess());
      unawaited(_readUsbHost());
      unawaited(updates.recheck());
      // Back from Notification access or App info, maybe.
      unawaited(refreshNotificationAccess());
      unawaited(_refreshGallery());
      unawaited(_moveLeftovers());
      _offerApps();
      // Back from Developer options, maybe.
      _readShareProtections();
    } else if (state == AppLifecycleState.hidden) {
      _endLeftRemotes();
      _watchMemory(idle: true);
      // Out of sight: decoded pictures go, they're read again on return.
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    }
  }

  /// Idle memory (mobile#3) in the log: a minute after Linksy leaves the
  /// screen, or starts without one (with the phone), then every half hour
  /// until it's back. The log people share then says what it took.
  Timer? _memoryTimer;

  void _watchMemory({required bool idle}) {
    _memoryTimer?.cancel();
    _memoryTimer = null;
    if (!idle) return;
    _memoryTimer = Timer(const Duration(minutes: 1), () {
      unawaited(_logMemory());
      _memoryTimer = Timer.periodic(
        const Duration(minutes: 30),
        (_) => unawaited(_logMemory()),
      );
    });
  }

  Future<void> _logMemory() async {
    final line = await LinksyPlatform.memory().catchError((Object _) => null);
    if (line != null) log.add('Memory, idle: $line');
  }

  /// Android-side settings and folders; not awaited by [start] (tests have
  /// no Android side).
  Future<void> _loadPlatform() async {
    prefs = await LinksyPlatform.prefs();
    _noteComputer();
    // Started with the phone: no screen, so idle from the start.
    if (Platform.isAndroid && !_onScreen) _watchMemory(idle: true);
    locale.value = resolveLocale(languageCode);
    useLocale(locale.value);
    themeMode.value = themeFrom(prefs['theme']);
    reduceMotion.value = prefs['motion'] == 'less';
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
    saveFolder = await LinksyPlatform.folder('received');
    allFiles = await LinksyPlatform.allFilesState();
    await LinksyPlatform.shareFiles(sharingFiles && filesReady, all: filesAll);
    await LinksyPlatform.watchCalls(pauseOnCalls);
    await refreshNotificationAccess();
    await _refreshGallery();
    _accessRead.complete();
    unawaited(_moveLeftovers());
    final phone = await LinksyPlatform.phoneMaker();
    maker = phone.maker;
    sdk = phone.sdk;
    _updateKeepAlive();
    notifyListeners();
    addListener(_shareTargets);
    _shareTargets();
    _usbSub = LinksyPlatform.usbPorts.listen(_onUsb);
    _controlsSub = LinksyPlatform.controlsChanges.listen(
      (_) => _controlsMoved(),
    );
    LinksyPlatform.screenRotations.listen(_onRotation);
    unawaited(_readCamera());
    unawaited(refreshDndAccess());
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
        // Carried on: some of it came before, or was there already.
        final speed = _resumeTries.containsKey(transfer)
            ? ', carried on'
            : s > 0 && total > 0
            ? ', ${formatBytes(total ~/ s)}/s'
            : '';
        log.add('Transfer with $name done in ${s.toStringAsFixed(1)} s$speed');
      case TransferFailed(:final transfer, :final reason)
          when _canResume(transfer, reason):
        final name = _logged.remove(transfer)?.$1 ?? '?';
        log.add(
          'Transfer with $name interrupted ($reason), continuing once it\'s back',
        );
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

  /// How far the pointer goes for the same swipe on the touchpad, 0.5–2×.
  double get pointerSpeed =>
      (double.tryParse(prefs['pointer_speed'] ?? '') ?? 1).clamp(0.5, 2.0);
  Future<void> setPointerSpeed(double speed) => _setPref(
    'pointer_speed',
    (speed - 1).abs() < 0.01 ? null : speed.toStringAsFixed(2),
  );

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
    for (final id in _computers) {
      _dialing(id, () => node.sendCallState(id, state));
    }
  }

  // This phone's notifications on its computers (§4.5).

  /// On unless turned off; they go once Android allows [notificationAccess].
  bool get phoneNotifications => prefs['phone_notifications'] != 'off';

  /// Turned on here, and Android hasn't allowed it yet.
  bool get notificationAccessMissing =>
      prefs['phone_notifications'] == 'on' && !notificationAccess;

  /// Android lets Linksy read notifications (Notification access).
  bool notificationAccess = false;

  /// Who made this phone (`Build.MANUFACTURER`) and its Android API level,
  /// for the battery guide and the Notification access steps.
  String maker = '';
  int sdk = 0;

  /// Both: notifications go to the computers.
  bool get mirroring => phoneNotifications && notificationAccess;

  /// Android's page for Notification access was opened once already: next
  /// time, the steps for a switch Android greys out come first.
  bool get notificationAccessAsked => prefs['notification_asked'] == 'on';

  Future<void> setPhoneNotifications(bool on) async {
    await _setPref('phone_notifications', on ? 'on' : 'off');
    // Turned off: the conversations kept for the computers go too.
    if (!on) await LinksyPlatform.forgetInbox();
    await _mirror();
  }

  /// Opens Android's Notification access page; whether it's allowed now.
  Future<bool> askNotificationAccess() async {
    await _setPref('notification_asked', 'on');
    notificationAccess = await LinksyPlatform.askNotificationAccess();
    await _mirror();
    notifyListeners();
    return notificationAccess;
  }

  /// Again, after Android's settings (it can be taken back there too).
  Future<void> refreshNotificationAccess() async {
    final access = await LinksyPlatform.notificationAccess();
    final changed = access != notificationAccess;
    notificationAccess = access;
    await _mirror();
    if (changed) notifyListeners();
  }

  /// Whether notifications go, to the listener and to the computers: they
  /// show their Inbox while this phone announces `notifications` (and scroll
  /// back with `inbox_history`).
  Future<void> _mirror() async {
    await LinksyPlatform.mirrorNotifications(mirroring);
    await _announce();
  }

  /// What this phone can do that comes and goes (§4.10), told to the
  /// computers whenever it changes.
  Future<void> _announce() async {
    await node.setFeatures(_features).catchError((Object _) {});
    if (mirroring && gallery && prefs['turn_on_card'] == null) {
      await _setPref('turn_on_card', 'done');
    }
  }

  List<String> get _features {
    const changing = {
      'notifications',
      'inbox_history',
      'gallery',
      'snap',
      'sound',
      'computer_notifications',
    };
    return [
      ...node.info.features.where((f) => !changing.contains(f)),
      if (mirroring) ...['notifications', 'inbox_history'],
      if (gallery) 'gallery',
      if (_cameraAllowed) 'snap',
      // AudioPlaybackCapture is Android 10.
      if (sdk >= 29) 'sound',
      if (computerNotifications) 'computer_notifications',
    ];
  }

  /// The same list again, for a computer that missed it. The core only tells
  /// a list that changed, and the order means nothing: backwards, then back.
  Future<void> _announceAgain() async {
    final features = _features;
    await node
        .setFeatures(features.reversed.toList())
        .catchError((Object _) {});
    await node.setFeatures(features).catchError((Object _) {});
  }

  /// Android's answers about notifications and photos are in.
  final _accessRead = Completer<void>();
  Future<void> get accessRead => _accessRead.future;

  /// The home card for people updating, who never saw the setup page's rows
  /// for these: until it's dismissed, or both are on.
  bool get turnOnCard =>
      _accessRead.isCompleted &&
      onboarded &&
      prefs['turn_on_card'] == null &&
      !(mirroring && gallery);

  Future<void> dismissTurnOnCard() => _setPref('turn_on_card', 'done');

  /// What Android allows now. A computer's ask, or the tap on its
  /// notification, can come before the check on coming back to the app.
  Future<void> refreshAccess() async {
    await refreshNotificationAccess();
    await _refreshGallery();
  }

  /// Whether what a computer's tab needs is on here: `notifications` or
  /// `gallery`. Null: not something this phone knows.
  bool? isTurnedOn(String feature) => switch (feature) {
    'notifications' => mirroring,
    'gallery' => gallery,
    _ => null,
  };

  /// When each computer last asked for each feature, to ask the user at most
  /// once a minute.
  final _turnOnAsked = <(String, String), DateTime>{};

  /// A computer asks (its "Ask the Phone"): already on, it only missed the
  /// news; else the user decides, here or from a notification.
  Future<void> _onTurnOnRequest(TurnOnRequested e) async {
    if (isTurnedOn(e.feature) == null) return;
    if (device(e.from.id)?.trusted != true) return;
    await refreshAccess();
    if (isTurnedOn(e.feature) == true) {
      await _announceAgain();
      return;
    }
    final key = (e.from.id, e.feature);
    final now = DateTime.now();
    final last = _turnOnAsked[key];
    if (last != null && now.difference(last) < const Duration(minutes: 1)) {
      return;
    }
    _turnOnAsked[key] = now;
    if (_onScreen) {
      _prompts.add(e);
      return;
    }
    final messages = e.feature == 'notifications';
    LinksyPlatform.noticeTurnOn(
      device: e.from.id,
      name: e.from.name,
      feature: e.feature,
      title: messages
          ? tr.turnOnAskMessages(e.from.name)
          : tr.turnOnAskPhotos(e.from.name),
      body: messages ? tr.onboardingMessagesDetail : tr.onboardingGalleryDetail,
    );
  }

  /// Linksy may read the phone's photos and videos (Android's permission, or
  /// All files access).
  bool photoAccess = false;

  /// Computers may look through them in their Gallery (§4.18, Settings ›
  /// Files): on unless turned off, once Linksy may read them.
  bool get gallery => photoAccess && prefs['gallery'] != 'off';

  Future<void> _refreshGallery() async {
    final was = gallery;
    photoAccess = await LinksyPlatform.shareGallery(prefs['gallery'] != 'off');
    if (gallery != was) {
      await _announce();
      notifyListeners();
    }
  }

  /// Turns it on, asking Android for the photos first when it must, or off;
  /// whether it's on now.
  Future<bool> setGallery(bool on) async {
    await _setPref('gallery', on ? null : 'off');
    if (on && !photoAccess) await LinksyPlatform.requestPermission('photos');
    await _refreshGallery();
    await _announce();
    notifyListeners();
    return gallery;
  }

  void _onPhoneNotification(Map<String, Object?> n) {
    if (!mirroring) return;
    for (final id in _computers) {
      _dialing(id, () => node.postNotification(id, n));
    }
  }

  void _onPhoneNotificationGone((String, bool) gone) {
    final (key, kept) = gone;
    for (final id in _computers) {
      _dialing(id, () => node.removeNotification(id, key, replyKept: kept));
    }
  }

  /// A computer scrolls back in a conversation: what the listener kept.
  Future<void> _answerHistory(InboxHistoryRequested r) async {
    if (!mirroring) return;
    final (messages, more) = await LinksyPlatform.inboxHistory(
      r.app,
      r.conversation,
      r.beforeMs,
      r.limit,
    );
    await node
        .inboxHistoryPage(
          r.from.id,
          r.app,
          r.conversation,
          messages,
          more: more,
        )
        .catchError((Object _) {});
  }

  // Files (§4.9): computers browse the one folder the user picked.

  Future<void> pickSaveFolder() async {
    final name = await LinksyPlatform.pickFolder('received');
    if (name == null) return;
    saveFolder = name;
    notifyListeners();
  }

  /// Back to Downloads › Linksy.
  Future<void> forgetSaveFolder() async {
    await LinksyPlatform.forgetFolder('received');
    saveFolder = null;
    notifyListeners();
  }

  Future<String?> pickFilesFolder() async {
    final name = await LinksyPlatform.pickFolder('files');
    if (name == null) return null;
    filesFolder = name;
    await _setPref('files_mode', null);
    await setSharingFiles(true);
    return name;
  }

  Future<void> setSharingFiles(bool on) async {
    await _setPref('share_files', on ? 'on' : null);
    await LinksyPlatform.shareFiles(on && filesReady, all: filesAll);
  }

  /// Computers browse all of this phone's files instead of the picked
  /// folder (All files access, Android 11+).
  bool get filesAll => prefs['files_mode'] == 'all';

  /// All files access: `allowed`, `denied` or `unsupported`.
  String? allFiles;

  /// There's something to browse: the picked folder, or all files allowed.
  bool get filesReady => filesAll ? allFiles == 'allowed' : filesFolder != null;

  /// Folder or all files; all files asks Android first when it isn't allowed.
  Future<void> setFilesAll(bool all) async {
    await _setPref('files_mode', all ? 'all' : null);
    allFiles = await LinksyPlatform.allFilesState();
    if (all && allFiles == 'denied') await LinksyPlatform.allowAllFiles();
    await refreshFiles();
  }

  /// Again after Android's settings: whether All files access was given.
  Future<void> refreshFiles() async {
    allFiles = await LinksyPlatform.allFilesState();
    await LinksyPlatform.shareFiles(sharingFiles && filesReady, all: filesAll);
    // All files access lets computers see the photos too.
    await _refreshGallery();
    notifyListeners();
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

  /// What each player tells about where it is, on the Logs page when that
  /// changes: a bar that stays empty is a missing position or length.
  final Map<String, String> _playerFacts = {};

  void _logPlayers(DeviceInfo from, MediaState state) {
    for (final p in state.players) {
      final facts =
          '${p.playing ? 'playing' : 'paused'}, '
          'position ${p.positionMs == null ? 'none' : '${p.positionMs! ~/ 1000} s'}, '
          'length ${p.lengthMs == null ? 'none' : '${p.lengthMs! ~/ 1000} s'}';
      final key = '${from.id}/${p.id}';
      final shape = facts.replaceAll(RegExp(r'\d+ s'), 'n');
      if (_playerFacts[key] == shape) continue;
      _playerFacts[key] = shape;
      log.add('Player ${p.app} on ${from.name}: $facts');
    }
  }

  /// The player [id]'s deck and media notice control: the one picked on the
  /// deck while it's there (ids are stable, desktop 0.13.2), else the one
  /// playing, else the first (mobile#21).
  MediaPlayer? playerFor(String id) {
    final players = media[id]?.players ?? const <MediaPlayer>[];
    final picked = prefs['player.$id'];
    return players.where((p) => p.id == picked).firstOrNull ??
        players.where((p) => p.playing).firstOrNull ??
        players.firstOrNull;
  }

  Future<void> pickPlayer(String id, String player) =>
      _setPref('player.$id', player);

  /// The deck over the whole screen, without the status and navigation
  /// bars (mobile#21).
  bool get deckFullScreen => prefs['deck_full'] == 'on';
  Future<void> setDeckFullScreen(bool on) =>
      _setPref('deck_full', on ? 'on' : null);

  /// Covers as they are, not drawn in the theme's dots or pixels.
  bool get deckRealCovers => prefs['deck_real_art'] == 'on';
  Future<void> setDeckRealCovers(bool on) =>
      _setPref('deck_real_art', on ? 'on' : null);

  /// Pages showing a computer's volume, in front: the phone's volume keys
  /// step it there (5 % a press) instead of the phone's own (§7).
  final Map<Object, String> _volumeKeys = {};
  StreamSubscription<bool>? _volumeKeySub;

  /// [owner] (a page) shows [id]'s volume in front, or no longer (null).
  void volumeKeysFor(Object owner, String? id) {
    if (id == null) {
      _volumeKeys.remove(owner);
    } else {
      _volumeKeys[owner] = id;
    }
    final on = _volumeKeys.isNotEmpty;
    if (on == (_volumeKeySub != null)) return;
    LinksyPlatform.volumeSteps(on);
    _volumeKeySub?.cancel();
    _volumeKeySub = on
        ? LinksyPlatform.volumeKeys.listen((up) {
            if (_volumeKeys.isNotEmpty) stepVolume(_volumeKeys.values.last, up);
          })
        : null;
  }

  /// A volume key's press: shown at once, sent at most ten times a second
  /// (a held key repeats faster), the newest level last.
  void stepVolume(String id, bool up) {
    final v = volume[id];
    if (v == null) return;
    final unmute = up && v.muted;
    volume[id] = VolumeState(
      seq: v.seq,
      level: (v.level + (up ? 0.05 : -0.05)).clamp(0.0, 1.0),
      muted: unmute ? false : v.muted,
    );
    if (unmute) _unmuting.add(id);
    notifyListeners();
    if (_volumeCooling.containsKey(id)) {
      _volumeDirty.add(id);
      return;
    }
    _sendVolume(id);
  }

  final Map<String, Timer> _volumeCooling = {};
  final Set<String> _volumeDirty = {};
  final Set<String> _unmuting = {};

  void _sendVolume(String id) {
    final v = volume[id];
    if (v == null) return;
    final unmute = _unmuting.remove(id);
    node
        .setVolume(id, level: v.level, muted: unmute ? false : null)
        .catchError((Object _) {});
    _volumeCooling[id] = Timer(const Duration(milliseconds: 100), () {
      _volumeCooling.remove(id);
      if (_volumeDirty.remove(id)) _sendVolume(id);
    });
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

  /// Asks the computer (its user allows it there); null when it's on. One
  /// still open from a moment ago is used again, with no new request, so the
  /// computer doesn't announce it again (Discussion #79).
  Future<String?> startRemote(String id) async {
    _remoteGrace.remove(id)?.cancel();
    if (remotes.containsKey(id)) return null;
    return _run(() async {
      final session = await node.startInput(id);
      remotes[id] = session;
      notifyListeners();
    });
  }

  /// This phone's networks, as last reported.
  final networks = NetworkState();

  /// How long a remote stays open once its page is left: Deck, Media or
  /// Terminal and back shouldn't ask the computer again.
  static const remoteGrace = Duration(seconds: 60);

  /// Remotes left a moment ago, ending unless their page comes back.
  final Map<String, Timer> _remoteGrace = {};

  /// The remote's page went away: ends it after [remoteGrace].
  void leaveRemote(String id) {
    if (!remotes.containsKey(id)) return;
    _remoteGrace.remove(id)?.cancel();
    _remoteGrace[id] = Timer(remoteGrace, () {
      _remoteGrace.remove(id);
      stopRemote(id);
    });
  }

  /// Ends the remotes nobody's on: Linksy went to the background, the
  /// screen locked, the network changed.
  void _endLeftRemotes() {
    for (final id in _remoteGrace.keys.toList()) {
      stopRemote(id);
    }
  }

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
    _remoteGrace.remove(id)?.cancel();
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

  // Sends connect first, on the network or from away, so they don't wait for
  // a link (§4.13). One that can't be dialed is left alone for a minute.

  final Map<String, DateTime> _undialable = {};

  bool _resting(String id) => _undialable[id]?.isAfter(DateTime.now()) ?? false;

  /// The paired computers worth a message now.
  Iterable<String> get _computers => [
    for (final v in devices)
      if (v.trusted &&
          _isComputer(v.device) &&
          (v.connected || !_resting(v.device.id)))
        v.device.id,
  ];

  /// Runs [send] to computer [id]; whether it went.
  Future<bool> _dialing(String id, Future<void> Function() send) async {
    try {
      await send();
      _undialable.remove(id);
      return true;
    } on Object {
      if (device(id)?.connected != true) {
        _undialable[id] = DateTime.now().add(const Duration(seconds: 60));
        notifyListeners();
      }
      return false;
    }
  }

  void _onBattery(Battery b) {
    _battery = b;
    for (final id in _computers) {
      _tellBattery(id);
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
    // Not around after all: say it again next time it connects.
    if (!await _dialing(id, () => node.sendBattery(id, b))) {
      _toldBattery.remove(id);
    }
  }

  Future<void> refresh() async {
    devices = await node.devices();
    _noteComputer();
    notifyListeners();
  }

  // Transfers cut off with their connection carry on (resume.dart).

  /// Files each transfer offered, in order, as the core listed them.
  final _offeredFiles = <String, List<OfferedFile>>{};

  /// Sender: who files went to, and what was picked, to offer again.
  final _sends = <String, (String, List<String>)>{};

  /// Sender: transfers waiting to be offered again, and how often they were.
  final _resuming = <String>{};
  final _resumeTries = <String, int>{};

  /// A transfer that carries on another: the one it continues, and the bytes
  /// that one had before the files offered again.
  final _aliasOf = <String, (String, int)>{};

  /// The transfer carrying on each one, while it runs.
  final _resumedAs = <String, String>{};

  /// Sender: offered again but not answered yet, by device: events can come
  /// before the offer returns its id.
  final _resendingTo = <String, (String, int)>{};

  /// Receiver: files that arrived before a lost connection and aren't
  /// offered again, saved with the rest at the end.
  final _earlier = <String, List<String>>{};

  /// Receiver: a transfer from each device cut off a moment ago, waiting for
  /// it to offer the rest.
  final _interrupted =
      <
        String,
        ({
          String id,
          List<OfferedFile> files,
          int bytes,
          DateTime since,
          Timer timer,
        })
      >{};

  LinksyEvent _aliased(LinksyEvent e) {
    final transfer = switch (e) {
      TransferStarted(:final transfer) ||
      TransferProgress(:final transfer) ||
      TransferComplete(:final transfer) ||
      TransferFailed(:final transfer) ||
      TransferRouted(:final transfer) => transfer,
      _ => null,
    };
    if (transfer == null) return e;
    var alias = _aliasOf[transfer];
    if (alias == null && e is TransferStarted && e.peer != null) {
      if (!e.incoming) {
        // Offered again, before the offer returned: the rest of that one
        final waiting = _resendingTo[e.peer!.id];
        final had = waiting == null ? null : _offeredFiles[waiting.$1];
        if (had != null && tailStart(had, e.files) != null) {
          alias = _resendingTo.remove(e.peer!.id);
        }
      } else {
        // Taken without asking (accepted on its own): carried on all the same
        alias = _carryOn(e.peer!, transfer, e.files, rename: false);
      }
      if (alias != null) {
        _aliasOf[transfer] = alias;
        _resumedAs[alias.$1] = transfer;
      }
    }
    if (alias == null) return e;
    final (to, before) = alias;
    if (e is TransferComplete || e is TransferFailed) {
      _aliasOf.remove(transfer);
      _resumedAs.remove(to);
    }
    return switch (e) {
      TransferStarted() => TransferStarted(
        to,
        peer: e.peer,
        incoming: e.incoming,
        files: e.files,
        total: e.total + before,
        apps: e.apps,
      ),
      TransferProgress() => TransferProgress(
        transfer: to,
        bytes: e.bytes + before,
        total: e.total + before,
      ),
      TransferComplete() => TransferComplete(
        transfer: to,
        saved: [...?_earlier.remove(to), ...e.saved],
      ),
      TransferFailed() => TransferFailed(transfer: to, reason: e.reason),
      TransferRouted() => TransferRouted(
        transfer: to,
        route: e.route,
        settingUpDirect: e.settingUpDirect,
        whyNotDirect: e.whyNotDirect,
      ),
      _ => e,
    };
  }

  /// A transfer of files that lost its connection, and can carry on: its
  /// files known, no apps among them (their folders are named for the
  /// offer), not an import, and not started again too often.
  bool _canResume(String id, String reason) {
    if (!lostConnection(reason) || _offeredFiles[id] == null) return false;
    if (_imports.containsKey(id) || _transferApps.containsKey(id)) return false;
    final a = _activity.where((a) => a.id == id).firstOrNull;
    if (a == null || a.kind != ActivityKind.files) return false;
    if ((_resumeTries[id] ?? 0) >= resumeTries) return false;
    return a.incoming || _sends.containsKey(id);
  }

  void _resume(String id, String reason) {
    final a = _activity.firstWhere((a) => a.id == id);
    _resumeTries[id] = (_resumeTries[id] ?? 0) + 1;
    LinksyPlatform.cancelNotice(id);
    _update(id, (a) {
      a
        ..status = ActivityStatus.active
        ..speed = 0
        ..reason = tr.activityReconnecting;
    });
    if (a.incoming) {
      _interrupted.remove(a.deviceId)?.timer.cancel();
      _interrupted[a.deviceId] = (
        id: id,
        files: _offeredFiles[id]!,
        bytes: a.bytes,
        since: a.time,
        timer: Timer(resumeWithin, () {
          if (_interrupted[a.deviceId]?.id != id) return;
          _interrupted.remove(a.deviceId);
          _onEvent(TransferFailed(transfer: id, reason: reason));
        }),
      );
    } else {
      _resuming.add(id);
      unawaited(_resend(id, a.deviceId, a.bytes, reason));
    }
  }

  /// Sender: offers again, once the device is back, what it may not have
  /// whole.
  Future<void> _resend(
    String id,
    String deviceId,
    int sent,
    String reason,
  ) async {
    final files = _offeredFiles[id]!;
    final (_, picked) = _sends[id]!;
    final from = firstUnsure([for (final f in files) f.size], sent);
    // Not what was picked (it can't be told apart): all of it, the receiver
    // has what it has.
    final (paths, before) = resendPaths(picked, files, from) ?? (picked, 0);
    final until = DateTime.now().add(resumeWithin);
    var wait = const Duration(seconds: 1);
    while (DateTime.now().isBefore(until)) {
      await Future<void>.delayed(wait);
      wait = const Duration(seconds: 5);
      if (!_resuming.contains(id)) return;
      _resendingTo[deviceId] = (id, before);
      try {
        final next = await node.sendBundle(deviceId, paths, const []);
        if (!_resuming.remove(id)) {
          // Cancelled meanwhile
          unawaited(node.cancel(next).catchError((Object _) {}));
          return;
        }
        _resendingTo.remove(deviceId);
        _aliasOf[next] = (id, before);
        _resumedAs[id] = next;
        _update(id, (a) => a.reason = null);
        log.add(
          'Transfer with ${_who(deviceId)}: offered again, '
          '${paths.length} of ${picked.length} item(s)',
        );
        return;
      } on LinksyException {
        _resendingTo.remove(deviceId);
      }
    }
    if (!_resuming.remove(id)) return;
    _onEvent(TransferFailed(transfer: id, reason: reason));
  }

  /// Receiver: an offer that is the rest of a transfer cut off from the same
  /// device is taken without asking, and carries on that transfer.
  bool _continueIncoming(TransferRequest e) {
    if (e.apps.isNotEmpty) return false;
    final alias = _carryOn(e.from, e.transfer, e.files, rename: true);
    if (alias == null) return false;
    _aliasOf[e.transfer] = alias;
    _resumedAs[alias.$1] = e.transfer;
    log.add(
      'Transfer with ${e.from.name}: carrying on, '
      '${e.files.length} file(s) offered again',
    );
    unawaited(_run(() => node.respond(e.transfer, accept: true)));
    return true;
  }

  /// Receiver: when [files] are the rest of what [from] was sending, takes
  /// up that transfer and returns it and the bytes before them. With
  /// [rename], before it's accepted: a file offered again that's here whole
  /// already goes back to being its part, so the core checks it and nothing
  /// of it is sent again (otherwise it would be saved twice, as "a (1).jpg").
  (String, int)? _carryOn(
    DeviceInfo from,
    String transfer,
    List<OfferedFile> files, {
    required bool rename,
  }) {
    final w = _interrupted[from.id];
    if (w == null) return null;
    final start = tailStart(w.files, files);
    if (start == null) return null;
    _interrupted.remove(from.id);
    w.timer.cancel();
    final dir = settings?.downloadDir;
    final earlier = <String>[];
    final whole = wholeWithin(w.files, w.bytes);
    for (var i = 0; dir != null && i < whole; i++) {
      final path = '$dir/${w.files[i].path}';
      try {
        final file = File(path);
        // Arrived for this transfer, whole, and not being resumed already
        if (!file.existsSync() ||
            file.lengthSync() != w.files[i].size ||
            file.lastModifiedSync().isBefore(w.since) ||
            File('$path.linksy-part').existsSync()) {
          continue;
        }
        if (i < start) {
          earlier.add(path);
        } else if (rename) {
          file.renameSync('$path.linksy-part');
        }
      } on FileSystemException {
        continue;
      }
    }
    _earlier[w.id] = earlier;
    _update(w.id, (a) => a.reason = null);
    var before = 0;
    for (final f in w.files.take(start)) {
      before += f.size;
    }
    return (w.id, before);
  }

  /// A transfer is over, for good: what was kept to carry it on goes.
  void _ended(String id) {
    _offeredFiles.remove(id);
    _sends.remove(id);
    _resumeTries.remove(id);
    _earlier.remove(id);
  }

  void _onEvent(LinksyEvent raw) {
    // A transfer that carries on after a lost connection is the one it
    // continues, from where that one was.
    final e = _aliased(raw);
    if (e is TransferStarted && identical(e, raw)) {
      _offeredFiles[e.transfer] = e.files;
    }
    if (e is ClipboardReceived) _lastCopied = e.text;
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
      case ControlsWatchRequested(:final from, :final on):
        unawaited(_watchControls(from.id, on: on));
      case ControlsSetRequested(:final from, :final change):
        unawaited(_setControls(from, change));
      case ComputerNotificationReceived(
        :final from,
        :final key,
        :final app,
        :final title,
        :final body,
        :final atMs,
      ):
        if (computerNotifications) {
          LinksyPlatform.computerNotice(
            computer: from.name,
            key: key,
            app: app,
            title: title,
            body: body,
            atMs: atMs,
          );
        }
      case SnapRequested(:final from):
        unawaited(_snapAsked(from));
      case SessionRequest(kind: SessionKind.sound):
        unawaited(_answerSound(e));
      case UsbPlugged(:final from, :final phones):
        _plugged[from.id] = phones;
        unawaited(_readUsbHost());
        notifyListeners();
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
          _logPlayers(from, state);
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
        if (!_onScreen) {
          LinksyPlatform.noticeArrived(
            'link-${from.id}',
            tr.shareSheetSentALink(from.name),
            url,
          );
        }
      // Answers to this phone's notifications, from a computer showing them.
      case NotificationReplyRequested(:final key, :final text) when mirroring:
        LinksyPlatform.replyNotification(key, text);
      case NotificationActionRequested(:final key, :final action)
          when mirroring:
        LinksyPlatform.notificationAction(key, action);
      case NotificationDismissRequested(:final key) when mirroring:
        LinksyPlatform.dismissNotification(key);
      case InboxHistoryRequested():
        _answerHistory(e);
      case LocationReceived() || AppInstalled():
        // Shown from the prompts.
        break;
      case TurnOnRequested():
        unawaited(_onTurnOnRequest(e));
      case DeckActionsReceived(:final from, :final actions):
        deckActions[from.id] = actions;
        _deckFirstLayout(from.id, actions);
        notifyListeners();
      case DeckStateReceived(:final from, :final states):
        final now = deckStates.putIfAbsent(from.id, () => {});
        for (final st in states) {
          now[st.id] = st;
        }
        notifyListeners();
      case DeckLayoutReceived(:final from, :final layouts):
        _onDeckLayouts(from.id, layouts);
      // Turned off here since: nothing to answer.
      case NotificationReplyRequested() ||
          NotificationActionRequested() ||
          NotificationDismissRequested():
        break;
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
      case TransferRequest() when _continueIncoming(e):
        break;
      case TransferRequest(
        :final transfer,
        :final from,
        :final files,
        :final total,
        :final apps,
      ):
        // Not on screen: Accept / Decline right in the notification.
        if (!_onScreen) {
          LinksyPlatform.noticeTransfer(
            transfer,
            apps.isEmpty
                ? tr.ctlTransferRequest(files.length, from.name)
                : tr.phoneInstallAsk(apps.length, from.name),
            [
              if (apps.isEmpty && files.length == 1) files.single.name,
              if (apps.isNotEmpty) apps.map((a) => a.label).join(', '),
              formatBytes(total),
            ].join(' · '),
          );
        }
        if (apps.isNotEmpty) _transferApps[transfer] = apps;
        _add(
          Activity(
            id: transfer,
            deviceId: from.id,
            kind: ActivityKind.files,
            incoming: true,
            time: DateTime.now(),
            status: ActivityStatus.waiting,
            names: _offered(files, apps).$1,
            sizes: _offered(files, apps).$2,
            total: total,
            packages: {for (final a in apps) a.label: a.package},
          ),
        );
      case TransferRouted(:final transfer, :final whyNotDirect):
        _routes[transfer] = e;
        if (whyNotDirect != null) log.add('No direct link: $whyNotDirect');
        notifyListeners();
      case AppsReceived():
        _transferApps.remove(e.transfer);
        pendingApps.add(e);
        if (_onScreen) {
          _offerApps();
        } else {
          LinksyPlatform.noticeArrived(
            'apps-${e.transfer}',
            tr.phoneInstallAsk(e.apps.length, e.from.name),
            e.apps.map((a) => a.info.label).join(', '),
          );
        }
      case TransferStarted(
        :final transfer,
        :final peer,
        :final incoming,
        :final files,
        :final total,
        :final apps,
      ):
        if (incoming && apps.isNotEmpty) _transferApps[transfer] = apps;
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
              names: _offered(files, apps).$1,
              sizes: _offered(files, apps).$2,
              total: total,
              packages: {for (final a in apps) a.label: a.package},
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
        _ended(transfer);
        LinksyPlatform.cancelNotice(transfer);
        // An app's files stay where they are, to be installed from there.
        final apps = _transferApps[transfer] ?? const <AppInfo>[];
        final plain = [
          for (final p in saved)
            if (!apps.any((a) => p.contains('/${a.dir}/'))) p,
        ];
        // Files that went or came: a light tick once they're all there.
        if (_onScreen && _activity.any((a) => a.id == transfer)) {
          HapticFeedback.lightImpact();
        }
        _update(transfer, (a) {
          a
            ..status = ActivityStatus.done
            ..bytes = a.total
            ..saved = plain;
        });
        // Where other apps find them: Downloads/Linksy, or the chosen folder.
        // Not a file put on the clipboard: no timeline entry was made for its transfer.
        if (plain.isNotEmpty && _activity.any((a) => a.id == transfer)) {
          LinksyPlatform.publishDownloads(plain).then((moved) {
            _update(transfer, (a) => a.saved = moved);
          });
        }
        _lastSample.remove(transfer);
        _routes.remove(transfer);
      case TransferFailed(:final transfer, :final reason)
          when _canResume(transfer, reason):
        _resume(transfer, reason);
      case TransferFailed(:final transfer, :final reason):
        _ended(transfer);
        LinksyPlatform.cancelNotice(transfer);
        _routes.remove(transfer);
        // An app's files have nothing left to be: they go.
        for (final a in _transferApps.remove(transfer) ?? const <AppInfo>[]) {
          final dir = Directory('${settings?.downloadDir}/${a.dir}');
          dir.delete(recursive: true).ignore();
        }
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
      case NotificationReceived(:final from, :final title, :final body):
        _addLocal(from.id, ActivityKind.ping, incoming: true, text: title);
        // On screen the app says it; away, a notification does.
        if (!_onScreen) {
          LinksyPlatform.noticeArrived(
            'ping-${from.id}',
            title.isEmpty ? from.name : title,
            body.isEmpty ? from.name : body,
          );
        }
      case SessionStarted(:final session, :final peer, :final kind)
          when e.sharing && kind != SessionKind.display:
        sharing[session] = e;
        LinksyPlatform.startShare(session, kind.name, peer.name, peer.id);
        // One line for a screen and its sound.
        if (kind != SessionKind.sound) _addSession(e);
      case SessionStarted(:final session, kind: SessionKind.display)
          when !e.sharing:
        displays[session] = e;
        LinksyPlatform.keepScreenOn(session, on: true);
        _addSession(e);
      case SessionEnded(:final session):
        if (remotes.containsValue(session)) {
          for (final id in [
            for (final MapEntry(:key, :value) in remotes.entries)
              if (value == session) key,
          ]) {
            _remoteGrace.remove(id)?.cancel();
          }
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
      case SessionRequest(kind: SessionKind.sound):
        break;
      // Carries on a transfer cut off: taken without asking.
      case TransferRequest(:final transfer) when _aliasOf.containsKey(transfer):
        break;
      case PairingRequest() ||
          PairingFailed() ||
          SessionRequest() ||
          Paired() ||
          TransferRequest() ||
          NotificationReceived() ||
          ClipboardFileReceived() ||
          OpenUrlReceived() ||
          LocationReceived():
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
        // A computer's screen watched from here. Not `input`: the phone
        // doesn't share there either, but it's the touchpad (Discussion #79).
        _
            when !e.sharing &&
                e.kind != SessionKind.display &&
                e.kind != SessionKind.input =>
          ActivityKind.watch,
        SessionKind.screen => ActivityKind.screen,
        SessionKind.camera => ActivityKind.camera,
        SessionKind.control => ActivityKind.control,
        SessionKind.display => ActivityKind.display,
        SessionKind.input => ActivityKind.remote,
        SessionKind.microphone => ActivityKind.microphone,
        SessionKind.sound => ActivityKind.screen,
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
      _sends[transfer] = (deviceId, paths);
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

  /// "Find my computer": makes it ring until [stopFinding]. Shown as
  /// ringing at once, and back if it couldn't.
  Future<String?> find(String deviceId) async {
    _finding.remove(deviceId)?.cancel();
    _finding[deviceId] = Timer(ringFor, () {
      _finding.remove(deviceId);
      notifyListeners();
    });
    notifyListeners();
    final error = await _run(() async {
      await node.ring(deviceId, on: true);
      _addLocal(deviceId, ActivityKind.ring, incoming: false);
    });
    if (error != null) {
      _finding.remove(deviceId)?.cancel();
      notifyListeners();
    }
    return error;
  }

  Future<String?> stopFinding(String deviceId) => _run(() async {
    _finding.remove(deviceId)?.cancel();
    notifyListeners();
    await node.ring(deviceId, on: false);
  });

  // The deck (§4.19): this phone as buttons for a computer.

  /// What each computer lets the deck do, once it said so, by device id.
  final deckActions = <String, List<DeckAction>>{};

  /// Their state now, by device id and action.
  final deckStates = <String, Map<String, DeckState>>{};

  final _phoneDecks = <String, PhoneDeck?>{};

  /// The deck's layout for [id], saved on the phone; none until that
  /// computer first offers something.
  PhoneDeck? phoneDeck(String id) =>
      _phoneDecks[id] ??= PhoneDeck.decode(prefs['deck.$id']);

  Future<void> saveDeck(String id, PhoneDeck layout) async {
    _phoneDecks[id] = layout;
    await _setPref('deck.$id', layout.encode());
  }

  /// The first time a computer offers actions, a deck made of them; after
  /// that, tiles keep the names and kinds it says now.
  void _deckFirstLayout(String id, List<DeckAction> actions) {
    // A computer that lays the deck out itself needs none here.
    if (deckLayouts(id) != null) return;
    final layout = phoneDeck(id);
    if (layout == null) {
      if (actions.isNotEmpty) saveDeck(id, PhoneDeck.first(actions));
      return;
    }
    var changed = false;
    for (final page in layout.pages) {
      for (final t in page.tiles) {
        final a = actions.where((a) => a.id == t.action).firstOrNull;
        if (a != null && (a.name != t.name || a.kind != t.kind)) {
          t
            ..name = a.name
            ..kind = a.kind;
          changed = true;
        }
      }
    }
    if (changed) saveDeck(id, layout);
  }

  final _laid = <String, DeckLayouts?>{};

  /// The deck as laid out on this phone, for [id]. It stays here, over what
  /// the computer has, until the computer can take it (`deck_layout_save`).
  final _laidHere = <String, DeckLayouts?>{};

  File? _deckHereFile(String id) =>
      _decks == null ? null : File('${_decks.path}/$id.here.json');

  DeckLayouts? _deckHere(String id) {
    if (_laidHere.containsKey(id)) return _laidHere[id];
    String? saved;
    try {
      saved = _deckHereFile(id)?.readAsStringSync();
    } on FileSystemException {
      saved = null;
    }
    return _laidHere[id] = DeckLayouts.decode(saved);
  }

  /// Laid out here rather than as the computer sent it.
  bool deckHasHere(String id) => _deckHere(id) != null;

  Future<void> saveDeckHere(String id, DeckLayouts layouts) async {
    _laidHere[id] = layouts;
    notifyListeners();
    final file = _deckHereFile(id);
    if (file == null) return;
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(layouts.toJson()));
    } on FileSystemException catch (e) {
      log.add('Deck not kept: $e');
    }
  }

  /// Back to what the computer has.
  Future<void> dropDeckHere(String id) async {
    _laidHere[id] = null;
    notifyListeners();
    await _deckHereFile(id)?.delete().catchError((Object _) => File(''));
  }

  /// The layouts to show for [id] (§4.20): the ones made here, else the last
  /// it sent, kept on the phone; none until it sends some.
  DeckLayouts? deckLayouts(String id) {
    if (_deckHere(id) case final here?) return here;
    if (_laid.containsKey(id)) return _laid[id];
    String? saved;
    try {
      saved = _deckFile(id)?.readAsStringSync();
    } on FileSystemException {
      saved = null;
    }
    return _laid[id] = DeckLayouts.decode(saved);
  }

  File? _deckFile(String id) =>
      _decks == null ? null : File('${_decks.path}/$id.json');

  /// Each set the computer sends is its current one: shown, and kept.
  void _onDeckLayouts(String id, Map<String, Object?> json) {
    final layouts = DeckLayouts.parse(json);
    if (layouts == null) return;
    _laid[id] = layouts;
    notifyListeners();
    final file = _deckFile(id);
    if (file == null) return;
    file.parent
        .create(recursive: true)
        .then((_) => file.writeAsString(jsonEncode(json)))
        .catchError((Object e) {
          log.add('Deck layouts not kept: $e');
          return file;
        });
  }

  /// The theme picked on the phone for [layout] on [id], drawn instead of
  /// the layout's own; none: the layout's.
  String? deckTheme(String id, String layout) =>
      prefs['deck_theme.$id.$layout'];

  Future<void> setDeckTheme(String id, String layout, String? theme) =>
      _setPref('deck_theme.$id.$layout', theme);

  Future<void> _forgetDeck(String id) async {
    _laid.remove(id);
    _laidHere.remove(id);
    await _deckHereFile(id)?.delete().catchError((Object _) => File(''));
    _phoneDecks.remove(id);
    await _deckFile(id)?.delete().catchError((Object _) => File(''));
    for (final key in [...prefs.keys]) {
      if (key == 'deck.$id' || key.startsWith('deck_theme.$id.')) {
        await _setPref(key, null);
      }
    }
  }

  /// The deck shows: the computer sends what it may do, then its state.
  Future<void> openDeck(String id) =>
      _dialing(id, () => node.deckOpen(id, open: true));

  /// A deck's tiles work: a tap dials, so no link has to be up. Not once
  /// the computer failed to answer.
  bool deckLive(String id) {
    final v = device(id);
    return v != null && (v.connected || v.reachable && !_resting(id));
  }

  /// …and stopped: it stops sending.
  Future<void> closeDeck(String id) =>
      node.deckOpen(id, open: false).catchError((Object _) {});

  final _slid = <String, double>{};
  final _sliding = <String, Timer>{};

  /// Runs [action] on [id]: a tap, or a slider's [value]. While a slider is
  /// dragged its newest value goes at most every 80 ms, the last one always.
  void runDeck(String id, String action, {double? value}) {
    if (value == null) {
      // A toggle flips at once; the computer's state follows.
      final offered = deckActions[id]?.where((a) => a.id == action).firstOrNull;
      if (offered?.kind == DeckKind.toggle) {
        final states = deckStates.putIfAbsent(id, () => {});
        final was = states[action];
        states[action] = DeckState(
          id: action,
          on: !(was?.on ?? false),
          value: was?.value,
          text: was?.text,
        );
        notifyListeners();
        _dialing(id, () => node.deckRun(id, action)).then((went) {
          if (went) return;
          if (was == null) {
            states.remove(action);
          } else {
            states[action] = was;
          }
          notifyListeners();
        });
        return;
      }
      _dialing(id, () => node.deckRun(id, action));
      return;
    }
    final key = '$id $action';
    _slid[key] = value;
    if (_sliding.containsKey(key)) return;
    bool send() {
      final v = _slid.remove(key);
      if (v == null) return false;
      if (deckLive(id)) _dialing(id, () => node.deckRun(id, action, value: v));
      return true;
    }

    send();
    _sliding[key] = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!send()) {
        t.cancel();
        _sliding.remove(key);
      }
    });
  }

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

  Future<String?> cancel(String transfer) {
    // Waiting to carry on: nothing runs to stop, it just ends here.
    if (_resuming.remove(transfer) ||
        _interrupted.values.any((w) => w.id == transfer)) {
      _interrupted.removeWhere((_, w) {
        if (w.id != transfer) return false;
        w.timer.cancel();
        return true;
      });
      _onEvent(TransferFailed(transfer: transfer, reason: 'cancelled'));
      return Future.value();
    }
    final live = _resumedAs[transfer] ?? transfer;
    return _run(() => node.cancel(live));
  }

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
        case SessionKind.input || SessionKind.sound:
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
    await _forgetDeck(deviceId);
    final error = await _run(() => node.forget(deviceId));
    _activity.removeWhere((a) => a.deviceId == deviceId);
    _changed();
    // The core announces no event for this: read the list again.
    await refresh();
    return error;
  }

  /// Shown at once, so a switch moves when it's tapped; put back if the
  /// core refuses.
  Future<String?> updateSettings(NodeSettings s) async {
    final before = settings;
    settings = s;
    notifyListeners();
    final error = await _run(() => node.updateSettings(s));
    if (error != null && identical(settings, s)) {
      settings = before;
      notifyListeners();
    }
    return error;
  }

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
    _memoryTimer?.cancel();
    for (final w in _interrupted.values) {
      w.timer.cancel();
    }
    _resuming.clear();
    _volumeKeySub?.cancel();
    for (final t in _volumeCooling.values) {
      t.cancel();
    }
    for (final t in _remoteGrace.values) {
      t.cancel();
    }
    _sub?.cancel();
    _batterySub?.cancel();
    _callSub?.cancel();
    _noticeSub?.cancel();
    _preflightSub?.cancel();
    _installSub?.cancel();
    _noticeGoneSub?.cancel();
    _answerSub?.cancel();
    _directSub?.cancel();
    _networkSub?.cancel();
    log.dispose();
    _mediaActionSub?.cancel();
    LinksyPlatform.mediaNotice(null);
    _controlsSub?.cancel();
    _controlsSoon?.cancel();
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

/// Which of [phones] is this one (§4.11): the one with its maker and model, or
/// the only one that could be. Only one that isn't on the cable already.
String? usbKeyFor(List<PluggedPhone> phones, String maker, String model) {
  final free = [
    for (final p in phones)
      if (p.state == 'plugged' || p.state == 'failed') p,
  ];
  bool same(String a, String b) => a.toLowerCase() == b.toLowerCase();
  for (final p in free) {
    if (same(p.manufacturer, maker) && same(p.product, model)) return p.key;
  }
  return free.length == 1 ? free.single.key : null;
}
