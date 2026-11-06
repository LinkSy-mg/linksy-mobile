import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/activity.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/activity_tile.dart';
import 'shelves.dart';

/// What went between the two phones, as a conversation read from the top:
/// newest first, as the store keeps them, what this phone sent on the right,
/// what came on the left, each thing shown as itself.
class HistoryThread extends StatelessWidget {
  const HistoryThread({super.key, required this.entries, required this.device});

  final List<Activity> entries;
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    String? day;
    for (final a in entries) {
      final thisDay = formatDayHeading(a.time);
      if (thisDay != day) {
        day = thisDay;
        children.add(_Day(thisDay));
      }
      children.add(_Item(activity: a, device: device));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// All of it, on a page of its own.
Future<void> openThread(BuildContext context, DeviceInfo device) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => _Thread(device: device)));

class _Thread extends StatelessWidget {
  const _Thread({required this.device});

  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.phoneHistory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: HistoryThread(
          entries: c.activityFor(device.id).toList(),
          device: device,
        ),
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          decoration: BoxDecoration(
            color: s.raised,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: s.muted,
            ),
          ),
        ),
      ),
    );
  }
}

const _media = {
  'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'mp4', 'mov', 'mkv', 'webm', //
};

bool _isMedia(String name) =>
    _media.contains(name.split('.').last.toLowerCase());

/// One thing: a line for what isn't an object, a bubble for what is.
class _Item extends StatelessWidget {
  const _Item({required this.activity, required this.device});

  final Activity activity;
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final time = formatClock(a.time);
    return switch (a.kind) {
      ActivityKind.files when a.packages.isNotEmpty && a.names.length == 1 =>
        _bubble(_App(activity: a, time: time)),
      ActivityKind.files
          when a.names.isNotEmpty &&
              a.names.every(_isMedia) &&
              a.pictures.isNotEmpty =>
        _bubble(_Photos(activity: a, time: time), flush: true),
      ActivityKind.files => _bubble(_File(activity: a, time: time)),
      ActivityKind.clipboard => _bubble(_Text(activity: a, time: time)),
      ActivityKind.link => _bubble(_Link(activity: a, time: time)),
      _ => _Line(activity: a, time: time),
    };
  }

  Widget _bubble(Widget child, {bool flush = false}) =>
      _Bubble(activity: activity, device: device, flush: flush, child: child);
}

/// Its side, and its corner pointing to whoever it came from.
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.activity,
    required this.device,
    required this.child,
    this.flush = false,
  });

  final Activity activity;
  final DeviceInfo device;
  final Widget child;

  /// A picture reaches closer to the edge than text.
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final a = activity;
    final mine = !a.incoming;
    final failed = _failed(a);
    final openable =
        a.kind == ActivityKind.link ||
        a.kind == ActivityKind.files && a.saved.isNotEmpty;
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: flush ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: failed
            ? Colors.transparent
            : mine
            ? Sig.blue
            : s.card,
        border: failed ? Border.all(color: s.line, width: 1.5) : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 6),
          bottomRight: Radius.circular(mine ? 6 : 18),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: mine && !failed ? Colors.white : s.ink),
        child: child,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            Orb(device: device, size: 24),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: openable
                ? Pressable(
                    onTap: () => TimelineEntry.open(context, a),
                    semanticLabel: activityTitle(a),
                    child: bubble,
                  )
                : bubble,
          ),
        ],
      ),
    );
  }
}

/// Details under a title: quieter than it, on either color.
class _Note extends StatelessWidget {
  const _Note(this.activity, this.text);

  final Activity activity;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final failed = _failed(activity);
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        height: 1.3,
        color: failed
            ? s.red
            : activity.incoming
            ? s.muted
            : const Color(0xE6FFFFFF),
      ),
    );
  }
}

/// Something to press, on a card of either theme.
Color _accent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Sig.cyanLight : Sig.deep;

bool _failed(Activity a) =>
    a.status == ActivityStatus.failed || a.status == ActivityStatus.declined;

String _size(Activity a) {
  final total = a.total > 0 ? a.total : a.sizes.fold(0, (n, s) => n + s);
  return total > 0 ? formatBytes(total) : '';
}

/// What to say under it: why, when it didn't go; else its size and time.
String _details(Activity a, String time) => switch (a.status) {
  ActivityStatus.failed || ActivityStatus.declined => activityDetail(a),
  _ => [_size(a), time].where((t) => t.isNotEmpty).join(' · '),
};

