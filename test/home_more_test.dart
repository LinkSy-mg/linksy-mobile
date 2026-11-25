import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/devices/home_screen.dart';
import 'package:linksy/ui/l10n.dart';
import 'package:linksy/ui/sig.dart';

void main() {
  testWidgets('a computer has More, with Send files in it; a phone has Send', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 1400);
    addTearDown(tester.view.reset);
    final c = LinksyController(
      DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
      ActivityStore(null),
    );
    await tester.runAsync(
      () => c.start().timeout(const Duration(seconds: 5), onTimeout: () {}),
    );
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await settle();
    expect(find.bySemanticsLabel('More'), findsOneWidget);
    // The phone's, and the island's.
    final sends = find.bySemanticsLabel('Send files').evaluate().length;
    await tester.tap(find.bySemanticsLabel('More'));
    await settle();
    expect(
      find.bySemanticsLabel('Send files').evaluate().length,
      greaterThan(0),
    );
    expect(sends, greaterThan(0));
    expect(find.text('Clipboard'), findsOneWidget);
    expect(find.text('Deck'), findsOneWidget);

    // A page opens in place of the sheet.
    await tester.tap(find.text('Deck'));
    await settle();
    expect(find.text('Clipboard'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
