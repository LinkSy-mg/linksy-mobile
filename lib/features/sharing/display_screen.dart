import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// A computer's screen full screen in landscape: this phone as its second
/// display (`display`), or its screen watched from here (`screen`, `control`
/// asked by the phone). With `display` and `control`, touches go back as
/// pointer input: one finger is the mouse with its left button held; two
/// fingers scroll.
class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key, required this.session});

  final SessionStarted session;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  int? _texture;
  double _aspect = 16 / 9;
  final _subs = <StreamSubscription<Object?>>[];
  final _pointers = <int, Offset>{};
  bool _pressed = false;
  Offset? _scrollFrom;
  bool _closing = false;
  bool _hint = true;

  String get _id => widget.session.session;

  /// Touches drive the computer (not when only watching).
  bool get _input => widget.session.kind != SessionKind.screen;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    LinksyPlatform.startDisplay(_id).then((t) {
      if (mounted) setState(() => _texture = t);
    });
    _subs
      ..add(
        LinksyPlatform.displaySizes.listen((size) {
          final (id, w, h) = size;
          if (id == _id && w > 0 && h > 0) setState(() => _aspect = w / h);
        }),
      )
      ..add(
        LinksyPlatform.displaysEnded.listen((id) {
          if (id == _id) _close();
        }),
      );
    Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _hint = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The computer stopped: the controller no longer lists this display.
    final c = LinksyScope.of(context);
    if (!c.displays.containsKey(_id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    LinksyScope.read(context).stopDisplay(_id);
    Navigator.of(context).maybePop();
  }

  /// Another of the computer's screens: this one closes, and its user picks
  /// again there; the new one opens like this one did.
  void _choose() {
    if (_closing) return;
    _closing = true;
    final peer = widget.session.peer;
    showMessage(context, context.l10n.displayChooseOn(peer.name));
    report(
      context,
      LinksyScope.read(context).chooseScreen(
        _id,
        peer.id,
        control: widget.session.kind == SessionKind.control,
      ),
    );
    Navigator.of(context).maybePop();
  }

  // Input: u32 big-endian length + JSON per message (docs/protocol.md §4.8).

  void _send(List<Map<String, Object>> messages) {
    final out = BytesBuilder(copy: false);
    for (final m in messages) {
      final body = utf8.encode(jsonEncode(m));
      out
        ..add((ByteData(4)..setUint32(0, body.length)).buffer.asUint8List())
        ..add(body);
    }
    LinksyPlatform.displayInput(_id, out.takeBytes());
  }

  Map<String, Object> _pointer(Offset at, Size size) => {
    'type': 'pointer',
    'x': (at.dx / size.width).clamp(0.0, 1.0),
    'y': (at.dy / size.height).clamp(0.0, 1.0),
  };

  Map<String, Object> _button(bool pressed) => {
    'type': 'button',
    'button': 'left',
    'pressed': pressed,
  };

  Offset _centroid() =>
      _pointers.values.reduce((a, b) => a + b) / _pointers.length.toDouble();

  void _down(PointerDownEvent e, Size size) {
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length == 1) {
      _pressed = true;
      _send([_pointer(e.localPosition, size), _button(true)]);
    } else {
      // A second finger turns the touch into scrolling.
      if (_pressed) {
        _pressed = false;
        _send([_button(false)]);
      }
      _scrollFrom = _centroid();
    }
  }

  void _move(PointerMoveEvent e, Size size) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length == 1 && _pressed) {
      _send([_pointer(e.localPosition, size)]);
    } else if (_pointers.length >= 2 && _scrollFrom != null) {
      final now = _centroid();
      final delta = now - _scrollFrom!;
      _scrollFrom = now;
      // The content follows the fingers, unless turned the other way
      // (Settings, as on the touchpad).
      final sign = LinksyScope.read(context).scrollReversed ? 1 : -1;
      _send([
        {
          'type': 'scroll',
          'dx': sign * delta.dx,
          'dy': sign * delta.dy,
          'discrete': false,
        },
      ]);
    }
  }

  void _up(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.isEmpty) {
      if (_pressed) _send([_button(false)]);
      _pressed = false;
      _scrollFrom = null;
    } else if (_pointers.length >= 2) {
      _scrollFrom = _centroid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final texture = _texture;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_closing) {
          _closing = true;
          LinksyScope.read(context).stopDisplay(_id);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _aspect,
                child: texture == null
                    ? const SizedBox.shrink()
                    : LayoutBuilder(
                        builder: (context, box) {
                          final size = box.biggest;
                          if (!_input) return Texture(textureId: texture);
                          return Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: (e) => _down(e, size),
                            onPointerMove: (e) => _move(e, size),
                            onPointerUp: _up,
                            onPointerCancel: _up,
                            child: Texture(textureId: texture),
                          );
                        },
                      ),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hint ? 1 : 0,
                duration: motion(context, 250),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Sig.deep,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      switch (widget.session.kind) {
                        SessionKind.display => context.l10n.displaySecondHint(
                          widget.session.peer.name,
                        ),
                        SessionKind.control => context.l10n.displayControlHint(
                          widget.session.peer.name,
                        ),
                        _ => context.l10n.displayWatchHint(
                          widget.session.peer.name,
                        ),
                      },
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.session.kind != SessionKind.display)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _ChooseButton(label: _hint, onTap: _choose),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Choose Screen, in a corner: with its name at first, then just the icon,
/// so it covers as little of the computer's screen as it can.
class _ChooseButton extends StatelessWidget {
  const _ChooseButton({required this.label, required this.onTap});

  final bool label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = context.l10n.displayChooseScreen;
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: name,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Sig.deep.withValues(alpha: 0.8),
            shape: const StadiumBorder(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedSize(
              duration: motion(context, 220),
              curve: Curves.easeOutCubic,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Ph.monitor, color: Colors.white, size: 20),
                  if (label) ...[
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
