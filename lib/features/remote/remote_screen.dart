import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// X11 keysyms the computer understands (docs/protocol.md §4.8).
abstract final class Keysym {
  static const left = 0xff51;
  static const right = 0xff53;
  static const enter = 0xff0d;
  static const backspace = 0xff08;
  static const escape = 0xff1b;
  static const f5 = 0xffc2;
  static const shiftLeft = 0xffe1;
  static const shiftRight = 0xffe2;
  static const up = 0xff52;
  static const down = 0xff54;
  static const home = 0xff50;
  static const end = 0xff57;
  static const pageUp = 0xff55;
  static const pageDown = 0xff56;
  static const tab = 0xff09;
  static const delete = 0xffff;
  static const insert = 0xff63;
  static const print = 0xff61;
  static const controlLeft = 0xffe3;
  static const altLeft = 0xffe9;
  static const superLeft = 0xffeb;

  /// F1 to F12: [f1] + 0 to 11.
  static const f1 = 0xffbe;

  /// The keysym a typed character has: Latin-1's are their code point
  /// (letters lower case, as the key is), the rest 0x01000000 + it.
  static int ofChar(String char) {
    final code = char.toLowerCase().runes.first;
    return code < 0x100 ? code : 0x01000000 + code;
  }
}

/// The modifiers on the touchpad's key row, in the order they're pressed.
const _modifiers = [
  (Keysym.controlLeft, 'Ctrl'),
  (Keysym.altLeft, 'Alt'),
  (Keysym.shiftLeft, 'Shift'),
  (Keysym.superLeft, 'Super'),
];

/// This phone as a computer's touchpad, keyboard and presentation remote
/// (session kind `input`). Asks the computer when it opens; its user allows
/// it there. Going back ends it.
class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key, required this.device});

  final DeviceInfo device;

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

enum _Mode { touchpad, slides, browser }

class _RemoteScreenState extends State<RemoteScreen> {
  late final LinksyController _c;
  _Mode _mode = _Mode.touchpad;
  String? _error;
  bool _asking = true;
  StreamSubscription<bool>? _volume;

  /// Modifiers tapped on the key row: held for the next key, then let go.
  final Set<int> _mods = {};

  String get _id => widget.device.id;

