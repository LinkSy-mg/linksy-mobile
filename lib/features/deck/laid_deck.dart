import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/deck_layouts.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/page_switcher.dart';
import '../remote/remote_screen.dart';
import 'deck_art.dart';
import 'deck_editor.dart';
import 'deck_looks.dart';

/// The deck as a computer laid it out (docs/protocol.md §4.20): its active
/// layout, the face for how the phone is held, pages swiped sideways, in
/// the layout's theme or the one picked here (hold the name). Tiles run
/// what the computer offers (§4.19); while it's away they wait.
class LaidDeck extends StatefulWidget {
  const LaidDeck({
    super.key,
    required this.device,
    required this.layouts,
    required this.live,
    this.editable = true,
  });

  final DeviceInfo device;
  final DeckLayouts layouts;
  final bool live;

  /// False while trying a deck out from the editor.
  final bool editable;

  @override
  State<LaidDeck> createState() => _LaidDeckState();
}

class _LaidDeckState extends State<LaidDeck> {
  final _pages = PageController();
  int _page = 0;

  /// A word on what a tap couldn't do, for a moment.
  String? _note;
  Timer? _noteTimer;

  /// Held sideways, the deck has the whole screen: no bars, no header. A
  /// swipe from the edge brings them back for a moment.
  bool _fullScreen = false;
  bool _chrome = false;
  Timer? _chromeTimer;

  void _setFullScreen(bool on) {
    if (on == _fullScreen) return;
    _fullScreen = on;
    _chrome = false;
    _chromeTimer?.cancel();
    LinksyPlatform.fullScreen(on: on);
    if (on) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setSystemUIChangeCallback((visible) async {
        if (visible && mounted) _showChrome();
      });
    } else {
      SystemChrome.setSystemUIChangeCallback(null);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showChrome() {
    setState(() => _chrome = true);
    _chromeTimer?.cancel();
    _chromeTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || !_fullScreen) return;
      setState(() => _chrome = false);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    });
  }

  String get _id => widget.device.id;

  /// Into the editor, like holding a widget on the home screen: with [tile]
  /// picked up, when it was one.
  void _edit([String? tile]) {
    if (!widget.editable) return;
    HapticFeedback.mediumImpact();
    openDeckEditor(context, widget.device, select: tile, page: _page);
  }

  void _say(String text) {
    _noteTimer?.cancel();
    setState(() => _note = text);
    _noteTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _note = null);
    });
  }

  @override
  void dispose() {
    _noteTimer?.cancel();
    _chromeTimer?.cancel();
    if (_fullScreen) {
      LinksyPlatform.fullScreen(on: false);
      SystemChrome.setSystemUIChangeCallback(null);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final layout = widget.layouts.shown;
    final name = widget.device.name;
    final own = layout == null ? null : c.deckTheme(_id, layout.id);
    final accent = layout?.theme.accent ?? DeckTheme.stock.accent;
    final look = DeckLook.of(own ?? layout?.theme.id ?? 'stock', accent);

    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (landscape != _fullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setFullScreen(landscape);
      });
    }
    var face = layout == null
        ? null
        : (landscape ? layout.landscape : layout.portrait);
    // A face never made: the other one, rather than nothing.
    if (layout != null && face!.isEmpty) {
      final other = landscape ? layout.portrait : layout.landscape;
      if (!other.isEmpty) face = other;
    }
    final pages = face?.pages ?? const <List<DeckTile>>[];
    if (_page >= pages.length && pages.isNotEmpty) _page = pages.length - 1;

    final actions = {
      for (final a in c.deckActions[_id] ?? const <DeckAction>[]) a.id: a,
    };
    final players = c.media[_id]?.players ?? const <MediaPlayer>[];
    final player = c.playerFor(_id);
    final scope = _Scope(
      deviceId: _id,
      deviceName: name,
      look: look,
      live: widget.live,
      actions: c.deckActions[_id] == null ? null : actions,
      states: c.deckStates[_id] ?? const {},
      player: widget.live ? player : null,
      players: widget.live ? players : const [],
      say: _say,
      hold: _edit,
      hideBlocked: true,
    );

    Widget body;
    if (face == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l.deckNoLayouts(name),
            textAlign: TextAlign.center,
            style: look.text(15, color: look.screenInk, opacity: 0.75),
          ),
        ),
      );
    } else {
      body = PageView.builder(
        controller: _pages,
        itemCount: pages.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, i) => _Page(
          face: face!,
          tiles: pages[i],
          scope: scope,
          sideways: landscape,
          dotsBelow: pages.length > 1,
        ),
      );
    }

    Widget header() => _Header(
      look: look,
      title: layout?.name ?? name,
      subtitle: name,
      live: widget.live,
      page: _page,
      pages: pages.length,
      compact: landscape,
      onTheme: layout == null ? null : () => _pickTheme(layout, own),
      onEdit: widget.editable ? _edit : null,
      onTouchpad: _touchpad,
      deviceId: widget.device.id,
    );

    final dark = look.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
      child: Material(
        color: look.background,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: look.gradient),
          child: CustomPaint(
            painter: DeckBackdropPainter(look, accent),
            child: landscape
                ? _sideways(context, body, look, pages.length, header())
                : SafeArea(
                    child: Column(
                      children: [
                        header(),
                        Expanded(child: body),
                        _Dots(
                          look: look,
                          count: pages.length,
                          at: _page,
                          height: 44,
                        ),
                        _noteLine(look),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _noteLine(DeckLook look) => AnimatedSize(
    duration: motion(context),
    curve: Curves.easeOutCubic,
    child: _note == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: Text(
              _note!,
              textAlign: TextAlign.center,
              style: look.text(13, color: look.screenInk, opacity: 0.8),
            ),
          ),
  );

  /// The deck from edge to edge; what it says, and its header once called,
  /// over it.
  Widget _sideways(
    BuildContext context,
    Widget body,
    DeckLook look,
    int pages,
    Widget header,
  ) => Stack(
    fit: StackFit.expand,
    children: [
      // Either way round (mobile#21): clear of the cut-out and the bars,
      // whichever side they're on.
      SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(child: body),
                  if (pages > 1)
                    _Dots(look: look, count: pages, at: _page, height: 32),
                ],
              ),
            ),
            _Rail(
              look: look,
              onEdit: widget.editable ? _edit : null,
              onTouchpad: _touchpad,
              deviceId: widget.device.id,
            ),
          ],
        ),
      ),
      if (_note != null)
        Positioned(left: 0, right: 0, bottom: 14, child: _noteLine(look)),
      AnimatedPositioned(
        duration: motion(context, 180),
        curve: Curves.easeOutCubic,
        left: 0,
        right: 0,
        top: _chrome ? 0 : -90,
        child: ColoredBox(
          color: look.background.withValues(alpha: 0.92),
          child: SafeArea(bottom: false, child: header),
        ),
      ),
    ],
  );

  /// Remote Input in one tap (Discussion #79); back is the deck again, and
  /// the remote stays open a minute for the next time.
  void _touchpad() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RemoteScreen(device: widget.device),
    ),
  );

  Future<void> _pickTheme(DeckLayout layout, String? own) async {
    final c = LinksyScope.read(context);
    final picked = await showModalBottomSheet<(String?,)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _ThemeSheet(computer: widget.device.name, layout: layout, own: own),
    );
    if (picked == null) return;
    await c.setDeckTheme(_id, layout.id, picked.$1);
  }
}

