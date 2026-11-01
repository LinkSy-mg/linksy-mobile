import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../src/rust/api/node.dart' as rust;
import '../ui/l10n.dart';
import '../src/rust/frb_generated.dart';
import 'core_json.dart';
import 'linksy_node.dart';
import 'models.dart';

/// [LinksyNode] on linksy-core itself, through the Rust bridge (rust/). This
/// is the node the app runs on; [DemoNode] is for tests and UI work.
class RustNode implements LinksyNode {
  RustNode._(this._node) {
    _events = _node
        .events()
        .map((raw) {
          final j = jsonDecode(raw) as Json;
          final event = eventFromJson(j);
          // Being controlled needs an accessibility service on Android, which
          // gets sideloaded apps blocked at install; this phone doesn't offer
          // it. That, or a kind this app doesn't know: say "can't" straight
          // away rather than leave the other device waiting.
          // `input` goes the other way (this phone drives a computer).
          if (j['type'] == 'session_request' &&
              (event == null ||
                  j['kind'] == 'control' ||
                  j['kind'] == 'input')) {
            _node.declineUnsupported(request: j['request'] as String);
            return null;
          }
          return event;
        })
        .where((e) => e != null)
        .cast<LinksyEvent>()
        .asBroadcastStream();
  }

  final rust.LinksyNode _node;
  late final Stream<LinksyEvent> _events;

  /// Loads the native library and starts this phone's node. Identity and
  /// paired devices live in [dataDir], which must be app-private.
  static Future<RustNode> start({
    required String dataDir,
    required String downloadDir,
    required String name,
    required List<String> features,
    required bool away,
    String? relay,
  }) async {
    await RustLib.init();
    final node = await _guard(
      () => rust.startNode(
        dataDir: dataDir,
        downloadDir: downloadDir,
        name: name,
        features: features,
        away: away,
        relay: relay,
      ),
    );
    return RustNode._(node);
  }

  /// The port other devices reach this phone on, for "pair by address".
  @override
  int get port => _node.port();

  @override
  DeviceInfo get info => deviceFromJson(jsonDecode(_node.infoJson()) as Json);

  @override
  Stream<LinksyEvent> get events => _events;

  @override
  Future<List<DeviceView>> devices() async => _devices();

  List<DeviceView> _devices() => [
    for (final j in (jsonDecode(_node.devicesJson()) as List).cast<Json>())
      deviceViewFromJson(j),
  ];

  String _nameOf(String id) =>
      _devices().where((v) => v.device.id == id).firstOrNull?.device.name ??
      tr.errorThatDevice;

  @override
  Future<void> pairDevice(String id) =>
      _guard(() => _node.pairDevice(id: id), name: _nameOf(id));

  @override
  Future<void> pairAddress(String address) => _guard(
    () => _node.pairAddress(address: address),
    name: tr.errorDeviceAt(address),
  );

  @override
  Future<void> pairWithInvite(String uri) =>
      _guard(() => _node.pairWithInvite(uri: uri), name: tr.errorThatDevice);

  @override
  Future<void> respond(String requestId, {required bool accept}) async {
    _node.respond(request: requestId, accept: accept);
  }

  @override
  Future<void> respondDisplay(
    String requestId, {
    required bool accept,
    required int width,
    required int height,
  }) async {
    _node.respondDisplay(
      request: requestId,
      accept: accept,
      width: width,
      height: height,
    );
  }

  @override
  Future<void> sendPicture(String id, String image) => _guard(
    () => _node.sendPicture(id: id, image: image),
    name: _nameOf(id),
  );

  @override
  Future<void> watchClipboard(String id, {required bool on}) => _guard(
    () => _node.watchClipboard(id: id, on_: on),
    name: _nameOf(id),
  );

  @override
  Future<String> sendClipboardFile(String id, String path) => _guard(
    () => _node.sendClipboardFile(id: id, path: path),
    name: _nameOf(id),
  );

  @override
  Future<void> sendLocation(
    String id, {
    required double lat,
    required double lon,
    double? accuracyM,
    required DateTime at,
  }) => _guard(
    () => _node.sendLocation(
      id: id,
      lat: lat,
      lon: lon,
      accuracyM: accuracyM,
      atMs: BigInt.from(at.millisecondsSinceEpoch),
    ),
    name: _nameOf(id),
  );

