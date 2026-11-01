import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../ui/components.dart';
import '../../ui/sig.dart';

/// A settings page: a round back button with the page it came from beside it,
/// and a big title under them that settles into the bar as the page scrolls.
/// [lead] sits above the title (the hub's mark); [highlight] is the setting a
/// search opened the page for ([Flash]).
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.title,
    required this.children,
    this.backLabel,
    this.lead,
    this.highlight,
  });

  final String title;
  final String? backLabel;
  final Widget? lead;
  final String? highlight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return _Highlight(
      id: highlight,
      child: Scaffold(
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _Header(
                title: title,
                backLabel: backLabel,
                lead: lead,
                top: top,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                40 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.list(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends SliverPersistentHeaderDelegate {
  _Header({
    required this.title,
    required this.backLabel,
    required this.lead,
    required this.top,
  });

  final String title;
  final String? backLabel;
  final Widget? lead;
  final double top;

  static const _button = 44.0;
  static const _bar = 12.0 + _button + 12.0;
  static const _titleHeight = 44.0;
  static const _leadHeight = 40.0;
  static const _small = 0.6;

  double get _lead => lead == null ? 0 : _leadHeight;

  @override
  double get maxExtent => top + _bar + _lead + _titleHeight + 18;

  @override
  double get minExtent => top + _bar;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final s = Sig.of(context);
    final p = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final big = sora(34, weight: FontWeight.w700, color: s.ink);
    // Open: under the button (and the lead). Settled: beside the button,
    // centred on it.
    final openTop = top + _bar + _lead;
    final settledTop = top + 12 + (_button - _titleHeight * _small) / 2;
    return ColoredBox(
      color: s.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 16,
            top: top + 12,
            child: RoundButton(
              icon: Ph.arrowLeft,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          if (backLabel case final label?)
            Positioned(
              left: 16 + _button + 10,
              top: top + 12,
              height: _button,
              child: Opacity(
                opacity: (1 - p * 2.5).clamp(0.0, 1.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: s.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          if (lead case final lead?)
            Positioned(
              left: 20,
              top: top + _bar - 4,
              child: Opacity(opacity: (1 - p * 2).clamp(0.0, 1.0), child: lead),
            ),
          Positioned(
            left: lerpDouble(20, 16 + _button + 12, p),
            top: lerpDouble(openTop, settledTop, p),
            right: 16,
            child: Transform.scale(
              scale: lerpDouble(1, _small, p),
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: _titleHeight,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: big,
                ),
              ),
            ),
          ),
          // A hairline once the page runs under the bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: Opacity(
              opacity: p,
              child: ColoredBox(color: s.line),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_Header old) =>
      old.title != title ||
      old.backLabel != backLabel ||
      old.lead != lead ||
      old.top != top;
}

/// A titled group: the title bold above one big rounded card of rows.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title case final title?)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 22, 6, 10),
            child: Text(
              title,
              style: sora(16, weight: FontWeight.w700, color: s.ink),
            ),
          )
        else
          const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: s.card,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// One setting in a [SettingsSection]: its icon in a circle, its name, a
/// line about it, and what it holds (a switch, a value) or a way in.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    this.id,
    this.caption,
    this.trailing,
    this.onTap,
  });

  /// What a search result points at ([Flash]).
  final String? id;
  final IconData icon;
  final String title;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      child: Row(
        children: [
          IconCircle(icon: icon, color: Sig.blue, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: s.ink,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: s.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          if (onTap != null && trailing == null)
            Icon(Ph.caretRight, color: s.faint, size: 18),
        ],
      ),
    );
    return Flash(
      id: id,
      child: onTap == null ? row : Pressable(onTap: onTap, child: row),
    );
  }
}

/// What a setting opens up while it's on: its own rows in a pill a step
/// up, under it in the same card.
class SubOptions extends StatelessWidget {
  const SubOptions({super.key, required this.open, required this.children});

  final bool open;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
    alignment: Alignment.topCenter,
    child: open
        ? Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Sig.of(context).raised,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(children: children),
          )
        : const SizedBox(width: double.infinity),
  );
}

/// A visual card at the top of a page, or anywhere a page shows something
/// rather than lists it: a small label, then [child].
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    this.label,
    this.id,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final String? label;
  final String? id;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Flash(
        id: id,
        radius: 28,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: s.card,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label case final label?) ...[
                Text(
                  label,
                  style: TextStyle(
                    color: s.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A category on the hub: its icon in a coloured circle, its name, and a
/// line saying how it's set now.
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.summary,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Pressable(
        onTap: onTap,
        semanticLabel: title,
        child: Container(
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: s.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              IconCircle(icon: icon, color: color, size: 46, filled: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: sora(17, weight: FontWeight.w600, color: s.ink),
                    ),
                    if (summary case final summary? when summary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: s.muted, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Ph.caretRight, color: s.faint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// The setting a search opened this page for.
class _Highlight extends InheritedWidget {
  const _Highlight({required this.id, required super.child});

  final String? id;

  static String? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Highlight>()?.id;

  @override
  bool updateShouldNotify(_Highlight old) => old.id != id;
}

/// Scrolls the setting a search pointed at into view and lights it up for a
/// moment.
class Flash extends StatefulWidget {
  const Flash({super.key, required this.id, required this.child, this.radius});

  final String? id;
  final Widget child;
  final double? radius;

  @override
  State<Flash> createState() => _FlashState();
}

class _FlashState extends State<Flash> with SingleTickerProviderStateMixin {
  AnimationController? _glow;
  var _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.id;
    if (_done || id == null || _Highlight.of(context) != id) return;
    _done = true;
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Scrollable.ensureVisible(
        context,
        alignment: 0.35,
        duration: const Duration(milliseconds: 300),
      );
      if (mounted) _glow?.forward();
    });
  }

  @override
  void dispose() {
    _glow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = _glow;
    if (glow == null) return widget.child;
    return AnimatedBuilder(
      animation: glow,
      child: widget.child,
      builder: (context, child) {
        // Up quickly, then a slow fade.
        final t = glow.value;
        final a = t < 0.15 ? t / 0.15 : 1 - (t - 0.15) / 0.85;
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: Sig.blue.withValues(alpha: 0.16 * a),
            borderRadius: BorderRadius.circular(widget.radius ?? 18),
          ),
          child: child,
        );
      },
    );
  }
}
