import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/deck_phone.dart';

void main() {
  test('a shortcut is its modifiers and one key', () {
    final s = deckShortcut('ctrl+shift+t')!;
    expect(s.mods, [0xffe3, 0xffe1]);
    expect(s.key, 0x74);
    expect(deckShortcut('Super+L')!.key, 0x6c);
    expect(deckShortcut('super'), isNull, reason: 'no key');
  });

  test('named keys, function keys and plus', () {
    expect(deckShortcut('f5')!.key, 0xffc2);
    expect(deckShortcut('F12')!.key, 0xffc9);
    expect(deckShortcut('alt+Left')!.key, 0xff51);
    expect(deckShortcut('ctrl+tab')!.key, 0xff09);
    expect(deckShortcut('ctrl++')!.key, 0x2b);
  });

  test('nothing to press, two keys or an unknown name: none', () {
    expect(deckShortcut(null), isNull);
    expect(deckShortcut(''), isNull);
    expect(deckShortcut('ctrl+shift'), isNull);
    expect(deckShortcut('a+b'), isNull);
    expect(deckShortcut('ctrl+banana'), isNull);
  });

  test('written and read back', () {
    expect(deckShortcutKeys({'shift', 'ctrl'}, 'T'), 'ctrl+shift+t');
    expect(deckShortcutLabel('ctrl+shift+t'), 'Ctrl+Shift+T');
    expect(deckShortcutLabel('super+f5'), 'Super+F5');
  });
}
