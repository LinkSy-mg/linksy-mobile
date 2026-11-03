import 'package:flutter/material.dart';

import '../../ui/l10n.dart';

/// How a look writes: in a font, or in 5×7 glyphs of dots or squares.
enum DeckLetters { font, dots, squares }

/// How it draws icons: a line, a line of dots, pixels, or a glowing line.
enum DeckStroke { line, dotted, pixel, glow }

/// How it draws bars: flat, rows of dots, or blocks.
enum DeckBars { flat, dots, blocks }

/// What's behind the tiles besides its colour.
enum DeckBackdrop { plain, dotGrid, scanlines, aurora }

/// Where a tile's own colour goes: nowhere, its fill, its fill in the
/// 16-colour palette, or its icon.
enum DeckTint { none, fill, pico, icon }

/// The music's cover when there's none, or how one is drawn.
enum DeckCovers { colour, grey, green, dots, pixel }

/// A tile's colours, as a look draws it.
typedef DeckPaint = ({Color fill, Color ink, Color icon, Color? stroke});

/// A deck's look (docs/protocol.md §4.20): the computer's five, as its
/// editor draws them (the desktop's deck/style.rs and the prototype's CSS),
/// and the phone's own. Each is made for one [accent], the colour of what's
/// on.
class DeckLook {
  const DeckLook({
    required this.id,
    required this.brightness,
    required this.background,
    this.gradient,
    this.backdrop = DeckBackdrop.plain,
    required this.screenInk,
    required this.tile,
    this.stroke,
    this.strokeWidth = 1,
    required this.radius,
    this.tint = DeckTint.none,
    required this.ink,
    required this.on,
    required this.onInk,
    this.onStroke,
    this.font,
    this.weight = FontWeight.w600,
    this.upper = false,
    this.spacing = 0,
    this.letters = DeckLetters.font,
    this.prefix = '',
    this.glow,
    this.icons = DeckStroke.line,
    this.bars = DeckBars.flat,
    required this.track,
    required this.fill,
    this.thickFill,
    this.barRadius = 3,
    this.thickRadius = 10,
    required this.play,
    required this.playInk,
    this.playRadius = 99,
    this.playShadow = false,
    required this.dot,
    required this.dotOn,
    this.squareDots = false,
    this.cover = DeckCovers.colour,
    this.coverRadius = 8,
    this.bevel = false,
  });

  final String id;

  /// Whether the screen is light (dark status bar icons) or dark.
  final Brightness brightness;
  final Color background;
  final Gradient? gradient;
  final DeckBackdrop backdrop;

  /// The deck's name and page dots, over the background.
  final Color screenInk;
  final Color tile;
  final Color? stroke;
  final double strokeWidth;
  final double radius;
  final DeckTint tint;
  final Color ink;

  /// What's on: a muted microphone, Wi-Fi.
  final Color on;
  final Color onInk;
  final Color? onStroke;
  final String? font;
  final FontWeight weight;
  final bool upper;
  final double spacing;
  final DeckLetters letters;

  /// Before each tile's label (Terminal's prompt).
  final String prefix;
  final List<Shadow>? glow;
  final DeckStroke icons;
  final DeckBars bars;
  final Color track;
  final Color fill;

  /// The volume's, when it isn't [fill].
  final Color? thickFill;
  final double barRadius;
  final double thickRadius;
  final Color play;
  final Color playInk;
  final double playRadius;
  final bool playShadow;
  final Color dot;
  final Color dotOn;
  final bool squareDots;
  final DeckCovers cover;
  final double coverRadius;

  /// Pixel's notched corners, bevels and hard shadow.
  final bool bevel;

  /// The computer's five, then the phone's own.
  static const computers = ['stock', 'dots', 'eink', 'term', 'pixel'];
  static const phones = ['signal', 'glass', 'midnight'];

