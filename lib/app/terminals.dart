import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

import '../core/linksy_node.dart';
import '../core/models.dart';
import '../ui/l10n.dart';

/// Where a terminal tab stands.
enum TabState {
  /// Waiting for the code to be typed.
  locked,

  /// Asking the computer.
  opening,

  /// Running and attached.
  live,

  /// Still running on the computer, not attached here (left, or the
  /// connection dropped).
  detached,

  /// Its shell exited, or it was closed.
  ended,
}

/// One terminal on a computer, shown in a tab (docs/protocol.md §4.15). The screen
/// keeps its scrollback here while the page is closed.
class TerminalTab extends ChangeNotifier {
  TerminalTab(this.deviceId, this._node) {
    term.onOutput = _typed;
    term.onResize = (cols, rows, _, _) => _channel?.resize(cols, rows);
    term.onTitleChange = (t) {
      title = t;
      notifyListeners();
    };
  }

  final String deviceId;
  final LinksyNode _node;
  final term = Terminal(maxLines: 5000);
  TerminalChannel? _channel;
  StreamSubscription<String>? _sub;

  /// The computer's id for it, for `resume`.
  String? terminalId;
  String title = tr.ctlTerminalTitle;
  TabState state = TabState.locked;

  /// Ctrl or Alt pressed on the key bar: applies to the next key.
  bool ctrl = false;
  bool alt = false;
  bool _leaving = false;

  void _typed(String data) {
    var out = data;
    if (ctrl && out.length == 1) {
      final c = out.toLowerCase().codeUnitAt(0);
      if (c >= 0x61 && c <= 0x7a) out = String.fromCharCode(c & 0x1f);
      ctrl = false;
      notifyListeners();
    }
    if (alt) {
      out = '\x1b$out';
      alt = false;
      notifyListeners();
    }
    _channel?.input(out);
  }

  /// A key from the key bar, as its xterm sequence.
  void key(String sequence) => _typed(sequence);

  /// A key with no character (arrows, F1–F12, Home…), with Ctrl or Alt if
  /// on: the terminal writes it as the program asked, so arrows work in
  /// htop and vim too (application cursor mode).
  void special(TerminalKey k) {
    final withCtrl = ctrl, withAlt = alt;
    if (ctrl || alt) {
      ctrl = false;
      alt = false;
      notifyListeners();
    }
    // xterm 4.0.0 reads application cursor keys from the keypad mode
    // instead of `?1h`: a program that sets only that (or only the keypad
    // mode) would get the wrong arrows. Written here as that mode says.
    final app = switch (k) {
      TerminalKey.arrowUp => 'A',
      TerminalKey.arrowDown => 'B',
      TerminalKey.arrowRight => 'C',
      TerminalKey.arrowLeft => 'D',
      TerminalKey.home => 'H',
      TerminalKey.end => 'F',
      _ => null,
    };
    if (app != null && !withCtrl && !withAlt) {
      _typed(term.cursorKeysMode ? '\x1bO$app' : '\x1b[$app');
      return;
    }
    term.keyInput(k, ctrl: withCtrl, alt: withAlt);
  }

  void toggleCtrl() {
    ctrl = !ctrl;
    notifyListeners();
  }

  void toggleAlt() {
    alt = !alt;
    notifyListeners();
  }

  /// Opens (or reattaches with [resume]) using the computer's [code].
  /// Throws [LinksyException] (a [TerminalRefused] for the computer's no).
  Future<void> open(String code, {String? resume}) async {
    state = TabState.opening;
    notifyListeners();
    try {
      final channel = await _node.openTerminal(
        deviceId,
        code: code,
        cols: term.viewWidth,
        rows: term.viewHeight,
        resume: resume ?? terminalId,
      );
      _attach(channel);
    } on LinksyException {
      state = terminalId == null ? TabState.locked : TabState.detached;
      notifyListeners();
      rethrow;
    }
  }

