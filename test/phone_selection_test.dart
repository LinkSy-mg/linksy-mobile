import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/features/phones/selection.dart';

PhoneMedia photo(int id, DateTime taken, {int size = 1000}) => PhoneMedia(
  id: id,
  path: '/p/$id.jpg',
  name: '$id.jpg',
  size: size,
  taken: taken,
);

PhoneApp app(String package, {int size = 5000, int apks = 1}) => PhoneApp(
  package: package,
  label: package,
  versionCode: 3,
  versionName: '1.2',
  signer: 'abc',
  apks: [for (var i = 0; i < apks; i++) '/a/$package/$i.apk'],
  size: size,
);

void main() {
  final now = DateTime(2026, 11, 5, 12);

  test('sizes and counts add up across the sources', () {
    final s = SendSelection();
    s.toggleMedia(photo(1, now, size: 100));
    s.addFiles([const PickedFile(path: '/f', name: 'f', size: 20)]);
    s.toggleApp(app('a', size: 3, apks: 2));
    expect(s.count, 3);
    expect(s.bytes, 123);
    expect(s.appBytes, 3);
    // An app is all its APKs.
    expect(s.fileCount, 4);
    expect(s.paths, ['/p/1.jpg', '/f']);
  });

  test('tapping again takes it out', () {
    final s = SendSelection();
    final p = photo(1, now);
    s.toggleMedia(p);
    s.toggleMedia(p);
    expect(s.isEmpty, isTrue);
  });

  test('a day heading picks the day, and then none of it', () {
    final s = SendSelection();
    final day = [photo(1, now), photo(2, now)];
    s.toggleMedia(day.first);
    s.toggleDay(day);
    expect(s.count, 2);
    s.toggleDay(day);
    expect(s.count, 0);
  });

  test('days, newest first, with the year for earlier years', () {
    final days = mediaByDay([
      photo(1, DateTime(2025, 11, 2)),
      photo(2, DateTime(2026, 11, 2)),
      photo(3, DateTime(2026, 11, 4, 9)),
      photo(4, DateTime(2026, 11, 5, 9)),
      photo(5, DateTime(2026, 11, 5, 11)),
    ], now: now);
    expect(days.map((d) => d.$1), [
      'Today',
      'Yesterday',
      'Nov 2',
      'Nov 2, 2025',
    ]);
    expect(days.first.$2.map((m) => m.id), [5, 4]);
  });

  test('what can be picked against the other phone', () {
    expect(appSelectable(AppThere.none), isTrue);
    expect(appSelectable(AppThere.older), isTrue);
    expect(appSelectable(AppThere.same), isTrue);
    expect(appSelectable(AppThere.newer), isFalse);
    expect(appSelectable(AppThere.otherSigner), isFalse);
    expect(AppThere.parse('other_signer'), AppThere.otherSigner);
    expect(AppThere.parse('none'), AppThere.none);
    expect(AppThere.parse('something new'), AppThere.unknown);
    expect(appSelectable(AppThere.unknown), isTrue);
  });

  group('warnings from a preflight answer', () {
    test('none from an older device, which gives no answer', () {
      expect(sendWarnings(reply: null, bytes: 1 << 40, apps: true), isEmpty);
    });

    test('no room', () {
      final w = sendWarnings(
        reply: const PreflightReply(free: 400),
        bytes: 2100,
        apps: false,
      );
      expect((w.single as NoRoom).free, 400);
    });

    test('room exactly is room', () {
      expect(
        sendWarnings(
          reply: const PreflightReply(free: 400),
          bytes: 400,
          apps: false,
        ),
        isEmpty,
      );
    });

    test('will ask, and not able to install, only with apps', () {
      const reply = PreflightReply(auto: false, canInstall: false);
      expect(
        sendWarnings(reply: reply, bytes: 1, apps: false).single,
        isA<WillAsk>(),
      );
      final w = sendWarnings(reply: reply, bytes: 1, apps: true);
      expect(w, hasLength(2));
      expect(w.last, isA<CantInstall>());
    });
  });

  test('asks first over the internet above 100 MB, once it knows', () {
    const away = SendPlan(route: 'away', direct: 'not');
    expect(asksFirst(away, 100 * 1000 * 1000), isFalse);
    expect(asksFirst(away, 100 * 1000 * 1000 + 1), isTrue);
    expect(asksFirst(const SendPlan(route: 'direct'), 1 << 40), isFalse);
    // Away now, but a direct link comes up first.
    expect(
      asksFirst(const SendPlan(route: 'away', direct: 'will'), 1 << 40),
      isFalse,
    );
    expect(asksFirst(null, 1 << 40), isFalse);
  });

  test('a very long selection goes in several sends', () {
    final paths = [for (var i = 0; i < 12001; i++) '$i'];
    final batches = sendBatches(paths);
    expect(batches.map((b) => b.length), [5000, 5000, 2001]);
    expect(sendBatches(const []), isEmpty);
  });

  test('a bundle carries what the other phone checks', () {
    final a = PhoneApp(
      package: 'x',
      label: 'X',
      versionCode: 9,
      versionName: '2',
      signer: 's',
      apks: const ['/base.apk'],
      size: 1,
      icon: Uint8List.fromList([1, 2, 3]),
    );
    expect(a.bundle.toJson(), {
      'package': 'x',
      'label': 'X',
      'version_code': 9,
      'version_name': '2',
      'signer': 's',
      'icon': 'AQID',
      'apks': ['/base.apk'],
    });
  });
}
