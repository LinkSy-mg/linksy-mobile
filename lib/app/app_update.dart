import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/updates.dart';
import 'platform.dart';

/// Where Update Now is.
enum UpdatePhase { idle, downloading, installing, failed }

/// Update Now, as on the computer: "Linksy X Is Available" when a newer
/// Android release is out, then download, check and install with one tap
/// and Android's confirmation. Never downloads anything by itself.
class AppUpdate extends ChangeNotifier {
  AppUpdate(this._checker, this._downloads);

  final UpdateChecker? _checker;
  final Directory? _downloads;
  StreamSubscription<String>? _statuses;

  /// This app's version, "0.2.3".
  String? installed;

  /// The newest release, when it's newer than this app.
  AppRelease? available;

  UpdatePhase phase = UpdatePhase.idle;
  double progress = 0;

  /// Why the last try failed: `network`, `unlisted`, `bad_sum`, `allow`, or
  /// the installer's message.
  String? failure;

  Future<void> start() async {
    _statuses = LinksyPlatform.updateStatuses.listen(_onStatus);
    // An APK from before is installed by now, or stale.
    try {
      _downloads?.deleteSync(recursive: true);
    } on Object {
      // Nothing there.
    }
    installed = (await LinksyPlatform.appVersion())?.split(' ').first;
    _offer(_checker?.cached());
    _offer(await _checker?.refresh());
  }

  /// Asks GitHub now (the About page's Check for Updates). Whether one is out.
  Future<bool> check() async {
    _offer(await _checker?.refresh(force: true));
    return available != null;
  }

  void _offer(AppRelease? release) {
    final v = installed;
    if (release == null || v == null) return;
    available = isNewer(release.version, v) ? release : null;
    notifyListeners();
  }

  /// Downloads, checks and installs [available].
  Future<void> run() async {
    final release = available, dir = _downloads;
    if (release == null || dir == null || phase == UpdatePhase.downloading) {
      return;
    }
    if (!await LinksyPlatform.updatesAllowed()) {
      await LinksyPlatform.allowUpdates();
      return _fail('allow');
    }
    phase = UpdatePhase.downloading;
    progress = 0;
    failure = null;
    notifyListeners();
    try {
      final (file, sum) = await downloadUpdate(
        release,
        await LinksyPlatform.abi(),
        dir,
        onProgress: (p) {
          progress = p;
          notifyListeners();
        },
      );
      phase = UpdatePhase.installing;
      notifyListeners();
      await LinksyPlatform.installUpdate(file.path, sum);
    } on UpdateFailed catch (e) {
      _fail(e.reason);
    }
  }

  void _onStatus(String status) {
    if (status == 'cancelled') {
      phase = UpdatePhase.idle;
      notifyListeners();
    } else if (status != 'installed') {
      _fail(status.startsWith('failed:') ? status.substring(7) : status);
    }
  }

  void _fail(String reason) {
    phase = UpdatePhase.failed;
    failure = reason;
    notifyListeners();
  }

  @override
  void dispose() {
    _statuses?.cancel();
    super.dispose();
  }
}
