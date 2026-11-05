import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/models.dart';
import 'package:linksy/features/settings/doctor.dart';

void main() {
  ConnectionFacts facts({
    bool wifi = true,
    bool vpn = false,
    bool batteryFree = true,
    bool powerSave = false,
    bool dataSaver = false,
    bool heard = true,
  }) => ConnectionFacts(
    wifi: wifi,
    vpn: vpn,
    batteryFree: batteryFree,
    powerSave: powerSave,
    dataSaver: dataSaver,
    heard: heard,
  );

  test('a healthy phone has nothing to say', () {
    expect(findingsOf(facts()), isEmpty);
  });

  test('no Wi-Fi explains hearing nobody', () {
    expect(findingsOf(facts(wifi: false, heard: false)), [Finding.wifi]);
  });

  test('hearing nobody on Wi-Fi comes before the rest', () {
    expect(findingsOf(facts(heard: false, vpn: true, batteryFree: false)), [
      Finding.heard,
      Finding.vpn,
      Finding.battery,
    ]);
  });

  group('which plugged-in phone is this one', () {
    const pixel = PluggedPhone(
      key: 'a',
      manufacturer: 'Google',
      product: 'Pixel 9',
      state: 'plugged',
    );
    const other = PluggedPhone(
      key: 'b',
      manufacturer: 'Samsung',
      product: 'SM-A055',
      state: 'failed',
    );

    test('its maker and model, whatever the case', () {
      expect(usbKeyFor([other, pixel], 'google', 'PIXEL 9'), 'a');
    });

    test('the only one, when the names differ', () {
      expect(usbKeyFor([other], 'Google', 'Pixel 9'), 'b');
    });

    test('nothing to guess between two strangers', () {
      expect(usbKeyFor([pixel, other], 'Xiaomi', 'Mi 11'), isNull);
    });

    test('not one on the cable already', () {
      const on = PluggedPhone(
        key: 'c',
        manufacturer: 'Google',
        product: 'Pixel 9',
        state: 'accessory',
      );
      expect(usbKeyFor([on], 'Google', 'Pixel 9'), isNull);
    });
  });
}
