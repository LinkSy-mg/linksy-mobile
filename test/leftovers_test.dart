import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';

void main() {
  final calls = <MethodCall>[];

  Iterable<MethodCall> leftovers() =>
      calls.where((c) => c.method == 'publishLeftovers');

  Future<(LinksyController, DemoNode)> start(WidgetTester tester) async {
    calls.clear();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          // A file that couldn't move keeps its path.
          'publishDownloads' => (call.arguments as Map)['paths'],
          _ => null,
        };
      },
    );
    final node = DemoNode(name: 'Test Phone', downloadDir: '/downloads');
    final c = LinksyController(node, ActivityStore(null));
    await c.start();
    await tester.pump();
    return (c, node);
  }

  Future<void> finish(WidgetTester tester, LinksyController c) async {
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  }

  Future<void> incoming(WidgetTester tester, DemoNode node) async {
    final settings = await node.settings();
    await node.updateSettings(settings.copyWith(autoAccept: true));
    node.simulateIncomingFiles();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('what the core left is moved at the start and on coming back', (
    tester,
  ) async {
    final (c, _) = await start(tester);
    expect(leftovers(), hasLength(1));

    c.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(leftovers(), hasLength(2));
    await finish(tester, c);
  });

  testWidgets('not while files are arriving, those move as they finish', (
    tester,
  ) async {
    final (c, node) = await start(tester);
    await incoming(tester, node);
    calls.clear();

    c.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(leftovers(), isEmpty);
    await finish(tester, c);
  });

  testWidgets('what the timeline points to stays where it is', (tester) async {
    final (c, node) = await start(tester);
    await incoming(tester, node);
    await tester.pump(const Duration(seconds: 30));
    final moved = calls.lastWhere((c) => c.method == 'publishDownloads');
    final paths = (moved.arguments as Map)['paths'] as List;
    expect(paths, isNotEmpty);
    calls.clear();

    c.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    final keep = (leftovers().single.arguments as Map)['keep'] as List;
    expect(keep, containsAll(paths));
    await finish(tester, c);
  });
}
