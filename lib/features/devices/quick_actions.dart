import 'package:flutter/material.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/responsive.dart';
import '../../ui/sig.dart';
import '../deck/deck_screen.dart';
import '../device/device_screen.dart';
import '../remote/remote_screen.dart';
import '../terminal/terminal_screen.dart';

/// What a computer's row on Home can do without opening it (mobile#24).
enum HomeAction {
  clipboard,
  ping,
  find,
  snap,
  remote,
  deck,
  terminal,
  playPause,
  previous,
  next,
  mute;

  IconData get icon => switch (this) {
    clipboard => Ph.clipboardText,
    ping => Ph.bellRinging,
    find => Ph.binoculars,
    snap => Ph.camera,
    remote => Ph.mouseSimple,
    deck => Ph.squaresFour,
    terminal => Ph.terminalWindow,
    playPause => PhFill.play,
    previous => PhFill.skipBack,
    next => PhFill.skipForward,
    mute => Ph.speakerSlash,
  };

  String label(AppLocalizations l) => switch (this) {
    clipboard => l.deviceClipboard,
    ping => l.devicePing,
    find => l.deviceFindIt,
    snap => l.deviceSnap,
    remote => l.deviceRemote,
    deck => l.deviceDeck,
    terminal => l.deviceTerminal,
    playPause => l.devicePlay,
    previous => l.devicePrevious,
    next => l.deviceNext,
    mute => l.deviceMute,
  };

  /// Sent, and nothing more to see: a check for a moment.
  bool get confirms => this == clipboard || this == ping;

  /// Takes the screen over.
  bool get opens => const {remote, deck, terminal, snap}.contains(this);

  /// What [d] can do at all; a player's and the volume's also need one now.
  static bool can(HomeAction a, DeviceInfo d, LinksyController c) =>
      switch (a) {
        deck => d.can('deck'),
        terminal => d.can('terminal'),
        playPause => c.playerFor(d.id) != null,
        previous => c.playerFor(d.id)?.canPrevious ?? false,
        next => c.playerFor(d.id)?.canNext ?? false,
        mute => c.volume[d.id] != null,
        _ => true,
      };
}

/// Runs [a] on [view]'s computer; null when it went, else why not.
Future<String?> _run(BuildContext context, DeviceView view, HomeAction a) {
  final c = LinksyScope.read(context);
  final d = view.device;
  final player = c.playerFor(d.id);
  Future<String?> open(Widget page) async {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    return null;
  }

  Future<String?> media(String action) async =>
      player == null ? null : c.mediaCommand(d.id, player.id, action);

  return switch (a) {
    HomeAction.clipboard => c.sendClipboard(d.id),
    HomeAction.ping => c.ping(d.id),
    HomeAction.find => c.isFinding(d.id) ? c.stopFinding(d.id) : c.find(d.id),
    HomeAction.snap => LinksyPlatform.snap(d.id).then((_) => null),
    HomeAction.remote => open(RemoteScreen(device: d)),
    HomeAction.deck => open(DeckScreen(device: d)),
    HomeAction.terminal => open(TerminalScreen(deviceId: d.id)),
    HomeAction.playPause => media('play_pause'),
    HomeAction.previous => media('previous'),
    HomeAction.next => media('next'),
    HomeAction.mute => c.setVolume(
      d.id,
      muted: !(c.volume[d.id]?.muted ?? false),
    ),
  };
}

/// What [a] looks like now: playing, muted, ringing.
(IconData, String) _now(BuildContext context, DeviceView view, HomeAction a) {
  final c = LinksyScope.of(context);
  final l = context.l10n;
  final id = view.device.id;
  return switch (a) {
    HomeAction.playPause when c.playerFor(id)?.playing ?? false => (
      PhFill.pause,
      l.devicePause,
    ),
    HomeAction.mute when c.volume[id]?.muted ?? false => (
      Ph.speakerHigh,
      l.deviceUnmute,
    ),
    HomeAction.find when c.isFinding(id) => (
      PhFill.bellRinging,
      l.deviceTapToStop,
    ),
    _ => (a.icon, a.label(l)),
  };
}

/// Keeps a computer's players and volume coming while [child] shows.
class _Watching extends StatefulWidget {
  const _Watching({required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  State<_Watching> createState() => _WatchingState();
}

class _WatchingState extends State<_Watching> {
  late final LinksyController _c = LinksyScope.read(context);

  @override
  void initState() {
    super.initState();
    _c.watchMedia(widget.id);
  }

  @override
  void dispose() {
    _c.unwatchMedia(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Everything a computer can do from Home.
Future<void> showQuickActions(BuildContext home, String id) => showSheet<void>(
  context: home,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (sheet) {
    final c = LinksyScope.of(sheet);
    final view = c.device(id);
    if (view == null) return const SizedBox.shrink();
    final s = Sig.of(sheet);
    return _Watching(
      id: id,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      view.device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(22, color: s.ink),
                    ),
                    const SizedBox(height: 14),
                    SigButton(
                      label: sheet.l10n.homeSendFiles,
                      icon: PhFill.paperPlaneTilt,
                      expand: true,
                      onTap: () {
                        Navigator.of(sheet).pop();
                        pickAndSend(home, id);
                      },
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, box) {
                  final across = box.maxWidth >= 560 ? 6 : 4;
                  return Wrap(
                    children: [
                      for (final a in HomeAction.values)
                        if (HomeAction.can(a, view.device, c))
                          SizedBox(
                            width: (box.maxWidth / across).floorToDouble(),
                            child: Builder(
                              builder: (context) {
                                final (icon, label) = _now(context, view, a);
                                return QuickAction(
                                  icon: icon,
                                  label: label,
                                  confirms: a.confirms,
                                  active:
                                      a == HomeAction.find && c.isFinding(id),
                                  onTap: () {
                                    // A page opens in place of the sheet.
                                    if (a.opens) Navigator.of(sheet).pop();
                                    return _run(
                                      a.opens ? home : context,
                                      view,
                                      a,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  },
);
