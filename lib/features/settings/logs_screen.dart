import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/responsive.dart';
import '../../ui/sig.dart';

/// Settings › Logs: this phone and what its Wi-Fi can do, then what happened
/// lately, each with its own Copy for a bug report. Kept on the phone only.
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  /// Label → value, in order; the labels stay English, as in the log.
  Map<String, String> _phone = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = LinksyScope.read(context);
    final version = await LinksyPlatform.appVersion();
    final report = await LinksyPlatform.deviceReport();
    if (!mounted) return;
    setState(
      () => _phone = {
        'Linksy': version ?? '?',
        'ID': c.node.info.shortId,
        ...report,
        'Wi-Fi Direct in Linksy': c.directOn ? 'on' : 'off',
      },
    );
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showMessage(context, context.l10n.logsCopied);
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l = context.l10n;
    final log = LinksyScope.of(context).log;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: log,
          builder: (context, _) {
            // Newest first to read; copied oldest first, as it happened
            final lines = log.lines.reversed.toList();
            return ListView(
              padding: EdgeInsets.fromLTRB(
                readableSide(context),
                8,
                readableSide(context),
                40,
              ),
              children: [
                Row(
                  children: [
                    RoundButton(
                      icon: Ph.arrowLeft,
                      tooltip: l.settingsBack,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
                  child: Text(
                    l.settingsLogs,
                    style: sora(34, weight: FontWeight.w700, color: s.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Ph.lockSimple, size: 16, color: s.muted),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.logsPrivacy,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: s.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SectionLabel(
                  l.logsThisPhone,
                  trailing: _CopyPill(
                    onTap: _phone.isEmpty
                        ? null
                        : () => _copy(
                            _phone.entries
                                .map((e) => '${e.key}: ${e.value}')
                                .join('\n'),
                          ),
                  ),
                ),
                SigCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      for (final (i, e) in _phone.entries.indexed) ...[
                        if (i > 0)
                          Divider(height: 1, thickness: 1, color: s.line),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: TextStyle(fontSize: 14, color: s.muted),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  e.value,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: s.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SectionLabel(
                  l.logsEvents,
                  trailing: _CopyPill(
                    onTap: lines.isEmpty
                        ? null
                        : () => _copy(log.lines.join('\n')),
                  ),
                ),
                SigCard(
                  child: lines.isEmpty
                      ? Text(
                          l.logsEmpty,
                          style: TextStyle(color: s.muted, height: 1.45),
                        )
                      : SelectionArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final line in lines)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: _Line(line),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One log line: the time faint (with the day, when it isn't today), what
/// happened in ink, monospace.
class _Line extends StatelessWidget {
  const _Line(this.line);

  final String line;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final cut = line.indexOf('  ');
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 11.5,
      height: 1.4,
      color: s.ink,
    );
    if (cut < 6) return Text(line, style: style);
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final today = line.startsWith('${two(now.month)}-${two(now.day)} ');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${line.substring(today ? 6 : 0, cut)}  ',
            style: TextStyle(color: s.faint),
          ),
          TextSpan(text: line.substring(cut + 2)),
        ],
      ),
      style: style,
    );
  }
}

class _CopyPill extends StatelessWidget {
  const _CopyPill({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
        decoration: BoxDecoration(
          color: Sig.blue.withValues(alpha: on ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Ph.copy,
              size: 14,
              color: Sig.blue.withValues(alpha: on ? 1 : 0.4),
            ),
            const SizedBox(width: 5),
            Text(
              context.l10n.logsCopy,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: Sig.blue.withValues(alpha: on ? 1 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
