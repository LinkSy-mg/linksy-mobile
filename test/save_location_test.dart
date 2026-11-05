import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/settings/settings_pages.dart';
import 'package:linksy/l10n/app_localizations.dart';
import 'package:linksy/ui/sig.dart';

void main() {
  final calls = <MethodCall>[];

  /// What Android's folder picker answers; null is cancelled.
  String? picked;

  Future<LinksyController> pumpFiles(WidgetTester tester) async {
    calls.clear();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          'pickFolder' => picked,
          _ => null,
        };
      },
    );
    final node = DemoNode(name: 'Test Phone', downloadDir: '/downloads');
    final c = LinksyController(node, ActivityStore(null));
    await c.start();
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
          home: const FilesSettings(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> finish(WidgetTester tester, LinksyController c) async {
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('tapping Save location picks the folder', (tester) async {
    picked = 'Phone backups';
    final c = await pumpFiles(tester);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Use Downloads › Linksy'), findsNothing);

    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    final pick = calls.singleWhere((c) => c.method == 'pickFolder');
    expect((pick.arguments as Map)['kind'], 'received');
    expect(c.saveFolder, 'Phone backups');
    expect(find.text('Phone backups'), findsOneWidget);
    expect(find.text('Downloads'), findsNothing);
    await finish(tester, c);
  });

  testWidgets('cancelling the picker changes nothing', (tester) async {
    picked = null;
    final c = await pumpFiles(tester);
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    expect(c.saveFolder, isNull);
    expect(find.text('Downloads'), findsOneWidget);
    await finish(tester, c);
  });

  testWidgets('back to Downloads forgets the folder', (tester) async {
    picked = 'Phone backups';
    final c = await pumpFiles(tester);
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use Downloads › Linksy'));
    await tester.pumpAndSettle();
    final forget = calls.singleWhere((c) => c.method == 'forgetFolder');
    expect((forget.arguments as Map)['kind'], 'received');
    expect(c.saveFolder, isNull);
    expect(find.text('Downloads'), findsOneWidget);
    // The button is its own: it didn't open the picker as well.
    expect(calls.where((c) => c.method == 'pickFolder'), hasLength(1));
    await finish(tester, c);
  });
}