class _Photos extends StatelessWidget {
  const _Photos({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final refs = a.pictures.take(3).toList();
    final more = a.names.length - refs.length;
    return SizedBox(
      width: 232,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 96,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: _Thumb(refs.first)),
                  if (refs.length > 1) ...[
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _Thumb(refs[1])),
                          if (refs.length > 2) ...[
                            const SizedBox(height: 2),
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _Thumb(refs[2]),
                                  if (more > 0)
                                    ColoredBox(
                                      color: const Color(0x9E0A1024),
                                      child: Center(
                                        child: Text(
                                          '+$more',
                                          style: sora(15, color: Colors.white),
                                        ),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    activityTitle(a),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Note(a, _details(a, time)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A picture of what went, while it's there to be read.
class _Thumb extends StatefulWidget {
  const _Thumb(this.ref);

  final String ref;

  static final _cache = <String, Uint8List>{};

  @override
  State<_Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<_Thumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _Thumb._cache[widget.ref];
    if (_bytes != null) return;
    LinksyPlatform.thumbOf(widget.ref).then((bytes) {
      if (bytes == null || !mounted) return;
      if (_Thumb._cache.length > 100) {
        _Thumb._cache.remove(_Thumb._cache.keys.first);
      }
      _Thumb._cache[widget.ref] = bytes;
      setState(() => _bytes = bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    return bytes == null
        ? ColoredBox(color: Sig.of(context).raised)
        : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
  }
}

class _App extends StatefulWidget {
  const _App({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  Uint8List? _icon;

  @override
  void initState() {
    super.initState();
    final package = widget.activity.packages.values.first;
    LinksyPlatform.appIcon(package).then((bytes) {
      if (mounted) setState(() => _icon = bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final icon = _icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Squircle(
          size: 38,
          child: icon == null
              ? const Icon(Ph.squaresFour, color: Sig.blue, size: 20)
              : Image.memory(icon, fit: BoxFit.cover, gaplessPlayback: true),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.packages.keys.first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _Note(a, _details(a, widget.time)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // An icon means it's here now, so it can be opened.
        if (a.incoming && icon != null && !_failed(a)) ...[
          const SizedBox(width: 4),
          Pressable(
            onTap: () => LinksyPlatform.openApp(a.packages.values.first),
            semanticLabel: context.l10n.shareSheetOpen,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Sig.of(context).raised,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                context.l10n.shareSheetOpen,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _accent(context),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _File extends StatelessWidget {
  const _File({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final mine = !a.incoming;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          fileIcon(a.names.isEmpty ? '' : a.names.first),
          size: 28,
          color: _failed(a)
              ? Sig.of(context).muted
              : mine
              ? Colors.white
              : Sig.blue,
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activityTitle(a),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _Note(a, _details(a, time)),
            ],
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final a = activity;
    final text = a.text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text?.trim() ?? activityTitle(a),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, height: 1.3),
                ),
                const SizedBox(height: 2),
                _Note(a, '${context.l10n.deviceClipboard} · $time'),
              ],
            ),
          ),
        ),
        if (text != null && a.incoming) ...[
          const SizedBox(width: 10),
          Pressable(
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              showMessage(context, context.l10n.activityCopiedHere);
            },
            semanticLabel: context.l10n.logsCopy,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: s.raised,
                shape: BoxShape.circle,
              ),
              child: Icon(Ph.copy, size: 17, color: _accent(context)),
            ),
          ),
        ],
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final ink = a.incoming || _failed(a) ? _accent(context) : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        Icon(Ph.link, size: 16, color: ink),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            activityTitle(a),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: ink,
              color: ink,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _Note(a, time),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// What isn't a thing: a ring, a location asked, a ping.
class _Line extends StatelessWidget {
  const _Line({required this.activity, required this.time});

  final Activity activity;
  final String time;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final a = activity;
    final title = a.kind == ActivityKind.locate && !a.incoming
        ? context.l10n.phoneWhere
        : activityTitle(a);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            switch (a.kind) {
              ActivityKind.locate => Ph.mapPin,
              ActivityKind.screen ||
              ActivityKind.display ||
              ActivityKind.watch => Ph.monitor,
              ActivityKind.camera => Ph.videoCamera,
              ActivityKind.microphone => Ph.microphone,
              ActivityKind.control || ActivityKind.remote => Ph.mouseSimple,
              _ => Ph.bellRinging,
            },
            size: 14,
            color: s.muted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$title · $time',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: s.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
