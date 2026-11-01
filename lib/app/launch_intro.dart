import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../ui/components.dart';
import '../ui/motion.dart';
import '../ui/sig.dart';

/// The launch, picked up from the system splash (res/drawable/ic_splash_mark.xml):
/// the mark at 120 in the middle of the page colour, exactly where the splash
/// drew it, holds while the home screen draws its first frames underneath,
/// then flies into the home screen's logo with a blur through the middle of
/// the flight, while the page colour clears and the home screen rises in
/// ([Rise]). Without [plays] (first run, animations off) the cover just fades.
class LaunchIntro extends StatefulWidget {
  const LaunchIntro({super.key, required this.plays});

  final bool plays;

  /// On the home screen's logo: where the mark lands.
  static final logoKey = GlobalKey();

  /// The home screen's logo shows from here on: the mark has landed in it.
  static final landed = ValueNotifier<bool>(false);

  @override
  State<LaunchIntro> createState() => _LaunchIntroState();
}

class _LaunchIntroState extends State<LaunchIntro>
    with SingleTickerProviderStateMixin {
  // The splash's mark: 120 of its 288 (ic_splash_mark.xml).
  static const _splashMark = 120.0;
  static const _hold = Duration(milliseconds: 180);
  static const _flight = Duration(milliseconds: 660);
  static const _fade = Duration(milliseconds: 240);

  late final _controller = AnimationController(vsync: this, duration: _flight);
  Rect? _to;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Animations off: nothing to cover or fly.
    if (Motion.speed.value == 0) {
      Rise.go();
      LaunchIntro.landed.value = true;
      _done = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeOff());
  }

  Future<void> _takeOff() async {
    await Future<void>.delayed(_hold);
    if (!mounted) return;
    final logo = LaunchIntro.logoKey.currentContext;
    _to = widget.plays && !Motion.off(context) && logo != null && logo.mounted
        ? GrowRoute.rectOf(logo)
        : null;
    if (_to == null) _controller.duration = _fade;
    Rise.go();
    await _controller.forward();
    LaunchIntro.landed.value = true;
    if (mounted) setState(() => _done = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    // The splash follows the system's dark mode, whatever Linksy's own is.
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final cover = dark ? Sig.dark.bg : Sig.light.bg;
    final screen = MediaQuery.sizeOf(context);
    final from = Rect.fromCenter(
      center: screen.center(Offset.zero),
      width: _splashMark,
      height: _splashMark,
    );
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final to = _to;
          var mark = from;
          var markOpacity = 1 - t;
          var blur = 0.0;
          if (to != null) {
            final size = ui.lerpDouble(
              _splashMark,
              to.width,
              Motion.flightSize.transform(t),
            )!;
            final center = Offset.lerp(
              from.center,
              to.center,
              Motion.flight.transform(t),
            )!;
            mark = Rect.fromCenter(center: center, width: size, height: size);
            markOpacity = 1;
            blur = 5 * sin(pi * t) * size / _splashMark + 2 * sin(pi * t);
          }
          // The page colour clears in the first part of the flight.
          final coverOpacity =
              1 - (t / (to == null ? 1 : 0.45)).clamp(0.0, 1.0);
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: coverOpacity,
                  child: ColoredBox(color: cover),
                ),
              ),
              Positioned.fromRect(
                rect: mark,
                child: Opacity(
                  opacity: markOpacity,
                  child: ImageFiltered(
                    enabled: blur > 0.05,
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                    ),
                    child: LinksyMark(size: mark.width),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
