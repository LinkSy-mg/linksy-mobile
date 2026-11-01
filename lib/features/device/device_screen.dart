import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/activity.dart';
import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../remote/remote_screen.dart';
import '../sharing/sharing.dart';
import '../sharing/webcam_screen.dart';
import '../terminal/terminal_screen.dart';
import '../../app/terminals.dart';
import 'activity_tile.dart';
import '../transfer/transfer_bubble.dart';

/// Send files: photos and videos from the gallery, or any file. Whatever
/// is picked goes as one offer, so the computer asks once.
Future<void> pickAndSend(BuildContext context, String deviceId) async {
  final c = LinksyScope.read(context);
  final media = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheet) {
      final l10n = sheet.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.deviceSendFiles,
                style: sora(24, color: Sig.of(sheet).ink),
              ),
              const SizedBox(height: 18),
              SheetOption(
                icon: Ph.images,
                title: l10n.sendPhotos,
                caption: l10n.sendPhotosCaption,
                primary: true,
                onTap: () => Navigator.of(sheet).pop(true),
              ),
              const SizedBox(height: 10),
              SheetOption(
                icon: Ph.folderOpen,
                title: l10n.sendFiles,
                caption: l10n.sendFilesCaption,
                onTap: () => Navigator.of(sheet).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (media == null) return;
  final paths = media
      ? await LinksyPlatform.pickMedia()
      : await LinksyPlatform.pickFiles();
  if (paths.isEmpty || !context.mounted) return;
  await report(context, c.sendFiles(deviceId, paths));
}

