import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'deck_looks.dart';

/// What Fluoro, Crystal and Pads are made of: glowing tubes, a liquid crystal
/// over glass, rubber lit from behind. Their tiles, numbers, bars, covers and
/// dials; the other looks draw theirs in deck_art.dart.

/// How far and how strongly Crystal's segments fall on the glass behind.
const deckCast = Offset(2, 3);
Color deckCastOf(Color ink) => ink.withValues(alpha: ink.a * 0.17);

/// A tile's box: nothing but a line under it (tube), a drawn frame (glass),
/// a pad, or a well or plate in the panel (rubber).
class DeckBoxPainter extends CustomPainter {
  DeckBoxPainter({
    required this.look,
    required this.kind,
    required this.fill,
    required this.ink,
    required this.on,
    required this.down,
  });

  final DeckLook look;
  final String kind;
  final Color fill;
  final Color ink;
  final bool on;
  final bool down;

  /// Shows something rather than being pressed.
  bool get _shows =>
      const {'clock', 'music', 'volume', 'touchpad'}.contains(kind);

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    final round = RRect.fromRectAndRadius(box, Radius.circular(look.radius));
    switch (look.material) {
      case DeckMaterial.flat:
        break;
      case DeckMaterial.tube:
        if (down || on) {
          canvas.drawRRect(
            round,
            Paint()..color = ink.withValues(alpha: down ? 0.14 : 0.07),
          );
        }
        if (kind == 'touchpad') {
          canvas.drawRRect(
            round.deflate(1),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = look.ghost,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(4, size.height - 1.5, size.width - 8, 1.5),
            Paint()..color = on ? ink.withValues(alpha: 0.8) : look.ghost,
          );
        }
      case DeckMaterial.glass:
        if (kind == 'clock' || kind == 'music' || kind == 'volume') return;
        const line = 2.5;
        final frame = round.deflate(line / 2);
        final pen = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = line;
        canvas.drawRRect(
          frame.shift(deckCast),
          pen..color = deckCastOf(look.ink),
        );
        if (on || down) {
          canvas.drawRRect(
            frame,
            Paint()..color = on ? fill : look.ink.withValues(alpha: 0.12),
          );
        }
        canvas.drawRRect(frame, pen..color = look.ink);
      case DeckMaterial.rubber:
        if (_shows) {
          canvas.drawRRect(
            round.shift(const Offset(0, 1)),
            Paint()..color = const Color(0xFF34363B),
          );
          canvas.drawRRect(round, Paint()..color = const Color(0xFF08090A));
          canvas.save();
          canvas.clipRRect(round);
          canvas.drawRRect(
            round,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(Rect.fromLTWH(0, 0, size.width, 12)),
          );
          canvas.restore();
          return;
        }
        final plate = kind == 'stat';
        final lip = plate || down ? 1.5 : 4.0;
        canvas.drawRRect(
          round.shift(Offset(0, down ? 1 : 3)),
          Paint()
            ..color = Colors.black
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        if (on) {
          canvas.drawRRect(
            round,
            Paint()
              ..color = fill.withValues(alpha: 0.55)
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
          );
        }
        final face = plate ? const Color(0xFF202225) : fill;
        final shown = down ? Color.lerp(face, Colors.white, 0.12)! : face;
        canvas.drawRRect(round, Paint()..color = _dark(shown, 0.34));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height - lip),
            Radius.circular(look.radius),
          ),
          Paint()..color = _lit(shown),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 1, size.width, size.height - lip - 1),
            Radius.circular(look.radius),
          ),
          Paint()..color = shown,
        );
    }
  }

  static Color _dark(Color c, double by) => Color.lerp(c, Colors.black, by)!;
  static Color _lit(Color c) => Color.lerp(c, Colors.white, 0.18)!;

  @override
  bool shouldRepaint(DeckBoxPainter old) =>
      old.look != look ||
      old.kind != kind ||
      old.fill != fill ||
      old.ink != ink ||
      old.on != on ||
      old.down != down;
}

// Numbers in seven segments, 48 × 92 a digit.

Path _seg(List<double> p) {
  final path = Path()..moveTo(p[0], p[1]);
  for (var i = 2; i < p.length; i += 2) {
    path.lineTo(p[i], p[i + 1]);
  }
  return path..close();
}

