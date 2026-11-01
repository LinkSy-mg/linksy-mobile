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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

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
      builder: (context, mode, _) => Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: s.card,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconCircle(
                  icon: Ph.circleHalf,
                  color: Sig.blue,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  t.settingsAppearance,
                  style: TextStyle(
                    fontSize: 16,
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
    final row = Container(
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          IconCircle(icon: icon, color: Sig.blue, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
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

/// One setting: the words search finds it by, and its row.
class _Entry {
  const _Entry(this.terms, this.child);

  final List<String> terms;
  final Widget child;
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final s = Sig.of(context);
    final l = context.l10n;
    final demo = c.node is DemoNode ? c.node as DemoNode : null;
    if (st == null) return const Scaffold(body: SizedBox.shrink());

    Future<void> update(NodeSettings next) =>
        report(context, c.updateSettings(next));

    final language = languages
        .firstWhere(
          (x) => x.code == c.locale.value.languageCode,
          orElse: () => languages.first,
        )
        .name;

    // Every setting, by section, with what search finds it by.
    final sections = <(String, List<_Entry>)>[
      (
        l.settingsReceiving,
        [
          _Entry(
            [l.settingsSaveLocation, l.settingsSaveLocationPath],
            _Row(
              icon: Ph.folderSimple,
              title: l.settingsSaveLocation,
              // Files land in the app's folder, then move to Downloads
              // (Android 10+).
              caption: l.settingsSaveLocationPath,
            ),
          ),
          _Entry(
            [
              l.settingsAcceptFromMyDevices,
              l.settingsAcceptFromMyDevicesCaption,
            ],
            _Row(
              icon: Ph.shieldCheck,
              title: l.settingsAcceptFromMyDevices,
              caption: l.settingsAcceptFromMyDevicesCaption,
              trailing: Switch(
                value: st.autoAccept,
                onChanged: (v) => update(st.copyWith(autoAccept: v)),
              ),
            ),
          ),
        ],
      ),
      (
        l.settingsConnection,
        [
          _Entry(
            [l.settingsStayConnected, l.settingsStayConnectedCaption],
            _Row(
              icon: Ph.lightning,
              title: l.settingsStayConnected,
              caption: l.settingsStayConnectedCaption,
              trailing: Switch(
                value: st.stayConnected,
                onChanged: (v) => update(st.copyWith(stayConnected: v)),
              ),
            ),
          ),
          _Entry(
            [l.settingsKeepRunning, l.settingsKeepRunningCaption],
            _Row(
              icon: Ph.deviceMobile,
              title: l.settingsKeepRunning,
              caption: l.settingsKeepRunningCaption,
              trailing: Switch(
                value: c.stayRunning,
                onChanged: c.setStayRunning,
              ),
            ),
          ),
          _Entry(
            [l.settingsAwayFromHome, l.settingsAwayFromHomeCaption],
            _Row(
              icon: Ph.globeHemisphereWest,
              title: l.settingsAwayFromHome,
              caption: l.settingsAwayFromHomeCaption,
              trailing: Switch(
                value: st.away,
                onChanged: (v) => update(st.copyWith(away: v)),
              ),
            ),
          ),
          // Direct links (§4.17) for big transfers
          _Entry(
            [l.settingsDirect, l.settingsDirectCaption],
            _Row(
              icon: Ph.arrowsLeftRight,
              title: l.settingsDirect,
              caption: l.settingsDirectCaption,
              trailing: Switch(value: c.directOn, onChanged: c.setDirectOn),
            ),
          ),
          // Self-hosting: a relay of the user's own (linksy-server).
          _Entry(
            [l.settingsRelay, st.relay ?? l.settingsRelayDefault],
            _Row(
              icon: Ph.network,
              title: l.settingsRelay,
              caption: st.relay ?? l.settingsRelayDefault,
              onTap: () async {
                final relay = await SettingsScreen._askRelay(context, st.relay);
                // Null: dismissed. Empty: back to Linksy's own.
                if (relay == null || relay == (st.relay ?? '')) return;
                await update(st.copyWith(relay: relay.isEmpty ? null : relay));
              },
            ),
          ),
        ],
      ),
      (
        l.settingsWithYourComputers,
        [
          _Entry(
            [l.settingsPauseMusic, l.settingsPauseMusicCaption],
            _Row(
              icon: Ph.phoneCall,
              title: l.settingsPauseMusic,
              caption: l.settingsPauseMusicCaption,
              trailing: Switch(
                value: c.pauseOnCalls,
                onChanged: c.setPauseOnCalls,
              ),
            ),
          ),
          _Entry(
            [l.settingsMediaNotice, l.settingsMediaNoticeCaption],
            _Row(
              icon: Ph.musicNotes,
              title: l.settingsMediaNotice,
              caption: l.settingsMediaNoticeCaption,
              trailing: Switch(
                value: c.mediaNotice,
                onChanged: c.setMediaNotice,
              ),
            ),
          ),
          _Entry(
            [l.settingsReverseScroll, l.settingsReverseScrollCaption],
            _Row(
              icon: Ph.mouseSimple,
              title: l.settingsReverseScroll,
              caption: l.settingsReverseScrollCaption,
              trailing: Switch(
                value: c.scrollReversed,
                onChanged: c.setScrollReversed,
              ),
            ),
          ),
          _Entry(
            [l.settingsBrowseFiles, l.settingsBrowseFilesChoose],
            _Row(
              icon: Ph.folderOpen,
              title: l.settingsBrowseFiles,
              caption: c.filesFolder == null
                  ? l.settingsBrowseFilesChoose
                  : l.settingsSharesFolder(c.filesFolder!),
              onTap: c.pickFilesFolder,
              trailing: Switch(
                value: c.sharingFiles && c.filesFolder != null,
                onChanged: (v) => v && c.filesFolder == null
                    ? c.pickFilesFolder()
                    : c.setSharingFiles(v),
              ),
            ),
          ),
          _Entry(
            [l.settingsPicture, l.settingsPictureChoose],
            _Row(
              icon: Ph.userCircle,
              title: l.settingsPicture,
              caption: c.ownPicture == null
                  ? l.settingsPictureChoose
                  : l.settingsPictureChange,
              onTap: c.pickOwnPicture,
              trailing: c.ownPicture == null
                  ? null
                  : TextButton(
                      onPressed: c.removeOwnPicture,
                      child: Text(l.settingsPictureRemove),
                    ),
            ),
          ),
          _Entry(
            [l.settingsLocate, l.settingsLocateCaption],
            _Row(
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
          ),
          _Entry(
            [l.settingsPhotoFolder, l.settingsPhotoFolderChoose],
            _Row(
              icon: Ph.images,
              title: l.settingsPhotoFolder,
              caption: c.photosFolder == null
                  ? l.settingsPhotoFolderChoose
                  : l.settingsPhotoFolderBacksUp(c.photosFolder!),
              onTap: c.pickPhotosFolder,
            ),
          ),
        ],
      ),
      (
        l.settingsThisApp,
        [
          _Entry(
            [l.settingsLanguage, language],
            _Row(
              icon: Ph.globe,
              title: l.settingsLanguage,
              caption: language,
              onTap: () => showLanguagePicker(context),
            ),
          ),
          _Entry([
            l.settingsAppearance,
            l.settingsThemeSystem,
            l.settingsThemeLight,
            l.settingsThemeDark,
          ], const _ThemeChoice()),
          _Entry(
            [l.newsTitle],
            _Row(
              icon: Ph.sparkle,
              title: l.newsTitle,
              onTap: () async {
                final v = (await LinksyPlatform.appVersion())?.split(' ').first;
                if (v == null || !context.mounted) return;
                await showWhatsNew(context, v, highlights(v));
              },
            ),
          ),
          _Entry([l.updateCheck], const _CheckUpdates()),
          _Entry(
            [l.settingsLogs, l.settingsLogsCaption],
            _Row(
              icon: Ph.fileText,
              title: l.settingsLogs,
              caption: l.settingsLogsCaption,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LogsScreen()),
              ),
            ),
          ),
        ],
      ),
      (
        l.settingsPermissions,
        [
          _Entry([
            l.settingsPermissionsRow,
            l.settingsPermissionsWhat,
          ], const _Permissions()),
        ],
      ),
      if (demo != null)
        (
          l.settingsDemo,
          [
            _Entry(
              [l.settingsDemoReceiveFiles],
              _Row(
                icon: Ph.downloadSimple,
                title: l.settingsDemoReceiveFiles,
                caption: l.settingsDemoCaption,
                onTap: demo.simulateIncomingFiles,
              ),
            ),
            _Entry(
              [l.settingsDemoReceivePairing],
              _Row(
                icon: Ph.handshake,
                title: l.settingsDemoReceivePairing,
                onTap: demo.simulateIncomingPairing,
              ),
            ),
            _Entry(
              [l.settingsDemoReceiveClipboard],
              _Row(
                icon: Ph.clipboardText,
                title: l.settingsDemoReceiveClipboard,
                onTap: demo.simulateClipboard,
              ),
            ),
          ],
        ),
    ];

    final query = _search.text.trim().toLowerCase();
    final searching = query.isNotEmpty;
    bool found(String section, _Entry e) =>
        !searching ||
        section.toLowerCase().contains(query) ||
        e.terms.any((t) => t.toLowerCase().contains(query));
    final shown = [
      for (final (label, entries) in sections)
        if (entries.where((e) => found(label, e)).toList() case final list
            when list.isNotEmpty)
          (label, list),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Row(
              children: [
                RoundButton(
                  icon: Ph.arrowLeft,
                  tooltip: l.settingsBack,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            // The mark over the big title.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 18, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinksyMark(size: 32),
                  const SizedBox(height: 8),
                  Text(
                    l.settingsTitle,
                    style: sora(34, weight: FontWeight.w700, color: s.ink),
                  ),
                ],
              ),
            ),
            _SearchField(
              controller: _search,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (!searching) ...[
              _ThisPhone(
                name: st.name,
                shortId: c.node.info.shortId,
                picture: c.ownPicture,
                pictureVersion: c.pictureVersion,
                onRename: () async {
                  final name = await SettingsScreen._askName(context, st.name);
                  if (name != null && name.isNotEmpty && name != st.name) {
                    await update(st.copyWith(name: name));
                  }
                },
              ),
              const _Recommended(),
            ],
            for (final (label, entries) in shown) ...[
              SectionLabel(label),
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                entries[i].child,
              ],
            ],
            if (searching && shown.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
                child: Text(
                  l.settingsNothingMatches(_search.text.trim()),
                  style: TextStyle(color: s.muted, fontSize: 15),
                ),
              ),
            if (!searching) ...[
              const SizedBox(height: 40),
              const Center(child: AppIcon(size: 52)),
              const SizedBox(height: 10),
              Text(
                l.settingsTagline,
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
          ],
        ),
      ),
    );
  }
}

/// Finds any setting by its name or what it says.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Icon(Ph.magnifyingGlass, color: s.muted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 15.5, color: s.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: context.l10n.settingsSearch,
                hintStyle: TextStyle(fontSize: 15.5, color: s.faint),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Icon(Ph.x, color: s.muted, size: 18),
            ),
        ],
      ),
    );
  }
}

