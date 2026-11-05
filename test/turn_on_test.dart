import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/app.dart';
import 'package:linksy/app/launch_intro.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/core_json.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/models.dart';

class _Node extends DemoNode {
  _Node() : super(name: 'Test Phone', downloadDir: '/downloads');

  final told = <List<String>>[];

  @override
  Future<void> setFeatures(List<String> features) async => told.add(features);
}

void main() {
  /// What the phone asked Android for, and what Android says.
  final calls = <MethodCall>[];
  var access = false;
  var photos = false;

  /// What Android keeps of a tapped notification until the app takes it.
  Map<String, String>? tapped;

  Future<(LinksyController, _Node)> pumpApp(WidgetTester tester) async {
    calls.clear();
    access = photos = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          'prefs' => {'onboarded': '1'},
          'notificationAccess' => access,
          'shareGallery' => photos,
          'takeTurnOn' => () {
            final ask = tapped;
            tapped = null;
            return ask;
          }(),
          _ => null,
        };
      },
    );
    final node = _Node();
    final c = LinksyController(node, ActivityStore(null));
    c.prefs = {'onboarded': '1'};
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await c.start();
    LaunchIntro.enabled = false;
    await tester.pumpWidget(LinksyApp(controller: c));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    return (c, node);
  }

  /// With the app up, and its timers stopped at the end.
  void testApp(
    String name,
    Future<void> Function(WidgetTester, LinksyController, _Node) body,
  ) => testWidgets(name, (tester) async {
    final (c, node) = await pumpApp(tester);
    await body(tester, c, node);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  });

  /// The computer's ask comes 4 seconds after [DemoNode.simulateTurnOn].
  Future<void> asks(WidgetTester tester, _Node node, String feature) async {
    node.simulateTurnOn(feature);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  /// A tap on the ask's notification while the app runs.
  Future<void> taps(WidgetTester tester, String feature) async {
    tapped = {'name': 'Studio Desktop', 'feature': feature};
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'app.linksy/platform',
      const StandardMethodCodec().encodeMethodCall(const MethodCall('turnOn')),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  const photosAsk = "Studio Desktop asks to show this phone's photos";

  test('the Inbox default moves once, keeping a switch turned off', () {
    // Access given and no pref: it was turned off before 0.3.4.
    expect(inboxDefaultPrefs({}, access: true), {
      'inbox_default': 'done',
      'phone_notifications': 'off',
    });
    // It was on, or nobody asked for it: on from now.
    expect(inboxDefaultPrefs({'phone_notifications': 'on'}, access: true), {
      'inbox_default': 'done',
    });
    expect(inboxDefaultPrefs({}, access: false), {'inbox_default': 'done'});
    // Only once: access given later is the new default at work.
    expect(inboxDefaultPrefs({'inbox_default': 'done'}, access: true), isEmpty);
  });

  test('reads a computer asking', () {
    final e = eventFromJson(
      jsonDecode(
        jsonEncode({
          'type': 'turn_on_request',
          'from': {
            'id': 'ebb09ce2${'a' * 56}',
            'name': 'Studio Desktop',
            'kind': 'desktop',
            'os': 'linux',
          },
          'feature': 'gallery',
        }),
      ) as Json,
    )!;
    expect((e as TurnOnRequested).feature, 'gallery');
    expect(e.from.name, 'Studio Desktop');
  });

  testApp('a computer asks: a sheet, at most once a minute', (
    tester,
    _,
    node,
  ) async {
    await asks(tester, node, 'gallery');
    expect(
      find.text("Studio Desktop asks to show this phone's photos"),
      findsOneWidget,
    );
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    await asks(tester, node, 'gallery');
    expect(
      find.text("Studio Desktop asks to show this phone's photos"),
      findsNothing,
    );
    // Each feature on its own.
    await asks(tester, node, 'notifications');
    expect(
      find.text("Studio Desktop asks to show this phone's messages"),
      findsOneWidget,
    );
  });

  testApp('out of sight, the ask is a notification with the same words', (
    tester,
    _,
    node,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await asks(tester, node, 'notifications');
    final notice = calls.singleWhere((c) => c.method == 'noticeTurnOn');
    final args = (notice.arguments as Map).cast<String, Object?>();
    expect(args['title'], "Studio Desktop asks to show this phone's messages");
    expect(args['feature'], 'notifications');
    expect(args['name'], 'Studio Desktop');
    expect(find.text('Turn On'), findsNothing);
  });

  testApp('allowed since the app last looked: no notification', (
    tester,
    _,
    node,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    access = true;
    await asks(tester, node, 'notifications');
    expect(calls.where((c) => c.method == 'noticeTurnOn'), isEmpty);
  });

  testApp('a tap on the notification opens the sheet', (tester, _, _) async {
    await taps(tester, 'gallery');
    expect(find.text(photosAsk), findsOneWidget);
  });

  testApp('allowed before the tap: nothing to ask', (tester, _, _) async {
    access = true;
    await taps(tester, 'notifications');
    expect(find.text('Turn On'), findsNothing);
  });

  testWidgets('a tap that started the app opens the sheet too', (tester) async {
    tapped = {'name': 'Studio Desktop', 'feature': 'gallery'};
    final (c, _) = await pumpApp(tester);
    expect(find.text(photosAsk), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  });

  testApp('what it asks for is on already: only the features again', (
    tester,
    c,
    node,
  ) async {
    access = photos = true;
    await c.refreshNotificationAccess();
    await c.setGallery(true);
    node.told.clear();
    await asks(tester, node, 'gallery');
    expect(find.text('Turn On'), findsNothing);
    // Backwards first: the core only tells a list that changed.
    final backwards = node.told[node.told.length - 2];
    expect(backwards, isNot(node.told.last));
    expect(backwards.reversed, node.told.last);
    expect(node.told.last, contains('gallery'));
  });

  testApp('a feature it does not know is ignored', (tester, _, node) async {
    node.told.clear();
    await asks(tester, node, 'telepathy');
    expect(find.text('Turn On'), findsNothing);
    expect(node.told, isEmpty);
    expect(calls.where((c) => c.method == 'noticeTurnOn'), isEmpty);
  });

  testApp('the home card, until dismissed or both are on', (
    tester,
    c,
    _,
  ) async {
    expect(c.turnOnCard, isTrue);
    await tester.pump();
    expect(find.text('Your messages and photos on your computers'), findsOne);
    expect(find.text('Turn On Messages'), findsOneWidget);
    expect(find.text('Turn On Photos'), findsOneWidget);

    // Only what's off keeps its button.
    photos = true;
    await c.setGallery(true);
    await tester.pump();
    expect(find.text('Turn On Photos'), findsNothing);
    expect(find.text('Turn On Messages'), findsOneWidget);

    await c.dismissTurnOnCard();
    await tester.pumpAndSettle();
    expect(
      find.text('Your messages and photos on your computers'),
      findsNothing,
    );
    // For good, even with the photos off again.
    await c.setGallery(false);
    expect(c.turnOnCard, isFalse);
  });

  testApp('both on: the card is gone for good', (tester, c, _) async {
    access = photos = true;
    await c.refreshNotificationAccess();
    await c.setGallery(true);
    expect(c.prefs['turn_on_card'], 'done');
    await c.setGallery(false);
    expect(c.turnOnCard, isFalse);
  });

  testApp('turning the switch off is remembered as off', (tester, c, _) async {
    expect(c.phoneNotifications, isTrue);
    await c.setPhoneNotifications(false);
    expect(c.prefs['phone_notifications'], 'off');
    expect(c.phoneNotifications, isFalse);
    await c.setPhoneNotifications(true);
    expect(c.phoneNotifications, isTrue);
  });
}
