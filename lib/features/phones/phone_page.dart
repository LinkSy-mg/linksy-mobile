import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/linksy_controller.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/device_screen.dart'
    show FindAction, GridBanner, HeroFade, QuickAction;
import '../device/device_settings.dart';
import '../transfer/transfer_bubble.dart';
import 'library.dart';
import 'see_all.dart';
import 'send_bar.dart';
import 'send_flow.dart';
import 'shelves.dart';
import 'thread.dart';

/// Another phone or tablet: not a smaller computer page, but what two phones
/// are good for. Who it is, the four things that always work (they need no
/// permission and go anywhere, so the first try does something), then what's
/// on this phone, there to tap, and what went between them.
class PhonePage extends StatefulWidget {
  const PhonePage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<PhonePage> createState() => _PhonePageState();
}

/// How far the quick actions sit over the header: half their height, so the
/// header's edge runs through their middle.
const _overlap = 50.0;

class _PhonePageState extends State<PhonePage> {
  late final LinksyController _c = LinksyScope.read(context);
  late final SendFlow _flow = SendFlow(_c, widget.deviceId);
  late final PhoneLibrary _library = PhoneLibrary(_flow);

  /// Read once it's allowed.
  bool _readPhotos = false;
  bool _readApps = false;

  final _scroll = ScrollController();

  /// Scrolled past the header: back and settings stay in reach, in a bar the
  /// color of the page.
  final _past = ValueNotifier(false);

  static const _headerGone = 130.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _past.value = _scroll.offset > _headerGone);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _past.dispose();
    _library.dispose();
    _flow.dispose();
    super.dispose();
  }

  /// What the page shows, as soon as it may.
  void _load(DeviceInfo d) {
    if (_c.photoAccess && !_readPhotos) {
      _readPhotos = true;
      _library.loadPhotos();
    }
    if (d.features.contains('apps') && !_readApps) {
      _readApps = true;
      _library.loadApps();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final s = Sig.of(context);
    final l = context.l10n;
    final view = c.device(widget.deviceId);
    if (view == null || !view.trusted) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final d = view.device;
    final id = d.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(d);
    });
    final recent = c.activityFor(id).take(8).toList();
    return ValueListenableBuilder(
      valueListenable: _past,
      builder: (context, past, page) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayFor(
          past ? Theme.of(context).brightness : Brightness.dark,
        ),
        child: page!,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(view: view),
                      Transform.translate(
                        offset: const Offset(0, -_overlap),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _Quick(view: view),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -_overlap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhotosShelf(
                          library: _library,
                          allowed: c.photoAccess,
                          name: d.name,
                          onAllow: c.allowPhotos,
                        ),
                        if (d.features.contains('apps'))
                          AppsShelf(library: _library, name: d.name),
                        FilesShelf(flow: _flow),
                        if (recent.isNotEmpty) ...[
                          ShelfTitle(
                            l.phoneHistory,
                            onSeeAll: () => openHistory(context, _library, d),
                          ),
                          HistoryThread(entries: recent, device: d),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListenableBuilder(
                    listenable: _flow.selection,
                    builder: (context, _) => SizedBox(
                      height:
                          (_flow.selection.isEmpty ? 0 : SendBar.room) +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ),
              ],
            ),
            _ScrolledBar(past: _past, view: view),
            Align(
              alignment: Alignment.bottomCenter,
              child: SendBar(flow: _flow, name: d.name),
            ),
            const TransferBubble(),
          ],
        ),
        backgroundColor: s.bg,
      ),
    );
  }
}

/// Back, the name and settings once the header has scrolled away.
class _ScrolledBar extends StatelessWidget {
  const _ScrolledBar({required this.past, required this.view});