/// Sideways, beside the tiles: the way back, the touchpad and Edit under it.
class _Rail extends StatelessWidget {
  const _Rail({
    required this.look,
    required this.onEdit,
    required this.onTouchpad,
    required this.deviceId,
  });

  final DeckLook look;
  final VoidCallback? onEdit;
  final VoidCallback onTouchpad;
  final String deviceId;

  Widget _button(IconData icon, String label, VoidCallback? onTap) => Pressable(
    onTap: onTap,
    scale: 0.9,
    semanticLabel: label,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: look.screenInk.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, color: look.screenInk, size: 20),
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 16, 12, 16),
    child: Column(
      children: [
        _button(
          Ph.arrowLeft,
          MaterialLocalizations.of(context).backButtonTooltip,
          () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 10),
        _button(Ph.mouseSimple, context.l10n.remoteTouchpad, onTouchpad),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: look.screenInk.withValues(alpha: 0.3)),
          ),
          child: PageSwitchButton(
            deviceId: deviceId,
            current: DevicePage.deck,
            color: look.screenInk,
            round: false,
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(height: 10),
          _button(Ph.pencilSimple, context.l10n.deckEdit, onEdit),
        ],
      ],
    ),
  );
}

/// One tile as the deck draws it, for the editor: with nothing playing, and
/// nothing to say.
class DeckTileView extends StatelessWidget {
  const DeckTileView({
    super.key,
    required this.tile,
    required this.cell,
    required this.gap,
    required this.device,
    required this.look,
    required this.live,
    required this.actions,
    required this.states,
  });

  final DeckTile tile;
  final double cell;
  final double gap;
  final DeviceInfo device;
  final DeckLook look;
  final bool live;
  final Map<String, DeckAction>? actions;
  final Map<String, DeckState> states;

  @override
  Widget build(BuildContext context) => _Tile(
    tile: tile,
    cell: cell,
    gap: gap,
    scope: _Scope(
      deviceId: device.id,
      deviceName: device.name,
      look: look,
      live: live,
      actions: actions,
      states: states,
      player: null,
      players: const [],
      say: (_) {},
      hold: null,
    ),
  );
}

/// What every tile of the deck needs to know besides itself.
class _Scope {
  const _Scope({
    required this.deviceId,
    required this.deviceName,
    required this.look,
    required this.live,
    required this.actions,
    required this.states,
    required this.player,
    required this.players,
    required this.say,
    required this.hold,
    this.hideBlocked = false,
  });

  final String deviceId;
  final String deviceName;
  final DeckLook look;
  final bool live;

  /// What the computer offers, by id; null until it said.
  final Map<String, DeckAction>? actions;
  final Map<String, DeckState> states;
  final MediaPlayer? player;

  /// Every player the computer has: a tap on the title picks among them.
  final List<MediaPlayer> players;
  final void Function(String) say;

  /// Held down: to the editor, with this tile.
  final void Function([String? tile])? hold;

  /// A tile whose action the computer doesn't let this phone use isn't
  /// drawn at all (mobile#21); the editor still shows it.
  final bool hideBlocked;
}

