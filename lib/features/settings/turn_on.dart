import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'phone_notifications.dart';

/// Turns on what a computer's tab needs, the same way from the setup page,
/// the home card and a computer's ask: `notifications` for its Inbox,
/// `gallery` for its Gallery.
Future<void> turnOn(BuildContext context, String feature) => switch (feature) {
  'notifications' => allowPhoneNotifications(context),
  'gallery' => allowGallery(context),
  _ => Future<void>.value(),
};

/// Computers may look through the photos: Android asks first. Refused, the
/// way to allow it; Android won't ask a third time.
Future<void> allowGallery(BuildContext context) async {
  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  if (await LinksyScope.read(context).setGallery(true)) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l.settingsGalleryDenied),
        action: SnackBarAction(
          label: l.commonOpenAppInfo,
          onPressed: LinksyPlatform.openAppInfo,
        ),
      ),
    );
}

/// A computer's "Ask the Phone": Turn On runs the same flow as the setup
/// page, Not now leaves everything as it is.
Future<void> askTurnOn(
  BuildContext context,
  String computer,
  String feature,
) async {
  final go = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) {
      final s = Sig.of(sheet);
      final l = sheet.l10n;
      final messages = feature == 'notifications';
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: IconCircle(
                  icon: messages ? Ph.chatCircleText : Ph.imagesSquare,
                  color: Sig.blue,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                messages
                    ? l.turnOnAskMessages(computer)
                    : l.turnOnAskPhotos(computer),
                textAlign: TextAlign.center,
                style: sora(21, color: s.ink),
              ),
              const SizedBox(height: 8),
              Text(
                messages
                    ? l.onboardingMessagesDetail
                    : l.onboardingGalleryDetail,
                textAlign: TextAlign.center,
                style: TextStyle(color: s.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              SigButton(
                label: l.turnOnNow,
                expand: true,
                onTap: () => Navigator.of(sheet).pop(true),
              ),
              SigButton(
                label: l.commonNotNow,
                kind: SigButtonKind.quiet,
                expand: true,
                onTap: () => Navigator.of(sheet).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (go == true && context.mounted) await turnOn(context, feature);
}
