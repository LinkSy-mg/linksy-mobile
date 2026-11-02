import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/activity.dart';
import '../../app/linksy_controller.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/activity_tile.dart' show openReceived;

/// Files on their way, in or out, on every device: how many, and how far
/// along all of them are.
class _Batch {
  _Batch(this.transfers);

  final List<Activity> transfers;

  int get files => transfers.fold(0, (n, a) => n + a.names.length);
  int get bytes => transfers.fold(0, (n, a) => n + a.bytes);
  int get total => transfers.fold(0, (n, a) => n + a.total);
  double get speed => transfers.fold(0.0, (n, a) => n + a.speed);
  bool get waiting =>
      transfers.every((a) => a.status == ActivityStatus.waiting);
  double? get progress => waiting || total == 0 ? null : bytes / total;

  /// Files finished so far: whole files the bytes cover, in order.
  int get filesDone => transfers.fold(0, (n, a) => n + _done(a));

  static int _done(Activity a) {
    var left = a.bytes;
    var done = 0;
    for (final size in a.sizes) {
      if (left < size || size == 0 && left == 0) break;
      left -= size;
      done++;
    }
    return done;
  }
}

/// Files on their way, as a circle: how many, ringed by their progress, and
/// a check for a moment when they're all done. Tapping it opens
/// [TransfersScreen].
///
/// On a device's page it floats at the bottom left only while files move.
/// Home has it all the time, joined to Add a device: [TransfersButton].
class TransferBubble extends StatelessWidget {
  const TransferBubble({super.key});

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    bottom: 16 + MediaQuery.paddingOf(context).bottom,
    child: _Live(
      builder: (files, progress, state) {
        final visible = state != _BubbleState.idle;
        return AnimatedScale(
          scale: visible ? 1 : 0,
          duration: motion(context, 220),
          curve: visible ? Curves.easeOutBack : Curves.easeIn,
          child: _Last(
            empty: const SizedBox.square(dimension: 60),
            child: visible
                ? _Bubble(
                    files: files,
                    progress: progress,
                    state: state,
                    size: 60,
                    raised: true,
                  )
                : null,
          ),
        );
      },
    ),
  );
}

/// [child], or once it's gone, the last one it was: so the check is still
/// there to see while the bubble scales away.
class _Last extends StatefulWidget {
  const _Last({required this.empty, required this.child});

  final Widget? child;
  final Widget empty;

  @override
  State<_Last> createState() => _LastState();
}

class _LastState extends State<_Last> {
  Widget? _last;

  @override
  Widget build(BuildContext context) =>
      (_last = widget.child ?? _last) ?? widget.empty;
}

/// Home's way into Transfers, on the left of Add a device: the arrows when
/// nothing moves, the count and its ring when files do.
class TransfersButton extends StatelessWidget {
  const TransfersButton({super.key, this.size = 52, this.onTap});

  final double size;

