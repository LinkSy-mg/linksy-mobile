import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'invite.dart';
import 'linksy_node.dart';
import 'models.dart';

/// An in-memory node with made-up devices, so the app runs before the Rust
/// bridge exists. Transfers, pairing and presence are simulated.
class DemoNode implements LinksyNode {
  DemoNode({required String name, required String downloadDir})
    : _settings = NodeSettings(
        name: name,
        downloadDir: downloadDir,
        stayConnected: false,
        autoAccept: false,
      ),
      info = DeviceInfo(
        id: _fakeId(name),
        name: name,
        kind: DeviceKind.phone,
        os: 'android',
      ) {
    for (final v in _seed) {
      _devices[v.device.id] = v;
    }
  }

  @override
  DeviceInfo info;

  NodeSettings _settings;
  final _events = StreamController<LinksyEvent>.broadcast();
  final _devices = <String, DeviceView>{};
  final _random = Random();
  final _pendingPairings = <String, DeviceInfo>{};
  final _timers = <String, Timer>{};
  final _cancelled = <String>{};

  static final _seed = [
    DeviceView(
      device: DeviceInfo(
        id: _fakeId('Studio Desktop'),
        name: 'Studio Desktop',
        kind: DeviceKind.desktop,
        os: 'linux',
        features: [
          'files',
          'clipboard',
          'open_url',
          'ring',
          'screen',
          'control',
          'display',
          'camera',
          'microphone',
          'terminal',
          'deck',
        ],
      ),
      trusted: true,
      connected: false,
      nearby: true,
    ),
    DeviceView(
      device: DeviceInfo(
        id: _fakeId('ThinkPad'),
        name: 'ThinkPad',
        kind: DeviceKind.laptop,
        os: 'linux',
      ),
      trusted: true,
      connected: false,
      nearby: false,
    ),
    DeviceView(
      device: DeviceInfo(
        id: _fakeId('Living Room PC'),
        name: 'Living Room PC',
        kind: DeviceKind.desktop,
        os: 'linux',
      ),
      trusted: false,
      connected: false,
      nearby: true,
    ),
  ];

  static String _fakeId(String seed) {
    var h = seed.hashCode & 0x7fffffff;
    final buf = StringBuffer();
    while (buf.length < 64) {
      h = (h * 1103515245 + 12345) & 0x7fffffff;
      buf.write((h % 16).toRadixString(16));
    }
    return buf.toString();
  }

  String _code() => _random.nextInt(1000000).toString().padLeft(6, '0');

  String _uuid() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  void _emit(LinksyEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  void _setConnected(String id, bool connected) {
    final v = _devices[id];
    if (v == null || v.connected == connected) return;
    _devices[id] = DeviceView(
      device: v.device,
      trusted: v.trusted,
      connected: connected,
      nearby: v.nearby || connected,
    );
    _emit(connected ? Connected(id) : Disconnected(id));
  }

  DeviceView _reachable(String id) {
    final v = _devices[id];
    if (v == null || !v.nearby) {
      final name = v?.device.name ?? 'That device';
      throw LinksyException(
        "$name isn't reachable. Check that it's on and on this network.",
      );
    }
    return v;
  }

  @override
  Stream<LinksyEvent> get events => _events.stream;

  @override
  Future<List<DeviceView>> devices() async => _devices.values.toList();

  @override
  Future<void> pairDevice(String id) async {
    final v = _reachable(id);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final request = _uuid();
    _pendingPairings[request] = v.device;
    _emit(
      PairingRequest(
        request: request,
        device: v.device,
        code: _code(),
        incoming: false,
      ),
    );
  }

  @override
  Future<void> pairAddress(String address) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final unpaired = _devices.values.where((v) => !v.trusted && v.nearby);
    if (unpaired.isEmpty) {
      throw LinksyException("Nothing answered at $address.");
    }
    await pairDevice(unpaired.first.device.id);
  }

  @override
  Future<void> pairWithInvite(String uri) async {
    final invite = Invite.tryParse(uri);
    if (invite == null) throw LinksyException("That's not a Linksy QR code.");
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final device = DeviceInfo(
      id: invite.id,
      name: invite.name.isEmpty ? shortDeviceId(invite.id) : invite.name,
      kind: DeviceKind.desktop,
      os: 'linux',
    );
    _devices[device.id] = DeviceView(
      device: device,
      trusted: true,
      connected: true,
      nearby: true,
    );
    _emit(Paired(device));
  }

