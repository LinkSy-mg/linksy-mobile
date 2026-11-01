import 'dart:typed_data';

import '../ui/l10n.dart';
import 'models.dart';

/// What the app needs from a Linksy node. The real implementation wraps
/// `linksy_core::Node` through flutter_rust_bridge (see `docs/protocol.md` §3 and §5
/// in linksy-desktop); [DemoNode] stands in until that bridge exists.
abstract interface class LinksyNode {
  DeviceInfo get info;

  /// Every event from the node. Consent questions (pairing, incoming files)
  /// carry an id that is answered with [respond].
  Stream<LinksyEvent> get events;

  Future<List<DeviceView>> devices();

  Future<void> pairDevice(String id);

  /// Pair by address (`ip:port`, default port 47200) when discovery is blocked.
  Future<void> pairAddress(String address);

  /// Pair with a scanned `linksy://pair?…` invite (§4.7).
  Future<void> pairWithInvite(String uri);

  Future<void> respond(String requestId, {required bool accept});

  /// Accepts or turns down a `display` request, giving this phone's landscape
  /// size so the computer makes the monitor in its shape (§4.8).
  Future<void> respondDisplay(
    String requestId, {
    required bool accept,
    required int width,
    required int height,
  });

  /// Returns the transfer id.
  Future<String> sendFiles(String id, List<String> paths);

  Future<void> cancel(String transferId);

  Future<void> sendClipboard(String id, String text);

  Future<void> notify(String id, String title, String body);

  /// "Open on PC": asks [id] to open an `http(s)` [url] in its browser.
  Future<void> openUrl(String id, String url);

  /// Tells [id] this phone's battery.
  Future<void> sendBattery(String id, Battery battery);

  /// "Find my computer": makes [id] ring, or stops it.
  Future<void> ring(String id, {required bool on});

  /// Touchpad and keyboard: asks [id] for an `input` session; returns its id.
  Future<String> startInput(String id);

  /// Watch [id]'s screen ([control]: and drive it). Its user picks the
  /// screen there ([choose]: again, not the one picked last time). Returns
  /// the session id.
  Future<String> startView(
    String id, {
    required bool control,
    bool choose = false,
  });

  /// Framed input messages into a session. False once it has ended.
  Future<bool> sessionWrite(String session, Uint8List bytes);

  /// Ask [id] for its players while [on] (`MediaStateReceived` events).
  Future<void> watchMedia(String id, {required bool on});

  /// `{"action": "play_pause"}` and so on, for [player] on [id].
  Future<void> mediaCommand(
    String id,
    String player,
    Map<String, Object> command,
  );

  /// Ask [id] for its volume while [on] (`VolumeStateReceived` events).
  Future<void> watchVolume(String id, {required bool on});

  /// [id]'s volume: [level] from 0 to 1, [muted], or both.
  Future<void> setVolume(String id, {double? level, bool? muted});

  /// `ringing`, `active` or `idle`.
  Future<void> sendCallState(String id, String state);

  /// A step of a direct link this phone hosts, to [id] (docs/protocol.md
  /// §4.17): `{'type': 'invite', 'address': ...}`, `connecting`, `up` with
  /// `ip` and `port`, or `end` with a `reason`.
  Future<void> directSend(String id, Map<String, Object?> step);

  /// This phone's networks changed: check the links, dial again, tell iroh
  /// (docs/protocol.md §4.13).
  void networkChanged();

  /// Phone to phone: this phone joined [id]'s group, and [address]
  /// (`ip:port`) is where its Linksy is on it.
  Future<void> directDial(String id, String address);

  /// Set up a direct link with [id] now (testing).
  Future<void> directLink(String id);

  /// The port this node listens on.
  int get port;

  /// Photo auto-import into [id]'s picture library; returns the transfer id.
  Future<String> importFiles(String id, List<String> paths);

  /// This phone's own picture (base64 JPEG, ≤ 128 KiB) for [id] to show.
  Future<void> sendPicture(String id, String image);

  /// Ask [id] for its clipboard text as it changes, while [on].
  Future<void> watchClipboard(String id, {required bool on});

