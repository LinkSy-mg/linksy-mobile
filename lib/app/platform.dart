import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/models.dart';

/// Something another app shared to Linksy: text (maybe a link) or files.
sealed class SharedIn {
  const SharedIn({this.device});

  /// The device picked in Android's share sheet, if one was: send straight
  /// to it, without asking.
  final String? device;
}

class SharedText extends SharedIn {
  const SharedText(this.text, {super.device});
  final String text;
}

class SharedFiles extends SharedIn {
  const SharedFiles(this.paths, {super.device});

  /// Copies in the app's cache.
  final List<String> paths;
}

/// The few things only Android knows (android/…/MainActivity.kt).
abstract final class LinksyPlatform {
  static const _channel = MethodChannel('app.linksy/platform');
  static final _links = StreamController<String>.broadcast();
  static final _displaySizes =
      StreamController<(String, double, double)>.broadcast();
  static final _displaysEnded = StreamController<String>.broadcast();
  static final _qrCodes = StreamController<String>.broadcast();
  static final _scannerErrors = StreamController<String>.broadcast();
  static final _shares = StreamController<SharedIn>.broadcast();
  static final _batteries = StreamController<Battery>.broadcast();
  static final _callStates = StreamController<String>.broadcast();
  static final _phoneNotifications =
      StreamController<Map<String, Object?>>.broadcast();
  static final _phoneNotificationsGone = StreamController<String>.broadcast();
  static final _volumeKeys = StreamController<bool>.broadcast();
  static final _webcamChanges =
      StreamController<(String, Map<String, Object?>)>.broadcast();
  static final _openWebcam = StreamController<String>.broadcast();
  static final _transferAnswers = StreamController<(String, bool)>.broadcast();
  static final _usbPorts = StreamController<int>.broadcast();
  static final _networkChanges = StreamController<void>.broadcast();

  /// This phone's networks changed (at most once a second).
  static Stream<void> get networkChanges {
    _listen();
    return _networkChanges.stream;
  }

  static final _directSteps =
      StreamController<(String, Map<String, Object?>)>.broadcast();
  static var _listening = false;

