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
import '../pairing/pairing_flows.dart';
import '../sharing/sharing.dart';
import '../settings/settings_screen.dart';
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
                  child: SectionLabel(
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
                  child: SectionLabel(context.l10n.homeNearbyNotPaired),
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
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 20, 0),
      child: Row(
        children: [
          const PulseDot(color: Sig.cyan, size: 7),
          const SizedBox(width: 2),
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
    if (cards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          for (final card in cards)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: card),
        ],
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
    this.onDismiss,
  });

  final IconData icon;
  final bool warning;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
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
                if (action != null)
                  TextButton(onPressed: onAction, child: Text(action!)),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: context.l10n.commonDismiss,
              onPressed: onDismiss,
              icon: Icon(Ph.x, size: 18, color: s.faint),
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
                    Text(
                      linkWords(view),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: away ? s.faint : _linkColor(s),
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
                if (transferring) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    color: last.incoming ? Sig.incoming : Sig.outgoing,
                    value: last.total == 0 || last.bytes == 0
                        ? null
                        : last.bytes / last.total,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (away)
            Icon(Ph.caretRight, color: s.faint, size: 18)
          else
            _QuickSend(deviceId: d.id),
        ],
      ),
    );
  }
}

/// Cyan text that still reads on white (the brand cyan is too light).
Color _linkColor(Sig s) =>
    s.bg.computeLuminance() > 0.5 ? const Color(0xFF0E8FAE) : Sig.cyanLight;

/// Send files without opening the device first.
class _QuickSend extends StatelessWidget {
  const _QuickSend({required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => pickAndSend(context, deviceId),
    scale: 0.88,
    semanticLabel: context.l10n.homeSendFiles,
    child: Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Sig.blue),
      child: const Icon(PhFill.paperPlaneTilt, color: Colors.white, size: 19),
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
          IconCircle(icon: kindIcon(d.kind), color: Sig.cyan, size: 46),
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
          SigButton(
            label: context.l10n.homePair,
            height: 40,
            kind: SigButtonKind.secondary,
            onTap: () => report(context, LinksyScope.read(context).pair(d.id)),
          ),
        ],
      ),
    );
  }
}

/// No devices yet: how pairing works, in three steps.
class _GetStarted extends StatelessWidget {
  const _GetStarted();

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l10n = context.l10n;
    final steps = [
      (l10n.homeStepOpen, Ph.desktop),
      (l10n.homeStepChoose, Ph.qrCode),
      (l10n.homeStepScan, Ph.scan),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.homeConnectTitle,
              style: sora(
                30,
                weight: FontWeight.w700,
                color: s.ink,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.homeConnectSubtitle,
              style: TextStyle(fontSize: 15, color: s.muted),
            ),
          ),
          const SizedBox(height: 20),
          SigCard(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Sig.blue.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: sora(
                              14,
                              weight: FontWeight.w700,
                              color: Sig.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            steps[i].$1,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: s.ink,
                            ),
                          ),
                        ),
                        Icon(steps[i].$2, color: s.faint, size: 22),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SigButton(
            label: l10n.homeScanQr,
            icon: PhBold.scan,
            expand: true,
            height: 58,
            onTap: () => scanAndPair(context),
          ),
          const SizedBox(height: 4),
          SigButton(
            label: l10n.homePairByAddress,
            kind: SigButtonKind.quiet,
            expand: true,
            onTap: () => pairByAddress(context),
          ),
        ],
      ),
    );
  }
}
