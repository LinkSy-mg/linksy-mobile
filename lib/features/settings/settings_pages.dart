import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../news/whats_new.dart';
import '../onboarding/language_wheel.dart';
import '../permissions/permissions_sheet.dart';
import 'battery_guide.dart';
import 'phone_notifications.dart';
import 'settings_kit.dart';

/// The settings pages the hub opens.
enum SettingsArea { files, connection, computers, app }

extension SettingsAreaLook on SettingsArea {
  String title(AppLocalizations l) => switch (this) {
    SettingsArea.files => l.settingsFiles,
    SettingsArea.connection => l.settingsConnection,
    SettingsArea.computers => l.settingsWithYourComputers,
    SettingsArea.app => l.settingsThisApp,
  };

  IconData get icon => switch (this) {
    SettingsArea.files => Ph.folderSimple,
    SettingsArea.connection => Ph.wifiHigh,
    SettingsArea.computers => Ph.desktop,
    SettingsArea.app => Ph.gearSix,
  };
}

/// Opens [area]'s page, lighting up [highlight] (a search result) on it.
Future<void> openSettingsArea(
  BuildContext context,
  SettingsArea area, {
  String? highlight,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => switch (area) {
      SettingsArea.files => FilesSettings(highlight: highlight),
      SettingsArea.connection => ConnectionSettings(highlight: highlight),
      SettingsArea.computers => ComputersSettings(highlight: highlight),
      SettingsArea.app => AppSettings(highlight: highlight),
    },
  ),
);

/// A setting as search finds it: on which page, under which name.
class SettingsHit {
  const SettingsHit(this.id, this.area, this.icon, this.title, [this.terms]);

  final String id;

  /// Null: on the hub itself (Check for Updates, Logs).
  final SettingsArea? area;
  final IconData icon;
  final String title;
  final List<String>? terms;
}

