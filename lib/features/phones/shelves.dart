import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'library.dart';
import 'see_all.dart';
import 'selection.dart';
import 'send_flow.dart';

/// A shelf's title, with See all when there's more.
class ShelfTitle extends StatelessWidget {
  const ShelfTitle(this.title, {super.key, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: sora(18, color: s.ink)),
          ),
          if (onSeeAll != null)
            SmallAction(label: context.l10n.phoneSeeAll, onTap: onSeeAll!),
        ],
      ),
    );
  }
}

/// A round check, on or off.
class PickMark extends StatelessWidget {
  const PickMark({super.key, required this.on, this.size = 24});

  final bool on;
  final double size;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: motion(context, 120),
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: on ? Sig.blue : const Color(0x33000000),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: on
        ? Icon(PhBold.check, size: size * 0.55, color: Colors.white)
        : null,
  );
}

/// A photo or video, tap to choose it.
class PhotoTile extends StatefulWidget {
  const PhotoTile({
    super.key,
    required this.media,
    required this.on,
    required this.onTap,
    this.radius = 6,
    this.markWhenOff = true,
  });

  final PhoneMedia media;
  final bool on;
  final VoidCallback onTap;
  final double radius;

  /// An empty mark on what isn't chosen, where choosing is the point.
  final bool markWhenOff;

  /// What's been drawn lately, so scrolling back doesn't ask Android again.
  static final _cache = <int, Uint8List>{};