  /// What a tap does; by default, open [TransfersScreen].
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _Live(
    builder: (files, progress, state) {
      final going = state == _BubbleState.going && progress != null;
      final wide = state != _BubbleState.idle;
      return AnimatedContainer(
        duration: motion(context, 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: wide
              ? Sig.blue.withValues(alpha: 0.07)
              : Sig.blue.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedSize(
          duration: motion(context, 300),
          curve: Curves.easeOutCubic,
          // The ring stays put; the percentage slides out beside it.
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Bubble(
                files: files,
                progress: progress,
                state: state,
                size: size,
                raised: false,
                onTap: onTap,
              ),
              if (going)
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 14),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Sig.blue,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Opens [TransfersScreen].
void openTransfers(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TransfersScreen()));

enum _BubbleState { idle, going, done }

/// Follows the transfers, and keeps the check up for a moment after they
/// all end.
class _Live extends StatefulWidget {
  const _Live({required this.builder});

  final Widget Function(int files, double? progress, _BubbleState state)
  builder;

  @override
  State<_Live> createState() => _LiveState();
}

class _LiveState extends State<_Live> {
  /// How many files the last batch had, kept for the check after it ends.
  int _lastFiles = 0;
  Timer? _done;

  @override
  void dispose() {
    _done?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final batch = _Batch(c.liveTransfers);
    final live = batch.transfers.isNotEmpty;
    if (live) {
      _lastFiles = batch.files;
      _done?.cancel();
      _done = null;
    } else if (_lastFiles > 0 && _done == null) {
      _done = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _lastFiles = 0);
      });
    }
    return widget.builder(
      live ? batch.files : _lastFiles,
      live ? batch.progress : 1,
      live
          ? _BubbleState.going
          : _lastFiles > 0
          ? _BubbleState.done
          : _BubbleState.idle,
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.files,
    required this.progress,
    required this.state,
    required this.size,
    required this.raised,
    this.onTap,
  });

  final int files;
  final double? progress;
  final _BubbleState state;
  final double size;

  /// Floating, with a shadow; else sitting in the pill.
  final bool raised;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final done = state == _BubbleState.done;
    return Pressable(
      onTap: onTap ?? () => openTransfers(context),
      semanticLabel: state == _BubbleState.idle
          ? context.l10n.transfersTitle
          : context.l10n.transfersBubble(files),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: raised ? s.card : Colors.transparent,
          boxShadow: raised
              ? const [
                  BoxShadow(
                    color: Color(0x2E0A1024),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedSwitcher(
          duration: motion(context, 220),
          child: state == _BubbleState.idle
              ? Icon(
                  Ph.arrowsDownUp,
                  key: const ValueKey('idle'),
                  color: Sig.blue,
                  size: 22,
                )
              : Stack(
                  key: const ValueKey('going'),
                  fit: StackFit.expand,
                  children: [
                    // Turning while the other side hasn't accepted yet.
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: progress ?? 0),
                      duration: motion(context, 400),
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: progress == null ? null : value,
                        strokeWidth: size > 56 ? 4 : 3,
                        strokeCap: StrokeCap.round,
                        color: done ? Sig.cyan : Sig.blue,
                        backgroundColor: s.line,
                      ),
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: motion(context),
                        transitionBuilder: popIn,
                        child: done
                            ? const Icon(
                                PhBold.check,
                                key: ValueKey(true),
                                color: Sig.cyan,
                                size: 22,
                              )
                            : Text(
                                '$files',
                                key: const ValueKey(false),
                                style: sora(
                                  files > 99 ? 13 : 17,
                                  weight: FontWeight.w700,
                                  color: s.ink,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Transfers in home's island: what's moving, with its speed and the next
/// few files, or the last few that moved. "See more" when there's more.
class TransfersPeek extends StatelessWidget {
  const TransfersPeek({super.key, required this.onMore});

  final VoidCallback onMore;

  static const _most = 3;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final s = Sig.of(context);
    final l = context.l10n;
    final batch = _Batch(c.liveTransfers);
    final recent = c.recentTransfers;
    final Widget more = Center(
      child: SmallAction(label: l.islandSeeMore, onTap: onMore),
    );
    if (batch.transfers.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recent.isEmpty)
            const _Nothing()
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Text(l.transfersRecent.toUpperCase(), style: _label(s)),
            ),
            for (final a in recent.take(_most)) _Recent(c: c, activity: a),
            if (recent.length > _most) more,
          ],
        ],
      );
    }
    // The file on its way first, then the ones after it.
    final files = [
      for (final a in batch.transfers)
        for (var i = _Batch._done(a); i < a.names.length; i++) (a, i),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Speed(c: c, batch: batch, flat: true),
        const SizedBox(height: 6),
        for (final (a, i) in files.take(_most))
          _File(
            name: a.names[i],
            size: i < a.sizes.length ? a.sizes[i] : null,
            state: i == _Batch._done(a) && a.status == ActivityStatus.active
                ? _FileState.going
                : _FileState.next,
            progress: _Transfer._fileProgress(a, i),
          ),
        // Always while files move: the page has Cancel.
        more,
      ],
    );
  }
}

/// Everything on its way: the speed on top, then each transfer's files,
/// then the ones that ended.
class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final batch = _Batch(c.liveTransfers);
    final recent = c.recentTransfers;
    return Scaffold(
      appBar: AppBar(title: Text(l.transfersTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (batch.transfers.isEmpty)
            const _Nothing()
          else ...[
            _Speed(c: c, batch: batch),
            _Feels(speed: batch.waiting ? 0 : batch.speed),
            for (final a in batch.transfers) _Transfer(c: c, activity: a),
          ],
          if (recent.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 28, 8, 10),
              child: Text(
                l.transfersRecent.toUpperCase(),
                style: _label(Sig.of(context)),
              ),
            ),
            for (final a in recent) _Recent(c: c, activity: a),
          ],
        ],
      ),
    );
  }
}