  @override
  void initState() {
    super.initState();
    _c = LinksyScope.read(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    setState(() {
      _asking = true;
      _error = null;
    });
    final error = await _c.startRemote(_id);
    if (!mounted) return;
    setState(() {
      _asking = false;
      _error = error;
    });
  }

  @override
  void dispose() {
    _volume?.cancel();
    LinksyPlatform.presentation(false);
    // Open a minute longer: Deck and back doesn't ask the computer again.
    _c.leaveRemote(_id);
    super.dispose();
  }

  void _send(List<Map<String, Object>> messages) {
    _c.remoteSend(_id, messages).then((ok) {
      if (!ok && mounted && _c.remotes[_id] == null) setState(() {});
    });
  }

  /// [keysym] pressed and let go, with the modifiers tapped before it.
  void _key(int keysym) {
    final mods = [
      for (final (m, _) in _modifiers)
        if (_mods.contains(m)) m,
    ];
    if (mods.isNotEmpty) setState(_mods.clear);
    _chord(mods, keysym);
  }

  /// [keysym] with [mods] held around it (Alt+Left, Ctrl+T).
  void _chord(List<int> mods, int keysym) => _send([
    for (final m in mods) {'type': 'key', 'keysym': m, 'pressed': true},
    {'type': 'key', 'keysym': keysym, 'pressed': true},
    {'type': 'key', 'keysym': keysym, 'pressed': false},
    for (final m in mods.reversed)
      {'type': 'key', 'keysym': m, 'pressed': false},
  ]);

  void _toggleMod(int keysym) => setState(
    () => _mods.contains(keysym) ? _mods.remove(keysym) : _mods.add(keysym),
  );

  void _setMode(_Mode mode) {
    setState(() => _mode = mode);
    final slides = mode == _Mode.slides;
    LinksyPlatform.presentation(slides);
    _volume?.cancel();
    _volume = slides
        ? LinksyPlatform.volumeKeys.listen(
            (up) => _key(up ? Keysym.left : Keysym.right),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final live = c.remotes.containsKey(_id);
    // Read above the Scaffold, which takes the keyboard out of its body's.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    final name = widget.device.name;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayFor(Theme.of(context).brightness),
      child: Scaffold(
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
                      tooltip: context.l10n.remoteBack,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.remoteTitle,
                            style: sora(20, color: s.ink),
                          ),
                          Text(
                            name,
                            style: TextStyle(color: s.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: motion(context),
                    child: !live
                        ? _Waiting(
                            key: const ValueKey(false),
                            name: name,
                            asking: _asking,
                            error: _error,
                            ended: !_asking && _error == null,
                            onRetry: _connect,
                          )
                        : Column(
                            key: const ValueKey(true),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ModeSwitch(mode: _mode, onChanged: _setMode),
                              const SizedBox(height: 14),
                              Expanded(
                                child: _Sliding(
                                  index: _mode.index,
                                  children: [
                                    _Touchpad(
                                      send: _send,
                                      onKey: _key,
                                      mods: _mods,
                                      onMod: _toggleMod,
                                      onModAlone: (m) => _chord(const [], m),
                                    ),
                                    _Slides(
                                      send: _send,
                                      onKey: _key,
                                      onChord: _chord,
                                      typing: typing,
                                    ),
                                    _Browser(
                                      send: _send,
                                      onKey: _key,
                                      onChord: _chord,
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
        ),
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({
    super.key,
    required this.name,
    required this.asking,
    required this.error,
    required this.ended,
    required this.onRetry,
  });

  final String name;
  final bool asking;
  final String? error;
  final bool ended;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final (title, detail) = asking
        ? (context.l10n.remoteAllowOn(name), context.l10n.remoteAsks(name))
        : error != null
        ? (context.l10n.remoteFailed, error!)
        : (context.l10n.remoteStopped, context.l10n.remoteEndedBy(name));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconCircle(icon: Ph.mouseSimple, color: Sig.blue, size: 72),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: sora(20, color: s.ink),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: TextStyle(color: s.muted, height: 1.4),
        ),
        if (!asking) ...[
          const SizedBox(height: 22),
          SigButton(label: context.l10n.remoteTryAgain, onTap: onRetry),
        ],
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _Mode mode;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final tabs = [
      (Ph.mouseSimple, context.l10n.remoteTouchpad),
      (Ph.presentation, context.l10n.remoteSlides),
      (Ph.globe, context.l10n.remoteBrowser),
    ];
    return Segments(
      labels: [for (final (_, label) in tabs) label],
      selected: mode.index,
      onChanged: (i) => onChanged(_Mode.values[i]),
      builder: (context, i, on) {
        final (icon, label) = tabs[i];
        final color = Color.lerp(s.muted, Colors.white, on);
        // Three to a narrow phone: the name gives way, the icon stays.
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The modes side by side: switching slides from one to the next, the way
/// the pill above moves. Only the one that's on is kept once it settles.
class _Sliding extends StatelessWidget {
  const _Sliding({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: index.toDouble()),
        duration: motion(context, 260),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => Stack(
          fit: StackFit.expand,
          children: [
            for (final (i, child) in children.indexed)
              if ((i - t).abs() < 1)
                FractionalTranslation(
                  key: ValueKey(i),
                  translation: Offset((rtl ? t - i : i - t), 0),
                  child: child,
                ),
          ],
        ),
      ),
    );
  }
}

/// One finger moves the pointer, a tap clicks, a two-finger tap right-clicks,
/// two fingers scroll. Double-tap and slide drags (mobile#22): the button
/// stays down when the finger lifts, so the drag goes on with the next
/// stroke, until a tap lets go. The keyboard types into whatever has focus
/// there.
class _Touchpad extends StatefulWidget {
  const _Touchpad({
    required this.send,
    required this.onKey,
    required this.mods,
    required this.onMod,
    required this.onModAlone,
  });

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;

  /// The modifiers tapped for the next key.
  final Set<int> mods;
  final ValueChanged<int> onMod;
  final ValueChanged<int> onModAlone;

  @override
  State<_Touchpad> createState() => _TouchpadState();
}

class _TouchpadState extends State<_Touchpad> {
  final _pointers = <int, Offset>{};
  int _maxFingers = 0;
  DateTime _downAt = DateTime.now();
  double _travel = 0;
  Offset? _scrollFrom;
  Offset _pending = Offset.zero;
  Timer? _flush;

  /// The last tap, for a double-tap that turns into a drag.
  DateTime? _tappedAt;

  /// This touch came right after a tap: moving drags.
  bool _armed = false;

  /// The left button is held down on the computer.
  bool _dragging = false;

  @override
  void dispose() {
    _flush?.cancel();
    // Never leave the computer's button held down.
    if (_dragging) _button('left', pressed: false);
    super.dispose();
  }

  Offset _centroid() =>
      _pointers.values.reduce((a, b) => a + b) / _pointers.length.toDouble();

  void _down(PointerDownEvent e) {
    if (_pointers.isEmpty) {
      _downAt = DateTime.now();
      _travel = 0;
      _maxFingers = 0;
      final tapped = _tappedAt;
      _armed =
          !_dragging &&
          tapped != null &&
          _downAt.difference(tapped) < const Duration(milliseconds: 300);
    }
    _pointers[e.pointer] = e.localPosition;
    _maxFingers = _pointers.length > _maxFingers
        ? _pointers.length
        : _maxFingers;
    if (_pointers.length >= 2) _scrollFrom = _centroid();
  }

  void _move(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _travel += e.delta.distance;
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length == 1 && _maxFingers == 1) {
      if (_armed && !_dragging && _travel >= 12) {
        // Double-tap and slide: hold the button down, then move.
        _armed = false;
        _sendMove();
        _button('left', pressed: true);
        HapticFeedback.mediumImpact();
        setState(() => _dragging = true);
      }
      // Faster swipes go further, as on a laptop's touchpad.
      final speed = e.delta.distance;
      final gain =
          (1.4 + (speed / 12).clamp(0.0, 1.6)) *
          LinksyScope.read(context).pointerSpeed;
      _pending += e.delta * gain;
      _flush ??= Timer(const Duration(milliseconds: 12), _sendMove);
    } else if (_pointers.length >= 2 && _scrollFrom != null) {
      final now = _centroid();
      final d = now - _scrollFrom!;
      _scrollFrom = now;
      // The content follows the fingers, unless turned the other way.
      final sign = LinksyScope.read(context).scrollReversed ? 1 : -1;
      widget.send([
        {
          'type': 'scroll',
          'dx': sign * d.dx,
          'dy': sign * d.dy,
          'discrete': false,
        },
      ]);
    }
  }

  void _sendMove() {
    _flush = null;
    if (_pending == Offset.zero) return;
    widget.send([
      {'type': 'pointer_by', 'dx': _pending.dx, 'dy': _pending.dy},
    ]);
    _pending = Offset.zero;
  }

  void _up(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.isNotEmpty) {
      if (_pointers.length >= 2) _scrollFrom = _centroid();
      return;
    }
    _scrollFrom = null;
    _armed = false;
    final quick =
        DateTime.now().difference(_downAt) < const Duration(milliseconds: 220);
    if (quick && _travel < 12) {
      if (_dragging) {
        // A tap ends the drag: the button comes up where the pointer is.
        _sendMove();
        _button('left', pressed: false);
        HapticFeedback.selectionClick();
        setState(() => _dragging = false);
        _tappedAt = null;
        return;
      }
      _click(_maxFingers >= 2 ? 'right' : 'left');
      _tappedAt = _maxFingers >= 2 ? null : DateTime.now();
    } else {
      _tappedAt = null;
    }
  }

  void _button(String button, {required bool pressed}) => widget.send([
    {'type': 'button', 'button': button, 'pressed': pressed},
  ]);

  void _click(String button) {
    HapticFeedback.selectionClick();
    widget.send([
      {'type': 'button', 'button': button, 'pressed': true},
      {'type': 'button', 'button': button, 'pressed': false},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _down,
            onPointerMove: _move,
            onPointerUp: _up,
            onPointerCancel: _up,
            child: Container(
              decoration: BoxDecoration(
                color: s.card,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              alignment: Alignment.center,
              foregroundDecoration: _dragging
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.xl),
                      border: Border.all(color: Sig.blue, width: 2),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _dragging ? Ph.handGrabbing : Ph.handPointing,
                    size: 34,
                    color: _dragging ? Sig.blue : s.faint,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _dragging
                        ? context.l10n.remoteDragging
                        : '${context.l10n.remoteTouchpadHint}\n'
                              '${context.l10n.remoteDragHint}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _dragging ? Sig.blue : s.faint,
                      height: 1.5,
                      fontWeight: _dragging ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PadButton(
                label: context.l10n.remoteLeftClick,
                onTap: () => _click('left'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PadButton(
                label: context.l10n.remoteRightClick,
                onTap: () => _click('right'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _KeyRow(
          mods: widget.mods,
          onMod: widget.onMod,
          onModAlone: widget.onModAlone,
          onKey: widget.onKey,
        ),
        const SizedBox(height: 10),
        _Keyboard(
          send: widget.send,
          onKey: widget.onKey,
          modded: widget.mods.isNotEmpty,
        ),
      ],
    );
  }
}

/// The keys a phone's keyboard hasn't got, in one row that scrolls: Ctrl,
/// Alt, Shift and Super stay down for the next key (or a typed letter:
/// Ctrl, then c), held they press alone (Super opens the launcher). Then
/// Esc, Tab, the arrows, Home to Insert, PrtSc and F1 to F12.
class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.mods,
    required this.onMod,
    required this.onModAlone,
    required this.onKey,
  });

  final Set<int> mods;
  final ValueChanged<int> onMod;
  final ValueChanged<int> onModAlone;
  final void Function(int keysym) onKey;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    Widget key(
      String label,
      VoidCallback onTap, {
      IconData? icon,
      bool on = false,
      VoidCallback? onHold,
      String? tooltip,
    }) {
      final face = Pressable.builder(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: onHold == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onHold();
              },
        semanticLabel: label,
        builder: (context, down) => AnimatedContainer(
          duration: motion(context, 90),
          height: 44,
          constraints: const BoxConstraints(minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? Sig.blue : (down ? s.raised : s.card),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: icon != null
              ? Icon(icon, size: 18, color: on ? Colors.white : s.ink)
              : Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: on ? Colors.white : s.ink,
                  ),
                ),
        ),
      );
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 6),
        child: tooltip == null ? face : Tooltip(message: tooltip, child: face),
      );
    }

    final hint = context.l10n.remoteModHint;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (m, label) in _modifiers)
            key(
              label,
              () => onMod(m),
              on: mods.contains(m),
              onHold: () => onModAlone(m),
              tooltip: hint,
            ),
          key('Esc', () => onKey(Keysym.escape)),
          key('Tab', () => onKey(Keysym.tab)),
          key('←', () => onKey(Keysym.left), icon: Ph.arrowLeft),
          key('↑', () => onKey(Keysym.up), icon: Ph.arrowUp),
          key('↓', () => onKey(Keysym.down), icon: Ph.arrowDown),
          key('→', () => onKey(Keysym.right), icon: Ph.arrowRight),
          key('Home', () => onKey(Keysym.home)),
          key('End', () => onKey(Keysym.end)),
          key('PgUp', () => onKey(Keysym.pageUp)),
          key('PgDn', () => onKey(Keysym.pageDown)),
          key('Del', () => onKey(Keysym.delete)),
          key('Ins', () => onKey(Keysym.insert)),
          key('PrtSc', () => onKey(Keysym.print)),
          for (var i = 0; i < 12; i++)
            key('F${i + 1}', () => onKey(Keysym.f1 + i)),
        ],
      ),
    );
  }
}

