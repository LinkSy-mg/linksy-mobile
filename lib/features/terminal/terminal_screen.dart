import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';

import '../../app/scope.dart';
import '../../app/terminals.dart';
import '../../core/linksy_node.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/format.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// Signal's navy, with the brand's blue and cyan in the palette.
const _theme = TerminalTheme(
  cursor: Color(0xFF22C3E6),
  selection: Color(0x662563FF),
  foreground: Color(0xFFE6EBF5),
  background: Color(0xFF080D1F),
  black: Color(0xFF0A1024),
  red: Color(0xFFFF5C72),
  green: Color(0xFF3DDC84),
  yellow: Color(0xFFF5C451),
  blue: Color(0xFF5B8CFF),
  magenta: Color(0xFFC77DFF),
  cyan: Color(0xFF22C3E6),
  white: Color(0xFFE6EBF5),
  brightBlack: Color(0xFF56628A),
  brightRed: Color(0xFFFF8A9A),
  brightGreen: Color(0xFF7BEAB0),
  brightYellow: Color(0xFFFFDC85),
  brightBlue: Color(0xFF8FB0FF),
  brightMagenta: Color(0xFFDDA8FF),
  brightCyan: Color(0xFF9FE6F5),
  brightWhite: Color(0xFFFFFFFF),
  searchHitBackground: Color(0xFFF5C451),
  searchHitBackgroundCurrent: Color(0xFF3DDC84),
  searchHitForeground: Color(0xFF0A1024),
);

const _bg = Color(0xFF080D1F);
const _panel = Color(0xFF111A3A);
const _raised = Color(0xFF1A2550);
const _muted = Color(0xFF94A0C0);