/// A round icon on a light tint of its color.
class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.color, {this.size = 36});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.12),
    ),
    child: Icon(icon, size: size * 0.48, color: color),
  );
}

class _Nothing extends StatelessWidget {
  const _Nothing();

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return SigCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          const _Badge(Ph.arrowsDownUp, Sig.blue, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.transfersNone, style: sora(18, color: s.ink)),
                const SizedBox(height: 4),
                Text(
                  l.transfersNoneBody,
                  style: TextStyle(fontSize: 13.5, height: 1.4, color: s.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The speed of everything together, with files flowing between the two
/// devices as fast as they really go.
class _Speed extends StatelessWidget {
  const _Speed({required this.c, required this.batch, this.flat = false});

  final LinksyController c;
  final _Batch batch;

  /// Inside something that's already a card: no card of its own.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final first = batch.transfers.first;
    final device = c.device(first.deviceId);
    final other = device?.device.kind ?? DeviceKind.desktop;
    final going = !batch.waiting && batch.speed > 0;
    final stage = c.direct[first.deviceId];
    final settingUp = stage != null && stage != DirectStage.up;
    final computer = _End(kindIcon(other), Sig.incoming);
    const phone = _End(Ph.deviceMobile, Sig.outgoing);
    final speed = formatSpeed(batch.speed).split(' ');
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: going
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: speed.first),
                          TextSpan(
                            text: ' ${speed.skip(1).join(' ')}',
                            style: TextStyle(fontSize: 15, color: s.muted),
                          ),
                        ],
                      ),
                      style: sora(28, weight: FontWeight.w700, color: s.ink)
                          .copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    )
                  : Text(
                      settingUp
                          ? l.transfersRouteDirectSetup
                          : l.transfersWaiting,
                      style: sora(22, color: s.ink),
                    ),
            ),
            if (batch.progress != null)
              Text(
                '${(batch.progress! * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Sig.blue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (first.incoming) computer else phone,
            const SizedBox(width: 10),
            // The way files go, riding in the middle of the lane
            Expanded(
              child: SizedBox(
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      child: _Flow(
                        speed: going ? batch.speed : 0,
                        scanning: stage == DirectStage.find,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: motion(context, 260),
                      transitionBuilder: (child, a) => ScaleTransition(
                        scale: Tween(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                        ),
                        child: FadeTransition(opacity: a, child: child),
                      ),
                      child: switch (stage) {
                        DirectStage.up => const _RoutePill.direct(
                          key: ValueKey('direct'),
                        ),
                        final DirectStage st => _RoutePill.step(
                          key: const ValueKey('step'),
                          stage: st,
                          name: device?.device.name ?? '',
                        ),
                        null when device != null => _RoutePill.network(
                          key: ValueKey(linkWords(device)),
                          view: device,
                        ),
                        null => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (first.incoming) phone else computer,
          ],
        ),
      ],
    );
    return flat
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: body,
          )
        : SigCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: body,
          );
  }
}

/// The small pill in the middle of the lane: a direct link's step while it
/// comes up, Wi-Fi Direct once it's up, else the network files go over.
class _RoutePill extends StatefulWidget {
  const _RoutePill.direct({super.key})
    : stage = DirectStage.up,
      name = '',
      view = null;
  const _RoutePill.step({super.key, required this.stage, required this.name})
    : view = null;
  const _RoutePill.network({super.key, required DeviceView this.view})
    : stage = null,
      name = '';

  final DirectStage? stage;
  final String name;
  final DeviceView? view;

  @override
  State<_RoutePill> createState() => _RoutePillState();
}