  static String name(BuildContext context, String id) {
    final l = context.l10n;
    return switch (id) {
      'dots' => l.deckThemeDots,
      'eink' => l.deckThemeEink,
      'term' => l.deckThemeTerm,
      'pixel' => l.deckThemePixel,
      'signal' => l.deckThemeSignal,
      'glass' => l.deckThemeGlass,
      'midnight' => l.deckThemeMidnight,
      _ => l.deckThemeStock,
    };
  }

  /// The look [id] in [accent]; one this phone doesn't know is Stock.
  static DeckLook of(String id, Color accent) => switch (id) {
    'dots' => _dots(accent),
    'eink' => _eink,
    'term' => _term,
    'pixel' => _pixel,
    'signal' => _signal(accent),
    'glass' => _glass(accent),
    'midnight' => _midnight(accent),
    _ => _stock(accent),
  };

  /// A tile of colour [c] (its own, or its kind's), off or [on].
  DeckPaint paint(Color c, {required bool on}) {
    switch (tint) {
      case DeckTint.fill:
        return on
            ? (fill: Colors.white, ink: c, icon: c, stroke: null)
            : (fill: c, ink: ink, icon: ink, stroke: stroke);
      case DeckTint.pico:
        if (on) return (fill: this.on, ink: onInk, icon: onInk, stroke: null);
        final (p, light) = pico(c);
        final i = light ? const Color(0xFF1D2B53) : ink;
        return (fill: p, ink: i, icon: i, stroke: null);
      case DeckTint.icon:
        final lit = _lighten(c);
        return on
            ? (fill: lit, ink: Colors.black, icon: Colors.black, stroke: null)
            : (fill: tile, ink: ink, icon: lit, stroke: stroke);
      case DeckTint.none:
        return on
            ? (fill: this.on, ink: onInk, icon: onInk, stroke: onStroke)
            : (fill: tile, ink: ink, icon: ink, stroke: stroke);
    }
  }

