import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/deck_copy.dart';
import 'package:linksy/core/deck_draft.dart';
import 'package:linksy/core/deck_layouts.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/models.dart';

DeckTile t(
  String id,
  String kind,
  int x,
  int y,
  int w,
  int h, {
  String? action,
  Map<String, String> props = const {},
}) => DeckTile(
  id: id,
  kind: kind,
  x: x,
  y: y,
  w: w,
  h: h,
  action: action,
  props: props,
);

DeckLayouts deck(
  List<DeckTile> tiles, {
  int columns = 4,
  int rows = 8,
  String theme = 'dots',
  int version = 0,
}) => DeckLayouts(
  version: version,
  active: 'work',
  layouts: [
    DeckLayout(
      id: 'work',
      name: 'Work',
      theme: DeckTheme(id: theme, accent: DeckTheme.dots.accent),
      portrait: DeckFace(columns: columns, rows: rows, pages: [tiles]),
      landscape: const DeckFace(columns: 9, rows: 4, pages: [[]]),
    ),
  ],
);

/// More than a computer takes, in every way.
DeckLayouts wild() => deck(
  [
    t('a', 'button', 0, 0, 3, 3, action: 'media.next'),
    t('b', 'clock', 3, 0, 3, 3),
    t('c', 'music', 0, 3, 6, 1),
    t('d', 'volume', 0, 4, 2, 2, action: 'sound.volume'),
    t('e', 'phone', 2, 4, 1, 1, props: {'do': 'ping'}),
    t('f', 'touchpad', 0, 6, 4, 4),
    t('g', 'stat', 4, 14, 2, 1, props: {'metric': 'cpu'}),
    t('h', 'stat', 0, 15, 4, 1, props: {'metric': 'ram'}),
    t('i', 'stat', 4, 15, 1, 1, props: {'metric': 'gpu'}),
  ],
  columns: 6,
  rows: 16,
  theme: 'glass',
);

/// A computer that keeps decks: what it was sent, and its answers.
class _Computer extends DemoNode {
  _Computer() : super(name: 'Test Phone', downloadDir: '/d');

  final saves = <(int, DeckLayouts)>[];
  final _told = StreamController<LinksyEvent>.broadcast();

  late DeviceInfo pc;

  void tell(LinksyEvent e) => _told.add(e);

  @override
  Stream<LinksyEvent> get events => _told.stream;

  @override
  Future<void> deckLayoutSave(
    String id,
    int base,
    Map<String, Object?> layouts,
  ) async =>
      saves.add((base, DeckLayouts.parse(jsonDecode(jsonEncode(layouts)))!));
}

