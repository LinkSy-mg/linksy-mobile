import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/remote/remote_screen.dart';
import 'package:linksy/l10n/app_localizations.dart';
import 'package:linksy/ui/icons.dart';
import 'package:linksy/ui/sig.dart';

class _Node extends DemoNode {
  _Node() : super(name: 'Test Phone', downloadDir: '/downloads');

  final sent = <Map<String, Object?>>[];

  @override
  Future<bool> sessionWrite(String session, Uint8List bytes) async {
    final data = ByteData.sublistView(bytes);
    var at = 0;
    while (at < bytes.length) {
      final n = data.getUint32(at);
      sent.add(
        jsonDecode(utf8.decode(bytes.sublist(at + 4, at + 4 + n)))
            as Map<String, Object?>,
      );
      at += 4 + n;
    }
    return true;
  }

  List<String> get buttons => [
    for (final m in sent)
      if (m['type'] == 'button') '${m['button']} ${m['pressed']}',
  ];
}

void main() {
  Future<(LinksyController, _Node)> pump(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async => call.method == 'prefs' ? {'onboarded': '1'} : null,
    );
    final node = _Node();
    final c = LinksyController(node, ActivityStore(null));
    await c.start();
    await c.refresh();
    final computer = c.devices.firstWhere((v) => v.trusted).device;
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RemoteScreen(device: computer),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return (c, node);
  }

  Future<void> finish(WidgetTester tester, LinksyController c) async {
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 70));
  }

  Offset pad(WidgetTester tester) =>
      tester.getCenter(find.byIcon(Ph.handPointing).first);

  Future<void> slide(WidgetTester tester, Offset at) async {
    final g = await tester.startGesture(at);
    for (var i = 0; i < 5; i++) {
      await g.moveBy(const Offset(12, 8));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('double-tap and slide drags until a tap', (tester) async {
    final (c, node) = await pump(tester);
    final at = pad(tester);
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.buttons, ['left true', 'left false']);

    await slide(tester, at);
    expect(node.buttons, ['left true', 'left false', 'left true']);
    expect(find.byIcon(Ph.handGrabbing), findsOneWidget);

    // Lifted and moved again: still held.
    await tester.pump(const Duration(milliseconds: 400));
    await slide(tester, at);
    expect(node.buttons.last, 'left true');
    expect(node.sent.last['type'], 'pointer_by');

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.buttons, [
      'left true',
      'left false',
      'left true',
      'left false',
    ]);
    expect(find.byIcon(Ph.handGrabbing), findsNothing);
    await finish(tester, c);
  });

  testWidgets('a slide long after a tap only moves', (tester) async {
    final (c, node) = await pump(tester);
    final at = pad(tester);
    await tester.tapAt(at);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 350)),
    );
    await slide(tester, at);
    expect(node.buttons, ['left true', 'left false']);
    await finish(tester, c);
  });

  testWidgets('two taps are a double-click', (tester) async {
    final (c, node) = await pump(tester);
    final at = pad(tester);
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.buttons, [
      'left true',
      'left false',
      'left true',
      'left false',
    ]);
    await finish(tester, c);
  });

  testWidgets('leaving mid-drag lets the button go', (tester) async {
    final (c, node) = await pump(tester);
    final at = pad(tester);
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 20));
    await slide(tester, at);
    expect(node.buttons.last, 'left true');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(node.buttons.last, 'left false');
    c.dispose();
    await tester.pump(const Duration(seconds: 70));
  });
}