  /// Text in this look's font, [size] at the editor's scale.
  TextStyle text(
    double size, {
    Color? color,
    FontWeight? weight,
    double opacity = 1,
  }) => TextStyle(
    fontFamily: font,
    fontSize: size,
    fontWeight: weight ?? this.weight,
    letterSpacing: spacing == 0 ? null : spacing * size,
    color: (color ?? ink).withValues(alpha: (color ?? ink).a * opacity),
    height: 1.2,
    // Terminal's glow, but under dark text on what's on.
    shadows: color == null || color == ink ? glow : null,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// The bright end of a colour, for an icon on black.
  static Color _lighten(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness(hsl.lightness < 0.62 ? 0.62 : hsl.lightness)
        .withSaturation(hsl.saturation < 0.55 ? 0.55 : hsl.saturation)
        .toColor();
  }

  static DeckLook _stock(Color a) => DeckLook(
    id: 'stock',
    brightness: Brightness.dark,
    background: const Color(0xFF1D1D20),
    screenInk: Colors.white,
    tile: const Color(0xFF2E2E32),
    radius: 14,
    ink: Colors.white,
    on: a,
    onInk: Colors.white,
    font: 'Inter',
    track: Colors.white.withValues(alpha: 0.14),
    fill: a,
    play: Colors.white,
    playInk: const Color(0xFF1D1D20),
    dot: Colors.white.withValues(alpha: 0.28),
    dotOn: Colors.white,
  );

  static DeckLook _dots(Color a) => DeckLook(
    id: 'dots',
    brightness: Brightness.dark,
    background: Colors.black,
    backdrop: DeckBackdrop.dotGrid,
    screenInk: const Color(0xFFF2F2F2),
    tile: Colors.white.withValues(alpha: 0.025),
    stroke: Colors.white.withValues(alpha: 0.13),
    radius: 18,
    ink: const Color(0xFFF2F2F2),
    on: a.withValues(alpha: 0.08),
    onInk: a,
    onStroke: a,
    font: 'monospace',
    weight: FontWeight.w800,
    upper: true,
    spacing: 0.05,
    letters: DeckLetters.dots,
    icons: DeckStroke.dotted,
    bars: DeckBars.dots,
    track: Colors.white.withValues(alpha: 0.22),
    fill: Colors.white,
    play: a,
    playInk: Colors.white,
    dot: Colors.white.withValues(alpha: 0.28),
    dotOn: a,
    cover: DeckCovers.dots,
  );

  static const _eink = DeckLook(
    id: 'eink',
    brightness: Brightness.light,
    background: Color(0xFFE7E7E1),
    screenInk: Color(0xFF111111),
    tile: Color(0xFFF5F5F0),
    stroke: Color(0xFF111111),
    strokeWidth: 2,
    radius: 10,
    ink: Color(0xFF111111),
    on: Color(0xFF111111),
    onInk: Color(0xFFF5F5F0),
    font: 'monospace',
    track: Color(0xFFCFCFC6),
    fill: Color(0xFF111111),
    play: Color(0xFF111111),
    playInk: Color(0xFFF5F5F0),
    dot: Color(0x40000000),
    dotOn: Color(0xFF111111),
    cover: DeckCovers.grey,
    coverRadius: 6,
  );

  static const _green = Color(0xFF39FF7A);

  static const _term = DeckLook(
    id: 'term',
    brightness: Brightness.dark,
    background: Color(0xFF040904),
    screenInk: _green,
    tile: Color(0x0A39FF7A),
    stroke: Color(0x7339FF7A),
    radius: 4,
    ink: _green,
    on: Color(0xD939FF7A),
    onInk: Color(0xFF041204),
    font: 'monospace',
    weight: FontWeight.w400,
    prefix: '> ',
    glow: [Shadow(color: Color(0x8C39FF7A), blurRadius: 6)],
    icons: DeckStroke.glow,
    track: Color(0x2639FF7A),
    fill: _green,
    barRadius: 0,
    thickRadius: 0,
    play: _green,
    playInk: Color(0xFF041204),
    playRadius: 2,
    dot: Color(0x4D39FF7A),
    dotOn: _green,
    cover: DeckCovers.green,
    coverRadius: 2,
  );

  static const _pixel = DeckLook(
    id: 'pixel',
    brightness: Brightness.dark,
    background: Color(0xFF1D2B53),
    backdrop: DeckBackdrop.scanlines,
    screenInk: Color(0xFFFFF1E8),
    tile: Color(0xFF5F574F),
    radius: 0,
    tint: DeckTint.pico,
    ink: Color(0xFFFFF1E8),
    on: Color(0xFFFF004D),
    onInk: Color(0xFFFFF1E8),
    font: 'monospace',
    weight: FontWeight.w700,
    upper: true,
    letters: DeckLetters.squares,
    icons: DeckStroke.pixel,
    bars: DeckBars.blocks,
    track: Colors.black,
    fill: Color(0xFF00E436),
    thickFill: Color(0xFFFFEC27),
    barRadius: 0,
    thickRadius: 0,
    play: Color(0xFFFF004D),
    playInk: Color(0xFFFFF1E8),
    playRadius: 0,
    playShadow: true,
    dot: Color(0x47FFFFFF),
    dotOn: Color(0xFFFFEC27),
    squareDots: true,
    cover: DeckCovers.pixel,
    coverRadius: 0,
    bevel: true,
  );

  /// Linksy's own: each tile in its colour on the app's night blue, white
  /// with its colour while on.
  static DeckLook _signal(Color a) => DeckLook(
    id: 'signal',
    brightness: Brightness.dark,
    background: const Color(0xFF0D1220),
    gradient: const LinearGradient(
      begin: Alignment(-0.6, -1),
      end: Alignment(0.6, 1),
      colors: [Color(0xFF111A33), Color(0xFF0D1220)],
      stops: [0, 0.55],
    ),
    screenInk: const Color(0xFFEEF2FB),
    tile: const Color(0xFF243050),
    radius: 16,
    tint: DeckTint.fill,
    ink: Colors.white,
    on: Colors.white,
    onInk: const Color(0xFF0D1220),
    font: 'Inter',
    track: Colors.white.withValues(alpha: 0.22),
    fill: Colors.white,
    play: Colors.white,
    playInk: const Color(0xFF111111),
    dot: Colors.white.withValues(alpha: 0.28),
    dotOn: Colors.white,
  );

  /// Frosted tiles over soft light in the accent, white while on.
  static DeckLook _glass(Color a) => DeckLook(
    id: 'glass',
    brightness: Brightness.dark,
    background: const Color(0xFF0B1026),
    backdrop: DeckBackdrop.aurora,
    screenInk: Colors.white,
    tile: Colors.white.withValues(alpha: 0.09),
    stroke: Colors.white.withValues(alpha: 0.16),
    radius: 22,
    ink: Colors.white,
    on: Colors.white.withValues(alpha: 0.9),
    onInk: const Color(0xFF0B1026),
    font: 'Inter',
    track: Colors.white.withValues(alpha: 0.16),
    fill: Colors.white,
    play: Colors.white,
    playInk: const Color(0xFF0B1026),
    dot: Colors.white.withValues(alpha: 0.3),
    dotOn: Colors.white,
    coverRadius: 12,
  );

  /// Black, for an OLED screen kept on: dark tiles, icons in their colour,
  /// lit in it while on.
  static DeckLook _midnight(Color a) => DeckLook(
    id: 'midnight',
    brightness: Brightness.dark,
    background: Colors.black,
    screenInk: const Color(0xFFB8B8C0),
    tile: const Color(0xFF111114),
    radius: 20,
    tint: DeckTint.icon,
    ink: const Color(0xFFD8D8DE),
    on: a,
    onInk: Colors.black,
    font: 'Inter',
    track: Colors.white.withValues(alpha: 0.1),
    fill: a,
    play: a,
    playInk: Colors.black,
    dot: Colors.white.withValues(alpha: 0.2),
    dotOn: const Color(0xFFD8D8DE),
    coverRadius: 12,
  );
}

/// The 16-colour console palette Pixel keeps to, but its night blue, black
/// and white, which it draws with.
const picoColors = [
  Color(0xFF7E2553),
  Color(0xFF008751),
  Color(0xFFAB5236),
  Color(0xFF5F574F),
  Color(0xFFC2C3C7),
  Color(0xFFFF004D),
  Color(0xFFFFA300),
  Color(0xFFFFEC27),
  Color(0xFF00E436),
  Color(0xFF29ADFF),
  Color(0xFF83769C),
  Color(0xFFFF77A8),
  Color(0xFFFFCCAA),
];

int _channel(double v) => (v * 255).round();

/// The nearest colour of [picoColors], and whether dark ink reads better
/// on it.
(Color, bool) pico(Color c) {
  final r = _channel(c.r), g = _channel(c.g), b = _channel(c.b);
  var best = picoColors.first;
  var dist = 1 << 30;
  for (final p in picoColors) {
    final dr = r - _channel(p.r),
        dg = g - _channel(p.g),
        db = b - _channel(p.b);
    final d = dr * dr + dg * dg + db * db;
    if (d < dist) {
      dist = d;
      best = p;
    }
  }
  final light =
      0.299 * _channel(best.r) +
          0.587 * _channel(best.g) +
          0.114 * _channel(best.b) >
      160;
  return (best, light);
}

/// A tile's colour when the computer gave none: by its kind, or its
/// action's group (the desktop's `default_color`).
Color deckDefaultColor(String kind, String? action) {
  final group = action?.split('.').first;
  return switch ((kind, group)) {
    ('music', _) => const Color(0xFF3B2A63),
    ('clock', _) => const Color(0xFF0F766E),
    ('volume', _) => const Color(0xFF1D4FD8),
    (_, 'media') => const Color(0xFF24345C),
    (_, 'sound') => const Color(0xFF2B3550),
    (_, 'command') => const Color(0xFF14532D),
    (_, 'network') => const Color(0xFF155E75),
    (_, 'power') => const Color(0xFFA16207),
    _ => const Color(0xFF334155),
  };
}
