import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'library.dart';
import 'selection.dart';
import 'send_bar.dart';
import 'shelves.dart';
import 'thread.dart';

Future<void> openAllPhotos(
  BuildContext context,
  PhoneLibrary library,
  String name,
) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => _AllPhotos(library: library, name: name),
  ),
);

Future<void> openAllApps(
  BuildContext context,
  PhoneLibrary library,
  String name,
) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => _AllApps(library: library, name: name),
  ),
);

Future<void> openHistory(
  BuildContext context,
  PhoneLibrary library,
  DeviceInfo device,
) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => _AllHistory(library: library, device: device),
  ),
);

/// A See all page: the blue bar of the phone's page, what's in it, and Send
/// floating over it.
class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.library,
    required this.name,
    required this.children,
  });

  final String title;
  final PhoneLibrary library;
  final String name;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayFor(Theme.of(context).brightness),
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
                    child: Row(
                      children: [
                        RoundButton(
                          icon: Ph.arrowLeft,
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 10),
                        Text(title, style: sora(22, color: s.ink)),
                      ],
                    ),
                  ),
                ),
                ...children,
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SendBar(
                flow: library.flow,
                name: name,
                onSent: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on ? Sig.blue : s.card,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: on ? Colors.white : s.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Everything between the two phones, the newest first.
class _AllHistory extends StatelessWidget {
  const _AllHistory({required this.library, required this.device});

  final PhoneLibrary library;
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    return _Page(
      title: context.l10n.phoneHistory,
      library: library,
      name: device.name,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: HistoryThread(
              entries: c.activityFor(device.id).toList(),
              device: device,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllPhotos extends StatelessWidget {
  const _AllPhotos({required this.library, required this.name});

  final PhoneLibrary library;
  final String name;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final chosen = library.flow.selection;
    return ListenableBuilder(
      listenable: Listenable.merge([library, chosen]),
      builder: (context, _) {
        final days = mediaByDay(library.media);
        return _Page(
          title: l.phoneShelfPhotos,
          library: library,
          name: name,
          children: [
            if (library.albums.length > 1)
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  children: [
                    _Chip(
                      label: l.phoneAllAlbums,
                      on: library.album == null,
                      onTap: () => library.pickAlbum(null),
                    ),
                    for (final a in library.albums)
                      _Chip(
                        label: a.name,
                        on: library.album == a.id,
                        onTap: () => library.pickAlbum(a.id),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 800) library.loadMore();
                  return false;
                },
                child: CustomScrollView(
                  slivers: [
                    for (final (day, items) in days) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(day, style: sora(16, color: s.ink)),
                              ),
                              SmallAction(
                                label: l.phoneSelectDay,
                                onTap: () => chosen.toggleDay(items),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                              ),
                          itemCount: items.length,
                          itemBuilder: (context, i) => PhotoTile(
                            key: ValueKey(items[i].id),
                            media: items[i],
                            on: chosen.hasMedia(items[i]),
                            onTap: () => chosen.toggleMedia(items[i]),
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: SendBar.room),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AllApps extends StatefulWidget {
  const _AllApps({required this.library, required this.name});

  final PhoneLibrary library;
  final String name;

  @override
  State<_AllApps> createState() => _AllAppsState();
}

class _AllAppsState extends State<_AllApps> {
  String _search = '';
  bool _bySize = false;

  @override
  void initState() {
    super.initState();
    widget.library.pickUpdates();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final library = widget.library;
    final flow = library.flow;
    return ListenableBuilder(
      listenable: Listenable.merge([library, flow, flow.selection]),
      builder: (context, _) {
        final query = _search.toLowerCase();
        final apps = [
          for (final a in library.apps ?? const <PhoneApp>[])
            if (a.label.toLowerCase().contains(query)) a,
        ];
        if (_bySize) apps.sort((a, b) => b.size.compareTo(a.size));
        return _Page(
          title: l.phoneApps,
          library: library,
          name: widget.name,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: s.card,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(Ph.magnifyingGlass, size: 18, color: s.muted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(
                                hintText: l.phoneAppsSearch,
                                isCollapsed: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: _Chip(
                      label: _bySize ? l.phoneSortSize : l.phoneSortName,
                      on: false,
                      onTap: () => setState(() => _bySize = !_bySize),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                l.phoneAppsNote,
                style: TextStyle(fontSize: 13, height: 1.35, color: s.muted),
              ),
            ),
            Expanded(
              child: apps.isEmpty && library.apps != null
                  ? Center(
                      child: Text(
                        l.phoneNoApps,
                        style: TextStyle(color: s.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        SendBar.room,
                      ),
                      itemCount: apps.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _AppRow(
                        app: apps[i],
                        there: library.there(apps[i]),
                        name: widget.name,
                        on: flow.selection.hasApp(apps[i]),
                        onToggle: () => flow.selection.toggleApp(apps[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.app,
    required this.there,
    required this.name,
    required this.on,
    required this.onToggle,
  });

  final PhoneApp app;
  final AppThere there;
  final String name;
  final bool on;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final mark = switch (there) {
      AppThere.none => l.phoneAppNotThere(name),
      AppThere.older => l.phoneAppUpdate,
      AppThere.same => l.phoneAppSame,
      AppThere.newer => l.phoneAppNewer,
      AppThere.otherSigner => l.phoneAppOtherSigner(name),
      AppThere.unknown => null,
    };
    final can = appSelectable(there);
    final dim = there == AppThere.same && !on;
    return Opacity(
      opacity: !can || dim ? 0.55 : 1,
      child: Pressable(
        // What's there already takes a long press, so nobody sends it twice
        // by accident. What can't go doesn't react at all.
        onTap: !can || dim ? null : onToggle,
        onLongPress: can ? onToggle : null,
        scale: 0.985,
        semanticLabel: app.label,
        child: AnimatedContainer(
          duration: motion(context, 120),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: s.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: on ? Sig.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AppGlyph(app: app, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: s.ink,
                      ),
                    ),
                    Text(
                      '${app.versionName} · ${formatBytes(app.size)}',
                      style: TextStyle(fontSize: 13, color: s.muted),
                    ),
                    if (mark != null)
                      Text(
                        mark,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: there == AppThere.older
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: there == AppThere.older ? Sig.deep : s.muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (can) ...[const SizedBox(width: 10), PickMark(on: on)],
            ],
          ),
        ),
      ),
    );
  }
}
