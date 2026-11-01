/// How Linksy moves: the curves and timings everything shares, the animation
/// speed setting, pages sliding an eighth of the way in, content rising into
/// place, and pages growing out of the card that opened them.
library;

import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

abstract final class Motion {
  /// Long and soft at the end: most things arriving.
  static const emphasized = Cubic(0.2, 0, 0, 1);

  /// The launch mark's flight: still, a gentle start, a long settle. Its size
  /// leads the move a little, so it has shrunk before it crosses the screen.
  static const flight = Cubic(0.55, 0, 0.1, 1);
  static const flightSize = Cubic(0.45, 0, 0.1, 1);

  static const page = Duration(milliseconds: 380);
  static const grow = Duration(milliseconds: 460);
  static const rise = Duration(milliseconds: 520);
  static const riseStagger = Duration(milliseconds: 50);
  static const riseDistance = 56.0;

  /// The animation speed setting: 0 is off, else 0.5 to 2 times as fast.
  static final speed = ValueNotifier<double>(1);
  static const speeds = [0.0, 0.5, 1.0, 1.5, 2.0];

  static void setSpeed(double value) {
    speed.value = value;
    // Every ticker in the app reads it, so everything keeps its proportions;
    // off leaves it alone and Linksy's own motion steps aside instead.
    timeDilation = value == 0 ? 1 : 1 / value;
  }

  /// Linksy's own motion stands still (the setting, or the system's
  /// "remove animations").
  static bool off(BuildContext context) =>
      speed.value == 0 || MediaQuery.disableAnimationsOf(context);
}

/// Pages slide an eighth of the width and fade: the new one in from the side,
/// the old one out the other way, and back again on the way back. A back
/// gesture drags the same motion with the finger.
class SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlidePageTransitionsBuilder();

  @override
  Duration get transitionDuration => Motion.page;

  @override
  Duration get reverseTransitionDuration => Motion.page;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => BackGesture(
    route: route,
    child: _SlideFade(
      route: route,
      animation: animation,
      secondary: secondaryAnimation,
      child: child,
    ),
  );
}

class _SlideFade extends StatefulWidget {
  const _SlideFade({
    required this.route,
    required this.animation,
    required this.secondary,
    required this.child,
  });

  final PageRoute<dynamic> route;
  final Animation<double> animation;
  final Animation<double> secondary;
  final Widget child;

  @override
  State<_SlideFade> createState() => _SlideFadeState();
}

class _SlideFadeState extends State<_SlideFade> {
  late CurvedAnimation _in;
  late CurvedAnimation _out;

  @override
  void initState() {
    super.initState();
    _curve();
  }

  @override
  void didUpdateWidget(_SlideFade old) {
    super.didUpdateWidget(old);
    if (old.animation != widget.animation ||
        old.secondary != widget.secondary) {
      _in.dispose();
      _out.dispose();
      _curve();
    }
  }

  void _curve() {
    _in = CurvedAnimation(
      parent: widget.animation,
      curve: Motion.emphasized,
      reverseCurve: Motion.emphasized.flipped,
    );
    _out = CurvedAnimation(
      parent: widget.secondary,
      curve: Motion.emphasized,
      reverseCurve: Motion.emphasized.flipped,
    );
  }

  @override
  void dispose() {
    _in.dispose();
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.off(context)) return widget.child;
    final dx = MediaQuery.sizeOf(context).width / 8;
    return AnimatedBuilder(
      animation: Listenable.merge([_in, _out]),
      child: widget.child,
      builder: (context, child) {
        // Under a finger the page follows it exactly, no curve.
        final a = widget.route.popGestureInProgress
            ? widget.animation.value
            : _in.value;
        final b = _out.value;
        // The fades take the first half: the old page is gone before the new
        // one has settled.
        final fadeIn = (a / 0.55).clamp(0.0, 1.0);
        final fadeOut = 1 - (b / 0.55).clamp(0.0, 1.0);
        return Opacity(
          opacity: fadeIn * fadeOut,
          child: Transform.translate(
            offset: Offset((1 - a) * dx - b * dx, 0),
            child: child,
          ),
        );
      },
    );
  }
}

