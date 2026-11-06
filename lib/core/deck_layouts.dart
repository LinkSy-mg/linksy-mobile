/// The deck's layouts made on a computer (docs/protocol.md §4.20): the
/// computer keeps them, one set per phone, and sends them when the deck
/// opens; the phone draws the active one, a face per orientation, and runs
/// its tiles (§4.19). It keeps the last set it got, to show straight away
/// and while the computer is away.
library;

import 'dart:convert';
import 'dart:ui';

typedef _Json = Map<String, Object?>;

/// Every layout of this phone's deck on one computer.
class DeckLayouts {
  const DeckLayouts({
    required this.version,
    required this.active,
    required this.layouts,
  });

  /// One more on every save there.
  final int version;

  /// The id of the layout to show.
  final String active;
  final List<DeckLayout> layouts;

  DeckLayouts copyWith({
    int? version,
    String? active,
    List<DeckLayout>? layouts,
  }) => DeckLayouts(
    version: version ?? this.version,
    active: active ?? this.active,
    layouts: layouts ?? this.layouts,
  );

  Map<String, Object?> toJson() => {
    'version': version,
    'active': active,
    'layouts': [for (final l in layouts) l.toJson()],
  };

  /// The layout to show: the active one, else the first.
  DeckLayout? get shown =>
      layouts.where((l) => l.id == active).firstOrNull ?? layouts.firstOrNull;

  /// What the computer sent, as it sent it; null when it isn't layouts.
  static DeckLayouts? parse(Object? j) {
    if (j is! _Json) return null;
    try {
      return DeckLayouts(
        version: (j['version'] as num? ?? 0).toInt(),
        active: j['active'] as String? ?? '',
        layouts: [
          for (final l
              in (j['layouts'] as List? ?? const []).whereType<_Json>())
            DeckLayout._parse(l),
        ],
      );
    } on Object {
      return null;
    }
  }

  static DeckLayouts? decode(String? s) {
    if (s == null) return null;
    try {
      return parse(jsonDecode(s));
    } on FormatException {
      return null;
    }
  }
}

class DeckLayout {
  const DeckLayout({
    required this.id,
    required this.name,
    required this.theme,
    required this.portrait,
    required this.landscape,
  });

  final String id;
  final String name;
  final DeckTheme theme;
  final DeckFace portrait;
  final DeckFace landscape;

  DeckLayout copyWith({
    String? name,
    DeckTheme? theme,
    DeckFace? portrait,
    DeckFace? landscape,
  }) => DeckLayout(
    id: id,
    name: name ?? this.name,
    theme: theme ?? this.theme,
    portrait: portrait ?? this.portrait,
    landscape: landscape ?? this.landscape,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'theme': theme.toJson(),
    'portrait': portrait.toJson(),
    'landscape': landscape.toJson(),
  };

  static DeckLayout _parse(_Json j) => DeckLayout(
    id: j['id'] as String? ?? '',
    name: j['name'] as String? ?? '',
    theme: DeckTheme._parse(j['theme']),
    portrait: DeckFace._parse(j['portrait'], 4, 8),
    landscape: DeckFace._parse(j['landscape'], 9, 4),
  );
}

/// The look the computer picked: `stock`, `dots`, `eink`, `term` or `pixel`
/// (one the phone doesn't know draws as `stock`), and its [accent] for
/// whatever is on.
class DeckTheme {
  const DeckTheme({required this.id, required this.accent});

  final String id;
  final Color accent;

  static const stock = DeckTheme(id: 'stock', accent: Color(0xFF3584E4));

  /// What a deck made on the phone starts with.
  static const dots = DeckTheme(id: 'dots', accent: Color(0xFF3B8BEB));

  Map<String, Object?> toJson() => {'id': id, 'accent': deckHex(accent)};

  static DeckTheme _parse(Object? j) {
    if (j is! _Json) return stock;
    return DeckTheme(
      id: j['id'] as String? ?? stock.id,
      accent: deckColor(j['accent'] as String?) ?? stock.accent,
    );
  }
}

