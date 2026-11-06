import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/scope.dart';
import '../../core/deck_draft.dart';
import '../../core/deck_layouts.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'deck_art.dart';
import 'deck_looks.dart';
import 'deck_screen.dart' show deckGroupName;
import 'laid_deck.dart';

const _panel = Color(0xFF0C0E13);
const _raised = Color(0xFF14171E);
const _edge = Color(0xFF262A33);
const _ink = Color(0xFFEDEFF3);
const _muted = Color(0xFF8B93A3);
const _accent = Color(0xFF3B8BEB);

/// Opens the editor on [device]'s deck: the layouts it has, or a first one
/// made of what it offers.
Future<void> openDeckEditor(BuildContext context, DeviceInfo device) {
  final c = LinksyScope.read(context);
  final offered = c.deckActions[device.id] ?? const <DeckAction>[];
  final start =
      c.deckLayouts(device.id) ??
      DeckDraft.starter(context.l10n.deviceDeck, offered);
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => DeckEditor(device: device, start: start),
    ),
  );
}

/// The deck laid out on the phone, right on the deck: a tap selects a tile,
/// a drag moves it, its corner resizes it, an empty cell adds one.
class DeckEditor extends StatefulWidget {
  const DeckEditor({super.key, required this.device, required this.start});

  final DeviceInfo device;
  final DeckLayouts start;

  @override
  State<DeckEditor> createState() => _DeckEditorState();
}

class _DeckEditorState extends State<DeckEditor> {
  late final DeckDraft _d = DeckDraft(widget.start);
  String? _selected;

  // A tile on the move: where the finger has it, and the cell it would take.
  String? _dragging;
  Offset _at = Offset.zero;
  (int, int)? _target;

  // What the page would come to, while a finger decides.
  List<DeckTile>? _preview;

  // A tile being resized: how it began, which sides move, where the finger
  // has them.
  DeckTile? _sizing;
  ({bool l, bool t, bool r, bool b})? _sides;
  Offset _pull = Offset.zero;

  // Held sideways, the deck to edit is the landscape one.
  bool? _wide;
  bool _startEmpty = false;

  List<DeckTile> get _shown => _preview ?? _d.tiles;
  DeckTile? _shownTile(String id) =>
      _shown.where((t) => t.id == id).firstOrNull;

  String get _id => widget.device.id;
  List<DeckAction> get _offered =>
      LinksyScope.read(context).deckActions[_id] ?? const [];

  void _do(void Function() change) => setState(change);

  void _say(String text) => showMessage(context, text);

  Future<void> _done() async {
    final c = LinksyScope.read(context);
    final nav = Navigator.of(context);
    await c.saveDeckHere(_id, _d.layouts);
    // A theme picked on the deck itself would hide the one chosen here.
    for (final l in _d.layouts.layouts) {
      await c.setDeckTheme(_id, l.id, null);
    }
    nav.pop();
  }