  @override
  Future<void> refuseLocation(String id, String reason) => _guard(
    () => _node.refuseLocation(id: id, reason: reason),
    name: _nameOf(id),
  );

  @override
  Future<void> setAwayAll(String id, {required bool on}) => _guard(
    () async => _node.setAwayAll(id: id, on_: on),
    name: _nameOf(id),
  );

  @override
  Future<void> connectAway(String id) =>
      _guard(() => _node.connectAway(id: id), name: _nameOf(id));

  @override
  Future<void> connectAddress(String address) => _guard(
    () => _node.connectAddress(address: address),
    name: tr.errorComputerOnCable,
  );

  @override
  Future<String> sendFiles(String id, List<String> paths) => _guard(
    () => _node.sendFiles(id: id, paths: paths),
    name: _nameOf(id),
  );

  @override
  Future<void> cancel(String transferId) async {
    _node.cancel(transfer: transferId);
  }

  @override
  Future<void> sendClipboard(String id, String text) => _guard(
    () => _node.sendClipboard(id: id, text: text),
    name: _nameOf(id),
  );

  @override
  Future<void> notify(String id, String title, String body) => _guard(
    () => _node.notify(id: id, title: title, body: body),
    name: _nameOf(id),
  );

  @override
  Future<void> openUrl(String id, String url) => _guard(
    () => _node.openUrl(id: id, url: url),
    name: _nameOf(id),
  );

  @override
  Future<void> sendBattery(String id, Battery battery) => _guard(
    () => _node.sendBattery(
      id: id,
      level: battery.level,
      charging: battery.charging,
    ),
    name: _nameOf(id),
  );

  @override
  Future<void> ring(String id, {required bool on}) => _guard(
    () => _node.ring(id: id, on_: on),
    name: _nameOf(id),
  );

  @override
  Future<String> startInput(String id) =>
      _guard(() => _node.startInput(id: id), name: _nameOf(id));

  @override
  Future<String> startView(
    String id, {
    required bool control,
    bool choose = false,
  }) => _guard(
    () => _node.startView(id: id, control: control, choose: choose),
    name: _nameOf(id),
  );

  @override
  Future<bool> sessionWrite(String session, Uint8List bytes) =>
      _node.sessionWrite(session: session, bytes: bytes);

  @override
  Future<void> watchMedia(String id, {required bool on}) => _guard(
    () => _node.watchMedia(id: id, on_: on),
    name: _nameOf(id),
  );

  @override
  Future<void> watchVolume(String id, {required bool on}) => _guard(
    () => _node.watchVolume(id: id, on_: on),
    name: _nameOf(id),
  );

  @override
  Future<void> setVolume(String id, {double? level, bool? muted}) => _guard(
    () => _node.setVolume(id: id, level: level, muted: muted),
    name: _nameOf(id),
  );

  @override
  Future<void> mediaCommand(
    String id,
    String player,
    Map<String, Object> command,
  ) => _guard(
    () => _node.mediaCommand(
      id: id,
      player: player,
      commandJson: jsonEncode(command),
    ),
    name: _nameOf(id),
  );

  @override
  Future<void> directSend(String id, Map<String, Object?> step) => _guard(
    () => _node.directSend(id: id, step: jsonEncode(step)),
    name: _nameOf(id),
  );

  @override
  void networkChanged() => _node.networkChanged();

  @override
  Future<void> directDial(String id, String address) => _guard(
    () => _node.directDial(id: id, addr: address),
    name: _nameOf(id),
  );

  @override
  Future<void> directLink(String id) =>
      _guard(() => _node.directLink(id: id), name: _nameOf(id));

  @override
  Future<void> sendCallState(String id, String state) => _guard(
    () => _node.sendCallState(id: id, state: state),
    name: _nameOf(id),
  );

  @override
  Future<String> importFiles(String id, List<String> paths) => _guard(
    () => _node.importFiles(id: id, paths: paths),
    name: _nameOf(id),
  );

  // Terminal (§4.15): a session whose output comes to Dart and which takes
  // framed `term_*` messages.

  @override
  Future<TerminalChannel> openTerminal(
    String id, {
    required String code,
    required int cols,
    required int rows,
    String? resume,
  }) async {
    final name = _nameOf(id);
    try {
      final j = jsonDecode(
        await _node.openTerminal(
          id: id,
          code: code,
          cols: cols.clamp(1, 1000),
          rows: rows.clamp(1, 1000),
          resume: resume,
        ),
      ) as Json;
      return _RustTerminal(
        _node,
        j['session'] as String,
        j['terminal'] as String? ?? '',
      );
    } on Object catch (e) {
      final error = e is String ? e : '$e';
      throw TerminalRefused.parse(error, name) ??
          LinksyException(describeCoreError(error, name));
    }
  }

