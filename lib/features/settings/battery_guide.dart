import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import 'settings_kit.dart';
import 'settings_pages.dart';

/// What to change so Android doesn't close Linksy in the background, for the
/// phone's maker: some close apps to save battery whatever Android says.
class BatteryGuide extends StatelessWidget {
  const BatteryGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final s = Sig.of(context);
    final maker = makerName(c.maker);
    return SettingsPage(
      title: l.batteryGuide,
      backLabel: l.settingsConnection,
      children: [
        SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.batteryIntro(maker),
                style: TextStyle(color: s.muted, fontSize: 14.5, height: 1.4),
              ),
              const SizedBox(height: 18),
              NumberedSteps(batterySteps(l, c.maker)),
              const SizedBox(height: 20),
              SettingsPill(
                icon: Ph.gearSix,
                label: l.commonOpenAppInfo,
                onTap: LinksyPlatform.openAppInfo,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Text(
            l.batteryNames,
            style: TextStyle(color: s.faint, fontSize: 13, height: 1.35),
          ),
        ),
      ],
    );
  }
}

/// The steps for phones by [maker] (`Build.MANUFACTURER`), most important
/// first; staying on in Linksy itself last.
List<String> batterySteps(AppLocalizations l, String maker) => [
  ...switch (maker.toLowerCase()) {
    'xiaomi' ||
    'redmi' ||
    'poco' => [l.batteryAutostart, l.batteryXiaomiSaver, l.batteryLockRecents],
    'samsung' => [l.batterySamsungUnrestricted, l.batterySamsungSleeping],
    'oppo' ||
    'realme' ||
    'oneplus' => [l.batteryOppoBackground, l.batteryLockRecents],
    'vivo' || 'iqoo' => [
      l.batteryVivoBackground,
      l.batteryAutostart,
      l.batteryLockRecents,
    ],
    'huawei' || 'honor' => [l.batteryHuaweiLaunch, l.batteryLockRecents],
    _ => [l.batteryUnrestricted],
  },
  l.batteryKeepRunning,
];

/// The maker as it writes its own name.
String makerName(String maker) =>
    const {
      'samsung': 'Samsung',
      'xiaomi': 'Xiaomi',
      'redmi': 'Redmi',
      'poco': 'POCO',
      'oppo': 'OPPO',
      'oneplus': 'OnePlus',
      'vivo': 'vivo',
      'iqoo': 'iQOO',
      'huawei': 'HUAWEI',
      'honor': 'HONOR',
      'google': 'Google',
      'motorola': 'Motorola',
    }[maker.toLowerCase()] ??
    maker;
