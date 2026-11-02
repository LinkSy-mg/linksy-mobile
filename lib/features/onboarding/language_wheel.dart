import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../app/scope.dart';
import '../../ui/sig.dart';

/// The 10 languages on a wheel: each in its own name, the English one
/// under it, the one in the middle chosen. Scrolling, or tapping one, picks.
class LanguageWheel extends StatefulWidget {
  const LanguageWheel({
    super.key,
    required this.selected,
    required this.onChanged,
    this.height = 340,
  });

  final String selected;
  final ValueChanged<String> onChanged;
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

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The band the chosen language sits in.
          Container(
            height: _extent,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Sig.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Radii.md + 2),
              border: Border.all(color: Sig.blue.withValues(alpha: 0.35)),
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
                              style: TextStyle(fontSize: 12.5, color: s.muted),
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
    );
  }
}

/// Settings › Language: the same wheel in a sheet; the app follows as it
/// turns.
Future<void> showLanguagePicker(BuildContext context) =>
    showModalBottomSheet<void>(
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
