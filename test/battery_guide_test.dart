import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/features/settings/battery_guide.dart';
import 'package:linksy/l10n/app_localizations_en.dart';

void main() {
  final l = AppLocalizationsEn();

  test('each maker gets its own steps, then Keep running last', () {
    expect(batterySteps(l, 'Xiaomi'), [
      l.batteryAutostart,
      l.batteryXiaomiSaver,
      l.batteryLockRecents,
      l.batteryKeepRunning,
    ]);
    expect(batterySteps(l, 'realme').first, l.batteryOppoBackground);
    expect(batterySteps(l, 'OnePlus').first, l.batteryOppoBackground);
    expect(batterySteps(l, 'samsung').first, l.batterySamsungUnrestricted);
    expect(batterySteps(l, 'HONOR').first, l.batteryHuaweiLaunch);
    expect(batterySteps(l, 'Google'), [
      l.batteryUnrestricted,
      l.batteryKeepRunning,
    ]);
  });

  test('makers are named as they write themselves', () {
    expect(makerName('samsung'), 'Samsung');
    expect(makerName('realme'), 'realme');
    expect(makerName('Fairphone'), 'Fairphone');
  });
}
