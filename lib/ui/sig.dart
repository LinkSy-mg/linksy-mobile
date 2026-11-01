import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Signal", Linksy's own look. Blue is the sender, cyan the receiver
/// (`brand/README.md` in linksy-desktop): outgoing things are blue, incoming
/// things cyan, everywhere.
@immutable
class Sig extends ThemeExtension<Sig> {
  const Sig({
    required this.bg,
    required this.card,
    required this.raised,
    required this.line,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.red,
    required this.heroTop,
    required this.heroBottom,
  });

  static const blue = Color(0xFF2563FF);
  static const cyan = Color(0xFF22C3E6);
  static const deep = Color(0xFF1438B8);

  /// The app icon's tile and receiver tint (data/icons in linksy-desktop).
  static const tileTop = Color(0xFF3B78FF);
  static const tileBottom = Color(0xFF1A45C8);
  static const tileShade = Color(0xFF12309A);
  static const cyanLight = Color(0xFF9FE6F5);

  /// Outgoing and incoming, by the brand's sender/receiver roles.
  static const outgoing = blue;
  static const incoming = cyan;

  static const display = 'Sora';
  static const body = 'Inter';

  final Color bg;
  final Color card;
  final Color raised;
  final Color line;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color red;

  /// The blue panel behind device headers, as on the app icon.
  final Color heroTop;
  final Color heroBottom;

  static const light = Sig(
    bg: Color(0xFFF2F4F9),
    card: Color(0xFFFFFFFF),
    raised: Color(0xFFE9EDF5),
    line: Color(0xFFE1E6EF),
    ink: Color(0xFF0A1024),
    muted: Color(0xFF5A6378),
    faint: Color(0xFF98A1B3),
    red: Color(0xFFE5384F),
    heroTop: blue,
    heroBottom: blue,
  );

  static const dark = Sig(
    bg: Color(0xFF080D1F),
    card: Color(0xFF111A3A),
    raised: Color(0xFF1A2550),
    line: Color(0xFF1E2A55),
    ink: Color(0xFFEEF2FA),
    muted: Color(0xFF94A0C0),
    faint: Color(0xFF56628A),
    red: Color(0xFFFF5C72),
    heroTop: deep,
    heroBottom: deep,
  );

  static Sig of(BuildContext context) => Theme.of(context).extension<Sig>()!;

  /// The flat blue of device headers: Signal blue, deep in dark mode.
  Color get hero => heroTop;

  @override
  Sig copyWith() => this;

  @override
  Sig lerp(Sig? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Sig(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      raised: l(raised, other.raised),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      red: l(red, other.red),
      heroTop: l(heroTop, other.heroTop),
      heroBottom: l(heroBottom, other.heroBottom),
    );
  }
}

abstract final class Radii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 30.0;
}

/// Display text in Sora: titles, names, numbers.
TextStyle sora(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color? color,
  double? spacing,
  double? height,
}) => TextStyle(
  fontFamily: Sig.display,
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing ?? -size * 0.025,
  height: height,
);

ThemeData buildTheme(Brightness brightness) {
  final s = brightness == Brightness.light ? Sig.light : Sig.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: Sig.blue,
        brightness: brightness,
      ).copyWith(
        primary: Sig.blue,
        onPrimary: Colors.white,
        secondary: Sig.cyan,
        surface: s.bg,
        onSurface: s.ink,
        onSurfaceVariant: s.muted,
        surfaceContainerLowest: s.card,
        surfaceContainerLow: s.card,
        surfaceContainer: s.card,
        surfaceContainerHigh: s.card,
        surfaceContainerHighest: s.raised,
        outline: s.faint,
        outlineVariant: s.line,
        error: s.red,
      );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: Sig.body,
    brightness: brightness,
  );
  final t = base.textTheme;
  TextStyle? d(TextStyle? x, FontWeight w) => x?.copyWith(
    fontFamily: Sig.display,
    fontWeight: w,
    letterSpacing: -(x.fontSize ?? 16) * 0.025,
  );

  return base.copyWith(
    scaffoldBackgroundColor: s.bg,
    canvasColor: s.bg,
    extensions: [s],
    // No ink ripples: pressables scale instead (see Pressable).
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: t.copyWith(
      displayLarge: d(t.displayLarge, FontWeight.w700),
      displayMedium: d(t.displayMedium, FontWeight.w700),
      displaySmall: d(t.displaySmall, FontWeight.w700),
      headlineLarge: d(t.headlineLarge, FontWeight.w700),
      headlineMedium: d(t.headlineMedium, FontWeight.w700),
      headlineSmall: d(t.headlineSmall, FontWeight.w600),
      titleLarge: d(t.titleLarge, FontWeight.w600),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      foregroundColor: s.ink,
      systemOverlayStyle: overlayFor(brightness),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: s.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 0,
      modalElevation: 0,
      backgroundColor: s.card,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: 0.45),
      showDragHandle: true,
      dragHandleColor: s.line,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.light ? s.ink : s.raised,
      contentTextStyle: TextStyle(
        fontFamily: Sig.body,
        color: brightness == Brightness.light ? Colors.white : s.ink,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 0,
      color: s.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: s.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: s.raised,
      hintStyle: TextStyle(color: s.faint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: Sig.blue, width: 1.5),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Sig.blue),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? Colors.white : s.card,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? Sig.blue : s.raised,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? Sig.blue : s.line,
      ),
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Sig.blue,
      linearTrackColor: s.raised,
      borderRadius: BorderRadius.circular(4),
      linearMinHeight: 5,
    ),
  );
}

SystemUiOverlayStyle overlayFor(Brightness brightness) => SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: Colors.transparent,
  statusBarIconBrightness: brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light,
  statusBarBrightness: brightness,
);

/// Each device's color, from its id so it survives renames, and only ever
/// one of the brand's, flat: (fill, initials) as blue/white, deep/white or
/// cyan/deep.
(Color, Color) devicePalette(String id) {
  const palettes = [
    (Sig.blue, Colors.white),
    (Sig.deep, Colors.white),
    (Sig.cyan, Sig.deep),
  ];
  return palettes[(int.tryParse(id.substring(0, 2), radix: 16) ?? 0) % 3];
}
