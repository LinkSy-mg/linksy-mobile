import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/deck_copy.dart';
import 'package:linksy/core/deck_layouts.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/deck/deck_looks.dart';
import 'package:linksy/features/deck/deck_materials.dart';
import 'package:linksy/features/deck/laid_deck.dart';
import 'package:linksy/ui/l10n.dart';
import 'package:linksy/ui/sig.dart';

class _Controller extends LinksyController {
  _Controller()
    : super(DemoNode(name: 'P', downloadDir: '/d'), ActivityStore(null));

  var left = 0;

  @override
  Future<String?> startRemote(String id) async => null;

  @override
  void leaveRemote(String id) => left++;
}

void main() {
  test('numbers are written in segments, words are not', () {
    expect(hasSegments('10:44'), isTrue);
    expect(hasSegments('1.4'), isTrue);
    expect(hasSegments('2d'), isFalse);
    expect(hasSegments(''), isFalse);
  });

  test('a first accent is the look\'s own colour; a picked one is kept', () {
    expect(
      DeckLook.of('fluoro', DeckTheme.dots.accent).fill,
      const Color(0xFF7FF5E0),
    );
    expect(
      DeckLook.of('pads', const Color(0xFF00E436)).fill,
      const Color(0xFF00E436),
    );
  });

  test('what is on can always be read', () {
    for (final accent in [
      DeckTheme.dots.accent,
      const Color(0xFFFFD23F),
      const Color(0xFF1B1464),
      const Color(0xFFFFFFFF),
    ]) {
      for (final id in ['fluoro', 'pads', 'crystal']) {
        final look = DeckLook.of(id, accent);
        final on = look.material == DeckMaterial.tube
            ? look.background
            : look.on;
        final a = on.computeLuminance(), b = look.onInk.computeLuminance();
        final contrast = a > b
            ? (a + 0.05) / (b + 0.05)
            : (b + 0.05) / (a + 0.05);
        expect(contrast, greaterThan(4), reason: '$id in $accent');
      }
    }
  });

  test('a computer gets them as a look it has', () {
    final deck = DeckLayouts(
      version: 0,
      active: 'a',
      layouts: const [
        DeckLayout(
          id: 'a',
          name: 'A',
          theme: DeckTheme(id: 'fluoro', accent: Color(0xFF3B8BEB)),
          portrait: DeckFace(columns: 4, rows: 8, pages: [[]]),
          landscape: DeckFace(columns: 9, rows: 4, pages: [[]]),
        ),
      ],
    );
    expect(deckForComputer(deck).layouts.single.theme.id, 'stock');
  });

  testWidgets('leaving the deck from its touchpad ends the remote', (
    tester,
  ) async {
    final c = _Controller();
    await tester.runAsync(
      () => c.start().timeout(const Duration(seconds: 5), onTimeout: () {}),
    );
    final pc = c.devices
        .firstWhere((v) => v.device.name == 'Studio Desktop')
        .device;
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LaidDeck(
            device: pc,
            live: true,
            layouts: const DeckLayouts(
              version: 0,
              active: 'a',
              layouts: [
                DeckLayout(
                  id: 'a',
                  name: 'A',
                  theme: DeckTheme(id: 'pads', accent: Color(0xFF3B8BEB)),
                  portrait: DeckFace(
                    columns: 4,
                    rows: 8,
                    pages: [
                      [
                        DeckTile(
                          id: 't',
                          kind: 'touchpad',
                          x: 0,
                          y: 0,
                          w: 4,
                          h: 4,
                        ),
                      ],
                    ],
                  ),
                  landscape: DeckFace(columns: 9, rows: 4, pages: [[]]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(c.left, 1);
    await tester.pump(const Duration(seconds: 10));
  });
}
