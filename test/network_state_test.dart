import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/network_state.dart';

Map<String, Object?> snap(
  Map<String, (String, List<String>)> networks, {
  String? default_ = '100',
  int? wifiMhz = 5180,
}) => {
  'networks': [
    for (final MapEntry(key: id, value: (kind, addresses)) in networks.entries)
      {'id': id, 'kind': kind, 'addresses': addresses},
  ],
  'default': default_,
  'wifiMhz': wifiMhz,
};

void main() {
  const wifi = ('wifi', ['192.168.1.20', 'fe80::1']);
  const mobile = ('mobile', ['10.20.30.40', '2001:db8::5']);

  test('the first snapshot is only taken in', () {
    final s = NetworkState();
    expect(s.update(snap({'100': wifi, '101': mobile})), isNull);
    expect(s.wifiMhz, 5180);
  });

  test(
    'the same networks again (a registration, DNS, routes) change nothing',
    () {
      final s = NetworkState()..update(snap({'100': wifi, '101': mobile}));
      expect(s.update(snap({'100': wifi, '101': mobile})), isNull);
      expect(s.update(snap({'101': mobile, '100': wifi})), isNull);
    },
  );

  test('an address added beside the others changes nothing', () {
    final s = NetworkState()..update(snap({'100': wifi, '101': mobile}));
    expect(
      s.update(
        snap({
          '100': wifi,
          '101': ('mobile', ['10.20.30.40', '2001:db8::5', '2001:db8::6']),
        }),
      ),
      isNull,
    );
  });

  test('a link-local address coming or going changes nothing', () {
    final s = NetworkState()..update(snap({'100': wifi}));
    expect(
      s.update(
        snap({
          '100': ('wifi', ['192.168.1.20', 'fe80::2']),
        }),
      ),
      isNull,
    );
  });

  test('an address gone is a change, on any network', () {
    final s = NetworkState()..update(snap({'100': wifi, '101': mobile}));
    expect(
      s.update(
        snap({
          '100': wifi,
          '101': ('mobile', ['10.20.30.41', '2001:db8::5']),
        }),
      ),
      'mobile data addresses changed',
    );
    expect(
      s.update(
        snap({
          '100': ('wifi', ['192.168.1.21']),
          '101': ('mobile', ['10.20.30.41', '2001:db8::5']),
        }),
      ),
      'Wi-Fi addresses changed',
    );
  });

  test('Wi-Fi lost, then back', () {
    final s = NetworkState()..update(snap({'100': wifi, '101': mobile}));
    expect(
      s.update(snap({'101': mobile}, default_: '101')),
      'Wi-Fi lost, default now mobile data',
    );
    expect(
      s.update(snap({'102': wifi, '101': mobile}, default_: '102')),
      'Wi-Fi came, default now Wi-Fi',
    );
  });

  test('a network that shows up before its addresses comes once they do', () {
    final s = NetworkState()..update(snap({'100': wifi}));
    expect(s.update(snap({'100': wifi, '101': ('mobile', [])})), isNull);
    expect(s.update(snap({'100': wifi, '101': mobile})), 'mobile data came');
  });

  test('the default network moving is a change', () {
    final s = NetworkState()..update(snap({'100': wifi, '101': mobile}));
    expect(
      s.update(snap({'100': wifi, '101': mobile}, default_: '101')),
      'default now mobile data',
    );
    expect(
      s.update(snap({'100': wifi, '101': mobile}, default_: null)),
      'no default network',
    );
  });
}
