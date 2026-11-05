import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app/linksy_controller.dart';
import '../../core/models.dart';
import 'selection.dart';

/// Choosing what to send to one phone: what's chosen, how it would go, and
/// what the other phone says. Fills in as the user chooses, so Send is instant.
class SendFlow extends ChangeNotifier {
  SendFlow(this.controller, this.deviceId) {
    selection.addListener(_changed);
  }

  final LinksyController controller;
  final String deviceId;
  final selection = SendSelection();

  /// How it would go, for the selection as it stands.
  SendPlan? plan;

  /// The other phone's latest answer; null from one that can't give any.
  PreflightReply? reply;

  Timer? _prepare;
  bool _disposed = false;

  /// At most this often, as the protocol asks (§4.22).
  static const prepareEvery = Duration(milliseconds: 500);

  void _changed() {
    _prepare?.cancel();
    plan = selection.isEmpty
        ? null
        : controller.planSend(deviceId, selection.bytes);
    if (!selection.isEmpty) {
      _prepare = Timer(prepareEvery, () async {
        final ready = await controller.prepareSend(deviceId, selection.bytes);
        if (_disposed || selection.isEmpty) return;
        plan = ready ?? plan;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  /// Asks the other phone, for the marks on apps or at Send.
  Future<void> ask(List<AppProbe> probes) async {
    reply = await controller.preflight(
      deviceId,
      selection.bytes,
      selection.fileCount,
      probes,
    );
    if (!_disposed) notifyListeners();
  }

  List<SendWarning> get warnings => sendWarnings(
    reply: reply,
    bytes: selection.bytes,
    apps: selection.apps.isNotEmpty,
  );

  bool get blocked => warnings.any((w) => w is NoRoom);

  /// One last question with the real total, whether it's still fine to go.
  Future<bool> check() async {
    await ask([for (final a in selection.apps) a.probe]);
    return !blocked;
  }

  /// Everything as one offer; a message if it didn't go.
  Future<String?> send() async {
    final failed = await controller.sendSelection(deviceId, selection);
    if (failed == null) selection.clear();
    return failed;
  }

  @override
  void dispose() {
    _disposed = true;
    _prepare?.cancel();
    selection.dispose();
    super.dispose();
  }
}
