import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'deck_looks.dart';

/// What the deck's tiles draw themselves, in each look, as the computer's
/// editor does (the desktop's deck/art.rs): icons as lines, dots, pixels or
/// glowing lines; text in 5×7 glyphs of dots or squares; bars; the music's
/// cover.

/// The editor's icons, as SVG paths in a 24-unit box.
const _icons = {
  'music': 'M9 18V5l11-2v13M9 18a3 3 0 1 1-6 0a3 3 0 0 1 6 0zM20 16a3 3 0 1 1-6 0a3 3 0 0 1 6 0z',
  'play': 'M8 5l11 7-11 7z',
  'pause': 'M7 5v14M17 5v14',
  'next': 'M6 6l9 6-9 6zM18 6v12',
  'prev': 'M18 6l-9 6 9 6zM6 6v12',
  'rewind': 'M11 6l-8 6 8 6zM21 6l-8 6 8 6z',
  'forward': 'M13 6l8 6-8 6zM3 6l8 6-8 6z',
  'keys': 'M3 7h18v10H3zM6.5 10.5h1M10 10.5h1M13.5 10.5h1M17 10.5h1M7.5 14h9',
  'type': 'M5 6h14M12 6v13M9 19h6',
  'link': 'M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1',
  'clipboard': 'M9 3h6v3H9zM7 4.5H5V21h14V4.5h-2M8 11h8M8 15h5',
  'bell': 'M6 16v-5a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0',
  'find': 'M10 3a7 7 0 1 0 0 14a7 7 0 1 0 0-14zM15 15l6 6',
  'click': 'M6 3l12 7-5.5 1.5L10 17zM13 13l5 5',
  'left': 'M19 12H5M11 6l-6 6 6 6',
  'right': 'M5 12h14M13 6l6 6-6 6',
  'up': 'M12 19V5M6 11l6-6 6 6',
  'down': 'M12 5v14M6 13l6 6 6-6',
  'touch': 'M8 3h8a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3zM12 3v6',
  'volume':
      'M4 9h4l5-4v14l-5-4H4zM16.5 8.5a5 5 0 0 1 0 7M19 6a8.5 8.5 0 0 1 0 12',
  'mute': 'M4 9h4l5-4v14l-5-4H4zM17 9l4 6M21 9l-4 6',
  'mic': 'M12 3a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V6a3 3 0 0 0-3-3zM5 11a7 7 0 0 0 14 0M12 18v3',
  'output': 'M3 9h3l4-4v14l-4-4H3zM14 12h7M18 9l3 3-3 3',
  'clock': 'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM12 7v5l3 2',
  'lock': 'M6 11h12v9H6zM8 11V8a4 4 0 0 1 8 0v3',
  'restart': 'M20 12a8 8 0 1 1-2.3-5.7M20 4v5h-5',
  'power': 'M12 3v8M6.4 6.4a8 8 0 1 0 11.2 0',
  'moon': 'M20 14A8 8 0 1 1 10 4a6 6 0 0 0 10 10z',
  'wifi': 'M2.5 9a14 14 0 0 1 19 0M5.5 12.5a9.5 9.5 0 0 1 13 0M8.5 16a5 5 0 0 1 7 0M12 19.5v.5',
  'bluetooth': 'M7 7l10 10-5 4V3l5 4L7 17',
  'airplane': 'M12 3c-.8 0-1.3.8-1.3 1.8V9.5L3 14v2.5l7.7-2.4v4.4L8.5 20v1.5l3.5-1 3.5 1V20l-2.2-1.5v-4.4l7.7 2.4V14l-7.7-4.5V4.8C13.3 3.8 12.8 3 12 3z',
  'leaf': 'M5 19C4 11 9 4 20 4c0 11-6 16-15 15zM5 19l8-8',
  'balanced': 'M12 4v16M8 20h8M4 8h16M4 8l-2.5 6h5zM20 8l-2.5 6h5z',
  'gauge': 'M4 18a8 8 0 1 1 16 0M12 18l4-6M12 8v1M7 11l.7.7M17 11l-.7.7',
  'auto': 'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM8.5 16l3.5-9 3.5 9M9.7 13h4.6',
  'terminal': 'M4 5h16v14H4zM7 9l3 3-3 3M12 15h5',
  'star': 'M12 3l2.7 5.8 6.3.8-4.6 4.4 1.2 6.3L12 17.2 6.4 20.3l1.2-6.3L3 9.6l6.3-.8z',
  'sun': 'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8zM12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M5 5l1.8 1.8M17.2 17.2L19 19M5 19l1.8-1.8M17.2 6.8L19 5',
  'house': 'M4 11l8-7 8 7M6 10v10h12V10M10 20v-6h4v6',
  'lightning': 'M13 3L5 14h6l-1 7 8-11h-6z',
  'code': 'M8 7l-5 5 5 5M16 7l5 5-5 5M14 5l-4 14',
  'rocket': 'M12 3c4 3 5 7 4 12H8C7 10 8 6 12 3zM8 13l-3 4h3M16 13l3 4h-3M10 18l2 3 2-3M12 8v.5',
  'game': 'M7 8h10a5 5 0 0 1 5 5v2a3 3 0 0 1-5.5 1.7L15 15H9l-1.5 1.7A3 3 0 0 1 2 15v-2a5 5 0 0 1 5-5zM7 10.5v3M5.5 12h3M16 11v.5M18 13v.5',
  'camera': 'M4 7h3.5L9 5h6l1.5 2H20v12H4zM12 9.5a3.5 3.5 0 1 0 0 7a3.5 3.5 0 1 0 0-7z',
  'heart': 'M12 20C6 16 3 13 3 9a4.5 4.5 0 0 1 9-1.5A4.5 4.5 0 0 1 21 9c0 4-3 7-9 11z',
  'coffee': 'M5 9h11v6a4 4 0 0 1-4 4H9a4 4 0 0 1-4-4zM16 10h2a2.5 2.5 0 0 1 0 5h-2M8 3v3M12 3v3',
  'monitor': 'M3 5h18v11H3zM12 16v4M8 20h8',
  'broadcast': 'M12 10.5a1.5 1.5 0 1 0 0 3a1.5 1.5 0 1 0 0-3zM8 8a5.5 5.5 0 0 0 0 8M16 8a5.5 5.5 0 0 1 0 8M5 5a10 10 0 0 0 0 14M19 5a10 10 0 0 1 0 14',
  'flag': 'M6 21V4M6 4h12l-2.5 4L18 12H6',
  'folder': 'M3 6h6l2 2.5h10V19H3z',
  'globe': 'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM3 12h18M12 3c-5 5-5 13 0 18M12 3c5 5 5 13 0 18',
  'cloud': 'M7 18a4 4 0 0 1-.5-8A6 6 0 0 1 18 9.5a4.3 4.3 0 0 1 0 8.5z',
  'timer': 'M12 6a7.5 7.5 0 1 0 0 15a7.5 7.5 0 1 0 0-15zM12 13.5l3-3M10 3h4',
  'chip': 'M7 7h10v10H7zM10 7V3.5M14 7V3.5M10 20.5V17M14 20.5V17M7 10H3.5M7 14H3.5M20.5 10H17M20.5 14H17',
  'memory': 'M3 8h18v8H3zM7 8v4M11 8v4M15 8v4M6 16v3M10 16v3M14 16v3M18 16v3',
  'disk': 'M4 5h16v14H4zM4 14h16M16.5 16.5v.5',
  'battery': 'M3 8h16v8H3zM21.5 11v2M6 10.5v3M9.5 10.5v3',
  'heat': 'M10 14V5a2 2 0 0 1 4 0v9a4 4 0 1 1-4 0zM12 9v7',
  'app': 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z',
};

