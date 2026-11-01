import 'dart:io';

import 'package:flutter/material.dart';

import '../onboarding/language_wheel.dart';
import '../../ui/l10n.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/demo_node.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../news/whats_new.dart';
import 'logs_screen.dart';
import '../permissions/permissions_sheet.dart';
import '../update/update_sheet.dart';
import '../../ui/sig.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final s = Sig.of(context);
    final demo = c.node is DemoNode ? c.node as DemoNode : null;

    Future<void> update(NodeSettings next) =>
        report(context, c.updateSettings(next));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: st == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  Row(
                    children: [
                      RoundButton(
                        icon: Ph.arrowLeft,
                        tooltip: context.l10n.settingsBack,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
                    child: Text(
                      context.l10n.settingsTitle,
                      style: sora(34, weight: FontWeight.w700, color: s.ink),
                    ),
                  ),
                  _ThisPhone(
                    name: st.name,
                    shortId: c.node.info.shortId,
                    picture: c.ownPicture,
                    pictureVersion: c.pictureVersion,
                    onRename: () async {
                      final name = await _askName(context, st.name);
                      if (name != null && name.isNotEmpty && name != st.name) {
                        await update(st.copyWith(name: name));
                      }
                    },
                  ),
                  SectionLabel(context.l10n.settingsReceiving),
                  _Group(
                    children: [
                      _Row(
                        icon: Ph.folderSimple,
                        title: context.l10n.settingsSaveLocation,
                        // Files land in the app's folder, then move to
                        // Downloads (Android 10+).
                        caption: context.l10n.settingsSaveLocationPath,
                      ),
                      _Row(
                        icon: Ph.shieldCheck,
                        title: context.l10n.settingsAcceptFromMyDevices,
                        caption:
                            context.l10n.settingsAcceptFromMyDevicesCaption,
                        trailing: Switch(
                          value: st.autoAccept,
                          onChanged: (v) => update(st.copyWith(autoAccept: v)),
                        ),
                      ),
                    ],
                  ),
                  SectionLabel(context.l10n.settingsConnection),
                  _Group(
                    children: [
                      _Row(
                        icon: Ph.lightning,
                        title: context.l10n.settingsStayConnected,
                        caption: context.l10n.settingsStayConnectedCaption,
                        trailing: Switch(
                          value: st.stayConnected,
                          onChanged: (v) =>
                              update(st.copyWith(stayConnected: v)),
                        ),
                      ),
                      _Row(
                        icon: Ph.deviceMobile,
                        title: context.l10n.settingsKeepRunning,
                        caption: context.l10n.settingsKeepRunningCaption,
                        trailing: Switch(
                          value: c.stayRunning,
                          onChanged: c.setStayRunning,
                        ),
                      ),
                      _Row(
                        icon: Ph.globeHemisphereWest,
                        title: context.l10n.settingsAwayFromHome,
                        caption: context.l10n.settingsAwayFromHomeCaption,
                        trailing: Switch(
                          value: st.away,
                          onChanged: (v) => update(st.copyWith(away: v)),
                        ),
                      ),
                      // Direct links (§4.17) for big transfers
                      _Row(
                        icon: Ph.arrowsLeftRight,
                        title: context.l10n.settingsDirect,
                        caption: context.l10n.settingsDirectCaption,
                        trailing: Switch(
                          value: c.directOn,
                          onChanged: c.setDirectOn,
                        ),
                      ),
                      // Self-hosting: a relay of the user's own (linksy-server).
                      _Row(
                        icon: Ph.network,
                        title: context.l10n.settingsRelay,
                        caption: st.relay ?? context.l10n.settingsRelayDefault,
                        onTap: () async {
                          final relay = await _askRelay(context, st.relay);
                          // Null: dismissed. Empty: back to Linksy's own.
                          if (relay == null || relay == (st.relay ?? '')) {
                            return;
                          }
                          await update(
                            st.copyWith(relay: relay.isEmpty ? null : relay),
                          );
                        },
                      ),
                    ],
                  ),
                  SectionLabel(context.l10n.settingsWithYourComputers),
                  _Group(
                    children: [
                      _Row(
                        icon: Ph.phoneCall,
                        title: context.l10n.settingsPauseMusic,
                        caption: context.l10n.settingsPauseMusicCaption,
                        trailing: Switch(
                          value: c.pauseOnCalls,
                          onChanged: c.setPauseOnCalls,
                        ),
                      ),
                      _Row(
                        icon: Ph.musicNotes,
                        title: context.l10n.settingsMediaNotice,
                        caption: context.l10n.settingsMediaNoticeCaption,
                        trailing: Switch(
                          value: c.mediaNotice,
                          onChanged: c.setMediaNotice,
                        ),
                      ),
                      _Row(
                        icon: Ph.mouseSimple,
                        title: context.l10n.settingsReverseScroll,
                        caption: context.l10n.settingsReverseScrollCaption,
                        trailing: Switch(
                          value: c.scrollReversed,
                          onChanged: c.setScrollReversed,
                        ),
                      ),
                      _Row(
                        icon: Ph.folderOpen,
                        title: context.l10n.settingsBrowseFiles,
                        caption: c.filesFolder == null
                            ? context.l10n.settingsBrowseFilesChoose
                            : context.l10n.settingsSharesFolder(c.filesFolder!),
                        onTap: c.pickFilesFolder,
                        trailing: Switch(
                          value: c.sharingFiles && c.filesFolder != null,
                          onChanged: (v) => v && c.filesFolder == null
                              ? c.pickFilesFolder()
                              : c.setSharingFiles(v),
                        ),
                      ),
                      _Row(
                        icon: Ph.userCircle,
                        title: context.l10n.settingsPicture,
                        caption: c.ownPicture == null
                            ? context.l10n.settingsPictureChoose
                            : context.l10n.settingsPictureChange,
                        onTap: c.pickOwnPicture,
                        trailing: c.ownPicture == null
                            ? null
                            : TextButton(
                                onPressed: c.removeOwnPicture,
                                child: Text(context.l10n.settingsPictureRemove),
                              ),
                      ),
                      _Row(
                        icon: Ph.mapPin,
                        title: context.l10n.settingsLocate,
                        caption: context.l10n.settingsLocateCaption,
                        trailing: Switch(
                          value: c.locatable,
                          onChanged: (v) async {
                            final ok = await c.setLocatable(v);
                            if (!ok && context.mounted) {
                              showMessage(
                                context,
                                context.l10n.settingsLocatePermission,
                              );
                            }
                          },
                        ),
                      ),
                      _Row(
                        icon: Ph.images,
                        title: context.l10n.settingsPhotoFolder,
                        caption: c.photosFolder == null
                            ? context.l10n.settingsPhotoFolderChoose
                            : context.l10n.settingsPhotoFolderBacksUp(
                                c.photosFolder!,
                              ),
                        onTap: c.pickPhotosFolder,
                      ),
                    ],
                  ),
                  SectionLabel(context.l10n.settingsThisApp),
                  _Group(
                    children: [
                      _Row(
                        icon: Ph.globe,
                        title: context.l10n.settingsLanguage,
                        caption: languages
                            .firstWhere(
                              (l) => l.code == c.locale.value.languageCode,
                              orElse: () => languages.first,
                            )
                            .name,
                        onTap: () => showLanguagePicker(context),
                      ),
                      const _ThemeChoice(),
                      _Row(
                        icon: Ph.sparkle,
                        title: context.l10n.newsTitle,
                        onTap: () async {
                          final v = (await LinksyPlatform.appVersion())
                              ?.split(' ')
                              .first;
                          if (v == null || !context.mounted) return;
                          await showWhatsNew(context, v, highlights(v));
                        },
                      ),
                      const _CheckUpdates(),
                      _Row(
                        icon: Ph.fileText,
                        title: context.l10n.settingsLogs,
                        caption: context.l10n.settingsLogsCaption,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LogsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SectionLabel(context.l10n.settingsPermissions),
                  const _Group(children: [_Permissions()]),
                  if (demo != null) ...[
                    SectionLabel(context.l10n.settingsDemo),
                    _Group(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            context.l10n.settingsDemoCaption,
                            style: TextStyle(color: s.muted, height: 1.4),
                          ),
                        ),
                        _Row(
                          icon: Ph.downloadSimple,
                          title: context.l10n.settingsDemoReceiveFiles,
                          onTap: demo.simulateIncomingFiles,
                        ),
                        _Row(
                          icon: Ph.handshake,
                          title: context.l10n.settingsDemoReceivePairing,
                          onTap: demo.simulateIncomingPairing,
                        ),
                        _Row(
                          icon: Ph.clipboardText,
                          title: context.l10n.settingsDemoReceiveClipboard,
                          onTap: demo.simulateClipboard,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 40),
                  const Center(child: AppIcon(size: 52)),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.settingsTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: s.faint, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  // Which build is installed (updates from GitHub are manual).
                  FutureBuilder<String?>(
                    future: LinksyPlatform.appVersion(),
                    builder: (context, v) => Text(
                      v.data == null ? '' : 'Linksy ${v.data}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: s.faint, fontSize: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static Future<String?> _askName(BuildContext context, String current) =>
      _askText(
        context,
        current: current,
        title: (l) => l.settingsNameTitle,
        caption: (l) => l.settingsNameCaption,
        maxLength: 48,
      );

  /// The relay's address; empty means Linksy's own. The core checks it.
  static Future<String?> _askRelay(BuildContext context, String? current) =>
      _askText(
        context,
        current: current ?? '',
        title: (l) => l.settingsRelay,
        caption: (l) => l.settingsRelayCaption,
        hint: 'https://relay.example.com',
        keyboardType: TextInputType.url,
      );

  /// One line of text; null when dismissed.
  static Future<String?> _askText(
    BuildContext context, {
    required String current,
    required String Function(AppLocalizations) title,
    required String Function(AppLocalizations) caption,
    int? maxLength,
    String? hint,
    TextInputType? keyboardType,
  }) {
    final text = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (dialog) {
        final s = Sig.of(dialog);
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title(dialog.l10n),
                  textAlign: TextAlign.center,
                  style: sora(21, color: s.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  caption(dialog.l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.muted),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: text,
                  autofocus: true,
                  maxLength: maxLength,
                  keyboardType: keyboardType,
                  autocorrect: keyboardType == null,
                  decoration: hint == null
                      ? null
                      : InputDecoration(hintText: hint),
                  style: sora(18, weight: FontWeight.w500, color: s.ink),
                  onSubmitted: (v) => Navigator.of(dialog).pop(v.trim()),
                ),
                const SizedBox(height: 8),
                SigButton(
                  label: dialog.l10n.settingsSave,
                  expand: true,
                  onTap: () => Navigator.of(dialog).pop(text.text.trim()),
                ),
                SigButton(
                  label: dialog.l10n.settingsCancel,
                  kind: SigButtonKind.quiet,
                  expand: true,
                  onTap: () => Navigator.of(dialog).pop(),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(text.dispose);
  }
}

/// Appearance: as the phone is, light or dark.
class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice();

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final t = context.l10n;
    return ValueListenableBuilder(
      valueListenable: c.themeMode,
      builder: (context, mode, _) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Ph.circleHalf, color: Sig.blue, size: 22),
                const SizedBox(width: 14),
                Text(
                  t.settingsAppearance,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: s.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: s.raised,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                children: [
                  for (final (m, icon, label) in [
                    (ThemeMode.system, Ph.deviceMobile, t.settingsThemeSystem),
                    (ThemeMode.light, Ph.sun, t.settingsThemeLight),
                    (ThemeMode.dark, Ph.moon, t.settingsThemeDark),
                  ])
                    Expanded(
                      child: Pressable(
                        onTap: () => c.setThemeMode(m),
                        semanticLabel: label,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          decoration: BoxDecoration(
                            color: m == mode ? s.card : Colors.transparent,
                            borderRadius: BorderRadius.circular(Radii.sm + 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 17,
                                color: m == mode ? Sig.blue : s.muted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: m == mode ? s.ink : s.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThisPhone extends StatelessWidget {
  const _ThisPhone({
    required this.name,
    required this.shortId,
    required this.onRename,
    this.picture,
    this.pictureVersion = 0,
  });

  final String name;
  final String shortId;
  final VoidCallback onRename;

  /// This phone's own picture, if chosen.
  final String? picture;
  final int pictureVersion;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable(
      onTap: onRename,
      semanticLabel: context.l10n.settingsRename(name),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: s.hero,
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: picture == null
                  ? const Center(child: LinksyMark(size: 32))
                  : Image.file(
                      File(picture!),
                      key: ValueKey(pictureVersion),
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: sora(21, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.settingsThisPhone(shortId),
                    style: sora(
                      12.5,
                      weight: FontWeight.w500,
                      color: Colors.white60,
                      spacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Ph.pencilSimple, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SigCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: s.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Check for Updates: asks GitHub now, then offers Update Now.
class _CheckUpdates extends StatefulWidget {
  const _CheckUpdates();

  @override
  State<_CheckUpdates> createState() => _CheckUpdatesState();
}

class _CheckUpdatesState extends State<_CheckUpdates> {
  var _checking = false;

  Future<void> _check() async {
    final u = LinksyScope.read(context).updates;
    setState(() => _checking = true);
    final found = await u.check();
    if (!mounted) return;
    setState(() => _checking = false);
    if (found) {
      await showUpdate(context);
    } else {
      showMessage(context, context.l10n.updateNewest(u.installed ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) => _Row(
    icon: Ph.arrowCircleUp,
    title: context.l10n.updateCheck,
    onTap: _checking ? null : _check,
    trailing: _checking
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.caption,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Icon(icon, color: Sig.blue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: s.ink,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: TextStyle(
                      fontSize: 13,
                      color: s.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          if (onTap != null) Icon(Ph.caretRight, color: s.faint, size: 18),
        ],
      ),
    );
    return onTap == null ? row : Pressable(onTap: onTap, child: row);
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
  Widget build(BuildContext context) => _Row(
    icon: Ph.shieldCheck,
    title: context.l10n.settingsPermissionsRow,
    caption: _allowed == null
        ? context.l10n.settingsPermissionsWhat
        : _allowed == 2
        ? context.l10n.settingsPermissionsBoth
        : context.l10n.settingsPermissionsSome(_allowed!),
    onTap: () async {
      await showPermissions(context);
      await _read();
    },
  );
}
