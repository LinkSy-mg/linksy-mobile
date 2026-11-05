import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models.dart';
import 'format.dart';
import 'icons.dart';
import 'l10n.dart';
import 'sig.dart';

export 'icons.dart';

/// [ms] long, or done by the next frame when motion is reduced (the
/// phone's setting, or Settings › This app › Reduce motion). Not zero:
/// AnimatedSize can't take that.
Duration motion(BuildContext context, [int ms = 200]) =>
    MediaQuery.disableAnimationsOf(context)
    ? const Duration(milliseconds: 1)
    : Duration(milliseconds: ms);

/// Shrinks a little while pressed, instead of an ink ripple; dims instead
/// when motion is reduced.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required Widget this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.semanticLabel,
  }) : builder = null;

  /// Built with whether it's held, for keys that also light up.
  const Pressable.builder({
    super.key,
    required Widget Function(BuildContext context, bool down) this.builder,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.semanticLabel,
  }) : child = null;

  final Widget? child;
  final Widget Function(BuildContext context, bool down)? builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  DateTime _since = DateTime(0);
  Timer? _release;

  void _press() {
    _release?.cancel();
    _since = DateTime.now();
    if (!_down) setState(() => _down = true);
  }

  /// Held a moment at least: in a list a quick tap reports down and up
  /// together, and would show nothing.
  void _lift() {
    final left =
        const Duration(milliseconds: 90) - DateTime.now().difference(_since);
    _release?.cancel();
    _release = left > Duration.zero ? Timer(left, _up) : null;
    if (_release == null) _up();
  }

  void _up() {
    _release?.cancel();
    if (mounted && _down) setState(() => _down = false);
  }

  @override
  void dispose() {
    _release?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _press() : null,
        onTapUp: enabled ? (_) => _lift() : null,
        onTapCancel: enabled ? _up : null,
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _up();
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: Opacity(
          opacity: reduced && _down ? 0.6 : 1,
          child: AnimatedScale(
            scale: !reduced && _down ? widget.scale : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: widget.builder?.call(context, _down) ?? widget.child,
          ),
        ),
      ),
    );
  }
}

/// A flat surface: white on the grey page in light, a step up from the page
/// in dark. No borders, no shadows.
class SigCard extends StatelessWidget {
  const SigCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = Radii.lg,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? s.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
    return onTap == null ? card : Pressable(onTap: onTap, child: card);
  }
}

enum SigButtonKind { primary, secondary, quiet, danger }

class SigButton extends StatelessWidget {
  const SigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.kind = SigButtonKind.primary,
    this.expand = false,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final SigButtonKind kind;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final fg = switch (kind) {
      SigButtonKind.primary || SigButtonKind.danger => Colors.white,
      SigButtonKind.secondary => Sig.blue,
      SigButtonKind.quiet => Sig.blue,
    };
    final decoration = switch (kind) {
      SigButtonKind.primary => BoxDecoration(
        color: Sig.blue,
        borderRadius: BorderRadius.circular(99),
      ),
      SigButtonKind.danger => BoxDecoration(
        color: s.red,
        borderRadius: BorderRadius.circular(99),
      ),
      SigButtonKind.secondary => BoxDecoration(
        color: Sig.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      SigButtonKind.quiet => const BoxDecoration(),
    };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Sig.body,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
    return AnimatedOpacity(
      opacity: onTap == null ? 0.5 : 1,
      duration: motion(context, 150),
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: motion(context, 150),
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: decoration,
          child: ExcludeSemantics(child: content),
        ),
      ),
    );
  }
}

/// A small text button (See more, Allow, Stop): [color] text on [fill], or
/// on nothing. Dips while pressed like the rest, and darkens or tints too;
/// Material's TextButton only shades.
class SmallAction extends StatelessWidget {
  const SmallAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = Sig.blue,
    this.fill,
    this.height = 40,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color? fill;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fill = this.fill;
    return AnimatedOpacity(
      opacity: onTap == null ? 0.5 : 1,
      duration: motion(context, 150),
      child: Pressable.builder(
        onTap: onTap,
        scale: 0.95,
        semanticLabel: label,
        builder: (context, down) => AnimatedContainer(
          duration: motion(context, 90),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: fill == null ? 12 : 16),
          decoration: BoxDecoration(
            color: fill == null
                ? color.withValues(alpha: down ? 0.12 : 0)
                : down
                ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), fill)
                : fill,
            borderRadius: BorderRadius.circular(99),
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon case final icon?) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

/// Equal tabs in one track, with a [pill] that slides under the chosen one.
class Segments extends StatelessWidget {
  const Segments({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.builder,
    this.pill = Sig.blue,
    this.track,
    this.height = 44,
    this.radius = 99,
    this.inset = 4,
  });