/// The icon the computer names for a command (§4.26), as this phone calls
/// it; null for one it doesn't have.
String? deckCommandIcon(String? name) {
  final own = switch (name) {
    null => null,
    'play_pause' => 'play',
    'previous' => 'prev',
    'speaker' => 'volume',
    'speaker_off' => 'mute',
    'microphone' || 'microphone_off' => 'mic',
    _ => name,
  };
  return _icons.containsKey(own) ? own : null;
}

/// A gauge's icon.
String deckMetricIcon(String? metric) => switch (metric) {
  'cpu' => 'chip',
  'ram' || 'swap' => 'memory',
  'disk' => 'disk',
  'battery' => 'battery',
  'temp' => 'heat',
  'net_down' => 'down',
  'net_up' => 'up',
  'uptime' => 'timer',
  _ => 'gauge',
};

/// A deck action's icon (the desktop's `icon_for`).
String deckIconName(String? action, {bool playing = false}) => switch (action) {
  null => 'app',
  'media.play_pause' => playing ? 'pause' : 'play',
  'media.next' => 'next',
  'media.previous' => 'prev',
  'sound.volume' => 'volume',
  'sound.mute' => 'mute',
  'sound.mic_mute' => 'mic',
  'sound.output' => 'output',
  'system.lock' => 'lock',
  'system.restart' => 'restart',
  'system.shutdown' => 'power',
  'system.dnd' => 'moon',
  'network.wifi' => 'wifi',
  'network.bluetooth' => 'bluetooth',
  'network.airplane' => 'airplane',
  'power.saver' => 'leaf',
  'power.balanced' => 'balanced',
  'power.performance' => 'gauge',
  'power.auto' => 'auto',
  _ when action.startsWith('command.') => 'terminal',
  _ => 'app',
};

