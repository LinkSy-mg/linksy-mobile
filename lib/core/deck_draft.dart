/// Editing the deck's layouts on the phone, with undo. The rules are the
/// core's (`deck_layout.rs`, docs/protocol.md §4.20): inside the grid, no
/// overlaps, and the limits. Sizes are freer than its list: any that reads.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'deck_layouts.dart';
import 'models.dart';

/// What a new deck starts from.
enum DeckStart { blank, media, presenter }

class DeckDraft {
  DeckDraft(this.layouts) : layoutId = layouts.shown?.id ?? '';

  static const maxLayouts = 20;
  static const maxPages = 8;
  static const maxTiles = 64;
  static const maxLabel = 60;
  static const portraitGrid = (4, 8);
  static const landscapeGrid = (9, 4);

  /// The sizes [kind] takes, its usual one first. One this phone doesn't know
  /// stays the size it came.
  static List<(int, int)> sizesOf(String kind) => switch (kind) {
    'button' => const [(1, 1), (2, 1)],
    'volume' => const [(4, 1), (2, 1), (1, 3)],
    'music' => const [(4, 2), (2, 2)],
    'clock' => const [(2, 1), (2, 2), (1, 1)],
    _ => const [],
  };

  /// Whether [kind] can be [w] × [h]: any size, as long as it still reads.
  static bool allows(String kind, int w, int h) => switch (kind) {
    'music' => w >= 2 && h >= 2,
    'volume' => w * h >= 2,
    _ => true,
  };

  DeckLayouts layouts;
  String layoutId;
  bool landscape = false;
  int page = 0;

  final _past = <DeckLayouts>[];
  final _future = <DeckLayouts>[];
  var _made = 0;

  bool get changed => _past.isNotEmpty;
  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  void _commit(DeckLayouts next) {
    _past.add(layouts);
    if (_past.length > 60) _past.removeAt(0);
    _future.clear();
    layouts = next;
  }

  void _settle() {
    if (!layouts.layouts.any((l) => l.id == layoutId)) {
      layoutId = layouts.shown?.id ?? '';
    }
    final pages = face.pages.length;
    if (page >= pages) page = pages - 1;
  }

  void undo() {
    if (_past.isEmpty) return;
    _future.add(layouts);
    layouts = _past.removeLast();
    _settle();
  }

  void redo() {
    if (_future.isEmpty) return;
    _past.add(layouts);
    layouts = _future.removeLast();
    _settle();
  }

  DeckLayout get layout => layouts.layouts.firstWhere((l) => l.id == layoutId);
  DeckFace get face => landscape ? layout.landscape : layout.portrait;
  List<DeckTile> get tiles => face.pages[page];

  void _replaceLayout(DeckLayout next) => _commit(
    layouts.copyWith(
      layouts: [
        for (final l in layouts.layouts)
          if (l.id == next.id) next else l,
      ],
    ),
  );

  void _setFace(DeckFace next) => _replaceLayout(
    landscape
        ? layout.copyWith(landscape: next)
        : layout.copyWith(portrait: next),
  );

  void _setTiles(List<DeckTile> next) {
    final pages = [...face.pages];
    pages[page] = next;
    _setFace(face.withPages(pages));
  }

  String _newId(String prefix) =>
      '$prefix${DateTime.now().microsecondsSinceEpoch}-${_made++}';

  // Where things go.

  bool fits(int x, int y, int w, int h, {String? ignore, List<DeckTile>? on}) {
    if (x < 0 || y < 0 || x + w > face.columns || y + h > face.rows) {
      return false;
    }
    for (final t in on ?? tiles) {
      if (t.id == ignore) continue;
      if (x < t.x + t.w && t.x < x + w && y < t.y + t.h && t.y < y + h) {
        return false;
      }
    }
    return true;
  }

  (int, int)? freeSpot(int w, int h, {List<DeckTile>? on}) {
    for (var y = 0; y + h <= face.rows; y++) {
      for (var x = 0; x + w <= face.columns; x++) {
        if (fits(x, y, w, h, on: on)) return (x, y);
      }
    }
    return null;
  }

