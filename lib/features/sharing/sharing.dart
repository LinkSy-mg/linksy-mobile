import 'package:flutter/material.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'webcam_screen.dart';

/// "Studio Desktop wants to see your screen": Allow leads on to Android's own
/// prompt (screen capture or camera permission).
class SessionRequestDialog extends StatelessWidget {
  const SessionRequestDialog({super.key, required this.request});

  final SessionRequest request;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final name = request.from.name;
    final (icon, title, detail) = switch (request.kind) {
      SessionKind.screen => (
        Ph.screencast,
        l.sharingScreenRequestTitle(name),
        l.sharingScreenRequestDetail(name),
      ),
      SessionKind.control => (
        Ph.cursorClick,
        l.sharingControlRequestTitle(name),
        l.sharingControlRequestDetail(name),
      ),
      SessionKind.camera => (
        Ph.videoCamera,
        l.sharingCameraRequestTitle(name),
        l.sharingCameraRequestDetail(name),
      ),
      SessionKind.input => (
        Ph.mouseSimple,
        l.sharingInputRequestTitle(name),
        l.sharingInputRequestDetail,
      ),
      SessionKind.microphone => (
        Ph.microphone,
        l.sharingMicrophoneRequestTitle(name),
        l.sharingMicrophoneRequestDetail(name),
      ),
      SessionKind.display => (
        Ph.monitor,
        l.sharingDisplayRequestTitle(name),
        l.sharingDisplayRequestDetail(name),
      ),
    };
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: IconCircle(icon: icon, color: Sig.blue, size: 64),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: sora(21, color: s.ink, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(color: s.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            SigButton(
              label: l.sharingAllow,
              expand: true,
              onTap: () => _answer(context, true),
            ),
            SigButton(
              label: l.sharingDontAllow,
              kind: SigButtonKind.quiet,
              expand: true,
              onTap: () => _answer(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _answer(BuildContext context, bool accept) async {
    final c = LinksyScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    final error = await c.respondSession(request, accept: accept);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

/// Live shares at the top of home, each with Stop.
class SharingBanners extends StatelessWidget {
  const SharingBanners({
    super.key,
    required this.controller,
    this.deviceId,
    this.kinds,
  });

  final LinksyController controller;

  /// Only the shares with this device (its page), else all (home).
  final String? deviceId;

  /// Only these kinds (a computer's page shows its webcam and microphone in
  /// its own card).
  final Set<SessionKind>? kinds;

  @override
  Widget build(BuildContext context) {
    final shares = controller.sharing.values
        .where((s) => deviceId == null || s.peer.id == deviceId)
        .where((s) => kinds == null || kinds!.contains(s.kind))
        .toList();
    // Banners come and go: the page makes room, and closes up.
    return AnimatedSize(
      duration: motion(context, 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: shares.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  for (final share in shares) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Banner(share: share, controller: controller),
                    ),
                    if ((share.kind == SessionKind.screen ||
                            share.kind == SessionKind.control) &&
                        controller.warnShareProtections)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProtectionHint(controller: controller),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Stop on a banner: dims with a small spinner until the share has ended.
class _Stop extends StatefulWidget {
  const _Stop({required this.onStop});

  final Future<void> Function() onStop;

  @override
  State<_Stop> createState() => _StopState();
}

class _StopState extends State<_Stop> {
  bool _stopping = false;

  Future<void> _stop() async {
    setState(() => _stopping = true);
    try {
      await widget.onStop();
    } finally {
      // Still here: it didn't end, so it can be tried again.
      if (mounted) setState(() => _stopping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnimatedOpacity(
      opacity: _stopping ? 0.7 : 1,
      duration: motion(context, 150),
      child: Pressable(
        onTap: _stopping ? null : _stop,
        semanticLabel: l.sharingStopSharing,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
          ),
          child: AnimatedSize(
            duration: motion(context, 150),
            child: AnimatedSwitcher(
              duration: motion(context, 150),
              child: _stopping
                  ? const SizedBox.square(
                      key: ValueKey(true),
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Sig.deep,
                      ),
                    )
                  : Text(
                      l.sharingStop,
                      key: const ValueKey(false),
                      style: const TextStyle(
                        color: Sig.deep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Android 15 hides parts of the screen from screen sharing; some phones
/// (realme, among others) black out the whole status bar and notification
/// shade. A developer option turns that off.
class _ProtectionHint extends StatelessWidget {
  const _ProtectionHint({required this.controller});

  final LinksyController controller;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SigCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Ph.warningCircle, color: Sig.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.sharingProtectionHint,
                  style: TextStyle(fontSize: 13, color: s.muted, height: 1.35),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallAction(
                label: context.l10n.sharingGotIt,
                onTap: controller.dismissShareHint,
              ),
              SmallAction(
                label: context.l10n.sharingDeveloperOptions,
                onTap: LinksyPlatform.developerOptions,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.share, required this.controller});

  final SessionStarted share;
  final LinksyController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = share.peer.name;
    final (icon, text) = switch (share.kind) {
      SessionKind.control => (Ph.cursorClick, l.sharingControlling(name)),
      SessionKind.camera => (Ph.videoCamera, l.sharingUsingCamera(name)),
      SessionKind.microphone => (Ph.microphone, l.sharingUsingMicrophone(name)),
      _ => (Ph.screencast, l.sharingScreenWith(name)),
    };
    final banner = Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: Sig.blue,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          const PulseDot(color: Sig.cyanLight, size: 8),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                if (share.kind == SessionKind.camera)
                  Text(
                    l.sharingTapForCameraControls,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (share.kind == SessionKind.camera) ...[
            Tooltip(
              message: l.sharingSwitchCamera,
              child: Pressable(
                onTap: () => controller.switchCamera(share.session),
                semanticLabel: l.sharingSwitchCamera,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Sig.deep,
                  ),
                  child: const Icon(
                    Ph.cameraRotate,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          _Stop(onStop: () => controller.stopSharing(share.session)),
        ],
      ),
    );
    // A webcam's banner opens its controls.
    if (share.kind != SessionKind.camera) return banner;
    return Pressable(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => WebcamScreen(share: share)),
      ),
      semanticLabel: l.sharingCameraControls,
      child: banner,
    );
  }
}