final _paths = <String, Path>{};

Path _path(String name) =>
    _paths[name] ??= _parse(_icons[name] ?? _icons['app']!);

/// The SVG path commands the icons use (M L H V C A Z, either case).
Path _parse(String d) {
  final path = Path();
  final tokens = RegExp(r'[MmLlHhVvCcAaZz]|-?(?:\d+\.?\d*|\.\d+)')
      .allMatches(d)
      .map((m) => m[0]!)
      .toList();
  var i = 0;
  var cmd = 'M';
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  double n() => double.parse(tokens[i++]);
  bool number() => i < tokens.length && !RegExp('[A-Za-z]').hasMatch(tokens[i]);
  while (i < tokens.length) {
    if (!number()) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    final dx = rel ? x : 0.0, dy = rel ? y : 0.0;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = dx + n();
        y = dy + n();
        path.moveTo(x, y);
        (sx, sy) = (x, y);
        // More pairs after a move are lines.
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = dx + n();
        y = dy + n();
        path.lineTo(x, y);
      case 'H':
        x = dx + n();
        path.lineTo(x, y);
      case 'V':
        y = dy + n();
        path.lineTo(x, y);
      case 'C':
        final x1 = dx + n(), y1 = dy + n(), x2 = dx + n(), y2 = dy + n();
        x = dx + n();
        y = dy + n();
        path.cubicTo(x1, y1, x2, y2, x, y);
      case 'A':
        final rx = n(), ry = n(), rotation = n(), large = n(), sweep = n();
        x = dx + n();
        y = dy + n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: large != 0,
          clockwise: sweep != 0,
        );
      case 'Z':
        path.close();
        (x, y) = (sx, sy);
      default:
        return path;
    }
  }
  return path;
}

final _masks = <String, List<bool>>{};

/// The icon on a 12-pixel grid, each pixel on or off: on where the 2.6-unit
/// line covers more than a little of it.
List<bool> _pixelMask(String name) => _masks[name] ??= () {
  final mask = List.filled(144, false);
  for (final metric in _path(name).computeMetrics()) {
    for (var d = 0.0; d <= metric.length; d += 0.1) {
      final p = metric.getTangentForOffset(d)!.position;
      final cx = (p.dx / 2).floor(), cy = (p.dy / 2).floor();
      for (var y = cy - 1; y <= cy + 1; y++) {
        for (var x = cx - 1; x <= cx + 1; x++) {
          if (x < 0 || y < 0 || x > 11 || y > 11) continue;
          final ox = x * 2 + 1 - p.dx, oy = y * 2 + 1 - p.dy;
          if (ox * ox + oy * oy <= 1.45 * 1.45) mask[y * 12 + x] = true;
        }
      }
    }
  }
  return mask;
}();

/// An icon [size] square in [color], as [stroke] draws it.
class DeckIcon extends StatelessWidget {
  const DeckIcon(
    this.name, {
    super.key,
    required this.size,
    required this.color,
    required this.stroke,
  });

