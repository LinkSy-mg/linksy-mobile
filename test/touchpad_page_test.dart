import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/app/scope.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/features/remote/remote_screen.dart';

void main() {
  testWidgets(
    'a finger sliding on the touchpad moves the pointer, not the page',
    (tester) async {
      final c = LinksyController(
        DemoNode(name: 'Test Phone', downloadDir: '/downloads'),
        ActivityStore(null),
      );
      final sent = <Map<String, Object>>[];
      final pages = PageController();
      await tester.pumpWidget(
        LinksyScope(
          controller: c,
          child: MaterialApp(
            home: PageView(
              controller: pages,
              children: [
                TouchpadSurface(
                  send: sent.addAll,
                  builder: (_, _) => const ColoredBox(color: Colors.black),
                ),
                const SizedBox(),
              ],
            ),
          ),
        ),
      );
      final g = await tester.startGesture(const Offset(400, 300));
      for (var i = 0; i < 10; i++) {
        await g.moveBy(const Offset(-30, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      // Mid-slide: the page hasn't moved at all.
      expect(pages.position.pixels, 0);
      await g.up();
      await tester.pumpAndSettle();
      expect(pages.page, 0);
      expect(sent.where((m) => m['type'] == 'pointer_by'), isNotEmpty);
      c.dispose();
    },
  );
}