  @override
  Future<void> respond(String requestId, {required bool accept}) async {
    final pairing = _pendingPairings.remove(requestId);
    if (pairing != null) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!accept) {
        _emit(PairingFailed(device: pairing, reason: 'Declined'));
        return;
      }
      final v = _devices[pairing.id];
      _devices[pairing.id] = DeviceView(
        device: pairing,
        trusted: true,
        connected: true,
        nearby: true,
      );
      if (v == null) _emit(DeviceFound(pairing));
      _emit(Paired(pairing));
      return;
    }
    final incoming = _pendingIncoming.remove(requestId);
    if (incoming != null) {
      if (!accept) return;
      _runTransfer(requestId, incoming.$1.id, incoming.$2, received: true);
    }
  }

  final _pendingIncoming = <String, (DeviceInfo, List<OfferedFile>)>{};

  @override
  Future<String> sendFiles(String id, List<String> paths) async {
    _reachable(id);
    final transfer = _uuid();
    final files = [
      for (final p in paths)
        OfferedFile(path: p.split('/').last, size: _sizeOf(p)),
    ];
    _setConnected(id, true);
    // "Waiting for … to accept" for a moment, then progress.
    _timers[transfer] = Timer(const Duration(milliseconds: 1500), () {
      _runTransfer(transfer, id, files, received: false);
    });
    return transfer;
  }

  int _sizeOf(String path) {
    try {
      return File(path).lengthSync();
    } on FileSystemException {
      return 4 * 1024 * 1024;
    }
  }

  void _runTransfer(
    String transfer,
    String peer,
    List<OfferedFile> files, {
    required bool received,
  }) {
    if (_cancelled.remove(transfer)) return;
    final total = files.fold<int>(0, (s, f) => s + f.size);
    _emit(
      TransferStarted(
        transfer,
        peer: _devices[peer]?.device,
        incoming: received,
        files: files,
        total: total,
      ),
    );
    // About three seconds whatever the size, in ten steps.
    var sent = 0;
    _timers[transfer] = Timer.periodic(const Duration(milliseconds: 300), (t) {
      sent = min(total, sent + (total / 10).ceil());
      _emit(TransferProgress(transfer: transfer, bytes: sent, total: total));
      if (sent >= total) {
        t.cancel();
        _timers.remove(transfer);
        _emit(
          TransferComplete(
            transfer: transfer,
            saved: received
                ? [for (final f in files) '${_settings.downloadDir}/${f.name}']
                : const [],
          ),
        );
      }
    });
  }

  @override
  Future<void> cancel(String transferId) async {
    _timers.remove(transferId)?.cancel();
    _cancelled.add(transferId);
    _emit(TransferFailed(transfer: transferId, reason: 'Cancelled'));
  }

  @override
  Future<void> sendClipboard(String id, String text) async {
    _reachable(id);
    _setConnected(id, true);
  }

  @override
  Future<void> notify(String id, String title, String body) async {
    _reachable(id);
    _setConnected(id, true);
  }

  @override
  Future<void> openUrl(String id, String url) async {
    _reachable(id);
    _setConnected(id, true);
  }

  @override
  Future<void> sendBattery(String id, Battery battery) async {}

  @override
  Future<void> ring(String id, {required bool on}) async {
    _reachable(id);
    _setConnected(id, true);
  }

  @override
  Future<String> startInput(String id) async {
    _reachable(id);
    _setConnected(id, true);
    final session = _uuid();
    _emit(
      SessionStarted(
        session: session,
        peer: _devices[id]!.device,
        kind: SessionKind.input,
        sharing: true,
      ),
    );
    return session;
  }

  @override
  Future<String> startView(
    String id, {
    required bool control,
    bool choose = false,
  }) async {
    _reachable(id);
    _setConnected(id, true);
    final session = _uuid();
    _emit(
      SessionStarted(
        session: session,
        peer: _devices[id]!.device,
        kind: control ? SessionKind.control : SessionKind.screen,
        sharing: false,
      ),
    );
    return session;
  }

  @override
  Future<bool> sessionWrite(String session, Uint8List bytes) async => true;

  @override
  Future<void> watchMedia(String id, {required bool on}) async {}

  @override
  Future<void> watchVolume(String id, {required bool on}) async {}

  @override
  Future<void> setVolume(String id, {double? level, bool? muted}) async {}

  @override
  Future<void> mediaCommand(
    String id,
    String player,
    Map<String, Object> command,
  ) async {}

  @override
  Future<void> sendCallState(String id, String state) async {}

  @override
  Future<void> setFeatures(List<String> features) async {}

  @override
  Future<void> postNotification(
    String id,
    Map<String, Object?> notification,
  ) async {}

  @override
  Future<void> removeNotification(
    String id,
    String key, {
    bool replyKept = false,
  }) async {}

  @override
  Future<void> inboxHistoryPage(
    String id,
    String app,
    String conversation,
    String messagesJson, {
    required bool more,
  }) async {}

  // The deck (§4.19): what a desktop offers, and its state as it's run.

  static const _deck = [
    DeckAction(
      id: 'media.play_pause',
      name: 'Play or Pause',
      kind: DeckKind.button,
      group: 'Media',
    ),
    DeckAction(
      id: 'media.previous',
      name: 'Previous',
      kind: DeckKind.button,
      group: 'Media',
    ),
    DeckAction(
      id: 'media.next',
      name: 'Next',
      kind: DeckKind.button,
      group: 'Media',
    ),
    DeckAction(
      id: 'sound.volume',
      name: 'Volume',
      kind: DeckKind.slider,
      group: 'Sound',
    ),
    DeckAction(
      id: 'sound.mute',
      name: 'Mute',
      kind: DeckKind.toggle,
      group: 'Sound',
    ),
    DeckAction(
      id: 'sound.mic_mute',
      name: 'Mute microphone',
      kind: DeckKind.toggle,
      group: 'Sound',
    ),
    DeckAction(
      id: 'system.lock',
      name: 'Lock',
      kind: DeckKind.button,
      group: 'System',
    ),
    DeckAction(
      id: 'command.backup',
      name: 'Backup',
      kind: DeckKind.button,
      group: 'Commands',
    ),
  ];

  final _deckState = <String, DeckState>{
    'sound.volume': const DeckState(id: 'sound.volume', value: 0.42),
    'sound.mute': const DeckState(id: 'sound.mute', on: false),
    'sound.mic_mute': const DeckState(id: 'sound.mic_mute', on: false),
  };

  @override
  Future<void> deckOpen(String id, {required bool open}) async {
    final from = _devices[id]?.device;
    if (!open || from == null) return;
    _emit(DeckActionsReceived(from: from, actions: _deck));
    _emit(DeckStateReceived(from: from, states: _deckState.values.toList()));
  }

  @override
  Future<void> deckRun(String id, String action, {double? value}) async {
    final from = _devices[id]?.device;
    if (from == null) return;
    final now = _deckState[action];
    if (value != null) {
      _deckState[action] = DeckState(id: action, value: value);
    } else if (now?.on != null) {
      _deckState[action] = DeckState(id: action, on: !now!.on!);
    } else {
      return;
    }
    _emit(DeckStateReceived(from: from, states: [_deckState[action]!]));
  }

  @override
  Future<void> directSend(String id, Map<String, Object?> step) async {}

  @override
  void networkChanged() {}

  @override
  Future<void> directDial(String id, String address) async {}

  @override
  Future<void> directLink(String id) async {}

  @override
  int get port => 0;

  @override
  Future<String> importFiles(String id, List<String> paths) =>
      sendFiles(id, paths);

  @override
  Future<NodeSettings> settings() async => _settings;

  @override
  Future<void> updateSettings(NodeSettings settings) async {
    _settings = settings;
    info = info.copyWith(name: settings.name);
    _emit(SettingsChanged(settings));
  }

  @override
  void pairingMode(bool on) {}

  @override
  Future<void> forget(String id) async {
    final v = _devices[id];
    if (v == null) return;
    if (v.nearby) {
      _devices[id] = DeviceView(
        device: v.device,
        trusted: false,
        connected: false,
        nearby: true,
      );
      _emit(DeviceUpdated(v.device));
    } else {
      _devices.remove(id);
      _emit(DeviceLost(id));
    }
  }

  @override
  Future<void> declineUnsupported(String request) async {}

  @override
  Future<void> endSession(String session) async => _emit(SessionEnded(session));

  @override
  Future<void> respondDisplay(
    String requestId, {
    required bool accept,
    required int width,
    required int height,
  }) => respond(requestId, accept: accept);

  @override
  Future<void> sendPicture(String id, String image) async {}

  @override
  Future<void> watchClipboard(String id, {required bool on}) async {}

  @override
  Future<String> sendClipboardFile(String id, String path) =>
      sendFiles(id, [path]);

  @override
  Future<void> sendLocation(
    String id, {
    required double lat,
    required double lon,
    double? accuracyM,
    required DateTime at,
  }) async {}

  @override
  Future<void> refuseLocation(String id, String reason) async {}

  @override
  Future<void> setAwayAll(String id, {required bool on}) async {}

  @override
  Future<void> connectAway(String id) async {}

  @override
  Future<void> connectAddress(String address) async {}

  // Terminal (§4.15): a pretend shell, code 123456, so the screens can be
  // tried without a computer that has terminals.

  static const demoTerminalCode = '123456';
  int _terminalTries = 5;
  final _shells = <String, _DemoShell>{};

  @override
  Future<TerminalChannel> openTerminal(
    String id, {
    required String code,
    required int cols,
    required int rows,
    String? resume,
  }) async {
    final v = _reachable(id);
    final name = v.device.name;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!v.device.features.contains('terminal')) {
      throw TerminalRefused(TerminalRefusal.unsupported, name: name);
    }
    if (_terminalTries <= 0) {
      throw TerminalRefused(TerminalRefusal.locked, name: name);
    }
    if (code != demoTerminalCode) {
      _terminalTries--;
      throw _terminalTries <= 0
          ? TerminalRefused(TerminalRefusal.locked, name: name)
          : TerminalRefused(
              TerminalRefusal.code,
              triesLeft: _terminalTries,
              name: name,
            );
    }
    _terminalTries = 5;
    final old = resume == null ? null : _shells[resume];
    if (old != null) return old..attach();
    final shell = _DemoShell(
      _uuid(),
      onExit: (s) => _shells.remove(s.terminalId),
    );
    _shells[shell.terminalId] = shell;
    return shell..attach();
  }

  @override
  Future<List<RemoteTerminal>> terminals(String id) async => [
    for (final s in _shells.values)
      if (s.detached)
        RemoteTerminal(id: s.terminalId, title: s.title, started: s.started),
  ];

  @override
  Future<void> shutdown() async {
    for (final t in _timers.values) {
      t.cancel();
    }
    await _events.close();
  }

  // Demo-only triggers for the flows that start on the other device.

  void simulateIncomingFiles() {
    final from = _devices.values.firstWhere((v) => v.trusted).device;
    final transfer = _uuid();
    final files = [
      const OfferedFile(path: 'Holiday/IMG_2041.jpg', size: 3400000),
      const OfferedFile(path: 'Holiday/IMG_2042.jpg', size: 2900000),
      const OfferedFile(path: 'Holiday/notes.txt', size: 1200),
    ];
    _pendingIncoming[transfer] = (from, files);
    _setConnected(from.id, true);
    if (_settings.autoAccept) {
      _pendingIncoming.remove(transfer);
      _runTransfer(transfer, from.id, files, received: true);
      return;
    }
    _emit(
      TransferRequest(
        transfer: transfer,
        from: from,
        files: files,
        total: files.fold(0, (s, f) => s + f.size),
      ),
    );
  }

  void simulateIncomingPairing() {
    final v = _devices.values.where((v) => !v.trusted && v.nearby).firstOrNull;
    if (v == null) return;
    final request = _uuid();
    _pendingPairings[request] = v.device;
    _emit(
      PairingRequest(
        request: request,
        device: v.device,
        code: _code(),
        incoming: true,
      ),
    );
  }

  /// A computer's "Ask the Phone", in a moment: time to leave the app and
  /// see its notification instead.
  void simulateTurnOn(String feature) {
    final from = _devices.values.firstWhere((v) => v.trusted).device;
    _setConnected(from.id, true);
    Timer(const Duration(seconds: 4), () {
      _emit(TurnOnRequested(from: from, feature: feature));
    });
  }

  void simulateClipboard() {
    final from = _devices.values.firstWhere((v) => v.trusted).device;
    _setConnected(from.id, true);
    _emit(
      ClipboardReceived(from: from, text: 'https://linksy.app/docs/pairing'),
    );
  }
}

