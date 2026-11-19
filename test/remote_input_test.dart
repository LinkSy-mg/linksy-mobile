import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/remote/remote_screen.dart';

void main() {
  group('what the phone keyboard did', () {
    test('a key, a swiped word, Backspace', () {
      expect(keyboardEdit('a', 'ab'), (back: 0, text: 'b'));
      expect(keyboardEdit('a', 'a hello'), (back: 0, text: ' hello'));
      expect(keyboardEdit('a hello', 'a hell'), (back: 1, text: ''));
    });

    test('a correction takes back only what changed', () {
      expect(keyboardEdit('teh', 'the '), (back: 2, text: 'he '));
      expect(keyboardEdit('x', ''), (back: 1, text: ''));
    });

    test('emoji count as one', () {
      expect(keyboardEdit('a😀', 'a'), (back: 1, text: ''));
    });
  });

  Future<(List<Map<String, Object>>, LinksyController)> pad(
    WidgetTester tester,
  ) async {
    final c = LinksyController(
      DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
      ActivityStore(null),
    );
    final sent = <Map<String, Object>>[];
    await tester.pumpWidget(
      LinksyScope(
        controller: c,
        child: MaterialApp(
          home: TouchpadSurface(
            send: sent.addAll,
            builder: (_, _) => const ColoredBox(color: Colors.black),
          ),
        ),
      ),
    );
    return (sent, c);
  }

  testWidgets('a three-finger tap middle-clicks', (tester) async {
    final (sent, c) = await pad(tester);
    final fingers = [
      for (final x in [200.0, 260.0, 320.0])
        await tester.startGesture(Offset(x, 300)),
    ];
    for (final f in fingers) {
      await f.up();
    }
    await tester.pump();
    expect(
      sent.where((m) => m['type'] == 'button').map((m) => m['button']),
      everyElement('middle'),
    );
    expect(sent.where((m) => m['type'] == 'button'), hasLength(2));
    c.dispose();
  });

  testWidgets('one finger down the right edge scrolls down', (tester) async {
    final (sent, c) = await pad(tester);
    final g = await tester.startGesture(const Offset(795, 200));
    for (var i = 0; i < 5; i++) {
      await g.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await tester.pumpAndSettle();
    final scrolls = sent.where((m) => m['type'] == 'scroll').toList();
    expect(scrolls, isNotEmpty);
    expect(scrolls.every((m) => (m['dy']! as num) > 0), isTrue);
    expect(sent.where((m) => m['type'] == 'pointer_by'), isEmpty);
    c.dispose();
  });
}
