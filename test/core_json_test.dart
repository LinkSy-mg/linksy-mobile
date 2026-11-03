import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/core_json.dart';
import 'package:linksy/core/deck_layouts.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/core/rust_node.dart';

void main() {
  final id = 'ebb09ce2${'a' * 56}';
  final device = {
    'id': id,
    'name': 'Studio Desktop',
    'kind': 'desktop',
    'os': 'linux',
  };
  LinksyEvent? parse(Map<String, Object?> j) =>
      eventFromJson(jsonDecode(jsonEncode(j)) as Json);

  test('reads devices as the core serializes them', () {
    final v = deviceViewFromJson({
      'device': device,
      'trusted': true,
      'connected': false,
      'nearby': true,
    });
    expect(v.device.id, id);
    expect(v.device.kind, DeviceKind.desktop);
    expect(v.presence, Presence.nearby);
  });

  test('reads pairing and transfer events', () {
    final pairing = parse({
      'type': 'pairing_request',
      'request': '0b3f-uuid',
      'device': device,
      'code': '147331',
      'incoming': true,
    });
    expect(pairing, isA<PairingRequest>());
    expect((pairing! as PairingRequest).code, '147331');

    final started =
        parse({
              'type': 'transfer_started',
              'transfer': 't1',
              'peer': device,
              'direction': 'incoming',
              'files': [
                {'path': 'Photos/a.jpg', 'size': 123},
              ],
              'total': 123,
            })!
            as TransferStarted;
    expect(started.incoming, isTrue);
    expect(started.peer?.name, 'Studio Desktop');
    expect(started.files.single.name, 'a.jpg');

    final connected = parse({'type': 'connected', 'device': device});
    expect((connected! as Connected).id, id);
  });

  test('settings round-trip in the core\'s field names', () {
    final s = settingsFromJson({
      'name': 'Pixel 9',
      'download_dir': '/sdcard/Received',
      'stay_connected': false,
      'auto_accept': true,
    });
    expect(s.autoAccept, isTrue);
    expect(settingsToJson(s)['download_dir'], '/sdcard/Received');
  });

  test('reads media session events', () {
    final request =
        parse({
              'type': 'session_request',
              'request': 's1',
              'from': device,
              'kind': 'camera',
            })!
            as SessionRequest;
    expect(request.kind, SessionKind.camera);
    expect(request.from.name, 'Studio Desktop');

    final started =
        parse({
              'type': 'session_started',
              'session': 's1',
              'peer': device,
              'kind': 'screen',
              'sharing': true,
            })!
            as SessionStarted;
    expect(started.sharing, isTrue);
    expect(started.kind, SessionKind.screen);

    expect(
      parse({'type': 'session_ended', 'session': 's1'}),
      isA<SessionEnded>(),
    );
  });

  test('reads links, batteries and rings', () {
    final link = parse({
      'type': 'open_url',
      'from': device,
      'url': 'https://linksy.diary.mg/',
    });
    expect(link, isA<OpenUrlReceived>());
    expect((link as OpenUrlReceived).url, 'https://linksy.diary.mg/');

    final battery = parse({
      'type': 'battery',
      'from': device,
      'battery': {'level': 82, 'charging': true},
    });
    expect(
      (battery as BatteryReported).battery,
      const Battery(level: 82, charging: true),
    );

    final ring = parse({'type': 'ring', 'from': device, 'on': false});
    expect((ring as RingRequested).on, isFalse);

    final v = deviceViewFromJson({
      'device': device,
      'trusted': true,
      'connected': true,
      'nearby': true,
      'battery': {'level': 40, 'charging': false},
    });
    expect(v.battery?.level, 40);
  });

  test('reads what a computer answers to this phone\'s notifications', () {
    const key = '0|com.whatsapp|1|null|10123';
    final reply = parse({
      'type': 'notification_reply',
      'from': device,
      'key': key,
      'text': 'Sure!',
    });
    expect((reply as NotificationReplyRequested).key, key);
    expect(reply.text, 'Sure!');

    final action = parse({
      'type': 'notification_action',
      'from': device,
      'key': key,
      'action': '1',
    });
    expect((action as NotificationActionRequested).action, '1');

    final dismissed = parse({
      'type': 'notification_dismissed',
      'from': device,
      'key': key,
    });
    expect((dismissed as NotificationDismissRequested).key, key);
  });

  test('reads media and lock-when-away events', () {
    final media = parse({
      'type': 'media_state',
      'from': device,
      'state': {
        'seq': 1760945000123,
        'players': [
          {
            'id': 'spotify',
            'app': 'Spotify',
            'title': 'Song',
            'playing': true,
            'length_ms': 215000,
            'can_next': true,
          },
        ],
      },
    });
    final p = (media as MediaStateReceived).state.players.single;
    expect(p.app, 'Spotify');
    expect(p.playing, isTrue);
    expect(p.canNext, isTrue);
    expect(p.canPrevious, isFalse);
    expect(p.lengthMs, 215000);

    final watch = parse({
      'type': 'heartbeat_watch',
      'from': device,
      'on': true,
      'every_s': 20,
    });
    expect((watch as HeartbeatWatchChanged).everyS, 20);
    expect(SessionKind.parse('input'), SessionKind.input);
  });

  test('reads the deck: confirm questions, state text and layouts', () {
    final actions =
        parse({
              'type': 'deck_actions',
              'from': device,
              'actions': [
                {'id': 'media.next', 'name': 'Next Track', 'kind': 'button'},
                {
                  'id': 'system.restart',
                  'name': 'Restart',
                  'kind': 'button',
                  'group': 'System',
                  'confirm': 'Restart Studio Desktop?',
                },
              ],
            })!
            as DeckActionsReceived;
    expect(actions.actions.first.confirm, isNull);
    expect(actions.actions.last.confirm, 'Restart Studio Desktop?');
    final states =
        parse({
              'type': 'deck_state',
              'from': device,
              'states': [
                {'id': 'sound.output', 'text': 'Speakers'},
              ],
            })!
            as DeckStateReceived;
    expect(states.states.single.text, 'Speakers');

    final e =
        parse({
              'type': 'deck_layout',
              'from': device,
              'layouts': {
                'version': 3,
                'active': 'work',
                'layouts': [
                  {'id': 'music', 'name': 'Music'},
                  {
                    'id': 'work',
                    'name': 'Work',
                    'theme': {'id': 'glass_from_later', 'accent': '#2563ff'},
                    'portrait': {
                      'grid': [4, 8],
                      'pages': [
                        [
                          {
                            'id': 'c',
                            'kind': 'clock',
                            'x': 0,
                            'y': 0,
                            'w': 2,
                            'h': 1,
                          },
                          {
                            'id': 'l',
                            'kind': 'button',
                            'x': 3,
                            'y': 7,
                            'w': 2,
                            'h': 1,
                            'color': '#e01b24',
                            'action': 'system.lock',
                            'props': {'zone': 'Europe/Paris', 'n': 1},
                          },
                          {
                            'id': 'w',
                            'kind': 'weather',
                            'x': 0,
                            'y': 1,
                            'w': 1,
                            'h': 1,
                          },
                        ],
                      ],
                    },
                  },
                ],
              },
            })!
            as DeckLayoutReceived;
    final layouts = DeckLayouts.parse(e.layouts)!;
    expect(layouts.version, 3);
    final work = layouts.shown!;
    expect(work.id, 'work');
    // An unknown theme is drawn as Stock by the phone; the id stays.
    expect(work.theme.id, 'glass_from_later');
    expect(work.theme.accent, const Color(0xFF2563FF));
    // A face not sent: the editor's grid, one empty page.
    expect((work.landscape.columns, work.landscape.rows), (9, 4));
    expect(work.landscape.isEmpty, isTrue);
    final tiles = work.portrait.pages.single;
    expect(tiles.map((t) => t.kind), ['clock', 'button', 'weather']);
    // Kept inside the grid, whatever came.
    expect((tiles[1].x, tiles[1].w), (3, 1));
    expect(tiles[1].color, const Color(0xFFE01B24));
    expect(tiles[1].props, {'zone': 'Europe/Paris'});
    expect(layouts.layouts.first.theme.id, 'stock');

    // The active one gone: the first.
    expect(
      DeckLayouts.parse({
        'active': 'gone',
        'layouts': [
          {'id': 'a', 'name': 'A'},
        ],
      })!.shown!.id,
      'a',
    );
    expect(DeckLayouts.decode('not json'), isNull);
    expect(DeckLayouts.parse({'layouts': []})!.shown, isNull);
  });

  test('ignores event types and session kinds it does not know', () {
    expect(parse({'type': 'from_the_future'}), isNull);
    expect(
      parse({
        'type': 'session_request',
        'request': 's2',
        'from': device,
        'kind': 'hologram',
      }),
      isNull,
    );
  });

  test('core errors read as sentences naming the device', () {
    expect(
      describeCoreError('unreachable', 'Studio Desktop'),
      "Studio Desktop isn't reachable. Check that it's on and on this network.",
    );
    expect(describeCoreError('declined', 'ThinkPad'), 'ThinkPad declined.');
    expect(
      describeCoreError("invalid:that's this device's own code", 'X'),
      "that's this device's own code",
    );
    expect(
      describeCoreError('other:connection lost: timed out', 'X'),
      'Something went wrong: connection lost: timed out',
    );
  });
}