  final String name;
  final double size;
  final Color color;
  final DeckStroke stroke;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _IconPainter(name, color, stroke),
  );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.name, this.color, this.stroke);

  final String name;
  final Color color;
  final DeckStroke stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (stroke == DeckStroke.pixel) {
      final px = (s / 12).floorToDouble().clamp(1.0, 100.0);
      final o = ((size.width - 12 * px) / 2).roundToDouble();
      final top = ((size.height - 12 * px) / 2).roundToDouble();
      final paint = Paint()
        ..color = color
        ..isAntiAlias = false;
      final mask = _pixelMask(name);
      for (var i = 0; i < 144; i++) {
        if (!mask[i]) continue;
        canvas.drawRect(
          Rect.fromLTWH(o + (i % 12) * px, top + (i ~/ 12) * px, px, px),
          paint,
        );
      }
      return;
    }
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s / 24);
    final path = _path(name);
    if (stroke == DeckStroke.dotted) {
      // Dots of 2.3 every 2.7 along the line.
      final dot = Paint()..color = color;
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d <= metric.length + 0.01; d += 2.7) {
          final at = metric.getTangentForOffset(math.min(d, metric.length));
          if (at != null) canvas.drawCircle(at.position, 1.15, dot);
        }
      }
    } else {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (stroke == DeckStroke.glow) {
        // Phosphor: a soft glow under the line.
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color.withValues(alpha: color.a * 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        );
      }
      canvas.drawPath(path, line..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.name != name || old.color != color || old.stroke != stroke;
}

// The 5×7 glyphs Dot Matrix and Pixel write with.

/// A character's 5×7 glyph, a row of five bits a line, the left one
/// highest.
const _glyphs = <String, List<int>>{
  '0': [0x0e, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0e],
  '1': [0x04, 0x0c, 0x04, 0x04, 0x04, 0x04, 0x0e],
  '2': [0x0e, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1f],
  '3': [0x1f, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0e],
  '4': [0x02, 0x06, 0x0a, 0x12, 0x1f, 0x02, 0x02],
  '5': [0x1f, 0x10, 0x1e, 0x01, 0x01, 0x11, 0x0e],
  '6': [0x06, 0x08, 0x10, 0x1e, 0x11, 0x11, 0x0e],
  '7': [0x1f, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
  '8': [0x0e, 0x11, 0x11, 0x0e, 0x11, 0x11, 0x0e],
  '9': [0x0e, 0x11, 0x11, 0x0f, 0x01, 0x02, 0x0c],
  'A': [0x0e, 0x11, 0x11, 0x11, 0x1f, 0x11, 0x11],
  'B': [0x1e, 0x11, 0x11, 0x1e, 0x11, 0x11, 0x1e],
  'C': [0x0e, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0e],
  'D': [0x1c, 0x12, 0x11, 0x11, 0x11, 0x12, 0x1c],
  'E': [0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x1f],
  'F': [0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x10],
  'G': [0x0e, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0f],
  'H': [0x11, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11],
  'I': [0x0e, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0e],
  'J': [0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0c],
  'K': [0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
  'L': [0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1f],
  'M': [0x11, 0x1b, 0x15, 0x15, 0x11, 0x11, 0x11],
  'N': [0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11],
  'O': [0x0e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e],
  'P': [0x1e, 0x11, 0x11, 0x1e, 0x10, 0x10, 0x10],
  'Q': [0x0e, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0d],
  'R': [0x1e, 0x11, 0x11, 0x1e, 0x14, 0x12, 0x11],
  'S': [0x0f, 0x10, 0x10, 0x0e, 0x01, 0x01, 0x1e],
  'T': [0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
  'U': [0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e],
  'V': [0x11, 0x11, 0x11, 0x11, 0x11, 0x0a, 0x04],
  'W': [0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0a],
  'X': [0x11, 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x11],
  'Y': [0x11, 0x11, 0x11, 0x0a, 0x04, 0x04, 0x04],
  'Z': [0x1f, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1f],
  ' ': [0, 0, 0, 0, 0, 0, 0],
  ':': [0x00, 0x0c, 0x0c, 0x00, 0x0c, 0x0c, 0x00],
  '.': [0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c],
  ',': [0x00, 0x00, 0x00, 0x00, 0x0c, 0x04, 0x08],
  '-': [0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00],
  '+': [0x00, 0x04, 0x04, 0x1f, 0x04, 0x04, 0x00],
  '%': [0x18, 0x19, 0x02, 0x04, 0x08, 0x13, 0x03],
  '/': [0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x00],
  '>': [0x08, 0x04, 0x02, 0x01, 0x02, 0x04, 0x08],
  '<': [0x02, 0x04, 0x08, 0x10, 0x08, 0x04, 0x02],
  '!': [0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04],
  '?': [0x0e, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04],
  "'": [0x0c, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00],
  '&': [0x0c, 0x12, 0x14, 0x08, 0x15, 0x12, 0x0d],
  '(': [0x02, 0x04, 0x08, 0x08, 0x08, 0x04, 0x02],
  ')': [0x08, 0x04, 0x02, 0x02, 0x02, 0x04, 0x08],
  '#': [0x0a, 0x0a, 0x1f, 0x0a, 0x1f, 0x0a, 0x0a],
  '=': [0x00, 0x00, 0x1f, 0x00, 0x1f, 0x00, 0x00],
  '*': [0x00, 0x04, 0x15, 0x0e, 0x15, 0x04, 0x00],
  '_': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f],
  '·': [0x00, 0x00, 0x00, 0x0c, 0x0c, 0x00, 0x00],
};

/// [c] as the glyphs have it: upper case, without its accent.
String _fold(String c) {
  final u = c.toUpperCase();
  const accents = {
    'ÀÁÂÃÄÅ': 'A',
    'Ç': 'C',
    'ÈÉÊË': 'E',
    'ÌÍÎÏ': 'I',
    'Ñ': 'N',
    'ÒÓÔÕÖØ': 'O',
    'ÙÚÛÜ': 'U',
    'ÝŸ': 'Y',
    '×': 'X',
    '…': '.',
    '–—': '-',
    '’‘': "'",
  };
  for (final MapEntry(:key, :value) in accents.entries) {
    if (key.contains(u)) return value;
  }
  return u;
}

List<int>? _glyph(String c) => _glyphs[_fold(c)];

/// Whether every character of [s] has a glyph; text that doesn't is written
/// in the look's font instead.
bool hasGlyphs(String s) => s.characters.every((c) => _glyph(c) != null);

/// [text] in lines of at most [perLine] glyphs, broken at spaces, at most
/// [lines] of them; what's cut ends in a full stop.
List<String> _wrap(String text, int perLine, int lines) {
  perLine = math.max(1, perLine);
  final out = <String>[];
  var line = '';
  for (var word in text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty)) {
    if (word.characters.length > perLine) {
      word = '${word.characters.take(perLine - 1)}.';
    }
    final len = line.characters.length;
    if (len > 0 && len + 1 + word.characters.length > perLine) {
      out.add(line);
      line = '';
    }
    line = line.isEmpty ? word : '$line $word';
  }
  if (line.isNotEmpty) out.add(line);
  if (out.length > lines) {
    out.length = math.max(1, lines);
    var last = out.last.characters.take(perLine - 1).toString().trimRight();
    last = '$last.';
    out[out.length - 1] = last;
  }
  return out;
}

/// The lines of [s] at the biggest of [pitches] that leaves nothing out,
/// else cut at the last.
(List<String>, double) fitGlyphs(
  String s,
  double width,
  int lines,
  List<double> pitches,
) {
  int per(double p) => math.max(1, ((width + p) / (6 * p)).floor());
  final whole = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');
  for (final p in pitches) {
    final wrapped = _wrap(s, per(p), 1 << 20);
    if (wrapped.length <= lines && wrapped.join(' ') == whole) {
      return (wrapped, p);
    }
  }
  final p = pitches.isEmpty ? 1.0 : pitches.last;
  return (_wrap(s, per(p), lines), p);
}

/// Lines of glyphs, [pitch] a dot: round dots, or [square] ones.
class GlyphText extends StatelessWidget {
  const GlyphText({
    super.key,
    required this.lines,
    required this.pitch,
    required this.color,
    required this.square,
    this.width,
  });

  final List<String> lines;
  final double pitch;
  final Color color;
  final bool square;

  /// Cut at this width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final most = lines.fold(0, (n, l) => math.max(n, l.characters.length));
    var w = math.max(0, most * 6 - 1) * pitch;
    if (width != null) w = math.min(w, width!);
    final h = math.max(0, lines.length * 9 - 2) * pitch;
    return Semantics(
      label: lines.join(' '),
      child: CustomPaint(
        size: Size(w, h),
        painter: _GlyphPainter(lines, pitch, color, square),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.lines, this.pitch, this.color, this.square);

  final List<String> lines;
  final double pitch;
  final Color color;
  final bool square;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = !square;
    for (var row = 0; row < lines.length; row++) {
      final y0 = row * 9 * pitch;
      var i = 0;
      for (final c in lines[row].characters) {
        final x0 = i++ * 6 * pitch;
        if (x0 + 5 * pitch > size.width + 0.5) break;
        final bits = _glyph(c);
        if (bits == null) continue;
        for (var y = 0; y < 7; y++) {
          for (var x = 0; x < 5; x++) {
            if (bits[y] & (0x10 >> x) == 0) continue;
            final px = x0 + x * pitch, py = y0 + y * pitch;
            if (square) {
              canvas.drawRect(Rect.fromLTWH(px, py, pitch, pitch), paint);
            } else {
              canvas.drawCircle(
                Offset(px + pitch / 2, py + pitch / 2),
                pitch * 0.42,
                paint,
              );
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.pitch != pitch ||
      old.color != color ||
      old.square != square ||
      old.lines.join('\n') != lines.join('\n');
}

/// A bar [value] full, from the left or up from the bottom; [thick] is the
/// volume's.
class DeckBar extends StatelessWidget {
  const DeckBar({
    super.key,
    required this.value,
    required this.look,
    this.vertical = false,
    this.thick = false,
  });

  final double value;
  final DeckLook look;
  final bool vertical;
  final bool thick;

  /// How thick it is across, in this look.
  double get across => switch ((thick, look.bars)) {
    (true, DeckBars.blocks) => 22,
    (true, _) => 26,
    (false, DeckBars.blocks) => 8,
    (false, DeckBars.dots) => 6,
    _ => 4,
  };

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: vertical
        ? Size(across, double.infinity)
        : Size(double.infinity, across),
    painter: _BarPainter(value.clamp(0, 1), look, vertical, thick),
  );
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.value, this.look, this.vertical, this.thick);

  final double value;
  final DeckLook look;
  final bool vertical;
  final bool thick;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final whole = Offset.zero & size;
    final full = vertical
        ? Rect.fromLTWH(0, h * (1 - value), w, h * value)
        : Rect.fromLTWH(0, 0, w * value, h);
    switch (look.bars) {
      case DeckBars.dots:
        final pitch = thick ? 6.0 : 5.0;
        final cols = math.max(1, (w / pitch).floor());
        final rows = thick || vertical ? math.max(1, (h / pitch).floor()) : 1;
        final ox = (w - cols * pitch) / 2, oy = (h - rows * pitch) / 2;
        final lit = Paint()..color = look.fill;
        final unlit = Paint()
          ..color = look.fill.withValues(alpha: thick ? 0.18 : 0.22);
        for (var y = 0; y < rows; y++) {
          for (var x = 0; x < cols; x++) {
            final at = Offset(ox + (x + 0.5) * pitch, oy + (y + 0.5) * pitch);
            final on = vertical
                ? rows - y <= value * rows + 0.01
                : x < value * cols - 0.01;
            canvas.drawCircle(
              at,
              on ? (thick ? 1.5 : 1.3) : (thick ? 1.4 : 1.2),
              on ? lit : unlit,
            );
          }
        }
      case DeckBars.blocks:
        canvas.drawRect(whole, Paint()..color = look.track);
        final fill = Paint()
          ..color = thick ? (look.thickFill ?? look.fill) : look.fill
          ..isAntiAlias = false;
        final on = thick ? 6.0 : 5.0;
        final inner = full.deflate(2);
        if (inner.width <= 0 || inner.height <= 0) return;
        final length = vertical ? inner.height : inner.width;
        for (var at = 0.0; at < length; at += on + 2) {
          final n = math.min(on, length - at);
          canvas.drawRect(
            vertical
                ? Rect.fromLTWH(
                    inner.left,
                    inner.bottom - at - n,
                    inner.width,
                    n,
                  )
                : Rect.fromLTWH(inner.left + at, inner.top, n, inner.height),
            fill,
          );
        }
      case DeckBars.flat:
        final r = thick ? look.thickRadius : look.barRadius;
        final shape = RRect.fromRectAndRadius(
          whole,
          Radius.circular(math.min(r, math.min(w, h) / 2)),
        );
        canvas.save();
        canvas.clipRRect(shape);
        canvas.drawRect(whole, Paint()..color = look.track);
        canvas.drawRect(full, Paint()..color = look.fill);
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value ||
      old.look != look ||
      old.vertical != vertical ||
      old.thick != thick;
}

// The music's cover.

/// A small copy of a cover, [n] × [n] colours, for the looks that draw it
/// in dots or pixels.
final _small = <(int, int), Future<List<Color>?>>{};

Future<List<Color>?> _shrink(Uint8List bytes, int n) =>
    _small[(Object.hashAll(bytes), n)] ??= () async {
      try {
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: n,
          targetHeight: n,
        );
        final image = (await codec.getNextFrame()).image;
        final data = await image.toByteData();
        image.dispose();
        if (data == null) return null;
        return [
          for (var i = 0; i < n * n; i++)
            Color.fromARGB(
              255,
              data.getUint8(i * 4),
              data.getUint8(i * 4 + 1),
              data.getUint8(i * 4 + 2),
            ),
        ];
      } on Object {
        return null;
      }
    }();

/// The cover of what plays, [size] square, drawn in the look; without one,
/// the look's own picture.
class DeckCover extends StatelessWidget {
  const DeckCover({
    super.key,
    required this.look,
    required this.size,
    this.art,
    this.real = false,
  });

  final DeckLook look;
  final double size;
  final Uint8List? art;

  /// The picture as it is, whatever the theme does to covers.
  final bool real;

  @override
  Widget build(BuildContext context) {
    final art = this.art;
    final square = Size.square(size);
    final themed = !(real && art != null);
    if (themed &&
        (look.cover == DeckCovers.dots || look.cover == DeckCovers.pixel)) {
      final n = look.cover == DeckCovers.pixel ? 12 : (size / 6).floor();
      if (art == null) {
        return CustomPaint(size: square, painter: _CoverPainter(look, null, n));
      }
      return FutureBuilder(
        future: _shrink(art, n),
        builder: (context, snap) => CustomPaint(
          size: square,
          painter: _CoverPainter(look, snap.data, n),
        ),
      );
    }
    final radius = BorderRadius.circular(look.coverRadius);
    if (art == null) {
      return CustomPaint(size: square, painter: _CoverPainter(look, null, 0));
    }
    final Widget image = Image.memory(
      art,
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      errorBuilder: (_, _, _) =>
          CustomPaint(size: square, painter: _CoverPainter(look, null, 0)),
    );
    return ClipRRect(
      borderRadius: radius,
      child: switch (look.cover) {
        DeckCovers.grey => ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grey),
          child: image,
        ),
        DeckCovers.green => ColorFiltered(
          colorFilter: const ColorFilter.matrix(_greenTint),
          child: image,
        ),
        _ => image,
      },
    );
  }
}

/// Grey with more contrast, as on paper.
const _grey = <double>[
  0.42, 0.82, 0.16, 0, -76, //
  0.42, 0.82, 0.16, 0, -76,
  0.42, 0.82, 0.16, 0, -76,
  0, 0, 0, 1, 0,
];

/// Green phosphor.
const _greenTint = <double>[
  0.05, 0.1, 0.02, 0, 0, //
  0.3, 0.6, 0.12, 0, 10,
  0.1, 0.2, 0.04, 0, 0,
  0, 0, 0, 1, 0,
];

class _CoverPainter extends CustomPainter {
  _CoverPainter(this.look, this.pixels, this.n);

  final DeckLook look;

  /// The cover, [n] × [n]; none: the look's own picture.
  final List<Color>? pixels;
  final int n;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    switch (look.cover) {
      case DeckCovers.pixel:
        final own = pixels == null;
        final side = own ? 10 : n;
        final colors = own
            ? _pixelArt()
            : [for (final c in pixels!) _nearest(c)];
        final step = (s / side).floorToDouble().clamp(1.0, 100.0);
        // Whole pixels, centred.
        final o = ((s - side * step) / 2).floorToDouble();
        final paint = Paint()..isAntiAlias = false;
        for (var i = 0; i < colors.length; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              o + (i % side) * step,
              o + (i ~/ side) * step,
              step,
              step,
            ),
            paint..color = colors[i],
          );
        }
      case DeckCovers.dots:
        // A disc of lit dots that fades from its upper left; a cover's own
        // dots as bright as it is.
        const pitch = 6.0;
        final count = (s / pitch).floor();
        final center = s * 0.38;
        final reach = math.sqrt(2 * math.pow(s - center, 2));
        final dot = Paint();
        for (var y = 0; y < count; y++) {
          for (var x = 0; x < count; x++) {
            final at = Offset((x + 0.5) * pitch, (y + 0.5) * pitch);
            double alpha;
            final px = pixels;
            if (px != null && n > 0) {
              final c = px[math.min(y, n - 1) * n + math.min(x, n - 1)];
              alpha = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
            } else {
              final d = (at - Offset(center, center)).distance / reach;
              alpha = ((0.72 - d) / (0.72 - 0.25)).clamp(0, 1);
            }
            if (alpha > 0.04) {
              canvas.drawCircle(
                at,
                1.4,
                dot..color = look.fill.withValues(alpha: alpha),
              );
            }
          }
        }
      case DeckCovers.colour || DeckCovers.grey || DeckCovers.green:
        final stops = switch (look.cover) {
          DeckCovers.grey => const [
            Color(0xFFAAAAAA),
            Color(0xFFF7F7F7),
            Color(0xFFE2E2E2),
            Color(0xFF757575),
            Color(0xFFAAAAAA),
          ],
          DeckCovers.green => const [
            Color(0xFF0F6A2A),
            Color(0xFF3CFF7F),
            Color(0xFF2FD468),
            Color(0xFF0A4A1D),
            Color(0xFF0F6A2A),
          ],
          _ => const [
            Color(0xFFFF7A59),
            Color(0xFFFFD36E),
            Color(0xFF6EE7FF),
            Color(0xFF7C5CFF),
            Color(0xFFFF7A59),
          ],
        };
        final rect = Offset.zero & Size.square(s);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(look.coverRadius)),
          Paint()
            ..shader = SweepGradient(
              colors: stops,
              transform: const GradientRotation(
                200 * math.pi / 180 - math.pi / 2,
              ),
            ).createShader(rect),
        );
    }
  }

  /// The prototype's sunset, 10 × 10 in the palette.
  static List<Color> _pixelArt() {
    const sky = [Color(0xFF29ADFF), Color(0xFF83769C), Color(0xFFFF77A8)];
    return [
      for (var y = 0; y < 10; y++)
        for (var x = 0; x < 10; x++)
          if (math.pow(x - 6.5, 2) + math.pow(y - 3.5, 2) < 5)
            const Color(0xFFFFEC27)
          else if (y > 6 + (math.sin(x) * 0.8).round())
            y > 8 ? const Color(0xFF1D2B53) : const Color(0xFF7E2553)
          else
            sky[math.min(2, (y / 2.4).floor())],
    ];
  }

  static const _full = [
    Color(0xFF000000),
    Color(0xFF1D2B53),
    Color(0xFFFFF1E8),
    ...picoColors,
  ];

  static Color _nearest(Color c) {
    var best = _full.first;
    var dist = double.infinity;
    for (final p in _full) {
      final d =
          math.pow(c.r - p.r, 2) +
          math.pow(c.g - p.g, 2) +
          math.pow(c.b - p.b, 2);
      if (d < dist) {
        dist = d.toDouble();
        best = p;
      }
    }
    return best;
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.look != look || old.pixels != pixels || old.n != n;
}

