import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/remote/remote_screen.dart';
import 'package:linksy/features/terminal/terminal_screen.dart';
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

  /// Key messages as `keysym-in-hex down|up`.
  List<String> get keys => [
    for (final m in sent)
      if (m['type'] == 'key')
        '${(m['keysym']! as int).toRadixString(16)} '
            '${m['pressed'] == true ? 'down' : 'up'}',
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

  testWidgets('a modifier holds for the next key, then lets go', (
    tester,
  ) async {
    final (c, node) = await pump(tester);
    await tester.tap(find.text('Ctrl'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('F4'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('F4'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffe3 down', 'ffc1 down', 'ffc1 up', 'ffe3 up']);

    // Let go: the next key goes alone.
    node.sent.clear();
    await tester.tap(find.text('F4'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffc1 down', 'ffc1 up']);
    await finish(tester, c);
  });

  testWidgets('a held modifier presses alone', (tester) async {
    final (c, node) = await pump(tester);
    await tester.longPress(find.text('Super'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffeb down', 'ffeb up']);
    await finish(tester, c);
  });

  testWidgets('the browser tab sends its shortcuts', (tester) async {
    final (c, node) = await pump(tester);
    await tester.tap(find.text('Browser'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Back'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffe9 down', 'ff51 down', 'ff51 up', 'ffe9 up']);
    node.sent.clear();
    await tester.tap(find.text('New tab'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffe3 down', '74 down', '74 up', 'ffe3 up']);
    await finish(tester, c);
  });

  testWidgets('more slideshow keys', (tester) async {
    final (c, node) = await pump(tester);
    await tester.tap(find.text('Slides'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Black screen'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['62 down', '62 up']);
    node.sent.clear();
    await tester.scrollUntilVisible(
      find.text('From here'),
      200,
      scrollable: find
          .ancestor(
            of: find.text('Black screen'),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('From here'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(node.keys, ['ffe1 down', 'ffc2 down', 'ffc2 up', 'ffe1 up']);
    await finish(tester, c);
  });

  testWidgets('the switcher swaps pages and keeps the remote open', (
    tester,
  ) async {
    final (c, _) = await pump(tester);
    final id = c.remotes.keys.single;
    await tester.tap(find.byIcon(Ph.cards));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Switch to'), findsOneWidget);
    await tester.tap(find.text('Terminal'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(TerminalScreen), findsOneWidget);
    expect(find.byType(RemoteScreen), findsNothing);
    expect(c.remotes.containsKey(id), isTrue);
    await finish(tester, c);
  });
}
