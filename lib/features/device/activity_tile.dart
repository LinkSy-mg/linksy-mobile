import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/activity.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../sharing/webcam_screen.dart';

IconData activityIcon(Activity a) => switch (a.kind) {
  ActivityKind.files when a.names.length > 1 =>
    _mediaOf(a.names) == null ? Ph.files : Ph.images,
  ActivityKind.files when a.names.isNotEmpty => fileIcon(a.names.first),
  ActivityKind.files => Ph.file,
  ActivityKind.clipboard => Ph.clipboardText,
  ActivityKind.ping => Ph.bellRinging,
  ActivityKind.screen => Ph.screencast,
  ActivityKind.camera => Ph.videoCamera,
  ActivityKind.control => Ph.cursorClick,
  ActivityKind.display => Ph.monitor,
  ActivityKind.link => Ph.link,
  ActivityKind.ring => Ph.bellSimpleRinging,
  ActivityKind.remote => Ph.mouseSimple,
  ActivityKind.watch => Ph.monitor,
  ActivityKind.microphone => Ph.microphone,
  ActivityKind.locate => Ph.mapPin,
};

/// What several files are: all 'photo', all 'video', 'media' (both), or
/// null for anything else.
String? _mediaOf(List<String> names) {
  final kinds = {
    for (final n in names)
      switch (fileIcon(n)) {
        Ph.fileImage => 'photo',
        Ph.fileVideo => 'video',
        _ => 'other',
      },
  };
  if (kinds.contains('other') || kinds.isEmpty) return null;
  return kinds.length == 1 ? kinds.single : 'media';
}

/// File name, "N items", quoted clipboard text or the ping title.
String activityTitle(Activity a) => switch (a.kind) {
  ActivityKind.files when a.names.length == 1 => a.names.first,
  ActivityKind.files => switch (_mediaOf(a.names)) {
    'photo' => tr.activityPhotos(a.names.length),
    'video' => tr.activityVideos(a.names.length),
    'media' => tr.activityPhotosVideos(a.names.length),
    _ => tr.activityItems(a.names.length),
  },
  ActivityKind.clipboard when a.names.isNotEmpty => a.names.first,
  ActivityKind.clipboard when a.text != null => tr.activityQuoted(
    a.text!.trim(),
  ),
  ActivityKind.clipboard => tr.activityClipboardText,
  ActivityKind.ping => a.text ?? tr.activityPing,
  ActivityKind.screen => tr.activityYourScreen,
  ActivityKind.camera => tr.activityYourCamera,
  ActivityKind.control => tr.activityYourScreen,
  ActivityKind.display => tr.activitySecondDisplay,
  ActivityKind.link => linkLabel(a.text ?? tr.activityLink),
  ActivityKind.ring =>
    a.incoming ? tr.activityRangThisPhone : tr.activityRangIt,
  ActivityKind.remote => tr.activityTouchpadKeyboard,
  ActivityKind.watch => tr.activityItsScreen,
  ActivityKind.microphone => tr.activityYourMicrophone,
  ActivityKind.locate => tr.activityWhereThisPhone,
};

/// A link without its scheme, "example.com/page".
String linkLabel(String url) =>
    url.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');

/// "Received · 2.1 MB", "Declined".
String activityDetail(Activity a) {
  final live = a.isLive;
  if (a.kind == ActivityKind.screen) {
    return live ? tr.activityWatchingNow : tr.activityWatched;
  }
  if (a.kind == ActivityKind.camera) {
    return live ? tr.activityInUseWebcam : tr.activityUsedWebcam;
  }
  if (a.kind == ActivityKind.control) {
    return live ? tr.activityBeingControlled : tr.activityWatchedControlled;
  }
  if (a.kind == ActivityKind.watch) {
    return a.isLive ? tr.activityWatchingNow : tr.activityWatchedFromPhone;
  }
  if (a.kind == ActivityKind.remote) {
    return a.isLive ? tr.activityInUseNow : tr.activityWasTouchpad;
  }
  if (a.kind == ActivityKind.display) {
    return live ? tr.activityInUseNow : tr.activityWasSecondDisplay;
  }
  if (a.kind == ActivityKind.link) {
    return a.incoming ? tr.activityLinkReceived : tr.activityOpenedOnComputer;
  }
  if (a.kind == ActivityKind.microphone) {
    return live ? tr.activityInUseMicrophone : tr.activityUsedMicrophone;
  }
  if (a.kind == ActivityKind.locate) {
    return a.status == ActivityStatus.declined
        ? (a.text ?? tr.activityNotTold)
        : tr.activityToldWhere;
  }
  if (a.kind == ActivityKind.ring) {
    return a.incoming ? tr.activityAskedToFind : tr.activityToFindIt;
  }
  final verb = switch (a.status) {
    ActivityStatus.declined => tr.activityDeclined,
    ActivityStatus.failed => a.reason ?? tr.activityFailed,
    ActivityStatus.waiting || ActivityStatus.active => tr.activityInProgress,
    _ when a.kind == ActivityKind.clipboard && a.incoming =>
      tr.activityCopiedHere,
    _ => a.incoming ? tr.activityReceived : tr.activitySent,
  };
  return [
    verb,
    if (a.kind == ActivityKind.files && a.total > 0) formatBytes(a.total),
  ].join(' · ');
}

