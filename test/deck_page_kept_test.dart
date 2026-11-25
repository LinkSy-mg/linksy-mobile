import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/deck_draft.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/features/deck/laid_deck.dart';
import 'package:linksy/ui/l10n.dart';
import 'package:linksy/ui/sig.dart';

void main() {
  testWidgets('the deck stays on its page, as its dots say, after the editor', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(500, 1200);
    addTearDown(tester.view.reset);
    final c = LinksyController(
      DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
      ActivityStore(null),
    );
    final draft = DeckDraft(
      DeckDraft.starter('Deck', const [
        DeckAction(id: 'media.next', name: 'Next', kind: DeckKind.button),
      ]),
    );
    for (final sideways in [false, true]) {
      draft.landscape = sideways;
      draft.addPage();
      draft.add('clock');
      draft.addPage();
      draft.add('clock');
    }
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LaidDeck(
            device: const DeviceInfo(
              id: 'pc',
              name: 'PC',
              kind: DeviceKind.desktop,
              os: 'linux',
            ),
            layouts: draft.layouts,
            live: false,
          ),
        ),
      ),
    );
    await tester.pump();
    PageView view() => tester.widget<PageView>(find.byType(PageView));
    expect(draft.layouts.shown!.portrait.pages, hasLength(3));
    view().controller!.jumpToPage(2);
    await tester.pump();
    // The editor comes over it, and goes.
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    nav.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(view().controller!.page, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    c.dispose();
  });
}