  /// One per tab, for screen readers.
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  /// Tab [i]'s content; [on] goes from 0 to 1 as it becomes the chosen one.
  final Widget Function(BuildContext context, int i, double on) builder;
  final Color pill;
  final Color? track;
  final double height;
  final double radius;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    // None chosen (a value the list lacks): no pill.
    final chosen = selected >= 0 && selected < n;
    final at = chosen ? selected : 0;
    return Container(
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: track ?? Sig.of(context).card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedAlign(
              alignment: AlignmentDirectional(
                n < 2 ? 0 : -1 + 2 * at / (n - 1),
                0,
              ),
              duration: motion(context, 260),
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: chosen ? pill : pill.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(radius - inset),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: Pressable(
                      onTap: () => onChanged(i),
                      semanticLabel: labels[i],
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: i == selected ? 1 : 0),
                        duration: motion(context),
                        builder: (context, on, _) =>
                            Center(child: builder(context, i, on)),
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
}

/// A round button for top bars.
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.onDark = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  /// White on the blue hero panels.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        semanticLabel: tooltip,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onDark ? Colors.white.withValues(alpha: 0.16) : s.card,
          ),
          child: Icon(icon, size: 20, color: onDark ? Colors.white : s.ink),
        ),
      ),
    );
  }
}

/// "DEVICES  3": small caps above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: Sig.body,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: s.muted,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

/// Connected is the receiver's cyan, nearby the sender's blue, away grey.
/// On the blue hero, nearby turns white so it still shows.
Color presenceColor(Sig s, Presence p, {bool onBlue = false}) => switch (p) {
  Presence.connected => onBlue ? Sig.cyanLight : Sig.cyan,
  Presence.nearby => onBlue ? Colors.white : Sig.blue,
  Presence.notNearby => onBlue ? Colors.white54 : s.faint,
};

String presenceLabel(Presence p) => switch (p) {
  Presence.connected => tr.commonConnected,
  Presence.nearby => tr.commonNearby,
  Presence.notNearby => tr.commonNotNearby,
};

/// [presenceLabel], saying how a connection goes: the USB cable, or the
/// internet (away from home).
/// How a device is reached, for lists: the cable, the internet, or the same
/// network.
String linkWords(DeviceView v) => switch (v) {
  DeviceView(connected: true, usb: true) => tr.commonUsbCable,
  DeviceView(connected: true, direct: true) => tr.routeDirect,
  DeviceView(connected: true, away: true) => tr.commonAwayFromHome,
  DeviceView(presence: Presence.notNearby) => tr.commonNotNearby,
  _ => tr.commonSameWifi,
};

String presenceText(DeviceView v) => switch (v) {
  DeviceView(connected: true, usb: true) => tr.commonConnectedByUsb,
  DeviceView(connected: true, away: true) => tr.commonConnectedAway,
  _ => presenceLabel(v.presence),
};

/// A device as a disc in one of the brand's colors (blue, deep or cyan),
/// initials in Sora. Its presence is the ring: cyan when connected, blue when
/// nearby, none when away (and the disc dims).
class Orb extends StatelessWidget {
  const Orb({
    super.key,
    required this.device,
    this.size = 52,
    this.presence,
    this.onBlue = false,
    this.picture,
    this.battery,
  });

  final DeviceInfo device;
  final double size;
  final Presence? presence;

  /// Its battery, drawn as the presence ring filled to the level.
  final Battery? battery;

  /// The device's picture (a file), shown instead of its initials.
  final String? picture;

  /// Sits on a blue hero: a white edge keeps it apart from the background.
  final bool onBlue;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final (fill, ink) = devicePalette(device.id);
    final away = presence == Presence.notNearby;
    final ring = presence == null || away
        ? null
        : presenceColor(s, presence!, onBlue: onBlue);
    final ringWidth = max(2.0, size * 0.045);

