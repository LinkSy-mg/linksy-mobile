import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../settings/settings_kit.dart';
import '../settings/settings_pages.dart' show SettingsPill;

/// One device's settings, behind the gear on its page: its picture, what it
/// gets from this phone, and Forget.
class DeviceSettings extends StatelessWidget {
  const DeviceSettings({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final view = c.device(deviceId);
    if (view == null || !view.trusted) {
      // Forgotten while open.
      return const Scaffold(body: SizedBox.shrink());
    }
    final d = view.device;
    final l10n = context.l10n;
    final s = Sig.of(context);
    final picture = c.pictureOf(d.id);
    final computer =
        d.kind == DeviceKind.desktop || d.kind == DeviceKind.laptop;
    final photos = c.backsUpPhotos(d.id);
    final at = c.photosBackedUp(d.id);
    final declined = photos && c.photosDeclined(d.id);
    return SettingsPage(
      title: l10n.settingsTitle,
      backLabel: d.name,
      children: [
        // The device as this phone shows it.
        SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.raised,
                    ),
                    child: picture == null
                        ? Icon(kindIcon(d.kind), color: Sig.blue, size: 32)
                        : Image.file(
                            File(picture),
                            key: ValueKey(c.pictureVersion),
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: sora(
                            20,
                            weight: FontWeight.w700,
                            color: s.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            d.description,
                            l10n.deviceShortId(d.shortId),
                          ].where((e) => e.isNotEmpty).join(' · '),
                          style: TextStyle(color: s.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SettingsPill(
                      icon: Ph.images,
                      label: picture == null
                          ? l10n.deviceAddPicture
                          : l10n.deviceChangePicture,
                      onTap: () => c.pickPicture(d.id),
                    ),
                  ),
                  if (picture != null) ...[
                    const SizedBox(width: 10),
                    SettingsPill(
                      label: l10n.settingsPictureRemove,
                      onTap: () => c.removePicture(d.id),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (computer)
          SettingsSection(
            children: [
              SettingRow(
                icon: Ph.images,
                title: l10n.deviceBackUpPhotos,
                caption: !photos
                    ? l10n.devicePhotosGoTo(d.name)
                    : declined
                    ? l10n.devicePhotosDeclined(d.name)
                    : [
                        if (c.photosFolder case final folder?)
                          l10n.devicePhotosFrom(folder)
                        else
                          l10n.devicePhotosFromCamera,
                        if (at != null) l10n.devicePhotosLast(formatClock(at)),
                      ].join(' · '),
                warn: declined,
                trailing: Switch(
                  value: photos,
                  onChanged: (v) => c.setPhotoBackup(d.id, v),
                ),
              ),
              if (d.features.contains('clipboard_watch'))
                SettingRow(
                  icon: Ph.clipboard,
                  title: l10n.deviceGetClipboard,
                  caption: l10n.deviceGetClipboardDetail(d.name),
                  trailing: Switch(
                    value: c.watchesClipboard(d.id),
                    onChanged: (v) => c.setClipboardWatch(d.id, v),
                  ),
                ),
              SettingRow(
                icon: Ph.globeHemisphereWest,
                title: l10n.deviceAwayAll,
                caption: view.awayAll
                    ? l10n.deviceAwayAllOn
                    : l10n.deviceAwayAllOff,
                trailing: Switch(
                  value: view.awayAll,
                  onChanged: (v) => report(context, c.setAwayAll(d.id, v)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        Pressable(
          onTap: () => _forget(context, d),
          semanticLabel: l10n.deviceForgetThis,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: s.card,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Ph.linkBreak, color: s.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.deviceForgetThis,
                  style: TextStyle(
                    color: s.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _forget(BuildContext context, DeviceInfo d) async {
    final c = LinksyScope.read(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) {
        final s = Sig.of(dialog);
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: IconCircle(icon: Ph.linkBreak, color: s.red, size: 56),
                ),
                const SizedBox(height: 16),
                Text(
                  dialog.l10n.deviceForgetTitle(d.name),
                  textAlign: TextAlign.center,
                  style: sora(21, color: s.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  dialog.l10n.deviceForgetBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.muted, height: 1.4),
                ),
                const SizedBox(height: 24),
                SigButton(
                  label: dialog.l10n.deviceForget,
                  kind: SigButtonKind.danger,
                  expand: true,
                  onTap: () => Navigator.of(dialog).pop(true),
                ),
                SigButton(
                  label: dialog.l10n.deviceCancel,
                  kind: SigButtonKind.quiet,
                  expand: true,
                  onTap: () => Navigator.of(dialog).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok != true || !context.mounted) return;
    // Out of this page and the device's, back home.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await c.forget(d.id);
  }
}