  void _attach(TerminalChannel channel) {
    // A new shell, or a reattach (the computer redraws): a clean screen.
    term.write('\x1b[2J\x1b[H');
    _channel = channel;
    terminalId = channel.terminalId;
    _leaving = false;
    state = TabState.live;
    notifyListeners();
    _sub = channel.output
        .cast<List<int>>()
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen(term.write, onDone: _ended);
  }

  Future<void> _ended() async {
    final channel = _channel;
    _sub = null;
    _channel = null;
    if (state == TabState.ended) return;
    // Left on purpose, or the connection dropped while the shell runs on:
    // detached. Gone from the computer's list: it exited.
    // Can't ask (the link dropped): it runs on, as far as we know.
    final running =
        _leaving ||
        await _node
            .terminals(deviceId)
            .then((list) => list.any((t) => t.id == terminalId))
            .catchError((Object _) => true);
    if (running) {
      state = TabState.detached;
      notifyListeners();
      return;
    }
    // The shell exited (`exit`, Ctrl+D…): finish our side of the session too,
    // so nothing is left open, and the tab goes.
    state = TabState.ended;
    await channel?.detach().catchError((Object _) {});
    notifyListeners();
    onGone?.call(this);
  }

  /// Called once this tab's shell is gone (closed here, or exited there).
  void Function(TerminalTab)? onGone;

  /// Closed from this phone (else it ended on the computer: `exit`, End
  /// there, or the phone no longer allowed).
  bool closedHere = false;

  /// Leaves the shell running on the computer.
  Future<void> detach() async {
    _leaving = true;
    await _channel?.detach();
  }

  /// Ends the shell and the session (`term_close`, then our side of the
  /// stream), so nothing stays open on either side. A detached tab has to be
  /// reattached first (the screen asks for the code), or its shell runs on.
  Future<void> close() async {
    closedHere = true;
    final channel = _channel;
    _channel = null;
    state = TabState.ended;
    notifyListeners();
    // `term_close` first: the computer ends the shell and finishes the
    // stream. The output listener is dropped without waiting on it.
    if (channel != null) {
      await channel.close().catchError((Object _) {});
    }
    unawaited(_sub?.cancel());
    _sub = null;
    onGone?.call(this);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Every computer's terminal tabs, kept while the app runs.
class Terminals extends ChangeNotifier {
  Terminals(this._node);

  final LinksyNode _node;
  final Map<String, List<TerminalTab>> _tabs = {};
  final _gone = StreamController<TerminalTab>.broadcast();

  /// Tabs whose shell ended, as they go (to say so on screen).
  Stream<TerminalTab> get gone => _gone.stream;

  List<TerminalTab> of(String deviceId) => _tabs[deviceId] ?? const [];

  /// A new tab, not opened yet (it asks for the code first).
  TerminalTab add(String deviceId) {
    final tab = TerminalTab(deviceId, _node)
      ..addListener(notifyListeners)
      ..onGone = (t) {
        if (!_gone.isClosed) _gone.add(t);
        remove(t);
      };
    (_tabs[deviceId] ??= []).add(tab);
    notifyListeners();
    return tab;
  }

  void remove(TerminalTab tab) {
    if (!(_tabs[tab.deviceId]?.remove(tab) ?? false)) return;
    tab
      ..removeListener(notifyListeners)
      ..dispose();
    notifyListeners();
  }

  /// What still runs on [deviceId] and isn't in a tab here.
  Future<List<RemoteTerminal>> running(String deviceId) async {
    final mine = {for (final t in of(deviceId)) t.terminalId};
    final all = await _node.terminals(deviceId);
    return [
      for (final t in all)
        if (!mine.contains(t.id)) t,
    ];
  }

  /// Leaving the app's process: every tab detaches (the shells run on).
  Future<void> detachAll() async {
    for (final tabs in _tabs.values) {
      for (final t in tabs) {
        if (t.state == TabState.live) await t.detach();
      }
    }
  }
}
