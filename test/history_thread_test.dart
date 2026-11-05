import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/features/phones/thread.dart';
import 'package:linksy/l10n/app_localizations.dart';
import 'package:linksy/ui/sig.dart';

void main() {
  final device = DeviceInfo(
    id: 'ab' * 32,
    name: 'Pixel of Sam',
    kind: DeviceKind.phone,
    os: 'Android',
  );
  final today = DateTime.now();

  Activity entry(
    String name, {
    required bool incoming,
    required int minutes,
    ActivityStatus status = ActivityStatus.done,
    String? reason,
  }) => Activity(
    id: name,
    deviceId: device.id,
    kind: ActivityKind.files,
    incoming: incoming,
    time: today.subtract(Duration(minutes: minutes)),
    status: status,
    names: [name],
    sizes: const [1000],
    total: 1000,
    reason: reason,
  );

  Future<void> pump(WidgetTester tester, List<Activity> entries) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async => null,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: HistoryThread(entries: entries, device: device),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the newest is first, sent on the right, received on the left', (
    tester,
  ) async {
    await pump(tester, [
      entry('new.pdf', incoming: false, minutes: 1),
      entry('old.pdf', incoming: true, minutes: 2),
    ]);
    final fresh = tester.getTopLeft(find.text('new.pdf'));
    final old = tester.getTopLeft(find.text('old.pdf'));
    expect(fresh.dy, lessThan(old.dy));
    expect(fresh.dx, greaterThan(old.dx));
  });

  testWidgets('what did not go says why', (tester) async {
    await pump(tester, [
      entry(
        'contract.pdf',
        incoming: false,
        minutes: 1,
        status: ActivityStatus.failed,
        reason: 'Interrupted',
      ),
    ]);
    expect(find.textContaining('Interrupted'), findsOneWidget);
  });

  test('photos and apps sent are remembered', () {
    final a = Activity.fromJson(
      Activity(
        id: 'a',
        deviceId: 'p',
        kind: ActivityKind.files,
        incoming: false,
        time: today,
        status: ActivityStatus.done,
        names: const ['a.jpg', 'Maps'],
        thumbs: const ['/a.jpg'],
        packages: const {'Maps': 'com.maps'},
      ).toJson(),
    );
    expect(a.pictures, ['/a.jpg']);
    expect(a.packages, {'Maps': 'com.maps'});
  });
}