    Widget orb = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: onBlue
            ? Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2)
            : null,
      ),
      clipBehavior: picture == null ? Clip.none : Clip.antiAlias,
      child: picture == null
          ? Text(
              initials(device.name),
              style: sora(
                size * 0.34,
                weight: FontWeight.w700,
                color: ink,
                spacing: 0.5,
              ),
            )
          : Image.file(
              File(picture!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 3).round(),
              gaplessPlayback: true,
            ),
    );
    if (away) orb = Opacity(opacity: 0.45, child: orb);
    if (ring == null) return orb;
    if (battery case final b?) {
      return Semantics(
        label: b.charging
            ? context.l10n.commonBatteryCharging(b.level)
            : context.l10n.commonBattery(b.level),
        child: CustomPaint(
          painter: _BatteryRing(
            level: b.level / 100,
            color: ring,
            track: onBlue ? Colors.white.withValues(alpha: 0.2) : s.raised,
            width: ringWidth,
          ),
          child: Padding(padding: EdgeInsets.all(ringWidth + 1.5), child: orb),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(ringWidth + 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: ringWidth),
      ),
      child: orb,
    );
  }
}

/// The ring round a device's disc, filled clockwise from the top to its
/// battery level.
class _BatteryRing extends CustomPainter {
  const _BatteryRing({
    required this.level,
    required this.color,
    required this.track,
    required this.width,
  });

  final double level;
  final Color color;
  final Color track;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    if (level > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * level.clamp(0.0, 1.0),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_BatteryRing old) =>
      old.level != level ||
      old.color != color ||
      old.track != track ||
      old.width != width;
}

/// Icon in a soft circle of its color.
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: motion(context, 180),
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color : color.withValues(alpha: 0.13),
    ),
    child: AnimatedSwitcher(
      duration: motion(context, 180),
      transitionBuilder: popIn,
      child: Icon(
        icon,
        key: ValueKey((icon, filled)),
        size: size * 0.48,
        color: filled ? Colors.white : color,
      ),
    ),
  );
}

/// How an icon or a short label changes in an [AnimatedSwitcher]: it fades,
/// growing from a little smaller.
Widget popIn(Widget child, Animation<double> animation) => FadeTransition(
  opacity: animation,
  child: ScaleTransition(
    scale: Tween(begin: 0.8, end: 1.0).animate(animation),
    child: child,
  ),
);

IconData kindIcon(DeviceKind kind) => switch (kind) {
  DeviceKind.desktop => Ph.desktop,
  DeviceKind.laptop => Ph.laptop,
  DeviceKind.phone => Ph.deviceMobile,
  DeviceKind.tablet => Ph.deviceTablet,
};

IconData fileIcon(String name) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  return switch (ext) {
    'jpg' ||
    'jpeg' ||
    'png' ||
    'gif' ||
    'webp' ||
    'heic' ||
    'heif' ||
    'bmp' ||
    'svg' ||
    'raw' ||
    'dng' => Ph.fileImage,
    'mp4' ||
    'mov' ||
    'mkv' ||
    'webm' ||
    'avi' ||
    'm4v' ||
    '3gp' => Ph.fileVideo,
    'mp3' ||
    'wav' ||
    'flac' ||
    'ogg' ||
    'm4a' ||
    'opus' ||
    'aac' => Ph.fileAudio,
    'pdf' => Ph.filePdf,
    'zip' || 'tar' || 'gz' || '7z' || 'rar' || 'xz' || 'bz2' => Ph.fileZip,
    'doc' || 'docx' || 'odt' || 'rtf' || 'pages' => Ph.fileDoc,
    'xls' || 'xlsx' || 'ods' || 'numbers' => Ph.fileXls,
    'csv' || 'tsv' => Ph.fileCsv,
    'ppt' || 'pptx' || 'odp' || 'key' => Ph.filePpt,
    'txt' || 'md' || 'log' => Ph.fileText,
    'json' ||
    'xml' ||
    'yaml' ||
    'yml' ||
    'html' ||
    'css' ||
    'js' ||
    'ts' ||
    'dart' ||
    'rs' ||
    'py' ||
    'kt' ||
    'java' ||
    'c' ||
    'cpp' ||
    'h' ||
    'go' ||
    'sh' => Ph.fileCode,
    _ => Ph.file,
  };
}

/// The "Sender" mark: Signal blue and cyan, or white and light cyan on blue
/// (as on the app icon).
class LinksyMark extends StatelessWidget {
  const LinksyMark({super.key, this.size = 48, this.onBlue = false});

  final double size;
  final bool onBlue;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Linksy',
    image: true,
    child: CustomPaint(
      size: Size.square(size),
      painter: _Mark(
        sender: onBlue ? Colors.white : Sig.blue,
        receiver: onBlue ? Sig.cyanLight : Sig.cyan,
      ),
    ),
  );
}

/// The app icon, flat: the mark in white and light cyan on a rounded blue
/// tile (data/icons in linksy-desktop).
class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.16),
    decoration: BoxDecoration(
      color: Sig.blue,
      borderRadius: BorderRadius.circular(size * 0.23),
    ),
    child: LinksyMark(size: size * 0.68, onBlue: true),
  );
}