class _RoutePillState extends State<_RoutePill>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  bool get _settingUp => widget.stage != null && widget.stage != DirectStage.up;

  /// Pulses while setting up, unless motion is reduced.
  void _sync() {
    if (_settingUp && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_RoutePill old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final stage = widget.stage;
    final blue = stage != null;
    final List<Widget> children;
    if (stage == DirectStage.up) {
      children = [
        const _DoubleBolt(),
        const SizedBox(width: 4),
        Text(l.transfersRouteDirect),
      ];
    } else if (stage != null) {
      children = [
        FadeTransition(
          opacity: Tween(begin: 0.3, end: 1.0).animate(_pulse),
          child: const _Dot(Sig.blue),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: AnimatedSwitcher(
            duration: motion(context, 220),
            child: Text(
              switch (stage) {
                DirectStage.find => l.transfersDirectFinding(widget.name),
                DirectStage.connect => l.transfersDirectConnecting,
                _ => l.transfersDirectLinking,
              },
              key: ValueKey(stage),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: s.ink),
            ),
          ),
        ),
        const SizedBox(width: 6),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
            child: _Dot(i <= stage.index ? Sig.blue : s.line, size: 4),
          ),
      ];
    } else {
      final v = widget.view!;
      children = [
        Icon(
          v.usb
              ? Ph.usb
              : v.away
              ? Ph.globe
              : Ph.wifiHigh,
          size: 12,
          color: s.muted,
        ),
        const SizedBox(width: 4),
        Text(linkWords(v)),
      ];
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 9, 3),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: blue ? Sig.blue.withValues(alpha: 0.22) : s.line,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: blue ? Sig.blue : s.muted,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color, {this.size = 6});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

/// Two bolts, the second a little behind: Wi-Fi Direct.
class _DoubleBolt extends StatelessWidget {
  const _DoubleBolt();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    height: 12,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 6,
          child: Icon(
            PhFill.lightning,
            size: 12,
            color: Sig.blue.withValues(alpha: 0.55),
          ),
        ),
        const Positioned(
          left: 0,
          child: Icon(PhFill.lightning, size: 12, color: Sig.blue),
        ),
      ],
    ),
  );
}

/// One end of the lane: a device in a tinted tile.
class _End extends StatelessWidget {
  const _End(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: color),
  );
}

/// A lane with files running along it: the faster the transfer, the faster
/// they run. Still while it waits.
class _Flow extends StatefulWidget {
  const _Flow({required this.speed, this.scanning = false});

  /// Bytes per second.
  final double speed;

  /// A light sweep along the lane, while a direct link looks for the other
  /// device.
  final bool scanning;

  @override
  State<_Flow> createState() => _FlowState();
}

class _FlowState extends State<_Flow> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// How far the files have run, in lanes.
  double _phase = 0;

  /// Lanes a second, eased towards the speed so a jump doesn't jolt.
  double _pace = 0;

  /// Where the sweep is, in lanes.
  double _scan = 0;

  /// Motion is reduced: the lane stays still.
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (_still) return;
    // 1 MB/s crawls, 100 MB/s races; past that it stays readable.
    final mb = widget.speed / 1e6;
    final target = mb <= 0 ? 0.0 : (0.12 + mb / 80).clamp(0.12, 1.6);
    _pace += (target - _pace) * (dt * 3).clamp(0.0, 1.0);
    if (widget.scanning) _scan = (_scan + dt / 1.4) % 1;
    if (_pace < 0.001 && !widget.scanning) return;
    setState(() => _phase = (_phase + _pace * dt) % 1);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 10,
    child: CustomPaint(
      painter: _FlowPainter(
        phase: _phase,
        track: Sig.of(context).raised,
        dot: Sig.blue,
        still: widget.speed <= 0,
        scan: widget.scanning ? _scan : null,
      ),
    ),
  );
}

class _FlowPainter extends CustomPainter {
  _FlowPainter({
    required this.phase,
    required this.track,
    required this.dot,
    required this.still,
    this.scan,
  });

  final double phase;
  final Color track;
  final Color dot;
  final bool still;

  /// Where the sweep is (0 to 1), when there is one.
  final double? scan;

  static const _dots = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final lane = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(lane, Paint()..color = track);
    if (scan case final t?) {
      final w = size.width * 0.3;
      final x = -w + t * (size.width + w);
      final sweep = Rect.fromLTWH(x, 0, w, size.height);
      canvas.save();
      canvas.clipRRect(lane);
      canvas.drawRect(
        sweep,
        Paint()
          ..shader = LinearGradient(
            colors: [
              dot.withValues(alpha: 0),
              dot.withValues(alpha: 0.55),
              dot.withValues(alpha: 0),
            ],
          ).createShader(sweep),
      );
      canvas.restore();
    }
    if (still) return;
    canvas.save();
    canvas.clipRRect(lane);
    const w = 14.0, h = 6.0;
    for (var i = 0; i < _dots; i++) {
      final t = (phase + i / _dots) % 1;
      final x = -w + t * (size.width + w);
      // Fade in at the start, out at the end.
      final fade = (t * 8).clamp(0.0, 1.0) * ((1 - t) * 8).clamp(0.0, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (size.height - h) / 2, w, h),
          const Radius.circular(3),
        ),
        Paint()..color = dot.withValues(alpha: fade),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.phase != phase ||
      old.still != still ||
      old.track != track ||
      old.scan != scan;
}