final _segments = [
  _seg([6, 0, 42, 0, 33, 10, 15, 10]),
  _seg([45, 3, 45, 41, 40, 46, 34, 40, 34, 13]),
  _seg([45, 51, 45, 89, 34, 79, 34, 52, 40, 47]),
  _seg([6, 92, 15, 82, 33, 82, 42, 92]),
  _seg([3, 51, 8, 47, 14, 52, 14, 79, 3, 89]),
  _seg([3, 3, 14, 13, 14, 40, 8, 45, 3, 41]),
  _seg([10, 46, 16, 41, 32, 41, 38, 46, 32, 51, 16, 51]),
];

const _lit = {
  '0': 0x7e, '1': 0x30, '2': 0x6d, '3': 0x79, '4': 0x33, //
  '5': 0x5b, '6': 0x5f, '7': 0x70, '8': 0x7f, '9': 0x7b,
  '-': 0x01, '–': 0x01, ' ': 0x00,
};

double _advance(String c) => c == ':' || c == '.' ? 22 : 56;

/// Whether [s] can be written in segments.
bool hasSegments(String s) =>
    s.isNotEmpty &&
    s.characters.every((c) => _lit.containsKey(c) || c == ':' || c == '.');

/// [text] in seven segments, [height] high: the lit ones in [color], the
/// others just there, as on the real thing.
class SegmentText extends StatelessWidget {
  const SegmentText(
    this.text, {
    super.key,
    required this.height,
    required this.color,
    required this.look,
  });

  final String text;
  final double height;
  final Color color;
  final DeckLook look;