/// The deck's name (hold or tap it for the theme), the computer's under it
/// (beside it when [compact], in landscape), and whether that's away or
/// which page this is.
class _Header extends StatelessWidget {
  const _Header({
    required this.look,
    required this.title,
    required this.subtitle,
    required this.live,
    required this.page,
    required this.pages,
    required this.compact,
    required this.onTheme,
    required this.onEdit,
    required this.onTouchpad,
    required this.deviceId,
  });

  final VoidCallback? onEdit;
  final VoidCallback onTouchpad;
  final String deviceId;
  final DeckLook look;
  final String title;
  final String subtitle;
  final bool live;
  final int page;
  final int pages;
  final bool compact;
  final VoidCallback? onTheme;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String up(String s) => look.upper ? s.toUpperCase() : s;
    final name = Text(
      up(title),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: look.text(
        compact ? 15 : 17,
        color: look.screenInk,
        weight: FontWeight.w700,
      ),
    );
    final computer = Text(
      up(subtitle),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: look.text(
        12,
        color: look.screenInk,
        weight: FontWeight.w500,
        opacity: 0.6,
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(12, compact ? 0 : 6, 16, compact ? 0 : 6),
      child: Row(
        children: [
          Pressable(
            onTap: () => Navigator.of(context).maybePop(),
            scale: 0.9,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
            child: SizedBox(
              width: compact ? 40 : 44,
              height: compact ? 36 : 44,
              child: Icon(Ph.arrowLeft, color: look.screenInk, size: 22),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTheme,
              onLongPress: onTheme == null
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      onTheme!();
                    },
              child: compact
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(child: name),
                        const SizedBox(width: 10),
                        Flexible(child: computer),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [name, computer],
                    ),
            ),
          ),
          Pressable(
            onTap: onTouchpad,
            scale: 0.9,
            semanticLabel: l.remoteTouchpad,
            child: SizedBox(
              width: compact ? 40 : 44,
              height: compact ? 36 : 44,
              child: Icon(Ph.mouseSimple, color: look.screenInk, size: 22),
            ),
          ),
          PageSwitchButton(
            deviceId: deviceId,
            current: DevicePage.deck,
            color: look.screenInk,
            size: compact ? 40 : 44,
            round: false,
          ),
          const SizedBox(width: 6),
          if (onEdit != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Pressable(
                onTap: onEdit,
                scale: 0.94,
                semanticLabel: l.deckEdit,
                child: Container(
                  height: compact ? 32 : 36,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: look.play,
                    borderRadius: BorderRadius.circular(
                      look.radius == 0 ? 0 : 18,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Ph.pencilSimple, size: 16, color: look.playInk),
                      const SizedBox(width: 6),
                      Text(
                        l.deckEdit,
                        style: TextStyle(
                          color: look.playInk,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!live)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(look.radius == 0 ? 0 : 99),
                border: Border.all(
                  color: look.screenInk.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                up(l.deckAwayShort),
                style: look.text(12, color: look.screenInk, opacity: 0.8),
              ),
            )
          else if (pages > 1)
            Text(
              '${page + 1} / $pages',
              style: look.text(12, color: look.screenInk, opacity: 0.6),
            ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.look,
    required this.count,
    required this.at,
    required this.height,
  });

  final DeckLook look;
  final int count;
  final int at;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: count < 2
        ? null
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: motion(context),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: i == at ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == at ? look.dotOn : look.dot,
                    borderRadius: BorderRadius.circular(
                      look.squareDots ? 0 : 4,
                    ),
                  ),
                ),
            ],
          ),
  );
}

/// One page: square cells, as many as the face's grid, as big as fit; each
/// tile where the computer put it.
class _Page extends StatelessWidget {
  const _Page({
    required this.face,
    required this.tiles,
    required this.scope,
    this.sideways = false,
    this.dotsBelow = false,
  });

  final DeckFace face;
  final List<DeckTile> tiles;
  final _Scope scope;

  final bool sideways;

  /// Sideways, the dots under the page bring their own room.
  final bool dotsBelow;

