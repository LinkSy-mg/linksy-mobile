import 'package:flutter/material.dart';

import '../../app/app_update.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/updates.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// "Linksy X Is Available": what changed, the APK it installs, and Update
/// Now filling with its progress.
Future<void> showUpdate(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => const _UpdateSheet(),
);

/// The APK's own id: the update is always the regular app.
const _package = 'app.linksy.mg';

class _UpdateSheet extends StatelessWidget {
  const _UpdateSheet();

  @override
  Widget build(BuildContext context) {
    final u = LinksyScope.read(context).updates;
    final s = Sig.of(context);
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: u,
      builder: (context, _) {
        final release = u.available;
        if (release == null) return const SizedBox.shrink();
        final busy =
            u.phase == UpdatePhase.downloading ||
            u.phase == UpdatePhase.installing;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: s.raised,
                      shape: BoxShape.circle,
                    ),
                    child: const LinksyMark(size: 52),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.updateAvailable(release.version),
                    style: sora(22, weight: FontWeight.w700, color: s.ink),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.updateBody(u.installed ?? ''),
                    style: TextStyle(color: s.muted, fontSize: 14, height: 1.4),
                  ),
                  if (release.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Card(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updateWhatChanged(release.version),
                            style: sora(
                              18,
                              weight: FontWeight.w700,
                              color: s.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * 0.28,
                            ),
                            child: SingleChildScrollView(
                              child: _Notes(release.notes),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      l10n.updateToInstall,
                      style: TextStyle(
                        color: s.faint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Apk(release: release, installed: u.installed),
                  if (u.phase == UpdatePhase.failed) ...[
                    const SizedBox(height: 12),
                    Text(
                      _failure(l10n, u.failure),
                      style: TextStyle(color: s.red, fontSize: 13, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _Pill(
                    primary: true,
                    progress: u.phase == UpdatePhase.downloading
                        ? u.progress
                        : null,
                    label: switch (u.phase) {
                      UpdatePhase.downloading => l10n.updateDownloading(
                        '${(u.progress * 100).round()}',
                      ),
                      UpdatePhase.installing => l10n.updateInstalling,
                      _ => l10n.updateNow,
                    },
                    onTap: busy ? null : u.run,
                  ),
                  if (release.page.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _Pill(
                      label: l10n.newsAllChanges(release.version),
                      onTap: () => LinksyPlatform.openUrl(release.page),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _Pill(
                    label: l10n.updateLater,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _failure(AppLocalizations l10n, String? reason) =>
      switch (reason) {
        'network' => l10n.updateFailedNetwork,
        'bad_sum' || 'unlisted' => l10n.updateFailedCheck,
        'allow' => l10n.updateAllow,
        _ => l10n.updateFailedInstall(reason ?? ''),
      };
}

/// A rounded surface a step up from the sheet.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Sig.of(context).raised,
      borderRadius: BorderRadius.circular(Radii.md + 2),
    ),
    child: child,
  );
}

/// The release notes, read as a list: their headings ("Fixed") small above
/// their points, each point after a dot; Markdown's marks left out.
class _Notes extends StatelessWidget {
  const _Notes(this.notes);

  final String notes;

  static String _plain(String line) => line
      .replaceAll(RegExp(r'\*\*|__|`'), '')
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1]!)
      .trim();

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final children = <Widget>[];
    for (final raw in notes.split('\n')) {
      if (raw.trim().isEmpty) continue;
      if (RegExp(r'^\s*#+\s*').hasMatch(raw)) {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 4 : 12, bottom: 2),
            child: Text(
              _plain(raw.replaceFirst(RegExp(r'^\s*#+\s*'), '')),
              style: TextStyle(
                color: s.muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      } else if (RegExp(r'^\s*[-*]\s+').hasMatch(raw)) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 8, right: 10, left: 2),
                  decoration: const BoxDecoration(
                    color: Sig.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    _plain(raw.replaceFirst(RegExp(r'^\s*[-*]\s+'), '')),
                    style: TextStyle(color: s.ink, fontSize: 14, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _plain(raw),
              style: TextStyle(color: s.muted, fontSize: 14, height: 1.45),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// The file Update Now installs: its name, the app's id, and the step from
/// this version to the new one.
class _Apk extends StatelessWidget {
  const _Apk({required this.release, required this.installed});

  final AppRelease release;
  final String? installed;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return _Card(
      child: Row(
        children: [
          const AppIcon(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: LinksyPlatform.abi(),
                  builder: (context, abi) => Text(
                    release.apkName(abi.data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: s.ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    _package,
                    if (installed case final v?) '$v → ${release.version}',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: s.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tall rounded button. The [primary] one is blue and fills from the left
/// with [progress] while it downloads.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.progress,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final p = progress;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Opacity(
        opacity: onTap == null && p == null ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: primary ? Sig.blue : s.raised,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (p != null)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: p.clamp(0.0, 1.0),
                    child: const ColoredBox(color: Sig.deep),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: primary ? Colors.white : s.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
