import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/deck_draft.dart';
import 'package:linksy/core/deck_layouts.dart';
import 'package:linksy/core/models.dart';

DeckAction a(String id, [DeckKind kind = DeckKind.button]) =>
    DeckAction(id: id, name: id, kind: kind);

/// A desktop's usual offer.
final offered = [
  a('sound.volume', DeckKind.slider),
  a('sound.mute', DeckKind.toggle),
  a('sound.mic_mute', DeckKind.toggle),
  a('media.play_pause'),
  a('media.next'),
  a('media.previous'),
  a('system.lock'),
  a('system.dnd', DeckKind.toggle),
  a('command.backup'),
];

/// Every cell of [face]'s first page taken once, nothing past the grid.
void expectFull(DeckFace face) {
  final cells = <(int, int)>{};
  for (final t in face.pages.first) {
    expect(t.x + t.w, lessThanOrEqualTo(face.columns), reason: t.id);
    expect(t.y + t.h, lessThanOrEqualTo(face.rows), reason: t.id);
    for (var y = t.y; y < t.y + t.h; y++) {
      for (var x = t.x; x < t.x + t.w; x++) {
        expect(cells.add((x, y)), isTrue, reason: '${t.id} overlaps');
      }
    }
  }
  expect(cells.length, face.columns * face.rows);
}

void main() {
  test('the starting deck fills a phone upright and sideways', () {
    final deck = DeckDraft.starter(
      'Deck',
      offered,
      portrait: (4, 9),
      landscape: (10, 4),
    ).layouts.single;
    expectFull(deck.portrait);
    expectFull(deck.landscape);
  });

  test('and a tablet, with few things offered', () {
    final deck = DeckDraft.starter(
      'Deck',
      offered.take(4).toList(),
      portrait: (6, 10),
      landscape: (11, 6),
    ).layouts.single;
    expectFull(deck.portrait);
    expectFull(deck.landscape);
  });

  test('the phone tiles join what the computer offers', () {
    final tiles = DeckDraft.starter(
      'Deck',
      offered,
      portrait: (4, 12),
    ).layouts.single.portrait.pages.first;
    expect(
      tiles.where((t) => t.kind == 'phone').map((t) => t.props['do']),
      containsAll(['clipboard', 'ping', 'find']),
    );
  });

  test('on a full deck, a tile dropped on another swaps with it', () {
    DeckTile t(String id, int x) =>
        DeckTile(id: id, kind: 'button', x: x, y: 0, w: 1, h: 1);
    final draft = DeckDraft(
      DeckLayouts(
        version: 0,
        active: 'l',
        layouts: [
          DeckLayout(
            id: 'l',
            name: 'Deck',
            theme: DeckTheme.dots,
            portrait: DeckFace(
              columns: 2,
              rows: 1,
              pages: [
                [t('a', 0), t('b', 1)],
              ],
            ),
            landscape: const DeckFace(columns: 2, rows: 1, pages: [[]]),
          ),
        ],
      ),
    );
    expect(draft.move('a', 1, 0), isTrue);
    expect(draft.tile('a')!.x, 1);
    expect(draft.tile('b')!.x, 0);
  });

  test('the Remote page fills the grid both ways up, the touchpad biggest', () {
    for (final (columns, rows, tall) in [
      (4, 9, true),
      (6, 10, true),
      (10, 4, false),
      (11, 6, false),
    ]) {
      final tiles = DeckDraft.remotePage(columns, rows, tall: tall);
      expectFull(DeckFace(columns: columns, rows: rows, pages: [tiles]));
      final pad = tiles.singleWhere((t) => t.kind == 'touchpad');
      expect(pad.w * pad.h, greaterThan(columns * rows ~/ 2));
      expect(
        tiles
            .where((t) => t.props['do'] == 'click')
            .map((t) => t.props['button']),
        unorderedEquals(['left', 'right']),
      );
    }
  });
}
