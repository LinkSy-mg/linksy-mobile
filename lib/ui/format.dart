import 'package:intl/intl.dart';

import 'l10n.dart';

/// Decimal units, like the desktop: "2.1 MB".
String formatBytes(int bytes) {
  if (bytes < 1000) return tr.formatBytesSmall(bytes);
  const units = ['kB', 'MB', 'GB', 'TB'];
  var value = bytes / 1000;
  var unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit++;
  }
  final digits = value >= 100 || unit == 0 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

String formatSpeed(double bytesPerSecond) =>
    '${formatBytes(bytesPerSecond.round())}/s';

/// "8 seconds left", "3 minutes left", "about 2 hours left".
String formatTimeLeft(int remaining, double bytesPerSecond) {
  if (bytesPerSecond <= 0) return '';
  final s = (remaining / bytesPerSecond).ceil();
  if (s < 60) return tr.formatSecondsLeft(s);
  final m = (s / 60).round();
  if (m < 60) return tr.formatMinutesLeft(m);
  final h = (m / 60).round();
  return tr.formatHoursLeft(h);
}

String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Today", "Yesterday", "Monday 12 October", with the year when it isn't
/// this year, in the app's language.
String formatDay(DateTime t, {DateTime? now}) {
  final today = _date(now ?? DateTime.now());
  final day = _date(t);
  final diff = today.difference(day).inDays;
  if (diff == 0) return tr.formatToday;
  if (diff == 1) return tr.formatYesterday;
  final locale = _dateLocale();
  return day.year == today.year
      ? DateFormat.MMMMEEEEd(locale).format(day)
      : DateFormat.yMMMMd(locale).format(day);
}

/// A day in short, as a clock shows it: "Tue, 3 Nov".
String shortDate(DateTime t) => DateFormat.MMMEd(_dateLocale()).format(t);

/// The app's language for dates: British English for English (day before
/// month, as the app writes it), French where intl has no data (Malagasy),
/// else intl's built-in English (all intl has before Flutter's localizations
/// load its date data, as in unit tests).
String _dateLocale() {
  final l = tr.localeName;
  for (final candidate in [l == 'en' ? 'en_GB' : l, 'fr']) {
    try {
      if (DateFormat.localeExists(candidate)) return candidate;
    } on Exception {
      break;
    }
  }
  return 'en_US';
}

DateTime _date(DateTime t) => DateTime(t.year, t.month, t.day);

/// "/storage/emulated/0/Download/Linksy" → "Phone › Download › Linksy".
String friendlyPath(String path) {
  final roots = {
    '/storage/emulated/0': tr.formatPhone,
    '/sdcard': tr.formatPhone,
  };
  for (final MapEntry(:key, :value) in roots.entries) {
    if (path == key || path.startsWith('$key/')) {
      final rest = path
          .substring(key.length)
          .split('/')
          .where((p) => p.isNotEmpty);
      return [value, ...rest].join(' › ');
    }
  }
  return path;
}

/// Up to two initials: "Studio Desktop" → "SD", "ThinkPad" → "T".
String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