/// Every setting, for the hub's search.
List<SettingsHit> settingsIndex(BuildContext context) {
  final l = context.l10n;
  return [
    SettingsHit(
      'save',
      SettingsArea.files,
      Ph.folderSimple,
      l.settingsSaveLocation,
      [l.settingsSaveLocationPath],
    ),
    SettingsHit(
      'accept',
      SettingsArea.files,
      Ph.shieldCheck,
      l.settingsAcceptFromMyDevices,
      [l.settingsAcceptFromMyDevicesCaption],
    ),
    SettingsHit(
      'browse',
      SettingsArea.files,
      Ph.folderOpen,
      l.settingsBrowseFiles,
      [l.settingsBrowseFilesChoose],
    ),
    SettingsHit(
      'gallery',
      SettingsArea.files,
      Ph.imagesSquare,
      l.settingsGallery,
      [l.settingsGalleryCaption],
    ),
    SettingsHit(
      'photos',
      SettingsArea.files,
      Ph.images,
      l.settingsPhotoFolder,
      [l.settingsPhotoFolderChoose],
    ),
    SettingsHit(
      'stay',
      SettingsArea.connection,
      Ph.lightning,
      l.settingsStayConnected,
      [l.settingsStayConnectedCaption],
    ),
    SettingsHit(
      'running',
      SettingsArea.connection,
      Ph.deviceMobile,
      l.settingsKeepRunning,
      [l.settingsKeepRunningCaption],
    ),
    SettingsHit(
      'battery',
      SettingsArea.connection,
      Ph.batteryCharging,
      l.batteryGuide,
      [l.batteryGuideCaption(makerName(LinksyScope.read(context).maker))],
    ),
    SettingsHit(
      'away',
      SettingsArea.connection,
      Ph.globeHemisphereWest,
      l.settingsAwayFromHome,
      [l.settingsAwayFromHomeCaption],
    ),
    SettingsHit('relay', SettingsArea.connection, Ph.network, l.settingsRelay, [
      l.settingsRelayDefault,
    ]),
    SettingsHit(
      'direct',
      SettingsArea.connection,
      Ph.arrowsLeftRight,
      l.settingsDirect,
      [l.settingsDirectCaption],
    ),
    SettingsHit(
      'picture',
      SettingsArea.computers,
      Ph.userCircle,
      l.settingsPicture,
      [l.settingsPictureChoose],
    ),
    SettingsHit(
      'notifications',
      SettingsArea.computers,
      Ph.bellRinging,
      l.settingsPhoneNotifications,
      [l.settingsPhoneNotificationsCaption],
    ),
    SettingsHit(
      'calls',
      SettingsArea.computers,
      Ph.phoneCall,
      l.settingsPauseMusic,
      [l.settingsPauseMusicCaption],
    ),
    SettingsHit(
      'media',
      SettingsArea.computers,
      Ph.musicNotes,
      l.settingsMediaNotice,
      [l.settingsMediaNoticeCaption],
    ),
    SettingsHit(
      'scroll',
      SettingsArea.computers,
      Ph.mouseSimple,
      l.settingsReverseScroll,
      [l.settingsReverseScrollCaption],
    ),
    SettingsHit('locate', SettingsArea.computers, Ph.mapPin, l.settingsLocate, [
      l.settingsLocateCaption,
    ]),
    SettingsHit(
      'appearance',
      SettingsArea.app,
      Ph.circleHalf,
      l.settingsAppearance,
      [l.settingsThemeSystem, l.settingsThemeLight, l.settingsThemeDark],
    ),
    SettingsHit(
      'motion',
      SettingsArea.app,
      Ph.personSimpleWalk,
      l.settingsReduceMotion,
      [l.settingsReduceMotionCaption],
    ),
    SettingsHit('language', SettingsArea.app, Ph.globe, l.settingsLanguage),
    SettingsHit('news', SettingsArea.app, Ph.sparkle, l.newsTitle),
    SettingsHit('update', null, Ph.arrowCircleUp, l.updateCheck),
    SettingsHit('logs', null, Ph.fileText, l.settingsLogs, [
      l.settingsLogsCaption,
    ]),
    SettingsHit(
      'permissions',
      SettingsArea.app,
      Ph.shieldCheck,
      l.settingsPermissionsRow,
      [l.settingsPermissions],
    ),
  ];
}

/// How each page is set now, in a line, for the hub.
String settingsSummary(BuildContext context, SettingsArea area) {
  final c = LinksyScope.of(context);
  final st = c.settings;
  final l = context.l10n;
  if (st == null) return '';
  final on = switch (area) {
    SettingsArea.files => [
      l.settingsSaveLocationPath,
      if (st.autoAccept) l.settingsAcceptFromMyDevices,
      if (c.sharingFiles && c.filesReady)
        c.filesAll ? l.settingsFilesAll : l.settingsBrowseFiles,
    ],
    SettingsArea.connection => [
      l.commonSameWifi,
      if (st.away) l.commonAwayFromHome,
      if (c.directOn) 'Wi-Fi Direct',
      if (st.stayConnected) l.settingsStayConnected,
    ],
    SettingsArea.computers => [
      if (c.mirroring) l.settingsPhoneNotifications,
      if (c.pauseOnCalls) l.settingsPauseMusic,
      if (c.mediaNotice) l.settingsMediaNotice,
      if (c.scrollReversed) l.settingsReverseScroll,
      if (c.locatable) l.settingsLocate,
    ],
    SettingsArea.app => [
      _languageName(c),
      switch (c.themeMode.value) {
        ThemeMode.light => l.settingsThemeLight,
        ThemeMode.dark => l.settingsThemeDark,
        ThemeMode.system => l.settingsThemeSystem,
      },
    ],
  };
  return on.join(' · ');
}

String _languageName(LinksyController c) => languages
    .firstWhere(
      (x) => x.code == c.locale.value.languageCode,
      orElse: () => languages.first,
    )
    .name;