/// One thing worth doing next, when there is one: the permissions, then a
/// photo folder, then this phone's picture. Then a line, then the rest.
class _Recommended extends StatefulWidget {
  const _Recommended();

  @override
  State<_Recommended> createState() => _RecommendedState();
}

class _RecommendedState extends State<_Recommended>
    with WidgetsBindingObserver {
  bool? _allAllowed;

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
    setState(() => _allAllowed = p.notifications && p.camera);
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final s = Sig.of(context);
    final l = context.l10n;
    final (IconData, String, String, VoidCallback)? next = switch (c) {
      _ when _allAllowed == false => (
        Ph.shieldCheck,
        l.settingsPermissionsRow,
        l.settingsPermissions,
        () async {
          await showPermissions(context);
          await _read();
        },
      ),
      _ when c.photosFolder == null => (
        Ph.images,
        l.settingsPhotoFolder,
        l.settingsWithYourComputers,
        c.pickPhotosFolder,
      ),
      _ when c.ownPicture == null => (
        Ph.userCircle,
        l.settingsPicture,
        l.settingsWithYourComputers,
        c.pickOwnPicture,
      ),
      _ => null,
    };
    if (next == null) return const SizedBox(height: 4);
    final (icon, title, section, onTap) = next;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Pressable(
            onTap: onTap,
            semanticLabel: title,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: s.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.settingsRecommended,
                    style: TextStyle(
                      color: s.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconCircle(icon: icon, color: Sig.blue, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: s.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              section,
                              style: TextStyle(color: s.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Ph.caretRight, color: s.faint, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.fromLTRB(4, 18, 4, 0),
            color: s.line,
          ),
        ],
      ),
    );
  }
}
