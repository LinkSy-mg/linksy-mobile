import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/app.dart';
import 'package:linksy/app/launch_intro.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/onboarding/language_wheel.dart';
import 'package:linksy/features/settings/settings_kit.dart';
import 'package:linksy/ui/components.dart';
import 'package:linksy/ui/sig.dart';

Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key, platform: 'android');
  await tester.pump(const Duration(milliseconds: 150));
}

/// The focused widget holds [finder]'s widget.
bool focusedHas(WidgetTester tester, Finder finder) {
  final focused = FocusManager.instance.primaryFocus;
  // A page's own scope holds everything on it: not a control.
  if (focused == null || focused is FocusScopeNode) return false;
  if (focused.context == null) return false;
  return find
      .descendant(
        of: find.byElementPredicate((e) => e == focused.context),
        matching: finder,
      )
      .evaluate()
      .isNotEmpty;
}

/// Down (then right, on wide screens) until [finder] has the focus.
Future<void> moveTo(WidgetTester tester, Finder finder) async {
  for (final key in [
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowDown,
  ]) {
    for (var i = 0; i < 25 && !focusedHas(tester, finder); i++) {
      await press(tester, key);
    }
  }
  expect(focusedHas(tester, finder), isTrue, reason: 'never reached $finder');
}

Widget host(Widget child) => MaterialApp(
  shortcuts: RemoteKeys.shortcuts,
  actions: RemoteKeys.actions,
  theme: buildTheme(Brightness.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('Pressable with a remote or a pad', () {
    testWidgets('the D-pad reaches it, the centre button taps on release', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          Pressable(
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Pressable');

      await tester.sendKeyDownEvent(
        LogicalKeyboardKey.select,
        platform: 'android',
      );
      await tester.pump();
      expect(taps, 0, reason: 'taps when let go, like Android TV');
      await tester.sendKeyUpEvent(
        LogicalKeyboardKey.select,
        platform: 'android',
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(taps, 1);

      await press(tester, LogicalKeyboardKey.gameButtonA);
      await press(tester, LogicalKeyboardKey.enter);
      expect(taps, 3);
    });

    testWidgets('held, or menu, X or Y: a long press, not a tap', (
      tester,
    ) async {
      var taps = 0, holds = 0;
      await tester.pumpWidget(
        host(
          Pressable(
            onTap: () => taps++,
            onLongPress: () => holds++,
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      await tester.sendKeyDownEvent(
        LogicalKeyboardKey.gameButtonA,
        platform: 'android',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.sendKeyUpEvent(
        LogicalKeyboardKey.gameButtonA,
        platform: 'android',
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect((taps, holds), (0, 1));

      await press(tester, LogicalKeyboardKey.gameButtonX);
      await press(tester, LogicalKeyboardKey.contextMenu);
      expect((taps, holds), (0, 3));
    });

    testWidgets('a disabled one is skipped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Pressable(child: SizedBox(width: 100, height: 50)),
              Pressable(
                onTap: () => taps++,
                child: const SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.select);
      expect(taps, 1);
    });

    testWidgets('the ring shows for keys, not for a finger', (tester) async {
      Finder ring() => find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.foregroundPainter.runtimeType.toString() == '_FocusRing',
      );
      await tester.pumpWidget(
        host(
          Pressable(
            onTap: () {},
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      expect(ring(), findsNothing);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(ring(), findsOneWidget);
      await tester.tap(find.byType(Pressable));
      await tester.pump(const Duration(milliseconds: 150));
      expect(ring(), findsNothing);
    });
  });

  testWidgets('a switch row is one stop, and picking it flips the switch', (
    tester,
  ) async {
    var on = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) => SettingRow(
            icon: Ph.gearSix,
            title: 'Something',
            trailing: Switch(value: on, onChanged: (v) => set(() => on = v)),
          ),
        ),
      ),
    );
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Pressable');
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'Pressable',
      reason: 'the switch is no stop of its own',
    );
    await press(tester, LogicalKeyboardKey.select);
    expect(on, isTrue);
  });

  testWidgets('the language wheel turns with up and down', (tester) async {
    var chosen = 'en';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) => LanguageWheel(
            selected: 'en',
            onChanged: (c) => set(() => chosen = c),
          ),
        ),
      ),
    );
    await press(tester, LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    final first = chosen;
    await press(tester, LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(chosen, isNot(first));
    await press(tester, LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(chosen, first);
  });

  group('the app on a TV', () {
    Future<LinksyController> pumpApp(
      WidgetTester tester, {
      bool setUp = true,
    }) async {
      final node = DemoNode(name: 'Shield', downloadDir: '/downloads');
      final c = LinksyController(node, ActivityStore(null));
      c.prefs = {if (setUp) 'onboarded': '1'};
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      // A 1080p TV at the Shield's density: 960 × 540.
      tester.view
        ..physicalSize = const Size(1920, 1080)
        ..devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await c.start();
      addTearDown(c.dispose);
      LaunchIntro.enabled = false;
      await tester.pumpWidget(LinksyApp(controller: c));
      await tester.pumpAndSettle();
      return c;
    }

    testWidgets('first run: down to a language, the centre button takes it', (
      tester,
    ) async {
      final c = await pumpApp(tester, setUp: false);
      expect(find.byType(LanguageWheel), findsOneWidget);
      final before = c.locale.value.languageCode;
      await press(tester, LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await press(tester, LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(c.locale.value.languageCode, isNot(before));
      expect(
        find.byType(LanguageWheel),
        findsNothing,
        reason: 'on to the next step, no Continue needed',
      );
    });

    testWidgets('D-pad to a computer, open it, B back', (tester) async {
      await pumpApp(tester);
      await moveTo(tester, find.text('Studio Desktop'));
      await press(tester, LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.text('Your devices'), findsNothing);

      await press(tester, LogicalKeyboardKey.gameButtonB);
      await tester.pumpAndSettle();
      expect(find.text('Your devices'), findsOneWidget);
    });

    testWidgets('a device row: right to its button, down on to the next', (
      tester,
    ) async {
      await pumpApp(tester);
      await moveTo(tester, find.text('Pixel of Sam'));
      final card = FocusManager.instance.primaryFocus;
      await press(tester, LogicalKeyboardKey.arrowRight);
      final button = FocusManager.instance.primaryFocus;
      expect(button, isNot(card));
      expect(card!.traversalDescendants, contains(button));
      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(FocusManager.instance.primaryFocus, card);
      await press(tester, LogicalKeyboardKey.arrowRight);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focusedHas(tester, find.text('Studio Desktop')), isTrue);
    });

    testWidgets('settings opens with A', (tester) async {
      await pumpApp(tester);
      for (var i = 0; i < 12; i++) {
        await press(tester, LogicalKeyboardKey.arrowUp);
      }
      expect(focusedHas(tester, find.byIcon(Ph.gearSix)), isTrue);
      await press(tester, LogicalKeyboardKey.gameButtonA);
      await tester.pumpAndSettle();
      expect(find.text('Your devices'), findsNothing);
      await press(tester, LogicalKeyboardKey.gameButtonB);
      await tester.pumpAndSettle();
      expect(find.text('Your devices'), findsOneWidget);
    });
  });
}