  DeckTile? tile(String id) => tiles.where((t) => t.id == id).firstOrNull;

  // Tiles.

  /// A tile of [kind], at ([x], [y]) when it fits there, else the first free
  /// spot. Its usual size, or the next that fits. Null: no room.
  DeckTile? add(String kind, {String? action, int? x, int? y}) {
    if (tiles.length >= maxTiles) return null;
    for (final (w, h) in sizesOf(kind)) {
      final at = x != null && y != null && fits(x, y, w, h)
          ? (x, y)
          : freeSpot(w, h);
      if (at == null) continue;
      final tile = DeckTile(
        id: _newId('t'),
        kind: kind,
        x: at.$1,
        y: at.$2,
        w: w,
        h: h,
        action: action,
      );
      _setTiles([...tiles, tile]);
      return tile;
    }
    return null;
  }

  void replace(DeckTile next) => _setTiles([
    for (final t in tiles)
      if (t.id == next.id) next else t,
  ]);

  bool move(String id, int x, int y) {
    final t = tile(id);
    if (t == null || (t.x == x && t.y == y)) return false;
    final next = arranged(id, x, y, t.w, t.h);
    if (next == null) return false;
    settle(next);
    return true;
  }

  /// The page with [id] at this place and size, the tiles in its way moved
  /// to the nearest room there is. Null when there's none left for them.
  List<DeckTile>? arranged(String id, int x, int y, int w, int h) {
    final t = tile(id);
    if (t == null || !DeckDraft.allows(t.kind, w, h)) return null;
    if (x < 0 || y < 0 || x + w > face.columns || y + h > face.rows) {
      return null;
    }
    final placed = t.copyWith(x: x, y: y, w: w, h: h);
    bool over(DeckTile o) =>
        x < o.x + o.w && o.x < x + w && y < o.y + o.h && o.y < y + h;
    final next = <DeckTile>[placed];
    final moved = <DeckTile>[];
    for (final o in tiles) {
      if (o.id == id) continue;
      (over(o) ? moved : next).add(o);
    }
    // The ones nearest it first, each to the spot nearest where it was.
    int far(DeckTile o) => (o.x - x).abs() + (o.y - y).abs();
    moved.sort((a, b) => far(a) - far(b));
    for (final o in moved) {
      final at = _nearest(o, next);
      if (at == null) return null;
      next.add(o.copyWith(x: at.$1, y: at.$2));
    }
    // In their first order: what's drawn last stays last.
    final order = {for (final (i, o) in tiles.indexed) o.id: i};
    return next..sort((a, b) => order[a.id]! - order[b.id]!);
  }

  (int, int)? _nearest(DeckTile t, List<DeckTile> on) {
    (int, int)? best;
    var least = 1 << 30;
    for (var y = 0; y + t.h <= face.rows; y++) {
      for (var x = 0; x + t.w <= face.columns; x++) {
        final d = (x - t.x).abs() + (y - t.y).abs();
        if (d < least && fits(x, y, t.w, t.h, on: on)) {
          least = d;
          best = (x, y);
        }
      }
    }
    return best;
  }

  /// What [arranged] came to, as one step of undo.
  void settle(List<DeckTile> tiles) => _setTiles(tiles);

  /// To [w] × [h] where it is, room made. False when it can't be.
  bool resize(String id, int w, int h) {
    final t = tile(id);
    if (t == null || (t.w == w && t.h == h)) return false;
    final next = arranged(
      id,
      t.x.clamp(0, math.max(0, face.columns - w)),
      t.y.clamp(0, math.max(0, face.rows - h)),
      w,
      h,
    );
    if (next == null) return false;
    settle(next);
    return true;
  }

  void remove(String id) => _setTiles([
    for (final t in tiles)
      if (t.id != id) t,
  ]);

