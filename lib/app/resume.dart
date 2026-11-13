/// Transfers cut off with their connection (a network change, a link that
/// moved to a better one, a router that dropped it a moment) carry on once the
/// devices are connected again, on the protocol as it is (docs/protocol.md
/// §4.6): the sender offers again what the receiver may not have whole, and
/// the receiver takes that offer without asking. The core resumes a file from
/// its `.linksy-part` and checks the whole file's hash (transfer.rs), so a file
/// the receiver already has whole is put back as its part: it's checked, and
/// no byte of it is sent again.
library;

import '../core/models.dart';

/// How long the devices have to find each other again.
const resumeWithin = Duration(minutes: 2);

/// How many times one transfer starts again before it's reported failed.
const resumeTries = 5;

/// What can be on its way but not yet saved there: the core's send window
/// (32 MiB) and stream receive window (16 MiB, tls.rs), and some room for the
/// frames between files. A file that ends this far before what was sent is
/// whole on the other side.
const inFlight = 52 << 20;

/// Whether a transfer failed because its connection went, rather than
/// because someone stopped it or a file was wrong. The core's words for it:
/// `connection lost` (quinn's, behind a read, a write or the connection),
/// `device isn't reachable right now`. A cancel shows as the stream reset or
/// stopped by the other side.
bool lostConnection(String reason) {
  final r = reason.toLowerCase();
  if (r.contains('cancel') ||
      r.contains('declin') ||
      r.contains('reset by peer') ||
      r.contains('stopped by peer') ||
      r.contains('checksum') ||
      r.contains('not enough room')) {
    return false;
  }
  return r.contains('connection lost') ||
      r.contains("isn't reachable") ||
      r.contains('could not connect') ||
      (r.contains('timed out') && !r.contains('waiting for an answer'));
}

/// Sender: the first file the receiver may not have whole, after [sent] bytes
/// went out of files of [sizes], in order.
int firstUnsure(List<int> sizes, int sent, {int slack = inFlight}) {
  final sure = sent - slack;
  var end = 0;
  for (var i = 0; i < sizes.length; i++) {
    end += sizes[i];
    if (end > sure) return i;
  }
  return sizes.length;
}

/// Sender: what to offer again from [paths] (what was picked, files or
/// folders) to send [entries] (what the core made of them, in order) from
/// [from] on, and how many bytes come before it. A folder goes again whole:
/// its files that are there already cost nothing. Null when the entries
/// don't line up with the paths.
(List<String>, int)? resendPaths(
  List<String> paths,
  List<OfferedFile> entries,
  int from,
) {
  var k = 0;
  var before = 0;
  final out = <String>[];
  for (final p in paths) {
    final name = p.split('/').where((s) => s.isNotEmpty).lastOrNull;
    if (name == null) return null;
    final start = k;
    var size = 0;
    while (k < entries.length &&
        (entries[k].path == name || entries[k].path.startsWith('$name/'))) {
      size += entries[k].size;
      k++;
    }
    // An empty folder sends nothing, and isn't offered again.
    if (k == start) continue;
    if (k > from) {
      out.add(p);
    } else {
      before += size;
    }
  }
  if (k != entries.length) return null;
  return (out, before);
}

/// Receiver: where [offered] begins among [failed]'s files when it's their
/// tail (the same paths and sizes, in order, to the last), else null.
int? tailStart(List<OfferedFile> failed, List<OfferedFile> offered) {
  if (offered.isEmpty || offered.length > failed.length) return null;
  final start = failed.length - offered.length;
  for (var i = 0; i < offered.length; i++) {
    final a = failed[start + i];
    final b = offered[i];
    if (a.path != b.path || a.size != b.size) return null;
  }
  return start;
}

/// Receiver: the files of [files] whole within the first [received] bytes.
int wholeWithin(List<OfferedFile> files, int received) {
  var end = 0;
  for (var i = 0; i < files.length; i++) {
    end += files[i].size;
    if (end > received) return i;
  }
  return files.length;
}