/// The "Sender" mark on its 100-unit grid (brand/README.md): sender dot r12
/// at (25,75) with an arc r28, receiver dot r8 at (78,22) with an arc r20.
class _Mark extends CustomPainter {
  const _Mark({required this.sender, required this.receiver});

  final Color sender;
  final Color receiver;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final dot = Paint();
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(25, 75), 12, dot..color = sender);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(25, 75), radius: 28),
      -pi / 2,
      pi / 2,
      false,
      arc
        ..color = sender
        ..strokeWidth = 9.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(78, 22), radius: 20),
      pi / 2,
      pi / 2,
      false,
      arc
        ..color = receiver
        ..strokeWidth = 8,
    );
    canvas.drawCircle(const Offset(78, 22), 8, dot..color = receiver);
  }

  @override
  bool shouldRepaint(_Mark old) =>
      old.sender != sender || old.receiver != receiver;
}

/// Mark plus the "Linksy" name.
class Wordmark extends StatelessWidget {
  const Wordmark({
    super.key,
    this.onBlue = false,
    this.markKey,
    this.markShown,
  });

  final bool onBlue;

  /// The launch intro's landing spot ([markKey]), and when the mark shows
  /// ([markShown]: once the intro's mark has landed in it).
  final Key? markKey;
  final ValueListenable<bool>? markShown;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (markShown case final shown?)
        ValueListenableBuilder(
          valueListenable: shown,
          builder: (_, on, _) => Opacity(
            opacity: on ? 1 : 0,
            child: LinksyMark(key: markKey, size: 30, onBlue: onBlue),
          ),
        )
      else
        LinksyMark(key: markKey, size: 30, onBlue: onBlue),
      const SizedBox(width: 8),
      Text(
        'Linksy',
        style: sora(
          24,
          weight: FontWeight.w700,
          color: onBlue ? Colors.white : Sig.of(context).ink,
          spacing: -0.8,
        ),
      ),
    ],
  );
}

/// Loops [controller], or holds it still when the system asks for less
/// motion.
void loopUnlessReduced(BuildContext context, AnimationController controller) {
  if (MediaQuery.disableAnimationsOf(context)) {
    controller.stop();
  } else if (!controller.isAnimating) {
    controller.repeat();
  }
}

/// A small dot that breathes, for "visible" and "looking".
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessReduced(context, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size * 2.4,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * (1 + 1.4 * p),
              height: widget.size * (1 + 1.4 * p),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.4 * (1 - p)),
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    ),
  );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Runs a controller action and shows its error, if any; true when it went.
/// The messenger is taken before waiting, so the screen may close meanwhile.
Future<bool> report(BuildContext context, Future<String?> action) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await action;
  if (error == null) return true;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(error)));
  return false;
}

/// One choice in a sheet: icon, title and caption; [primary] is the blue one.
class SheetOption extends StatelessWidget {
  const SheetOption({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final fg = primary ? Colors.white : s.ink;
    final content = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary
                ? Colors.white.withValues(alpha: 0.16)
                : Sig.blue.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: primary ? Colors.white : Sig.blue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: sora(17, color: fg)),
              Text(
                caption,
                style: TextStyle(
                  fontSize: 13,
                  color: primary
                      ? Colors.white.withValues(alpha: 0.75)
                      : s.muted,
                ),
              ),
            ],
          ),
        ),
        Icon(Ph.caretRight, color: primary ? Colors.white70 : s.faint),
      ],
    );
    if (!primary) {
      return SigCard(onTap: onTap, color: s.bg, child: content);
    }
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Sig.blue,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: content,
      ),
    );
  }
}

/// Numbered steps to follow in Android's own settings: a blue number, then
/// the step.
class NumberedSteps extends StatelessWidget {
  const NumberedSteps(this.steps, {super.key, this.fontSize = 14.5});

  final List<String> steps;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, step) in steps.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Sig.blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Sig.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          // ⚙ is the gear Android draws: drawn as ours, not
                          // as the font's emoji.
                          for (final (j, part) in step.split('⚙').indexed) ...[
                            if (j > 0)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Icon(
                                  Ph.gearSix,
                                  size: fontSize + 2,
                                  color: s.ink,
                                ),
                              ),
                            TextSpan(text: part),
                          ],
                        ],
                      ),
                      style: TextStyle(
                        color: s.ink,
                        fontSize: fontSize,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
