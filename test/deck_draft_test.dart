import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/deck_draft.dart';
import 'package:linksy/core/deck_layouts.dart';
import 'package:linksy/core/models.dart';

void main() {
  const offered = [
    DeckAction(id: 'system.lock', name: 'Lock', kind: DeckKind.button),
    DeckAction(id: 'sound.mic_mute', name: 'Mic', kind: DeckKind.toggle),
    DeckAction(id: 'sound.volume', name: 'Volume', kind: DeckKind.slider),
    DeckAction(id: 'media.next', name: 'Next', kind: DeckKind.button),
    DeckAction(id: 'command.1', name: 'Deploy', kind: DeckKind.button),
  ];

  DeckDraft draft() => DeckDraft(DeckDraft.starter('Work', offered));

  /// No tile outside the grid or over another.
  void sound(DeckDraft d) {
    for (final l in d.layouts.layouts) {
      for (final f in [l.portrait, l.landscape]) {
        for (final p in f.pages) {
          for (final t in p) {
            expect(t.x + t.w <= f.columns && t.y + t.h <= f.rows, isTrue);
            for (final o in p) {
              if (o.id == t.id) continue;
              final over =
                  t.x < o.x + o.w &&
                  o.x < t.x + t.w &&
                  t.y < o.y + o.h &&
                  o.y < t.y + t.h;
              expect(over, isFalse, reason: '${t.id} over ${o.id}');
            }
          }
        }
      }
    }
  }

  test('a new deck is on Dots, and sound', () {
    final d = draft();
    expect(d.layout.theme.id, 'dots');
    expect(d.tiles, isNotEmpty);
    sound(d);
  });

  test('a tile takes the place it is dragged to, the others make room', () {
    final d = draft();
    final t = d.add('button', action: 'media.next', x: 3, y: 7)!;
    expect(d.move(t.id, 0, 0), isTrue);
    expect((d.tile(t.id)!.x, d.tile(t.id)!.y), (0, 0));
    sound(d);
  });

  test('any size that reads, and undo brings it back', () {
    final d = draft();
    final t = d.add('button', action: 'media.next', x: 0, y: 7)!;
    expect(d.resize(t.id, 3, 1), isTrue);
    expect((d.tile(t.id)!.w, d.tile(t.id)!.h), (3, 1));
    d.undo();
    expect(d.tile(t.id)!.w, 1);
    d.redo();
    expect(d.tile(t.id)!.w, 3);
    expect(DeckDraft.allows('music', 1, 3), isFalse);
    expect(DeckDraft.allows('volume', 1, 1), isFalse);
    expect(DeckDraft.allows('button', 4, 3), isTrue);
  });

  test('growing over neighbours moves them, never onto each other', () {
    final d = draft();
    final t = d.tiles.firstWhere((o) => o.kind == 'clock');
    expect(d.resize(t.id, 4, 3), isTrue);
    sound(d);
    expect(d.tile(t.id)!.w, 4);
  });

  test('with no room left for the others, it says no', () {
    final d = draft()..addPage();
    for (var i = 0; i < 32; i++) {
      d.add('button', action: 'media.next');
    }
    final t = d.tiles.first;
    expect(d.resize(t.id, 2, 1), isFalse);
    sound(d);
  });

  test('a full page says no', () {
    final d = draft()..addPage();
    for (var i = 0; i < 32; i++) {
      expect(d.add('button', action: 'media.next'), isNotNull);
    }
    expect(d.add('button', action: 'media.next'), isNull);
    sound(d);
  });

  test('pages, moving between them, and removing one', () {
    final d = draft();
    final t = d.add('button', action: 'media.next')!;
    d.addPage();
    expect(d.page, 1);
    d.page = 0;
    expect(d.moveToPage(t.id, 1), isTrue);
    expect(d.tile(t.id), isNull);
    d.page = 1;
    expect(d.tile(t.id), isNotNull);
    d.removePage();
    expect(d.face.pages.length, 1);
  });

  test('a new deck has a landscape too, with every tile that fits', () {
    final d = draft();
    final tall = d.tiles.length;
    d.landscape = true;
    expect(d.tiles.length, tall);
    sound(d);
  });

  test('layouts can be made and removed, never the last', () {
    final d = draft();
    expect(d.newLayout('Stream', DeckStart.presenter, offered), isTrue);
    expect(d.layout.name, 'Stream');
    expect(d.removeLayout(d.layoutId), isTrue);
    expect(d.removeLayout(d.layoutId), isFalse);
  });

  test('what it saves reads back the same', () {
    final d = draft();
    final t = d.add('button', action: 'media.next')!;
    d.replace(t.copyWith(label: 'Skip', props: {'icon': 'lock'}));
    final back = DeckLayouts.parse(d.layouts.toJson())!;
    final tile = back.shown!.portrait.pages.first.firstWhere(
      (o) => o.id == t.id,
    );
    expect(tile.label, 'Skip');
    expect(tile.props['icon'], 'lock');
    expect(back.shown!.theme.id, 'dots');
  });
}
