import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/features/device/device_screen.dart';
import 'package:linksy/features/phones/selection.dart';
import 'package:linksy/features/phones/send_bar.dart';
import 'package:linksy/features/phones/send_flow.dart';
import 'package:linksy/l10n/app_localizations.dart';
import 'package:linksy/ui/sig.dart';

void main() {
  Future<(LinksyController, String)> pump(
    WidgetTester tester, {
    required String name,
  }) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async => call.method == 'shareGallery' ? true : null,
    );
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final c = LinksyController(
      DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
      ActivityStore(null),
    );
    await c.start();
    await tester.pump();
    final id = c.devices.firstWhere((v) => v.device.name == name).device.id;
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeviceScreen(deviceId: id),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return (c, id);
  }

  Future<void> finish(WidgetTester tester, LinksyController c) async {
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('a phone gets the basics first, and none of a computer\'s page', (
    tester,
  ) async {
    final (c, _) = await pump(tester, name: 'Pixel of Sam');
    double y(String text) => tester.getTopLeft(find.text(text)).dy;
    // The four that always work, side by side, then what's on this phone.
    for (final quick in ['Clipboard', 'Note', 'Find it', 'Where']) {
      expect(find.text(quick), findsOneWidget);
    }
    expect(y('Clipboard'), lessThan(y('Photos')));
    expect(y('Photos'), lessThan(y('Apps')));
    expect(y('Apps'), lessThan(y('Files')));
    for (final gone in ['Remote', 'See its screen', 'Deck', 'This phone as']) {
      expect(find.text(gone), findsNothing);
    }
    await finish(tester, c);
  });

  testWidgets('a computer keeps its page', (tester) async {
    final (c, _) = await pump(tester, name: 'Studio Desktop');
    expect(find.text('Note'), findsNothing);
    expect(find.text('Choose files'), findsNothing);
    await finish(tester, c);
  });

  testWidgets('the send bar: the route, a warning, and no Send without room', (
    tester,
  ) async {
    final (c, id) = await pump(tester, name: 'Pixel of Sam');
    final flow = SendFlow(c, id);
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SendBar(flow: flow, name: 'Sam'),
            ),
          ),
        ),
      ),
    );
    // Nothing chosen, nothing to show.
    expect(find.text('Send'), findsNothing);

    flow.selection.addFiles([
      const PickedFile(path: '/big', name: 'big', size: 4000000000),
    ]);
    await tester.pump();
    expect(find.text('Send'), findsOneWidget);
    expect(find.textContaining('Direct link · about'), findsOneWidget);

    await flow.ask(const []);
    await tester.pump();
    expect(find.textContaining('free and this is'), findsOneWidget);
    expect(find.text('Sam will ask before taking it'), findsOneWidget);
    expect(flow.blocked, isTrue);

    flow.selection.clear();
    await tester.pump(const Duration(seconds: 1));
    flow.dispose();
    await finish(tester, c);
  });

  test('how a plan reads', () {
    expect(
      routeLine(const SendPlan(route: 'lan', seconds: 120)),
      'Same network · about 2 min',
    );
    expect(
      routeLine(const SendPlan(route: 'lan', direct: 'will', seconds: 40)),
      'Direct link · about 40 s',
    );
    expect(
      routeLine(const SendPlan(route: 'away', seconds: 540)),
      'Over the internet · uses mobile data · about 9 min',
    );
    // Too quick for a guess to mean anything.
    expect(routeLine(const SendPlan(route: 'lan', seconds: 0)), 'Same network');
  });
}
