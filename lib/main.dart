import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/activity.dart';
import 'app/app.dart';
import 'app/app_update.dart';
import 'app/linksy_controller.dart';
import 'app/platform.dart';
import 'core/demo_node.dart';
import 'core/linksy_node.dart';
import 'core/rust_node.dart';
import 'core/service_info.dart';
import 'core/updates.dart';
import 'ui/l10n.dart';

/// `--dart-define=LINKSY_DEMO=true` runs on made-up devices, for UI work.
const _demo = bool.fromEnvironment('LINKSY_DEMO');

/// What this phone does for computers (docs/protocol.md §4.10). Not `control`,
/// `notifications` or `sms` (each needs a permission that gets sideloaded
/// apps blocked at install), nor `media_state` or `clipboard_watch`
/// (Android doesn't let apps watch either in the background).
const _features = [
  'files',
  'clipboard',
  'open_url',
  'battery',
  'ring',
  'media_remote',
  'call_state',
  'heartbeat',
  'import',
  'fs',
  'input',
  'screen',
  'display',
  'camera',
  'watch',
  'clipboard_file',
  'microphone',
  'picture',
  'locate',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A few device pictures and covers: Flutter's 100 MB default is far more
  // than the app shows at once (#3).
  PaintingBinding.instance.imageCache.maximumSizeBytes = 24 << 20;
  // Day and month names in every language the app speaks.
  await initializeDateFormatting();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final paths = (await LinksyPlatform.paths())!;
  final support = Directory(paths.support);
  final received = Directory('${paths.external ?? paths.support}/Received')
    ..createSync(recursive: true);
  final name = await LinksyPlatform.deviceName();

  final service = ServiceInfoStore(File('${support.path}/service.json'));

  final prefs = await LinksyPlatform.prefs();
  // Direct links (§4.17), unless turned off in Settings: a Wi-Fi Direct
  // group of its own for big transfers, or another phone's to join
  final direct = prefs['direct'] != 'off' && await LinksyPlatform.directHost();

  final LinksyNode node;
  if (_demo) {
    node = DemoNode(name: name, downloadDir: received.path);
  } else {
    try {
      node = await RustNode.start(
        // Holds this phone's private key: app-private storage only.
        dataDir: '${support.path}/node',
        downloadDir: received.path,
        name: name,
        features: [
          ..._features,
          if (direct) ...['direct_host', 'direct_join', 'direct_group'],
        ],
        away: true,
        relay: service.cached()?.relay ?? defaultRelay,
      );
    } on Object catch (e) {
      // Before the controller knows the chosen language: the phone's own.
      useLocale(resolveLocale(null));
      runApp(StartupFailedApp(message: '$e'));
      return;
    }
  }

  final controller = LinksyController(
    node,
    ActivityStore(File('${support.path}/history.json')),
    service: service,
    dir: support,
    updates: _demo
        ? null
        : AppUpdate(
            UpdateChecker(File('${support.path}/releases.json')),
            Directory('${support.path}/updates'),
          ),
  );
  // The language and whether setup was done, before the first frame.
  controller.prefs = prefs;
  controller.locale.value = resolveLocale(controller.languageCode);
  useLocale(controller.locale.value);
  controller.themeMode.value = LinksyController.themeFrom(
    controller.prefs['theme'],
  );
  await controller.start();
  runApp(LinksyApp(controller: controller));
}
