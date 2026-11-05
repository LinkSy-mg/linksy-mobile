import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'shelves.dart';

/// Apps from another phone, arrived: Install asks Android for each, which
/// shows its own confirmation. Not now lets go of their files.
class InstallSheet extends StatefulWidget {
  const InstallSheet({super.key, required this.offer});

  final AppsReceived offer;

  @override
  State<InstallSheet> createState() => _InstallSheetState();
}

class _InstallSheetState extends State<InstallSheet>
    with WidgetsBindingObserver {
  /// Android lets Linksy install apps; null until known.
  bool? _allowed;

  /// Sent to Android's page: back from it, carry on by itself.
  bool _waiting = false;

  /// What each app is to this phone: `none` is new.
  var _here = const <String, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _read();
    LinksyPlatform.preflightFacts([
      for (final a in widget.offer.apps)
        AppProbe(
          package: a.info.package,
          versionCode: a.info.versionCode,
          signer: a.info.signer ?? '',
        ).toJson(),
    ]).then((facts) {
      if (!mounted) return;
      setState(() {
        _here = {
          for (final a in (facts['apps'] as List? ?? const []).cast<Map>())
            a['package'] as String: a['have'] as String,
        };
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _read() async {
    final allowed = await LinksyPlatform.updatesAllowed();
    if (!mounted) return;
    setState(() => _allowed = allowed);
    if (allowed && _waiting) _finish(install: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  void _finish({required bool install}) {
    LinksyScope.read(context).finishApps(widget.offer, install: install);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final offer = widget.offer;
    final allowed = _allowed;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.phoneInstallAsk(offer.apps.length, offer.from.name),
              style: sora(22, color: s.ink, height: 1.2),
            ),
            const SizedBox(height: 14),
            for (final a in offer.apps)
              AppLine(
                info: a.info,
                mark: switch (_here[a.info.package]) {
                  'none' => l.phoneAppNew,
                  'older' => l.phoneAppUpdateShort,
                  _ => null,
                },
              ),
            const SizedBox(height: 8),
            Text(
              l.phoneAppsNote,
              style: TextStyle(fontSize: 13.5, height: 1.35, color: s.muted),
            ),
            if (allowed == false) ...[
              const SizedBox(height: 10),
              Text(
                l.phoneInstallAllowBody,
                style: TextStyle(fontSize: 14, height: 1.35, color: s.ink),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SigButton(
                    label: l.commonNotNow,
                    kind: SigButtonKind.secondary,
                    expand: true,
                    height: 56,
                    onTap: () => _finish(install: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SigButton(
                    label: allowed == false
                        ? l.phoneInstallAllow
                        : l.phoneInstall,
                    icon: PhBold.downloadSimple,
                    expand: true,
                    height: 56,
                    onTap: allowed == null
                        ? null
                        : () {
                            if (allowed) return _finish(install: true);
                            _waiting = true;
                            LinksyPlatform.allowUpdates();
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// An app in an offer: its icon, name and version, and [mark] when known.
class AppLine extends StatelessWidget {
  const AppLine({super.key, required this.info, this.mark});

  final AppInfo info;
  final String? mark;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final icon = info.icon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SigCard(
        color: s.bg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Squircle(
              size: 40,
              child: icon == null
                  ? const Icon(Ph.squaresFour, color: Sig.incoming)
                  : Image.memory(
                      base64Decode(icon),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Ph.squaresFour),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, color: s.ink),
                  ),
                  if (info.versionName case final v?)
                    Text(v, style: TextStyle(fontSize: 13, color: s.muted)),
                ],
              ),
            ),
            if (mark case final m?)
              Text(
                m,
                style: sora(13, weight: FontWeight.w500, color: Sig.blue),
              ),
          ],
        ),
      ),
    );
  }
}