void main() {
  test('what a computer takes is sent as it is', () {
    final d = deck([
      t('a', 'button', 0, 0, 2, 1, action: 'media.next'),
      t('b', 'stat', 2, 0, 2, 2, props: {'metric': 'ram'}),
    ]);
    expect(deckContent(deckForComputer(d)), deckContent(d));
  });

  test('the rest is made smaller, moved into the grid or left out', () {
    final face = deckForComputer(wild()).layouts.single.portrait;
    expect((face.columns, face.rows), (6, 12));
    final tiles = {for (final x in face.pages.expand((p) => p)) x.id: x};
    expect(tiles.keys, unorderedEquals(['a', 'b', 'd', 'g', 'h']));
    expect((tiles['a']!.w, tiles['a']!.h), (2, 1));
    expect((tiles['d']!.w, tiles['d']!.h), (2, 1));
    expect(tiles['g']!.y, lessThan(12));
    expect(deckForComputer(wild()).layouts.single.theme.id, 'stock');
    expect(
      deckForComputer(wild(), actions: {}).layouts.single.portrait.pages
          .expand((p) => p)
          .map((x) => x.kind)
          .toSet(),
      {'clock', 'stat'},
    );
    // For the core's own check (tool: rust example), when asked.
    if (Platform.environment['DECK_OUT'] case final out?) {
      File(out).writeAsStringSync(
        jsonEncode([
          deckForComputer(wild()).toJson(),
          deckForComputer(
            DeckDraft.starter(
              'Deck',
              const [
                DeckAction(
                  id: 'media.next',
                  name: 'Next',
                  kind: DeckKind.button,
                ),
                DeckAction(
                  id: 'sound.volume',
                  name: 'Volume',
                  kind: DeckKind.slider,
                ),
              ],
              portrait: (6, 14),
              landscape: (14, 6),
            ),
          ).toJson(),
        ]),
      );
    }
  });

  test('a finer grid than the computer has is read back whole', () {
    final back = DeckLayouts.decode(jsonEncode(wild().toJson()))!;
    expect(back.layouts.single.portrait.rows, 16);
    expect(
      back.layouts.single.portrait.pages.first.firstWhere((x) => x.id == 'h').y,
      15,
    );
  });

  group('with a computer that keeps decks', () {
    late _Computer node;
    late LinksyController c;
    late Directory dir;
    final made = deck([t('old', 'clock', 0, 0, 2, 1)], version: 3);

    Future<void> tick() =>
        Future<void>.delayed(const Duration(milliseconds: 60));

    Future<void> start() async {
      node = _Computer();
      node.pc = (await node.devices())
          .firstWhere((v) => v.device.name == 'Studio Desktop')
          .device;
      c = LinksyController(node, ActivityStore(null), dir: dir);
      await c.start().timeout(const Duration(seconds: 5), onTimeout: () {});
    }

    Future<void> open(DeckLayouts layouts) async {
      node.tell(
        DeckActionsReceived(
          from: node.pc,
          actions: const [
            DeckAction(id: 'media.next', name: 'Next', kind: DeckKind.button),
          ],
        ),
      );
      node.tell(DeckLayoutReceived(from: node.pc, layouts: layouts.toJson()));
      await tick();
    }

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      dir = Directory.systemTemp.createTempSync('deck');
      await start();
    });
    tearDown(() async {
      c.dispose();
      await tick();
      dir.deleteSync(recursive: true);
    });

    test('nothing is sent while the deck is the computer\'s own', () async {
      await open(made);
      expect(node.saves, isEmpty);
      expect(c.deckLayouts(node.pc.id)!.version, 3);
    });

    test('a deck made here goes once, and its answer sends nothing', () async {
      await open(made);
      await c.saveDeckHere(node.pc.id, wild());
      await tick();
      expect(node.saves, hasLength(1));
      expect(node.saves.single.$1, 3);
      final kept = node.saves.single.$2.copyWith(version: 4);
      await open(kept);
      await open(kept);
      expect(node.saves, hasLength(1));
      expect(
        deckContent(c.deckLayouts(node.pc.id)!),
        deckContent(wild()),
        reason: 'the phone shows its own',
      );
    });

    test('what the computer had made is still there to go back to, even '
        'after a restart', () async {
      await open(made);
      await c.saveDeckHere(node.pc.id, wild());
      await tick();
      final kept = node.saves.single.$2.copyWith(version: 4);
      await open(kept);
      c.dispose();
      await start();
      await open(kept);
      expect(node.saves, isEmpty);
      await c.dropDeckHere(node.pc.id);
      await tick();
      expect(deckContent(c.deckLayouts(node.pc.id)!), deckContent(made));
      expect(node.saves.single.$1, 4);
      expect(deckContent(node.saves.single.$2), deckContent(made));
    });

    test('stale: again on the computer\'s version; invalid: once, with what '
        'it offers', () async {
      await open(made);
      await c.saveDeckHere(node.pc.id, wild());
      await tick();
      node.tell(DeckLayoutRefused(from: node.pc, code: 'stale', reason: ''));
      await open(made.copyWith(version: 7));
      expect(node.saves.last.$1, 7);
      for (var i = 0; i < 3; i++) {
        node.tell(
          DeckLayoutRefused(from: node.pc, code: 'invalid', reason: 'x'),
        );
        await tick();
      }
      expect(node.saves, hasLength(3));
      expect(
        node.saves.last.$2.layouts.single.portrait.pages.first.map((x) => x.id),
        isNot(contains('d')),
        reason: 'the volume is not offered',
      );
    });
  });
}
