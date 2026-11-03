/// The deck (docs/protocol.md §4.19): this phone as buttons for a computer.
/// A computer that makes the layouts sends them (deck_layouts.dart); for one
/// that doesn't, the phone lays its deck out itself, one per computer, saved
/// here: pages of tiles, each an action the computer offers, with its size,
/// colour and icon.
library;

import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'models.dart';

/// How much of the deck's four columns a tile takes, and how many rows.
enum DeckSize {
  small(1, 1),
  wide(2, 1),
  tall(1, 2),
  big(2, 2),
  row(4, 1);

  const DeckSize(this.columns, this.rows);
  final int columns;
  final int rows;

  static DeckSize parse(String? s) =>
      values.firstWhere((v) => v.name == s, orElse: () => small);
}

/// One tile: [action] (the computer's id), and the [name] and [kind] it had
/// when last offered, so a tile whose action left the list still says what
/// it was.
class PhoneDeckTile {
  PhoneDeckTile({
    required this.action,
    required this.name,
    required this.kind,
    this.size = DeckSize.small,
    this.color = 0,
    this.icon,
  });

  final String action;
  String name;
  DeckKind kind;
  DeckSize size;

  /// An index into [deckColors].
  int color;

  /// A name in [deckIcons]; none: the action's own.
  String? icon;

  Map<String, Object?> toJson() => {
    'action': action,
    'name': name,
    'kind': kind.name,
    'size': size.name,
    'color': color,
    if (icon != null) 'icon': icon,
  };

  static PhoneDeckTile fromJson(Map<String, Object?> j) => PhoneDeckTile(
    action: j['action'] as String,
    name: j['name'] as String? ?? '',
    kind: DeckKind.parse(j['kind'] as String?),
    size: DeckSize.parse(j['size'] as String?),
    color: (j['color'] as num? ?? 0).toInt(),
    icon: j['icon'] as String?,
  );
}

class PhoneDeckPage {
  PhoneDeckPage([List<PhoneDeckTile>? tiles]) : tiles = tiles ?? [];
  final List<PhoneDeckTile> tiles;
}

class PhoneDeck {
  PhoneDeck(this.pages);
  final List<PhoneDeckPage> pages;

  String encode() => jsonEncode({
    'pages': [
      for (final p in pages) [for (final t in p.tiles) t.toJson()],
    ],
  });

  static PhoneDeck? decode(String? s) {
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Map<String, Object?>;
      return PhoneDeck([
        for (final p in j['pages'] as List)
          PhoneDeckPage([
            for (final t in (p as List).cast<Map<String, Object?>>())
              PhoneDeckTile.fromJson(t),
          ]),
      ]);
    } on Object {
      return null;
    }
  }

  /// A first deck from what the computer offers: media up front, the volume
  /// along a row, then the rest of each group.
  static PhoneDeck first(List<DeckAction> actions) {
    PhoneDeckTile tile(
      DeckAction a, {
      DeckSize? size,
      int? color,
    }) => PhoneDeckTile(
      action: a.id,
      name: a.name,
      kind: a.kind,
      size: size ?? (a.kind == DeckKind.slider ? DeckSize.row : DeckSize.small),
      color: color ?? _groupColor(a.group),
    );
    final tiles = <PhoneDeckTile>[];
    final byId = {for (final a in actions) a.id: a};
    final play = byId['media.play_pause'];
    if (play != null) tiles.add(tile(play, size: DeckSize.big));
    for (final id in ['media.previous', 'media.next']) {
      if (byId[id] case final a?) tiles.add(tile(a, size: DeckSize.wide));
    }
    for (final a in actions) {
      if (tiles.any((t) => t.action == a.id)) continue;
      tiles.add(tile(a));
    }
    return PhoneDeck([PhoneDeckPage(tiles)]);
  }

  static int _groupColor(String group) => switch (group) {
    'Media' => 0,
    'Sound' => 1,
    'System' => 2,
    _ => 3,
  };
}

/// The colours a tile can take: blue, cyan, deep, the card's own, then a few
/// to tell commands apart.
const deckColors = [
  Color(0xFF2563FF),
  Color(0xFF22C3E6),
  Color(0xFF1438B8),
  Color(0x00000000),
  Color(0xFF7C5CFF),
  Color(0xFF2BB673),
  Color(0xFFF5A524),
  Color(0xFFFF5C72),
];

/// The icons a tile can show, by name (what's saved).
const deckIcons = <String, IconData>{
  'play_pause': IconData(0xe8be, fontFamily: 'PhosphorFill'),
  'play': IconData(0xe3d0, fontFamily: 'PhosphorFill'),
  'pause': IconData(0xe39e, fontFamily: 'PhosphorFill'),
  'previous': IconData(0xe5a4, fontFamily: 'PhosphorFill'),
  'next': IconData(0xe5a6, fontFamily: 'PhosphorFill'),
  'speaker': IconData(0xe44a, fontFamily: 'PhosphorFill'),
  'speaker_off': IconData(0xe45a, fontFamily: 'PhosphorFill'),
  'microphone': IconData(0xe326, fontFamily: 'PhosphorFill'),
  'microphone_off': IconData(0xe328, fontFamily: 'PhosphorFill'),
  'lock': IconData(0xe2fa, fontFamily: 'PhosphorFill'),
  'terminal': IconData(0xeae8, fontFamily: 'PhosphorFill'),
  'lightning': IconData(0xe2de, fontFamily: 'PhosphorFill'),
  'star': IconData(0xe46a, fontFamily: 'PhosphorFill'),
  'moon': IconData(0xe330, fontFamily: 'PhosphorFill'),
  'sun': IconData(0xe472, fontFamily: 'PhosphorFill'),
  'house': IconData(0xe2c2, fontFamily: 'PhosphorFill'),
  'bell': IconData(0xe0ce, fontFamily: 'PhosphorFill'),
  'code': IconData(0xe1bc, fontFamily: 'PhosphorFill'),
  'power': IconData(0xe3da, fontFamily: 'PhosphorFill'),
  'rocket': IconData(0xe3fe, fontFamily: 'PhosphorFill'),
  'game': IconData(0xe26e, fontFamily: 'PhosphorFill'),
  'camera': IconData(0xe10e, fontFamily: 'PhosphorFill'),
  'heart': IconData(0xe2a8, fontFamily: 'PhosphorFill'),
  'coffee': IconData(0xe1c2, fontFamily: 'PhosphorFill'),
  'music': IconData(0xe340, fontFamily: 'PhosphorFill'),
  'monitor': IconData(0xe32e, fontFamily: 'PhosphorFill'),
  'broadcast': IconData(0xe0f2, fontFamily: 'PhosphorFill'),
  'flag': IconData(0xe244, fontFamily: 'PhosphorFill'),
  'folder': IconData(0xe24a, fontFamily: 'PhosphorFill'),
  'globe': IconData(0xe288, fontFamily: 'PhosphorFill'),
  'cloud': IconData(0xe1aa, fontFamily: 'PhosphorFill'),
  'timer': IconData(0xe492, fontFamily: 'PhosphorFill'),
};

/// The icon a tile shows when none was chosen: the action's own, or by kind.
String deckIconFor(String action, DeckKind kind) => switch (action) {
  'media.play_pause' => 'play_pause',
  'media.previous' => 'previous',
  'media.next' => 'next',
  'sound.volume' => 'speaker',
  'sound.mute' => 'speaker_off',
  'sound.mic_mute' => 'microphone_off',
  'system.lock' => 'lock',
  _ when action.startsWith('command.') => 'terminal',
  _ => kind == DeckKind.slider ? 'speaker' : 'lightning',
};
