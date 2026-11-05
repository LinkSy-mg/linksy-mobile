import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// Turns on this phone's notifications on its computers (§4.5). On Android
/// 13 and up, the steps for a switch Android greys out come first: most
/// people install Linksy from the web. Before that, Android's Notification
/// access page, then the steps if it came back still not allowed.
Future<void> allowPhoneNotifications(BuildContext context) async {
  final c = LinksyScope.read(context);
  await c.setPhoneNotifications(true);
  if (c.notificationAccess) return;
  if (c.sdk < 33 &&
      !c.notificationAccessAsked &&
      await c.askNotificationAccess()) {
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AccessGuide(restricted: c.sdk >= 33),
  );
}

/// How to allow Notification access. On Android 13 and up, apps installed
/// from the web find the switch greyed out until App info › ⋮ › Allow
/// restricted settings, and that ⋮ only appears once the greyed-out switch
/// was tapped and Android refused.
class _AccessGuide extends StatefulWidget {
  const _AccessGuide({required this.restricted});

  final bool restricted;

  @override
  State<_AccessGuide> createState() => _AccessGuideState();
}

class _AccessGuideState extends State<_AccessGuide> {
  bool _closed = false;

  /// Allowed, from here or straight in Android's settings: nothing left to do.
  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final c = LinksyScope.of(context);
    final restricted = widget.restricted;
    if (c.notificationAccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }
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
                l.noticeAccessStepSwitch,
                l.noticeAccessStepInfo,
                l.noticeAccessStepRestricted,
                l.noticeAccessStepAgain,
              ]),
            ],
            const SizedBox(height: 22),
            SigButton(
              label: restricted ? l.noticeAccessOpen : l.remoteTryAgain,
              icon: Ph.bellRinging,
              expand: true,
              onTap: () async {
                if (await c.askNotificationAccess()) _close();
              },
            ),
            if (restricted) ...[
              const SizedBox(height: 10),
              SigButton(
                label: l.commonOpenAppInfo,
                icon: Ph.gearSix,
                kind: SigButtonKind.secondary,
                expand: true,
                onTap: LinksyPlatform.openAppInfo,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