  @override
  Widget build(BuildContext context) => Padding(
    padding: sideways
        ? EdgeInsets.fromLTRB(18, 16, 14, dotsBelow ? 0 : 16)
        : const EdgeInsets.fromLTRB(14, 6, 14, 6),
    child: LayoutBuilder(
      builder: (context, box) {
        final cols = face.columns, rows = face.rows;
        final gap = face.rows > face.columns || sideways ? 10.0 : 8.0;
        final cell = math
            .max(
              8.0,
              math.min(
                (box.maxWidth - gap * (cols - 1)) / cols,
                (box.maxHeight - gap * (rows - 1)) / rows,
              ),
            )
            .floorToDouble();
        double span(int n) => n * cell + (n - 1) * gap;
        return Center(
          child: SizedBox(
            width: span(cols),
            height: span(rows),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Held on nothing: the same as holding a tile.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: scope.hold,
                  ),
                ),
                for (final t in tiles)
                  Positioned(
                    key: ValueKey(t.id),
                    left: t.x * (cell + gap),
                    top: t.y * (cell + gap),
                    width: span(t.w),
                    height: span(t.h),
                    child: _Tile(tile: t, cell: cell, gap: gap, scope: scope),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Writes in a look, at the editor's scale: in glyphs where the look draws
/// them and has them all, else in its font.
class _Pen {
  const _Pen(this.look, this.scale, this.color);

  final DeckLook look;

  /// The cell over the editor's 58 px one.
  final double scale;
  final Color color;

  Widget words(
    String s, {
    required double size,
    required double width,
    int lines = 1,
    List<double> pitches = const [1],
    bool center = false,
    FontWeight? weight,
    double opacity = 1,
    bool label = false,
  }) {
    if (label && look.prefix.isNotEmpty) s = '${look.prefix}$s';
    final ink = color.withValues(alpha: color.a * opacity);
    if (look.letters != DeckLetters.font && hasGlyphs(s)) {
      final square = look.letters == DeckLetters.squares;
      final scaled = [
        for (final p in pitches)
          square ? math.max(1.0, (p * scale).roundToDouble()) : p * scale,
      ];
      final (fitted, pitch) = fitGlyphs(s, width, lines, scaled);
      return GlyphText(
        lines: fitted,
        pitch: pitch,
        color: ink,
        square: square,
        width: width,
      );
    }
    final text = look.upper ? s.toUpperCase() : s;
    var style = look.text(
      size * scale,
      color: color,
      weight: weight,
      opacity: opacity,
    );
    // A word too long for the tile: the label a little smaller, not split.
    if (lines > 1) {
      final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      final widest = words.fold(0.0, (most, w) {
        final p = TextPainter(
          text: TextSpan(text: w, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final wide = p.width;
        p.dispose();
        return math.max(most, wide);
      });
      // With a little room: a word a hair under the width still breaks.
      if (widest > width * 0.97) {
        final shrink = math.max(0.6, width / widest * 0.95);
        style = style.copyWith(fontSize: style.fontSize! * shrink);
        if (shrink == 0.6) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text, maxLines: 1, style: style),
          );
        }
      }
    }
    return Text(
      text,
      maxLines: lines,
      softWrap: lines > 1,
      overflow: TextOverflow.ellipsis,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: style,
    );
  }

  /// Numbers [px] high (the glyphs' height in the looks that draw them).
  Widget number(String s, {required double px, required double width}) {
    if (look.letters != DeckLetters.font) {
      final pitch = px / 7;
      return words(
        s.replaceAll('\n', ' '),
        size: px,
        width: width,
        lines: '\n'.allMatches(s).length + 1,
        pitches: [pitch, pitch * 0.85, pitch * 0.7],
      );
    }
    return Text(
      s,
      maxLines: '\n'.allMatches(s).length + 1,
      style: look.text(px * scale, color: color).copyWith(height: 1.05),
    );
  }
}

/// A tile, drawn by its kind; one this phone doesn't know as a plain tile
/// with its label. Its action not offered (or the computer away): dimmed,
/// and a tap says why.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.tile,
    required this.cell,
    required this.gap,
    required this.scope,
  });

  final DeckTile tile;

  final double cell;

  final double gap;
  final _Scope scope;

  @override
  Widget build(BuildContext context) {
    final t = tile;
    final look = scope.look;
    final scale = cell / 58;
    final action = t.action;
    final offered = action == null
        ? null
        : scope.actions == null
        ? null
        : scope.actions![action];
    // Before the computer said what it offers, a tile isn't dimmed yet.
    final known = action == null || scope.actions == null || offered != null;
    final state = action == null ? null : scope.states[action];
    final on = state?.on ?? false;
    final available = scope.live && known;
    final runs = const {'button', 'volume'}.contains(t.kind);
    if (scope.hideBlocked && scope.live && runs && !known) {
      return const SizedBox.shrink();
    }
    final dimmed = t.kind != 'clock' && (!scope.live || runs && !known);
    final one = t.w == 1 && t.h == 1 && t.kind != 'clock';
    final pad = (one ? 5.0 : 9.0) * scale;
    final paint = look.paint(
      t.color ?? deckDefaultColor(t.kind, action),
      on: on && t.kind == 'button',
    );
    final label = t.label.isNotEmpty
        ? t.label
        : offered?.name ?? _named(action) ?? t.kind;

    void why() => scope.say(
      scope.live
          ? context.l10n.deckNotAvailable(scope.deviceName)
          : context.l10n.deckAwayNote(scope.deviceName),
    );

    // Dimmed, a tap says why and tries the computer again.
    void retry() {
      why();
      LinksyScope.read(context).openDeck(scope.deviceId);
    }

    Widget shell(Widget child, {bool down = false}) {
      final fill = down ? Color.lerp(paint.fill, paint.ink, 0.14)! : paint.fill;
      final content = Padding(padding: EdgeInsets.all(pad), child: child);
      if (look.bevel) {
        return CustomPaint(painter: PixelBoxPainter(fill), child: content);
      }
      final glass = look.id == 'glass' && !(on && t.kind == 'button');
      return DecoratedBox(
        decoration: BoxDecoration(
          color: glass ? null : fill,
          gradient: glass
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fill.withValues(alpha: fill.a * 1.7),
                    fill.withValues(alpha: fill.a * 0.6),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(look.radius),
          border: paint.stroke == null
              ? null
              : Border.all(color: paint.stroke!, width: look.strokeWidth),
        ),
        child: content,
      );
    }

    final pen = _Pen(look, scale, paint.ink);
    final inner = cell * t.w + (t.w - 1) * gap - 2 * pad;
    // A big tile, a big icon.
    final grown = cell * 0.36 * (1 + (math.min(t.w, t.h) - 1) * 0.6);
    final iconSize = look.icons == DeckStroke.pixel
        ? math.max(12.0, (grown / 12).roundToDouble() * 12)
        : grown;
    final Widget built;
    switch (t.kind) {
      case 'clock':
        built = shell(_ClockFace(tile: t, pen: pen, width: inner));
      case 'music':
        built = shell(
          _MusicFace(
            tile: t,
            scope: scope,
            pen: pen,
            ink: paint.icon,
            scale: scale,
          ),
        );
      case 'volume':
        built = _VolumeTile(
          tile: t,
          scope: scope,
          pen: pen,
          ink: paint.icon,
          iconSize: iconSize,
          enabled: available && offered != null,
          shell: shell,
          onBlocked: why,
        );
      case 'button':
        final playing = scope.player?.playing ?? false;
        final icon = DeckIcon(
          t.props['icon'] ?? deckIconName(action, playing: playing),
          size: iconSize,
          color: paint.icon,
          stroke: look.icons,
        );
        final shown = state?.text ?? label;
        built = Pressable.builder(
          onTap: () {
            if (!scope.live) return retry();
            // Before the computer said what it offers: nothing to run yet.
            if (scope.actions == null) return;
            offered == null ? why() : _run(context, offered);
          },
          scale: 0.95,
          semanticLabel: state?.text == null ? label : '$label, ${state!.text}',
          builder: (context, down) => shell(
            down: down,
            one
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      SizedBox(height: 3 * scale),
                      pen.words(
                        shown,
                        size: 10,
                        width: inner,
                        lines: look.prefix.isEmpty ? 2 : 1,
                        center: true,
                        weight: look.prefix.isEmpty ? null : FontWeight.w400,
                        label: true,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      icon,
                      const Spacer(),
                      pen.words(
                        shown,
                        size: look.prefix.isEmpty ? 11 : 12,
                        width: inner,
                        pitches: const [1.3],
                        label: true,
                      ),
                    ],
                  ),
          ),
        );
      default:
        built = shell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              pen.words(
                label,
                size: 11,
                width: inner,
                lines: 2,
                pitches: const [1.3, 1.1],
                label: true,
              ),
            ],
          ),
        );
    }
    final confirm = offered?.confirm != null;
    return GestureDetector(
      onLongPress: scope.hold == null ? null : () => scope.hold!(t.id),
      child: AnimatedOpacity(
        opacity: dimmed ? 0.45 : 1,
        duration: motion(context),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            built,
            if (dimmed && t.kind != 'button' && t.kind != 'volume')
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: why,
                ),
              ),
            if (confirm)
              Positioned(
                top: 5 * scale,
                right: 5 * scale,
                child: IgnorePointer(
                  child: Container(
                    width: 13 * scale,
                    height: 13 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020),
                      shape: look.bevel ? BoxShape.rectangle : BoxShape.circle,
                    ),
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: const Color(0xFF1D1D20),
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// An action's name from its id, for a tile without a label whose action
  /// the computer doesn't offer now: `system.restart`, Restart.
  static String? _named(String? action) {
    if (action == null) return null;
    final last = action.split('.').last.replaceAll('_', ' ');
    if (last.isEmpty || action.startsWith('command.')) return null;
    return last[0].toUpperCase() + last.substring(1);
  }

  /// Runs it, asking first when the computer wants that.
  Future<void> _run(BuildContext context, DeckAction a) async {
    final c = LinksyScope.read(context);
    if (a.confirm case final question?) {
      final ok = await _confirm(context, question, a.name);
      if (!ok) return;
    }
    c.runDeck(scope.deviceId, a.id);
  }
}