  Future<void> _leave() async {
    if (!_d.changed) return Navigator.of(context).pop();
    final l = context.l10n;
    final nav = Navigator.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.deckDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.deckKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.deckDiscard),
          ),
        ],
      ),
    );
    if (discard ?? false) nav.pop();
  }

  Future<void> _add({int? x, int? y}) async {
    final l = context.l10n;
    final picked = await showModalBottomSheet<(String, String?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => _AddSheet(
        offered: _offered,
        placed: {for (final t in _d.tiles) ?t.action},
      ),
    );
    if (picked == null || !mounted) return;
    final (kind, action) = picked;
    DeckTile? made;
    _do(() {
      made = _d.add(kind, action: action, x: x, y: y);
      _selected = made?.id;
    });
    if (made == null) _say(l.deckNoRoom);
  }

  Future<void> _editTile(DeckTile tile) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => _TileSheet(
        draft: _d,
        id: tile.id,
        offered: _offered,
        preview: (t) => _tileView(t, 72, 8),
        onChanged: () => setState(() {}),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _toPage(DeckTile tile) async {
    final l = context.l10n;
    final to = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _d.face.pages.length; i++)
              if (i != _d.page)
                ListTile(
                  title: Text(
                    l.deckPageN(i + 1),
                    style: const TextStyle(color: _ink),
                  ),
                  onTap: () => Navigator.of(sheet).pop(i),
                ),
            ListTile(
              leading: const Icon(PhBold.plus, color: _ink),
              title: Text(l.deckNewPage, style: const TextStyle(color: _ink)),
              onTap: () => Navigator.of(sheet).pop(-1),
            ),
          ],
        ),
      ),
    );
    if (to == null) return;
    _do(() {
      final from = _d.page;
      final target = to == -1 ? _d.face.pages.length : to;
      if (to == -1 && !_d.addPage()) return;
      _d.page = from;
      if (_d.moveToPage(tile.id, target)) {
        _d.page = target;
      } else {
        _say(l.deckNoRoom);
      }
    });
  }

  Future<void> _theme() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      barrierColor: Colors.black26,
      isScrollControlled: true,
      builder: (_) => _ThemeSheet(draft: _d, onChanged: () => setState(() {})),
    );
  }

  Future<void> _layouts() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LayoutsPage(
          draft: _d,
          offered: _offered,
          fromComputer: LinksyScope.read(context).deckHasHere(_id),
          device: widget.device,
        ),
      ),
    );
    if (mounted) setState(() => _selected = null);
  }

  void _try() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LaidDeck(
        device: widget.device,
        layouts: _d.layouts.copyWith(active: _d.layoutId),
        connected: LinksyScope.read(context).device(_id)?.connected ?? false,
      ),
    ),
  );

  DeckLook get _look => DeckLook.of(_d.layout.theme.id, _d.layout.theme.accent);

  Widget _tileView(DeckTile t, double cell, double gap) {
    final c = LinksyScope.read(context);
    return DeckTileView(
      tile: t,
      cell: cell,
      gap: gap,
      device: widget.device,
      look: _look,
      connected: true,
      actions: c.deckActions[_id] == null
          ? null
          : {for (final a in c.deckActions[_id]!) a.id: a},
      states: c.deckStates[_id] ?? const {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final look = _look;
    final wide = MediaQuery.orientationOf(context) == Orientation.landscape;
    if (wide != _wide) {
      _wide = wide;
      _d.landscape = wide;
      _d.page = 0;
      _selected = null;
    }
    final selected = _selected == null ? null : _shownTile(_selected!);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _leave();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            (look.brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(statusBarColor: Colors.transparent),
        child: Material(
          color: look.background,
          child: CustomPaint(
            painter: DeckBackdropPainter(look, _d.layout.theme.accent),
            child: wide
                ? SafeArea(
                    child: Row(
                      children: [
                        _leftRail(look),
                        Expanded(child: _gridOrStart(selected, wide: true)),
                        _rightRail(),
                      ],
                    ),
                  )
                : SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _top(look),
                        Expanded(child: _gridOrStart(selected, wide: false)),
                        _pages(),
                        _dock(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// An empty landscape next to a portrait with tiles: the quick way there.
  Widget _gridOrStart(DeckTile? selected, {required bool wide}) {
    final l = context.l10n;
    final fresh =
        _d.landscape &&
        !_startEmpty &&
        _d.layout.landscape.isEmpty &&
        !_d.layout.portrait.isEmpty;
    if (!fresh) return _grid(selected, wide: wide);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmallAction(
            label: l.deckStartFromPortrait,
            icon: Ph.deviceRotate,
            color: Colors.white,
            fill: _accent,
            onTap: () => _do(_d.landscapeFromPortrait),
          ),
          const SizedBox(height: 8),
          SmallAction(
            label: l.deckStartEmpty,
            color: _ink,
            fill: _raised,
            onTap: () => _do(() => _startEmpty = true),
          ),
        ],
      ),
    );
  }

  Widget _railButton(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool on = false,
  }) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? _accent : _raised,
        border: Border.all(color: on ? _accent : _edge),
      ),
      child: Icon(
        icon,
        size: 19,
        color: onTap == null ? _muted : (on ? Colors.white : _ink),
      ),
    ),
  );

  /// Sideways: leaving, undo and the pages down the left…
  Widget _leftRail(DeckLook look) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _railButton(Ph.x, l.deckDiscard, _leave),
          _railButton(
            Ph.arrowCounterClockwise,
            l.deckUndo,
            _d.canUndo ? () => _do(_d.undo) : null,
          ),
          _railButton(
            Ph.arrowClockwise,
            l.deckRedo,
            _d.canRedo ? () => _do(_d.redo) : null,
          ),
          for (var i = 0; i < _d.face.pages.length && i < 3; i++)
            Pressable(
              onTap: () => _do(() {
                _d.page = i;
                _selected = null;
              }),
              semanticLabel: l.deckPageN(i + 1),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _d.page ? _accent : _raised,
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_d.face.pages.length < DeckDraft.maxPages)
            _railButton(
              PhBold.plus,
              l.deckNewPage,
              () => _do(() => _d.addPage()),
            ),
        ],
      ),
    );
  }

  /// …and Done with everything else down the right.
  Widget _rightRail() {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _railButton(PhBold.check, l.deckDone, _done, on: true),
          _railButton(PhBold.plus, l.deckAdd, () => _add()),
          _railButton(Ph.sparkle, l.deckFillForMe, _fill),
          _railButton(Ph.palette, l.deckThemeTitle, _theme),
          _railButton(Ph.stack, l.deckLayouts, _layouts),
          _railButton(PhFill.play, l.deckTryIt, _try),
        ],
      ),
    );
  }

  void _fill() {
    var added = 0;
    _do(() => added = _d.fill(_offered));
    if (added == 0) _say(context.l10n.deckNoRoom);
  }

  Widget _top(DeckLook look) {
    final l = context.l10n;
    final ink = look.screenInk;
    Widget icon(IconData i, String tip, VoidCallback? onTap) => Pressable(
      onTap: onTap,
      semanticLabel: tip,
      child: SizedBox(
        width: 40,
        height: 44,
        child: Icon(i, size: 21, color: onTap == null ? _muted : ink),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        children: [
          icon(Ph.x, l.deckDiscard, _leave),
          Expanded(
            child: Pressable(
              onTap: _layouts,
              semanticLabel: l.deckLayouts,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _d.layout.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: look.text(16, color: ink, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Ph.caretDown, size: 14, color: ink),
                ],
              ),
            ),
          ),
          icon(
            Ph.arrowCounterClockwise,
            l.deckUndo,
            _d.canUndo ? () => _do(_d.undo) : null,
          ),
          icon(
            Ph.arrowClockwise,
            l.deckRedo,
            _d.canRedo ? () => _do(_d.redo) : null,
          ),
          const SizedBox(width: 4),
          SmallAction(
            label: l.deckDone,
            color: Colors.white,
            fill: _accent,
            onTap: _done,
          ),
        ],
      ),
    );
  }

  Widget _grid(DeckTile? selected, {required bool wide}) => Padding(
    padding: wide
        ? const EdgeInsets.fromLTRB(4, 8, 4, 8)
        : const EdgeInsets.fromLTRB(12, 4, 12, 4),
    child: LayoutBuilder(
      builder: (context, box) {
        final face = _d.face;
        final cols = face.columns, rows = face.rows;
        final gap = rows > cols ? 8.0 : 6.0;
        final cell = math
            .max(
              8.0,
              math.min(
                (box.maxWidth - gap * (cols - 1)) / cols,
                (box.maxHeight - gap * (rows - 1)) / rows,
              ),
            )
            .floorToDouble();
        final step = cell + gap;
        double span(int n) => n * cell + (n - 1) * gap;
        final taken = <(int, int)>{
          for (final t in _shown)
            for (var y = t.y; y < t.y + t.h; y++)
              for (var x = t.x; x < t.x + t.w; x++) (x, y),
        };
        final moving = _dragging == null ? null : _shownTile(_dragging!);
        final busy = _dragging != null || _sizing != null;
        return Center(
          child: SizedBox(
            width: span(cols),
            height: span(rows),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Off a tile, a tap lets it go.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _do(() => _selected = null),
                  ),
                ),
                for (var y = 0; y < rows; y++)
                  for (var x = 0; x < cols; x++)
                    if (!taken.contains((x, y)))
                      Positioned(
                        left: x * step,
                        top: y * step,
                        width: cell,
                        height: cell,
                        child: _Empty(
                          label: context.l10n.deckAdd,
                          onTap: () => _add(x: x, y: y),
                        ),
                      ),
                if (moving != null)
                  Positioned(
                    left: moving.x * step,
                    top: moving.y * step,
                    width: span(moving.w),
                    height: span(moving.h),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: _accent.withValues(alpha: 0.18),
                          border: Border.all(color: _accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                // The one on the move stays here, unseen: its gesture lives here.
                for (final t in _shown)
                  AnimatedPositioned(
                    key: ValueKey(t.id),
                    duration: motion(context, 130),
                    curve: Curves.easeOutCubic,
                    left: t.x * step,
                    top: t.y * step,
                    width: span(t.w),
                    height: span(t.h),
                    child: Opacity(
                      opacity: t.id == _dragging ? 0 : 1,
                      child: _placed(t, cell, gap, step),
                    ),
                  ),
                if (selected != null && _dragging == null)
                  ..._handles(selected, step, span),
                if (_sizing != null && selected != null)
                  _badge(selected, step, span),
                if (selected != null && !busy)
                  _menu(selected, step, span, span(cols), span(rows)),
                if (moving != null)
                  Positioned(
                    left: _at.dx,
                    top: _at.dy,
                    width: span(moving.w),
                    height: span(moving.h),
                    child: IgnorePointer(
                      child: Transform.scale(
                        scale: 1.05,
                        child: Opacity(
                          opacity: 0.92,
                          child: _tileView(moving, cell, gap),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _placed(DeckTile t, double cell, double gap, double step) {
    final on = t.id == _selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _do(() => _selected = on ? null : t.id),
      onPanStart: (_) {
        HapticFeedback.selectionClick();
        _do(() {
          _dragging = t.id;
          _selected = t.id;
          _at = Offset(t.x * step, t.y * step);
          _target = (t.x, t.y);
        });
      },
      onPanUpdate: (e) => _do(() {
        _at += e.delta;
        final face = _d.face;
        final x = (_at.dx / step).round().clamp(0, face.columns - t.w);
        final y = (_at.dy / step).round().clamp(0, face.rows - t.h);
        if ((x, y) == _target) return;
        final next = _d.arranged(t.id, x, y, t.w, t.h);
        if (next == null) return;
        _target = (x, y);
        _preview = next;
        HapticFeedback.selectionClick();
      }),
      onPanEnd: (_) => _settle(),
      onPanCancel: _settle,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(child: _tileView(t, cell, gap)),
          if (on)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _accent, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A finger lifts: what it came to is one step of undo.
  void _settle() => _do(() {
    final next = _preview;
    _dragging = null;
    _target = null;
    _sizing = null;
    _sides = null;
    _preview = null;
    if (next != null) _d.settle(next);
  });

  void _pullTo(Offset delta, double step) {
    final start = _sizing, sides = _sides;
    if (start == null || sides == null) return;
    _pull += delta;
    final dx = (_pull.dx / step).round(), dy = (_pull.dy / step).round();
    final face = _d.face;
    var left = start.x, top = start.y;
    var right = start.x + start.w, bottom = start.y + start.h;
    if (sides.l) left = (left + dx).clamp(0, right - 1);
    if (sides.r) right = (right + dx).clamp(left + 1, face.columns);
    if (sides.t) top = (top + dy).clamp(0, bottom - 1);
    if (sides.b) bottom = (bottom + dy).clamp(top + 1, face.rows);
    final now = _shownTile(start.id);
    if (now == null) return;
    final (w, h) = (right - left, bottom - top);
    if (now.x == left && now.y == top && now.w == w && now.h == h) return;
    final next = _d.arranged(start.id, left, top, w, h);
    if (next == null) return;
    HapticFeedback.selectionClick();
    _do(() => _preview = next);
  }

  /// A dot on each corner and a bar on each side: pull any of them.
  List<Widget> _handles(DeckTile t, double step, double Function(int) span) {
    final x = t.x * step, y = t.y * step, w = span(t.w), h = span(t.h);
    // Corners are for both ways; the rest of each side, all along it, for one.
    Widget grip(
      String key,
      Rect area,
      ({bool l, bool t, bool r, bool b}) sides,
      Widget mark,
    ) => Positioned.fromRect(
      key: ValueKey(key),
      rect: area,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          HapticFeedback.selectionClick();
          _do(() {
            _sizing = _d.tile(t.id);
            _sides = sides;
            _pull = Offset.zero;
          });
        },
        onPanUpdate: (e) => _pullTo(e.delta, step),
        onPanEnd: (_) => _settle(),
        onPanCancel: _settle,
        child: Center(child: mark),
      ),
    );
    Widget mark(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
    const reach = 20.0, side = 14.0;
    Rect corner(double cx, double cy) =>
        Rect.fromCircle(center: Offset(cx, cy), radius: reach);
    final dot = mark(16, 16);
    return [
      grip('e-t', Rect.fromLTRB(x + reach, y - side, x + w - reach, y + side), (
        l: false,
        t: true,
        r: false,
        b: false,
      ), mark(26, 6)),
      grip(
        'e-b',
        Rect.fromLTRB(x + reach, y + h - side, x + w - reach, y + h + side),
        (l: false, t: false, r: false, b: true),
        mark(26, 6),
      ),
      grip('e-l', Rect.fromLTRB(x - side, y + reach, x + side, y + h - reach), (
        l: true,
        t: false,
        r: false,
        b: false,
      ), mark(6, 26)),
      grip(
        'e-r',
        Rect.fromLTRB(x + w - side, y + reach, x + w + side, y + h - reach),
        (l: false, t: false, r: true, b: false),
        mark(6, 26),
      ),
      grip('c-tl', corner(x, y), (l: true, t: true, r: false, b: false), dot),
      grip('c-tr', corner(x + w, y), (
        l: false,
        t: true,
        r: true,
        b: false,
      ), dot),
      grip('c-bl', corner(x, y + h), (
        l: true,
        t: false,
        r: false,
        b: true,
      ), dot),
      grip('c-br', corner(x + w, y + h), (
        l: false,
        t: false,
        r: true,
        b: true,
      ), dot),
    ];
  }

  /// Its size, over it, while it changes.
  Widget _badge(DeckTile t, double step, double Function(int) span) =>
      Positioned(
        left: t.x * step,
        top: t.y * step,
        width: span(t.w),
        height: span(t.h),
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${t.w} × ${t.h}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _menu(
    DeckTile t,
    double step,
    double Function(int) span,
    double width,
    double height,
  ) {
    final l = context.l10n;
    const w = 232.0, h = 56.0;
    final top = t.y * step;
    final above = top - h - 16;
    final below = top + span(t.h) + 16;
    final y = above >= 0
        ? above
        : below + h <= height
        ? below
        : math.max(0.0, top + 8);
    final x = (t.x * step + span(t.w) / 2 - w / 2)
        .clamp(0.0, math.max(0.0, width - w))
        .toDouble();
    Widget item(IconData i, String label, VoidCallback onTap) => Expanded(
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 18, color: _ink),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    return Positioned(
      left: x,
      top: y,
      width: math.min(w, width),
      height: h,
      child: Container(
        decoration: BoxDecoration(
          color: _raised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _edge),
        ),
        child: Row(
          children: [
            item(Ph.pencilSimple, l.deckEdit, () => _editTile(t)),
            item(Ph.copy, l.deckCopy, () {
              _do(() {
                final made = _d.duplicate(t.id);
                if (made == null) {
                  _say(l.deckNoRoom);
                } else {
                  _selected = made.id;
                }
              });
            }),
            item(Ph.files, l.deckPage, () => _toPage(t)),
            item(Ph.trash, l.deckRemoveShort, () {
              _do(() {
                _d.remove(t.id);
                _selected = null;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _pages() {
    final l = context.l10n;
    Widget chip(String label, bool on, VoidCallback onTap) => Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? _accent : _raised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? _accent : _edge),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          chip(
            _d.landscape ? l.deckLandscape : l.deckPortrait,
            false,
            () => _do(() {
              _d.landscape = !_d.landscape;
              _d.page = 0;
              _selected = null;
            }),
          ),
          const SizedBox(width: 12),
          for (var i = 0; i < _d.face.pages.length; i++) ...[
            chip(
              l.deckPageN(i + 1),
              i == _d.page,
              () => _do(() {
                _d.page = i;
                _selected = null;
              }),
            ),
            const SizedBox(width: 6),
          ],
          if (_d.face.pages.length < DeckDraft.maxPages)
            chip('+', false, () => _do(() => _d.addPage())),
          if (_d.face.pages.length > 1) ...[
            const SizedBox(width: 6),
            chip(l.deckRemovePage, false, () => _do(_d.removePage)),
          ],
        ],
      ),
    );
  }

  Widget _dock() {
    final l = context.l10n;
    Widget item(
      IconData i,
      String label,
      VoidCallback onTap, {
      bool on = false,
    }) => Expanded(
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? _accent : _raised,
                border: Border.all(color: on ? _accent : _edge),
              ),
              child: Icon(i, size: 20, color: on ? Colors.white : _ink),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(top: BorderSide(color: _edge)),
      ),
      padding: EdgeInsets.fromLTRB(
        6,
        8,
        6,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          item(PhBold.plus, l.deckAdd, () => _add(), on: true),
          item(Ph.sparkle, l.deckFillForMe, _fill),
          item(Ph.palette, l.deckThemeTitle, _theme),
          item(Ph.stack, l.deckLayouts, _layouts),
          item(PhFill.play, l.deckTryIt, _try),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: CustomPaint(
      painter: const _Dashes(),
      child: const Center(
        child: Icon(PhBold.plus, size: 14, color: Color(0xFF4A515E)),
      ),
    ),
  );
}

class _Dashes extends CustomPainter {
  const _Dashes();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      );
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2B303A);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), pen);
      }
    }
  }

  @override
  bool shouldRepaint(_Dashes old) => false;
}

TextStyle get _head => sora(19, color: _ink);

Widget _label(String t) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 6),
  child: Text(
    t,
    style: const TextStyle(
      color: _muted,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
);

/// Everything that can go on the deck: what it shows live, what the computer
/// offers. A tap picks it.
class _AddSheet extends StatefulWidget {
  const _AddSheet({required this.offered, required this.placed});

  final List<DeckAction> offered;
  final Set<String> placed;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  String _find = '';

  Widget _cell(String icon, String label, VoidCallback onTap) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _edge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DeckIcon(icon, size: 21, color: _ink, stroke: DeckStroke.dotted),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 11.5,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _grid(List<Widget> cells) => GridView.count(
    crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape
        ? 7
        : 4,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 1.08,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: cells,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final find = _find.trim().toLowerCase();
    bool shows(String name) => name.toLowerCase().contains(find);
    void pick(String kind, [String? action]) =>
        Navigator.of(context).pop((kind, action));
    final volume = widget.offered.where((a) => a.kind == DeckKind.slider);
    final live = [
      if (shows(l.deckMusic)) _cell('music', l.deckMusic, () => pick('music')),
      for (final a in volume)
        if (shows(a.name)) _cell('volume', a.name, () => pick('volume', a.id)),
      if (shows(l.deckClock)) _cell('clock', l.deckClock, () => pick('clock')),
    ];
    final buttons = [
      for (final a in widget.offered)
        if (a.kind != DeckKind.slider && shows(a.name)) a,
    ];
    final fresh = [
      for (final a in buttons)
        if (!widget.placed.contains(a.id)) a,
    ].take(8).toList();
    final groups = <String, List<DeckAction>>{};
    for (final a in buttons) {
      (groups[a.group] ??= []).add(a);
    }
    Widget action(DeckAction a) => _cell(
      deckIconName(a.id, playing: false),
      a.name,
      () => pick('button', a.id),
    );
    return FractionallySizedBox(
      heightFactor: MediaQuery.orientationOf(context) == Orientation.landscape
          ? 0.96
          : 0.86,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.deckAddTitle, style: _head),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => _find = v),
                style: const TextStyle(color: _ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l.deckAddSearch,
                  hintStyle: const TextStyle(color: _muted),
                  prefixIcon: const Icon(Ph.magnifyingGlass, color: _muted),
                  filled: true,
                  fillColor: Colors.black,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(color: _edge),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(color: _edge),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    if (live.isNotEmpty) ...[_label(l.deckLive), _grid(live)],
                    if (fresh.isNotEmpty && find.isEmpty) ...[
                      _label(l.deckSuggested),
                      _grid([for (final a in fresh) action(a)]),
                    ],
                    for (final MapEntry(key: group, value: list)
                        in groups.entries) ...[
                      _label(deckGroupName(context, group)),
                      _grid([for (final a in list) action(a)]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tile: its name, what it does, its icon, colour and size, shown as
/// they change.
class _TileSheet extends StatefulWidget {
  const _TileSheet({
    required this.draft,
    required this.id,
    required this.offered,
    required this.preview,
    required this.onChanged,
  });

  final DeckDraft draft;
  final String id;
  final List<DeckAction> offered;
  final Widget Function(DeckTile) preview;
  final VoidCallback onChanged;

  @override
  State<_TileSheet> createState() => _TileSheetState();
}

class _TileSheetState extends State<_TileSheet> {
  static const _icons = [
    'lock', 'mic', 'volume', 'terminal', 'moon', 'wifi', //
    'power', 'restart', 'leaf', 'gauge', 'music', 'bluetooth',
  ];

  late final _name = TextEditingController(
    text: widget.draft.tile(widget.id)?.label ?? '',
  );

  DeckTile? get _t => widget.draft.tile(widget.id);

  void _change(DeckTile next) {
    setState(() => widget.draft.replace(next));
    widget.onChanged();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _size(DeckTile t, int w, int h) {
    if (w < 1 || h < 1) return;
    if (widget.draft.resize(t.id, w, h)) {
      setState(() {});
      widget.onChanged();
    } else {
      showMessage(context, context.l10n.deckNoRoom);
    }
  }

  Future<void> _pickAction(DeckTile t) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (sheet) => FractionallySizedBox(
        heightFactor: 0.7,
        child: ListView(
          children: [
            for (final a in widget.offered)
              if (a.kind != DeckKind.slider)
                ListTile(
                  title: Text(a.name, style: const TextStyle(color: _ink)),
                  subtitle: Text(
                    deckGroupName(sheet, a.group),
                    style: const TextStyle(color: _muted),
                  ),
                  onTap: () => Navigator.of(sheet).pop(a.id),
                ),
          ],
        ),
      ),
    );
    if (picked != null) _change(t.copyWith(action: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = _t;
    if (t == null) return const SizedBox.shrink();
    final name = widget.offered
        .where((a) => a.id == t.action)
        .firstOrNull
        ?.name;
    final runs = t.kind == 'button';
    return FractionallySizedBox(
      heightFactor: MediaQuery.orientationOf(context) == Orientation.landscape
          ? 0.96
          : 0.82,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            SizedBox(
              height: 120,
              child: FittedBox(
                child: SizedBox(
                  width: t.w * 72 + (t.w - 1) * 8,
                  height: t.h * 72 + (t.h - 1) * 8,
                  child: IgnorePointer(child: widget.preview(t)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _label(l.deckName),
            TextField(
              controller: _name,
              maxLength: DeckDraft.maxLabel,
              onChanged: (v) => _change(t.copyWith(label: v)),
              style: const TextStyle(color: _ink),
              decoration: InputDecoration(
                hintText: name ?? l.deckName,
                hintStyle: const TextStyle(color: _muted),
                counterText: '',
                isDense: true,
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _edge),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _edge),
                ),
              ),
            ),
            if (runs) ...[
              _label(l.deckDoes),
              Pressable(
                onTap: () => _pickAction(t),
                semanticLabel: l.deckDoes,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _edge),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name ?? t.action ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Ph.caretRight, size: 15, color: _muted),
                    ],
                  ),
                ),
              ),
              _label(l.deckIcon),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final i in _icons)
                    Pressable(
                      onTap: () =>
                          _change(t.copyWith(props: {...t.props, 'icon': i})),
                      semanticLabel: i,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.props['icon'] == i ? _raised : Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: t.props['icon'] == i ? _accent : _edge,
                          ),
                        ),
                        child: DeckIcon(
                          i,
                          size: 20,
                          color: _ink,
                          stroke: DeckStroke.dotted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            _label(l.deckColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final c in deckSwatches)
                  Pressable(
                    onTap: () => _change(
                      c == null
                          ? t.copyWith(noColor: true)
                          : t.copyWith(color: c),
                    ),
                    semanticLabel: l.deckColor,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c ?? Colors.black,
                        border: Border.all(
                          color: t.color == c ? Colors.white : _edge,
                          width: t.color == c ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            _label(l.deckSize),
            _Stepper(
              label: l.deckWidth,
              value: t.w,
              onChange: (w) => _size(t, w, t.h),
            ),
            const SizedBox(height: 8),
            _Stepper(
              label: l.deckHeight,
              value: t.h,
              onChange: (h) => _size(t, t.w, h),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, int by) => Pressable(
      onTap: () => onChange(value + by),
      semanticLabel: '$label ${by > 0 ? '+' : '-'}',
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: _raised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: _ink),
      ),
    );
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: _ink, fontSize: 14)),
        ),
        step(PhBold.minus, -1),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        step(PhBold.plus, 1),
      ],
    );
  }
}

/// The look, tried on the deck behind it.
class _ThemeSheet extends StatefulWidget {
  const _ThemeSheet({required this.draft, required this.onChanged});

  final DeckDraft draft;
  final VoidCallback onChanged;

  @override
  State<_ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends State<_ThemeSheet> {
  void _set(DeckTheme theme) {
    setState(() => widget.draft.setTheme(theme));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = widget.draft.layout.theme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.deckThemeTitle, style: _head),
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final id in DeckLook.computers)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _swatch(context, id, theme),
                    ),
                ],
              ),
            ),
            _label(l.deckAccent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final c in deckSwatches.nonNulls)
                  Pressable(
                    onTap: () => _set(DeckTheme(id: theme.id, accent: c)),
                    semanticLabel: l.deckAccent,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c,
                        border: Border.all(
                          color: theme.accent == c
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _swatch(BuildContext context, String id, DeckTheme theme) {
    final look = DeckLook.of(id, theme.accent);
    final on = theme.id == id;
    final name = DeckLook.name(context, id);
    return Pressable(
      onTap: () => _set(DeckTheme(id: id, accent: theme.accent)),
      semanticLabel: name,
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          color: look.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? _accent : _edge, width: on ? 2 : 1),
        ),
        child: Text(
          name,
          maxLines: 2,
          style: look.text(
            12.5,
            color: look.screenInk,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Every layout of this deck, what to start a new one from, and the face.
class _LayoutsPage extends StatefulWidget {
  const _LayoutsPage({
    required this.draft,
    required this.offered,
    required this.fromComputer,
    required this.device,
  });

  final DeckDraft draft;
  final List<DeckAction> offered;

  /// It's laid out here, over what the computer has.
  final bool fromComputer;
  final DeviceInfo device;

  @override
  State<_LayoutsPage> createState() => _LayoutsPageState();
}

class _LayoutsPageState extends State<_LayoutsPage> {
  DeckDraft get _d => widget.draft;

  Future<String?> _ask(String title, String start) async {
    final l = context.l10n;
    final field = TextEditingController(text: start);
    final name = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: field,
          autofocus: true,
          maxLength: DeckDraft.maxLabel,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(field.text),
            child: Text(l.deckDone),
          ),
        ],
      ),
    );
    field.dispose();
    return name;
  }

  Future<void> _new(String label, DeckStart start) async {
    final l = context.l10n;
    final name = await _ask(l.deckNewLayout, label);
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      if (!_d.newLayout(name.trim(), start, widget.offered)) {
        showMessage(context, l.deckNoRoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = LinksyScope.read(context);
    final nav = Navigator.of(context);
    Widget start(String label, DeckStart s) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SmallAction(
        label: label,
        color: _ink,
        fill: _raised,
        onTap: () => _new(label, s),
      ),
    );
    return Scaffold(
      backgroundColor: _panel,
      appBar: AppBar(
        backgroundColor: _panel,
        foregroundColor: _ink,
        title: Text(l.deckLayouts),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final layout in _d.layouts.layouts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Pressable(
                onTap: () {
                  _d.show(layout.id);
                  nav.pop();
                },
                semanticLabel: layout.name,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: layout.id == _d.layoutId ? _accent : _edge,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              layout.name,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l.deckPages(layout.portrait.pages.length),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.deckRename,
                        icon: const Icon(Ph.pencilSimple, color: _muted),
                        onPressed: () async {
                          final name = await _ask(l.deckRename, layout.name);
                          if (name != null) {
                            setState(() => _d.rename(layout.id, name));
                          }
                        },
                      ),
                      if (_d.layouts.layouts.length > 1)
                        IconButton(
                          tooltip: l.deckRemoveShort,
                          icon: const Icon(Ph.trash, color: _muted),
                          onPressed: () =>
                              setState(() => _d.removeLayout(layout.id)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          _label(l.deckNewLayout),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                start(l.deckBlank, DeckStart.blank),
                start(l.deckMusic, DeckStart.media),
                start(l.deckPresenter, DeckStart.presenter),
              ],
            ),
          ),
          _label(l.deckLandscape),
          SmallAction(
            label: l.deckLandscapeFromPortrait,
            color: _ink,
            fill: _raised,
            onTap: () {
              setState(_d.landscapeFromPortrait);
              showMessage(context, l.deckMade);
            },
          ),
          if (widget.fromComputer) ...[
            const SizedBox(height: 18),
            SmallAction(
              label: l.deckUseComputers(widget.device.name),
              color: _ink,
              fill: _raised,
              onTap: () async {
                await c.dropDeckHere(widget.device.id);
                nav.popUntil((r) => r.isFirst || r.settings.name == null);
              },
            ),
          ],
          const SizedBox(height: 18),
          Text(
            l.deckSavedHere(widget.device.name),
            style: const TextStyle(color: _muted, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