  @override
  Widget build(BuildContext context) {
    var wide = 0.0;
    for (final c in text.characters) {
      wide += _advance(c);
    }
    return CustomPaint(
      size: Size((wide - 8) * height / 92 + height * 0.06, height),
      painter: _SegmentPainter(text, color, look),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  _SegmentPainter(this.text, this.color, this.look);

  final String text;
  final Color color;
  final DeckLook look;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.height / 92;
    final lit = Path(), unlit = Path();
    var x = 0.0;
    for (final c in text.characters) {
      final at = Offset(x, 0);
      if (c == ':') {
        lit.addRect(Rect.fromLTWH(x + 2, 24, 11, 12));
        lit.addRect(Rect.fromLTWH(x + 2, 56, 11, 12));
      } else if (c == '.') {
        lit.addRect(Rect.fromLTWH(x + 2, 80, 11, 12));
      } else {
        final mask = _lit[c] ?? 0;
        for (var i = 0; i < 7; i++) {
          (mask & (64 >> i) != 0 ? lit : unlit).addPath(_segments[i], at);
        }
      }
      x += _advance(c);
    }
    canvas.save();
    canvas.scale(k);
    final tube = look.material == DeckMaterial.tube;
    if (tube) {
      canvas.translate(8, 0);
      canvas.skew(-0.09, 0);
    }
    canvas.drawPath(unlit, Paint()..color = look.ghost);
    if (tube) {
      canvas.drawPath(
        lit,
        Paint()
          ..color = color.withValues(alpha: color.a * 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 / k.clamp(0.1, 4)),
      );
    } else {
      canvas.save();
      canvas.translate(deckCast.dx / k, deckCast.dy / k);
      canvas.drawPath(lit, Paint()..color = deckCastOf(color));
      canvas.restore();
    }
    canvas.drawPath(lit, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.text != text || old.color != color || old.look != look;
}

/// A bar in one of these materials: slanted tube segments, crystal cells
/// (rising, when [thick]), or a groove with a fader in it.
void paintDeckBar(
  Canvas canvas,
  Size size,
  DeckLook look,
  double value, {
  required bool vertical,
  required bool thick,
}) {
  final w = size.width, h = size.height;
  final length = vertical ? h : w, across = vertical ? w : h;
  // Along the bar from its start, across it from its near side.
  Rect part(double at, double n, double side, double thickness) => vertical
      ? Rect.fromLTWH(side, h - at - n, thickness, n)
      : Rect.fromLTWH(at, h - side - thickness, n, thickness);
  switch (look.material) {
    case DeckMaterial.flat:
      break;
    case DeckMaterial.tube:
      final pitch = thick ? 10.0 : 7.0;
      final count = math.max(1, (length / pitch).floor());
      final step = length / count;
      final lean = vertical ? 0.0 : math.min(across * 0.16, step * 0.35);
      for (var i = 0; i < count; i++) {
        final on = i < (value * count).round();
        final r = part(i * step + 1, step - 2 - lean, 0, across);
        final path = Path()
          ..moveTo(r.left + lean, r.top)
          ..lineTo(r.right + lean, r.top)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.left, r.bottom)
          ..close();
        if (on) {
          canvas.drawPath(
            path,
            Paint()
              ..color = look.fill.withValues(alpha: 0.28)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4,
          );
        }
        canvas.drawPath(path, Paint()..color = on ? look.fill : look.ghost);
      }
    case DeckMaterial.glass:
      final pitch = thick ? 11.0 : 7.0;
      final count = math.max(1, (length / pitch).floor());
      final step = length / count;
      for (var i = 0; i < count; i++) {
        final on = i < (value * count).round();
        final tall = thick ? across * (0.25 + 0.75 * (i + 1) / count) : across;
        final r = part(i * step, step - 3, 0, tall);
        if (on) {
          canvas.drawRect(
            r.shift(deckCast),
            Paint()..color = deckCastOf(look.fill),
          );
        }
        canvas.drawRect(r, Paint()..color = on ? look.fill : look.ghost);
      }
    case DeckMaterial.rubber:
      final groove = math.min(5.0, across);
      final side = (across - groove) / 2;
      // The fader's cap: across the groove, never past its ends.
      final cap = math.min(26.0, length * 0.3);
      final at = thick ? (length - cap) * value : 0.0;
      final lit = thick ? at + cap / 2 : length * value;
      RRect round(Rect r) =>
          RRect.fromRectAndRadius(r, const Radius.circular(3));
      canvas.drawRRect(
        round(part(0, length, side, groove)),
        Paint()..color = look.track,
      );
      if (lit > 0) {
        final r = round(part(0, lit, side, groove));
        canvas.drawRRect(
          r,
          Paint()
            ..color = look.fill.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawRRect(r, Paint()..color = look.fill);
      }
      if (!thick) return;
      final body = RRect.fromRectAndRadius(
        part(at, cap, 0, across).deflate(1),
        const Radius.circular(7),
      );
      canvas.drawRRect(
        body.shift(const Offset(0, 4)),
        Paint()
          ..color = Colors.black
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
            end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
            colors: const [
              Color(0xFF2B2D31),
              Color(0xFF565A62),
              Color(0xFF2B2D31),
            ],
          ).createShader(body.outerRect),
      );
      final line = part(at + cap / 2 - 1, 2, across * 0.16, across * 0.68);
      canvas.drawRect(line, Paint()..color = Colors.white);
  }
}

/// A gauge as a dial: an arc of tube segments, or a knob in a ring of lights.
class DeckDialPainter extends CustomPainter {
  DeckDialPainter(this.look, this.value, this.hot);

  final DeckLook look;
  final double value;

  /// The last part of the arc, when it's near its end.
  final Color hot;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    Offset at(double degrees, double far) {
      final a = degrees * math.pi / 180;
      return c + Offset(math.cos(a), math.sin(a)) * far;
    }

    if (look.material == DeckMaterial.tube) {
      const count = 31;
      for (var i = 0; i < count; i++) {
        final on = i / (count - 1) <= value;
        final color = !on
            ? look.ghost
            : i > 24
            ? hot
            : look.fill;
        final a = -210 + i * 8.0;
        final from = at(a, r * 0.76), to = at(a, r * 0.98);
        if (on) {
          canvas.drawLine(
            from,
            to,
            Paint()
              ..strokeWidth = r * 0.14
              ..color = color.withValues(alpha: 0.2),
          );
        }
        canvas.drawLine(
          from,
          to,
          Paint()
            ..strokeWidth = r * 0.062
            ..color = color,
        );
      }
      return;
    }
    const count = 25;
    for (var i = 0; i < count; i++) {
      final on = i / (count - 1) <= value;
      final p = at(-225 + i * 11.25, r * 0.92);
      if (on) {
        canvas.drawCircle(
          p,
          r * 0.11,
          Paint()..color = look.fill.withValues(alpha: 0.28),
        );
      }
      canvas.drawCircle(
        p,
        r * 0.055,
        Paint()..color = on ? look.fill : const Color(0xFF3A3C41),
      );
    }
    final knob = r * 0.7;
    canvas.drawCircle(
      c + Offset(0, knob * 0.07),
      knob * 1.04,
      Paint()..color = const Color(0xFF0C0D0E),
    );
    canvas.drawCircle(c, knob, Paint()..color = const Color(0xFF36393F));
    canvas.drawCircle(
      c + Offset(0, knob * 0.02),
      knob * 0.9,
      Paint()..color = const Color(0xFF272A2E),
    );
    final turn = -225 + value * 270;
    canvas.drawLine(
      at(turn, knob * 0.66),
      at(turn, knob * 0.84),
      Paint()
        ..strokeWidth = math.max(2, knob * 0.08)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(DeckDialPainter old) =>
      old.look != look || old.value != value || old.hot != hot;
}

/// The cover in one of these materials: its picture in lit cells, or without
/// one a spectrum that moves while it [playing]s.
class MaterialCover extends StatefulWidget {
  const MaterialCover({
    super.key,
    required this.look,
    required this.size,
    required this.playing,
    this.pixels,
    required this.n,
  });

  final DeckLook look;
  final double size;
  final bool playing;

  /// The picture, [n] × [n].
  final List<Color>? pixels;
  final int n;

  /// How many cells across a cover this size.
  static int cells(DeckLook look, double size) =>
      look.material == DeckMaterial.rubber
      ? 8
      : math.max(6, (size / 7).floor());

  @override
  State<MaterialCover> createState() => _MaterialCoverState();
}

class _MaterialCoverState extends State<MaterialCover> {
  Timer? _tick;
  int _t = 0;

  void _run() {
    final moves =
        widget.playing &&
        widget.pixels == null &&
        !MediaQuery.disableAnimationsOf(context);
    if (moves) {
      _tick ??= Timer.periodic(
        const Duration(milliseconds: 170),
        (_) => setState(() => _t++),
      );
    } else {
      _tick?.cancel();
      _tick = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _run();
  }

  @override
  void didUpdateWidget(MaterialCover old) {
    super.didUpdateWidget(old);
    _run();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(widget.size),
      painter: _MaterialCoverPainter(
        widget.look,
        widget.pixels,
        widget.n,
        _t,
        widget.playing,
      ),
    ),
  );
}

class _MaterialCoverPainter extends CustomPainter {
  _MaterialCoverPainter(this.look, this.pixels, this.n, this.t, this.playing);

  final DeckLook look;
  final List<Color>? pixels;
  final int n;
  final int t;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final step = size.shortestSide / n;
    final rubber = look.material == DeckMaterial.rubber;
    final glass = look.material == DeckMaterial.glass;
    final gap = rubber ? 3.0 : 2.0;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final cell = Rect.fromLTWH(
          x * step,
          y * step + (rubber || glass ? 0 : step * 0.2),
          step - gap,
          rubber || glass ? step - gap : step * 0.55,
        );
        final px = pixels;
        Color color;
        bool on;
        if (px != null) {
          final c = px[y * n + x];
          final light = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
          on = rubber || (glass ? light < 0.75 : light > 0.12);
          color = rubber
              ? c
              : glass
              // Dark where the picture is, in the crystal's few shades.
              ? look.fill.withValues(alpha: ((1 - light) * 4).ceil() / 4)
              : look.fill.withValues(alpha: 0.25 + 0.75 * light);
        } else {
          final wave =
              (math.sin(x * 1.1 * 8 / n + t * 0.33) *
                      math.cos(x * 0.4 * 8 / n - t * 0.12))
                  .abs();
          final high = playing ? 1 + (wave * (n - 1.2)).floor() : 1 + x % 2;
          final up = n - 1 - y;
          on = up < high;
          color = rubber
              ? [
                  look.fill,
                  const Color(0xFFFFD23F),
                  const Color(0xFFF4F1EA),
                  const Color(0xFF4CC3FF),
                ][(up * 4 ~/ n).clamp(0, 3)]
              : !glass && up > n * 0.75
              ? look.on
              : look.fill;
        }
        if (!on) color = rubber ? const Color(0xFF1C1D20) : look.ghost;
        if (on && glass) {
          canvas.drawRect(
            cell.shift(deckCast * 0.6),
            Paint()..color = deckCastOf(color),
          );
        }
        if (rubber) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(cell, Radius.circular(step * 0.14)),
            Paint()..color = color,
          );
        } else {
          canvas.drawRect(cell, Paint()..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_MaterialCoverPainter old) =>
      old.look != look ||
      old.pixels != pixels ||
      old.n != n ||
      old.t != t ||
      old.playing != playing;
}