  /// A copy in the next free spot, on this page.
  DeckTile? duplicate(String id) {
    final t = tile(id);
    if (t == null || tiles.length >= maxTiles) return null;
    final at = freeSpot(t.w, t.h);
    if (at == null) return null;
    final copy = t.copyWith(id: _newId('t'), x: at.$1, y: at.$2);
    _setTiles([...tiles, copy]);
    return copy;
  }

  bool moveToPage(String id, int to) {
    final t = tile(id);
    if (t == null || to == page) return false;
    final target = face.pages[to];
    final at = freeSpot(t.w, t.h, on: target);
    if (at == null) return false;
    final pages = [...face.pages];
    pages[page] = [
      for (final o in tiles)
        if (o.id != id) o,
    ];
    pages[to] = [...target, t.copyWith(x: at.$1, y: at.$2)];
    _setFace(face.withPages(pages));
    return true;
  }

  /// One button for each thing it offers that isn't on this page, while
  /// there's room. How many went on.
  int fill(List<DeckAction> offered) {
    final there = {for (final t in tiles) t.action};
    final next = [...tiles];
    var added = 0;
    for (final a in offered) {
      if (there.contains(a.id) || a.kind == DeckKind.slider) continue;
      final at = freeSpot(1, 1, on: next);
      if (at == null || next.length >= maxTiles) break;
      next.add(
        DeckTile(
          id: _newId('t'),
          kind: 'button',
          x: at.$1,
          y: at.$2,
          w: 1,
          h: 1,
          action: a.id,
        ),
      );
      added++;
    }
    if (added > 0) _setTiles(next);
    return added;
  }

  // Pages.

  bool addPage() {
    if (face.pages.length >= maxPages) return false;
    _setFace(face.withPages([...face.pages, const []]));
    page = face.pages.length - 1;
    return true;
  }

  void removePage() {
    if (face.pages.length < 2) return;
    _setFace(face.withPages([...face.pages]..removeAt(page)));
    if (page >= face.pages.length) page = face.pages.length - 1;
  }

  // Layouts.

  void show(String id) {
    layoutId = id;
    page = 0;
    _commit(layouts.copyWith(active: id));
  }

  void rename(String id, String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final text = clean.characters60;
    final l = layouts.layouts.firstWhere((l) => l.id == id);
    _replaceLayout(l.copyWith(name: text));
  }

  void setTheme(DeckTheme theme) =>
      _replaceLayout(layout.copyWith(theme: theme));

  bool removeLayout(String id) {
    if (layouts.layouts.length < 2) return false;
    final rest = [
      for (final l in layouts.layouts)
        if (l.id != id) l,
    ];
    _commit(
      layouts.copyWith(
        layouts: rest,
        active: layouts.active == id ? rest.first.id : layouts.active,
      ),
    );
    _settle();
    page = 0;
    return true;
  }

  /// A new layout, shown. False at the limit.
  bool newLayout(String name, DeckStart start, List<DeckAction> offered) {
    if (layouts.layouts.length >= maxLayouts) return false;
    final made = _withLandscape(_make(_newId('l'), name, start, offered));
    _commit(
      layouts.copyWith(layouts: [...layouts.layouts, made], active: made.id),
    );
    layoutId = made.id;
    page = 0;
    return true;
  }

  /// This layout's landscape, from its portrait: the same tiles in the same
  /// order, each as big as still fits.
  void landscapeFromPortrait() {
    _replaceLayout(_withLandscape(layout));
  }