/// The speed as something felt, under the card: a movie, photos, songs. A
/// new one every few seconds.
class _Feels extends StatefulWidget {
  const _Feels({required this.speed});

  final double speed;

  @override
  State<_Feels> createState() => _FeelsState();
}

class _FeelsState extends State<_Feels> {
  int _turn = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => setState(() => _turn++),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final mb = widget.speed / 1e6;
    // Only once it's fast enough to enjoy.
    if (mb < 15) return const SizedBox.shrink();
    final lines = [
      // A 1 GB movie, 3 MB photos, 5 MB songs.
      l.transfersFastMovie((1000 / mb).round()),
      if (mb / 3 >= 2) l.transfersFastPhotos((mb / 3).round()),
      if (mb / 5 >= 2) l.transfersFastSongs((mb / 5).round()),
    ];
    if (lines.isEmpty) return const SizedBox(height: 4);
    final i = _turn % lines.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Row(
        children: [
          const Icon(PhFill.lightning, size: 15, color: Sig.blue),
          const SizedBox(width: 7),
          Expanded(
            child: AnimatedSwitcher(
              duration: motion(context, 300),
              layoutBuilder: (current, previous) => Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [...previous, ?current],
              ),
              child: Text(
                lines[i],
                key: ValueKey(i),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Sig.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Transfer extends StatelessWidget {
  const _Transfer({required this.c, required this.activity});

  final LinksyController c;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final s = Sig.of(context);
    final l = context.l10n;
    final name = c.device(a.deviceId)?.device.name ?? shortDeviceId(a.deviceId);
    final doneCount = _Batch._done(a);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    [
                      a.incoming ? l.transfersFrom(name) : l.transfersTo(name),
                      l.transfersFilesDone(doneCount, a.names.length),
                    ].join(' · ').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _label(s),
                  ),
                ),
              ),
              SmallAction(
                label: l.commonCancel,
                onTap: () => c.cancel(a.id),
                color: s.muted,
              ),
            ],
          ),
          for (var i = 0; i < a.names.length; i++)
            _File(
              name: a.names[i],
              size: i < a.sizes.length ? a.sizes[i] : null,
              state: i < doneCount
                  ? _FileState.done
                  : i == doneCount && a.status == ActivityStatus.active
                  ? _FileState.going
                  : _FileState.next,
              progress: _fileProgress(a, i),
            ),
        ],
      ),
    );
  }

  /// How far along file [i] is, from the bytes past the files before it.
  static double? _fileProgress(Activity a, int i) {
    if (i >= a.sizes.length || a.sizes[i] == 0) return null;
    final before = a.sizes.take(i).fold(0, (n, s) => n + s);
    return ((a.bytes - before) / a.sizes[i]).clamp(0.0, 1.0);
  }
}

/// The small caps above a list.
TextStyle _label(Sig s) => TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.3,
  color: s.muted,
);

enum _FileState { done, going, next }

/// A small icon in a soft circle; for the file on its way, blue and ringed
/// by its progress, like the bubble on the home screen.
class _Round extends StatelessWidget {
  const _Round(this.icon, {this.progress, this.going = false});

  final IconData icon;
  final double? progress;
  final bool going;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: going
                  ? Sig.blue.withValues(alpha: 0.10)
                  : s.ink.withValues(alpha: 0.05),
            ),
          ),
          if (going)
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress ?? 0),
              duration: motion(context, 400),
              builder: (context, v, _) => CircularProgressIndicator(
                value: progress == null ? null : v,
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
                color: Sig.blue,
                backgroundColor: s.line,
              ),
            ),
          Icon(icon, size: 18, color: going ? Sig.blue : s.faint),
        ],
      ),
    );
  }
}

class _File extends StatelessWidget {
  const _File({
    required this.name,
    required this.size,
    required this.state,
    required this.progress,
  });

