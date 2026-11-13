import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/linksy_node.dart';
import 'package:linksy/core/models.dart';

DeviceView _computer(
  String id, {
  bool connected = false,
  bool away = false,
  DateTime? awayUntil,
}) => DeviceView(
  device: DeviceInfo(id: id, name: id, kind: DeviceKind.desktop, os: 'linux'),
  trusted: true,
  connected: connected,
  nearby: false,
  away: away,
  awayUntil: awayUntil,
);

class _Node extends DemoNode {
  _Node() : super(name: 'Test Phone', downloadDir: '/downloads');

  final posted = <String>[];
  final refused = <String>[];
  final ran = <String>[];
  final sent = StreamController<LinksyEvent>.broadcast();

  @override
  Stream<LinksyEvent> get events => sent.stream;

  @override
  Future<List<DeviceView>> devices() async => [
    _computer('here', connected: true, away: true),
    _computer('reached'),
    _computer('gone'),
    _computer('off', awayUntil: DateTime.now().add(const Duration(days: 3))),
    _computer('far', awayUntil: DateTime.now().add(const Duration(days: 3))),
  ];

  @override
  Future<void> deckRun(String id, String action, {double? value}) async {
    if (id == 'off') throw const LinksyException('unreachable');
    ran.add(id);
  }

  @override
  Future<void> postNotification(
    String id,
    Map<String, Object?> notification,
  ) async {
    posted.add(id);
    if (id == 'gone') throw const LinksyException('unreachable');
  }

  @override
  Future<void> refuseControls(String id, String what, String reason) async =>
      refused.add(what);
}

void main() {
  final calls = <MethodCall>[];

  /// What the controller asked the platform has come back.
  Future<void> settle(WidgetTester tester) => tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );

  Future<(LinksyController, _Node)> start(WidgetTester tester) async {
    calls.clear();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          'prefs' => {'onboarded': '1'},
          'notificationAccess' => true,
          'controlsSet' => <String, String>{},
          _ => null,
        };
      },
    );
    final node = _Node();
    final c = LinksyController(node, ActivityStore(null));
    await c.start();
    await c.refresh();
    await settle(tester);
    return (c, node);
  }

  Future<void> notice(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'app.linksy/platform',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('phoneNotification', {'key': 'k'}),
      ),
      (_) {},
    );
    await settle(tester);
  }

  /// With the controller up, and its timers stopped at the end.
  void test(
    String name,
    Future<void> Function(WidgetTester, _Node, LinksyController) body,
  ) => testWidgets(name, (tester) async {
    final (c, node) = await start(tester);
    await body(tester, node, c);
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  });

  test('a notice goes to every paired computer, link or not', (
    tester,
    node,
    _,
  ) async {
    await notice(tester);
    expect(node.posted, ['here', 'reached', 'gone', 'off', 'far']);
  });

  test('a computer that can\'t be dialed is left alone', (
    tester,
    node,
    _,
  ) async {
    await notice(tester);
    node.posted.clear();
    await notice(tester);
    expect(node.posted, ['here', 'reached', 'off', 'far']);
  });

  test('controls work from away', (tester, node, _) async {
    node.sent.add(
      ControlsSetRequested(
        from: _computer('here').device,
        change: const {'media': 0.5},
      ),
    );
    await settle(tester);
    expect(node.refused, isEmpty);
    expect(calls.map((c) => c.method), contains('controlsSet'));
  });

  test('a deck works with no link up', (tester, node, c) async {
    expect(c.deckLive('far'), isTrue);
    c.runDeck('far', 'system.lock');
    await settle(tester);
    expect(node.ran, ['far']);
    expect(c.deckLive('far'), isTrue);
  });

  test('a deck dims when the computer doesn\'t answer', (
    tester,
    node,
    c,
  ) async {
    expect(c.deckLive('reached'), isFalse, reason: 'nothing says it\'s there');
    expect(c.deckLive('off'), isTrue);
    c.deckActions['off'] = const [
      DeckAction(id: 'dnd', name: 'DND', kind: DeckKind.toggle),
    ];
    c.runDeck('off', 'dnd');
    expect(c.deckStates['off']?['dnd']?.on, isTrue);
    await settle(tester);
    expect(c.deckLive('off'), isFalse);
    expect(c.deckStates['off']?['dnd'], isNull);
  });
}
