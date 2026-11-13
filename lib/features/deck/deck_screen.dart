import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/deck.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'deck_editor.dart';
import 'laid_deck.dart';

/// The deck (docs/protocol.md §4.19): this phone as buttons for a computer.
/// The layouts the computer makes and sends (§4.20, [LaidDeck]), or, from a
/// computer that sends none, pages of tiles the user lays out here (Edit);
/// toggles and sliders show the computer's state. While it shows, the
/// computer keeps it current and the screen stays on, dimmed after a
/// minute untouched; it stops when the deck goes.
class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key, required this.device});

  final DeviceInfo device;

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> with WidgetsBindingObserver {
  late final LinksyController _c;
  final _pages = PageController();
  int _page = 0;
  final bool _editing = false;
  bool _open = false;
  bool _connected = false;

  /// Untouched a minute: the screen dims until a touch.
  Timer? _idle;
  bool _dim = false;

  /// A computer that offers actions but sends no layouts: its deck is laid
  /// out here, once it's had a moment to send them.
  Timer? _grace;
  bool _waited = false;

  String get _id => widget.device.id;

  @override
  void initState() {
    super.initState();
    _c = LinksyScope.read(context);
    _connected = _c.device(_id)?.connected ?? false;
    WidgetsBinding.instance.addObserver(this);
    _show(true);
    _c.watchMedia(_id);
    LinksyPlatform.keepScreenOn('deck', on: true);
    _touched();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _show(false);
    _c.unwatchMedia(_id);
    _c.volumeKeysFor(this, null);
    _idle?.cancel();
    _grace?.cancel();
    // The screen is the phone's again.
    LinksyPlatform.keepScreenOn('deck', on: false);
    LinksyPlatform.dimScreen(null);
    _pages.dispose();
    super.dispose();
  }

  /// Out of sight, the computer stops sending; back, it starts again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _show(true);
      _touched();
    }
    if (state == AppLifecycleState.hidden) {
      _show(false);
      _idle?.cancel();
      if (_dim) {
        _dim = false;
        LinksyPlatform.dimScreen(null);
      }
    }
  }

  /// A touch: full brightness, and another minute before dimming.
  void _touched() {
    if (_dim) {
      LinksyPlatform.dimScreen(null);
      setState(() => _dim = false);
    }
    _idle?.cancel();
    _idle = Timer(const Duration(seconds: 60), () {
      if (!mounted) return;
      LinksyPlatform.dimScreen(0.2);
      setState(() => _dim = true);
    });
  }

  void _show(bool open) {
    if (open == _open) return;
    _open = open;
    open ? _c.openDeck(_id) : _c.closeDeck(_id);
  }

  PhoneDeck? get _layout => _c.phoneDeck(_id);

  void _save() {
    final layout = _layout;
    if (layout != null) _c.saveDeck(_id, layout);
  }

  void _edit(void Function(PhoneDeck layout) change) {
    final layout = _layout;
    if (layout == null) return;
    setState(() => change(layout));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final connected = c.device(_id)?.connected ?? false;
    // In front with the computer's volume: the phone's keys step it (§7).
    final front = ModalRoute.of(context)?.isCurrent ?? false;
    final stepping = front && c.volume[_id] != null;
    scheduleMicrotask(() {
      if (mounted) _c.volumeKeysFor(this, stepping ? _id : null);
    });
    // Connected again: the computer needs telling the deck shows.
    if (connected && !_connected && _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _c.openDeck(_id));
    }
    _connected = connected;
    final live = c.deckLive(_id);
    final layouts = c.deckLayouts(_id);
    final actions = c.deckActions[_id];
    if (layouts == null && actions != null && _grace == null) {
      _grace = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _waited = true);
      });
    }
    final Widget deck;
    if (layouts != null) {
      deck = LaidDeck(device: widget.device, layouts: layouts, live: live);
    } else {
      deck = _ownDeck(context, live, waiting: live && !_waited);
    }
    return Listener(
      onPointerDown: (_) {
        if (!_dim) _touched();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          deck,
          // Dimmed, a touch only brings the screen back.
          if (_dim)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _touched(),
                onPanDown: (_) => _touched(),
              ),
            ),
        ],
      ),
    );
  }

  /// The deck laid out on the phone, for a computer that sends no layouts.
  Widget _ownDeck(BuildContext context, bool live, {required bool waiting}) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final actions = c.deckActions[_id];
    final layout = waiting ? null : c.phoneDeck(_id);
    final pages = layout?.pages ?? const <PhoneDeckPage>[];
    if (_page >= pages.length && pages.isNotEmpty) _page = pages.length - 1;
    final name = widget.device.name;

    Widget body;
    if (layout == null || pages.isEmpty) {
      body = _Message(
        busy: live && (actions == null || waiting),
        text: !live
            ? l.deckAway(name)
            : actions == null || waiting
            ? l.deckAsking(name)
            : l.deckNothingOffered(name),
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _Grid(
                deviceId: _id,
                page: pages[i],
                actions: actions,
                states: c.deckStates[_id] ?? const {},
                editing: _editing,
                enabled: live,
                onChanged: () => _edit((_) {}),
                onTileEdit: (t) => _editTile(pages[i], t),
                onAdd: () => _addTile(pages[i]),
              ),
            ),
          ),
          if (pages.length > 1) _Dots(count: pages.length, at: _page),
          AnimatedSize(
            duration: motion(context, 200),
            curve: Curves.easeOutCubic,
            child: _editing
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      children: [
                        Text(
                          l.deckMoveHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: s.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            SmallAction(
                              label: l.deckNewPage,
                              icon: PhBold.plus,
                              onTap: () {
                                _edit((d) => d.pages.add(PhoneDeckPage()));
                                _pages.animateToPage(
                                  pages.length - 1,
                                  duration: motion(context, 260),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                            if (pages.length > 1)
                              SmallAction(
                                label: l.deckRemovePage,
                                icon: Ph.trash,
                                color: s.red,
                                onTap: () =>
                                    _edit((d) => d.pages.removeAt(_page)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundButton(
                    icon: Ph.arrowLeft,
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.deviceDeck, style: sora(20, color: s.ink)),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: s.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (layout != null)
                    SmallAction(
                      label: _editing ? l.deckDone : l.deckEdit,
                      icon: _editing ? null : Ph.pencilSimple,
                      color: _editing ? Colors.white : Sig.blue,
                      fill: _editing
                          ? Sig.blue
                          : Sig.blue.withValues(alpha: 0.1),
                      onTap: () => openDeckEditor(context, widget.device),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: motion(context),
                  child: KeyedSubtree(
                    key: ValueKey(layout == null),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTile(PhoneDeckPage page) async {
    final actions = _c.deckActions[_id] ?? const <DeckAction>[];
    final picked = await showModalBottomSheet<DeckAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddSheet(actions: actions),
    );
    if (picked == null) return;
    _edit(
      (_) => page.tiles.add(
        PhoneDeckTile(
          action: picked.id,
          name: picked.name,
          kind: picked.kind,
          size: picked.kind == DeckKind.slider ? DeckSize.row : DeckSize.small,
          color: switch (picked.group) {
            'Media' => 0,
            'Sound' => 1,
            'System' => 2,
            _ => 3,
          },
        ),
      ),
    );
  }

  Future<void> _editTile(PhoneDeckPage page, PhoneDeckTile tile) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _EditSheet(
          tile: tile,
          onChanged: () => _edit((_) {}),
          onRemove: () {
            Navigator.of(context).pop();
            _edit((_) => page.tiles.remove(tile));
          },
        ),
      );
}

/// What the deck says instead of tiles: waiting, away, or nothing offered.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.busy = false});

  final String text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconCircle(icon: Ph.squaresFour, color: Sig.blue, size: 72),
            const SizedBox(height: 18),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: s.muted, fontSize: 15, height: 1.4),
            ),
            if (busy) ...[
              const SizedBox(height: 18),
              const PulseDot(color: Sig.blue),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.at});

  final int count;
  final int at;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: motion(context),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == at ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == at ? Sig.blue : s.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}

/// A page's tiles in four columns, each where it first fits, in order. While
/// editing, a tile held and dragged onto another takes its place, and an Add
/// tile ends the page.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.deviceId,
    required this.page,
    required this.actions,
    required this.states,
    required this.editing,
    required this.enabled,
    required this.onChanged,
    required this.onTileEdit,
    required this.onAdd,
  });

  final String deviceId;
  final PhoneDeckPage page;
  final List<DeckAction>? actions;
  final Map<String, DeckState> states;
  final bool editing;
  final bool enabled;
  final VoidCallback onChanged;
  final ValueChanged<PhoneDeckTile> onTileEdit;
  final VoidCallback onAdd;

  static const _gap = 10.0;

  /// Where each size lands: its column and row.
  static List<(int, int)> _pack(List<DeckSize> sizes) {
    final taken = <List<bool>>[];
    bool free(int row, int col, DeckSize s) {
      if (col + s.columns > 4) return false;
      for (var r = row; r < row + s.rows; r++) {
        while (taken.length <= r) {
          taken.add(List.filled(4, false));
        }
        for (var c = col; c < col + s.columns; c++) {
          if (taken[r][c]) return false;
        }
      }
      return true;
    }

    final at = <(int, int)>[];
    for (final s in sizes) {
      for (var row = 0; ; row++) {
        final col = [0, 1, 2, 3].where((c) => free(row, c, s)).firstOrNull;
        if (col == null) continue;
        for (var r = row; r < row + s.rows; r++) {
          for (var c = col; c < col + s.columns; c++) {
            taken[r][c] = true;
          }
        }
        at.add((col, row));
        break;
      }
    }
    return at;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tiles = page.tiles;
    final sizes = [for (final t in tiles) t.size, if (editing) DeckSize.small];
    final at = _pack(sizes);
    if (tiles.isEmpty && !editing) {
      return _Message(text: l.deckEmptyPage);
    }
    return LayoutBuilder(
      builder: (context, box) {
        final cell = (box.maxWidth - 3 * _gap) / 4;
        Rect rect(int i) {
          final (col, row) = at[i];
          final s = sizes[i];
          return Rect.fromLTWH(
            col * (cell + _gap),
            row * (cell + _gap),
            s.columns * cell + (s.columns - 1) * _gap,
            s.rows * cell + (s.rows - 1) * _gap,
          );
        }

        var rows = 0;
        for (var i = 0; i < sizes.length; i++) {
          final (_, row) = at[i];
          rows = rows > row + sizes[i].rows ? rows : row + sizes[i].rows;
        }
        final height = rows == 0 ? 0.0 : rows * cell + (rows - 1) * _gap;
        return SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                for (var i = 0; i < tiles.length; i++)
                  AnimatedPositioned.fromRect(
                    key: ObjectKey(tiles[i]),
                    rect: rect(i),
                    duration: motion(context, 220),
                    curve: Curves.easeOutCubic,
                    child: _place(context, i, rect(i).size),
                  ),
                if (editing)
                  Positioned.fromRect(
                    rect: rect(tiles.length),
                    child: _AddTile(onTap: onAdd),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _place(BuildContext context, int i, Size size) {
    final t = page.tiles[i];
    final action = actions?.where((a) => a.id == t.action).firstOrNull;
    // Before the computer said what it offers, a tile isn't greyed yet.
    final available = enabled && (actions == null || action != null);
    final tile = _Tile(
      deviceId: deviceId,
      tile: t,
      state: states[t.action],
      available: available,
      offered: actions == null || action != null,
      editing: editing,
      onEdit: () => onTileEdit(t),
    );
    if (!editing) return tile;
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != i,
      onAcceptWithDetails: (d) {
        final moved = page.tiles.removeAt(d.data);
        page.tiles.insert(i, moved);
        onChanged();
      },
      builder: (context, hovering, _) => LongPressDraggable<int>(
        data: i,
        onDragStarted: HapticFeedback.mediumImpact,
        feedback: SizedBox.fromSize(
          size: size,
          child: Opacity(opacity: 0.9, child: tile),
        ),
        childWhenDragging: Opacity(opacity: 0.25, child: tile),
        child: AnimatedScale(
          scale: hovering.isEmpty ? 1 : 0.92,
          duration: motion(context, 120),
          child: tile,
        ),
      ),
    );
  }
}

/// One tile: a button runs its action, a toggle flips (filled while on), a
/// slider sets a value by dragging along it. Greyed when its action isn't
/// offered anymore; while editing, a tap opens its settings.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.deviceId,
    required this.tile,
    required this.state,
    required this.available,
    required this.offered,
    required this.editing,
    required this.onEdit,
  });

  final String deviceId;
  final PhoneDeckTile tile;
  final DeckState? state;
  final bool available;
  final bool offered;
  final bool editing;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final picked = deckColors[tile.color.clamp(0, deckColors.length - 1)];
    final plain = picked.a == 0;
    final accent = plain ? Sig.blue : picked;
    final icon =
        deckIcons[tile.icon ?? deckIconFor(tile.action, tile.kind)] ??
        deckIcons['lightning']!;
    final big = tile.size == DeckSize.big;
    final Widget face;
    if (tile.kind == DeckKind.slider && !editing && available) {
      face = _Slider(
        deviceId: deviceId,
        tile: tile,
        value: state?.value ?? 0,
        accent: accent,
        icon: icon,
      );
    } else {
      final on = tile.kind == DeckKind.toggle && (state?.on ?? false);
      // A button is its colour; a toggle only while it's on.
      final filled =
          !plain && (tile.kind != DeckKind.toggle || on) || plain && on;
      final fg = filled
          ? Colors.white
          : (tile.kind == DeckKind.toggle ? accent : s.ink);
      face = Pressable.builder(
        onTap: editing
            ? onEdit
            : available
            ? () => LinksyScope.read(context).runDeck(deviceId, tile.action)
            : null,
        scale: big ? 0.97 : 0.94,
        semanticLabel: tile.name,
        builder: (context, down) => AnimatedContainer(
          duration: motion(context, 160),
          padding: EdgeInsets.all(big ? 16 : 12),
          decoration: BoxDecoration(
            color: filled
                ? (down ? Color.lerp(accent, Colors.black, 0.15) : accent)
                : (down ? s.raised : s.card),
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: _Label(
            icon: icon,
            name: tile.name,
            color: fg,
            big: big,
            note: offered ? null : context.l10n.deckUnavailable,
          ),
        ),
      );
    }
    return AnimatedOpacity(
      opacity: available || editing ? 1 : 0.4,
      duration: motion(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          face,
          if (editing)
            Positioned(
              top: 6,
              right: 6,
              child: IgnorePointer(
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: s.ink.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Ph.pencilSimple,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tile's icon over its name, sized to the tile.
class _Label extends StatelessWidget {
  const _Label({
    required this.icon,
    required this.name,
    required this.color,
    required this.big,
    this.note,
  });

  final IconData icon;
  final String name;
  final Color color;
  final bool big;
  final String? note;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      // A small tile has room for the icon and two short lines.
      final tight = box.maxHeight < 70;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: big ? 34 : (tight ? 20 : 24), color: color),
          Text(
            note ?? name,
            // "Not available" gets two lines even on a small tile.
            maxLines: tight && note == null ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: big ? 16 : (tight ? 11.5 : 12.5),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      );
    },
  );
}

/// A slider tile: filled to its value, along it (or up it when it's tall);
/// dragged or tapped, the computer follows.
class _Slider extends StatefulWidget {
  const _Slider({
    required this.deviceId,
    required this.tile,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String deviceId;
  final PhoneDeckTile tile;
  final double value;
  final Color accent;
  final IconData icon;

  @override
  State<_Slider> createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  /// While dragged: the finger's value, not the computer's.
  double? _held;

  bool get _upright => widget.tile.size.rows > widget.tile.size.columns;

  void _set(Offset at, Size size) {
    final v = (_upright ? 1 - at.dy / size.height : at.dx / size.width).clamp(
      0.0,
      1.0,
    );
    final was = _held ?? widget.value;
    // A tick at either end.
    if ((v == 0 || v == 1) && v != was) HapticFeedback.selectionClick();
    setState(() => _held = v);
    LinksyScope.read(context)
        .runDeck(widget.deviceId, widget.tile.action, value: v);
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final value = _held ?? widget.value;
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        void end() => setState(() => _held = null);
        return Semantics(
          slider: true,
          label: widget.tile.name,
          value: '${(value * 100).round()}%',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _set(d.localPosition, size),
            onTapUp: (_) => end(),
            onHorizontalDragUpdate: _upright
                ? null
                : (d) => _set(d.localPosition, size),
            onHorizontalDragEnd: _upright ? null : (_) => end(),
            onVerticalDragUpdate: _upright
                ? (d) => _set(d.localPosition, size)
                : null,
            onVerticalDragEnd: _upright ? (_) => end() : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: s.card),
                  Align(
                    alignment: _upright
                        ? Alignment.bottomCenter
                        : AlignmentDirectional.centerStart,
                    child: AnimatedFractionallySizedBox(
                      duration: motion(context, _held == null ? 200 : 40),
                      widthFactor: _upright ? 1 : value,
                      heightFactor: _upright ? value : 1,
                      child: ColoredBox(color: widget.accent),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: _upright
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                      children: [
                        if (!_upright) ...[
                          Icon(widget.icon, size: 22, color: s.ink),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            widget.tile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: s.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!_upright)
                          Text(
                            '${(value * 100).round()}%',
                            style: TextStyle(
                              color: s.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The page's last tile while editing: adds one.
class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    scale: 0.94,
    semanticLabel: context.l10n.deckAdd,
    child: Container(
      decoration: BoxDecoration(
        color: Sig.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: Sig.blue.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhBold.plus, color: Sig.blue, size: 22),
          const SizedBox(height: 4),
          Text(
            context.l10n.deckAdd,
            style: const TextStyle(
              color: Sig.blue,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The computer's own group names, in this phone's language.
String deckGroupName(BuildContext context, String group) {
  final l = context.l10n;
  return switch (group) {
    'Media' => l.deckGroupMedia,
    'Sound' => l.deckGroupSound,
    'System' => l.deckGroupSystem,
    'Network' => l.deckGroupNetwork,
    'Power' => l.deckGroupPower,
    'Commands' => l.deckGroupCommands,
    _ => group,
  };
}

/// What the computer offers, by group; a tap adds it.
class _AddSheet extends StatelessWidget {
  const _AddSheet({required this.actions});

  final List<DeckAction> actions;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final groups = <String, List<DeckAction>>{};
    for (final a in actions) {
      groups.putIfAbsent(a.group, () => []).add(a);
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(l.deckAddTitle, style: sora(20, color: s.ink)),
          for (final MapEntry(key: group, value: list) in groups.entries) ...[
            const SizedBox(height: 14),
            SectionLabel(deckGroupName(context, group)),
            SigCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final a in list)
                    Pressable(
                      onTap: () => Navigator.of(context).pop(a),
                      semanticLabel: a.name,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Row(
                          children: [
                            IconCircle(
                              icon: deckIcons[deckIconFor(a.id, a.kind)]!,
                              color: Sig.blue,
                              size: 36,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.name,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      color: s.ink,
                                    ),
                                  ),
                                  Text(
                                    switch (a.kind) {
                                      DeckKind.button => l.deckKindButton,
                                      DeckKind.toggle => l.deckKindToggle,
                                      DeckKind.slider => l.deckKindSlider,
                                    },
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: s.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(PhBold.plus, color: Sig.blue, size: 18),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tile's size, colour and icon, changed as they're picked; and Remove.
class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.tile,
    required this.onChanged,
    required this.onRemove,
  });

  final PhoneDeckTile tile;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  void _change(void Function(PhoneDeckTile t) f) {
    setState(() => f(widget.tile));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final t = widget.tile;
    final sizes = [
      (DeckSize.small, l.deckSizeSmall),
      (DeckSize.wide, l.deckSizeWide),
      (DeckSize.tall, l.deckSizeTall),
      (DeckSize.big, l.deckSizeBig),
      (DeckSize.row, l.deckSizeRow),
    ].where((e) => t.kind != DeckKind.slider || e.$1 != DeckSize.small);
    final current = t.icon ?? deckIconFor(t.action, t.kind);

    Widget chip(String label, bool on, VoidCallback onTap) => Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: motion(context, 160),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: on ? Sig.blue : s.raised,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          widthFactor: 1,
          child: AnimatedDefaultTextStyle(
            duration: motion(context, 160),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: on ? Colors.white : s.ink,
            ),
            child: Text(label),
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            t.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: sora(20, color: s.ink),
          ),
          const SizedBox(height: 18),
          SectionLabel(l.deckSize),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (size, label) in sizes)
                chip(
                  label,
                  t.size == size,
                  () => _change((t) => t.size = size),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SectionLabel(l.deckColor),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < deckColors.length; i++)
                Pressable(
                  onTap: () => _change((t) => t.color = i),
                  scale: 0.9,
                  semanticLabel: '${l.deckColor} ${i + 1}',
                  child: AnimatedContainer(
                    duration: motion(context, 160),
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: t.color == i ? s.ink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: deckColors[i].a == 0 ? s.card : deckColors[i],
                        border: deckColors[i].a == 0
                            ? Border.all(color: s.line, width: 1.5)
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SectionLabel(l.deckIcon),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final MapEntry(key: name, value: icon) in deckIcons.entries)
                Pressable(
                  onTap: () => _change((t) => t.icon = name),
                  scale: 0.9,
                  semanticLabel: name,
                  child: AnimatedContainer(
                    duration: motion(context, 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: name == current ? Sig.blue : s.raised,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: name == current ? Colors.white : s.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SigButton(
            label: l.deckRemove,
            icon: Ph.trash,
            kind: SigButtonKind.danger,
            expand: true,
            onTap: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