/// What's behind the tiles: a grid of faint dots, scanlines, or soft light.
class DeckBackdropPainter extends CustomPainter {
  DeckBackdropPainter(this.look, this.accent);

  final DeckLook look;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    switch (look.backdrop) {
      case DeckBackdrop.plain:
        break;
      case DeckBackdrop.dotGrid:
        final dot = Paint()..color = look.screenInk.withValues(alpha: 0.07);
        for (var y = 3.0; y < size.height; y += 6) {
          for (var x = 3.0; x < size.width; x += 6) {
            canvas.drawCircle(Offset(x, y), 1, dot);
          }
        }
      case DeckBackdrop.scanlines:
        final line = Paint()..color = Colors.black.withValues(alpha: 0.18);
        for (var y = 0.0; y < size.height; y += 4) {
          canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), line);
        }
      case DeckBackdrop.aurora:
        void glow(Alignment at, double r, Color c) {
          final center = at.alongSize(size);
          final radius = size.longestSide * r;
          canvas.drawCircle(
            center,
            radius,
            Paint()
              ..shader = RadialGradient(
                colors: [c, c.withValues(alpha: 0)],
              ).createShader(Rect.fromCircle(center: center, radius: radius)),
          );
        }
        glow(
          const Alignment(-0.9, -0.85),
          0.62,
          accent.withValues(alpha: 0.42),
        );
        glow(const Alignment(1, -0.1), 0.55, const Color(0x5922C3E6));
        glow(const Alignment(-0.3, 1), 0.6, const Color(0x597C5CFF));
    }
  }

  @override
  bool shouldRepaint(DeckBackdropPainter old) =>
      old.look.id != look.id || old.accent != accent;
}

