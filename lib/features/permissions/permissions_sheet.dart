import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// What Linksy asks Android for, why, and a button that brings up Android's
/// own dialog (or, for remote control, its settings page). Re-reads when the
/// user comes back from Android's settings.
Future<void> showPermissions(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PermissionsSheet(),
    );

class _PermissionsSheet extends StatefulWidget {
  const _PermissionsSheet();

  @override
  State<_PermissionsSheet> createState() => _PermissionsSheetState();
}

class _PermissionsSheetState extends State<_PermissionsSheet>
    with WidgetsBindingObserver {
  ({bool notifications, bool camera})? _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _read();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    final state = await LinksyPlatform.permissions();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _request(String name) async {
    await LinksyPlatform.requestPermission(name);
    await _read();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final state = _state;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.permissionsTitle, style: sora(24, color: s.ink)),
            const SizedBox(height: 6),
            Text(
              context.l10n.permissionsIntro,
              style: TextStyle(color: s.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            _Permission(
              icon: Ph.bellRinging,
              title: context.l10n.permissionsNotifications,
              why: context.l10n.permissionsNotificationsWhy,
              allowed: state?.notifications,
              action: context.l10n.permissionsAllow,
              onTap: () => _request('notifications'),
            ),
            const SizedBox(height: 10),
            _Permission(
              icon: Ph.videoCamera,
              title: context.l10n.permissionsCamera,
              why: context.l10n.permissionsCameraWhy,
              allowed: state?.camera,
              action: context.l10n.permissionsAllow,
              onTap: () => _request('camera'),
            ),
            const SizedBox(height: 20),
            SigButton(
              label: context.l10n.permissionsDone,
              kind: SigButtonKind.secondary,
              expand: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Permission extends StatelessWidget {
  const _Permission({
    required this.icon,
    required this.title,
    required this.why,
    required this.allowed,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String why;
  final bool? allowed;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SigCard(
      color: s.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconCircle(icon: icon, color: Sig.blue, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: sora(16, color: s.ink)),
                const SizedBox(height: 4),
                Text(
                  why,
                  style: TextStyle(fontSize: 13, color: s.muted, height: 1.4),
                ),
                const SizedBox(height: 12),
                // Allow turns into Allowed when it comes back granted.
                AnimatedSwitcher(
                  duration: motion(context),
                  transitionBuilder: popIn,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: allowed == true
                      ? SizedBox(
                          key: const ValueKey(true),
                          height: 40,
                          child: Row(
                            children: [
                              const Icon(
                                PhBold.check,
                                size: 16,
                                color: Sig.blue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.permissionsAllowed,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: s.ink,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Align(
                          key: const ValueKey(false),
                          alignment: Alignment.centerLeft,
                          child: SigButton(
                            label: action,
                            height: 40,
                            onTap: allowed == null ? null : onTap,
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