/// A pretend shell for demo mode: echoes, edits a line, knows a few
/// commands. Nothing runs anywhere.
class _DemoShell implements TerminalChannel {
  _DemoShell(this.terminalId, {required this.onExit});

  @override
  final String terminalId;
  final void Function(_DemoShell) onExit;
  final started = DateTime.now();
  String title = 'bash — ~';
  bool detached = false;
  StreamController<Uint8List>? _out;
  final _line = StringBuffer();
  final _screen = StringBuffer();

  static const _prompt = '\x1b[1;34maxel@studio\x1b[0m:\x1b[1;36m~\x1b[0m\$ ';

  void attach() {
    detached = false;
    _out = StreamController<Uint8List>();
    if (_screen.isEmpty) {
      _say(
        '\x1b]0;bash — ~\x07'
        '\x1b[2mDemo terminal: nothing here runs on a computer. '
        'Try ls, top or help.\x1b[0m\r\n$_prompt',
      );
    } else {
      // Reattached: the computer redraws the screen.
      final again = _screen.toString();
      Future<void>.microtask(() => _out?.add(_utf8(again)));
    }
  }

  @override
  Stream<Uint8List> get output => _out!.stream;

  void _say(String text) {
    _screen.write(text);
    final out = _out;
    if (out != null && !out.isClosed) {
      Future<void>.microtask(() {
        if (!out.isClosed) out.add(_utf8(text));
      });
    }
  }

