/// Update Now: the newest Android release on LinkSy-mg/linksy-releases (tagged
/// `vX.Y.Z`; the computer's are `linux-vX.Y.Z`), its APK for this phone, and
/// the SHA-256 the release lists for it. Android then installs it, and only
/// over this app when it's signed with the same key.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _github =
    'https://api.github.com/repos/LinkSy-mg/linksy-releases/releases?per_page=20';

/// A test build may ask a test server instead (`--dart-define=LINKSY_RELEASES=`),
/// over plain HTTP too. Releases never set it.
const _test = String.fromEnvironment('LINKSY_RELEASES');
const releasesApi = _test == '' ? _github : _test;

bool _allowed(String url) =>
    url.startsWith('https://') || (_test != '' && url.startsWith('http://'));

/// One Android release.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.page,
    required this.notes,
    required this.assets,
  });

  final String version;

  /// The release's page, for the full notes.
  final String page;

  /// The release notes, as written (Markdown), without the checksum list.
  final String notes;

  /// File name to download link.
  final Map<String, String> assets;

  /// The APK for a phone whose preferred ABI is [abi], the universal one
  /// when there's none for it.
  String apkName(String? abi) {
    final split = switch (abi) {
      'arm64-v8a' => 'linksy-$version-arm64.apk',
      'armeabi-v7a' => 'linksy-$version-armv7.apk',
      'x86_64' => 'linksy-$version-x86_64.apk',
      _ => null,
    };
    return split != null && assets.containsKey(split)
        ? split
        : 'linksy-$version.apk';
  }

  /// The newest Android release in a GitHub releases list; null if none.
  static AppRelease? newest(String raw) {
    final Object? list;
    try {
      list = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (list is! List) return null;
    AppRelease? best;
    for (final r in list) {
      if (r is! Map || r['draft'] == true || r['prerelease'] == true) continue;
      final tag = r['tag_name'];
      if (tag is! String) continue;
      final m = RegExp(r'^v(\d+\.\d+\.\d+)$').firstMatch(tag);
      if (m == null) continue;
      final version = m[1]!;
      if (best != null && !isNewer(version, best.version)) continue;
      final assets = <String, String>{
        for (final a in r['assets'] is List ? r['assets'] as List : const [])
          if (a is Map &&
              a['name'] is String &&
              a['browser_download_url'] is String &&
              _allowed(a['browser_download_url'] as String))
            a['name'] as String: a['browser_download_url'] as String,
      };
      if (!assets.containsKey('linksy-$version.apk')) continue;
      best = AppRelease(
        version: version,
        page: r['html_url'] is String ? r['html_url'] as String : '',
        notes: _withoutSums(r['body'] is String ? r['body'] as String : ''),
        assets: assets,
      );
    }
    return best;
  }

  static String _withoutSums(String body) {
    final at = body.indexOf('### SHA-256');
    return (at < 0 ? body : body.substring(0, at)).trim();
  }
}

/// Whether version [a] is newer than [b] ("0.10.0" after "0.9.3").
bool isNewer(String a, String b) {
  List<int> parts(String v) =>
      v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d > 0;
  }
  return false;
}

/// The SHA-256 that a `SHA256SUMS` file (`<hex>  <name>` lines) gives [name].
String? sumFor(String sums, String name) {
  for (final line in const LineSplitter().convert(sums)) {
    final m = RegExp(r'^([0-9a-fA-F]{64})\s+\*?(\S+)\s*$').firstMatch(line);
    if (m != null && m[2] == name) return m[1]!.toLowerCase();
  }
  return null;
}

/// Asks GitHub at most once an hour, keeping the last answer in [cache].
class UpdateChecker {
  UpdateChecker(this.cache);
  final File cache;

  /// The newest release from the last answer, without the network.
  AppRelease? cached() {
    try {
      return AppRelease.newest(cache.readAsStringSync());
    } on Object {
      return null;
    }
  }

  /// A fresh answer when the last is an hour old, or [force]; else null.
  Future<AppRelease?> refresh({bool force = false}) async {
    try {
      if (!force &&
          cache.existsSync() &&
          DateTime.now().difference(cache.lastModifiedSync()) <
              const Duration(hours: 1)) {
        return null;
      }
    } on Object {
      // Unreadable cache: ask.
    }
    final raw = await _get(Uri.parse(releasesApi), limit: 1 << 20);
    if (raw == null) return null;
    final release = AppRelease.newest(raw);
    if (release != null) {
      try {
        await cache.writeAsString(raw);
      } on Object {
        // Asked again next time.
      }
    }
    return release;
  }
}

/// A small text file over HTTPS, or null.
Future<String?> _get(Uri uri, {required int limit}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final bytes = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 8))) {
      bytes.addAll(chunk);
      if (bytes.length > limit) return null;
    }
    return utf8.decode(bytes, allowMalformed: true);
  } on Object {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Why an update didn't download.
class UpdateFailed implements Exception {
  const UpdateFailed(this.reason);

  /// `network`, or `unlisted` when the release lists no checksum for the APK.
  final String reason;
}

/// Downloads [release]'s APK for [abi] into [dir], reporting progress from 0
/// to 1. Returns the file and the SHA-256 it must have.
Future<(File, String)> downloadUpdate(
  AppRelease release,
  String? abi,
  Directory dir, {
  void Function(double progress)? onProgress,
}) async {
  final name = release.apkName(abi);
  final sumsUrl = release.assets['SHA256SUMS'];
  final sums = sumsUrl == null
      ? null
      : await _get(Uri.parse(sumsUrl), limit: 64 * 1024);
  if (sumsUrl != null && sums == null) throw const UpdateFailed('network');
  final sum = sums == null ? null : sumFor(sums, name);
  if (sum == null) throw const UpdateFailed('unlisted');

  dir.createSync(recursive: true);
  for (final old in dir.listSync()) {
    if (old is File) old.deleteSync();
  }
  final file = File('${dir.path}/$name');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(release.assets[name]!));
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw const UpdateFailed('network');
    final total = response.contentLength;
    var got = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress?.call(got / total);
      }
    } finally {
      await sink.close();
    }
    if (total > 0 && got != total) throw const UpdateFailed('network');
    return (file, sum);
  } on UpdateFailed {
    rethrow;
  } on Object {
    throw const UpdateFailed('network');
  } finally {
    client.close(force: true);
  }
}