/// A button that brings up the phone's keyboard, which types into whatever
/// has focus on the computer.
class _Keyboard extends StatefulWidget {
  const _Keyboard({
    required this.send,
    required this.onKey,
    this.modded = false,
    this.focus,
  });

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;

  /// A modifier is down for the next key: a typed letter goes as its key
  /// (Ctrl, then c), not as text.
  final bool modded;

  /// Given by a page that brings the keyboard up itself (Address).
  final FocusNode? focus;

  @override
  State<_Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<_Keyboard> {
  // The keyboard: a hidden field that always holds one placeholder, so
  // Backspace on an empty field still shows up as a change.
  static const _placeholder = '​';

  /// What a US keyboard types with Shift, besides capitals.
  static final _shifted = RegExp(r'[~!@#$%^&*()_+{}|:"<>?]');
  final _field = TextEditingController(text: _placeholder);
  late final FocusNode _focus = widget.focus ?? FocusNode();

  @override
  void dispose() {
    _field.dispose();
    if (widget.focus == null) _focus.dispose();
    super.dispose();
  }

  void _typed(String value) {
    if (value.length < _placeholder.length || !value.startsWith(_placeholder)) {
      widget.onKey(Keysym.backspace);
    } else if (value.length > _placeholder.length) {
      final text = value.substring(_placeholder.length);
      if (widget.modded && text.runes.length == 1) {
        widget.onKey(Keysym.ofChar(text));
      } else {
        widget.send([
          {'type': 'text', 'text': text},
          // Some computers (KDE's) hold Shift down to type a capital and
          // never let go: let go of it here.
          if (text.toLowerCase() != text || _shifted.hasMatch(text)) ...[
            {'type': 'key', 'keysym': Keysym.shiftLeft, 'pressed': false},
            {'type': 'key', 'keysym': Keysym.shiftRight, 'pressed': false},
          ],
        ]);
      }
    }
    _field.value = const TextEditingValue(
      text: _placeholder,
      selection: TextSelection.collapsed(offset: _placeholder.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Off screen, but focusable: it brings up the keyboard.
        SizedBox(
          height: 0,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _field,
              focusNode: _focus,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              onChanged: _typed,
              onSubmitted: (_) {
                widget.onKey(Keysym.enter);
                _focus.requestFocus();
              },
            ),
          ),
        ),
        SigButton(
          label: context.l10n.remoteKeyboard,
          icon: Ph.keyboard,
          kind: SigButtonKind.secondary,
          expand: true,
          onTap: () {
            if (_focus.hasFocus) {
              _focus.unfocus();
            } else {
              _focus.requestFocus();
              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
            }
          },
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable.builder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, down) => AnimatedContainer(
        duration: motion(context, 90),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: down ? s.raised : s.card,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: s.ink),
        ),
      ),
    );
  }
}