  @override
  Future<List<RemoteTerminal>> terminals(String id) async {
    final raw = await _guard(() => _node.terminals(id: id), name: _nameOf(id));
    return [
      for (final t in (jsonDecode(raw) as List).cast<Json>())
        RemoteTerminal(
          id: t['id'] as String,
          title: t['title'] as String? ?? tr.ctlTerminalTitle,
          started: DateTime.fromMillisecondsSinceEpoch(
            (t['started_ms'] as num? ?? 0).toInt(),
          ),
        ),
    ];
  }

  @override
  Future<NodeSettings> settings() async =>
      settingsFromJson(jsonDecode(_node.settingsJson()) as Json);

  @override
  Future<void> updateSettings(NodeSettings settings) => _guard(
    () => _node.updateSettings(
      settingsJson: jsonEncode(settingsToJson(settings)),
    ),
  );

  @override
  Future<void> forget(String id) =>
      _guard(() async => _node.forget(id: id), name: _nameOf(id));

  @override
  void pairingMode(bool on) => _node.pairingMode(on_: on);

  @override
  Future<void> declineUnsupported(String request) async =>
      _node.declineUnsupported(request: request);

  @override
  Future<void> endSession(String session) async =>
      _node.endSession(session: session);

  @override
  Future<void> shutdown() => _node.shutdown();

  /// Runs a bridge call, turning the core's error kinds into sentences that
  /// name the device.
  static Future<T> _guard<T>(
    FutureOr<T> Function() call, {
    String? name,
  }) async {
    try {
      return await call();
    } on LinksyException {
      rethrow;
    } on Object catch (e) {
      final error = e is String ? e : '$e';
      throw LinksyException(
        describeCoreError(error, name ?? tr.errorOtherDevice),
        kind: error.split(':').first,
      );
    }
  }
}

/// A terminal over a session: output from the core, input framed as u32
/// big-endian length + JSON (`term_input`, `term_resize`, `term_close`).
class _RustTerminal implements TerminalChannel {
  _RustTerminal(this._node, this._session, this.terminalId)
    : output = _node.terminalOutput(session: _session);

  final rust.LinksyNode _node;
  final String _session;

  @override
  final String terminalId;

  @override
  final Stream<Uint8List> output;

  Future<bool> _send(Map<String, Object> message) {
    final body = utf8.encode(jsonEncode(message));
    final frame = BytesBuilder(copy: false)
      ..add((ByteData(4)..setUint32(0, body.length)).buffer.asUint8List())
      ..add(body);
    return _node.sessionWrite(session: _session, bytes: frame.takeBytes());
  }

  @override
  Future<bool> input(String data) =>
      _send({'type': 'term_input', 'data': data});

  @override
  Future<bool> resize(int cols, int rows) =>
      _send({'type': 'term_resize', 'cols': cols, 'rows': rows});

  /// `term_close`, then this side of the stream: queued in order, so the
  /// computer gets the close before the end.
  @override
  Future<void> close() async {
    await _send({'type': 'term_close'});
    _node.endSession(session: _session);
  }

  /// Just this side of the stream: the shell stays, detached.
  @override
  Future<void> detach() async => _node.endSession(session: _session);
}

/// `unreachable`, `declined`, `invalid:…` and so on, as the user should read
/// them.
String describeCoreError(String error, String name) {
  final colon = error.indexOf(':');
  final kind = colon < 0 ? error : error.substring(0, colon);
  final detail = colon < 0 ? '' : error.substring(colon + 1).trim();
  return switch (kind) {
    'unreachable' => tr.errorUnreachable(name),
    'declined' => tr.errorDeclined(name),
    'timeout' => tr.errorTimeout(name),
    'not_paired' => tr.errorNotPaired(name),
    'unsupported' => tr.errorUnsupported(name),
    'not_from_away' => tr.errorNotFromAway(name),
    'invalid' => detail.isEmpty ? tr.errorInvalid : detail,
    _ =>
      detail.isEmpty
          ? tr.errorSomethingWrong
          : tr.errorSomethingWrongDetail(detail),
  };
}
