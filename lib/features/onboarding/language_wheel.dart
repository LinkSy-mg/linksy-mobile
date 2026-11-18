import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../app/scope.dart';
import '../../ui/sig.dart';
import '../../ui/responsive.dart';

/// The 10 languages on a wheel: each in its own name, the English one
/// under it, the one in the middle chosen. Scrolling, or tapping one, picks.
class LanguageWheel extends StatefulWidget {
  const LanguageWheel({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onPicked,
    this.autofocus = false,
    this.height = 340,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  /// The centre button, A or Enter on the wheel: the language in the band
  /// is the one, and this goes on (a remote needn't reach Continue).
  final VoidCallback? onPicked;

  /// A remote's focus starts on the wheel.
  final bool autofocus;
  final double height;

  @override
  State<LanguageWheel> createState() => _LanguageWheelState();
}

class _LanguageWheelState extends State<LanguageWheel> {
  static const _extent = 62.0;
  late final _scroll = FixedExtentScrollController(initialItem: _index);
  late int _current = _index;

  int get _index {
    final i = languages.indexWhere((l) => l.code == widget.selected);
    return i < 0 ? 0 : i;
  }

  final _focus = FocusNode(debugLabel: 'LanguageWheel');
  bool _focused = false;

  /// Where the wheel is turning to, while it turns.
  int? _target;

  /// A remote's up and down turn the wheel a step; past either end they
  /// move on, to the title above or the button below. The centre button
  /// or A picks the language in the band.
  KeyEventResult _key(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final picked = widget.onPicked;
    if (picked != null && RemoteKeys.activates(e.logicalKey)) {
      if (e is KeyDownEvent) {
        final at = _target ?? _current;
        HapticFeedback.selectionClick();
        widget.onChanged(languages[at].code);
        picked();
      }
      return KeyEventResult.handled;
    }
    final step = switch (e.logicalKey) {
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowDown => 1,
      _ => 0,
    };
    if (step == 0) return KeyEventResult.ignored;
    final to = (_target ?? _current) + step;
    if (to < 0 || to >= languages.length) return KeyEventResult.ignored;
    _target = to;
    _scroll
        .animateToItem(
          to,
          duration: motion(context, 180),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (_target == to) _target = null;
        });
    return KeyEventResult.handled;
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_highlightChanged);
  }

  void _highlightChanged(FocusHighlightMode _) {
    if (mounted && _focused) setState(() {});
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_highlightChanged);
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    // Under a remote's focus the band's edge goes solid.
    final ring =
        _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return Focus(
      focusNode: _focus,
      autofocus: widget.autofocus,
      onKeyEvent: _key,
      onFocusChange: (on) => setState(() => _focused = on),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The band the chosen language sits in.
            Container(
              height: _extent,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Sig.blue.withValues(alpha: ring ? 0.16 : 0.1),
                borderRadius: BorderRadius.circular(Radii.md + 2),
                border: Border.all(
                  color: ring ? Sig.blue : Sig.blue.withValues(alpha: 0.35),
                  width: ring ? 3 : 1,
                ),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 18),
              child: const Icon(PhBold.check, color: Sig.blue, size: 20),
            ),
            ListWheelScrollView.useDelegate(
              controller: _scroll,
              itemExtent: _extent,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 2.6,
              perspective: 0.002,
              overAndUnderCenterOpacity: 0.4,
              onSelectedItemChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _current = i);
                widget.onChanged(languages[i].code);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: languages.length,
                builder: (context, i) {
                  final l = languages[i];
                  final chosen = i == _current;
                  return GestureDetector(
                    onTap: () => _scroll.animateToItem(
                      i,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: Semantics(
                      button: true,
                      selected: chosen,
                      label: l.name,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: motion(context, 150),
                              style: sora(
                                chosen ? 22 : 19,
                                weight: chosen
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: chosen ? s.ink : s.muted,
                              ),
                              child: Text(l.name),
                            ),
                            if (l.english != l.name)
                              Text(
                                l.english,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: s.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings › Language: the same wheel in a sheet; the app follows as it
/// turns.
Future<void> showLanguagePicker(BuildContext context) => showSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (sheet) {
    final c = LinksyScope.read(sheet);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sheet.l10n.settingsLanguage,
              style: sora(21, color: Sig.of(sheet).ink),
            ),
            const SizedBox(height: 8),
            LanguageWheel(
              height: 300,
              selected: c.locale.value.languageCode,
              onChanged: c.setLanguage,
              onPicked: () => Navigator.of(sheet).pop(),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            SigButton(
              label: sheet.l10n.languageDone,
              expand: true,
              onTap: () => Navigator.of(sheet).pop(),
            ),
          ],
        ),
      ),
    );
  },
);
