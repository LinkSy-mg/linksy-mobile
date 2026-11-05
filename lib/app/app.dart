import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/invite.dart';
import '../core/models.dart';
import '../features/device/device_screen.dart';
import '../features/devices/home_screen.dart';
import '../features/news/whats_new.dart';
import '../features/pairing/pairing_flows.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/ring/ring_screen.dart';
import '../features/settings/turn_on.dart';
import '../features/share/share_sheet.dart';
import '../features/sharing/display_screen.dart';
import '../features/sharing/sharing.dart';
import '../features/sharing/webcam_screen.dart';
import '../features/transfer/incoming_sheet.dart';
import '../ui/icons.dart';
import '../ui/l10n.dart';
import '../ui/sig.dart';
import 'launch_intro.dart';
import 'linksy_controller.dart';
import 'platform.dart';
import 'scope.dart';

class LinksyApp extends StatefulWidget {
  const LinksyApp({super.key, required this.controller});

  final LinksyController controller;

  @override
  State<LinksyApp> createState() => _LinksyAppState();
}

class _LinksyAppState extends State<LinksyApp> {
  final _navigator = GlobalKey<NavigatorState>();
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<LinksyEvent>? _prompts;
  StreamSubscription<UsbNews>? _usb;
  StreamSubscription<String>? _links;
  StreamSubscription<SharedIn>? _shares;
  StreamSubscription<String>? _webcams;
  StreamSubscription<void>? _turnOns;

  /// The pairing dialog on screen, so a decline from the other side closes it.
  String? _openPairing;

