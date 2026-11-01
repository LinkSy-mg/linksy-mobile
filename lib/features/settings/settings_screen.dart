import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/demo_node.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../permissions/permissions_sheet.dart';
import 'settings_kit.dart';
import 'settings_pages.dart';

/// Settings: this phone, one thing worth doing next, and a few pages, each
/// opened from its own bubble. Search finds any setting on any of them.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(SettingsHit hit) {
    final area = hit.area;
    if (area == null) {
      showPermissions(context);
    } else {
      openSettingsArea(context, area, highlight: hit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final st = c.settings;
    final s = Sig.of(context);
    final l = context.l10n;
    final demo = c.node is DemoNode ? c.node as DemoNode : null;
    if (st == null) return const Scaffold(body: SizedBox.shrink());

    final query = _search.text.trim().toLowerCase();
    final hits = query.isEmpty
        ? const <SettingsHit>[]
        : [
            for (final hit in settingsIndex(context))
              if ([
                hit.title,
                ...?hit.terms,
                hit.area?.title(l) ?? l.settingsPermissions,
              ].any((t) => t.toLowerCase().contains(query)))
                hit,
          ];

    return SettingsPage(
      title: l.settingsTitle,
      lead: const LinksyMark(size: 32),
      children: [
        const SizedBox(height: 8),
        _SearchField(controller: _search, onChanged: (_) => setState(() {})),
        if (query.isNotEmpty) ...[
          for (final hit in hits)
            _Result(
              hit: hit,
              page: hit.area?.title(l) ?? l.settingsPermissions,
              onTap: () => _open(hit),
            ),
          if (hits.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Text(
                l.settingsNothingMatches(_search.text.trim()),
                style: TextStyle(color: s.muted, fontSize: 15),
              ),
            ),
        ] else ...[
          const SizedBox(height: 16),
          _ThisPhone(
            name: st.name,
            shortId: c.node.info.shortId,
            picture: c.ownPicture,
            pictureVersion: c.pictureVersion,
            onRename: () async {
              final name = await askPhoneName(context, st.name);
              if (name != null && name.isNotEmpty && name != st.name) {
                if (!context.mounted) return;
                await report(
                  context,
                  c.updateSettings(st.copyWith(name: name)),
                );
              }
            },
          ),
          const _Recommended(),
          for (final area in SettingsArea.values)
            CategoryBubble(
              icon: area.icon,
              color: area.color,
              title: area.title(l),
              summary: settingsSummary(context, area),
              onTap: () => openSettingsArea(context, area),
            ),
          const _PermissionsBubble(),
          if (demo != null)
            SettingsSection(
              title: l.settingsDemo,
              children: [
                SettingRow(
                  icon: Ph.downloadSimple,
                  title: l.settingsDemoReceiveFiles,
                  caption: l.settingsDemoCaption,
                  onTap: demo.simulateIncomingFiles,
                ),
                SettingRow(
                  icon: Ph.handshake,
                  title: l.settingsDemoReceivePairing,
                  onTap: demo.simulateIncomingPairing,
                ),
                SettingRow(
                  icon: Ph.clipboardText,
                  title: l.settingsDemoReceiveClipboard,
                  onTap: demo.simulateClipboard,
                ),
              ],
            ),
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
    );
  }
}

/// A search result: the setting, and the page it's on.
class _Result extends StatelessWidget {
  const _Result({required this.hit, required this.page, required this.onTap});

  final SettingsHit hit;
  final String page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Pressable(
        onTap: onTap,
        semanticLabel: hit.title,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: s.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              IconCircle(icon: hit.icon, color: Sig.blue, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.title,
                      style: TextStyle(
                        color: s.ink,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      page,
                      style: TextStyle(color: s.muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Icon(Ph.caretRight, color: s.faint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// The permissions: a bubble like the pages', opening Android's questions.
class _PermissionsBubble extends StatefulWidget {
  const _PermissionsBubble();

  @override
  State<_PermissionsBubble> createState() => _PermissionsBubbleState();
}

class _PermissionsBubbleState extends State<_PermissionsBubble>
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
    return CategoryBubble(
      icon: Ph.shieldCheck,
      color: Sig.cyan,
      title: l.settingsPermissions,
      summary: switch (_allowed) {
        null => l.settingsPermissionsRow,
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
