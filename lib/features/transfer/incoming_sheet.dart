import 'package:flutter/material.dart';

import '../../app/activity.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../phones/install_sheet.dart';

/// "Studio Desktop is sending you 3 files": names, sizes, Accept / Decline.
class IncomingFilesSheet extends StatelessWidget {
  const IncomingFilesSheet({super.key, required this.request});

  final TransferRequest request;

  static const _shown = 4;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    // Answered from the notification: nothing left to ask here.
    final c = LinksyScope.of(context);
    final entry = c
        .activityFor(request.from.id)
        .where((a) => a.id == request.transfer)
        .firstOrNull;
    if (entry != null && entry.status != ActivityStatus.waiting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = ModalRoute.of(context);
        if (context.mounted && route != null && route.isActive) {
          // On top, it slides away as usual; under something, it just goes.
          if (route.isCurrent) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).removeRoute(route);
          }
        }
      });
    }
    final apps = request.apps;
    final files = request.plainFiles.toList();
    final l10n = context.l10n;
    // The sender's name in ink, the rest of the sentence muted.
    final name = request.from.name;
    final sentence = apps.isNotEmpty
        ? l10n.phoneInstallAsk(apps.length, name)
        : l10n.incomingSendingYou(name, files.length);
    final at = name.isEmpty ? -1 : sentence.indexOf(name);
    final muted = TextStyle(color: s.muted);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Orb(
                  device: request.from,
                  size: 56,
                  picture: c.pictureOf(request.from.id),
                ),
                const SizedBox(width: 6),
                const Icon(PhBold.arrowRight, color: Sig.incoming, size: 18),
                const SizedBox(width: 6),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Sig.incoming.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Ph.deviceMobile,
                    color: Sig.incoming,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                children: at < 0
                    ? [TextSpan(text: sentence, style: muted)]
                    : [
                        if (at > 0)
                          TextSpan(
                            text: sentence.substring(0, at),
                            style: muted,
                          ),
                        TextSpan(text: name),
                        TextSpan(
                          text: sentence.substring(at + name.length),
                          style: muted,
                        ),
                      ],
              ),
              style: sora(23, color: s.ink, height: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.incomingTotal(formatBytes(request.total)),
              style: TextStyle(fontSize: 14, color: s.muted),
            ),
            const SizedBox(height: 18),
            for (final a in apps.take(_shown)) AppLine(info: a),
            if (apps.length > _shown)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.incomingMore(apps.length - _shown),
                  style: TextStyle(color: s.muted),
                ),
              ),
            for (final f in files.take(_shown))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SigCard(
                  color: s.bg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(fileIcon(f.name), color: Sig.incoming, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: s.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatBytes(f.size),
                        style: sora(
                          13,
                          weight: FontWeight.w500,
                          color: s.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (files.length > _shown)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.incomingMore(files.length - _shown),
                  style: TextStyle(color: s.muted),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SigButton(
                    label: l10n.commonDecline,
                    kind: SigButtonKind.secondary,
                    expand: true,
                    height: 56,
                    onTap: () => _answer(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SigButton(
                    label: l10n.incomingAccept,
                    icon: PhBold.downloadSimple,
                    expand: true,
                    height: 56,
                    onTap: () => _answer(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _answer(BuildContext context, bool accept) async {
    final c = LinksyScope.read(context);
    Navigator.of(context).pop();
    await c.respond(request.transfer, accept: accept);
  }
}