/// Presentation remote: big Back / Next, and the volume keys do the same
/// with the phone in a pocket. The screen stays on meanwhile. A number pad
/// jumps to a slide (its number, then Enter), and the keyboard types.
class _Slides extends StatelessWidget {
  const _Slides({
    required this.send,
    required this.onKey,
    required this.onChord,
    required this.typing,
  });

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;
  final void Function(List<int> mods, int keysym) onChord;

  /// Whether the phone's keyboard is up.
  final bool typing;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    // The keyboard and the number pad don't both fit: the pad steps aside
    // while the keyboard is up, and comes back when it goes.
    final numpad = c.slidesNumpad && !typing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Pressable.builder(
            onTap: () => onKey(Keysym.right),
            semanticLabel: context.l10n.remoteNextSlide,
            builder: (context, down) => AnimatedContainer(
              duration: motion(context, 90),
              decoration: BoxDecoration(
                color: down ? Sig.deep : Sig.blue,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              // Smaller while the number pad takes room.
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: numpad ? 0 : 1),
                duration: motion(context, 220),
                curve: Curves.easeOutCubic,
                builder: (context, big, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ph.caretRight,
                      color: Colors.white,
                      size: 40 + 16 * big,
                    ),
                    Text(
                      context.l10n.remoteNext,
                      style: sora(
                        20 + 6 * big,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: Pressable.builder(
            onTap: () => onKey(Keysym.left),
            semanticLabel: context.l10n.remotePreviousSlide,
            builder: (context, down) => AnimatedContainer(
              duration: motion(context, 90),
              decoration: BoxDecoration(
                color: down ? s.raised : s.card,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ph.caretLeft, color: s.ink, size: 32),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.remoteSlideBack,
                    style: sora(20, color: s.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // The keys Impress, PowerPoint and most PDF viewers share.
        _ChipRow(
          chips: [
            (context.l10n.remoteFirstSlide, () => onKey(Keysym.home)),
            (context.l10n.remoteLastSlide, () => onKey(Keysym.end)),
            (context.l10n.remoteBlackScreen, () => onKey(Keysym.ofChar('b'))),
            (context.l10n.remoteWhiteScreen, () => onKey(Keysym.ofChar('w'))),
            (
              context.l10n.remoteFromHere,
              () => onChord(const [Keysym.shiftLeft], Keysym.f5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSize(
          duration: motion(context, 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: numpad
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _Numpad(onKey: onKey),
                )
              : const SizedBox(width: double.infinity),
        ),
        Row(
          children: [
            Expanded(
              child: _PadButton(
                label: context.l10n.remoteStartShow,
                onTap: () => onKey(Keysym.f5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PadButton(
                label: context.l10n.remoteEndShow,
                onTap: () => onKey(Keysym.escape),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SigButton(
                label: context.l10n.remoteNumbers,
                icon: Ph.numpad,
                kind: numpad ? SigButtonKind.primary : SigButtonKind.secondary,
                expand: true,
                onTap: () {
                  if (typing) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    c.setSlidesNumpad(true);
                  } else {
                    c.setSlidesNumpad(!numpad);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Keyboard(send: send, onKey: onKey),
            ),
          ],
        ),
        AnimatedSize(
          duration: motion(context, 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !numpad && !typing
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    context.l10n.remoteVolumeHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: s.muted, fontSize: 13),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// 1–9, then Backspace, 0 and Enter: "12, Enter" goes to slide 12 in
/// Impress, PowerPoint and most PDF viewers.
class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});

  final void Function(int keysym) onKey;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    Widget key(int keysym, String label, {IconData? icon}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Pressable.builder(
          onTap: () => onKey(keysym),
          semanticLabel: label,
          builder: (context, down) => AnimatedContainer(
            duration: motion(context, 90),
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: down ? s.raised : s.card,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: icon != null
                ? Icon(icon, color: s.ink, size: 22)
                : Text(label, style: sora(20, color: s.ink)),
          ),
        ),
      ),
    );
    Widget digit(int n) => key(0x30 + n, '$n');
    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final n in row) digit(n)]),
        Row(
          children: [
            key(
              Keysym.backspace,
              context.l10n.remoteBackspace,
              icon: Ph.backspace,
            ),
            digit(0),
            key(
              Keysym.enter,
              context.l10n.remoteEnter,
              icon: Ph.arrowElbowDownLeft,
            ),
          ],
        ),
      ],
    );
  }
}

/// Small buttons in one row that scrolls when they don't fit.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.chips});

  final List<(String, VoidCallback)> chips;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (label, onTap) in chips)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Pressable.builder(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                semanticLabel: label,
                builder: (context, down) => AnimatedContainer(
                  duration: motion(context, 90),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: down ? s.raised : s.card,
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: s.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The browser in front on the computer, by its shortcuts (Chrome, Firefox,
/// Edge and most others share them): Back and Forward big, then Reload,
/// Home, tabs, and Address, which goes to the address bar and brings up the
/// keyboard to type there.
class _Browser extends StatefulWidget {
  const _Browser({
    required this.send,
    required this.onKey,
    required this.onChord,
  });

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;
  final void Function(List<int> mods, int keysym) onChord;

  @override
  State<_Browser> createState() => _BrowserState();
}

class _BrowserState extends State<_Browser> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _chord(List<int> mods, int keysym) {
    HapticFeedback.selectionClick();
    widget.onChord(mods, keysym);
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    const alt = [Keysym.altLeft];
    const ctrl = [Keysym.controlLeft];
    Widget big(IconData icon, String label, VoidCallback onTap, bool main) =>
        Expanded(
          child: Pressable.builder(
            onTap: onTap,
            semanticLabel: label,
            builder: (context, down) => AnimatedContainer(
              duration: motion(context, 90),
              decoration: BoxDecoration(
                color: main
                    ? (down ? Sig.deep : Sig.blue)
                    : (down ? s.raised : s.card),
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: main ? Colors.white : s.ink),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: sora(18, color: main ? Colors.white : s.ink),
                  ),
                ],
              ),
            ),
          ),
        );
    Widget small(IconData icon, String label, VoidCallback onTap) => Expanded(
      child: Pressable.builder(
        onTap: onTap,
        semanticLabel: label,
        builder: (context, down) => AnimatedContainer(
          duration: motion(context, 90),
          height: 64,
          decoration: BoxDecoration(
            color: down ? s.raised : s.card,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: s.ink),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: s.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    const gap = SizedBox(width: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              big(
                Ph.arrowLeft,
                l.remoteWebBack,
                () => _chord(alt, Keysym.left),
                false,
              ),
              gap,
              big(
                Ph.arrowRight,
                l.remoteWebForward,
                () => _chord(alt, Keysym.right),
                false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            small(
              Ph.arrowClockwise,
              l.remoteWebReload,
              () => _chord(const [], Keysym.f5),
            ),
            gap,
            small(Ph.house, l.remoteWebHome, () => _chord(alt, Keysym.home)),
            gap,
            small(Ph.plus, l.remoteWebNewTab, () => _chord(ctrl, 0x74)),
            gap,
            small(Ph.x, l.remoteWebCloseTab, () => _chord(ctrl, 0x77)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            small(
              Ph.caretLeft,
              l.remoteWebPrevTab,
              () => _chord(ctrl, Keysym.pageUp),
            ),
            gap,
            small(
              Ph.caretRight,
              l.remoteWebNextTab,
              () => _chord(ctrl, Keysym.pageDown),
            ),
            gap,
            small(Ph.arrowUp, 'PgUp', () => _chord(const [], Keysym.pageUp)),
            gap,
            small(
              Ph.arrowDown,
              'PgDn',
              () => _chord(const [], Keysym.pageDown),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SigButton(
                label: l.remoteWebAddress,
                icon: Ph.globe,
                kind: SigButtonKind.secondary,
                expand: true,
                onTap: () {
                  // Ctrl+L selects the address; what's typed replaces it.
                  _chord(ctrl, 0x6c);
                  _focus.requestFocus();
                  SystemChannels.textInput.invokeMethod<void>('TextInput.show');
                },
              ),
            ),
            gap,
            Expanded(
              child: _Keyboard(
                send: widget.send,
                onKey: widget.onKey,
                focus: _focus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l.remoteWebHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: s.muted, fontSize: 13),
        ),
      ],
    );
  }
}
