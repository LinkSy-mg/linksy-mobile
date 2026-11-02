import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// Turns on this phone's notifications on its computers (§4.5): Android's
/// Notification access page the first time; after that, or when it came
/// back still not allowed, the steps for a switch Android greys out.
Future<void> allowPhoneNotifications(BuildContext context) async {
  final c = LinksyScope.read(context);
  await c.setPhoneNotifications(true);
  if (c.notificationAccess) return;
  if (!c.notificationAccessAsked && await c.askNotificationAccess()) return;
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AccessGuide(restricted: c.sdk >= 33),
  );
}

/// How to allow Notification access. On Android 13 and up, apps installed
/// from the web find the switch greyed out until App info › ⋮ › Allow
/// restricted settings.
class _AccessGuide extends StatelessWidget {
  const _AccessGuide({required this.restricted});

  final bool restricted;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final c = LinksyScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.noticeAccessTitle, style: sora(24, color: s.ink)),
            const SizedBox(height: 8),
            Text(
              restricted ? l.noticeAccessGreyed : l.noticeAccessPlain,
              style: TextStyle(color: s.muted, fontSize: 14.5, height: 1.4),
            ),
            if (restricted) ...[
              const SizedBox(height: 18),
              NumberedSteps([
                l.noticeAccessStepInfo,
                l.noticeAccessStepRestricted,
                l.noticeAccessStepAgain,
              ]),
            ],
            const SizedBox(height: 22),
            if (restricted) ...[
              SigButton(
                label: l.commonOpenAppInfo,
                icon: Ph.gearSix,
                expand: true,
                onTap: LinksyPlatform.openAppInfo,
              ),
              const SizedBox(height: 10),
            ],
            SigButton(
              label: l.remoteTryAgain,
              icon: Ph.bellRinging,
              kind: restricted
                  ? SigButtonKind.secondary
                  : SigButtonKind.primary,
              expand: true,
              onTap: () async {
                if (await c.askNotificationAccess() && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
