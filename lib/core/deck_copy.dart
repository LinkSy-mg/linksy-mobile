/// The phone's deck as a computer can keep it (docs/protocol.md §4.20, §4.26).
///
/// The phone lays out more than a computer takes: its own tiles (shortcuts,
/// the touchpad), free sizes, finer grids, its own themes. So the phone keeps
/// its deck, and the computer gets a copy with what it takes: enough to know
/// which gauges to send (§4.28), and all of a deck that is within its rules.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'deck_layouts.dart';

/// The sizes a computer takes each kind in, biggest first.
const _sizes = <String, List<(int, int)>>{
  'button': [(2, 1), (1, 1)],
  'volume': [(4, 1), (1, 3), (2, 1)],
  'music': [(4, 2), (2, 2)],
  'clock': [(2, 2), (2, 1), (1, 1)],
  'stat': [(2, 2), (2, 1), (1, 1)],
};

/// The gauges there are, by metric.
const deckMetrics = [
  'cpu',
  'ram',
  'swap',
  'disk',
  'battery',
  'temp',
  'net_down',
  'net_up',
  'uptime',
];

const _most = 12, _pages = 8, _tiles = 64, _label = 60;

/// [deck] as a computer takes it. [actions]: only tiles of these, when the
/// computer wouldn't take the rest. [themes]: the custom ones it has.
DeckLayouts deckForComputer(
  DeckLayouts deck, {
  Set<String>? actions,
  Set<String> themes = const {},
}) {
  final layouts = [
    for (final l in deck.layouts.take(20))
      if (l.id.isNotEmpty)
        DeckLayout(
          id: l.id,
          name: l.name.trim().isEmpty ? 'Deck' : _short(l.name.trim()),
          theme:
              DeckThemeDef.bases.contains(l.theme.id) ||
                  themes.contains(l.theme.id)
              ? l.theme
              : DeckTheme(id: 'stock', accent: l.theme.accent),
          portrait: _face(l.portrait, actions),
          landscape: _face(l.landscape, actions),
        ),
  ];
  return DeckLayouts(
    version: deck.version,
    active: layouts.any((l) => l.id == deck.active)
        ? deck.active
        : layouts.firstOrNull?.id ?? '',
    layouts: layouts,
  );
}

String _short(String s) =>
    s.runes.length <= _label ? s : String.fromCharCodes(s.runes.take(_label));

DeckFace _face(DeckFace face, Set<String>? actions) {
  final columns = math.min(face.columns, _most);
  final rows = math.min(face.rows, _most);
  final pages = [for (final _ in face.pages.take(_pages)) <DeckTile>[]];
  final later = <DeckTile>[];
  for (final (i, page) in face.pages.indexed) {
    for (final t in page) {
      final fit = _tile(t, actions);
      if (fit == null) continue;
      final inside =
          i < pages.length &&
          pages[i].length < _tiles &&
          fit.x + fit.w <= columns &&
          fit.y + fit.h <= rows &&
          !pages[i].any((o) => o.id == fit.id);
      inside ? pages[i].add(fit) : later.add(fit);
    }
  }
  // Past the computer's grid: in the first room there is, small.
  for (final t in later) {
    if (t.kind != 'stat' && t.kind != 'button') continue;
    final small = t.copyWith(w: 1, h: 1);
    var placed = false;
    for (var p = 0; p < _pages && !placed; p++) {
      if (p == pages.length) pages.add([]);
      final page = pages[p];
      if (page.length >= _tiles || page.any((o) => o.id == t.id)) continue;
      for (var at = 0; at < columns * rows && !placed; at++) {
        final x = at % columns, y = at ~/ columns;
        final taken = page.any(
          (o) => x >= o.x && x < o.x + o.w && y >= o.y && y < o.y + o.h,
        );
        if (taken) continue;
        page.add(small.copyWith(x: x, y: y));
        placed = true;
      }
    }
  }
  if (pages.isEmpty) pages.add([]);
  return DeckFace(columns: columns, rows: rows, pages: pages);
}

/// [t] no bigger than it is, at a size the computer takes; null when it
/// doesn't take it at all.
DeckTile? _tile(DeckTile t, Set<String>? actions) {
  final sizes = _sizes[t.kind];
  if (sizes == null || t.id.isEmpty) return null;
  if (t.kind == 'button' || t.kind == 'volume') {
    final a = t.action;
    if (a == null || actions != null && !actions.contains(a)) return null;
  }
  if (t.kind == 'stat' && !deckMetrics.contains(t.props['metric'])) return null;
  for (final (w, h) in sizes) {
    if (w <= t.w && h <= t.h) {
      return t.copyWith(w: w, h: h, label: _short(t.label));
    }
  }
  return null;
}

/// What [deck] lays out, to tell whether two are the same: not its version,
/// nor the themes it came with.
String deckContent(DeckLayouts deck) {
  Object? sorted(Object? v) => switch (v) {
    final Map<String, Object?> m => {
      for (final k in m.keys.toList()..sort()) k: sorted(m[k]),
    },
    final List<Object?> l => [for (final e in l) sorted(e)],
    _ => v,
  };
  final json = deck.toJson()
    ..remove('version')
    ..remove('themes');
  return jsonEncode(sorted(json));
}