/// Android's back gesture, handed to [route] so its own transition follows
/// the finger (as Flutter's predictive back does for its transition).
class BackGesture extends StatefulWidget {
  const BackGesture({super.key, required this.route, required this.child});

  final PageRoute<dynamic> route;
  final Widget child;

  @override
  State<BackGesture> createState() => _BackGestureState();
}

class _BackGestureState extends State<BackGesture> with WidgetsBindingObserver {
  bool get _enabled => widget.route.isCurrent && widget.route.popGestureEnabled;

  @override
  bool handleStartBackGesture(PredictiveBackEvent event) {
    if (event.isButtonEvent || !_enabled) return false;
    widget.route.handleStartBackGesture(progress: 1 - event.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent event) => widget
      .route
      .handleUpdateBackGestureProgress(progress: 1 - event.progress);

  @override
  void handleCancelBackGesture() => widget.route.handleCancelBackGesture();

  @override
  void handleCommitBackGesture() => widget.route.handleCommitBackGesture();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Comes up into place: from a little below, fading in, each [index] a beat
/// after the one before. Content of the first screen waits for the launch
/// intro's flight ([Rise.start]); anything later rises when it appears.
class Rise extends StatefulWidget {
  const Rise({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Completes when the launch intro takes off (at once without one).
  static Future<void> get start => _start.future;
  static final _start = Completer<void>();

  static void go() {
    if (!_start.isCompleted) _start.complete();
  }

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.rise,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.emphasized,
  );

  @override
  void initState() {
    super.initState();
    _begin();
  }

  Future<void> _begin() async {
    if (Motion.speed.value == 0) {
      _controller.value = 1;
      return;
    }
    await Rise.start;
    // A long list doesn't keep its last rows waiting.
    final step = widget.index.clamp(0, 8);
    await Future<void>.delayed(
      const Duration(milliseconds: 80) + Motion.riseStagger * step,
    );
    if (!mounted) return;
    if (Motion.off(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curve,
    child: widget.child,
    builder: (context, child) {
      final t = _curve.value;
      return Opacity(
        opacity: (_controller.value / 0.6).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * Motion.riseDistance),
          child: child,
        ),
      );
    },
  );
}

/// A page that grows out of the card that opened it, [from] (in global
/// coordinates, with the card's [radius] and [color]), and shrinks back into
/// it on the way back. The page under it dims a little.
class GrowRoute<T> extends PageRoute<T> {
  GrowRoute({
    required this.builder,
    required this.from,
    required this.color,
    this.radius = 22,
  });

  final WidgetBuilder builder;
  final Rect from;
  final Color color;
  final double radius;

  /// [context]'s box, for [GrowRoute.from].
  static Rect? rectOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Motion.grow;

  @override
  Duration get reverseTransitionDuration => Motion.grow;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Going further from here, it moves like any page.
    final onward = _SlideFade(
      route: this,
      animation: kAlwaysCompleteAnimation,
      secondary: secondaryAnimation,
      child: child,
    );
    return BackGesture(
      route: this,
      child: _Grow(route: this, animation: animation, child: onward),
    );
  }
}

class _Grow extends StatelessWidget {
  const _Grow({
    required this.route,
    required this.animation,
    required this.child,
  });

  final GrowRoute<dynamic> route;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final raw = animation.value;
      if (raw >= 1 || Motion.off(context)) return child!;
      final t = route.popGestureInProgress
          ? raw
          : (animation.status == AnimationStatus.reverse
                ? Motion.emphasized.flipped.transform(raw)
                : Motion.emphasized.transform(raw));
      final screen = Offset.zero & MediaQuery.sizeOf(context);
      final rect = Rect.lerp(route.from, screen, t)!;
      final scale = rect.width / screen.width;
      // The page fades in over the card's colour once it has some room.
      final fade = ((t - 0.15) / 0.45).clamp(0.0, 1.0);
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.18 * t)),
            ),
          ),
          Positioned.fromRect(
            rect: rect,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                lerpDouble(route.radius, 0, t)!,
              ),
              child: ColoredBox(
                color: route.color,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minWidth: screen.width,
                  maxWidth: screen.width,
                  minHeight: screen.height,
                  maxHeight: screen.height,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Opacity(opacity: fade, child: child),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