/// The computer's question before a restart, turning off, Wi-Fi off…:
/// Cancel, or the action's name to go on.
Future<bool> _confirm(BuildContext context, String question, String go) async {
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
              Text(
                question,
                textAlign: TextAlign.center,
                style: sora(20, color: s.ink),
              ),
              const SizedBox(height: 24),
              SigButton(
                label: go,
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
  return ok ?? false;
}

/// The phone's own time: across a wide tile with the date, big on a square
/// one, hours over minutes on a single cell.
class _ClockFace extends StatefulWidget {
  const _ClockFace({
    required this.tile,
    required this.pen,
    required this.width,
  });

  final DeckTile tile;
  final _Pen pen;
  final double width;

  @override
  State<_ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<_ClockFace> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _next();
  }

  /// On the minute.
  void _next() {
    final now = DateTime.now();
    _tick = Timer(
      Duration(seconds: 60 - now.second, milliseconds: -now.millisecond + 20),
      () {
        if (!mounted) return;
        setState(() {});
        _next();
      },
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tile, pen = widget.pen;
    final now = DateTime.now();
    final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final hh = h24
        ? now.hour.toString().padLeft(2, '0')
        : '${now.hour % 12 == 0 ? 12 : now.hour % 12}';
    final mm = now.minute.toString().padLeft(2, '0');
    final date = shortDate(now);
    final w = widget.width;
    if (t.w == 1) {
      return Center(child: pen.number('$hh\n$mm', px: 17, width: w));
    }
    if (t.h == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pen.number('$hh:$mm', px: 18.5, width: w),
          SizedBox(height: 2 * pen.scale),
          pen.words(
            date,
            size: 10.5,
            width: w,
            pitches: const [1.1, 1.0],
            opacity: 0.75,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pen.number('$hh:$mm', px: 29, width: w),
        const Spacer(),
        pen.words(
          date,
          size: 10.5,
          width: w,
          pitches: const [1.3, 1.1],
          opacity: 0.75,
        ),
      ],
    );
  }
}

/// The computer's player: its cover on a wide tile, the title, where it
/// is, and its buttons.
class _MusicFace extends StatefulWidget {
  const _MusicFace({
    required this.tile,
    required this.scope,
    required this.pen,
    required this.ink,
    required this.scale,
  });

  final DeckTile tile;
  final _Scope scope;
  final _Pen pen;
  final Color ink;
  final double scale;

  @override
  State<_MusicFace> createState() => _MusicFaceState();
}

class _MusicFaceState extends State<_MusicFace> {
  /// When the position came: the bar moves on by itself in between.
  DateTime _since = DateTime.now();
  Timer? _tick;
  String? _art;
  Uint8List? _cover;

  @override
  void initState() {
    super.initState();
    _ticking();
  }

  @override
  void didUpdateWidget(_MusicFace old) {
    super.didUpdateWidget(old);
    final p = widget.scope.player, o = old.scope.player;
    if (p?.positionMs != o?.positionMs || p?.playing != o?.playing) {
      _since = DateTime.now();
    }
    _ticking();
  }

  void _ticking() {
    final p = widget.scope.player;
    final on = p != null && p.playing && p.lengthMs != null;
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

  double get _progress {
    final p = widget.scope.player;
    final at = p?.positionMs, length = p?.lengthMs;
    if (p == null || at == null || length == null || length <= 0) return 0;
    final now = p.playing
        ? at + DateTime.now().difference(_since).inMilliseconds
        : at;
    return (now / length).clamp(0, 1);
  }

  Uint8List? _coverOf(MediaPlayer? p) {
    final art = p?.art;
    if (art != _art) {
      _art = art;
      try {
        _cover = art == null ? null : base64Decode(art);
      } on FormatException {
        _cover = null;
      }
    }
    return _cover;
  }

  /// Which player the deck controls, when the computer has more than one.
  Future<void> _pick() async {
    final scope = widget.scope;
    if (scope.players.length < 2) return;
    final c = LinksyScope.read(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) =>
          _PlayerSheet(players: scope.players, current: scope.player?.id),
    );
    if (picked != null) await c.pickPlayer(scope.deviceId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final scope = widget.scope, look = scope.look, pen = widget.pen;
    final s = widget.scale;
    final p = scope.player;
    final c = LinksyScope.read(context);
    final playing = p?.playing ?? false;
    final several = scope.players.length > 1;
    final subtitle = [
      if (several) p?.app,
      p?.artist,
      p?.album,
    ].whereType<String>().where((x) => x.isNotEmpty).join(' · ');
    final title = p == null || p.title.isEmpty
        ? context.l10n.deckNothingPlaying
        : p.title;
    // A timeline only when the player knows how long the track is.
    final timeline = p?.lengthMs != null;

    Widget control(String icon, String command, double f, {bool big = false}) {
      final size = (big ? 15.0 : 18.0) * s * f;
      final glyph = DeckIcon(
        icon,
        size: look.icons == DeckStroke.pixel
            ? math.max(12.0, (size / 12).roundToDouble() * 12)
            : size,
        color: big ? look.playInk : widget.ink,
        stroke: look.icons,
      );
      return Pressable(
        onTap: p == null
            ? null
            : () => c.mediaCommand(scope.deviceId, p.id, command),
        scale: 0.88,
        semanticLabel: command,
        child: Padding(
          padding: EdgeInsets.all(4 * s * f),
          child: big
              ? Container(
                  width: 30 * s * f,
                  height: 30 * s * f,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: look.play,
                    borderRadius: BorderRadius.circular(
                      look.playRadius == 99 ? 15 * s * f : look.playRadius,
                    ),
                    boxShadow: look.playShadow
                        ? const [BoxShadow(offset: Offset(2, 2))]
                        : null,
                  ),
                  child: glyph,
                )
              : glyph,
        ),
      );
    }

    // What the player can't do isn't shown, rather than greyed (mobile#21).
    Widget controls(double f) => Opacity(
      opacity: p == null ? 0.5 : 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p?.canPrevious ?? false) control('prev', 'previous', f),
          control(playing ? 'pause' : 'play', 'play_pause', f, big: true),
          if (p?.canNext ?? false) control('next', 'next', f),
        ],
      ),
    );

    Widget words(double f, double width) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: several ? _pick : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Marquee(
            key: ValueKey(title),
            width: width,
            child: pen.words(
              title,
              size: 13 * f,
              width: 4000,
              pitches: const [1.5, 1.3],
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 2 * s * f),
            _Marquee(
              key: ValueKey(subtitle),
              width: width,
              child: pen.words(
                subtitle,
                size: 10.5 * f,
                width: 4000,
                opacity: 0.75,
              ),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        // A tile one row high: everything on one line.
        if (h < 64 * s) {
          final side = h;
          final cover = w >= side * 5;
          final f = (h / (40 * s)).clamp(0.8, 1.2);
          return Row(
            children: [
              if (cover) ...[
                DeckCover(
                  look: look,
                  size: side,
                  art: _coverOf(p),
                  real: c.deckRealCovers,
                ),
                SizedBox(width: 8 * s),
              ],
              Expanded(
                child: LayoutBuilder(
                  builder: (context, inner) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: several ? _pick : null,
                        child: _Marquee(
                          key: ValueKey(title),
                          width: inner.maxWidth,
                          child: pen.words(
                            title,
                            size: 12 * f,
                            width: 4000,
                            pitches: const [1.3],
                          ),
                        ),
                      ),
                      if (timeline) ...[
                        SizedBox(height: 5 * s),
                        DeckBar(value: _progress, look: look),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: 4 * s),
              FittedBox(fit: BoxFit.scaleDown, child: controls(f)),
            ],
          );
        }
        // Taller: the cover beside when there's room for words too, and
        // words and buttons as big as the tile allows, never cut.
        final cover = w - h - 9 * s >= 110 * s;
        final meta = cover ? w - h - 9 * s : w;
        final need = (13 * 1.5 + 10.5 * 1.4 + 2 + 6 + 8 + 38 + 6) * s;
        final f = math.min(h / need, meta / (100 * s)).clamp(0.7, 2.4);
        return Row(
          children: [
            if (cover) ...[
              DeckCover(
                look: look,
                size: h,
                art: _coverOf(p),
                real: c.deckRealCovers,
              ),
              SizedBox(width: 9 * s),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  words(f, meta),
                  if (timeline) ...[
                    SizedBox(height: 6 * s * f),
                    DeckBar(value: _progress, look: look),
                  ],
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: controls(f),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A line too long for its tile slides by now and then, like an old
/// stereo's display (mobile#21); not with reduced motion.
class _Marquee extends StatefulWidget {
  const _Marquee({super.key, required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> {
  final _scroll = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_running || !mounted || !_scroll.hasClients) return;
    if (motion(context) == Duration.zero) return;
    _running = true;
    while (mounted && _scroll.hasClients) {
      final far = _scroll.position.maxScrollExtent;
      if (far <= 0) break;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted || !_scroll.hasClients) break;
      await _scroll.animateTo(
        far,
        duration: Duration(milliseconds: (far * 28).round() + 300),
        curve: Curves.linear,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted || !_scroll.hasClients) break;
      _scroll.jumpTo(0);
    }
    _running = false;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
    ),
  );
}

/// A switch in the theme sheet.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String caption;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: s.ink,
                  ),
                ),
                Text(caption, style: TextStyle(fontSize: 13, color: s.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// The computer's players, to pick the one the deck controls.
class _PlayerSheet extends StatelessWidget {
  const _PlayerSheet({required this.players, required this.current});

  final List<MediaPlayer> players;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text(
                context.l10n.deckPickPlayer,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: s.ink,
                ),
              ),
            ),
            for (final p in players)
              Pressable(
                onTap: () => Navigator.of(context).pop(p.id),
                scale: 0.97,
                semanticLabel: p.app,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: p.id == current ? s.raised : null,
                    borderRadius: BorderRadius.circular(Radii.lg),
                    border: Border.all(
                      color: p.id == current ? Sig.blue : s.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        p.playing ? PhFill.play : PhFill.pause,
                        size: 18,
                        color: p.playing ? Sig.blue : s.muted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.app,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: s.ink,
                              ),
                            ),
                            if (p.title.isNotEmpty)
                              Text(
                                p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: s.muted),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The computer's volume, dragged along (or up a tall tile); the newest
/// value goes while dragging, throttled.
class _VolumeTile extends StatefulWidget {
  const _VolumeTile({
    required this.tile,
    required this.scope,
    required this.pen,
    required this.ink,
    required this.iconSize,
    required this.enabled,
    required this.shell,
    required this.onBlocked,
  });

  final DeckTile tile;
  final _Scope scope;
  final _Pen pen;
  final Color ink;
  final double iconSize;
  final bool enabled;
  final Widget Function(Widget child, {bool down}) shell;
  final VoidCallback onBlocked;

  @override
  State<_VolumeTile> createState() => _VolumeTileState();
}

class _VolumeTileState extends State<_VolumeTile> {
  /// While dragged: the finger's value, not the computer's.
  double? _held;

  String get _action => widget.tile.action ?? 'sound.volume';

  bool get _upright => widget.tile.h > widget.tile.w;

  void _set(Offset at, Size size) {
    final v = (_upright ? 1 - at.dy / size.height : at.dx / size.width).clamp(
      0.0,
      1.0,
    );
    final was = _held ?? widget.scope.states[_action]?.value ?? 0;
    if ((v == 0 || v == 1) && v != was) HapticFeedback.selectionClick();
    setState(() => _held = v);
    LinksyScope.read(context).runDeck(widget.scope.deviceId, _action, value: v);
  }

  void _end() => setState(() => _held = null);

  @override
  Widget build(BuildContext context) {
    final scope = widget.scope, look = scope.look, pen = widget.pen;
    final value = _held ?? scope.states[_action]?.value ?? 0;
    final muted = scope.states['sound.mute']?.on ?? false;
    final icon = DeckIcon(
      muted ? 'mute' : 'volume',
      size: widget.iconSize,
      color: widget.ink,
      stroke: look.icons,
    );
    final s = pen.scale;
    final percent = '${(value * 100).round()}%';
    final named = scope.actions == null ? null : scope.actions![_action]?.name;
    final face = _upright
        ? Column(
            children: [
              Expanded(
                child: DeckBar(
                  value: value,
                  look: look,
                  vertical: true,
                  thick: true,
                ),
              ),
              SizedBox(height: 9 * s),
              icon,
            ],
          )
        : Row(
            children: [
              icon,
              SizedBox(width: 9 * s),
              Expanded(
                child: DeckBar(value: value, look: look, thick: true),
              ),
              if (widget.tile.w > 1) ...[
                SizedBox(width: 9 * s),
                pen.words(
                  percent,
                  size: 10.5,
                  width: 40 * s,
                  pitches: const [1.4, 1.2],
                  weight: FontWeight.w600,
                ),
              ],
            ],
          );
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        if (!widget.enabled) {
          return GestureDetector(
            onTap: widget.onBlocked,
            child: widget.shell(face),
          );
        }
        return Semantics(
          slider: true,
          label: widget.tile.label.isEmpty ? named : widget.tile.label,
          value: percent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _set(d.localPosition, size),
            onTapUp: (_) => _end(),
            onHorizontalDragUpdate: _upright
                ? null
                : (d) => _set(d.localPosition, size),
            onHorizontalDragEnd: _upright ? null : (_) => _end(),
            onVerticalDragUpdate: _upright
                ? (d) => _set(d.localPosition, size)
                : null,
            onVerticalDragEnd: _upright ? (_) => _end() : null,
            child: widget.shell(face, down: _held != null),
          ),
        );
      },
    );
  }
}

/// The deck's look, picked on the phone: as the computer made it, one of
/// its five, or one of the phone's own; kept here, for this layout.
class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({
    required this.computer,
    required this.layout,
    required this.own,
  });

  final String computer;
  final DeckLayout layout;

  /// The phone's pick now; none: the layout's own.
  final String? own;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final c = LinksyScope.of(context);
    final accent = layout.theme.accent;

    Widget option(
      String id,
      String title, {
      required bool picked,
      String? caption,
      required (String?,) result,
    }) => Pressable(
      onTap: () => Navigator.of(context).pop(result),
      scale: 0.96,
      semanticLabel: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: motion(context, 160),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.lg + 3),
              border: Border.all(
                color: picked ? Sig.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: _Preview(look: DeckLook.of(id, accent), accent: accent),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: s.ink,
                    ),
                  ),
                ),
                if (picked) const Icon(PhBold.check, size: 16, color: Sig.blue),
              ],
            ),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: s.muted),
              ),
            ),
        ],
      ),
    );

    Widget grid(List<Widget> children) => LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final columns = box.maxWidth > 520 ? 4 : 2;
        final w = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [for (final c in children) SizedBox(width: w, child: c)],
        );
      },
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(l.deckThemeTitle, style: sora(20, color: s.ink)),
          const SizedBox(height: 16),
          grid([
            option(
              layout.theme.id,
              l.deckThemeAsMade(computer),
              caption: DeckLook.name(context, layout.theme.id),
              picked: own == null,
              result: (null,),
            ),
          ]),
          const SizedBox(height: 18),
          SectionLabel(l.deckThemesShared),
          grid([
            for (final id in DeckLook.computers)
              option(
                id,
                DeckLook.name(context, id),
                picked: own == id,
                result: (id,),
              ),
          ]),
          const SizedBox(height: 18),
          SectionLabel(l.deckThemesPhone),
          grid([
            for (final id in DeckLook.phones)
              option(
                id,
                DeckLook.name(context, id),
                picked: own == id,
                result: (id,),
              ),
          ]),
          const SizedBox(height: 18),
          // mobile#21: the whole screen, and covers as they are.
          SectionLabel(l.deckDisplay),
          _Toggle(
            title: l.deckFullScreen,
            caption: l.deckFullScreenCaption,
            value: c.deckFullScreen,
            onChanged: c.setDeckFullScreen,
          ),
          _Toggle(
            title: l.deckRealCovers,
            caption: l.deckRealCoversCaption,
            value: c.deckRealCovers,
            onChanged: c.setDeckRealCovers,
          ),
        ],
      ),
    );
  }
}

