import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../app/terminals.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../deck/deck_screen.dart';
import '../remote/remote_screen.dart';
import '../terminal/terminal_screen.dart';

/// The pages that drive one computer, which the switcher goes between.
enum DevicePage { remote, deck, terminal }

/// The pages [d] has: the remote always, the deck and the terminal when it
/// announces them.
List<DevicePage> devicePages(DeviceInfo d) => [
  DevicePage.remote,
  if (d.can('deck')) DevicePage.deck,
  if (d.can('terminal')) DevicePage.terminal,
];

/// Goes from [current] to another of the computer's pages, like tabs: the
/// page is replaced, not stacked, and what it had open stays (the remote a
/// minute, terminals until they're closed), so coming back doesn't ask the
/// computer again.
class PageSwitchButton extends StatelessWidget {
  const PageSwitchButton({
    super.key,
    required this.deviceId,
    required this.current,
    this.color,
    this.size = 44,
    this.round = true,
  });

  final String deviceId;
  final DevicePage current;

  /// The icon's colour on a page with its own look (the deck, the terminal).
  final Color? color;
  final double size;

  /// A [RoundButton], or the bare icon the deck's header uses.
  final bool round;

  @override
  Widget build(BuildContext context) {
    final d = LinksyScope.of(context).device(deviceId)?.device;
    if (d == null || devicePages(d).length < 2) return const SizedBox.shrink();
    final label = context.l10n.switchTitle;
    void open() => switchPage(context, d, current);
    if (round) {
      return RoundButton(icon: Ph.cards, tooltip: label, onTap: open);
    }
    return Pressable(
      onTap: open,
      scale: 0.9,
      semanticLabel: label,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Ph.cards, color: color, size: 22),
      ),
    );
  }
}

Future<void> switchPage(
  BuildContext context,
  DeviceInfo d,
  DevicePage current,
) async {
  final picked = await showModalBottomSheet<DevicePage>(
    context: context,
    showDragHandle: true,
    builder: (_) => _Sheet(device: d, current: current),
  );
  if (picked == null || picked == current || !context.mounted) return;
  final Widget page = switch (picked) {
    DevicePage.remote => RemoteScreen(device: d),
    DevicePage.deck => DeckScreen(device: d),
    DevicePage.terminal => TerminalScreen(deviceId: d.id),
  };
  await Navigator.of(context)
      .pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.device, required this.current});

  final DeviceInfo device;
  final DevicePage current;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final terminals = c.terminals
        .of(device.id)
        .where((t) => t.state != TabState.ended)
        .length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text(
                l.switchTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: s.ink,
                ),
              ),
            ),
            for (final page in devicePages(device))
              _Row(
                icon: switch (page) {
                  DevicePage.remote => Ph.mouseSimple,
                  DevicePage.deck => Ph.squaresFour,
                  DevicePage.terminal => Ph.terminalWindow,
                },
                title: switch (page) {
                  DevicePage.remote => l.deviceRemote,
                  DevicePage.deck => l.deviceDeck,
                  DevicePage.terminal => l.deviceTerminal,
                },
                state: page == current
                    ? l.switchHere
                    : switch (page) {
                        DevicePage.remote
                            when c.remotes.containsKey(device.id) =>
                          l.switchOpen,
                        DevicePage.terminal when terminals > 0 =>
                          l.deviceTerminalsOpen(terminals),
                        _ => null,
                      },
                here: page == current,
                onTap: () => Navigator.of(context).pop(page),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.state,
    required this.here,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? state;
  final bool here;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      semanticLabel: title,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: here ? s.raised : null,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: here ? Sig.blue : s.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: here ? Sig.blue : s.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, color: s.ink),
              ),
            ),
            if (state != null) ...[
              if (!here) ...[
                const PulseDot(color: Sig.cyan, size: 6),
                const SizedBox(width: 6),
              ],
              Text(
                state!,
                style: TextStyle(
                  fontSize: 13,
                  color: here ? Sig.blue : s.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