  static Uint8List _utf8(String s) => utf8.encode(s);

  @override
  Future<bool> input(String data) async {
    if (data.startsWith('\x1b')) return true; // arrows and such: ignored here
    for (final ch in data.split('')) {
      switch (ch) {
        case '\r':
          final cmd = _line.toString().trim();
          _line.clear();
          _say('\r\n');
          _run(cmd);
        case '\x7f':
          if (_line.isNotEmpty) {
            final t = _line.toString();
            _line
              ..clear()
              ..write(t.substring(0, t.length - 1));
            _say('\b \b');
          }
        case '\x03':
          _line.clear();
          _say('^C\r\n$_prompt');
        case '\t':
          break;
        default:
          if (ch.codeUnitAt(0) >= 0x20) {
            _line.write(ch);
            _say(ch);
          }
      }
    }
    return true;
  }

  void _run(String cmd) {
    final word = cmd.split(' ').first;
    final rest = cmd.length > word.length ? cmd.substring(word.length + 1) : '';
    switch (word) {
      case '':
        break;
      case 'help':
        _say('ls  pwd  date  whoami  echo  top  clear  exit\r\n');
      case 'ls':
        _say(
          '\x1b[1;34mDesktop\x1b[0m  \x1b[1;34mDocuments\x1b[0m  '
          '\x1b[1;34mProjects\x1b[0m  notes.md  \x1b[1;32mbuild.sh\x1b[0m\r\n',
        );
      case 'pwd':
        _say('/home/axel\r\n');
      case 'whoami':
        _say('axel\r\n');
      case 'date':
        _say('${DateTime.now()}\r\n');
      case 'echo':
        _say('$rest\r\n');
      case 'top':
        title = 'top — ~';
        _say('\x1b]0;top — ~\x07');
        _say(
          '\x1b[7m  PID USER      %CPU %MEM COMMAND             \x1b[0m\r\n'
          ' 2041 axel      \x1b[1;31m42.0\x1b[0m  3.1 cargo               \r\n'
          ' 1873 axel      \x1b[33m12.5\x1b[0m  8.4 firefox             \r\n'
          '  988 axel       \x1b[32m1.2\x1b[0m  0.9 linksyd             \r\n',
        );
      case 'clear':
        _screen.clear();
        _say('\x1b[2J\x1b[H');
      case 'exit':
        _end();
        return;
      default:
        _say('$word: command not found\r\n');
    }
    _say(_prompt);
  }

  void _end() {
    _out?.close();
    _out = null;
    onExit(this);
  }

  @override
  Future<bool> resize(int cols, int rows) async => true;

  @override
  Future<void> close() async => _end();

  @override
  Future<void> detach() async {
    detached = true;
    await _out?.close();
    _out = null;
  }
}
