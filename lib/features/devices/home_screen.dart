import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/activity.dart';
import '../../app/launch_intro.dart';
import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/activity_tile.dart';
import '../device/device_screen.dart';
import '../sharing/sharing.dart';
import '../settings/settings_screen.dart';
import '../settings/turn_on.dart';
import 'island.dart';
import '../update/update_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final s = Sig.of(context);
    final paired = c.paired;
    final unpaired = c.unpaired;

    void open(DeviceView v) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceScreen(deviceId: v.device.id)),
    );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 68,
                titleSpacing: 20,
                backgroundColor: s.bg,
                // The launch intro's mark lands in this logo.
                title: Wordmark(
                  markKey: LaunchIntro.logoKey,
                  markShown: LaunchIntro.landed,
                ),
                actions: [
                  RoundButton(
                    icon: Ph.gearSix,
                    tooltip: context.l10n.homeSettings,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(child: _Visible(controller: c)),
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: c.updates,
                  builder: (_, _) => _Notices(controller: c),
                ),
              ),
              SliverToBoxAdapter(child: SharingBanners(controller: c)),
              if (paired.isEmpty)
                const SliverToBoxAdapter(child: _GetStarted())
              else ...[
                SliverToBoxAdapter(
                  child: _Title(
                    context.l10n.homeYourDevices,
                    trailing: Text(
                      '${paired.length}',
                      style: sora(13, color: s.muted),
                    ),
                  ),
                ),
                SliverList.separated(
                  itemCount: paired.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DeviceRow(
                      view: paired[i],
                      controller: c,
                      onTap: () => open(paired[i]),
                    ),
                  ),
                ),
              ],
              if (unpaired.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _Title(context.l10n.homeNearbyNotPaired),
                ),
                SliverList.separated(
                  itemCount: unpaired.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _NearbyRow(view: unpaired[i]),
                  ),
                ),
              ],
              _PageEnd(arrow: paired.isEmpty),
            ],
          ),
          // Transfers, Send files and Add a device, growing in place.
          Positioned.fill(child: Island(paired: paired)),
        ],
      ),
    );
  }
}

/// One quiet line: this phone can be found.
class _Visible extends StatelessWidget {
  const _Visible({required this.controller});

