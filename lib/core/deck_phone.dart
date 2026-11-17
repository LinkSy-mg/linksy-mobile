/// The deck's own tiles: ones the phone runs itself, through what it already
/// does with the computer, so they need nothing new from it. A tile of kind
/// `phone` says which in its `do` prop:
///
/// - `shortcut`: keys pressed together, `keys` as written ("ctrl+shift+t"),
///   sent as Remote Input key presses (§4.8; the computer allows Remote
///   Input once).
/// - `text`: `text` typed on the computer, the same way.
/// - `link`: `url` opened on the computer (§4.3, open_url).
/// - `clipboard`, `ping`, `find`: as on the computer's page.
/// - `click`: the mouse's `button` (left, right), and `keyboard`: the
///   phone's keyboard typing on the computer, both through Remote Input, as
///   on the deck's Remote page with its `touchpad` tile.
library;

/// What a phone tile does.
enum DeckPhoneDo {
  shortcut,
  text,
  link,
  clipboard,
  ping,
  find,
  click,
  keyboard,
}

DeckPhoneDo? deckPhoneDo(String? name) =>
    DeckPhoneDo.values.where((d) => d.name == name).firstOrNull;

/// The deck icon for each.
String deckPhoneIcon(DeckPhoneDo d) => switch (d) {
  DeckPhoneDo.shortcut => 'keys',
  DeckPhoneDo.text => 'type',
  DeckPhoneDo.link => 'link',
  DeckPhoneDo.clipboard => 'clipboard',
  DeckPhoneDo.ping => 'bell',
  DeckPhoneDo.find => 'find',
  DeckPhoneDo.click => 'click',
  DeckPhoneDo.keyboard => 'keys',
};

/// Modifiers, as written and as X11 keysyms (left ones).
const deckModifiers = <String, int>{
  'ctrl': 0xffe3,
  'alt': 0xffe9,
  'shift': 0xffe1,
  'super': 0xffeb,
};

/// Keys with a name, as written in a shortcut.
const _named = <String, int>{
  'enter': 0xff0d,
  'return': 0xff0d,
  'esc': 0xff1b,
  'escape': 0xff1b,
  'tab': 0xff09,
  'space': 0x20,
  'backspace': 0xff08,
  'delete': 0xffff,
  'del': 0xffff,
  'insert': 0xff63,
  'home': 0xff50,
  'end': 0xff57,
  'pageup': 0xff55,
  'pgup': 0xff55,
  'pagedown': 0xff56,
  'pgdn': 0xff56,
  'left': 0xff51,
  'up': 0xff52,
  'right': 0xff53,
  'down': 0xff54,
  'print': 0xff61,
  'prtsc': 0xff61,
  'plus': 0x2b,
  'minus': 0x2d,
};

/// The key a shortcut ends with, written ("t", "F5", "Tab", "Left"), as a
/// keysym; null for one this doesn't know.
int? deckKeysym(String key) {
  final k = key.trim().toLowerCase();
  if (k.isEmpty) return null;
  if (_named[k] case final sym?) return sym;
  final f = RegExp(r'^f([1-9]|1[0-2])$').firstMatch(k);
  if (f != null) return 0xffbe + int.parse(f.group(1)!) - 1;
  final runes = k.runes.toList();
  if (runes.length != 1) return null;
  final c = runes.single;
  return c < 0x100 ? c : 0x01000000 + c;
}

/// A shortcut as written ("ctrl+shift+t"): its modifiers and its key, or
/// null when it has no key or one this doesn't know.
({List<int> mods, int key})? deckShortcut(String? keys) {
  if (keys == null) return null;
  // "ctrl++" is Ctrl and plus.
  final parts = keys.replaceAll('++', '+plus').split('+');
  final mods = <int>[];
  int? key;
  for (final p in parts.map((p) => p.trim().toLowerCase())) {
    if (p.isEmpty) continue;
    if (deckModifiers[p] case final m?) {
      if (!mods.contains(m)) mods.add(m);
    } else {
      if (key != null) return null;
      key = deckKeysym(p);
      if (key == null) return null;
    }
  }
  return key == null ? null : (mods: mods, key: key);
}

/// A shortcut as people read it: "Ctrl+Shift+T".
String deckShortcutLabel(String keys) => keys
    .split('+')
    .where((p) => p.trim().isNotEmpty)
    .map((p) {
      final k = p.trim();
      return k.length == 1
          ? k.toUpperCase()
          : k[0].toUpperCase() + k.substring(1).toLowerCase();
    })
    .join('+');

/// Writes a shortcut from its parts, modifiers in the usual order.
String deckShortcutKeys(Set<String> mods, String key) => [
  for (final m in deckModifiers.keys)
    if (mods.contains(m)) m,
  if (key.trim().isNotEmpty) key.trim().toLowerCase(),
].join('+');
