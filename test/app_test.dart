import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/app.dart';
import 'package:linksy/app/launch_intro.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/updates.dart';
import 'package:linksy/features/terminal/terminal_screen.dart';
import 'package:linksy/features/transfer/transfer_bubble.dart';
import 'package:xterm/xterm.dart';

/// Pumps frames for half a second, for screens with something that never
/// stops animating (an indeterminate progress bar).
Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  Future<(LinksyController, DemoNode)> pumpApp(WidgetTester tester) async {
    final node = DemoNode(name: 'Test Phone', downloadDir: '/downloads');
    final c = LinksyController(node, ActivityStore(null));
    // Set up already (language, permissions): straight to home.
    c.prefs = {'onboarded': '1'};
    // Looping animations stop when motion is reduced, so the tree settles.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    // A phone, not the default 800×600.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await c.start();
    // Cancels its timers (photo backup checks) before the test ends.
    addTearDown(c.dispose);
    // No launch intro: nothing to cover or fly.
    LaunchIntro.enabled = false;
    await tester.pumpWidget(LinksyApp(controller: c));
    await tester.pumpAndSettle();
    return (c, node);
  }

  testWidgets('home lists paired and unpaired devices', (tester) async {
    await pumpApp(tester);
    expect(find.text('YOUR DEVICES'), findsOneWidget);
    expect(find.text('Studio Desktop'), findsOneWidget);
    expect(find.text('ThinkPad'), findsOneWidget);
    expect(find.text('NEARBY, NOT PAIRED'), findsOneWidget);
    expect(find.text('Living Room PC'), findsOneWidget);
    expect(find.text('Pair'), findsOneWidget);
  });

  testWidgets('a newer version: the card, then Update Now', (tester) async {
    final (c, _) = await pumpApp(tester);
    c.updates
      ..installed = '0.2.4'
      ..available = const AppRelease(
        version: '0.2.5',
        page: 'https://example.com/v0.2.5',
        notes: '### Fixed\n- **Faster** sending.',
        assets: {'linksy-0.2.5.apk': 'https://example.com/a.apk'},
      )
      ..notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text('Linksy 0.2.5 Is Available'), findsOneWidget);
    await tester.tap(find.text('Update Now'));
    await tester.pumpAndSettle();
    expect(find.text('Linksy 0.2.5 Is Available'), findsNWidgets(2));
    expect(find.textContaining('Faster sending'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('a device page offers its actions', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Studio Desktop'));
    await tester.pumpAndSettle();
    expect(find.text('Send files'), findsOneWidget);
    expect(find.text('Clipboard'), findsOneWidget);
    expect(find.text('Ping'), findsOneWidget);
    expect(find.text('Remote'), findsOneWidget);
    expect(find.text('Find it'), findsOneWidget);
    expect(find.text('Back up photos'), findsOneWidget);
  });

  testWidgets('incoming files ask first', (tester) async {
    final (_, node) = await pumpApp(tester);
    node.simulateIncomingFiles();
    await frames(tester);
    final title = find.text(
      'Studio Desktop is sending you 3 files',
      findRichText: true,
    );
    expect(title, findsOneWidget);
    expect(find.text('6.3 MB in total'), findsOneWidget);
    await tester.tap(find.text('Decline'));
    await frames(tester);
    expect(title, findsNothing);
  });

  testWidgets('pinching the terminal resizes its text, kept', (tester) async {
    final (c, _) = await pumpApp(tester);
    final studio = c.devices.firstWhere(
      (v) => v.device.name == 'Studio Desktop',
    );
    final tab = c.terminals.add(studio.device.id);
    await tester.runAsync(() => tab.open(DemoNode.demoTerminalCode));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => TerminalScreen(deviceId: studio.device.id),
      ),
    );
    await frames(tester);
    double size() => tester
        .widget<TerminalView>(find.byType(TerminalView))
        .textStyle
        .fontSize;
    final before = size();
    final center = tester.getCenter(find.byType(TerminalView));
    final a = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 7,
    );
    final b = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 8,
    );
    await a.moveTo(center - const Offset(20, 0));
    await b.moveTo(center + const Offset(20, 0));
    await a.up();
    await b.up();
    await frames(tester);
    expect(size(), lessThan(before));
    expect(c.prefs['term_font'], '${size()}');
  });

  testWidgets('files on their way show in the bubble and its page', (
    tester,
  ) async {
    final (c, _) = await pumpApp(tester);
    final id = c.devices
        .firstWhere((v) => v.device.name == 'Studio Desktop')
        .device
        .id;
    await c.sendFiles(id, ['/x/a.jpg', '/x/b.jpg', '/x/c.jpg']);
    await tester.pump();
    // Waiting for the computer: the count, ring turning.
    expect(find.text('3'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.tap(find.text('3'));
    await frames(tester);
    // The island grows in place: the files still on their way.
    expect(find.text('b.jpg'), findsOneWidget);
    expect(find.text('c.jpg'), findsOneWidget);
    // The whole page, with the transfer's header.
    openTransfers(tester.element(find.text('c.jpg')));
    await frames(tester);
    expect(find.text('Transfers'), findsOneWidget);
    expect(find.textContaining('TO STUDIO DESKTOP'), findsOneWidget);
    expect(find.textContaining('OF 3 FILES'), findsOneWidget);
    // Done: nothing on its way, the transfer under Recent, and the count
    // goes from home.
    await tester.pump(const Duration(seconds: 4));
    await frames(tester);
    expect(find.text('Nothing on its way'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 3));
    await frames(tester);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('a device picked in the share sheet gets the files at once', (
    tester,
  ) async {
    final (c, _) = await pumpApp(tester);
    final id = c.devices
        .firstWhere((v) => v.device.name == 'Studio Desktop')
        .device
        .id;
    const codec = StandardMethodCodec();
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'app.linksy/platform',
      codec.encodeMethodCall(
        MethodCall('share', {
          'files': ['/x/a.jpg', '/x/b.jpg'],
          'device': id,
        }),
      ),
      (_) {},
    );
    await tester.pump();
    await tester.pump();
    // No sheet asking where: it's on its way to that computer.
    expect(find.text('Send 2 files'), findsNothing);
    final sent = c.activityFor(id).first;
    expect(sent.names, ['a.jpg', 'b.jpg']);
    expect(
      find.descendant(
        of: find.byType(TransfersButton),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 8));
    await frames(tester);
  });
}