/// One row of a device's timeline: the time, a node on the rail (blue
/// outgoing, cyan incoming, red failed or declined), and a card.
class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.activity,
    this.first = false,
    this.last = false,
  });

  final Activity activity;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final s = Sig.of(context);
    final bad =
        a.status == ActivityStatus.failed ||
        a.status == ActivityStatus.declined;
    final color = bad
        ? s.red
        : a.incoming
        ? Sig.incoming
        : Sig.outgoing;
    final c = LinksyScope.of(context);
    final webcam = a.kind == ActivityKind.camera && a.isLive
        ? c.sharing[a.id]
        : null;
    final openable =
        (a.incoming && a.saved.isNotEmpty) ||
        (a.kind == ActivityKind.link && a.text != null) ||
        webcam != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatClock(a.time),
                  textAlign: TextAlign.right,
                  style: sora(12.5, weight: FontWeight.w500, color: s.muted),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: CustomPaint(
              painter: _Rail(
                color: color,
                line: s.line,
                first: first,
                last: last,
                live: a.isLive,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 5, 16, 5),
              child: _Box(
                // Files and what's running get a card; the small things
                // (a ping, a link, copied text) a plain line.
                card:
                    a.kind == ActivityKind.files ||
                    a.isLive ||
                    a.names.isNotEmpty,
                onTap: !openable
                    ? null
                    : webcam != null
                    // The webcam running: back to its controls.
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WebcamScreen(share: webcam),
                        ),
                      )
                    : () => open(context, a),
                child: Row(
                  children: [
                    Icon(activityIcon(a), color: color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activityTitle(a),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: s.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (a.isLive && !_isSession(a))
                            _Live(activity: a, color: color)
                          else
                            Row(
                              children: [
                                Icon(
                                  a.incoming
                                      ? PhBold.arrowDownLeft
                                      : PhBold.arrowUpRight,
                                  size: 12,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    activityDetail(a),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: bad ? s.red : s.muted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    ?_trailing(context, a, s),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _trailing(BuildContext context, Activity a, Sig s) {
    Widget button(IconData icon, String tip, VoidCallback onTap) => Tooltip(
      message: tip,
      child: Pressable(
        onTap: onTap,
        scale: 0.85,
        semanticLabel: tip,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 19, color: s.muted),
        ),
      ),
    );

    if (a.isLive && _isSession(a)) {
      final c = LinksyScope.read(context);
      return button(
        Ph.x,
        context.l10n.activityStop,
        () => switch (a.kind) {
          ActivityKind.display || ActivityKind.watch => c.stopDisplay(a.id),
          ActivityKind.remote => c.stopRemote(a.deviceId),
          _ => c.stopSharing(a.id),
        },
      );
    }
    if (a.isLive && (!a.incoming || a.status == ActivityStatus.active)) {
      return button(
        Ph.x,
        context.l10n.activityCancel,
        () => report(context, LinksyScope.read(context).cancel(a.id)),
      );
    }
    if (a.kind == ActivityKind.clipboard && a.text != null) {
      return button(Ph.copy, context.l10n.activityCopyAgain, () async {
        await Clipboard.setData(ClipboardData(text: a.text!));
        if (context.mounted) showMessage(context, context.l10n.activityCopied);
      });
    }
    if (a.kind == ActivityKind.link && a.text != null) {
      return button(Ph.copy, context.l10n.activityCopyLink, () async {
        await Clipboard.setData(ClipboardData(text: a.text!));
        if (context.mounted) {
          showMessage(context, context.l10n.activityLinkCopied);
        }
      });
    }
    if (a.incoming && a.saved.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Icon(Ph.arrowSquareOut, size: 18, color: s.faint),
      );
    }
    return null;
  }

  static bool _isSession(Activity a) => const [
    ActivityKind.microphone,
    ActivityKind.screen,
    ActivityKind.camera,
    ActivityKind.control,
    ActivityKind.display,
    ActivityKind.remote,
    ActivityKind.watch,
  ].contains(a.kind);

  /// Opens what it holds: its link, its file, or a choice of its files.
  static Future<void> open(BuildContext context, Activity a) async {
    if (a.kind == ActivityKind.link) {
      if (!await LinksyPlatform.openUrl(a.text!) && context.mounted) {
        showMessage(context, context.l10n.activityNoAppForLink);
      }
      return;
    }
    if (a.saved.length == 1) return _openFile(context, a.saved.single);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheet) {
        final s = Sig.of(sheet);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                sheet.l10n.activityFiles(a.saved.length),
                textAlign: TextAlign.center,
                style: sora(20, color: s.ink),
              ),
              const SizedBox(height: 16),
              for (final path in a.saved)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SigCard(
                    onTap: () => _openFile(sheet, path),
                    color: s.bg,
                    child: Row(
                      children: [
                        Icon(fileIcon(path), color: Sig.incoming),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            path.split('/').last,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: s.ink,
                            ),
                          ),
                        ),
                        Icon(Ph.arrowSquareOut, size: 18, color: s.faint),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _openFile(BuildContext context, String path) =>
      openReceived(context, path);
}

/// Opens a received file (a path or a `content://` URI) in whatever app
/// takes it; says so when it's gone or nothing does.
Future<void> openReceived(BuildContext context, String path) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final name = path.split('/').last;
  final result = await LinksyPlatform.openFile(path);
  if (result == 'done') return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        result == 'missing'
            ? l10n.activityFileMissing(name)
            : l10n.activityNoAppForFile(name),
      ),
    ),
  );
}

