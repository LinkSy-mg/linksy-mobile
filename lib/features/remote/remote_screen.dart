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
}

/// This phone as a computer's touchpad, keyboard and presentation remote
/// (session kind `input`). Asks the computer when it opens; its user allows
/// it there. Going back ends it.
class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key, required this.device});

  final DeviceInfo device;

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

enum _Mode { touchpad, slides }

class _RemoteScreenState extends State<RemoteScreen> {
  late final LinksyController _c;
  _Mode _mode = _Mode.touchpad;
  String? _error;
  bool _asking = true;
  StreamSubscription<bool>? _volume;

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

  void _key(int keysym) => _send([
    {'type': 'key', 'keysym': keysym, 'pressed': true},
    {'type': 'key', 'keysym': keysym, 'pressed': false},
  ]);

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
                                    _Touchpad(send: _send, onKey: _key),
                                    _Slides(
                                      send: _send,
                                      onKey: _key,
                                      typing: typing,
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
    ];
    return Segments(
      labels: [for (final (_, label) in tabs) label],
      selected: mode.index,
      onChanged: (i) => onChanged(_Mode.values[i]),
      builder: (context, i, on) {
        final (icon, label) = tabs[i];
        final color = Color.lerp(s.muted, Colors.white, on);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
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
/// two fingers scroll. The keyboard types into whatever has focus there.
class _Touchpad extends StatefulWidget {
  const _Touchpad({required this.send, required this.onKey});

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;

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

  @override
  void dispose() {
    _flush?.cancel();
    super.dispose();
  }

  Offset _centroid() =>
      _pointers.values.reduce((a, b) => a + b) / _pointers.length.toDouble();

  void _down(PointerDownEvent e) {
    if (_pointers.isEmpty) {
      _downAt = DateTime.now();
      _travel = 0;
      _maxFingers = 0;
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
      // Faster swipes go further, as on a laptop's touchpad.
      final speed = e.delta.distance;
      final gain = 1.4 + (speed / 12).clamp(0.0, 1.6);
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
    final quick =
        DateTime.now().difference(_downAt) < const Duration(milliseconds: 220);
    if (quick && _travel < 12) {
      _click(_maxFingers >= 2 ? 'right' : 'left');
    }
  }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Ph.handPointing, size: 34, color: s.faint),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.remoteTouchpadHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: s.faint, height: 1.5),
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
        _Keyboard(send: widget.send, onKey: widget.onKey),
      ],
    );
  }
}

/// A button that brings up the phone's keyboard, which types into whatever
/// has focus on the computer.
class _Keyboard extends StatefulWidget {
  const _Keyboard({required this.send, required this.onKey});

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;

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
  final _focus = FocusNode();

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _typed(String value) {
    if (value.length < _placeholder.length || !value.startsWith(_placeholder)) {
      widget.onKey(Keysym.backspace);
    } else if (value.length > _placeholder.length) {
      final text = value.substring(_placeholder.length);
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
    required this.typing,
  });

  final void Function(List<Map<String, Object>>) send;
  final void Function(int keysym) onKey;

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
        const SizedBox(height: 12),
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
