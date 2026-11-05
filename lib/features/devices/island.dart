import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/platform.dart';
import '../../core/models.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/device_screen.dart';
import '../pairing/pairing_flows.dart';
import '../transfer/transfer_bubble.dart';
import 'phased_size.dart';

/// What the island shows when it's open.
enum _Open { transfers, send, add }

/// Home's bottom pill, which grows in place into a card instead of opening a
/// sheet: Transfers (what's moving, or what moved last), Send files (which
/// device), Add a device (how). Tapping outside or Back shrinks it back.
///
/// The pill: Transfers on the left; with devices, Send files in the middle
/// and Add on the right; before the first one, Add a device in the middle
/// and Send on the right.
class Island extends StatefulWidget {
  const Island({super.key, required this.paired});

  final List<DeviceView> paired;

  @override
  State<Island> createState() => _IslandState();
}

class _IslandState extends State<Island> with SingleTickerProviderStateMixin {
  _Open? _open;

  static const _growFor = Duration(milliseconds: 460);
  static const _shrinkFor = Duration(milliseconds: 470);

  // At once when motion is reduced.
  Duration get _grow => motion(context, _growFor.inMilliseconds);
  Duration get _shrink => motion(context, _shrinkFor.inMilliseconds);

  // Out fast and settle softly, both ways at once.
  static const _growCurve = Cubic(0.16, 1, 0.3, 1);

  // Back in two steps: down to the pill's height first; when that's half
  // done, in to its width, with a small bounce at the end.
  static const _shrinkHeight = Interval(0, 0.6, curve: Cubic(0.3, 0, 0.2, 1));
  static const _shrinkWidth = Interval(0.3, 1, curve: Curves.easeOutBack);
  static const _shrinkCurve = Interval(0, 0.6, curve: Curves.easeOut);

  void _show(_Open what) {
    HapticFeedback.lightImpact();
    if (what == _Open.add) LinksyScope.read(context).node.pairingMode(true);
    setState(() => _open = what);
  }

  void _close() {
    HapticFeedback.selectionClick();
    if (_open == _Open.add) LinksyScope.read(context).node.pairingMode(false);
    setState(() => _open = null);
  }

  /// Shrinks, then runs [then] once the pill is back.
  void _closeThen(void Function() then) {
    _close();
    Future<void>.delayed(_shrink, () {
      if (mounted) then();
    });
  }