  final ValueListenable<bool> past;
  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final d = view.device;
    return ValueListenableBuilder(
      valueListenable: past,
      builder: (context, on, _) => IgnorePointer(
        ignoring: !on,
        child: AnimatedOpacity(
          opacity: on ? 1 : 0,
          duration: motion(context, 160),
          child: ColoredBox(
            color: s.bg,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    RoundButton(
                      icon: Ph.arrowLeft,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        d.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sora(18, color: s.ink),
                      ),
                    ),
                    RoundButton(
                      icon: Ph.gearSix,
                      tooltip: l.homeSettings,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeviceSettings(deviceId: d.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Who it is, and the two phones joined.
class _Header extends StatelessWidget {
  const _Header({required this.view});

  final DeviceView view;

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final d = view.device;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Stack(
        children: [
          const Positioned.fill(child: GridBanner()),
          const Positioned.fill(child: HeroFade()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, _overlap + 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      RoundButton(
                        icon: Ph.arrowLeft,
                        onDark: true,
                        tooltip: MaterialLocalizations.of(context)
                            .backButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          d.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sora(19, color: Colors.white),
                        ),
                      ),
                      RoundButton(
                        icon: Ph.gearSix,
                        onDark: true,
                        tooltip: l.homeSettings,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DeviceSettings(deviceId: d.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Ph.deviceMobile,
                          color: Sig.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Link(live: view.connected),
                      const SizedBox(width: 12),
                      Orb(
                        device: d,
                        size: 50,
                        onBlue: true,
                        picture: c.pictureOf(d.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    linkWords(view),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xDBFFFFFF),
                    ),
                  ),
                  if (view.awayUntil case final until?
                      when until.isAfter(DateTime.now()))
                    Text(
                      l.deviceReachableUntil(formatDay(until)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xDBFFFFFF),
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

/// The dots between the two phones: moving while they're connected.
class _Link extends StatefulWidget {
  const _Link({required this.live});

  final bool live;

  @override
  State<_Link> createState() => _LinkState();
}

class _LinkState extends State<_Link> with SingleTickerProviderStateMixin {
  static const _dots = 5;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.live) loopUnlessReduced(context, _controller);
  }

  @override
  void didUpdateWidget(_Link old) {
    super.didUpdateWidget(old);
    if (widget.live) {
      loopUnlessReduced(context, _controller);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final at = _controller.value * _dots;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _dots; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.5),
              child: Builder(
                builder: (context) {
                  // A bright dot runs along them while they're connected.
                  final near = (at - i).abs().clamp(0.0, 1.0);
                  final lit = widget.live ? 1 - near : 0.0;
                  // Each keeps its slot: only the dot grows, nothing moves.
                  return SizedBox.square(
                    dimension: 8,
                    child: Center(
                      child: Container(
                        width: 6 + 2 * lit,
                        height: 6 + 2 * lit,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            widget.live ? Sig.cyan : const Color(0x66FFFFFF),
                            Colors.white,
                            lit,
                          ),
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

/// The four that always work, over the header.
class _Quick extends StatelessWidget {
  const _Quick({required this.view});

  final DeviceView view;

  Future<void> _note(BuildContext context, String id) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _NoteSheet(deviceId: id),
      );

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.read(context);
    final s = Sig.of(context);
    final l = context.l10n;
    final d = view.device;
    final id = d.id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: BorderRadius.circular(Radii.xl),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 8),
            color: Color(0x140A1024),
          ),
        ],
      ),
      child: Row(
        children: [
          if (d.can('clipboard'))
            Expanded(
              child: QuickAction(
                icon: Ph.clipboardText,
                label: l.deviceClipboard,
                confirms: true,
                onTap: () => c.sendClipboard(id),
              ),
            ),
          Expanded(
            child: QuickAction(
              icon: Ph.pencilSimple,
              label: l.phoneNote,
              onTap: () async {
                await _note(context, id);
                return null;
              },
            ),
          ),
          if (d.can('ring')) Expanded(child: FindAction(view: view)),
          if (d.can('locate'))
            Expanded(
              child: QuickAction(
                icon: Ph.mapPin,
                label: l.phoneWhereShort,
                onTap: () => c.locate(id),
              ),
            ),
        ],
      ),
    );
  }
}

/// A note goes to the other phone's clipboard; a link opens there.
class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.deviceId});

  final String deviceId;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// On its way: it can take a moment while the link comes back.
  bool _sending = false;

  Future<void> _send() async {
    if (_sending || _text.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final c = LinksyScope.read(context);
    final sent = await report(context, c.sendNote(widget.deviceId, _text.text));
    if (!mounted) return;
    if (sent) return Navigator.of(context).pop();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(hintText: l.phoneNoteHint),
          ),
          const SizedBox(height: 12),
          SigButton(
            label: l.phoneSend,
            icon: PhFill.paperPlaneTilt,
            expand: true,
            onTap: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}
