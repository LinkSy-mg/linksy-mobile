import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';

class _Node extends DemoNode {
  _Node() : super(name: 'Test Phone', downloadDir: '/downloads');

  int asked = 0;
  Completer<void>? approval;
  final ended = <String>[];

  @override
  Future<String> startInput(String id) async {
    asked++;
    await approval?.future;
    return super.startInput(id);
  }

  @override
  Future<void> endSession(String session) {
    ended.add(session);
    return super.endSession(session);
  }
}

void main() {
  Future<(LinksyController, _Node, String)> start(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async => call.method == 'prefs' ? {'onboarded': '1'} : null,
    );
    final node = _Node();
    final c = LinksyController(node, ActivityStore(null));
    await c.start();
    await c.refresh();
    await tester.pump();
    final id = c.devices.firstWhere((v) => v.trusted).device.id;
    return (c, node, id);
  }

  Future<void> done(WidgetTester tester, LinksyController c) async {
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('back on the page within a minute: the same session', (
    tester,
  ) async {
    final (c, node, id) = await start(tester);
    expect(await c.startRemote(id), isNull);
    final session = c.remotes[id];
    c.leaveRemote(id);
    await tester.pump(const Duration(seconds: 50));
    expect(await c.startRemote(id), isNull);
    expect(node.asked, 1);
    expect(c.remotes[id], session);
    // The old timer is gone: still open past the first minute.
    await tester.pump(const Duration(seconds: 20));
    expect(c.remotes[id], session);
    expect(node.ended, isEmpty);
    await done(tester, c);
  });

  testWidgets('approval arriving after Back closes the session', (
    tester,
  ) async {
    final (c, node, id) = await start(tester);
    final approval = node.approval = Completer<void>();
    final starting = c.startRemote(id);
    c.leaveRemote(id);
    approval.complete();
    await starting;
    expect(c.remotes, isEmpty);
    expect(node.ended, hasLength(1));
    await done(tester, c);
  });

  testWidgets('returning during approval reuses the pending request', (
    tester,
  ) async {
    final (c, node, id) = await start(tester);
    final approval = node.approval = Completer<void>();
    final starting = c.startRemote(id);
    c.leaveRemote(id);
    final returning = c.startRemote(id);
    approval.complete();
    expect(await starting, isNull);
    expect(await returning, isNull);
    expect(node.asked, 1);
    expect(node.ended, isEmpty);
    expect(c.remotes.containsKey(id), isTrue);
    await done(tester, c);
  });

  testWidgets('left alone, it ends after a minute', (tester) async {
    final (c, node, id) = await start(tester);
    await c.startRemote(id);
    final session = c.remotes[id]!;
    c.leaveRemote(id);
    await tester.pump(const Duration(seconds: 59));
    expect(node.ended, isEmpty);
    await tester.pump(const Duration(seconds: 2));
    expect(node.ended, [session]);
    expect(c.remotes, isEmpty);
    await done(tester, c);
  });

  testWidgets('in the background, a left remote ends at once', (tester) async {
    final (c, node, id) = await start(tester);
    await c.startRemote(id);
    c.leaveRemote(id);
    c.didChangeAppLifecycleState(AppLifecycleState.hidden);
    await tester.pump();
    expect(node.ended, hasLength(1));
    expect(c.remotes, isEmpty);
    await done(tester, c);
  });

  testWidgets('on its page, going to the background keeps it', (tester) async {
    final (c, node, id) = await start(tester);
    await c.startRemote(id);
    c.didChangeAppLifecycleState(AppLifecycleState.hidden);
    await tester.pump();
    expect(node.ended, isEmpty);
    await done(tester, c);
  });

  testWidgets('the touchpad reads as such in History', (tester) async {
    final (c, _, id) = await start(tester);
    await c.startRemote(id);
    await tester.pump();
    expect(c.activityFor(id).first.kind, ActivityKind.remote);
    await done(tester, c);
  });
}