/// One orientation: a grid of [columns] × [rows] square cells, and pages of
/// tiles on it.
class DeckFace {
  const DeckFace({
    required this.columns,
    required this.rows,
    required this.pages,
  });

  final int columns;
  final int rows;
  final List<List<DeckTile>> pages;

  bool get isEmpty => pages.every((p) => p.isEmpty);

  DeckFace withPages(List<List<DeckTile>> pages) =>
      DeckFace(columns: columns, rows: rows, pages: pages);

  Map<String, Object?> toJson() => {
    'grid': [columns, rows],
    'pages': [
      for (final p in pages) [for (final t in p) t.toJson()],
    ],
  };

  static DeckFace _parse(Object? j, int columns, int rows) {
    if (j is! _Json) return DeckFace(columns: columns, rows: rows, pages: [[]]);
    final grid = (j['grid'] as List?)?.whereType<num>().toList();
    if (grid != null && grid.length == 2) {
      columns = grid[0].toInt().clamp(1, 12);
      rows = grid[1].toInt().clamp(1, 12);
    }
    final pages = [
      for (final p in (j['pages'] as List? ?? const []).whereType<List>())
        [
          for (final t in p.whereType<_Json>())
            DeckTile._parse(t, columns, rows),
        ],
    ];
    return DeckFace(
      columns: columns,
      rows: rows,
      pages: pages.isEmpty ? [[]] : pages,
    );
  }
}

/// A tile on the grid: [kind] (`button`, `volume`, `music`, `clock`, or one
/// this phone doesn't know yet), at [x], [y], [w] × [h] cells.
class DeckTile {
  const DeckTile({
    required this.id,
    required this.kind,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.label = '',
    this.color,
    this.action,
    this.props = const {},
  });

  final String id;
  final String kind;
  final int x;
  final int y;
  final int w;
  final int h;

  /// Empty: the action's name.
  final String label;

  /// For the themes that colour tiles.
  final Color? color;

  /// The deck action it runs (§4.19), for the kinds that run one.
  final String? action;
  final Map<String, String> props;

  /// [noColor]: back to the look's own colour.
  DeckTile copyWith({
    String? id,
    int? x,
    int? y,
    int? w,
    int? h,
    String? label,
    Color? color,
    bool noColor = false,
    String? action,
    Map<String, String>? props,
  }) => DeckTile(
    id: id ?? this.id,
    kind: kind,
    x: x ?? this.x,
    y: y ?? this.y,
    w: w ?? this.w,
    h: h ?? this.h,
    label: label ?? this.label,
    color: noColor ? null : color ?? this.color,
    action: action ?? this.action,
    props: props ?? this.props,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    if (label.isNotEmpty) 'label': label,
    if (color case final c?) 'color': deckHex(c),
    'action': ?action,
    if (props.isNotEmpty) 'props': props,
  };

  /// Kept inside the grid, whatever came.
  static DeckTile _parse(_Json j, int columns, int rows) {
    int n(String k) => (j[k] as num? ?? 0).toInt();
    final x = n('x').clamp(0, columns - 1), y = n('y').clamp(0, rows - 1);
    final w = n('w').clamp(1, columns - x), h = n('h').clamp(1, rows - y);
    return DeckTile(
      id: j['id'] as String? ?? '',
      kind: j['kind'] as String? ?? '',
      x: x,
      y: y,
      w: w,
      h: h,
      label: j['label'] as String? ?? '',
      color: deckColor(j['color'] as String?),
      action: j['action'] as String?,
      props: {
        for (final MapEntry(:key, :value)
            in (j['props'] as _Json? ?? const {}).entries)
          if (value is String) key: value,
      },
    );
  }
}

/// A colour as `#rrggbb`.
String deckHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// `#rrggbb` as a colour; null for anything else.
Color? deckColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  final v = int.tryParse(hex.substring(1), radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}
