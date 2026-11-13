/// This phone's networks as the last snapshot from Android had them, to tell
/// a change that can take a link away from one that can't.
///
/// Android calls back for a lot that leaves every link where it is: a
/// network's DNS servers, routes or MTU, mobile data's link details, an IPv6
/// address added beside the others, and every network once more when the
/// watcher registers. Each of those used to make the core probe every link on
/// the network and drop the ones that didn't answer within 2 s
/// (`Node::network_changed`), which a busy or sleepy link can miss. What
/// counts here: a network lost or come, an address gone, the default network
/// moved (traffic not tied to a network follows it).
class NetworkState {
  final _addresses = <String, Set<String>>{};
  final _kinds = <String, String>{};
  String? _default;
  bool _primed = false;

  /// The frequency this phone's Wi-Fi is on, when it's connected.
  int? wifiMhz;

  /// Takes a snapshot (`networks`: `id`, `kind`, `addresses`; `default`;
  /// `wifiMhz`) and says what changed that a link may have been using, in
  /// words for the log, or null when nothing did. The first one is only taken
  /// in: the core starts with the networks as they are.
  String? update(Map<String, Object?> snapshot) {
    final networks = <String, (String, Set<String>)>{
      for (final n in (snapshot['networks'] as List? ?? const []).cast<Map>())
        n['id'] as String: (
          n['kind'] as String? ?? 'other',
          {
            for (final a
                in (n['addresses'] as List? ?? const []).cast<String>())
              if (!_linkLocal(a)) a,
          },
        ),
    };
    final defaultNow = snapshot['default'] as String?;
    wifiMhz = snapshot['wifiMhz'] as int?;
    final changes = <String>[];
    if (_primed) {
      for (final id in _addresses.keys) {
        final was = _addresses[id]!;
        final now = networks[id]?.$2;
        if (now == null) {
          if (was.isNotEmpty) changes.add('${_name(_kinds[id])} lost');
        } else if (was.isEmpty && now.isNotEmpty) {
          changes.add('${_name(networks[id]!.$1)} came');
        } else if (was.difference(now).isNotEmpty) {
          changes.add('${_name(networks[id]!.$1)} addresses changed');
        }
      }
      for (final MapEntry(key: id, value: (kind, now)) in networks.entries) {
        if (!_addresses.containsKey(id) && now.isNotEmpty) {
          changes.add('${_name(kind)} came');
        }
      }
      if (defaultNow != _default) {
        changes.add(
          defaultNow == null
              ? 'no default network'
              : 'default now ${_name(networks[defaultNow]?.$1)}',
        );
      }
    }
    _primed = true;
    _addresses
      ..clear()
      ..addAll({for (final e in networks.entries) e.key: e.value.$2});
    _kinds
      ..clear()
      ..addAll({for (final e in networks.entries) e.key: e.value.$1});
    _default = defaultNow;
    return changes.isEmpty ? null : changes.join(', ');
  }

  /// IPv6 link-local (fe80::/10): every interface has one, nothing dials it.
  static bool _linkLocal(String address) {
    final a = address.toLowerCase();
    return a.startsWith('fe8') ||
        a.startsWith('fe9') ||
        a.startsWith('fea') ||
        a.startsWith('feb');
  }

  static String _name(String? kind) => switch (kind) {
    'wifi' => 'Wi-Fi',
    'mobile' => 'mobile data',
    'ethernet' => 'Ethernet',
    'vpn' => 'VPN',
    _ => 'a network',
  };
}
