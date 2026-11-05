import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'selection.dart';
import 'send_flow.dart';

/// "Direct link · about 40 s". Say "about": the number is a guess.
String routeLine(SendPlan plan) {
  final l = tr;
  final seconds = plan.seconds;
  return [
    switch (plan.goes) {
      'direct' => l.routeDirect,
      'away' => l.routeAway,
      'usb' => l.routeUsb,
      _ => l.routeLan,
    },
    // Too quick to be worth a guess.
    if (seconds != null && seconds >= 3) l.routeAbout(_span(seconds)),
  ].join(' · ');
}

String _span(int seconds) {
  if (seconds < 90) return '$seconds s';
  final minutes = (seconds / 60).round();
  if (minutes < 90) return '$minutes min';
  return '${(minutes / 60).round()} h';
}

/// One sentence for each warning.
String warningText(SendWarning w, String name, int bytes) => switch (w) {
  NoRoom(:final free) => tr.warnNoRoom(
    name,
    formatBytes(free),
    formatBytes(bytes),
  ),
  WillAsk() => tr.warnWillAsk(name),
  CantInstall() => tr.warnCantInstall(name),
};

/// What's chosen, how it would go, what to know, and Send, floating over the
/// page under the thumb. Nothing at all until something is chosen.
class SendBar extends StatefulWidget {
  const SendBar({
    super.key,
    required this.flow,
    required this.name,
    this.onSent,
  });

  final SendFlow flow;
  final String name;

  /// After a send that went, to close what's open.
  final VoidCallback? onSent;

  /// What to leave free under a list so nothing ends up behind the bar.
  static const room = 110.0;

  @override
  State<SendBar> createState() => _SendBarState();
}

class _SendBarState extends State<SendBar> {
  /// Asking the other phone, then offering: one Send at a time.
  bool _sending = false;

  SendFlow get flow => widget.flow;
  String get name => widget.name;

  Future<void> _send(BuildContext context) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await _go(context);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _go(BuildContext context) async {
    final chosen = flow.selection;
    if (!await flow.check() || !context.mounted) return;
    if (asksFirst(flow.plan, chosen.bytes)) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.mobileDataTitle),
          content: Text(context.l10n.mobileDataAsk(formatBytes(chosen.bytes))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.commonNotNow),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.phoneSend),
            ),
          ],
        ),
      );
      if (go != true) return;
    }
    final failed = await flow.send();
    if (!context.mounted) return;
    if (failed != null) return showMessage(context, failed);
    widget.onSent?.call();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([flow, flow.selection]),
    builder: (context, _) {
      final l = context.l10n;
      final chosen = flow.selection;
      final warnings = flow.warnings;
      return AnimatedSize(
        duration: motion(context, 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: chosen.isEmpty
            ? const SizedBox(width: double.infinity)
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (warnings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Warnings(
                            warnings: warnings,
                            name: name,
                            bytes: chosen.bytes,
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Sig.blue,
                          // The Send button's radius plus the space around
                          // it, so the two curves run together.
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 3),
                              color: Color(0x261438B8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 11, 11, 11),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.phoneSelected(
                                        chosen.count,
                                        formatBytes(chosen.bytes),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: sora(15, color: Colors.white),
                                    ),
                                    if (flow.plan case final plan?)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          routeLine(plan),
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xE0FFFFFF),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Pressable(
                                onTap: chosen.clear,
                                semanticLabel: l.phoneClear,
                                child: const SizedBox.square(
                                  dimension: 44,
                                  child: Icon(
                                    Ph.x,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Opacity(
                                opacity: flow.blocked || _sending ? 0.55 : 1,
                                child: Pressable(
                                  onTap: flow.blocked || _sending
                                      ? null
                                      : () => _send(context),
                                  semanticLabel: l.phoneSendTo(name),
                                  child: Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(23),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l.phoneSend,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Sig.deep,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          PhFill.paperPlaneTilt,
                                          size: 16,
                                          color: Sig.deep,
                                        ),
                                      ],
                                    ),
                                  ),
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
      );
    },
  );
}

class _Warnings extends StatelessWidget {
  const _Warnings({
    required this.warnings,
    required this.name,
    required this.bytes,
  });

  final List<SendWarning> warnings;
  final String name;
  final int bytes;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x140A1024))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, w) in warnings.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1, right: 7),
                    child: Icon(
                      Ph.warningCircle,
                      size: 16,
                      color: w is NoRoom ? s.red : s.muted,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      [
                        warningText(w, name, bytes),
                        if (w is CantInstall) l.warnCantInstallHow(name),
                      ].join('\n'),
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: w is NoRoom ? s.red : s.ink,
                      ),
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
