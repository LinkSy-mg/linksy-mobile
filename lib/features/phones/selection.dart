import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/models.dart';
import '../../ui/format.dart';

/// A photo or video on this phone.
class PhoneMedia {
  const PhoneMedia({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.taken,
    this.video = false,
  });

  factory PhoneMedia.fromMap(Map<Object?, Object?> m) => PhoneMedia(
    id: m['id'] as int,
    path: m['path'] as String? ?? '',
    name: m['name'] as String? ?? '',
    size: m['size'] as int? ?? 0,
    taken: DateTime.fromMillisecondsSinceEpoch(m['taken'] as int? ?? 0),
    video: m['video'] == true,
  );

  final int id;
  final String path;
  final String name;
  final int size;
  final DateTime taken;
  final bool video;
}

/// A folder of photos, as a filter.
class PhoneAlbum {
  const PhoneAlbum({required this.id, required this.name});

  factory PhoneAlbum.fromMap(Map<Object?, Object?> m) =>
      PhoneAlbum(id: m['id'] as String, name: m['name'] as String? ?? '');

  final String id;
  final String name;
}

/// An app installed here that can travel.
class PhoneApp {
  const PhoneApp({
    required this.package,
    required this.label,
    required this.versionCode,
    required this.versionName,
    required this.signer,
    required this.apks,
    required this.size,
    this.icon,
  });

  factory PhoneApp.fromMap(Map<Object?, Object?> m) => PhoneApp(
    package: m['package'] as String,
    label: m['label'] as String? ?? '',
    versionCode: m['version_code'] as int? ?? 0,
    versionName: m['version_name'] as String? ?? '',
    signer: m['signer'] as String? ?? '',
    apks: (m['apks'] as List? ?? const []).cast<String>(),
    size: m['size'] as int? ?? 0,
    icon: m['icon'] as Uint8List?,
  );

  final String package;
  final String label;
  final int versionCode;
  final String versionName;
  final String signer;
  final List<String> apks;
  final int size;
  final Uint8List? icon;

  AppProbe get probe =>
      AppProbe(package: package, versionCode: versionCode, signer: signer);

  AppBundle get bundle => AppBundle(
    package: package,
    label: label,
    versionCode: versionCode,
    versionName: versionName,
    signer: signer,
    icon: icon == null ? null : base64Encode(icon!),
    apks: apks,
  );
}

/// A file or folder from Android's document picker.
class PickedFile {
  const PickedFile({
    required this.path,
    required this.name,
    required this.size,
  });

  final String path;
  final String name;
  final int size;
}

/// Whether [there] may be picked, and whether it's picked by default.
/// Newer there, or from another developer, can't be: Android wouldn't update
/// it. What's already there is only on a long press.
bool appSelectable(AppThere there) =>
    there != AppThere.newer && there != AppThere.otherSigner;

/// What's chosen to send, kept across Photos, Files and Apps.
class SendSelection extends ChangeNotifier {
  final _media = <int, PhoneMedia>{};
  final _files = <String, PickedFile>{};
  final _apps = <String, PhoneApp>{};

  Iterable<PhoneMedia> get media => _media.values;
  Iterable<PickedFile> get files => _files.values;
  Iterable<PhoneApp> get apps => _apps.values;

  bool hasMedia(PhoneMedia m) => _media.containsKey(m.id);
  bool hasApp(PhoneApp a) => _apps.containsKey(a.package);

  int get count => _media.length + _files.length + _apps.length;
  bool get isEmpty => count == 0;

  /// Everything chosen, in bytes.
  int get bytes =>
      _media.values.fold<int>(0, (n, m) => n + m.size) +
      _files.values.fold<int>(0, (n, f) => n + f.size) +
      appBytes;

  int get appBytes => _apps.values.fold<int>(0, (n, a) => n + a.size);

  /// How many files that is, an app being all its APKs.
  int get fileCount =>
      _media.length +
      _files.length +
      _apps.values.fold<int>(0, (n, a) => n + a.apks.length);

  /// Everything but the apps, as the core takes it.
  List<String> get paths => [
    for (final m in _media.values) m.path,
    for (final f in _files.values) f.path,
  ];

  void toggleMedia(PhoneMedia m) {
    if (_media.remove(m.id) == null) _media[m.id] = m;
    notifyListeners();
  }

  /// A day's heading: all of them, or none if they all are.
  void toggleDay(List<PhoneMedia> day) {
    if (day.every(hasMedia)) {
      for (final m in day) {
        _media.remove(m.id);
      }
    } else {
      for (final m in day) {
        _media[m.id] = m;
      }
    }
    notifyListeners();
  }

  void addFiles(Iterable<PickedFile> files) {
    for (final f in files) {
      _files[f.path] = f;
    }
    notifyListeners();
  }

  void removeFile(PickedFile f) {
    _files.remove(f.path);
    notifyListeners();
  }

  void toggleApp(PhoneApp a) {
    if (_apps.remove(a.package) == null) _apps[a.package] = a;
    notifyListeners();
  }

  void clear() {
    _media.clear();
    _files.clear();
    _apps.clear();
    notifyListeners();
  }
}

/// [media], newest first, under their days.
List<(String, List<PhoneMedia>)> mediaByDay(
  Iterable<PhoneMedia> media, {
  DateTime? now,
}) {
  final sorted = media.toList()..sort((a, b) => b.taken.compareTo(a.taken));
  final days = <(String, List<PhoneMedia>)>[];
  for (final m in sorted) {
    final day = formatDayHeading(m.taken, now: now);
    if (days.isEmpty || days.last.$1 != day) days.add((day, []));
    days.last.$2.add(m);
  }
  return days;
}

/// What to say in the send bar before sending.
sealed class SendWarning {
  const SendWarning();
}

/// Not enough room there: Send is off.
class NoRoom extends SendWarning {
  const NoRoom(this.free);
  final int free;
}

/// It will ask first. Fine, just so nobody waits unaware.
class WillAsk extends SendWarning {
  const WillAsk();
}

/// Apps chosen, and it can't install them yet.
class CantInstall extends SendWarning {
  const CantInstall();
}

/// From a preflight answer, or nothing when there was none.
List<SendWarning> sendWarnings({
  required PreflightReply? reply,
  required int bytes,
  required bool apps,
}) => [
  if (reply?.free case final free? when bytes > free) NoRoom(free),
  if (reply != null && !reply.auto) const WillAsk(),
  if (reply != null && apps && !reply.canInstall) const CantInstall(),
];

/// Over the internet and this big, Send asks once: it's mobile data.
const askOverMobileData = 100 * 1000 * 1000;

/// Whether to ask before sending [bytes] the way [plan] says.
bool asksFirst(SendPlan? plan, int bytes) =>
    plan?.overTheInternet == true && bytes > askOverMobileData;

/// More files than this go in several calls, which are asked about together.
const filesPerSend = 5000;

/// [paths] in sends of at most [filesPerSend], the apps in the first.
List<List<String>> sendBatches(List<String> paths) => [
  for (var i = 0; i < paths.length; i += filesPerSend)
    paths.sublist(
      i,
      i + filesPerSend > paths.length ? paths.length : i + filesPerSend,
    ),
];
