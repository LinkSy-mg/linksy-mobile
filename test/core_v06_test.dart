import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/core_json.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/core/service_info.dart';

void main() {
  test('service info: relays, notices for Android, robustness', () {
    final now = DateTime.utc(2026, 10, 21);
    final info = ServiceInfo.parse(
      jsonEncode({
        'schema': 1,
        'relays': [
          {'url': 'http://plain.example'},
          {'url': 'https://relay.example'},
        ],
        'protocol': {'current': 1, 'minimum': 2},
        'latest': {
          'android': {'download': 'https://example.com/linksy.apk'},
        },
        'notices': [
          {
            'id': 'a',
            'title': 'Hi',
            'body': 'All',
            'platforms': ['android'],
          },
          {
            'id': 'b',
            'title': 'Linux',
            'platforms': ['linux'],
          },
          {'id': 'c', 'title': 'Old', 'until': '2026-01-01T00:00:00Z'},
          {'id': 'd', 'level': 'warning', 'title': 'Everyone'},
        ],
        'future_field': true,
      }),
      now: now,
    )!;
    expect(info.relay, 'https://relay.example');
    expect(info.outdated, isTrue);
    expect(info.androidDownload, 'https://example.com/linksy.apk');
    expect([for (final n in info.notices) n.id], ['a', 'd']);
    expect(info.notices.last.warning, isTrue);

    expect(ServiceInfo.parse('{"schema":2}'), isNull);
    expect(ServiceInfo.parse('not json'), isNull);
    expect(ServiceInfo.parse('{"schema":1}')!.relay, defaultRelay);
  });

  test('device views read the link and away fields', () {
    final v = deviceViewFromJson({
      'device': {
        'id': 'ab' * 32,
        'name': 'Studio',
        'kind': 'laptop',
        'os': 'linux',
        'features': ['files', 'clipboard_watch'],
      },
      'trusted': true,
      'connected': true,
      'nearby': false,
      'away': true,
      'away_all': true,
      'away_until': 1793000000,
    });
    expect(v.away, isTrue);
    expect(v.usb, isFalse);
    expect(v.awayAll, isTrue);
    expect(v.awayUntil!.millisecondsSinceEpoch, 1793000000 * 1000);
    expect(v.device.features, contains('clipboard_watch'));
    expect(v.device.can('sms'), isFalse);
  });

  test('new events and settings parse', () {
    final from = {
      'id': 'cd' * 32,
      'name': 'Studio',
      'kind': 'laptop',
      'os': 'linux',
    };
    expect(
      eventFromJson({'type': 'locate_request', 'from': from}),
      isA<LocateRequested>(),
    );
    expect(
      eventFromJson({
        'type': 'clipboard_file',
        'from': from,
        'path': '/x/a.png',
      }),
      isA<ClipboardFileReceived>(),
    );
    expect(
      eventFromJson({
        'type': 'session_request',
        'request': 'r',
        'from': from,
        'kind': 'microphone',
      }),
      isA<SessionRequest>().having(
        (e) => e.kind,
        'kind',
        SessionKind.microphone,
      ),
    );
    final st = settingsFromJson({
      'name': 'P',
      'download_dir': '/d',
      'away': false,
    });
    expect(st.away, isFalse);
    expect(settingsToJson(st.copyWith(away: true))['away'], isTrue);
  });

  test('a relay of one\'s own is kept, and cleared with null', () {
    final st = settingsFromJson({'name': 'P', 'download_dir': '/d'});
    expect(st.relay, isNull);
    final own = st.copyWith(relay: 'https://relay.example.com');
    expect(settingsToJson(own)['relay'], 'https://relay.example.com');
    expect(own.copyWith(away: false).relay, 'https://relay.example.com');
    expect(own.copyWith(relay: null).relay, isNull);
    expect(
      settingsFromJson({
        'name': 'P',
        'download_dir': '/d',
        'relay': 'https://relay.example.com/',
      }).relay,
      'https://relay.example.com/',
    );
  });
}