  @override
  State<PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<PhotoTile> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final m = widget.media;
    _bytes = PhotoTile._cache[m.id];
    if (_bytes != null) return;
    LinksyPlatform.phoneThumb(m.id, video: m.video).then((bytes) {
      if (bytes == null || !mounted) return;
      if (PhotoTile._cache.length > 400) {
        PhotoTile._cache.remove(PhotoTile._cache.keys.first);
      }
      PhotoTile._cache[m.id] = bytes;
      setState(() => _bytes = bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final bytes = _bytes;
    final radius = BorderRadius.circular(widget.radius);
    return Pressable(
      onTap: widget.onTap,
      onLongPress: widget.onTap,
      scale: 0.96,
      semanticLabel: widget.media.name,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: s.raised),
            if (bytes != null)
              Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
            if (widget.media.video)
              const Positioned(
                left: 8,
                bottom: 8,
                child: Icon(PhFill.play, size: 18, color: Colors.white),
              ),
            AnimatedContainer(
              duration: motion(context, 120),
              decoration: BoxDecoration(
                borderRadius: radius,
                color: widget.on ? const Color(0x2E2563FF) : Colors.transparent,
                border: widget.on
                    ? Border.all(color: Sig.blue, width: 3)
                    : null,
              ),
            ),
            if (widget.on || widget.markWhenOff)
              Positioned(
                right: 6,
                top: 6,
                child: PickMark(on: widget.on, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}

/// The latest photos, to swipe through and tap.
class PhotosShelf extends StatelessWidget {
  const PhotosShelf({
    super.key,
    required this.library,
    required this.allowed,
    required this.name,
    required this.onAllow,
  });

  final PhoneLibrary library;
  final bool allowed;
  final String name;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = Sig.of(context);
    if (!allowed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShelfTitle(l.phoneShelfPhotos),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: SigCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.phoneAllowPhotosCaption,
                    style: TextStyle(fontSize: 14, height: 1.4, color: s.muted),
                  ),
                  const SizedBox(height: 12),
                  SigButton(
                    label: l.phoneAllowPhotos,
                    icon: Ph.imagesSquare,
                    expand: true,
                    height: 48,
                    onTap: onAllow,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final chosen = library.flow.selection;
    return ListenableBuilder(
      listenable: Listenable.merge([library, chosen]),
      builder: (context, _) {
        final latest = library.media.take(24).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShelfTitle(
              l.phoneShelfPhotos,
              onSeeAll: () => openAllPhotos(context, library, name),
            ),
            SizedBox(
              height: 142,
              child: latest.isEmpty
                  ? Center(
                      child: Text(
                        l.phoneNoPhotos,
                        style: TextStyle(color: s.muted),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: latest.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => SizedBox(
                        width: 126,
                        child: PhotoTile(
                          key: ValueKey(latest[i].id),
                          media: latest[i],
                          radius: 18,
                          markWhenOff: false,
                          on: chosen.hasMedia(latest[i]),
                          onTap: () => chosen.toggleMedia(latest[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// The shape of an app's icon, whatever this phone's launcher masks them to.
ShapeBorder squircle(double size, {BorderSide side = BorderSide.none}) =>
    ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(size * 0.56),
      side: side,
    );

/// [child] cut to that shape, on white for icons with a clear background.
class Squircle extends StatelessWidget {
  const Squircle({super.key, required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: ShapeBorderClipper(shape: squircle(size)),
    child: ColoredBox(
      color: Colors.white,
      child: SizedBox.square(dimension: size, child: child),
    ),
  );
}

/// An app's icon, or a plain tile while it has none.
class AppGlyph extends StatelessWidget {
  const AppGlyph({super.key, required this.app, this.size = 60});

  final PhoneApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;
    return Squircle(
      size: size,
      child: icon == null
          ? const Icon(Ph.squaresFour, color: Sig.blue)
          : Image.memory(icon, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}

/// The apps, worth sending first: what the other phone lacks or has older.
class AppsShelf extends StatelessWidget {
  const AppsShelf({super.key, required this.library, required this.name});

  final PhoneLibrary library;
  final String name;

  static int _rank(AppThere there) => switch (there) {
    AppThere.older => 0,
    AppThere.none => 1,
    AppThere.unknown => 2,
    AppThere.same => 3,
    AppThere.newer || AppThere.otherSigner => 4,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = Sig.of(context);
    final flow = library.flow;
    return ListenableBuilder(
      listenable: Listenable.merge([library, flow, flow.selection]),
      builder: (context, _) {
        final apps = [...?library.apps]
          ..sort(
            (a, b) =>
                _rank(library.there(a)).compareTo(_rank(library.there(b))),
          );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShelfTitle(
              l.phoneApps,
              onSeeAll: () => openAllApps(context, library, name),
            ),
            SizedBox(
              height: 100,
              child: apps.isEmpty
                  ? Center(
                      child: Text(
                        library.apps == null ? '' : l.phoneNoApps,
                        style: TextStyle(color: s.muted),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: apps.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, i) {
                        final a = apps[i];
                        final there = library.there(a);
                        final can = appSelectable(there);
                        final dim = there == AppThere.same;
                        final on = flow.selection.hasApp(a);
                        return Opacity(
                          opacity: !can || (dim && !on) ? 0.45 : 1,
                          child: Pressable(
                            onTap: can && !dim
                                ? () => flow.selection.toggleApp(a)
                                : null,
                            onLongPress: can
                                ? () => flow.selection.toggleApp(a)
                                : null,
                            semanticLabel: a.label,
                            child: SizedBox(
                              width: 66,
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      AnimatedContainer(
                                        duration: motion(context, 120),
                                        decoration: ShapeDecoration(
                                          shape: squircle(
                                            62,
                                            side: BorderSide(
                                              color: on
                                                  ? Sig.blue
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: AppGlyph(app: a, size: 56),
                                      ),
                                      if (on)
                                        const Positioned(
                                          right: -4,
                                          top: -4,
                                          child: PickMark(on: true, size: 22),
                                        )
                                      else if (there == AppThere.older)
                                        Positioned(
                                          right: -6,
                                          top: -6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Sig.deep,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: s.bg,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              l.phoneAppUpdateShort,
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    a.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: s.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Files and folders from Android's picker, and what's been picked.
class FilesShelf extends StatelessWidget {
  const FilesShelf({super.key, required this.flow});

  final SendFlow flow;

  static int _size(String path) {
    try {
      if (FileSystemEntity.isDirectorySync(path)) {
        return Directory(path)
            .listSync(recursive: true)
            .whereType<File>()
            .fold(0, (n, f) => n + f.lengthSync());
      }
      return File(path).lengthSync();
    } on FileSystemException {
      return 0;
    }
  }

  void _add(Iterable<String> paths) => flow.selection.addFiles([
    for (final p in paths)
      PickedFile(path: p, name: p.split('/').last, size: _size(p)),
  ]);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = Sig.of(context);
    final chosen = flow.selection;
    return ListenableBuilder(
      listenable: chosen,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShelfTitle(l.settingsFiles),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _FileTile(
                    icon: Ph.files,
                    label: l.phoneChooseFiles,
                    onTap: () async => _add(await LinksyPlatform.pickFiles()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FileTile(
                    icon: Ph.folderSimple,
                    label: l.phoneChooseFolder,
                    onTap: () async {
                      final folder = await LinksyPlatform.pickSendFolder();
                      if (folder != null) _add([folder]);
                    },
                  ),
                ),
              ],
            ),
          ),
          for (final f in chosen.files)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SigCard(
                padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                child: Row(
                  children: [
                    Icon(fileIcon(f.name), color: Sig.blue, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: s.ink,
                        ),
                      ),
                    ),
                    Text(
                      formatBytes(f.size),
                      style: TextStyle(fontSize: 13, color: s.muted),
                    ),
                    Pressable(
                      onTap: () => chosen.removeFile(f),
                      semanticLabel: l.phoneClear,
                      child: SizedBox.square(
                        dimension: 44,
                        child: Icon(Ph.x, size: 16, color: s.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: s.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Sig.blue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: s.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
