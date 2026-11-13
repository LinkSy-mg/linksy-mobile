import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/terminals.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/models.dart';
import 'package:xterm/xterm.dart';

class _Channel implements TerminalChannel {
  final typed = <String>[];
  final out = StreamController<Uint8List>();

  @override
  String get terminalId => 't';
  @override
  Stream<Uint8List> get output => out.stream;
  @override
  Future<bool> input(String data) async {
    typed.add(data);
    return true;
  }

  @override
  Future<bool> resize(int cols, int rows) async => true;
  @override
  Future<void> close() async {}
  @override
  Future<void> detach() async {}
}

class _Node extends DemoNode {
  _Node() : super(name: 'Test Phone', downloadDir: '/downloads');
  final channel = _Channel();

  @override
  Future<TerminalChannel> openTerminal(
    String id, {
    required String code,
    required int cols,
    required int rows,
    String? resume,
  }) async => channel;
}

void main() {
  Future<(TerminalTab, _Channel)> open() async {
    final node = _Node();
    final tab = TerminalTab('pc', node);
    await tab.open('123456');
    return (tab, node.channel);
  }

  Future<void> show(TerminalTab tab, _Channel ch, String s) async {
    ch.out.add(Uint8List.fromList(utf8.encode(s)));
    await pumpEventQueue();
  }

  test('arrows follow the program: a shell, then htop or vim', () async {
    final (tab, ch) = await open();
    tab.special(TerminalKey.arrowUp);
    // htop and vim turn on application cursor keys.
    await show(tab, ch, '\x1b[?1h');
    tab.special(TerminalKey.arrowUp);
    expect(ch.typed, ['\x1b[A', '\x1bOA']);
  });

  test('Ctrl reaches an arrow, then lets go', () async {
    final (tab, ch) = await open();
    tab.toggleCtrl();
    tab.special(TerminalKey.arrowRight);
    tab.special(TerminalKey.arrowRight);
    expect(ch.typed, ['\x1b[1;5C', '\x1b[C']);
    expect(tab.ctrl, isFalse);
  });

  test('F10 and Enter for htop and btm', () async {
    final (tab, ch) = await open();
    tab.special(TerminalKey.f10);
    tab.special(TerminalKey.enter);
    expect(ch.typed, ['\x1b[21~', '\r']);
  });
}