/// Pixel's tile: notched corners, bevels, and a hard shadow below right.
class PixelBoxPainter extends CustomPainter {
  PixelBoxPainter(this.fill);

  final Color fill;

  static Path _notched(Rect r) {
    const a = 3.0, b = 6.0;
    final l = r.left, t = r.top, rr = r.right, bt = r.bottom;
    return Path()
      ..moveTo(l, t + b)
      ..lineTo(l + a, t + b)
      ..lineTo(l + a, t + a)
      ..lineTo(l + b, t + a)
      ..lineTo(l + b, t)
      ..lineTo(rr - b, t)
      ..lineTo(rr - b, t + a)
      ..lineTo(rr - a, t + a)
      ..lineTo(rr - a, t + b)
      ..lineTo(rr, t + b)
      ..lineTo(rr, bt - b)
      ..lineTo(rr - a, bt - b)
      ..lineTo(rr - a, bt - a)
      ..lineTo(rr - b, bt - a)
      ..lineTo(rr - b, bt)
      ..lineTo(l + b, bt)
      ..lineTo(l + b, bt - a)
      ..lineTo(l + a, bt - a)
      ..lineTo(l + a, bt - b)
      ..lineTo(l, bt - b)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final plain = Paint()..isAntiAlias = false;
    canvas.drawPath(
      _notched(r.shift(const Offset(3, 3))),
      plain..color = Colors.black,
    );
    final shape = _notched(r);
    canvas.drawPath(shape, plain..color = fill);
    canvas.save();
    canvas.clipPath(shape);
    void band(Rect b, Color c) => canvas.drawRect(b, plain..color = c);
    band(Rect.fromLTWH(0, 0, size.width, 3), const Color(0x47FFFFFF));
    band(
      Rect.fromLTWH(0, size.height - 3, size.width, 3),
      const Color(0x4D000000),
    );
    band(Rect.fromLTWH(0, 3, 3, size.height - 6), const Color(0x1FFFFFFF));
    band(
      Rect.fromLTWH(size.width - 3, 3, 3, size.height - 6),
      const Color(0x2E000000),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PixelBoxPainter old) => old.fill != fill;
}