  final LinksyController controller;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final name = controller.settings?.name ?? controller.node.info.name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 20, 0),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Sig.cyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.l10n.homeVisible(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: s.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// What Linksy's service says (docs/protocol.md §4.12): an update this phone needs
/// to keep connecting, and notices, each shown until dismissed. Plain text.
class _Notices extends StatelessWidget {
  const _Notices({required this.controller});

  final LinksyController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final download = c.serviceInfo?.androidDownload;
    final update = c.updates.available;
    final cards = [
      if (update != null && c.prefs['update_later'] != update.version)
        _Notice(
          icon: Ph.arrowCircleUp,
          warning: false,
          title: context.l10n.updateAvailable(update.version),
          body: '',
          action: context.l10n.updateNow,
          onAction: () => showUpdate(context),
          onDismiss: () => c.setPref('update_later', update.version),
        ),
      if (c.turnOnCard)
        _Notice(
          icon: Ph.chatCircleText,
          warning: false,
          title: context.l10n.homeTurnOnTitle,
          body: context.l10n.homeTurnOnBody,
          action: c.mirroring ? null : context.l10n.homeTurnOnMessages,
          onAction: () => turnOn(context, 'notifications'),
          secondAction: c.gallery ? null : context.l10n.homeTurnOnPhotos,
          onSecondAction: () => turnOn(context, 'gallery'),
          onDismiss: c.dismissTurnOnCard,
        ),
      if (c.outdated)
        _Notice(
          icon: Ph.warningCircle,
          warning: true,
          title: context.l10n.homeUpdateTitle,
          body: context.l10n.homeUpdateBody,
          action: download == null ? null : context.l10n.homeGetUpdate,
          onAction: update != null
              ? () => showUpdate(context)
              : download == null
              ? null
              : () => LinksyPlatform.openUrl(download),
        ),
      for (final n in c.notices)
        _Notice(
          icon: n.warning ? Ph.warningCircle : Ph.bellRinging,
          warning: n.warning,
          title: n.title,
          body: n.body,
          onDismiss: () => c.dismissNotice(n.id),
        ),
    ];
    // Notices come and go: the list makes room, and closes up.
    return AnimatedSize(
      duration: motion(context, 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: cards.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    ),
                ],
              ),
            ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.warning,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.secondAction,
    this.onSecondAction,
    this.onDismiss,
  });

  final IconData icon;
  final bool warning;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final String? secondAction;
  final VoidCallback? onSecondAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final color = warning ? s.red : Sig.blue;
    return SigCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title, style: sora(15.5, color: s.ink)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 13,
                      color: s.muted,
                      height: 1.35,
                    ),
                  ),
                ],
                if (action != null || secondAction != null)
                  Wrap(
                    children: [
                      if (action != null)
                        SmallAction(label: action!, onTap: onAction),
                      if (secondAction != null)
                        SmallAction(
                          label: secondAction!,
                          onTap: onSecondAction,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            Tooltip(
              message: context.l10n.commonDismiss,
              child: Pressable(
                onTap: onDismiss,
                scale: 0.85,
                semanticLabel: context.l10n.commonDismiss,
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(Ph.x, size: 18, color: s.faint),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.view,
    required this.controller,
    required this.onTap,
  });

  final DeviceView view;
  final LinksyController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final d = view.device;
    final last = controller.lastActivity(d.id);
    // Only transfers have progress; a live screen or camera share shows as
    // the banner at the top instead.
    final transferring =
        last != null && last.isLive && last.kind == ActivityKind.files;
    final away = view.presence == Presence.notNearby;

    return SigCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Orb(
            device: d,
            size: 46,
            presence: view.presence,
            picture: LinksyScope.of(context).pictureOf(d.id),
            battery: view.battery,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: sora(16.5, color: s.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: motion(context),
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: away
                            ? s.line
                            : view.connected
                            ? Sig.cyan
                            : Sig.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      linkWords(view),
                      style: TextStyle(
                        fontSize: 13,
                        color: away ? s.faint : s.muted,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        [
                          if (view.battery case final b? when !away)
                            '${b.level}%',
                          if (last != null && !transferring)
                            activityTitle(last),
                        ].map((p) => '  ·  $p').join(),
                        style: TextStyle(fontSize: 13, color: s.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: motion(context),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: transferring
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: last.total == 0 || last.bytes == 0
                              ? LinearProgressIndicator(
                                  color: last.incoming
                                      ? Sig.incoming
                                      : Sig.outgoing,
                                )
                              : TweenAnimationBuilder<double>(
                                  tween: Tween(end: last.bytes / last.total),
                                  duration: motion(context, 250),
                                  builder: (context, value, _) =>
                                      LinearProgressIndicator(
                                        color: last.incoming
                                            ? Sig.incoming
                                            : Sig.outgoing,
                                        value: value,
                                      ),
                                ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: motion(context),
            transitionBuilder: popIn,
            child: away
                ? Icon(
                    Ph.caretRight,
                    key: const ValueKey(true),
                    color: s.faint,
                    size: 18,
                  )
                : _QuickSend(key: const ValueKey(false), deviceId: d.id),
          ),
        ],
      ),
    );
  }
}

/// Send files without opening the device first.
class _QuickSend extends StatelessWidget {
  const _QuickSend({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => pickAndSend(context, deviceId),
    scale: 0.88,
    semanticLabel: context.l10n.homeSendFiles,
    // Soft, so a list of devices isn't a column of loud buttons.
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Sig.blue.withValues(alpha: 0.12),
      ),
      child: const Icon(PhFill.paperPlaneTilt, color: Sig.blue, size: 19),
    ),
  );
}

class _NearbyRow extends StatelessWidget {
  const _NearbyRow({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final d = view.device;
    return SigCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          IconCircle(icon: kindIcon(d.kind), color: Sig.cyan, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name, style: sora(16, color: s.ink)),
                Text(
                  '${d.description} · ${d.shortId}',
                  style: TextStyle(fontSize: 12.5, color: s.muted),
                ),
              ],
            ),
          ),
          _PairPill(deviceId: d.id),
        ],
      ),
    );
  }
}

/// Pair: a small spinner beside it while the computer is asked, until its
/// code comes up (or a few seconds pass), so the tap is seen.
class _PairPill extends StatefulWidget {
  const _PairPill({required this.deviceId});

  final String deviceId;