  /// Puts one file (≤ 10 MiB) on [id]'s clipboard; returns the transfer id.
  Future<String> sendClipboardFile(String id, String path);

  /// Answers a locate request with a fix.
  Future<void> sendLocation(
    String id, {
    required double lat,
    required double lon,
    double? accuracyM,
    required DateTime at,
  });

  /// Answers a locate request with why not.
  Future<void> refuseLocation(String id, String reason);

  /// Allow everything from away for [id] (screens, files, camera…).
  Future<void> setAwayAll(String id, {required bool on});

  /// Connect to [id] over the internet now.
  Future<void> connectAway(String id);

  /// Dials a paired computer at [address] (the USB cable's bridge).
  Future<void> connectAddress(String address);

  /// Opens a terminal on computer [id] (§4.15) with the code its user set
  /// there, or reattaches to [resume]. Throws [TerminalRefused] when the
  /// computer says no.
  Future<TerminalChannel> openTerminal(
    String id, {
    required String code,
    required int cols,
    required int rows,
    String? resume,
  });

  /// The terminals still running on [id] for this phone.
  Future<List<RemoteTerminal>> terminals(String id);

  Future<NodeSettings> settings();

  Future<void> updateSettings(NodeSettings settings);

  Future<void> forget(String id);

  /// Findable by devices that aren't paired, while Add Device is open
  /// (docs/protocol.md §4.16). Ends by itself after 5 minutes.
  void pairingMode(bool on);

  /// Turns down a session this phone can't do at all, so the other device
  /// says "can't" instead of "didn't allow it".
  Future<void> declineUnsupported(String request);

  /// Stops sharing into a media session from this side.
  Future<void> endSession(String session);

  Future<void> shutdown();
}

/// Default QUIC port of a Linksy device.
const defaultPort = 47200;

/// Largest clipboard text the protocol carries (§4.5).
const maxClipboardBytes = 256 * 1024;

/// A failure worth showing to the user as is, naming the device in plain words.
class LinksyException implements Exception {
  const LinksyException(this.message, {this.kind = ''});
  final String message;

  /// The core's error kind (`not_paired`, `timeout`, …), when it came from
  /// the core.
  final String kind;

  @override
  String toString() => message;
}

/// A computer turned a terminal down, saying why.
class TerminalRefused extends LinksyException {
  /// From the core's error: `refused:code:3`, `refused:locked:`, `declined`,
  /// `unsupported`, `not_from_away`. Null for any other error.
  static TerminalRefused? parse(String error, String name) {
    final parts = error.split(':');
    final reason = switch (parts.first) {
      'refused' when parts.length > 1 => switch (parts[1]) {
        'code' => TerminalRefusal.code,
        'locked' => TerminalRefusal.locked,
        'off' => TerminalRefusal.off,
        'limit' => TerminalRefusal.limit,
        'away' => TerminalRefusal.away,
        _ => TerminalRefusal.unsupported,
      },
      'declined' => TerminalRefusal.declined,
      'unsupported' => TerminalRefusal.unsupported,
      'not_from_away' => TerminalRefusal.away,
      _ => null,
    };
    if (reason == null) return null;
    final tries = parts.length > 2 ? int.tryParse(parts[2]) : null;
    return TerminalRefused(reason, triesLeft: tries, name: name);
  }

  TerminalRefused(this.reason, {this.triesLeft, String? name})
    : super(_say(reason, triesLeft, name ?? tr.terminalRefusedComputer));

  final TerminalRefusal reason;
  final int? triesLeft;

  static String _say(TerminalRefusal reason, int? tries, String name) =>
      switch (reason) {
        TerminalRefusal.code =>
          tries == null
              ? tr.terminalRefusedCode
              : tr.terminalRefusedCodeTries(tries),
        TerminalRefusal.locked => tr.terminalRefusedLocked(name),
        TerminalRefusal.off => tr.terminalRefusedOff(name),
        TerminalRefusal.away => tr.terminalRefusedAway(name),
        TerminalRefusal.unsupported => tr.terminalRefusedUnsupported(name),
        TerminalRefusal.limit => tr.terminalRefusedLimit(name),
        TerminalRefusal.declined => tr.terminalRefusedDeclined(name),
      };
}
