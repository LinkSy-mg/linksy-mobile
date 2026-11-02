import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// "Find my phone": full screen while it rings, one big "Found it". Closes by
/// itself when the computer stops it or after 30 seconds.
class RingScreen extends StatefulWidget {
  const RingScreen({super.key, required this.from});

  final DeviceInfo from;

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  bool _closed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stopped elsewhere: the controller isn't ringing anymore.
    if (LinksyScope.of(context).ringingFrom == null && !_closed) {
      _closed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  void _found() {
    LinksyScope.read(context).stopRinging();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) LinksyScope.read(context).stopRinging();
    },
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayFor(Brightness.dark),
      child: Scaffold(
        backgroundColor: Sig.blue,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              children: [
                const Spacer(),
                _Halo(
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Sig.deep,
                    ),
                    child: const Icon(
                      PhFill.bellRinging,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  context.l10n.ringTitle,
                  textAlign: TextAlign.center,
                  style: sora(34, weight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.ringLookingFor(widget.from.name),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                Pressable(
                  onTap: _found,
                  semanticLabel: context.l10n.ringFoundIt,
                  child: Container(
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      context.l10n.ringFoundIt,
                      style: sora(19, weight: FontWeight.w700, color: Sig.deep),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// A soft wave leaving the bell while it rings; still when motion is
/// reduced.
class _Halo extends StatefulWidget {
  const _Halo({required this.child});

  final Widget child;

  @override
  State<_Halo> createState() => _HaloState();
}

class _HaloState extends State<_Halo> with SingleTickerProviderStateMixin {
  late final _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessReduced(context, _wave);
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _Wave(_wave), child: widget.child);
}

/// A disc behind the bell that grows half again and fades as it goes.
class _Wave extends CustomPainter {
  _Wave(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final v = Curves.easeOut.transform(t.value);
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 * (1 + 0.5 * v),
      Paint()..color = Colors.white.withValues(alpha: 0.22 * (1 - v)),
    );
  }

  @override
  bool shouldRepaint(_Wave old) => old.t != t;
}