Future<void> _update(BuildContext context, NodeSettings next) =>
    report(context, LinksyScope.read(context).updateSettings(next));

// Files.

class FilesSettings extends StatefulWidget {
  const FilesSettings({super.key, this.highlight});

  final String? highlight;

  @override
  State<FilesSettings> createState() => _FilesSettingsState();
}

class _FilesSettingsState extends State<FilesSettings>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from Android's All files access page.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LinksyScope.read(context).refreshFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final l = context.l10n;
    if (st == null) return const Scaffold(body: SizedBox.shrink());
    final sharing = c.sharingFiles && (c.filesAll || c.filesFolder != null);
    return SettingsPage(
      title: l.settingsFiles,
      backLabel: l.settingsTitle,
      highlight: widget.highlight,
      children: [
        SettingsCard(
          id: 'save',
          label: l.settingsSaveLocation,
          child: _Path(l.settingsSaveLocationPath),
        ),
        SettingsSection(
          title: l.settingsReceiving,
          children: [
            SettingRow(
              id: 'accept',
              icon: Ph.shieldCheck,
              title: l.settingsAcceptFromMyDevices,
              caption: l.settingsAcceptFromMyDevicesCaption,
              trailing: Switch(
                value: st.autoAccept,
                onChanged: (v) => _update(context, st.copyWith(autoAccept: v)),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: l.settingsWithYourComputers,
          children: [
            SettingRow(
              id: 'browse',
              icon: Ph.folderOpen,
              title: l.settingsBrowseFiles,
              caption: sharing ? null : l.settingsBrowseFilesChoose,
              trailing: Switch(
                value: sharing,
                onChanged: (v) => v && !c.filesAll && c.filesFolder == null
                    ? c.pickFilesFolder()
                    : c.setSharingFiles(v),
              ),
            ),
            // What they browse: one folder, or everything.
            SubOptions(
              open: sharing,
              children: [
                _Choice(
                  selected: !c.filesAll,
                  icon: Ph.folderSimple,
                  title: l.settingsFilesFolder,
                  caption: c.filesFolder,
                  onTap: () => !c.filesAll || c.filesFolder == null
                      ? c.pickFilesFolder()
                      : c.setFilesAll(false),
                ),
                if (c.allFiles != 'unsupported')
                  _Choice(
                    selected: c.filesAll,
                    icon: Ph.files,
                    title: l.settingsFilesAll,
                    caption: c.allFiles == 'allowed'
                        ? l.settingsFilesAllCaption
                        : l.settingsFilesAllAllow,
                    onTap: () => c.setFilesAll(true),
                  ),
              ],
            ),
            SettingRow(
              id: 'gallery',
              icon: Ph.imagesSquare,
              title: l.settingsGallery,
              caption: l.settingsGalleryCaption,
              trailing: Switch(
                value: c.gallery,
                onChanged: (v) async {
                  final on = await c.setGallery(v);
                  if (v && !on && context.mounted) {
                    showMessage(context, l.settingsGalleryDenied);
                  }
                },
              ),
            ),
            SettingRow(
              id: 'photos',
              icon: Ph.images,
              title: l.settingsPhotoFolder,
              caption: c.photosFolder == null
                  ? l.settingsPhotoFolderChoose
                  : l.settingsPhotoFolderBacksUp(c.photosFolder!),
              onTap: c.pickPhotosFolder,
            ),
          ],
        ),
      ],
    );
  }
}

/// One of a few choices: a row with a round mark on the right.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
    this.caption,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SettingRow(
      icon: icon,
      title: title,
      caption: caption,
      onTap: onTap,
      trailing: AnimatedContainer(
        duration: motion(context, 150),
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selected ? Sig.blue : s.faint, width: 2),
        ),
        child: AnimatedScale(
          scale: selected ? 1 : 0,
          duration: motion(context, 150),
          curve: Curves.easeOut,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Sig.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Downloads › Linksy" as the folders it is.
class _Path extends StatelessWidget {
  const _Path(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final parts = path.split('›').map((p) => p.trim()).toList();
    return Row(
      children: [
        const IconCircle(
          icon: Ph.downloadSimple,
          color: Sig.cyan,
          size: 52,
          filled: true,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (i > 0) Icon(Ph.caretRight, color: s.faint, size: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: s.raised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Ph.folderSimple, color: Sig.blue, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        parts[i],
                        style: TextStyle(
                          color: s.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Connection.

class ConnectionSettings extends StatelessWidget {
  const ConnectionSettings({super.key, this.highlight});

  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final l = context.l10n;
    if (st == null) return const Scaffold(body: SizedBox.shrink());
    return SettingsPage(
      title: l.settingsConnection,
      backLabel: l.settingsTitle,
      highlight: highlight,
      children: [
        SettingsCard(
          id: 'ways',
          label: l.settingsWays,
          child: _Ways(
            ways: [
              (Ph.wifiHigh, l.commonSameWifi, true),
              (Ph.globeHemisphereWest, l.commonAwayFromHome, st.away),
              (Ph.arrowsLeftRight, 'Wi-Fi Direct', c.directOn),
              (Ph.usb, l.commonUsbCable, true),
            ],
          ),
        ),
        SettingsSection(
          children: [
            SettingRow(
              id: 'stay',
              icon: Ph.lightning,
              title: l.settingsStayConnected,
              caption: l.settingsStayConnectedCaption,
              trailing: Switch(
                value: st.stayConnected,
                onChanged: (v) =>
                    _update(context, st.copyWith(stayConnected: v)),
              ),
            ),
            SettingRow(
              id: 'running',
              icon: Ph.deviceMobile,
              title: l.settingsKeepRunning,
              caption: l.settingsKeepRunningCaption,
              trailing: Switch(
                value: c.stayRunning,
                onChanged: c.setStayRunning,
              ),
            ),
            SettingRow(
              id: 'battery',
              icon: Ph.batteryCharging,
              title: l.batteryGuide,
              caption: l.batteryGuideCaption(makerName(c.maker)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BatteryGuide()),
              ),
            ),
          ],
        ),
        SettingsSection(
          children: [
            SettingRow(
              id: 'away',
              icon: Ph.globeHemisphereWest,
              title: l.settingsAwayFromHome,
              caption: l.settingsAwayFromHomeCaption,
              trailing: Switch(
                value: st.away,
                onChanged: (v) => _update(context, st.copyWith(away: v)),
              ),
            ),
            // Self-hosting: a relay of the user's own (linksy-server).
            SubOptions(
              open: st.away,
              children: [
                SettingRow(
                  id: 'relay',
                  icon: Ph.network,
                  title: l.settingsRelay,
                  caption: st.relay ?? l.settingsRelayDefault,
                  onTap: () async {
                    final relay = await askRelay(context, st.relay);
                    // Null: dismissed. Empty: back to Linksy's own.
                    if (relay == null || relay == (st.relay ?? '')) return;
                    if (!context.mounted) return;
                    await _update(
                      context,
                      st.copyWith(relay: relay.isEmpty ? null : relay),
                    );
                  },
                ),
              ],
            ),
            // Direct links (§4.17) for big transfers.
            SettingRow(
              id: 'direct',
              icon: Ph.arrowsLeftRight,
              title: l.settingsDirect,
              caption: l.settingsDirectCaption,
              trailing: Switch(value: c.directOn, onChanged: c.setDirectOn),
            ),
          ],
        ),
      ],
    );
  }
}

/// The ways this phone reaches its computers, as a list: what's on is
/// dark with a cyan dot, what's off is faint. Nothing here is a button.
class _Ways extends StatelessWidget {
  const _Ways({required this.ways});

  final List<(IconData, String, bool)> ways;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - 20) / 2;
        return Wrap(
          spacing: 20,
          runSpacing: 14,
          children: [
            for (final (icon, label, on) in ways)
              SizedBox(
                width: width,
                child: Row(
                  children: [
                    Icon(icon, size: 19, color: on ? Sig.blue : s.faint),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: on ? s.ink : s.faint,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: on ? Sig.cyan : s.line,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// With your computers.

class ComputersSettings extends StatelessWidget {
  const ComputersSettings({super.key, this.highlight});

  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final l = context.l10n;
    final s = Sig.of(context);
    if (st == null) return const Scaffold(body: SizedBox.shrink());
    final picture = c.ownPicture;
    return SettingsPage(
      title: l.settingsWithYourComputers,
      backLabel: l.settingsTitle,
      highlight: highlight,
      children: [
        // This phone as its computers show it.
        SettingsCard(
          id: 'picture',
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
                        ? const Center(child: LinksyMark(size: 38))
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
                          st.name,
                          style: sora(
                            20,
                            weight: FontWeight.w700,
                            color: s.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.settingsThisPhone(c.node.info.shortId),
                          style: TextStyle(color: s.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                picture == null
                    ? l.settingsPictureChoose
                    : l.settingsPictureChange,
                style: TextStyle(color: s.muted, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SettingsPill(
                      icon: Ph.images,
                      label: l.settingsPicture,
                      onTap: c.pickOwnPicture,
                    ),
                  ),
                  if (picture != null) ...[
                    const SizedBox(width: 10),
                    SettingsPill(
                      label: l.settingsPictureRemove,
                      onTap: c.removeOwnPicture,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        SettingsSection(
          children: [
            SettingRow(
              id: 'notifications',
              icon: Ph.bellRinging,
              title: l.settingsPhoneNotifications,
              caption: c.notificationAccessMissing
                  ? l.settingsPhoneNotificationsAllow
                  : l.settingsPhoneNotificationsCaption,
              warn: c.notificationAccessMissing,
              onTap: c.notificationAccessMissing
                  ? () => allowPhoneNotifications(context)
                  : null,
              trailing: Switch(
                value: c.mirroring,
                onChanged: (v) => v
                    ? allowPhoneNotifications(context)
                    : c.setPhoneNotifications(false),
              ),
            ),
            SettingRow(
              id: 'calls',
              icon: Ph.phoneCall,
              title: l.settingsPauseMusic,
              caption: l.settingsPauseMusicCaption,
              trailing: Switch(
                value: c.pauseOnCalls,
                onChanged: c.setPauseOnCalls,
              ),
            ),
            SettingRow(
              id: 'media',
              icon: Ph.musicNotes,
              title: l.settingsMediaNotice,
              caption: l.settingsMediaNoticeCaption,
              trailing: Switch(
                value: c.mediaNotice,
                onChanged: c.setMediaNotice,
              ),
            ),
            SettingRow(
              id: 'scroll',
              icon: Ph.mouseSimple,
              title: l.settingsReverseScroll,
              caption: l.settingsReverseScrollCaption,
              trailing: Switch(
                value: c.scrollReversed,
                onChanged: c.setScrollReversed,
              ),
            ),
            SettingRow(
              id: 'locate',
              icon: Ph.mapPin,
              title: l.settingsLocate,
              caption: l.settingsLocateCaption,
              trailing: Switch(
                value: c.locatable,
                onChanged: (v) async {
                  final ok = await c.setLocatable(v);
                  if (!ok && context.mounted) {
                    showMessage(context, context.l10n.settingsLocatePermission);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// This app.

class AppSettings extends StatelessWidget {
  const AppSettings({super.key, this.highlight});

  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    return SettingsPage(
      title: l.settingsThisApp,
      backLabel: l.settingsTitle,
      highlight: highlight,
      children: [
        SettingsCard(
          id: 'appearance',
          label: l.settingsAppearance,
          child: const _Themes(),
        ),
        SettingsSection(
          children: [
            SettingRow(
              id: 'motion',
              icon: Ph.personSimpleWalk,
              title: l.settingsReduceMotion,
              caption: l.settingsReduceMotionCaption,
              trailing: Switch(
                value: c.reduceMotion.value,
                onChanged: c.setReduceMotion,
              ),
            ),
            SettingRow(
              id: 'language',
              icon: Ph.globe,
              title: l.settingsLanguage,
              caption: _languageName(c),
              onTap: () => showLanguagePicker(context),
            ),
          ],
        ),
        SettingsSection(
          title: l.settingsPermissions,
          children: const [_Permissions()],
        ),
        const SettingsCard(id: 'news', child: _About()),
      ],
    );
  }
}

/// System, light and dark as small screens to pick from.
class _Themes extends StatelessWidget {
  const _Themes();

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final s = Sig.of(context);
    final l = context.l10n;
    return ValueListenableBuilder(
      valueListenable: c.themeMode,
      builder: (context, mode, _) => Row(
        children: [
          for (final (i, (m, icon, label)) in [
            (ThemeMode.system, Ph.deviceMobile, l.settingsThemeSystem),
            (ThemeMode.light, Ph.sun, l.settingsThemeLight),
            (ThemeMode.dark, Ph.moon, l.settingsThemeDark),
          ].indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Pressable(
                onTap: () => c.setThemeMode(m),
                semanticLabel: label,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: motion(context, 180),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: m == mode ? Sig.blue : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.62,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: switch (m) {
                            ThemeMode.light => const _Mini(Sig.light),
                            ThemeMode.dark => const _Mini(Sig.dark),
                            ThemeMode.system => const Row(
                              children: [
                                Expanded(
                                  child: _Mini(
                                    Sig.light,
                                    half: Alignment.centerLeft,
                                  ),
                                ),
                                Expanded(
                                  child: _Mini(
                                    Sig.dark,
                                    half: Alignment.centerRight,
                                  ),
                                ),
                              ],
                            ),
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: m == mode ? 1 : 0),
                      duration: motion(context, 180),
                      builder: (context, on, _) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 15,
                            color: Color.lerp(s.muted, Sig.blue, on),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color.lerp(s.muted, s.ink, on),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A home screen in miniature, in [look]'s colours; [half]: only that half
/// of it (the system tile shows light beside dark).
class _Mini extends StatelessWidget {
  const _Mini(this.look, {this.half});

  final Sig look;
  final Alignment? half;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, Color color, [double height = 5]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
    );
    Widget screen(double width) => Container(
      width: width,
      color: look.bg,
      padding: const EdgeInsets.fromLTRB(9, 12, 9, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Sig.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              bar(26, look.ink.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < 2; i++) ...[
            Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: look.card,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == 0 ? Sig.cyan : Sig.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: bar(30, look.muted.withValues(alpha: 0.5), 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
          const Spacer(),
          Center(child: bar(36, Sig.blue, 10)),
        ],
      ),
    );
    final half = this.half;
    if (half == null) {
      return LayoutBuilder(builder: (_, box) => screen(box.maxWidth));
    }
    // Half of a full-width screen: laid out at twice the width, clipped.
    return LayoutBuilder(
      builder: (_, box) => ClipRect(
        child: OverflowBox(
          alignment: half,
          minWidth: box.maxWidth * 2,
          maxWidth: box.maxWidth * 2,
          child: screen(box.maxWidth * 2),
        ),
      ),
    );
  }
}

/// Linksy, its version, What's New and Check for Updates.
class _About extends StatefulWidget {
  const _About();

  @override
  State<_About> createState() => _AboutState();
}

class _AboutState extends State<_About> {
  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppIcon(size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linksy',
                    style: sora(20, weight: FontWeight.w700, color: s.ink),
                  ),
                  FutureBuilder<String?>(
                    future: LinksyPlatform.appVersion(),
                    builder: (context, v) => Text(
                      v.data ?? '',
                      style: TextStyle(color: s.muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsPill(
          icon: Ph.sparkle,
          label: l.newsTitle,
          onTap: () async {
            final v = (await LinksyPlatform.appVersion())?.split(' ').first;
            if (v == null || !context.mounted) return;
            await showWhatsNew(context, v, highlights(v));
          },
        ),
      ],
    );
  }
}

/// How many of Linksy's permissions are allowed; opens the sheet that asks
/// Android for the rest. Read again on return.
class _Permissions extends StatefulWidget {
  const _Permissions();

  @override
  State<_Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<_Permissions>
    with WidgetsBindingObserver {
  int? _allowed;

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
    final p = await LinksyPlatform.permissions();
    if (!mounted || p == null) return;
    setState(
      () => _allowed = [p.notifications, p.camera].where((x) => x).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SettingRow(
      id: 'permissions',
      icon: Ph.shieldCheck,
      title: l.settingsPermissionsRow,
      caption: switch (_allowed) {
        null => l.settingsPermissionsWhat,
        2 => l.settingsPermissionsBoth,
        final n => l.settingsPermissionsSome(n),
      },
      onTap: () async {
        await showPermissions(context);
        await _read();
      },
    );
  }
}

/// A rounded button on a settings card.
class SettingsPill extends StatelessWidget {
  const SettingsPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.busy = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: s.raised,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (icon case final icon?)
              Icon(icon, color: Sig.blue, size: 17),
            if (busy || icon != null) const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: s.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This phone's name, as its computers show it.
Future<String?> askPhoneName(BuildContext context, String current) =>
    askSettingText(
      context,
      current: current,
      title: (l) => l.settingsNameTitle,
      caption: (l) => l.settingsNameCaption,
      maxLength: 48,
    );

/// The relay's address; empty means Linksy's own. The core checks it.
Future<String?> askRelay(BuildContext context, String? current) =>
    askSettingText(
      context,
      current: current ?? '',
      title: (l) => l.settingsRelay,
      caption: (l) => l.settingsRelayCaption,
      hint: 'https://relay.example.com',
      keyboardType: TextInputType.url,
    );

/// One line of text, in a sheet from the bottom; null when dismissed.
Future<String?> askSettingText(
  BuildContext context, {
  required String current,
  required String Function(AppLocalizations) title,
  required String Function(AppLocalizations) caption,
  int? maxLength,
  String? hint,
  TextInputType? keyboardType,
}) {
  final text = TextEditingController(text: current);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) {
      final s = Sig.of(sheet);
      return Padding(
        // Above the keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title(sheet.l10n),
                  style: sora(22, weight: FontWeight.w700, color: s.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  caption(sheet.l10n),
                  style: TextStyle(color: s.muted, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: s.raised,
                    borderRadius: BorderRadius.circular(Radii.md + 2),
                  ),
                  child: TextField(
                    controller: text,
                    autofocus: true,
                    maxLength: maxLength,
                    keyboardType: keyboardType,
                    autocorrect: keyboardType == null,
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      hintText: hint,
                      hintStyle: TextStyle(color: s.faint),
                    ),
                    style: sora(18, weight: FontWeight.w500, color: s.ink),
                    onSubmitted: (v) => Navigator.of(sheet).pop(v.trim()),
                  ),
                ),
                const SizedBox(height: 16),
                SigButton(
                  label: sheet.l10n.settingsSave,
                  expand: true,
                  onTap: () => Navigator.of(sheet).pop(text.text.trim()),
                ),
                SigButton(
                  label: sheet.l10n.settingsCancel,
                  kind: SigButtonKind.quiet,
                  expand: true,
                  onTap: () => Navigator.of(sheet).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(text.dispose);
}
