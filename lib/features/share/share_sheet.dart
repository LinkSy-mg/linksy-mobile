import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../device/activity_tile.dart' show linkLabel;

/// The first web link in [text], or null. A link shared from a browser comes
/// alone or after the page title.
String? findWebLink(String text) => RegExp(
  r'https?://[^\s<>"]+',
  caseSensitive: false,
).firstMatch(text)?.group(0);

/// "Share → Linksy": pick a paired computer. A link opens in its browser
/// (or goes to its clipboard, as text), other text goes to its clipboard,
/// files are sent.
class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.shared});

  final SharedIn shared;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  /// For a link: open it, or send the text to the clipboard instead.
  late bool _asText = widget.shared.quick;

  /// For one file: onto the computer's clipboard instead of its Downloads.
  bool _toClipboard = false;

  /// One file small enough for a clipboard (≤ 10 MiB, §4.5).
  bool get _clippable => switch (widget.shared) {
    SharedFiles(:final paths) when paths.length == 1 => (() {
      try {
        return File(paths.single).lengthSync() <= 10 * 1024 * 1024;
      } on FileSystemException {
        return false;
      }
    })(),
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final l10n = context.l10n;
    final c = LinksyScope.of(context);
    final shared = widget.shared;
    final link = shared is SharedText ? findWebLink(shared.text) : null;
    final (icon, title, detail) = switch (shared) {
      SharedFiles(:final paths) when _toClipboard => (
        Ph.clipboard,
        l10n.shareSheetPutOnClipboard,
        paths.single.split('/').last,
      ),
      SharedFiles(:final paths) => (
        Ph.files,
        l10n.shareSheetSendFiles(paths.length),
        paths.length == 1 ? paths.single.split('/').last : null,
      ),
      SharedText() when link != null && !_asText => (
        Ph.globe,
        l10n.shareSheetOpenOnComputer,
        linkLabel(link),
      ),
      SharedText(:final text) => (
        Ph.clipboardText,
        l10n.shareSheetSendToClipboard,
        text.trim(),
      ),
    };
    // Only computers that take a file onto their clipboard.
    final devices = _toClipboard
        ? [
            for (final v in c.paired)
              if (v.device.features.contains('clipboard_file')) v,
          ]
        : c.paired;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconCircle(icon: icon, color: Sig.blue, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: sora(20, color: s.ink)),
                      if (detail != null && detail.isNotEmpty)
                        Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: s.muted, fontSize: 13.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (devices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  _toClipboard
                      ? l10n.shareSheetNoClipboardFiles
                      : l10n.shareSheetNoComputers,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.muted, height: 1.4),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final v in devices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SigCard(
                          color: s.raised,
                          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                          radius: Radii.md,
                          onTap: () => _send(v.device.id, link),
                          child: Row(
                            children: [
                              Orb(
                                picture: c.pictureOf(v.device.id),
                                device: v.device,
                                size: 40,
                                presence: v.presence,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.device.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: s.ink,
                                      ),
                                    ),
                                    Text(
                                      linkWords(v),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: s.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                PhBold.arrowRight,
                                color: Sig.blue,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_clippable)
              SigButton(
                label: _toClipboard
                    ? l10n.shareSheetSendFileInstead
                    : l10n.shareSheetClipboardInstead,
                kind: SigButtonKind.quiet,
                expand: true,
                height: 46,
                onTap: () => setState(() => _toClipboard = !_toClipboard),
              ),
            if (link != null)
              SigButton(
                label: _asText
                    ? l10n.shareSheetOpenLinkInstead
                    : l10n.shareSheetSendAsTextInstead,
                kind: SigButtonKind.quiet,
                expand: true,
                height: 46,
                onTap: () => setState(() => _asText = !_asText),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(String deviceId, String? link) async {
    final c = LinksyScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final name = c.device(deviceId)?.device.name;
    Navigator.of(context).pop();
    final shared = widget.shared;
    final (error, done) = switch (shared) {
      SharedFiles(:final paths) when _toClipboard => (
        await c.sendToClipboard(deviceId, paths.single),
        name == null
            ? l10n.shareSheetPuttingOnClipboardUnnamed
            : l10n.shareSheetPuttingOnClipboard(name),
      ),
      SharedFiles(:final paths) => (await c.sendFiles(deviceId, paths), null),
      SharedText() when link != null && !_asText => (
        await c.openUrl(deviceId, link),
        name == null
            ? l10n.shareSheetOpenedUnnamed
            : l10n.shareSheetOpened(name),
      ),
      SharedText(:final text) => (
        await c.sendText(deviceId, text),
        name == null
            ? l10n.shareSheetSentToClipboardUnnamed
            : l10n.shareSheetSentToClipboard(name),
      ),
    };
    final message = error ?? done;
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

/// A share aimed at [deviceId] from Android's share sheet: sent at once, as
/// the sheet would by default (files to Downloads, a link opened, text to the
/// clipboard). Returns what to say: an error, or what happened.
Future<String?> sendShared(
  LinksyController c,
  String deviceId,
  SharedIn shared,
) async {
  final name = c.device(deviceId)?.device.name ?? tr.ctlYourComputer;
  LinksyPlatform.sharedTo(deviceId);
  // Opened by the share itself, Linksy may not have found the device yet:
  // give it a few seconds before trying.
  for (var i = 0; i < 20; i++) {
    final view = c.device(deviceId);
    if (view == null || view.presence != Presence.notNearby) break;
    // Reachable away from home without being found nearby.
    if (view.awayUntil?.isAfter(DateTime.now()) ?? false) break;
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  switch (shared) {
    case SharedFiles(:final paths) when shared.quick:
      return await c.snap(deviceId, paths.single) ?? tr.snapSent(name);
    case SharedFiles(:final paths):
      return c.sendFiles(deviceId, paths);
    case SharedText(:final text) when shared.quick:
      return await c.sendText(deviceId, text) ?? tr.copySent(name);
    case SharedText(:final text):
      final link = findWebLink(text);
      if (link != null) {
        return await c.openUrl(deviceId, link) ?? tr.shareSheetOpened(name);
      }
      return await c.sendText(deviceId, text) ??
          tr.shareSheetSentToClipboard(name);
  }
}

/// "Studio Desktop sent a link": open it here, copy it, or leave it (it's in
/// the device's timeline either way).
class LinkReceivedDialog extends StatelessWidget {
  const LinkReceivedDialog({super.key, required this.event});

  final OpenUrlReceived event;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: IconCircle(icon: Ph.link, color: Sig.incoming, size: 64),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.shareSheetSentALink(event.from.name),
              textAlign: TextAlign.center,
              style: sora(21, color: s.ink, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              linkLabel(event.url),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: s.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            SigButton(
              label: context.l10n.shareSheetOpen,
              icon: Ph.arrowSquareOut,
              expand: true,
              onTap: () async {
                Navigator.of(context).pop();
                await LinksyPlatform.openUrl(event.url);
              },
            ),
            SigButton(
              label: context.l10n.shareSheetCopyLink,
              kind: SigButtonKind.quiet,
              expand: true,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final copied = context.l10n.shareSheetLinkCopied;
                Navigator.of(context).pop();
                await Clipboard.setData(ClipboardData(text: event.url));
                messenger.showSnackBar(SnackBar(content: Text(copied)));
              },
            ),
            SigButton(
              label: context.l10n.commonNotNow,
              kind: SigButtonKind.quiet,
              expand: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
