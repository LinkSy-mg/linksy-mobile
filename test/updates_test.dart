import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/updates.dart';
import 'package:linksy/features/news/whats_new.dart';

Map<String, Object?> _release(
  String tag,
  List<String> files, {
  bool pre = false,
}) => {
  'tag_name': tag,
  'draft': false,
  'prerelease': pre,
  'html_url': 'https://github.com/LinkSy-mg/linksy-releases/releases/tag/$tag',
  'body': 'Fixes.\n\n### SHA-256\n```\nabc  linksy.apk\n```',
  'assets': [
    for (final f in files)
      {'name': f, 'browser_download_url': 'https://example.com/$tag/$f'},
  ],
};

void main() {
  test('the newest Android release, not the computer\'s', () {
    final raw = jsonEncode([
      _release('linux-v0.8.7', ['linksy_0.8.7_amd64.deb']),
      _release('v0.3.0', ['linksy-0.3.0.apk'], pre: true),
      _release('v0.2.4', [
        'linksy-0.2.4.apk',
        'linksy-0.2.4-arm64.apk',
        'SHA256SUMS',
      ]),
      _release('v0.2.10', ['linksy-0.2.10.apk']),
      _release('v0.2.3', ['linksy-0.2.3.apk']),
    ]);
    final r = AppRelease.newest(raw)!;
    expect(r.version, '0.2.10');
    expect(r.notes, 'Fixes.');
    expect(AppRelease.newest('not json'), isNull);
  });

  test('an answer under an hour old is used, not asked again', () async {
    final dir = Directory.systemTemp.createTempSync('linksy_updates');
    addTearDown(() => dir.deleteSync(recursive: true));
    final cache = File('${dir.path}/releases.json')
      ..writeAsStringSync(
        jsonEncode([
          _release('v0.3.1', ['linksy-0.3.1.apk']),
        ]),
      )
      ..setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 40)),
      );
    final checker = UpdateChecker(cache);
    expect(await checker.refresh(), isNull);
    expect(checker.cached()?.version, '0.3.1');
  });

  test('the APK for this phone, else the universal one', () {
    final r = AppRelease.newest(
      jsonEncode([
        _release('v0.2.4', ['linksy-0.2.4.apk', 'linksy-0.2.4-arm64.apk']),
      ]),
    )!;
    expect(r.apkName('arm64-v8a'), 'linksy-0.2.4-arm64.apk');
    expect(r.apkName('armeabi-v7a'), 'linksy-0.2.4.apk');
    expect(r.apkName(null), 'linksy-0.2.4.apk');
  });

  test('versions compare by number', () {
    expect(isNewer('0.2.10', '0.2.9'), isTrue);
    expect(isNewer('0.3.0', '0.2.23'), isTrue);
    expect(isNewer('0.2.3', '0.2.3'), isFalse);
    expect(isNewer('0.2.2', '0.2.3'), isFalse);
  });

  test('a checksum from SHA256SUMS', () {
    final a = 'A' * 64, b = 'b' * 64;
    final sums = '$a  linksy-0.2.4.apk\n$b *linksy-0.2.4-arm64.apk\n';
    expect(sumFor(sums, 'linksy-0.2.4.apk'), 'a' * 64);
    expect(sumFor(sums, 'linksy-0.2.4-arm64.apk'), b);
    expect(sumFor(sums, 'linksy-0.2.4-armv7.apk'), isNull);
  });

  test('What\'s New: since the last version seen, up to this one', () {
    expect(highlights('0.2.4', since: '0.2.3'), hasLength(3));
    expect(highlights('0.2.4', since: '0.2.4'), isEmpty);
    expect(highlights('0.2.5', since: '0.2.4'), hasLength(3));
    expect(highlights('0.2.5', since: '0.2.3'), hasLength(5));
    expect(highlights('0.2.6', since: '0.2.5'), hasLength(2));
    expect(highlights('0.2.6', since: '0.2.4'), hasLength(5));
    expect(highlights('0.2.3'), isEmpty);
  });
}