  @override
  void initState() {
    super.initState();
    _prompts = widget.controller.prompts.listen(_onPrompt);
    _usb = widget.controller.usbNews.listen(_onUsb);
    // A pairing link opened the app (the desktop's QR code scanned with the
    // camera app), or arrives while it runs.
    _links = LinksyPlatform.links.listen(_pairWith);
    LinksyPlatform.takeLink().then((link) {
      if (link != null) _pairWith(link);
    });
    // "Share → Linksy" from another app, before or while the app runs.
    _shares = LinksyPlatform.shares.listen(_shareOut);
    // The webcam notification opens its controls.
    _webcams = LinksyPlatform.openWebcam.listen((session) {
      final share = widget.controller.sharing[session];
      if (share != null) _openWebcam(share);
    });
    LinksyPlatform.takeShare().then((shared) {
      if (shared != null) _shareOut(shared);
    });
    // A computer's ask, from its notification.
    _turnOns = LinksyPlatform.turnOnAsks.listen((_) => _takeTurnOn());
    _takeTurnOn();
    // First run: the language, then what Linksy may do.
    if (!widget.controller.onboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // In place, not sliding over a home that was never seen.
        _navigator.currentState?.push(
          PageRouteBuilder<void>(
            fullscreenDialog: true,
            transitionDuration: Duration.zero,
            pageBuilder: (_, _, _) => const OnboardingScreen(),
            // Done, it fades into home.
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _whatsNew());
  }

  /// The first time a new version opens: what it brings.
  Future<void> _whatsNew() async {
    final version = (await LinksyPlatform.appVersion())?.split(' ').first;
    if (version == null) return;
    final list = toShow(widget.controller, version);
    final context = _navigator.currentContext;
    if (list.isEmpty || context == null || !context.mounted) return;
    await showWhatsNew(context, version, list);
  }

  @override
  void dispose() {
    _prompts?.cancel();
    _usb?.cancel();
    _links?.cancel();
    _shares?.cancel();
    _webcams?.cancel();
    _turnOns?.cancel();
    super.dispose();
  }

  /// A computer asks for its Inbox or Gallery; from a notification it may be
  /// on by now.
  Future<void> _takeTurnOn() async {
    final ask = await LinksyPlatform.takeTurnOn();
    if (ask != null) await _askTurnOn(ask.$1, ask.$2);
  }

  Future<void> _askTurnOn(String computer, String feature) async {
    final c = widget.controller;
    await c.accessRead;
    await c.refreshAccess();
    final context = _navigator.currentContext;
    if (c.isTurnedOn(feature) != false || context == null) return;
    if (context.mounted) await askTurnOn(context, computer, feature);
  }

  Future<void> _pairWith(String link) async {
    final invite = Invite.tryParse(link);
    if (invite == null) {
      _say(tr.appInvalidPairingLink);
      return;
    }
    _say(
      invite.name.isEmpty
          ? tr.pairingWithOtherDevice
          : tr.pairingWith(invite.name),
    );
    final error = await widget.controller.pairWithInvite(link);
    if (error != null) _say(error);
  }

  Future<void> _shareOut(SharedIn shared) async {
    final context = _navigator.currentContext;
    if (context == null) return;
    // A device picked in Android's share sheet: no need to ask which.
    final to = shared.device;
    if (to != null && widget.controller.device(to)?.trusted == true) {
      final message = await sendShared(widget.controller, to, shared);
      if (message != null) _say(message);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ShareSheet(shared: shared),
    );
  }

  void _openWebcam(SessionStarted share) => _navigator.currentState?.push(
    MaterialPageRoute<void>(builder: (_) => WebcamScreen(share: share)),
  );

  Future<void> _onUsb(UsbNews news) async {
    switch (news) {
      case UsbDialing():
        _say(tr.usbConnecting);
      case UsbConnected(:final name, :final id):
        _say(tr.usbConnectedTo(name));
        // From the home screen, that computer's page, which says "USB cable".
        final navigator = _navigator.currentState;
        if (id != null && navigator != null && !navigator.canPop()) {
          unawaited(
            navigator.push(
              MaterialPageRoute<void>(
                builder: (_) => DeviceScreen(deviceId: id),
              ),
            ),
          );
        }
      case UsbPairOffer(:final address):
        final context = _navigator.currentContext;
        if (context == null) return;
        final pair = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            icon: const Icon(Ph.usb),
            title: Text(dialog.l10n.usbPairTitle),
            content: Text(dialog.l10n.usbPairBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialog).pop(false),
                child: Text(dialog.l10n.commonNotNow),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialog).pop(true),
                child: Text(dialog.l10n.usbPairAction),
              ),
            ],
          ),
        );
        if (pair != true) return;
        final error = await widget.controller.pairOverCable(address);
        if (error != null) _say(error);
    }
  }

  /// A snack bar; [icon] in cyan for what came in, so it reads at a glance.
  void _say(String text, {IconData? icon}) => _messenger.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: icon == null
            ? Text(text)
            : Row(
                children: [
                  Icon(icon, color: Sig.cyan, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text)),
                ],
              ),
      ),
    );

  /// A ping: two short buzzes, like a knock.
  static Future<void> _knock() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.mediumImpact();
  }

  void _onPrompt(LinksyEvent e) {
    final context = _navigator.currentContext;
    if (context == null) return;
    switch (e) {
      case PairingRequest():
        _openPairing = e.request;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PairingDialog(request: e),
        ).whenComplete(() {
          if (_openPairing == e.request) _openPairing = null;
        });
      case PairingFailed(:final device, :final reason):
        if (_openPairing != null) {
          _openPairing = null;
          _navigator.currentState?.pop();
        }
        _say(
          device == null
              ? tr.appPairingFailed(reason)
              : tr.appCouldntPair(device.name, reason),
        );
      case Paired(:final device):
        _say(tr.appPairedWith(device.name));
      case TurnOnRequested(:final from, :final feature):
        _askTurnOn(from.name, feature);
      case SessionStarted(kind: SessionKind.camera) when e.sharing:
        _openWebcam(e);
      case SessionStarted() when !e.sharing && e.kind != SessionKind.input:
        _navigator.currentState?.push(
          MaterialPageRoute<void>(builder: (_) => DisplayScreen(session: e)),
        );
      case SessionRequest():
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SessionRequestDialog(request: e),
        );
      case TransferRequest():
        HapticFeedback.lightImpact();
        showModalBottomSheet<void>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => IncomingFilesSheet(request: e),
        );
      case NotificationReceived(:final from, :final title, :final body):
        _knock();
        // A ping's body only says who it's from, which the line says first.
        _say(
          tr.appNotification(
            from.name,
            body.isEmpty || body.contains(from.name) ? title : body,
          ),
          icon: Ph.bellRinging,
        );
      case ClipboardReceived(:final from):
        HapticFeedback.lightImpact();
        _say(tr.appCopiedText(from.name), icon: Ph.clipboardText);
      case ClipboardFileReceived(:final from, :final path):
        HapticFeedback.lightImpact();
        _say(
          tr.appCopiedFile(path.split('/').last, from.name),
          icon: Ph.clipboardText,
        );
      case OpenUrlReceived():
        HapticFeedback.lightImpact();
        showDialog<void>(
          context: context,
          builder: (_) => LinkReceivedDialog(event: e),
        );
      case RingRequested(:final from, on: true):
        _navigator.currentState?.push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => RingScreen(from: from),
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => LinksyScope(
    controller: widget.controller,
    child: ListenableBuilder(
      listenable: Listenable.merge([
        widget.controller.locale,
        widget.controller.themeMode,
        widget.controller.reduceMotion,
      ]),
      builder: (context, _) => MaterialApp(
        title: 'Linksy',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigator,
        scaffoldMessengerKey: _messenger,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: widget.controller.themeMode.value,
        locale: widget.controller.locale.value,
        supportedLocales: [for (final l in languages) Locale(l.code)],
        localizationsDelegates: localizationsDelegates,
        // The launch intro over everything, until the mark has landed; and
        // Reduce motion, read like the phone's own setting.
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              disableAnimations:
                  media.disableAnimations ||
                  widget.controller.reduceMotion.value,
            ),
            child: Stack(
              children: [
                child!,
                LaunchIntro(plays: widget.controller.onboarded),
              ],
            ),
          );
        },
        home: const HomeScreen(),
      ),
    ),
  );
}

/// Shown instead of the app when this phone's node can't start.
class StartupFailedApp extends StatelessWidget {
  const StartupFailedApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    home: Builder(
      builder: (context) {
        final s = Sig.of(context);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tr.appCouldntStart,
                    style: sora(24, color: s.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(color: s.muted, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