  final String name;
  final int? size;
  final _FileState state;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final size = this.size;
    final going = state == _FileState.going;
    final percent = '${((progress ?? 0) * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _Round(fileIcon(name), progress: progress, going: going),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: going ? FontWeight.w600 : FontWeight.w500,
                    color: going ? s.ink : s.muted,
                  ),
                ),
                if (going && size != null && progress != null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${l.activityProgress(formatBytes((size * progress!).round()), formatBytes(size))} · ',
                        ),
                        TextSpan(
                          text: percent,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Sig.blue,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: s.muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                else if (size != null)
                  Text(
                    formatBytes(size),
                    style: TextStyle(fontSize: 12.5, color: s.faint),
                  ),
              ],
            ),
          ),
          if (state == _FileState.done) ...[
            const SizedBox(width: 10),
            Icon(PhBold.check, size: 16, color: s.faint),
          ],
        ],
      ),
    );
  }
}

/// One transfer that ended: what, with whom, how big, when, and how. A tap
/// opens a single received file; a group opens up to list its files, each
/// one opening on a tap when it came here.
class _Recent extends StatefulWidget {
  const _Recent({required this.c, required this.activity});

  final LinksyController c;
  final Activity activity;

  @override
  State<_Recent> createState() => _RecentState();
}

class _RecentState extends State<_Recent> {
  bool _open = false;

  /// Where file [i] landed here, when it did.
  String? _saved(int i) {
    final a = widget.activity;
    return a.incoming && a.status == ActivityStatus.done && i < a.saved.length
        ? a.saved[i]
        : null;
  }

  void _tap() {
    final a = widget.activity;
    if (a.names.length > 1) {
      setState(() => _open = !_open);
    } else if (_saved(0) case final path?) {
      openReceived(context, path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final s = Sig.of(context);
    final l = context.l10n;
    final name =
        widget.c.device(a.deviceId)?.device.name ?? shortDeviceId(a.deviceId);
    final today = DateUtils.isSameDay(a.time, DateTime.now());
    final group = a.names.length > 1;
    // A tap opens the group or the file; a single sent or failed file has
    // nothing to open, so the row doesn't pretend to.
    final opens = group || _saved(0) != null;
    final row = Pressable(
      onTap: opens ? _tap : null,
      scale: 0.98,
      semanticLabel: a.names.length == 1
          ? a.names.first
          : l.activityItems(a.names.length),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _Round(
              group
                  ? (a.incoming ? PhBold.arrowDownLeft : PhBold.arrowUpRight)
                  : fileIcon(a.names.first),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group ? l.activityItems(a.names.length) : a.names.first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: s.ink,
                    ),
                  ),
                  Text(
                    [
                      a.incoming ? l.transfersFrom(name) : l.transfersTo(name),
                      if (a.total > 0) formatBytes(a.total),
                      today ? formatClock(a.time) : formatDay(a.time),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: s.faint),
                  ),
                ],
              ),
            ),
            if (a.status != ActivityStatus.done) ...[
              const SizedBox(width: 10),
              Text(
                a.status == ActivityStatus.declined
                    ? l.activityDeclined
                    : l.activityFailed,
                style: TextStyle(fontSize: 12.5, color: s.red),
              ),
            ] else if (group) ...[
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: motion(context, 260),
                curve: Curves.easeOutCubic,
                child: Icon(Ph.caretDown, size: 16, color: s.faint),
              ),
            ],
          ],
        ),
      ),
    );
    if (!group) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        AnimatedSize(
          duration: motion(context, 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !_open
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(60, 2, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          [
                            l.activityFiles(a.names.length),
                            if (a.total > 0) formatBytes(a.total),
                          ].join(' · ').toUpperCase(),
                          style: _label(s),
                        ),
                      ),
                      for (var i = 0; i < a.names.length; i++)
                        Pressable(
                          onTap: _saved(i) == null
                              ? null
                              : () => openReceived(context, _saved(i)!),
                          scale: 0.99,
                          semanticLabel: a.names[i],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                Icon(
                                  fileIcon(a.names[i]),
                                  size: 18,
                                  color: s.faint,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    a.names[i],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: s.ink,
                                    ),
                                  ),
                                ),
                                if (i < a.sizes.length)
                                  Text(
                                    formatBytes(a.sizes[i]),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: s.faint,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
