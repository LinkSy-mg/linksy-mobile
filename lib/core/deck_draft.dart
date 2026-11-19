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
    'button' || 'phone' => const [(1, 1), (2, 1)],
    'touchpad' => const [(4, 4), (4, 3), (3, 3), (2, 2)],
    'volume' => const [(4, 1), (2, 1), (1, 3)],
    'music' => const [(4, 2), (4, 1), (2, 2)],
    'clock' => const [(2, 1), (2, 2), (1, 1)],
    _ => const [],
  };

  /// Whether [kind] can be [w] × [h]: any size, as long as it still reads.
  static bool allows(String kind, int w, int h) => switch (kind) {
    // One row high, on one line (mobile#21): wide enough for its buttons.
    'music' => h == 1 ? w >= 3 : w >= 2,
    'volume' => w * h >= 2,
    // Room to move a finger on.
    'touchpad' => w >= 2 && h >= 2,
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

  /// How many columns upright (rows sideways) the tiles of this face take,
  /// on any page: the grid never goes below it.
  int get usedAcross {
    var used = 1;
    for (final p in face.pages) {
      for (final t in p) {
        used = landscape
            ? math.max(used, t.y + t.h)
            : math.max(used, t.x + t.w);
      }
    }
    return used;
  }

  /// Smaller or bigger tiles: [n] columns upright, [n] rows sideways; the
  /// other way follows, the cells staying square. Never fewer than the tiles
  /// take; a step to undo.
  bool setAcross(int n) {
    if (n < usedAcross || n == (landscape ? face.rows : face.columns)) {
      return false;
    }
    _setFace(
      DeckFace(
        columns: landscape ? face.columns : n,
        rows: landscape ? n : face.rows,
        pages: face.pages,
      ),
    );
    return true;
  }

  /// The face's grid as this screen fits it (square cells, as many as fit):
  /// every cell the editor shows takes a tile. Not a step to undo; never
  /// fewer cells than the tiles use, which the caller sees to.
  void fitGrid(int columns, int rows) {
    final next = DeckFace(columns: columns, rows: rows, pages: face.pages);
    layouts = layouts.copyWith(
      layouts: [
        for (final l in layouts.layouts)
          if (l.id != layoutId)
            l
          else if (landscape)
            l.copyWith(landscape: next)
          else
            l.copyWith(portrait: next),
      ],
    );
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
  DeckTile? add(
    String kind, {
    String? action,
    Map<String, String> props = const {},
    int? x,
    int? y,
  }) {
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
        props: props,
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
    // Swapped, when they fit where it was: moved by as much the other way.
    // A full deck has no other room.
    if (moved.isNotEmpty) {
      final swapped = [
        for (final o in moved)
          o.copyWith(x: o.x - (x - t.x), y: o.y - (y - t.y)),
      ];
      final all = [...next];
      var fit = true;
      for (final o in swapped) {
        if (!fits(o.x, o.y, o.w, o.h, on: all)) {
          fit = false;
          break;
        }
        all.add(o);
      }
      if (fit) {
        final order = {for (final (i, o) in tiles.indexed) o.id: i};
        return all..sort((a, b) => order[a.id]! - order[b.id]!);
      }
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
  bool newLayout(
    String name,
    DeckStart start,
    List<DeckAction> offered, {
    (int, int) portrait = portraitGrid,
    (int, int) landscape = landscapeGrid,
  }) {
    if (layouts.layouts.length >= maxLayouts) return false;
    final made = _complete(
      _withLandscape(
        _make(
          _newId('l'),
          name,
          start,
          offered,
          portrait: portrait,
          landscape: landscape,
        ),
      ),
      offered,
      full: start != DeckStart.blank,
    );
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

  /// What a computer that sent no layouts starts from: both ways up, every
  /// cell of this screen's grid ([portrait], [landscape]) taken.
  static DeckLayouts starter(
    String name,
    List<DeckAction> offered, {
    (int, int) portrait = portraitGrid,
    (int, int) landscape = landscapeGrid,
  }) {
    final made = _complete(
      _withLandscape(
        _make(
          'deck',
          name,
          DeckStart.media,
          offered,
          full: true,
          portrait: portrait,
          landscape: landscape,
        ),
      ),
      offered,
      full: true,
    );
    return DeckLayouts(version: 0, active: made.id, layouts: [made]);
  }

  /// The deck's Remote page on a [columns] × [rows] grid: the touchpad as
  /// big as it can be, and around it the clicks, the keyboard and the keys
  /// it lacks (Esc, Tab, the arrows), every cell taken. Upright ([tall])
  /// the rest goes under it, sideways beside it.
  static List<DeckTile> remotePage(
    int columns,
    int rows, {
    required bool tall,
  }) {
    var made = 0;
    DeckTile phone(
      String does,
      int x,
      int y,
      int w, [
      Map<String, String>? more,
    ]) => DeckTile(
      id: 'r${made++}$does',
      kind: 'phone',
      x: x,
      y: y,
      w: w,
      h: 1,
      props: {'do': does, ...?more},
    );
    DeckTile key(String keys, int x, int y) => phone('shortcut', x, y, 1, {
      'keys': keys,
      if (const {'left', 'up', 'down', 'right'}.contains(keys)) 'icon': keys,
    });
    final tiles = <DeckTile>[];
    if (tall && columns >= 2 && rows >= 5) {
      final pad = rows - 3;
      final half = columns ~/ 2;
      tiles.addAll([
        DeckTile(id: 'rpad', kind: 'touchpad', x: 0, y: 0, w: columns, h: pad),
        phone('click', 0, pad, half, {'button': 'left'}),
        phone('click', half, pad, columns - half, {'button': 'right'}),
        phone('keyboard', 0, pad + 1, math.min(2, columns)),
        if (columns >= 4) ...[
          key('escape', 2, pad + 1),
          key('tab', 3, pad + 1),
        ],
        if (columns >= 4)
          for (final (i, k) in ['left', 'up', 'down', 'right'].indexed)
            key(k, i, pad + 2),
      ]);
    } else if (!tall && columns >= 5 && rows >= 3) {
      final pad = columns - 3;
      tiles.addAll([
        DeckTile(id: 'rpad', kind: 'touchpad', x: 0, y: 0, w: pad, h: rows),
        phone('click', pad, 0, 1, {'button': 'left'}),
        phone('click', pad + 1, 0, 1, {'button': 'right'}),
        phone('keyboard', pad + 2, 0, 1),
        key('escape', pad, 1),
        key('up', pad + 1, 1),
        key('tab', pad + 2, 1),
        key('left', pad, 2),
        key('down', pad + 1, 2),
        key('right', pad + 2, 2),
      ]);
    } else {
      tiles.add(
        DeckTile(id: 'rpad', kind: 'touchpad', x: 0, y: 0, w: columns, h: rows),
      );
    }
    return filled(tiles, columns, rows, const [], tall: tall, more: false);
  }

  /// Both faces of a starting layout, full ([full]): see [filled].
  static DeckLayout _complete(
    DeckLayout l,
    List<DeckAction> offered, {
    required bool full,
  }) {
    if (!full) return l;
    DeckFace face(DeckFace f) => f.withPages([
      for (final p in f.pages)
        filled(p, f.columns, f.rows, offered, tall: f.rows >= f.columns),
    ]);
    return l.copyWith(portrait: face(l.portrait), landscape: face(l.landscape));
  }

  /// [tiles] on a [columns] × [rows] grid with no cell left empty, as far as
  /// it goes: free cells take what the computer offers that isn't there yet,
  /// then the phone's own tiles; lines left empty at the end (rows when
  /// [tall], else columns) make the big tiles bigger; a cell still empty
  /// goes to the tile beside or above it.
  static List<DeckTile> filled(
    List<DeckTile> tiles,
    int columns,
    int rows,
    List<DeckAction> offered, {
    required bool tall,
    bool more = true,
  }) {
    var next = [...tiles];
    var made = 0;
    final there = {for (final t in next) t.action ?? t.props['do']};
    final pool = <DeckTile Function(int, int)>[
      if (more) ...[
        for (final a in offered)
          if (a.kind != DeckKind.slider && !there.contains(a.id))
            (x, y) => DeckTile(
              id: 'f${made++}${a.id}',
              kind: 'button',
              x: x,
              y: y,
              w: 1,
              h: 1,
              action: a.id,
            ),
        for (final d in ['clipboard', 'ping', 'find'])
          if (!there.contains(d))
            (x, y) => DeckTile(
              id: 'f${made++}$d',
              kind: 'phone',
              x: x,
              y: y,
              w: 1,
              h: 1,
              props: {'do': d},
            ),
      ],
    ];
    bool taken(int x, int y) =>
        next.any((t) => x >= t.x && x < t.x + t.w && y >= t.y && y < t.y + t.h);
    List<(int, int)> holes() => [
      for (var y = 0; y < rows; y++)
        for (var x = 0; x < columns; x++)
          if (!taken(x, y)) (x, y),
    ];
    // An empty line at the end: the last row (or column) nothing is in.
    bool lastEmpty() => tall
        ? !next.any((t) => t.y + t.h >= rows)
        : !next.any((t) => t.x + t.w >= columns);
    void fillHoles() {
      for (final (x, y) in holes()) {
        if (pool.isEmpty || next.length >= maxTiles) return;
        next.add(pool.removeAt(0)(x, y));
      }
    }

    // Grows [t] by a line after it: what's after moves along, and a tile
    // across that line grows with it.
    void grow(DeckTile t) {
      final at = tall ? t.y + t.h : t.x + t.w;
      next = [
        for (final o in next)
          if (o.id == t.id)
            tall ? o.copyWith(h: o.h + 1) : o.copyWith(w: o.w + 1)
          else if ((tall ? o.y : o.x) >= at)
            tall ? o.copyWith(y: o.y + 1) : o.copyWith(x: o.x + 1)
          else if ((tall ? o.y + o.h : o.x + o.w) > at)
            tall ? o.copyWith(h: o.h + 1) : o.copyWith(w: o.w + 1)
          else
            o,
      ];
    }

    fillHoles();
    // Big tiles first, then the ones that span the grid (no gap beside them).
    const order = ['touchpad', 'music', 'volume', 'clock'];
    var guard = 0;
    while (lastEmpty() && next.isNotEmpty && guard++ < 24) {
      final across = next.where((t) => tall ? t.w == columns : t.h == rows);
      // In turn, so no one tile grows huge.
      DeckTile? pick;
      for (var k = 0; k < order.length && pick == null; k++) {
        final kind = order[(guard + k) % order.length];
        pick = next
            .where((t) => t.kind == kind)
            .where(
              (t) => allows(t.kind, tall ? t.w : t.w + 1, tall ? t.h + 1 : t.h),
            )
            .firstOrNull;
      }
      pick ??= across.firstOrNull ?? next.last;
      grow(pick);
      fillHoles();
    }
    // Cells nothing reached: a tile beside them grows over them, where its
    // whole edge is free (right, down, left, up), until none is left.
    bool free(int x0, int y0, int w, int h) {
      if (x0 < 0 || y0 < 0 || x0 + w > columns || y0 + h > rows) return false;
      for (var y = y0; y < y0 + h; y++) {
        for (var x = x0; x < x0 + w; x++) {
          if (taken(x, y)) return false;
        }
      }
      return true;
    }

    for (var changed = true; changed && holes().isNotEmpty;) {
      changed = false;
      for (var i = 0; i < next.length; i++) {
        final t = next[i];
        final DeckTile? grown = free(t.x + t.w, t.y, 1, t.h)
            ? t.copyWith(w: t.w + 1)
            : free(t.x, t.y + t.h, t.w, 1)
            ? t.copyWith(h: t.h + 1)
            : free(t.x - 1, t.y, 1, t.h)
            ? t.copyWith(x: t.x - 1, w: t.w + 1)
            : free(t.x, t.y - 1, t.w, 1)
            ? t.copyWith(y: t.y - 1, h: t.h + 1)
            : null;
        if (grown != null && allows(grown.kind, grown.w, grown.h)) {
          next[i] = grown;
          changed = true;
        }
      }
    }
    return next;
  }

  static DeckLayout _make(
    String id,
    String name,
    DeckStart start,
    List<DeckAction> offered, {
    bool full = false,
    (int, int) portrait = portraitGrid,
    (int, int) landscape = landscapeGrid,
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
    final (pc, pr) = portrait;
    final (lc, lr) = landscape;
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
