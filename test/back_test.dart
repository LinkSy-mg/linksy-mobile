import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/app.dart';
import 'package:linksy/app/launch_intro.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';

void main() {
  final calls = <MethodCall>[];

  Iterable<MethodCall> left() => calls.where((c) => c.method == 'toBackground');

  void testApp(
    String name,
    Future<void> Function(WidgetTester, LinksyController) body,
  ) => testWidgets(name, (tester) async {
    calls.clear();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('app.linksy/platform'),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          'prefs' => {'onboarded': '1'},
          _ => null,
        };
      },
    );
    final c = LinksyController(
      DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
      ActivityStore(null),
    );
    c.prefs = {'onboarded': '1', 'turn_on_card': 'done'};
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
    await body(tester, c);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    await tester.pump(const Duration(seconds: 6));
  });

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testApp('Back on the home screen leaves Linksy running', (tester, _) async {
    await back(tester);
    expect(left(), hasLength(1));
  });

  testApp('Back from a page goes to the page before', (tester, _) async {
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    await back(tester);
    expect(left(), isEmpty);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    await back(tester);
    expect(left(), hasLength(1));
  });

  testApp('Back closes the open card first', (tester, _) async {
    await tester.tap(find.text('Send files').last);
    await tester.pumpAndSettle();
    await back(tester);
    expect(left(), isEmpty);
    await back(tester);
    expect(left(), hasLength(1));
  });
}
