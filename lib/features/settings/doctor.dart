import 'package:flutter/material.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../pairing/pairing_flows.dart';
import 'battery_guide.dart';
import 'settings_kit.dart';

/// What can stand between this phone and its computers.
class ConnectionFacts {
  const ConnectionFacts({
    required this.wifi,
    required this.vpn,
    required this.batteryFree,
    required this.powerSave,
    required this.dataSaver,
    required this.heard,
  });

  final bool wifi;
  final bool vpn;

  /// Android's battery saving leaves Linksy alone.
  final bool batteryFree;
  final bool powerSave;
  final bool dataSaver;

  /// A device answers or announces itself on this network.
  final bool heard;
}

/// What the doctor looks at, the likeliest cause first.
enum Finding { wifi, heard, vpn, battery, powerSave, dataSaver }

/// What's wrong, in the order to fix it. No Wi-Fi explains hearing nobody, so
/// that one isn't said as well.
List<Finding> findingsOf(ConnectionFacts f) => [
  if (!f.wifi) Finding.wifi,
  if (f.wifi && !f.heard) Finding.heard,
  if (f.vpn) Finding.vpn,
  if (!f.batteryFree) Finding.battery,
  if (f.powerSave) Finding.powerSave,
  if (f.dataSaver) Finding.dataSaver,
];

/// "Why can't I see my computer?": says what's in the way in a sentence, with
/// a button where the phone can do something about it.
class ConnectionDoctor extends StatefulWidget {
  const ConnectionDoctor({super.key});

  @override
  State<ConnectionDoctor> createState() => _ConnectionDoctorState();
}

class _ConnectionDoctorState extends State<ConnectionDoctor>
    with WidgetsBindingObserver {
  Map<String, bool>? _facts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from Wi-Fi or VPN settings, maybe fixed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final facts = await LinksyPlatform.connectionFacts();
    if (mounted) setState(() => _facts = facts);
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    final l = context.l10n;
    final facts = _facts;
    if (facts == null) return const Scaffold(body: SizedBox.shrink());
    final found = findingsOf(
      ConnectionFacts(
        wifi: facts['wifi'] ?? true,
        vpn: facts['vpn'] ?? false,
        batteryFree: facts['batteryFree'] ?? true,
        powerSave: facts['powerSave'] ?? false,
        dataSaver: facts['dataSaver'] ?? false,
        heard: c.devices.any((v) => v.connected || v.nearby),
      ),
    );
    return SettingsPage(
      title: l.doctorTitle,
      backLabel: l.settingsConnection,
      children: [
        if (found.isEmpty)
          SigCard(
            child: _Row(
              icon: Ph.shieldCheck,
              color: Sig.cyan,
              title: l.doctorAllGood,
              detail: l.doctorAllGoodDetail,
              action: l.pairingByAddress,
              onAction: () => pairByAddress(context),
            ),
          )
        else
          for (final f in found)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SigCard(child: _finding(context, f)),
            ),
        const SizedBox(height: 6),
        Center(
          child: SmallAction(label: l.doctorCheckAgain, onTap: _check),
        ),
      ],
    );
  }

  Widget _finding(BuildContext context, Finding f) {
    final l = context.l10n;
    final c = LinksyScope.read(context);
    final red = Sig.of(context).red;
    return switch (f) {
      Finding.wifi => _Row(
        icon: Ph.wifiSlash,
        color: red,
        title: l.doctorWifi,
        detail: l.doctorWifiDetail,
        action: l.doctorOpenSettings,
        onAction: () => LinksyPlatform.openSystem('wifi'),
      ),
      Finding.heard => _Row(
        icon: Ph.wifiHigh,
        color: red,
        title: l.doctorHeard,
        detail: l.doctorHeardDetail,
        action: l.pairingByAddress,
        onAction: () => pairByAddress(context),
      ),
      Finding.vpn => _Row(
        icon: Ph.globe,
        color: red,
        title: l.doctorVpn,
        detail: l.doctorVpnDetail,
        action: l.doctorOpenSettings,
        onAction: () => LinksyPlatform.openSystem('vpn'),
      ),
      Finding.battery => _Row(
        icon: Ph.batteryWarning,
        color: red,
        title: l.doctorBattery,
        detail: l.doctorBatteryDetail(makerName(c.maker)),
        action: l.doctorShowHow,
        onAction: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const BatteryGuide())),
      ),
      Finding.powerSave => _Row(
        icon: Ph.batteryWarning,
        color: red,
        title: l.doctorPowerSave,
        detail: l.doctorPowerSaveDetail,
        action: l.doctorOpenSettings,
        onAction: () => LinksyPlatform.openSystem('saver'),
      ),
      Finding.dataSaver => _Row(
        icon: Ph.warningCircle,
        color: red,
        title: l.doctorDataSaver,
        detail: l.doctorDataSaverDetail,
        action: l.doctorOpenSettings,
        onAction: () => LinksyPlatform.openSystem('data'),
      ),
    };
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconCircle(icon: icon, color: color, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: sora(15.5, color: s.ink)),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: s.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SmallAction(label: action, onTap: onAction),
        ),
      ],
    );
  }
}