/// The rail: a hairline through the day, a node for this entry.
class _Rail extends CustomPainter {
  _Rail({
    required this.color,
    required this.line,
    required this.first,
    required this.last,
    required this.live,
  });

  final Color color;
  final Color line;
  final bool first;
  final bool last;
  final bool live;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    // Level with the entry's icon, which its row centers.
    final nodeY = size.height / 2;
    final rail = Paint()
      ..color = line
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(x, first ? nodeY : 0),
      Offset(x, last ? nodeY : size.height),
      rail,
    );
    if (live) {
      canvas.drawCircle(
        Offset(x, nodeY),
        10,
        Paint()..color = color.withValues(alpha: 0.2),
      );
    }
    canvas.drawCircle(Offset(x, nodeY), 6, Paint()..color = color);
    canvas.drawCircle(Offset(x, nodeY), 2.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_Rail old) =>
      old.color != color ||
      old.line != line ||
      old.first != first ||
      old.last != last ||
      old.live != live;
}

class _Live extends StatelessWidget {
  const _Live({required this.activity, required this.color});

  final Activity activity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final s = Sig.of(context);
    final String text;
    final double? value;
    if (a.status == ActivityStatus.waiting) {
      final name = LinksyScope.of(context).device(a.deviceId)?.device.name;
      text = a.incoming
          ? context.l10n.activityWaitingForYou
          : name == null
          ? context.l10n.activityWaitingForDevice
          : context.l10n.activityWaitingFor(name);
      value = null;
    } else {
      text = [
        context.l10n.activityProgress(
          formatBytes(a.bytes),
          formatBytes(a.total),
        ),
        if (a.speed > 0) formatSpeed(a.speed),
        if (a.speed > 0) formatTimeLeft(a.total - a.bytes, a.speed),
      ].join(' · ');
      value = a.total == 0 ? null : a.bytes / a.total;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 12.5, color: s.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: LinearProgressIndicator(value: value, color: color),
        ),
      ],
    );
  }
}

/// A timeline entry's box: a card, or the same padding with no card.
class _Box extends StatelessWidget {
  const _Box({required this.card, required this.child, this.onTap});

  final bool card;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(14, 12, 6, 12);
    if (card) {
      return SigCard(
        onTap: onTap,
        padding: padding,
        radius: Radii.md + 2,
        child: child,
      );
    }
    final plain = Padding(padding: padding, child: child);
    return onTap == null ? plain : Pressable(onTap: onTap, child: plain);
  }
}