/// A look in small: its background, a tile, one that's on, and a bar.
class _Preview extends StatelessWidget {
  const _Preview({required this.look, required this.accent});

  final DeckLook look;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget tile(String icon, Color color, {required bool on}) {
      final p = look.paint(color, on: on);
      final child = Center(
        child: DeckIcon(
          icon,
          size: look.icons == DeckStroke.pixel ? 12 : 16,
          color: p.icon,
          stroke: look.icons,
        ),
      );
      if (look.bevel) {
        return CustomPaint(painter: PixelBoxPainter(p.fill), child: child);
      }
      return DecoratedBox(
        decoration: BoxDecoration(
          color: p.fill,
          borderRadius: BorderRadius.circular(math.min(look.radius, 10)),
          border: p.stroke == null
              ? null
              : Border.all(color: p.stroke!, width: look.strokeWidth),
        ),
        child: child,
      );
    }

    return AspectRatio(
      aspectRatio: 1.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: look.background,
          gradient: look.gradient,
        ),
        child: CustomPaint(
          painter: DeckBackdropPainter(look, accent),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: tile('play', const Color(0xFF24345C), on: false),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: tile('mic', const Color(0xFF2B3550), on: true),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: tile('wifi', const Color(0xFF155E75), on: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 8, child: DeckBar(value: 0.62, look: look)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
