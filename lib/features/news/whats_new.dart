import 'package:flutter/material.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../core/updates.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// What's New: the few things each version brings, shown once the first time
/// a new version opens, and from Settings any time. Not the changelog: what a
/// person would notice, with a link to the full release notes. A fresh
/// install shows nothing. Like the computer's (linksy-news).
///
/// Each release adds its highlights at the top of [_releases] when it's cut.
class Highlight {
  const Highlight(this.icon, this.title, this.body);
  final IconData icon;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) body;
}

/// Linksy's source, for "Star Linksy on GitHub".
const repo = 'https://github.com/LinkSy-mg/linksy-desktop';

/// At most this many highlights at once, when several versions were skipped.
const _most = 5;

/// Newest first.
final List<(String, List<Highlight>)> _releases = [
  (
    '0.3.3',
    [
      Highlight(
        Ph.squaresFour,
        (l) => l.news033DeckTitle,
        (l) => l.news033DeckBody,
      ),
      Highlight(
        Ph.imagesSquare,
        (l) => l.news033PhotosTitle,
        (l) => l.news033PhotosBody,
      ),
      Highlight(
        Ph.clockCounterClockwise,
        (l) => l.news033MessagesTitle,
        (l) => l.news033MessagesBody,
      ),
    ],
  ),
  (
    '0.3.2',
    [
      Highlight(
        Ph.bellRinging,
        (l) => l.news032NotificationsTitle,
        (l) => l.news032NotificationsBody,
      ),
      Highlight(
        Ph.batteryCharging,
        (l) => l.news032BatteryTitle,
        (l) => l.news032BatteryBody,
      ),
    ],
  ),
  (
    '0.2.9',
    [
      Highlight(
        Ph.deviceMobile,
        (l) => l.news029PhonesTitle,
        (l) => l.news029PhonesBody,
      ),
      Highlight(
        Ph.fileText,
        (l) => l.news029LogsTitle,
        (l) => l.news029LogsBody,
      ),
    ],
  ),
  (
    '0.2.8',
    [
      Highlight(
        PhFill.lightning,
        (l) => l.news028DirectTitle,
        (l) => l.news028DirectBody,
      ),
      Highlight(
        Ph.arrowsDownUp,
        (l) => l.news028BackgroundTitle,
        (l) => l.news028BackgroundBody,
      ),
    ],
  ),
  (
    '0.2.6',
    [
      Highlight(
        Ph.speakerHigh,
        (l) => l.news026VolumeTitle,
        (l) => l.news026VolumeBody,
      ),
      Highlight(
        Ph.arrowsDownUp,
        (l) => l.news026TransfersTitle,
        (l) => l.news026TransfersBody,
      ),
    ],
  ),
  (
    '0.2.5',
    [
      Highlight(
        Ph.musicNotes,
        (l) => l.news025MediaTitle,
        (l) => l.news025MediaBody,
      ),
      Highlight(
        Ph.numpad,
        (l) => l.news025NumbersTitle,
        (l) => l.news025NumbersBody,
      ),
      Highlight(
        Ph.mouseSimple,
        (l) => l.news025RemoteTitle,
        (l) => l.news025RemoteBody,
      ),
    ],
  ),
  (
    '0.2.4',
    [
      Highlight(
        Ph.eyeSlash,
        (l) => l.news024PrivateTitle,
        (l) => l.news024PrivateBody,
      ),
      Highlight(
        Ph.arrowCircleUp,
        (l) => l.news024UpdateTitle,
        (l) => l.news024UpdateBody,
      ),
      Highlight(
        Ph.sparkle,
        (l) => l.news024NewsTitle,
        (l) => l.news024NewsBody,
      ),
    ],
  ),
];

/// The highlights of [version] and the versions after [since] up to it.
List<Highlight> highlights(String version, {String? since}) => [
  for (final (v, list) in _releases)
    if (!isNewer(v, version) && (since == null || isNewer(v, since))) ...list,
].take(_most).toList();

/// What to show the first time [version] opens, once: nothing on a fresh
/// install, else what came since the last version seen. Notes it as seen.
List<Highlight> toShow(LinksyController c, String version) {
  final seen = c.prefs['news_seen'];
  if (seen == version) return const [];
  c.setPref('news_seen', version);
  // Set up before, but no version noted: it came from 0.2.3 or earlier.
  if (seen == null && !c.onboarded) return const [];
  return highlights(version, since: seen ?? _beforeNews);
}

/// The last version without What's New.
const _beforeNews = '0.2.3';

/// The release notes of [version] on GitHub.
String notesUrl(String version) =>
    'https://github.com/LinkSy-mg/linksy-releases/releases/tag/v$version';

Future<void> showWhatsNew(
  BuildContext context,
  String version,
  List<Highlight> list,
) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => WhatsNewScreen(version: version, highlights: list),
  ),
);

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({
    super.key,
    required this.version,
    required this.highlights,
  });

  final String version;
  final List<Highlight> highlights;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            const Center(child: AppIcon(size: 64)),
            const SizedBox(height: 20),
            Text(
              l10n.newsHeading(version),
              textAlign: TextAlign.center,
              style: sora(26, color: s.ink),
            ),
            const SizedBox(height: 28),
            for (final h in highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Sig.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(h.icon, color: Sig.blue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.title(l10n), style: sora(16.5, color: s.ink)),
                          const SizedBox(height: 4),
                          Text(
                            h.body(l10n),
                            style: TextStyle(
                              color: s.muted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Center(
              child: SmallAction(
                label: l10n.newsAllChanges(version),
                onTap: () => LinksyPlatform.openUrl(notesUrl(version)),
              ),
            ),
            const SizedBox(height: 20),
            SigButton(
              label: l10n.newsContinue,
              expand: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 10),
            SigButton(
              label: l10n.newsStar,
              icon: Ph.star,
              kind: SigButtonKind.secondary,
              expand: true,
              onTap: () => LinksyPlatform.openUrl(repo),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.newsStarCaption,
              textAlign: TextAlign.center,
              style: TextStyle(color: s.faint, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