  @override
  void dispose() {
    if (_open == _Open.add) {
      LinksyScope.read(context).node.pairingMode(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final open = _open != null;
    final width = MediaQuery.sizeOf(context).width;
    final duration = open ? _grow : _shrink;
    final curve = open ? _growCurve : _shrinkCurve;
    // Back closes the card. Else, on the home screen, it leaves Linksy running
    // as Home does: finishing would end Flutter but not the core, and files
    // would go on arriving with nobody to move them, list them or say so.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popped, _) {
        if (popped) return;
        open ? _close() : LinksyPlatform.toBackground();
      },
      child: Stack(
        children: [
          // The page dims behind the open card; a tap there closes it.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !open,
              child: GestureDetector(
                onTap: _close,
                child: AnimatedOpacity(
                  opacity: open ? 1 : 0,
                  duration: duration,
                  curve: curve,
                  child: ColoredBox(color: s.ink.withValues(alpha: 0.18)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: AnimatedContainer(
                duration: duration,
                curve: curve,
                decoration: BoxDecoration(
                  color: s.card,
                  borderRadius: BorderRadius.circular(open ? 30 : 99),
                  border: Border.all(color: s.ink.withValues(alpha: 0.04)),
                  // Wide and barely there; a little more once it's a card.
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A1024)
                          .withValues(alpha: open ? 0.06 : 0.02),
                      blurRadius: 40,
                      spreadRadius: 4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: PhasedSize(
                  vsync: this,
                  grow: _grow,
                  growCurve: _growCurve,
                  shrink: _shrink,
                  shrinkWidth: _shrinkWidth,
                  shrinkHeight: _shrinkHeight,
                  child: AnimatedSwitcher(
                    // Closing, as long as the island's own shrink, so the
                    // pill comes back with it.
                    duration: open ? motion(context, 340) : _shrink,
                    // Only what's coming sets the size, so the island starts
                    // moving at once; what's leaving keeps its own size,
                    // clipped, while it fades.
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        for (final p in previous)
                          Positioned.fill(
                            child: OverflowBox(
                              alignment: Alignment.bottomCenter,
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                              child: p,
                            ),
                          ),
                        ?current,
                      ],
                    ),
                    // The old leaves in the first half, the new comes in the
                    // second: they never show together. The pill's content
                    // never shows inside the card: opening, it's gone in a
                    // frame or two; closing, it comes back in the bounce,
                    // once the island is the pill's size again.
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: child.key == const ValueKey('pill')
                            ? Interval(open ? 0.98 : 0.85, 1)
                            : const Interval(0.5, 1, curve: Curves.easeOut),
                      ),
                      child: ScaleTransition(
                        scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                    child: switch (_open) {
                      null => _Pill(
                        key: const ValueKey('pill'),
                        paired: widget.paired,
                        onOpen: _show,
                      ),
                      final what => SizedBox(
                        key: ValueKey(what),
                        width: (width - 24).clamp(0, 520),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          child: switch (what) {
                            _Open.transfers => TransfersPeek(
                              onMore: () =>
                                  _closeThen(() => openTransfers(context)),
                            ),
                            _Open.send => _SendPanel(
                              paired: widget.paired,
                              onPick: (id) =>
                                  _closeThen(() => pickAndSend(context, id)),
                              onAdd: () => setState(() {
                                LinksyScope.read(context).node
                                    .pairingMode(true);
                                _open = _Open.add;
                              }),
                            ),
                            _Open.add => _AddPanel(
                              onScan: () =>
                                  _closeThen(() => scanAndPair(context)),
                              onAddress: () =>
                                  _closeThen(() => pairByAddress(context)),
                            ),
                          },
                        ),
                      ),
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The closed island: three parts in one pill.
class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.paired, required this.onOpen});

  final List<DeviceView> paired;
  final void Function(_Open) onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final none = paired.isEmpty;
    // While files move the left part widens: the middle drops its icon.
    final moving = LinksyScope.of(context).liveTransfers.isNotEmpty;
    final pill = Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransfersButton(onTap: () => onOpen(_Open.transfers)),
          const SizedBox(width: 4),
          SigButton(
            label: none ? l.homeAddDevice : l.homeSendFiles,
            icon: moving
                ? null
                : none
                ? PhBold.qrCode
                : PhFill.paperPlaneTilt,
            height: 52,
            onTap: () => onOpen(none ? _Open.add : _Open.send),
          ),
          const SizedBox(width: 4),
          _Round(
            icon: none ? PhFill.paperPlaneTilt : PhBold.plus,
            label: none ? l.homeSendFiles : l.homeAddDevice,
            onTap: () => onOpen(none ? _Open.send : _Open.add),
          ),
        ],
      ),
    );
    // Long labels on a narrow phone: smaller, never cut.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32,
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: pill),
    );
  }
}

/// An icon-only part of the pill.
class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Pressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: label,
      child: SizedBox.square(
        dimension: 52,
        child: Icon(icon, size: 21, color: Sig.of(context).ink),
      ),
    ),
  );
}

/// The title of an open island.
class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
    child: Text(text, style: sora(20, color: Sig.of(context).ink)),
  );
}

/// Send files: which device. None yet: say so, and offer to add one.
class _SendPanel extends StatelessWidget {
  const _SendPanel({
    required this.paired,
    required this.onPick,
    required this.onAdd,
  });

  final List<DeviceView> paired;
  final void Function(String id) onPick;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l.homeSendFiles),
        if (paired.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: Text(
              l.shareSheetNoComputers,
              style: TextStyle(fontSize: 14, height: 1.4, color: s.muted),
            ),
          ),
          SigButton(
            label: l.homeAddDevice,
            icon: PhBold.qrCode,
            expand: true,
            onTap: onAdd,
          ),
        ] else
          for (final v in paired)
            Pressable(
              onTap: () => onPick(v.device.id),
              semanticLabel: v.device.name,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.ink.withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        kindIcon(v.device.kind),
                        size: 18,
                        color: s.ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        v.device.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: s.ink,
                        ),
                      ),
                    ),
                    Icon(PhFill.paperPlaneTilt, size: 18, color: Sig.blue),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

/// Add a device: scan its code, or type its address.
class _AddPanel extends StatelessWidget {
  const _AddPanel({required this.onScan, required this.onAddress});

  final VoidCallback onScan;
  final VoidCallback onAddress;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l.pairingAddDevice),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Text(
            l.pairingAddDeviceHint,
            style: TextStyle(fontSize: 14, height: 1.4, color: s.muted),
          ),
        ),
        SheetOption(
          icon: PhBold.scan,
          title: l.pairingScanQr,
          caption: l.pairingScanQrCaption,
          primary: true,
          onTap: onScan,
        ),
        const SizedBox(height: 10),
        SheetOption(
          icon: Ph.network,
          title: l.pairingByAddress,
          caption: l.pairingByAddressCaption,
          onTap: onAddress,
        ),
      ],
    );
  }
}
