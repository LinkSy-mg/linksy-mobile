import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/features/deck/deck_art.dart';
import 'package:linksy/features/deck/deck_looks.dart';

void main() {
  test('glyphs cover Latin text, folded, and nothing else', () {
    expect(hasGlyphs('Wi-Fi 42%'), isTrue);
    expect(hasGlyphs('Écran · Arrêt'), isTrue);
    expect(hasGlyphs('音量'), isFalse);
  });

  test('glyph text wraps at spaces and cuts what does not fit', () {
    // Six glyphs a line at pitch 1: 6 × 6 − 1 = 35 wide.
    final (lines, pitch) = fitGlyphs('Lock Screen', 35, 2, [1]);
    expect(lines, ['Lock', 'Screen']);
    expect(pitch, 1.0);
    expect(fitGlyphs('Lock Screen', 35, 1, [1]).$1, ['Lock.']);
    expect(fitGlyphs('Bluetooth', 35, 2, [1]).$1, ['Bluet.']);
    // The biggest pitch that leaves nothing out.
    expect(fitGlyphs('Mute', 35, 1, [2, 1]).$2, 1.0);
    expect(fitGlyphs('Mute', 70, 1, [2, 1]).$2, 2.0);
  });

  test('icons for each action, as the editor has them', () {
    expect(deckIconName('media.play_pause'), 'play');
    expect(deckIconName('media.play_pause', playing: true), 'pause');
    expect(deckIconName('network.airplane'), 'airplane');
    expect(deckIconName('command.3f2a'), 'terminal');
    expect(deckIconName('lights.on'), 'app');
  });

  test('Pixel keeps to its palette, with dark ink on light colours', () {
    expect(pico(const Color(0xFFE01B24)), (const Color(0xFFFF004D), false));
    expect(pico(const Color(0xFFFFE000)).$2, isTrue);
  });

  testWidgets('every icon draws in every stroke', (tester) async {
    const names = [
      'music', 'play', 'pause', 'next', 'prev', 'volume', 'mute', 'mic', //
      'output', 'clock', 'lock', 'restart', 'power', 'moon', 'wifi',
      'bluetooth', 'airplane', 'leaf', 'balanced', 'gauge', 'auto',
      'terminal', 'app',
    ];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          children: [
            for (final stroke in DeckStroke.values)
              for (final n in names)
                DeckIcon(n, size: 24, color: Colors.white, stroke: stroke),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