/// A shell on a computer (docs/protocol.md §4.15): tabs, the terminal, a key bar
/// above the keyboard. Each open asks for the code set on the computer.
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  TerminalTab? _current;
  final _focus = FocusNode();
  StreamSubscription<TerminalTab>? _gone;

  /// The terminal's text size, pinched; kept for next time.
  late double _fontSize =
      double.tryParse(LinksyScope.read(context).prefs['term_font'] ?? '') ??
      11.5;
  static const _minFont = 6.0;
  static const _maxFont = 24.0;
  final _pointers = <int, Offset>{};
  double? _pinchStart;
  double _fontAtStart = 11.5;

  double get _spread {
    final p = _pointers.values.toList();
    return (p[0] - p[1]).distance;
  }

  void _pointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _pinchStart = _spread;
      _fontAtStart = _fontSize;
    }
  }

  void _pointerMove(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.position;
    final start = _pinchStart;
    if (_pointers.length != 2 || start == null || start < 1) return;
    final size = (_fontAtStart * _spread / start).clamp(_minFont, _maxFont);
    // Whole half-points: fewer relayouts (and resizes sent) while pinching.
    final rounded = (size * 2).roundToDouble() / 2;
    if (rounded != _fontSize) setState(() => _fontSize = rounded);
  }

  void _pointerUp(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.length < 2 && _pinchStart != null) {
      _pinchStart = null;
      LinksyScope.read(context).setPref('term_font', '$_fontSize');
    }
  }

  @override
  void initState() {
    super.initState();
    // `exit` typed in the shell (or Close): the tab goes, and says so.
    _gone = LinksyScope.read(context).terminals.gone.listen((t) {
      if (!mounted || t.deviceId != widget.deviceId) return;
      // Nothing to type into any more: the keyboard goes too.
      if (LinksyScope.read(context).terminals.of(widget.deviceId).isEmpty) {
        _focus.unfocus();
      }
      showMessage(
        context,
        t.closedHere
            ? context.l10n.terminalTabClosed(t.title)
            : context.l10n.terminalTabEnded(t.title, _name),
      );
    });
  }

  @override
  void dispose() {
    _gone?.cancel();
    _focus.dispose();
    super.dispose();
  }

  /// Close, made obvious: asks first (a shell may be busy), offers to leave
  /// it running instead. A detached one is reattached to end it.
  Future<void> _close(TerminalTab tab) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(context.l10n.terminalCloseTitle),
        content: Text(context.l10n.terminalCloseDetail(_name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop('keep'),
            child: Text(context.l10n.terminalKeepRunning),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop('close'),
            style: TextButton.styleFrom(foregroundColor: Sig.of(context).red),
            child: Text(context.l10n.terminalClose),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'keep') {
      if (tab.state == TabState.live) await tab.detach();
      return;
    }
    if (tab.state == TabState.detached) {
      // Ending it takes the shell itself: open it once more, then close.
      if (!await askCodeAndOpen(context, tab, _name)) return;
    }
    if (!mounted) return;
    if (tab.state == TabState.locked || tab.state == TabState.opening) {
      LinksyScope.read(context).terminals.remove(tab);
      return;
    }
    await tab.close();
  }

  String get _name =>
      LinksyScope.read(context).device(widget.deviceId)?.device.name ??
      context.l10n.terminalTheComputer;

  Future<void> _newTab({RemoteTerminal? resume}) async {
    final terminals = LinksyScope.read(context).terminals;
    final tab = terminals.add(widget.deviceId);
    if (resume != null) {
      tab
        ..terminalId = resume.id
        ..title = resume.title;
    }
    setState(() => _current = tab);
    final opened = await askCodeAndOpen(context, tab, _name);
    if (!mounted) return;
    if (!opened && tab.state != TabState.live) {
      terminals.remove(tab);
      setState(() => _current = terminals.of(widget.deviceId).lastOrNull);
    } else {
      _focus.requestFocus();
    }
  }

  Future<void> _reattach(TerminalTab tab) async {
    final opened = await askCodeAndOpen(context, tab, _name);
    if (opened && mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final terminals = c.terminals;
    return ListenableBuilder(
      listenable: terminals,
      builder: (context, _) {
        final tabs = terminals.of(widget.deviceId);
        var tab = _current;
        if (tab == null || !tabs.contains(tab)) tab = tabs.lastOrNull;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayFor(Brightness.dark),
          child: Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    name: _name,
                    tab: tab,
                    onDetach: tab == null || tab.state != TabState.live
                        ? null
                        : () => tab!.detach(),
                    onClose: tab == null ? null : () => _close(tab!),
                  ),
                  _Tabs(
                    tabs: tabs,
                    current: tab,
                    onPick: (t) => setState(() => _current = t),
                    onClose: _close,
                    onAdd: _newTab,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: motion(context),
                      child: tab == null
                          ? _Start(
                              key: const ValueKey('start'),
                              deviceId: widget.deviceId,
                              name: _name,
                              onNew: () => _newTab(),
                              onResume: (r) => _newTab(resume: r),
                            )
                          : Stack(
                              key: const ValueKey('tabs'),
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      4,
                                      4,
                                      0,
                                    ),
                                    // Two fingers: pinch the text smaller
                                    // for more columns (wide output like
                                    // fastfetch), or bigger to read.
                                    child: Listener(
                                      onPointerDown: _pointerDown,
                                      onPointerMove: _pointerMove,
                                      onPointerUp: _pointerUp,
                                      onPointerCancel: _pointerUp,
                                      child: TerminalView(
                                        tab.term,
                                        key: ObjectKey(tab),
                                        theme: _theme,
                                        focusNode: _focus,
                                        autofocus: tab.state == TabState.live,
                                        readOnly: tab.state != TabState.live,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        // Nerd Font symbols for prompts
                                        // (starship, powerline) and logos.
                                        textStyle: TerminalStyle(
                                          fontSize: _fontSize,
                                          fontFamily: 'JetBrainsMono',
                                          fontFamilyFallback: const [
                                            'NerdSymbols',
                                            'monospace',
                                            'Noto Sans Mono',
                                            'Noto Sans Symbols',
                                            'Noto Color Emoji',
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: AnimatedSwitcher(
                                    duration: motion(context),
                                    child: tab.state == TabState.detached
                                        ? _StateCard(
                                            icon: Ph.terminalWindow,
                                            title:
                                                context.l10n.terminalDetached,
                                            detail: context.l10n
                                                .terminalDetachedDetail(_name),
                                            action:
                                                context.l10n.terminalReattach,
                                            onAction: () => _reattach(tab!),
                                          )
                                        : const SizedBox(
                                            width: double.infinity,
                                          ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: AnimatedSwitcher(
                                    duration: motion(context),
                                    child: tab.state == TabState.opening
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Sig.cyan,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (tab != null && tab.state == TabState.live)
                    _KeyBar(tab: tab),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.tab,
    required this.onDetach,
    required this.onClose,
  });

  final String name;
  final TerminalTab? tab;
  final VoidCallback? onDetach;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = switch (tab?.state) {
      TabState.live => l.terminalOn(name),
      TabState.detached => l.terminalDetachedOn(name),
      TabState.opening => l.terminalOpeningOn(name),
      TabState.locked => l.terminalWaitingForCode,
      TabState.ended => l.terminalEnded,
      null => l.terminalOn(name),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
      child: Row(
        children: [
          RoundButton(
            icon: Ph.arrowLeft,
            tooltip: l.terminalBack,
            onDark: true,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tab?.title ?? l.terminalTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(17, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (tab?.state == TabState.live) ...[
                      const PulseDot(color: Sig.cyan, size: 6),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        state,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (tab != null && onDetach != null)
            PopupMenuButton<String>(
              tooltip: l.terminalMenu,
              icon: const Icon(Ph.dotsThree, color: Colors.white),
              color: _panel,
              onSelected: (v) =>
                  v == 'detach' ? onDetach?.call() : onClose?.call(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'detach',
                  child: Text(
                    l.terminalDetachMenu,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          if (tab != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: SmallAction(
                label: l.terminalClose,
                icon: Ph.x,
                onTap: onClose,
                color: const Color(0xFFFF8A9A),
                fill: const Color(0x26FF5C72),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tabs,
    required this.current,
    required this.onPick,
    required this.onClose,
    required this.onAdd,
  });

  final List<TerminalTab> tabs;
  final TerminalTab? current;
  final ValueChanged<TerminalTab> onPick;
  final ValueChanged<TerminalTab> onClose;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox(height: 4);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final t in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pressable(
                onTap: () => onPick(t),
                semanticLabel: t.title,
                child: AnimatedContainer(
                  duration: motion(context, 150),
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.only(left: 14),
                  decoration: BoxDecoration(
                    color: t == current ? Sig.blue : _panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: switch (t.state) {
                            TabState.live => Sig.cyan,
                            TabState.detached => const Color(0xFFF5C451),
                            _ => _muted,
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Pressable(
                        onTap: () => onClose(t),
                        scale: 0.85,
                        semanticLabel: context.l10n.terminalCloseTab(t.title),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(Ph.x, color: Colors.white70, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Pressable(
            onTap: onAdd,
            semanticLabel: context.l10n.terminalNew,
            child: Container(
              width: 36,
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(PhBold.plus, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// No tab yet: what still runs on the computer, and a new one.
class _Start extends StatefulWidget {
  const _Start({
    super.key,
    required this.deviceId,
    required this.name,
    required this.onNew,
    required this.onResume,
  });

  final String deviceId;
  final String name;
  final VoidCallback onNew;
  final ValueChanged<RemoteTerminal> onResume;

  @override
  State<_Start> createState() => _StartState();
}

class _StartState extends State<_Start> {
  late final Future<List<RemoteTerminal>> _running = LinksyScope.read(context)
      .terminals
      .running(widget.deviceId)
      .catchError((Object _) => <RemoteTerminal>[]);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Icon(Ph.terminalWindow, color: Sig.cyan, size: 44),
        const SizedBox(height: 14),
        Text(
          l.terminalShellOn(widget.name),
          textAlign: TextAlign.center,
          style: sora(22, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          l.terminalShellDetail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 22),
        SigButton(
          label: l.terminalNew,
          icon: PhBold.plus,
          expand: true,
          onTap: widget.onNew,
        ),
        FutureBuilder(
          future: _running,
          builder: (context, snap) {
            final list = snap.data ?? const <RemoteTerminal>[];
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 26, 6, 10),
                  child: Text(
                    l.terminalStillRunning,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: _muted,
                    ),
                  ),
                ),
                for (final r in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Pressable(
                      onTap: () => widget.onResume(r),
                      semanticLabel: l.terminalReattachTab(r.title),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(Radii.md + 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Ph.terminalWindow,
                              color: Color(0xFFF5C451),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.terminalStarted(formatClock(r.started)),
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              l.terminalReattach,
                              style: const TextStyle(
                                color: Sig.cyanLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: _raised),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF5C451), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: sora(16, color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SmallAction(
            label: action,
            onTap: onAction,
            color: Colors.white,
            fill: Sig.blue,
            height: 42,
          ),
        ],
      ),
    );
  }
}

/// Keys a phone keyboard lacks, above it: Esc, Ctrl and Alt (for the next
/// key), Tab, arrows and the symbols shells want.
class _KeyBar extends StatelessWidget {
  const _KeyBar({required this.tab});

  final TerminalTab tab;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget key(
      String label,
      VoidCallback onTap, {
      bool on = false,
      IconData? icon,
    }) => Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Pressable.builder(
        onTap: onTap,
        scale: 0.9,
        semanticLabel: label,
        builder: (context, down) => AnimatedContainer(
          duration: motion(context, 120),
          constraints: const BoxConstraints(minWidth: 44),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on
                ? Sig.blue
                : down
                ? Color.lerp(_raised, Colors.white, 0.12)
                : _raised,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 18)
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
        ),
      ),
    );
    return ListenableBuilder(
      listenable: tab,
      builder: (context, _) => Container(
        color: _panel,
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          children: [
            key('Esc', () => tab.special(TerminalKey.escape)),
            key('Ctrl', tab.toggleCtrl, on: tab.ctrl),
            key('Alt', tab.toggleAlt, on: tab.alt),
            key('Tab', () => tab.special(TerminalKey.tab)),
            key(
              l.terminalKeyLeft,
              () => tab.special(TerminalKey.arrowLeft),
              icon: Ph.arrowLeft,
            ),
            key(
              l.terminalKeyUp,
              () => tab.special(TerminalKey.arrowUp),
              icon: Ph.arrowUp,
            ),
            key(
              l.terminalKeyDown,
              () => tab.special(TerminalKey.arrowDown),
              icon: Ph.arrowDown,
            ),
            key(
              l.terminalKeyRight,
              () => tab.special(TerminalKey.arrowRight),
              icon: PhBold.arrowRight,
            ),
            key('Enter', () => tab.special(TerminalKey.enter)),
            key('^C', () => tab.key('\x03')),
            // What htop and btm want (mobile#2): sort, expand, zoom.
            for (final s in const ['%', '+', '-', '|', '~', '/'])
              key(s, () => tab.key(s)),
            key('Home', () => tab.special(TerminalKey.home)),
            key('End', () => tab.special(TerminalKey.end)),
            key('PgUp', () => tab.special(TerminalKey.pageUp)),
            key('PgDn', () => tab.special(TerminalKey.pageDown)),
            key('Del', () => tab.special(TerminalKey.delete)),
            for (final (i, f) in const [
              TerminalKey.f1,
              TerminalKey.f2,
              TerminalKey.f3,
              TerminalKey.f4,
              TerminalKey.f5,
              TerminalKey.f6,
              TerminalKey.f7,
              TerminalKey.f8,
              TerminalKey.f9,
              TerminalKey.f10,
              TerminalKey.f11,
              TerminalKey.f12,
            ].indexed)
              key('F${i + 1}', () => tab.special(f)),
          ],
        ),
      ),
    );
  }
}

/// Asks for the computer's terminal code and opens [tab] with it. The code
/// is never kept: it's typed each time (§4.15). True once open.
Future<bool> askCodeAndOpen(
  BuildContext context,
  TerminalTab tab,
  String name,
) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CodeSheet(tab: tab, name: name),
    ) ??
    false;

class _CodeSheet extends StatefulWidget {
  const _CodeSheet({required this.tab, required this.name});

  final TerminalTab tab;
  final String name;

  @override
  State<_CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends State<_CodeSheet> {
  final _code = TextEditingController();
  final _field = FocusNode();
  bool _letters = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code
      ..clear()
      ..dispose();
    _field.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final code = _code.text;
    if (code.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.tab.open(code);
      if (mounted) Navigator.of(context).pop(true);
    } on LinksyException catch (e) {
      _code.clear();
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
        // Straight back to typing it again, once the field is enabled.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _field.requestFocus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: IconCircle(icon: Ph.lockSimple, color: Sig.blue, size: 56),
          ),
          const SizedBox(height: 14),
          Text(
            l.terminalCodeTitle,
            textAlign: TextAlign.center,
            style: sora(21, color: s.ink),
          ),
          const SizedBox(height: 6),
          Text(
            l.terminalCodeDetail(widget.name),
            textAlign: TextAlign.center,
            style: TextStyle(color: s.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _code,
            focusNode: _field,
            autofocus: true,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            enabled: !_busy,
            keyboardType: _letters
                ? TextInputType.visiblePassword
                : TextInputType.number,
            textAlign: TextAlign.center,
            style: sora(22, color: s.ink, spacing: 4),
            onSubmitted: (_) => _open(),
            decoration: InputDecoration(
              hintText: _letters
                  ? l.terminalCodePassphrase
                  : l.terminalCodeDigitsHint,
              hintStyle: TextStyle(
                fontSize: 16,
                letterSpacing: 0,
                color: s.faint,
              ),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          Align(
            child: SmallAction(
              label: _letters
                  ? l.terminalCodeUseDigits
                  : l.terminalCodeUseLetters,
              onTap: _busy ? null : () => setState(() => _letters = !_letters),
            ),
          ),
          const SizedBox(height: 6),
          SigButton(
            label: _busy ? l.terminalOpening : l.terminalOpen,
            icon: Ph.terminalWindow,
            expand: true,
            onTap: _busy ? null : _open,
          ),
        ],
      ),
    );
  }
}