/// A device's page: big actions, then everything shared with it, as a
/// timeline by day.
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late final LinksyController _c;

  /// The timeline's filter: null for everything.
  ActivityKind? _filter;

  String get deviceId => widget.deviceId;

  // A computer's players show here while the page is open.
  @override
  void initState() {
    super.initState();
    _c = LinksyScope.read(context);
    _c.watchMedia(deviceId);
  }

  @override
  void dispose() {
    _c.unwatchMedia(deviceId);
    _volumeSteps(false);
    super.dispose();
  }

  /// While this page is in front and shows the computer's volume, the
  /// phone's volume keys step it (5 % a press) instead of the phone's.
  bool _stepping = false;
  StreamSubscription<bool>? _steps;

  void _volumeSteps(bool on) {
    if (on == _stepping) return;
    _stepping = on;
    LinksyPlatform.volumeSteps(on);
    _steps?.cancel();
    _steps = on
        ? LinksyPlatform.volumeKeys.listen((up) {
            final v = _c.volume[deviceId];
            if (v == null) return;
            _c.setVolume(
              deviceId,
              level: (v.level + (up ? 0.05 : -0.05)).clamp(0.0, 1.0),
              muted: up && v.muted ? false : null,
            );
          })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final view = c.device(deviceId);
    if (view == null || !view.trusted) {
      // Forgotten while open.
      return const Scaffold(body: SizedBox.shrink());
    }
    final volume = view.connected ? c.volume[deviceId] : null;
    final front = ModalRoute.of(context)?.isCurrent ?? false;
    scheduleMicrotask(() {
      if (mounted) _volumeSteps(front && volume != null);
    });
    final all = c.activityFor(deviceId);
    final days = _byDay([
      for (final a in all)
        if (_filter == null || a.kind == _filter) a,
    ]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayFor(Brightness.dark),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  systemOverlayStyle: overlayFor(Brightness.dark),
                  // The banner's top under its shadow, so the two meet without
                  // a seam.
                  backgroundColor: Color.alphaBlend(
                    const Color(0x590A1024),
                    Sig.deep,
                  ),
                ),
                // One box, so the actions paint over the hero they overlap.
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _Hero(view: view),
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: _Actions(view: view),
                      ),
                      // Its screen being shared from here, with Stop.
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: SharingBanners(
                          controller: c,
                          deviceId: deviceId,
                          kinds: const {
                            SessionKind.screen,
                            SessionKind.control,
                          },
                        ),
                      ),
                      if (_isComputer(view.device)) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _WatchScreen(view: view),
                        ),
                        // Only computers that announce it (desktop 0.7, §4.15).
                        if (view.device.features.contains('terminal'))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: _TerminalCard(view: view),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _PhoneAs(view: view),
                        ),
                      ],
                      if (c.media[deviceId]?.players case final players?
                          when players.isNotEmpty)
                        for (final p in players)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: _NowPlaying(deviceId: deviceId, player: p),
                          ),
                      if (volume != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _Volume(deviceId: deviceId, volume: volume),
                        ),
                      if (_isComputer(view.device))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _Switches(view: view),
                        ),
                    ],
                  ),
                ),
                if (all.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _Filters(
                      selected: _filter,
                      onSelected: (k) => setState(() => _filter = k),
                    ),
                  ),
                if (all.isEmpty)
                  SliverToBoxAdapter(child: _NoActivity(name: view.device.name))
                else if (days.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Text(
                        context.l10n.deviceNothingOfKind,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Sig.of(context).muted),
                      ),
                    ),
                  )
                else
                  for (final (day, entries) in days) ...[
                    SliverToBoxAdapter(child: SectionLabel(day)),
                    SliverList.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, i) => TimelineEntry(
                        activity: entries[i],
                        first: i == 0,
                        last: i == entries.length - 1,
                      ),
                    ),
                  ],
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 32 + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            ),
            // Files on their way, from any page.
            const TransferBubble(),
          ],
        ),
      ),
    );
  }

  static bool _isComputer(DeviceInfo d) =>
      d.kind == DeviceKind.desktop || d.kind == DeviceKind.laptop;

  static List<(String, List<Activity>)> _byDay(List<Activity> entries) {
    final days = <(String, List<Activity>)>[];
    for (final a in entries) {
      final day = formatDay(a.time);
      if (days.isEmpty || days.last.$1 != day) days.add((day, []));
      days.last.$2.add(a);
    }
    return days;
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.view});

  final DeviceView view;

  /// Tall enough for the name and its lines, plus the 64 px the action card
  /// overlaps at the bottom.
  static const height = 330.0;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final d = view.device;
    final picture = c.pictureOf(d.id);

    final notNearby = view.presence == Presence.notNearby;
    final chipColor = presenceColor(s, view.presence, onBlue: true);
    final details = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          d.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: sora(30, weight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          [
            if (view.battery case final b? when !notNearby)
              b.charging
                  ? context.l10n.deviceBatteryCharging(b.level)
                  : context.l10n.deviceBattery(b.level),
            d.description,
          ].join(' · '),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        // How it's reached, small, under its kind.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notNearby)
              const Icon(Ph.wifiSlash, size: 13, color: Colors.white54)
            else if (view.connected && view.usb)
              Icon(Ph.usb, size: 13, color: chipColor)
            else if (view.connected && view.away)
              Icon(Ph.globeHemisphereWest, size: 13, color: chipColor)
            else
              PulseDot(color: chipColor, size: 6),
            const SizedBox(width: 5),
            Text(
              linkWords(view),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: chipColor,
              ),
            ),
          ],
        ),
        if (view.presence == Presence.notNearby &&
            (c.settings?.away ?? false) &&
            view.trusted)
          if (view.awayUntil case final until?
              when until.isAfter(DateTime.now())) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Ph.globeHemisphereWest,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    context.l10n.deviceReachableUntil(formatDay(until)),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ],
        if (c.lockWatchers.containsKey(d.id)) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Ph.lockSimple, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                context.l10n.deviceLocksWhenLeave,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ],
    );

    Widget button(IconData icon, String tip, VoidCallback onTap) =>
        RoundButton(icon: icon, tooltip: tip, onDark: true, onTap: onTap);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (picture != null)
              Image.file(
                File(picture),
                key: ValueKey(c.pictureVersion),
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            else
              const _GridBanner(),
            // An inner shadow: deep at the bottom, where the name sits, and
            // light at the top, under the buttons; the picture or the grid
            // fades into it. (The one gradient in the app, on purpose.)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x590A1024),
                    Color(0x000A1024),
                    Color(0x000A1024),
                    Color(0xCC0A1024),
                    Color(0xF20A1024),
                  ],
                  stops: [0, 0.22, 0.38, 0.72, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: Row(
                children: [
                  button(
                    Ph.arrowLeft,
                    context.l10n.deviceBack,
                    () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  button(
                    Ph.dotsThree,
                    context.l10n.deviceMore,
                    () => _more(context, d),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 64,
              child: Center(child: details),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _more(BuildContext context, DeviceInfo d) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (sheet) {
          final s = Sig.of(sheet);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    d.name,
                    textAlign: TextAlign.center,
                    style: sora(20, color: s.ink),
                  ),
                  Text(
                    context.l10n.deviceShortId(d.shortId),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: s.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  SigButton(
                    label: LinksyScope.read(context).pictures.containsKey(d.id)
                        ? context.l10n.deviceChangePicture
                        : context.l10n.deviceAddPicture,
                    icon: Ph.images,
                    kind: SigButtonKind.secondary,
                    expand: true,
                    onTap: () {
                      Navigator.of(sheet).pop();
                      LinksyScope.read(context).pickPicture(d.id);
                    },
                  ),
                  if (LinksyScope.read(context).pictures.containsKey(d.id)) ...[
                    const SizedBox(height: 10),
                    SigButton(
                      label: context.l10n.deviceRemovePicture,
                      kind: SigButtonKind.quiet,
                      expand: true,
                      onTap: () {
                        Navigator.of(sheet).pop();
                        LinksyScope.read(context).removePicture(d.id);
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  SigButton(
                    label: context.l10n.deviceForgetThis,
                    icon: Ph.linkBreak,
                    kind: SigButtonKind.secondary,
                    expand: true,
                    onTap: () {
                      Navigator.of(sheet).pop();
                      _forget(context, d);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

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
    Navigator.of(context).pop();
    await c.forget(d.id);
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.read(context);
    final s = Sig.of(context);
    final id = view.device.id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Pressable(
            onTap: () => pickAndSend(context, id),
            semanticLabel: context.l10n.deviceSendFiles,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
              // White on the blue header it overlaps; the blue is in the button.
              decoration: BoxDecoration(
                color: s.card,
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.deviceSendFiles,
                          style: sora(21, color: s.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.deviceSendFilesCaption,
                          style: TextStyle(fontSize: 13.5, color: s.muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Sig.blue,
                    ),
                    child: const Icon(
                      PhFill.paperPlaneTilt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallAction(
                  icon: Ph.clipboardText,
                  title: context.l10n.deviceClipboard,
                  caption: context.l10n.deviceClipboardCaption,
                  onTap: () => report(context, c.sendClipboard(id)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallAction(
                  icon: Ph.bellRinging,
                  title: context.l10n.devicePing,
                  caption: context.l10n.devicePingCaption,
                  onTap: () => report(context, c.ping(id)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SmallAction(
                  icon: Ph.mouseSimple,
                  title: context.l10n.deviceRemote,
                  caption: context.l10n.deviceRemoteCaption,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RemoteScreen(device: view.device),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _FindAction(view: view)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The banner without a picture: deep blue with a fine grid, which the
/// banner's shadow fades out toward the name.
class _GridBanner extends StatelessWidget {
  const _GridBanner();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _Grid(), child: SizedBox.expand());
}

class _Grid extends CustomPainter {
  const _Grid();

  static const _cell = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Sig.deep);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 1;
    // Centered, so the grid sits evenly on any width.
    final dx = (size.width % _cell) / 2;
    for (var x = dx; x <= size.width; x += _cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y <= size.height; y += _cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_Grid oldDelegate) => false;
}

/// "Find my computer": rings it until stopped (or 30 s), so it can be found.
class _FindAction extends StatelessWidget {
  const _FindAction({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final id = view.device.id;
    final ringing = c.isFinding(id);
    return _SmallAction(
      icon: ringing ? PhFill.bellRinging : Ph.binoculars,
      title: ringing ? context.l10n.deviceRinging : context.l10n.deviceFindIt,
      caption: ringing
          ? context.l10n.deviceTapToStop
          : context.l10n.deviceFindItCaption,
      active: ringing,
      onTap: () => report(context, ringing ? c.stopFinding(id) : c.find(id)),
    );
  }
}

/// What a computer plays (its MPRIS players): play/pause and skip, and when
/// it can seek, 10 seconds back and forward and where in the track.
class _NowPlaying extends StatefulWidget {
  const _NowPlaying({required this.deviceId, required this.player});

  final String deviceId;
  final MediaPlayer player;

  @override
  State<_NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<_NowPlaying> {
  /// When [MediaPlayer.positionMs] came: the computer says where it is only
  /// when that changes, so the bar moves on by itself in between.
  DateTime _since = DateTime.now();
  Timer? _tick;

  /// Where the finger holds the bar, while it does.
  double? _dragging;

  @override
  void initState() {
    super.initState();
    _ticking();
  }

  @override
  void didUpdateWidget(_NowPlaying old) {
    super.didUpdateWidget(old);
    final p = widget.player, o = old.player;
    if (p.positionMs != o.positionMs || p.playing != o.playing) {
      _since = DateTime.now();
    }
    _ticking();
  }

  void _ticking() {
    final on = widget.player.playing && widget.player.lengthMs != null;
    if (on && _tick == null) {
      _tick = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    } else if (!on) {
      _tick?.cancel();
      _tick = null;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  int? get _position {
    final p = widget.player;
    final at = p.positionMs;
    if (at == null) return null;
    final now = p.playing
        ? at + DateTime.now().difference(_since).inMilliseconds
        : at;
    final length = p.lengthMs;
    return length == null ? now : now.clamp(0, length);
  }

  void _seek(int to) {
    final p = widget.player;
    final length = p.lengthMs;
    final at = length == null ? (to < 0 ? 0 : to) : to.clamp(0, length);
    report(
      context,
      LinksyScope.read(context)
          .mediaCommand(widget.deviceId, p.id, 'seek', positionMs: at),
    );
  }

  static String _time(int ms) {
    final t = Duration(milliseconds: ms);
    final s = (t.inSeconds % 60).toString().padLeft(2, '0');
    return t.inHours > 0
        ? '${t.inHours}:${(t.inMinutes % 60).toString().padLeft(2, '0')}:$s'
        : '${t.inMinutes}:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.read(context);
    final p = widget.player;
    final deviceId = widget.deviceId;
    final art = p.art;
    Uint8List? cover;
    if (art != null) {
      try {
        cover = base64Decode(art);
      } on FormatException {
        cover = null;
      }
    }
    final position = _position, length = p.lengthMs;
    final seekable = p.canSeek && position != null;
    Widget button(
      IconData icon,
      String tip,
      VoidCallback onTap, {
      bool big = false,
    }) => Tooltip(
      message: tip,
      child: Pressable(
        onTap: onTap,
        semanticLabel: tip,
        child: Container(
          width: big ? 48 : 40,
          height: big ? 48 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: big ? Sig.blue : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: big ? 22 : 20,
            color: big ? Colors.white : s.ink,
          ),
        ),
      ),
    );
    Widget control(
      IconData icon,
      String tip,
      String action, {
      bool big = false,
    }) => button(
      icon,
      tip,
      () => report(context, c.mediaCommand(deviceId, p.id, action)),
      big: big,
    );
    final controls = [
      if (seekable)
        button(
          Ph.clockCounterClockwise,
          context.l10n.deviceBack10,
          () => _seek(position - 10000),
        ),
      if (p.canPrevious)
        control(PhFill.skipBack, context.l10n.devicePrevious, 'previous'),
      control(
        p.playing ? PhFill.pause : PhFill.play,
        p.playing ? context.l10n.devicePause : context.l10n.devicePlay,
        'play_pause',
        big: true,
      ),
      if (p.canNext)
        control(PhFill.skipForward, context.l10n.deviceNext, 'next'),
      if (seekable)
        button(
          Ph.clockClockwise,
          context.l10n.deviceForward10,
          () => _seek(position + 10000),
        ),
    ];
    final info = Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.sm),
          child: SizedBox(
            width: 52,
            height: 52,
            child: cover != null
                ? Image.memory(
                    cover,
                    // Decoded at the size shown, not the cover's own.
                    cacheWidth: (52 * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : ColoredBox(
                    color: s.raised,
                    child: Icon(Ph.musicNotes, color: s.muted),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title.isEmpty ? p.app : p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: s.ink,
                ),
              ),
              Text(
                [if (p.artist.isNotEmpty) p.artist, p.app].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: s.muted),
              ),
            ],
          ),
        ),
        if (!seekable) ...controls,
      ],
    );
    if (!seekable) {
      return SigCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: info,
      );
    }
    final shown = _dragging?.round() ?? position;
    final times = TextStyle(
      fontSize: 12,
      color: s.muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SigCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          info,
          if (length != null && length > 0) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Sig.blue,
                thumbColor: Sig.blue,
                inactiveTrackColor: s.raised,
              ),
              child: Slider(
                value: shown.clamp(0, length).toDouble(),
                max: length.toDouble(),
                semanticFormatterCallback: (v) => _time(v.round()),
                onChanged: (v) => setState(() => _dragging = v),
                onChangeEnd: (v) {
                  setState(() => _dragging = null);
                  _seek(v.round());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_time(shown), style: times),
                  Text(_time(length), style: times),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: controls,
          ),
        ],
      ),
    );
  }
}

/// The computer's own volume (desktop 0.9.8): a slider and mute.
class _Volume extends StatefulWidget {
  const _Volume({required this.deviceId, required this.volume});

  final String deviceId;
  final VolumeState volume;

  @override
  State<_Volume> createState() => _VolumeState();
}

class _VolumeState extends State<_Volume> {
  /// Where the finger holds the slider, while it does.
  double? _dragging;

  /// A dragged slider tells the computer about 10 times a second.
  DateTime _sent = DateTime(0);

  void _set(double level, {bool last = false}) {
    final now = DateTime.now();
    if (!last && now.difference(_sent) < const Duration(milliseconds: 100)) {
      return;
    }
    _sent = now;
    report(
      context,
      LinksyScope.read(context).setVolume(
        widget.deviceId,
        level: level,
        // Moving it unmutes, as on phones.
        muted: widget.volume.muted ? false : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final v = widget.volume;
    final level = _dragging ?? v.level;
    final silent = v.muted || level == 0;
    final tip = v.muted ? context.l10n.deviceUnmute : context.l10n.deviceMute;
    return SigCard(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          Tooltip(
            message: tip,
            child: Pressable(
              onTap: () => report(
                context,
                LinksyScope.read(context)
                    .setVolume(widget.deviceId, muted: !v.muted),
              ),
              semanticLabel: tip,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  silent
                      ? Ph.speakerSlash
                      : level < 0.5
                      ? Ph.speakerLow
                      : Ph.speakerHigh,
                  size: 22,
                  color: v.muted ? s.muted : Sig.blue,
                ),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: v.muted ? s.muted : Sig.blue,
                thumbColor: v.muted ? s.muted : Sig.blue,
                inactiveTrackColor: s.raised,
              ),
              child: Slider(
                value: level,
                semanticFormatterCallback: (l) =>
                    context.l10n.deviceVolume('${(l * 100).round()}'),
                onChanged: (l) {
                  setState(() => _dragging = l);
                  _set(l);
                },
                onChangeEnd: (l) {
                  setState(() => _dragging = null);
                  _set(l, last: true);
                },
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(level * 100).round()} %',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                color: s.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A computer's screen on this phone: just watch it, or drive it with touch.
/// Its user allows it and picks the screen there.
class _WatchScreen extends StatelessWidget {
  const _WatchScreen({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.read(context);
    final id = view.device.id;
    Widget button(String label, bool control) => Expanded(
      child: SigButton(
        label: label,
        kind: control ? SigButtonKind.primary : SigButtonKind.secondary,
        height: 44,
        onTap: () {
          showMessage(context, context.l10n.deviceAllowOn(view.device.name));
          report(context, c.watchScreen(id, control: control));
        },
      ),
    );
    return SigCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconCircle(icon: Ph.monitor, color: Sig.blue, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.deviceSeeScreen,
                      style: sora(16, color: s.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.deviceSeeScreenCaption,
                      style: TextStyle(fontSize: 12.5, color: s.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              button(context.l10n.deviceWatch, false),
              const SizedBox(width: 10),
              button(context.l10n.deviceControl, true),
            ],
          ),
        ],
      ),
    );
  }
}

/// A shell on the computer, behind its terminal code.
class _TerminalCard extends StatelessWidget {
  const _TerminalCard({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final open = c.terminals
        .of(view.device.id)
        .where((t) => t.state != TabState.ended)
        .length;
    return SigCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TerminalScreen(deviceId: view.device.id),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          IconCircle(icon: Ph.terminalWindow, color: Sig.blue, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.deviceTerminal,
                  style: sora(16, color: s.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  open == 0
                      ? context.l10n.deviceTerminalShell(view.device.name)
                      : context.l10n.deviceTerminalsOpen(open),
                  style: TextStyle(fontSize: 12.5, color: s.muted),
                ),
              ],
            ),
          ),
          Icon(Ph.caretRight, color: s.faint, size: 18),
        ],
      ),
    );
  }
}

/// "Activity" and its filters: All, Files, Clipboard, Links.
class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});

  final ActivityKind? selected;
  final ValueChanged<ActivityKind?> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l10n = context.l10n;
    final options = [
      (l10n.deviceFilterAll, l10n.deviceFilterShowAll, null),
      (l10n.deviceFilterFiles, l10n.deviceFilterShowFiles, ActivityKind.files),
      (
        l10n.deviceFilterClipboard,
        l10n.deviceFilterShowClipboard,
        ActivityKind.clipboard,
      ),
      (l10n.deviceFilterLinks, l10n.deviceFilterShowLinks, ActivityKind.link),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.deviceActivity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, semantic, kind) in options)
                Pressable(
                  onTap: () => onSelected(kind),
                  semanticLabel: semantic,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected == kind ? Sig.blue : s.card,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: selected == kind ? Colors.white : s.ink,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What this phone is for the computer right now, or could be: its webcam,
/// microphone and second display. The computer starts them.
class _PhoneAs extends StatelessWidget {
  const _PhoneAs({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final d = view.device;
    SessionStarted? live(SessionKind kind) => c.sharing.values
        .where((e) => e.peer.id == d.id && e.kind == kind)
        .firstOrNull;
    final camera = live(SessionKind.camera);
    final mic = live(SessionKind.microphone);
    final display = c.displays.values
        .where((e) => e.peer.id == d.id && e.kind == SessionKind.display)
        .firstOrNull;
    final ready = context.l10n.deviceReadyWhenAsks(d.name);
    final size = c.screenSize;

    Widget action(String label, VoidCallback onTap, {bool primary = false}) =>
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: primary ? Sig.blue : s.raised,
              foregroundColor: primary ? Colors.white : Sig.blue,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: Text(label),
          ),
        );

    final rows = [
      if (d.can('camera'))
        _PhoneAsRow(
          icon: Ph.videoCamera,
          title: context.l10n.deviceWebcam,
          live: camera != null,
          detail: camera != null ? context.l10n.deviceInUseNow : ready,
          action: camera == null
              ? null
              : action(
                  context.l10n.deviceControls,
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WebcamScreen(share: camera),
                    ),
                  ),
                ),
        ),
      if (d.can('microphone'))
        _PhoneAsRow(
          icon: Ph.microphone,
          title: context.l10n.deviceMicrophone,
          live: mic != null,
          detail: mic != null ? context.l10n.deviceInUseNow : ready,
          action: mic == null
              ? null
              : action(
                  context.l10n.deviceStop,
                  () => c.stopSharing(mic.session),
                ),
        ),
      if (d.can('display'))
        _PhoneAsRow(
          icon: Ph.monitor,
          title: context.l10n.deviceSecondDisplay,
          live: display != null,
          detail: display != null
              ? context.l10n.deviceShowingNow
              : size == null
              ? ready
              : context.l10n.deviceReadySize(size.$1, size.$2),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return SigCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  context.l10n.devicePhoneAs,
                  style: sora(16, color: s.ink),
                ),
              ),
              Text(
                context.l10n.deviceStartedOn(d.name),
                style: TextStyle(fontSize: 12.5, color: s.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: s.line),
            rows[i],
          ],
          if (!view.usb) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.deviceFasterOverUsb,
              style: TextStyle(fontSize: 12.5, color: s.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhoneAsRow extends StatelessWidget {
  const _PhoneAsRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.live,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool live;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final cyanText = s.bg.computeLuminance() > 0.5
        ? const Color(0xFF0E8FAE)
        : Sig.cyanLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: live ? Sig.blue : s.raised,
            ),
            child: Icon(icon, size: 18, color: live ? Colors.white : Sig.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: s.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (live) ...[
                      const PulseDot(color: Sig.cyan, size: 6),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: live ? FontWeight.w600 : null,
                          color: live ? cyanText : s.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// This computer's switches in one card: photo backup, its clipboard, what
/// it may do from away.
class _Switches extends StatelessWidget {
  const _Switches({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final id = view.device.id;
    final name = view.device.name;
    final photos = c.backsUpPhotos(id);
    final at = c.photosBackedUp(id);
    final declined = photos && c.photosDeclined(id);
    final rows = [
      _SwitchRow(
        icon: Ph.images,
        title: context.l10n.deviceBackUpPhotos,
        detail: !photos
            ? context.l10n.devicePhotosGoTo(name)
            : declined
            ? context.l10n.devicePhotosDeclined(name)
            : [
                if (c.photosFolder case final folder?)
                  context.l10n.devicePhotosFrom(folder)
                else
                  context.l10n.devicePhotosFromCamera,
                if (at != null) context.l10n.devicePhotosLast(formatClock(at)),
              ].join(' · '),
        warn: declined,
        value: photos,
        onChanged: (v) => c.setPhotoBackup(id, v),
      ),
      if (view.device.features.contains('clipboard_watch'))
        _SwitchRow(
          icon: Ph.clipboard,
          title: context.l10n.deviceGetClipboard,
          detail: context.l10n.deviceGetClipboardDetail(name),
          value: c.watchesClipboard(id),
          onChanged: (v) => c.setClipboardWatch(id, v),
        ),
      _SwitchRow(
        icon: Ph.globeHemisphereWest,
        title: context.l10n.deviceAwayAll,
        detail: view.awayAll
            ? context.l10n.deviceAwayAllOn
            : context.l10n.deviceAwayAllOff,
        value: view.awayAll,
        onChanged: (v) => report(context, c.setAwayAll(id, v)),
      ),
    ];
    return SigCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: s.line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
    this.warn = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
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
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: warn ? s.red : s.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  /// Blue while it's going on (ringing).
  final bool active;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SigCard(
      onTap: onTap,
      color: active ? Sig.blue : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          active
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Sig.deep,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                )
              : IconCircle(icon: icon, color: Sig.blue, size: 40),
          const SizedBox(height: 14),
          Text(title, style: sora(16, color: active ? Colors.white : s.ink)),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12.5,
              color: active ? Colors.white70 : s.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActivity extends StatelessWidget {
  const _NoActivity({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 0),
      child: Column(
        children: [
          Icon(Ph.arrowsLeftRight, size: 34, color: s.faint),
          const SizedBox(height: 12),
          Text(context.l10n.deviceNothingShared, style: sora(17, color: s.ink)),
          const SizedBox(height: 6),
          Text(
            context.l10n.deviceNothingSharedBody(name),
            textAlign: TextAlign.center,
            style: TextStyle(color: s.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