  static DeckLayout _withLandscape(DeckLayout l) {
    final wide = l.landscape;
    bool clear(List<DeckTile> on, int x, int y, int w, int h) => !on.any(
      (o) => x < o.x + o.w && o.x < x + w && y < o.y + o.h && o.y < y + h,
    );
    (int, int)? spot(List<DeckTile> on, int w, int h) {
      for (var y = 0; y + h <= wide.rows; y++) {
        for (var x = 0; x + w <= wide.columns; x++) {
          if (clear(on, x, y, w, h)) return (x, y);
        }
      }
      return null;
    }

    final pages = <List<DeckTile>>[];
    for (final source in l.portrait.pages) {
      final next = <DeckTile>[];
      final ordered = [...source]
        ..sort((a, b) => a.y != b.y ? a.y - b.y : a.x - b.x);
      for (final t in ordered) {
        // Its own size, then smaller ones, until one fits.
        place:
        for (var h = math.min(t.h, wide.rows); h >= 1; h--) {
          for (var w = math.min(t.w, wide.columns); w >= 1; w--) {
            if (!allows(t.kind, w, h)) continue;
            final at = spot(next, w, h);
            if (at == null) continue;
            next.add(t.copyWith(x: at.$1, y: at.$2, w: w, h: h));
            break place;
          }
        }
      }
      pages.add(next);
    }
    return l.copyWith(landscape: wide.withPages(pages));
  }

  /// What a computer that sent no layouts starts from.
  static DeckLayouts starter(String name, List<DeckAction> offered) {
    final made = _withLandscape(
      _make('deck', name, DeckStart.media, offered, full: true),
    );
    return DeckLayouts(version: 0, active: made.id, layouts: [made]);
  }

  static DeckLayout _make(
    String id,
    String name,
    DeckStart start,
    List<DeckAction> offered, {
    bool full = false,
  }) {
    final has = {for (final a in offered) a.id};
    final tiles = <DeckTile>[];
    var y = 0;
    void put(String kind, int x, int y, int w, int h, [String? action]) =>
        tiles.add(
          DeckTile(
            id: '$kind$x$y',
            kind: kind,
            x: x,
            y: y,
            w: w,
            h: h,
            action: action,
          ),
        );
    void row(List<String> actions) {
      var x = 0;
      for (final a in actions.where(has.contains)) {
        if (x == 4) {
          x = 0;
          y++;
        }
        put('button', x++, y, 1, 1, a);
      }
      if (x > 0) y++;
    }

    switch (start) {
      case DeckStart.blank:
        break;
      case DeckStart.media:
        put('clock', 0, 0, 2, 1);
        var x = 2;
        for (final a in ['system.lock', 'sound.mic_mute'].where(has.contains)) {
          put('button', x++, 0, 1, 1, a);
        }
        put('music', 0, 1, 4, 2);
        y = 3;
        if (has.contains('sound.volume')) {
          put('volume', 0, y++, 4, 1, 'sound.volume');
        }
        row(['media.previous', 'media.play_pause', 'media.next', 'sound.mute']);
        if (full) {
          final used = {for (final t in tiles) t.action};
          row(
            [
              for (final a in offered)
                if (!used.contains(a.id) && a.kind != DeckKind.slider) a.id,
            ].take(8 * (8 - y).clamp(0, 2)).toList(),
          );
        }
      case DeckStart.presenter:
        put('clock', 0, 0, 2, 2);
        var x = 2;
        for (final a in ['sound.mic_mute', 'system.dnd'].where(has.contains)) {
          put('button', x++, 0, 1, 1, a);
        }
        y = 2;
        if (has.contains('sound.volume')) {
          put('volume', 0, y++, 4, 1, 'sound.volume');
        }
        row(['media.previous', 'media.next', 'system.lock']);
    }
    final (pc, pr) = portraitGrid;
    final (lc, lr) = landscapeGrid;
    return DeckLayout(
      id: id,
      name: name,
      theme: DeckTheme.dots,
      portrait: DeckFace(columns: pc, rows: pr, pages: [tiles]),
      landscape: DeckFace(columns: lc, rows: lr, pages: const [[]]),
    );
  }
}

extension on String {
  String get characters60 => runes.length <= DeckDraft.maxLabel
      ? this
      : String.fromCharCodes(runes.take(DeckDraft.maxLabel));
}

/// The colours a tile can take; null is the look's own.
const deckSwatches = <Color?>[
  null,
  Color(0xFF3B8BEB),
  Color(0xFF22C3E6),
  Color(0xFF34D27A),
  Color(0xFFF2A81D),
  Color(0xFFEF4B4B),
  Color(0xFFB36BFF),
];
