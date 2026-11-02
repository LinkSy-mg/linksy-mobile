import 'dart:ui' show lerpDouble;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Like [AnimatedSize], but width and height follow their own curves, and
/// the curves differ for growing and shrinking. The island grows both ways
/// at once, and shrinks in two steps: down to the pill's height first, then
/// in to its width with a small bounce. The child sits at the bottom centre
/// and is clipped to the animated size.
class PhasedSize extends SingleChildRenderObjectWidget {
  const PhasedSize({
    super.key,
    required this.vsync,
    required this.grow,
    required this.growCurve,
    required this.shrink,
    required this.shrinkWidth,
    required this.shrinkHeight,
    super.child,
  });

  final TickerProvider vsync;
  final Duration grow;
  final Curve growCurve;
  final Duration shrink;

  /// Over [shrink], the width's and the height's own curves.
  final Curve shrinkWidth;
  final Curve shrinkHeight;

  @override
  RenderPhasedSize createRenderObject(BuildContext context) => RenderPhasedSize(
    vsync: vsync,
    grow: grow,
    growCurve: growCurve,
    shrink: shrink,
    shrinkWidth: shrinkWidth,
    shrinkHeight: shrinkHeight,
  );

  @override
  void updateRenderObject(BuildContext context, RenderPhasedSize renderObject) {
    renderObject
      ..grow = grow
      ..growCurve = growCurve
      ..shrink = shrink
      ..shrinkWidth = shrinkWidth
      ..shrinkHeight = shrinkHeight;
  }
}

class RenderPhasedSize extends RenderProxyBox {
  RenderPhasedSize({
    required TickerProvider vsync,
    required this.grow,
    required this.growCurve,
    required this.shrink,
    required this.shrinkWidth,
    required this.shrinkHeight,
  }) : _controller = AnimationController(vsync: vsync, value: 1) {
    // Only for a value this layout hasn't used yet: restarting the
    // animation inside performLayout must not dirty it again.
    _controller.addListener(() {
      if (_controller.value != _laidOutAt) markNeedsLayout();
    });
  }

  Duration grow;
  Curve growCurve;
  Duration shrink;
  Curve shrinkWidth;
  Curve shrinkHeight;

  final AnimationController _controller;
  final _clip = LayerHandle<ClipRectLayer>();

  /// The animation's value at the last layout.
  double? _laidOutAt;

  /// Where the size comes from and goes to; null before the first layout.
  Size? _from;
  Size? _to;
  bool _shrinking = false;

  Size get _now {
    final from = _from, to = _to;
    if (from == null || to == null) return to ?? Size.zero;
    final t = _controller.value;
    final (w, h) = _shrinking
        ? (shrinkWidth.transform(t), shrinkHeight.transform(t))
        : (growCurve.transform(t), growCurve.transform(t));
    return Size(
      lerpDouble(from.width, to.width, w)!,
      lerpDouble(from.height, to.height, h)!,
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints.loosen(), parentUsesSize: true);
    final target = child.size;
    if (_to == null) {
      _from = target;
      _to = target;
    } else if (target != _to) {
      // A new size: start from wherever the animation is now.
      _from = _now;
      _to = target;
      _shrinking = target.height < _from!.height;
      final duration = _shrinking ? shrink : grow;
      if (duration == Duration.zero) {
        // Motion reduced: at the new size in this same layout.
        _laidOutAt = 1;
        _controller.value = 1;
      } else {
        _controller.duration = duration;
        _laidOutAt = 0;
        _controller.forward(from: 0);
      }
    }
    _laidOutAt = _controller.value;
    size = constraints.constrain(_now);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    // Bottom centre, clipped to the size of the moment.
    final at =
        offset +
        Offset(
          (size.width - child.size.width) / 2,
          size.height - child.size.height,
        );
    _clip.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (context, _) => context.paintChild(child, at),
      oldLayer: _clip.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    final at = Offset(
      (size.width - child.size.width) / 2,
      size.height - child.size.height,
    );
    return result.addWithPaintOffset(
      offset: at,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(
      (size.width - child.size.width) / 2,
      size.height - child.size.height,
      0,
      1,
    );
  }

  @override
  void dispose() {
    _clip.layer = null;
    _controller.dispose();
    super.dispose();
  }
}