  @override
  State<_PairPill> createState() => _PairPillState();
}

class _PairPillState extends State<_PairPill> {
  Timer? _asking;

  Future<void> _pair() async {
    setState(() {
      _asking = Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => _asking = null);
      });
    });
    final ok = await report(
      context,
      LinksyScope.read(context).pair(widget.deviceId),
    );
    if (!ok && mounted) {
      _asking?.cancel();
      setState(() => _asking = null);
    }
  }

  @override
  void dispose() {
    _asking?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asking = _asking != null;
    return Pressable(
      onTap: asking ? null : _pair,
      semanticLabel: context.l10n.homePair,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: Sig.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedSize(
          duration: motion(context, 180),
          curve: Curves.easeOutCubic,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asking) ...[
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Sig.blue,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                context.l10n.homePair,
                style: const TextStyle(
                  color: Sig.blue,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// No devices yet: how pairing works, in three steps, calm and centred.
class _GetStarted extends StatelessWidget {
  const _GetStarted();

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l10n = context.l10n;
    final steps = [l10n.homeStepOpen, l10n.homeStepChoose, l10n.homeStepScan];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: s.card, shape: BoxShape.circle),
            child: const LinksyMark(size: 50),
          ),
          const SizedBox(height: 22),
          Text(
            l10n.homeConnectTitle,
            textAlign: TextAlign.center,
            style: sora(
              24,
              weight: FontWeight.w700,
              color: s.ink,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeConnectSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: s.muted, height: 1.4),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: s.card,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Sig.blue.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: sora(
                              13,
                              weight: FontWeight.w700,
                              color: Sig.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            steps[i],
                            style: TextStyle(fontSize: 15, color: s.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Room for the island under the page. Before the first device, an arrow to
/// it too, if the page leaves enough: on a small phone, or under a card, it
/// would end up behind the island.
class _PageEnd extends StatelessWidget {
  const _PageEnd({required this.arrow});

  final bool arrow;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final room =
          constraints.viewportMainAxisExtent -
          constraints.precedingScrollExtent;
      return arrow && room >= _PointToAdd.needs(context)
          ? const SliverFillRemaining(
              hasScrollBody: false,
              child: _PointToAdd(),
            )
          : const SliverToBoxAdapter(child: SizedBox(height: 120));
    },
  );
}

/// Under the steps, an arrow down to the island's Add a device, where they
/// start. It fills what's left of the page over the pill.
class _PointToAdd extends StatefulWidget {
  const _PointToAdd();

  /// The pill's height with its margin, and the air left over it.
  static double over(BuildContext context) =>
      76 + 14 + MediaQuery.paddingOf(context).bottom;

  /// With the least arrow worth drawing.
  static double needs(BuildContext context) => over(context) + 110;

  @override
  State<_PointToAdd> createState() => _PointToAddState();
}

class _PointToAddState extends State<_PointToAdd>
    with SingleTickerProviderStateMixin {
  late final _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessReduced(context, _bob);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: _PointToAdd.over(context)),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _bob,
          builder: (_, child) {
            final there = 1 - (2 * _bob.value - 1).abs();
            return Transform.translate(
              offset: Offset(0, 6 * Curves.easeInOut.transform(there) - 6),
              child: child,
            );
          },
          child: const CustomPaint(
            painter: _ArrowPainter(Sig.blue),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// A dashed swoop from the right, straight down at its tip.
class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final height = math.min(size.height, 210.0);
    final top = size.height - height;
    final tip = Offset(size.width / 2, size.height);
    final from = size.width * 0.7;
    final line = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final swoop = Path()
      ..moveTo(from, top)
      ..cubicTo(
        from,
        top + height * 0.62,
        tip.dx,
        top + height * 0.34,
        tip.dx,
        tip.dy - 5,
      );
    for (final metric in swoop.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += 15) {
        final end = math.min(at + 7, metric.length);
        canvas.drawPath(metric.extractPath(at, end), line);
      }
    }
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - 10, tip.dy - 12)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + 10, tip.dy - 12),
      line
        ..color = color
        ..strokeWidth = 2.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

/// A quiet heading over a list, as in Settings: sentence case, no shouting.
class _Title extends StatelessWidget {
  const _Title(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: sora(
              16,
              weight: FontWeight.w700,
              color: Sig.of(context).ink,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