  /// Calls from Android: pairing links, second-display size and end, and
  /// the QR scanner's results.
  static void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'link' when call.arguments is String:
          _links.add(call.arguments as String);
        case 'log' when call.arguments is String:
          _logs.add(call.arguments as String);
        case 'displaySize':
          final a = call.arguments as Map;
          _displaySizes.add((
            a['session'] as String,
            (a['width'] as num).toDouble(),
            (a['height'] as num).toDouble(),
          ));
        case 'displayEnded' when call.arguments is String:
          _displaysEnded.add(call.arguments as String);
        case 'qrCode' when call.arguments is String:
          _qrCodes.add(call.arguments as String);
        case 'scannerError' when call.arguments is String:
          _scannerErrors.add(call.arguments as String);
        case 'share':
          final share = _shared(call.arguments);
          if (share != null) _shares.add(share);
        case 'callState' when call.arguments is String:
          _callStates.add(call.arguments as String);
        case 'phoneNotification' when call.arguments is Map:
          _phoneNotifications.add(
            (call.arguments as Map).cast<String, Object?>(),
          );
        case 'phoneNotificationGone' when call.arguments is String:
          _phoneNotificationsGone.add(call.arguments as String);
        case 'webcamChanged':
          final a = call.arguments as Map;
          _webcamChanges.add((
            a['session'] as String,
            (jsonDecode(a['state'] as String) as Map).cast<String, Object?>(),
          ));
        case 'openWebcam' when call.arguments is String:
          _openWebcam.add(call.arguments as String);
        case 'networkChanged':
          _networkChanges.add(null);
        case 'directStep' when call.arguments is Map:
          final a = (call.arguments as Map).cast<String, Object?>();
          final device = a.remove('device');
          if (device is String) _directSteps.add((device, a));
        case 'transferAnswer':
          final a = call.arguments as Map;
          _transferAnswers.add((a['transfer'] as String, a['accept'] == true));
        case 'volumeKey' when call.arguments is String:
          _volumeKeys.add(call.arguments == 'up');
        case 'usbPort' when call.arguments is int:
          _usbPorts.add(call.arguments as int);
        case 'updateStatus' when call.arguments is String:
          _updateStatuses.add(call.arguments as String);
        case 'mediaAction' when call.arguments is Map:
          final a = call.arguments as Map;
          if (a['action'] case final String action) {
            _mediaActions.add((action, (a['position_ms'] as num?)?.toInt()));
          }
        case 'batteryChanged':
          final b = _battery(call.arguments);
          if (b != null) _batteries.add(b);
      }
    });
  }

  static SharedIn? _shared(Object? args) {
    if (args is! Map) return null;
    final device = args['device'] as String?;
    final files = (args['files'] as List?)?.cast<String>();
    if (files != null && files.isNotEmpty) {
      return SharedFiles(files, device: device);
    }
    final text = args['text'];
    return text is String && text.trim().isNotEmpty
        ? SharedText(text, device: device)
        : null;
  }

  static Battery? _battery(Object? args) => args is Map
      ? Battery(
          level: (args['level'] as num).toInt(),
          charging: args['charging'] == true,
        )
      : null;

  static Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      // No Android side (tests).
      return null;
    }
  }

  /// The name the user gave this phone, else its model.
  static Future<String> deviceName() async {
    try {
      final name = await _channel.invokeMethod<String>('deviceName');
      return name == null || name.trim().isEmpty ? 'Android phone' : name;
    } on Object {
      return 'Android phone';
    }
  }

  /// A `linksy://pair?…` link that opened the app, once.
  static Future<String?> takeLink() async {
    try {
      return await _channel.invokeMethod<String>('takeLink');
    } on Object {
      return null;
    }
  }

  /// Each paired device in Android's share sheet, in this order (`id`,
  /// `name`, `initials`, `picture`).
  static Future<void> shareTargets(List<Map<String, String?>> devices) =>
      _call<void>('shareTargets', devices);

  /// A share went to [device]: it moves up in the share sheet.
  static Future<void> sharedTo(String device) =>
      _call<void>('sharedTo', device);

  /// What was shared to Linksy before the app was ready, once.
  static Future<SharedIn?> takeShare() async =>
      _shared(await _call<Object?>('takeShare'));

  /// Shares that arrive while the app is running.
  static Stream<SharedIn> get shares {
    _listen();
    return _shares.stream;
  }

  /// This phone's battery now (null without one, or in tests).
  static Future<Battery?> battery() async =>
      _battery(await _call<Object?>('battery'));

  /// Every battery change Android reports (often the same level again).
  static Stream<Battery> get batteryChanges {
    _listen();
    return _batteries.stream;
  }

  /// Android's folder picker, for `files` (shared with computers) or
  /// `photos` (backed up). Returns the folder's name, or null if cancelled.
  static Future<String?> pickFolder(String kind) =>
      _call<String>('pickFolder', {'kind': kind});

  /// The name of the folder picked for [kind], if still allowed.
  static Future<String?> folder(String kind) =>
      _call<String>('folder', {'kind': kind});

  /// Lets paired computers browse the `files` folder, or with [all] the
  /// phone's whole storage (once All files access is allowed), or nothing.
  static Future<void> shareFiles(bool on, {bool all = false}) =>
      _call<void>('shareFiles', {'on': on, 'all': all});

  /// All files access: `allowed`, `denied`, or `unsupported` (before Android 11).
  static Future<String?> allFilesState() => _call<String>('allFilesState');

  /// Android's page that allows All files access for Linksy.
  static Future<void> allowAllFiles() => _call<void>('allowAllFiles');

  /// Keeps Linksy running with the screen off, with a quiet notification
  /// saying [text]; [awake] keeps the CPU on too (heartbeats). With
  /// [progress] (a percentage, or -1 not started yet), it's files on their
  /// way: shown in the status bar under [title], with Wi-Fi kept on too.
  static Future<void> keepAlive({
    required bool on,
    String text = '',
    bool awake = false,
    String? title,
    int? progress,
  }) => _call<void>('keepAlive', {
    'on': on,
    'text': text,
    'awake': awake,
    'title': title,
    'progress': progress,
  });

  /// Reports calls (`ringing`, `active`, `idle`) on [callStates] while on.
  static Future<void> watchCalls(bool on) =>
      _call<void>('watchCalls', {'on': on});

  static Stream<String> get callStates {
    _listen();
    return _callStates.stream;
  }

  /// This phone's notifications while [mirrorNotifications] is on and
  /// Android lets Linksy read them: each new or changed one, in the core's
  /// shape (docs/protocol.md §4.5).
  static Stream<Map<String, Object?>> get phoneNotifications {
    _listen();
    return _phoneNotifications.stream;
  }

  /// …and the keys of those that went away.
  static Stream<String> get phoneNotificationsGone {
    _listen();
    return _phoneNotificationsGone.stream;
  }

  /// Whether Android lets Linksy read notifications (Notification access).
  static Future<bool> notificationAccess() async =>
      await _call<bool>('notificationAccess') ?? false;

  /// Android's Notification access page for Linksy; whether it's allowed
  /// once the user comes back.
  static Future<bool> askNotificationAccess() async =>
      await _call<bool>('askNotificationAccess') ?? false;

  /// Sends this phone's notifications to [phoneNotifications], or stops.
  static Future<void> mirrorNotifications(bool on) =>
      _call<void>('mirrorNotifications', {'on': on});

  /// Answers notification [key] through its own reply; false if it's gone.
  static Future<bool> replyNotification(String key, String text) async =>
      await _call<bool>('replyNotification', {'key': key, 'text': text}) ??
      false;

  /// Presses its button [action] (the id it was sent with).
  static Future<bool> notificationAction(String key, String action) async =>
      await _call<bool>('notificationAction', {'key': key, 'action': action}) ??
      false;

  /// Takes it away, as if swiped.
  static Future<bool> dismissNotification(String key) async =>
      await _call<bool>('dismissNotification', {'key': key}) ?? false;

  /// Linksy's App info page in Android's settings.
  static Future<void> openAppInfo() => _call<void>('openAppInfo');

  /// Who made this phone (`Build.MANUFACTURER`, as written) and its Android
  /// API level.
  static Future<({String maker, int sdk})> phoneMaker() async {
    final m = await _call<Map>('phoneMaker');
    return (
      maker: m?['maker'] as String? ?? '',
      sdk: (m?['sdk'] as num?)?.toInt() ?? 0,
    );
  }

  /// New photos in the `photos` folder after [sinceMs], copied into month
  /// folders: (folders to send, newest time, count, more to come). Null
  /// without a folder.
  static Future<({List<String> folders, int newest, int count, bool more})?>
  photoBatch(int sinceMs) async {
    final m = await _call<Map<Object?, Object?>>('photoBatch', {
      'since': sinceMs,
    });
    if (m == null) return null;
    return (
      folders: (m['folders'] as List).cast<String>(),
      newest: (m['newest'] as num).toInt(),
      count: (m['count'] as num).toInt(),
      more: m['more'] == true,
    );
  }

  /// Small settings kept by Android (no plugin), as strings.
  static Future<Map<String, String>> prefs() async =>
      (await _call<Map<Object?, Object?>>('prefs'))
          ?.map((k, v) => MapEntry(k as String, v as String)) ??
      {};

  /// Null removes it.
  static Future<void> setPref(String key, String? value) =>
      _call<void>('setPref', {'key': key, 'value': value});

  /// Presentation remote: keeps the screen on and turns the volume keys into
  /// [volumeKeys] (true = up) while on.
  static Future<void> presentation(bool on) =>
      _call<void>('presentation', {'on': on});

  /// The volume keys as [volumeKeys], held down too, while on: they step
  /// a computer's volume instead of the phone's.
  static Future<void> volumeSteps(bool on) =>
      _call<void>('volumeSteps', {'on': on});

  static Stream<bool> get volumeKeys {
    _listen();
    return _volumeKeys.stream;
  }

  /// Incoming files as a notification with Accept and Decline (when Linksy
  /// isn't on screen); the answer comes back on [transferAnswers].
  static Future<void> noticeTransfer(
    String transfer,
    String title,
    String body,
  ) => _call<void>('noticeTransfer', {
    'transfer': transfer,
    'title': title,
    'body': body,
  });

  /// A ping or a link from a computer while Linksy isn't on screen: a
  /// notification that buzzes and opens the app.
  static Future<void> noticeArrived(String id, String title, String body) =>
      _call<void>('noticeArrived', {'id': id, 'title': title, 'body': body});

  static Future<void> cancelNotice(String transfer) =>
      _call<void>('cancelNotice', {'transfer': transfer});

  /// Whether this phone can host a direct link (Wi-Fi Direct, Android 10+).
  static Future<Map<String, String>> deviceReport() async =>
      (await _call<Map>('deviceReport'))?.cast<String, String>() ?? {};

  static Future<bool> directHost() async =>
      await _call<bool>('directHost') ?? false;

  /// A direct link's Wi-Fi part (docs/protocol.md §4.17): start it for
  /// [device], connect once the computer listens at [address], drop it. Each
  /// step it takes comes back on [directSteps].
  /// [group] (`ssid`, `passphrase`, `frequency`): another phone, which joins
  /// the group this one makes with it.
  static Future<void> directWanted(
    String device, {
    Map<String, Object?>? group,
  }) => _call<void>('directWanted', {'device': device, ...?group});

  /// Join the [group] another phone made (phone to phone).
  static Future<void> directJoin(String device, Map<String, Object?> group) =>
      _call<void>('directJoin', {'device': device, ...group});
  static Future<void> directListening(String device, String address) =>
      _call<void>('directListening', {'device': device, 'address': address});
  static Future<void> directLinked(String device) =>
      _call<void>('directLinked', {'device': device});
  static Future<void> directEnded(String device) =>
      _call<void>('directEnded', {'device': device});

  /// (device, step): `invite` with `address`, `connecting`, `up` with `ip`,
  /// or `end` with `reason`.
  static Stream<(String, Map<String, Object?>)> get directSteps {
    _listen();
    return _directSteps.stream;
  }

  static Stream<(String, bool)> get transferAnswers {
    _listen();
    return _transferAnswers.stream;
  }

  /// Moves received files into Downloads/Linksy (Android 10+); returns where
  /// each one is now (a `content://` URI, or the same path if it stayed).
  static Future<List<String>> publishDownloads(List<String> paths) async =>
      (await _call<List<Object?>>('publishDownloads', {
        'paths': paths,
      }))?.cast<String>() ??
      paths;

  /// A running webcam's capabilities and controls (see CameraShare.kt).
  static Future<Map<String, Object?>?> webcamState(String session) async {
    final raw = await _call<String>('webcamState', {'session': session});
    return raw == null
        ? null
        : (jsonDecode(raw) as Map).cast<String, Object?>();
  }

  /// Changes any of the webcam's controls (same keys as the state).
  static Future<void> webcamSet(
    String session,
    Map<String, Object?> controls,
  ) => _call<void>('webcamSet', {
    'session': session,
    'controls': jsonEncode(controls),
  });

  /// Shows the webcam in a texture (its id), or stops showing it.
  static Future<int?> webcamPreview(String session, {required bool on}) =>
      _call<int>('webcamPreview', {'session': session, 'on': on});

  /// Every webcam change, from the phone or from the computer.
  static Stream<(String, Map<String, Object?>)> get webcamChanges {
    _listen();
    return _webcamChanges.stream;
  }

  /// The webcam notification was tapped: open its controls.
  static Stream<String> get openWebcam {
    _listen();
    return _openWebcam.stream;
  }

  /// Front ↔ back camera while the phone is a webcam.
  static Future<void> switchCamera(String session) =>
      _call<void>('switchCamera', {'session': session});

  /// Each paired device's picture: id → file path.
  static Future<Map<String, String>> pictures() async =>
      (await _call<Map<Object?, Object?>>('pictures'))
          ?.map((k, v) => MapEntry(k as String, v as String)) ??
      {};

  /// Android's photo picker; the picture saved for [device], or null.
  static Future<String?> pickPicture(String device) =>
      _call<String>('pickPicture', {'device': device});

  static Future<void> removePicture(String device) =>
      _call<void>('removePicture', {'device': device});

  /// "0.1.14 (3015)": the installed version and its version code.
  static Future<String?> appVersion() => _call<String>('appVersion');

  /// The ABI this phone prefers (`arm64-v8a`…), for the smaller APK.
  static Future<String?> abi() => _call<String>('abi');

  /// Whether Linksy may install its updates (Install unknown apps).
  static Future<bool> updatesAllowed() async =>
      await _call<bool>('updatesAllowed') ?? false;

  /// Opens Install unknown apps for Linksy.
  static Future<void> allowUpdates() => _call<void>('allowUpdates');

  /// Checks [path] against [sha256] and hands it to Android's installer; the
  /// outcome comes on [updateStatuses].
  static Future<void> installUpdate(String path, String sha256) =>
      _call<void>('installUpdate', {'path': path, 'sha256': sha256});

  /// `installed`, `cancelled`, `bad_sum` or `failed:<message>`.
  static Stream<String> get updateStatuses {
    _listen();
    return _updateStatuses.stream;
  }

  static final _updateStatuses = StreamController<String>.broadcast();

  /// The computer's music as a media notification ([player]: its fields as
  /// in `media_state`, plus `device`, the computer's name), or none.
  static Future<void> mediaNotice(Map<String, Object?>? player) =>
      _call<void>('mediaNotice', player);

  /// Its buttons: `play`, `pause`, `play_pause`, `next`, `previous`, or
  /// `seek` with where to, in milliseconds.
  static Stream<(String, int?)> get mediaActions {
    _listen();
    return _mediaActions.stream;
  }

  static final _mediaActions = StreamController<(String, int?)>.broadcast();

  /// This install's Firebase push token (null without Google Play services).
  static Future<String?> pushToken() => _call<String>('pushToken');

  /// This phone's screen in landscape (long side first), in pixels.
  static Future<(int, int)?> screenSize() async {
    final s = await _call<Map>('screenSize');
    return s == null
        ? null
        : ((s['width'] as num).toInt(), (s['height'] as num).toInt());
  }

  /// Keeps the screen from timing out while a display or a computer's screen
  /// shows, for [session]; on until every session lets go.
  static Future<void> keepScreenOn(String session, {required bool on}) =>
      _call<void>('keepScreenOn', {'session': session, 'on': on});

  /// Android 15's screen share protections: `on`, `off`, `unknown`, or null
  /// before Android 15.
  static Future<String?> shareProtections() =>
      _call<String>('shareProtections');

  /// Developer options (or About phone while they're off).
  static Future<void> developerOptions() => _call<void>('developerOptions');

  /// [path] as a JPEG small enough to send as a device picture
  /// (≤ 128 KiB), base64.
  static Future<String?> pictureJpeg(String path) =>
      _call<String>('pictureJpeg', {'path': path});

  /// Puts the file at [path] on Android's clipboard (an image, a file).
  static Future<bool> clipboardFile(String path) async =>
      await _call<bool>('clipboardFile', {'path': path}) ?? false;

  /// One fresh location fix, or why not (`error`).
  static Future<
    ({double lat, double lon, double? accuracy, DateTime at, String? error})
  >
  locate() async {
    final r = await _call<Map>('locate');
    if (r == null || r['error'] is String) {
      return (
        lat: 0.0,
        lon: 0.0,
        accuracy: null,
        at: DateTime.now(),
        error: (r?['error'] as String?) ?? 'This phone can’t tell where it is.',
      );
    }
    return (
      lat: (r['lat'] as num).toDouble(),
      lon: (r['lon'] as num).toDouble(),
      accuracy: (r['accuracy'] as num?)?.toDouble(),
      at: DateTime.fromMillisecondsSinceEpoch((r['at'] as num).toInt()),
      error: null,
    );
  }

  /// The local port of the USB cable's bridge each time a computer is
  /// plugged in as an accessory (docs/protocol.md §4.11).
  static Stream<int> get usbPorts {
    _listen();
    return _usbPorts.stream;
  }

  static final _logs = StreamController<String>.broadcast();

  /// Lines for the Logs page from Android's side: the video encoder, the
  /// camera, the screen capture.
  static Stream<String> get logs {
    _listen();
    return _logs.stream;
  }

  /// A cable plugged in before the app was listening.
  static Future<int?> usbPort() => _call<int>('usbPort');

  /// "Ring my phone": the alarm sound at full volume until [stopRing].
  static Future<void> startRing() => _call<void>('startRing');

  static Future<void> stopRing() => _call<void>('stopRing');

  /// Android's own screen capture prompt, for [session]. True if allowed.
  static Future<bool> requestScreenCapture(String session) async =>
      await _call<bool>('requestScreenCapture', {'session': session}) ?? false;

  /// The camera permission. True if granted.
  static Future<bool> requestCamera() async =>
      await _call<bool>('requestCamera') ?? false;

  /// Starts encoding the screen or camera into [session] (a foreground
  /// service, so it goes on in other apps). `control` also plays the other
  /// side's input.
  static Future<void> startShare(
    String session,
    String kind,
    String peer,
    String peerId,
  ) => _call<void>('startShare', {
    'session': session,
    'kind': kind,
    'peer': peer,
    'peerId': peerId,
  });

  /// Shares Android's service runs now: (session, kind, peer id). The app
  /// may have restarted while one went on.
  static Future<List<(String, String, String)>> activeShares() async => [
    for (final m
        in (await _call<List<Object?>>('activeShares') ?? const [])
            .cast<Map<Object?, Object?>>())
      (m['session'] as String, m['kind'] as String, m['peer'] as String),
  ];

  static Future<void> stopShare(String session) =>
      _call<void>('stopShare', {'session': session});

  /// What's allowed now. Null without an Android side (tests).
  static Future<({bool notifications, bool camera})?> permissions() async {
    final m = await _call<Map<Object?, Object?>>('permissions');
    if (m == null) return null;
    return (
      notifications: m['notifications'] == true,
      camera: m['camera'] == true,
    );
  }

  /// True the first time it's asked on this install (then false), for the
  /// permissions sheet shown on first launch.
  static Future<bool> firstPermissionsVisit() async =>
      await _call<bool>('firstPermissionsVisit') ?? false;

  /// Android's own permission dialog for `camera`, `notifications`,
  /// `microphone`, `location` or `nearby` (Wi-Fi Direct) (or
  /// Linksy's app settings once Android stops showing it). True if granted.
  static Future<bool> requestPermission(String name) async =>
      await _call<bool>('requestPermission', {'name': name}) ?? false;

  /// App-private storage (identity, history) and the app's own external
  /// folder (received files). The same folders path_provider gave before.
  static Future<({String support, String? external})?> paths() async {
    final m = await _call<Map<Object?, Object?>>('paths');
    if (m == null) return null;
    return (
      support: m['support'] as String,
      external: m['external'] as String?,
    );
  }

  /// Android's document picker; returns copies' paths (empty if cancelled).
  static Future<List<String>> pickFiles() async =>
      (await _call<List<Object?>>('pickFiles'))?.cast<String>() ?? const [];

  /// Android's photo picker, many photos and videos at once; returns
  /// copies' paths (empty if cancelled).
  static Future<List<String>> pickMedia() async =>
      (await _call<List<Object?>>('pickMedia'))?.cast<String>() ?? const [];

  /// Opens a received file in another app: `done`, `missing` or `noApp`.
  static Future<String> openFile(String path) async =>
      await _call<String>('openFile', {'path': path}) ?? 'noApp';

  /// Opens an `http(s)` link in the phone's browser. False if nothing can.
  static Future<bool> openUrl(String url) async =>
      await _call<bool>('openUrl', {'url': url}) ?? false;

  /// Starts the pairing QR scanner: its preview texture, the camera's frame
  /// size and how far the camera is turned from upright.
  static Future<({int texture, double width, double height, int rotation})?>
  startScanner() async {
    final m = await _call<Map<Object?, Object?>>('startScanner');
    if (m == null) return null;
    return (
      texture: m['texture'] as int,
      width: (m['width'] as num).toDouble(),
      height: (m['height'] as num).toDouble(),
      rotation: m['rotation'] as int,
    );
  }

  static Future<void> stopScanner() => _call<void>('stopScanner');

  static Future<void> scannerTorch(bool on) =>
      _call<void>('scannerTorch', {'on': on});

  /// Text of each QR code the scanner reads.
  static Stream<String> get qrCodes {
    _listen();
    return _qrCodes.stream;
  }

  /// The scanner's camera failing.
  static Stream<String> get scannerErrors {
    _listen();
    return _scannerErrors.stream;
  }

  /// Decodes a second-display session; returns the texture id to show.
  static Future<int?> startDisplay(String session) =>
      _call<int>('startDisplay', {'session': session});

  static Future<void> stopDisplay(String session) =>
      _call<void>('stopDisplay', {'session': session});

  /// Framed input messages for a second display (u32 length + JSON each).
  static Future<void> displayInput(String session, Uint8List frames) =>
      _call<void>('displayInput', {'session': session, 'frames': frames});

  /// Links that arrive while the app is running.
  static Stream<String> get links {
    _listen();
    return _links.stream;
  }

  /// A second display's video size once known: (session, width, height).
  static Stream<(String, double, double)> get displaySizes {
    _listen();
    return _displaySizes.stream;
  }

  /// A second display whose video stopped.
  static Stream<String> get displaysEnded {
    _listen();
    return _displaysEnded.stream;
  }
}
