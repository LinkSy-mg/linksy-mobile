import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/resume.dart';
import 'package:linksy/core/models.dart';

OfferedFile f(String path, int size) => OfferedFile(path: path, size: size);

void main() {
  const mb = 1 << 20;

  test('a lost connection is worth continuing, a stop is not', () {
    for (final r in [
      'protocol error: connection lost',
      'stream write failed: connection lost',
      'connection lost: timed out',
      'connection lost: closed by peer: gone',
      "device isn't reachable right now",
    ]) {
      expect(lostConnection(r), isTrue, reason: r);
    }
    for (final r in [
      'cancelled',
      'declined',
      'request was declined',
      'protocol error: stream reset by peer: error 0',
      'stream write failed: sending stopped by peer: error 0',
      'file failed integrity check: a.jpg did not match its checksum',
      'not enough room: 5 bytes to receive, 1 free',
      'timed out waiting for an answer',
    ]) {
      expect(lostConnection(r), isFalse, reason: r);
    }
  });

  test('the sender offers again from the first file not surely there', () {
    final sizes = [10 * mb, 10 * mb, 10 * mb, 10 * mb, 10 * mb, 10 * mb];
    // Nothing is sure until more than the windows went out.
    expect(firstUnsure(sizes, 40 * mb), 0);
    expect(firstUnsure(sizes, 60 * mb), 0);
    expect(firstUnsure(sizes, 63 * mb), 1);
    expect(firstUnsure(sizes, 0, slack: 0), 0);
    expect(firstUnsure(sizes, 25 * mb, slack: 0), 2);
    expect(firstUnsure(sizes, 60 * mb, slack: 0), 6);
  });

  test('files and folders map back to what was picked', () {
    final entries = [
      f('a.jpg', 5),
      f('Trip/1.jpg', 3),
      f('Trip/2.jpg', 4),
      f('b.mp4', 9),
    ];
    final paths = ['/x/0/a.jpg', '/x/1/Trip', '/x/2/b.mp4'];
    // Records compare their lists by identity.
    Object? r(List<String> p, int from) =>
        switch (resendPaths(p, entries, from)) {
          (final out, final before) => [out, before],
          null => null,
        };
    expect(r(paths, 0), [paths, 0]);
    expect(r(paths, 1), [
      ['/x/1/Trip', '/x/2/b.mp4'],
      5,
    ]);
    // Inside the folder: the folder again, whole.
    expect(r(paths, 2), [
      ['/x/1/Trip', '/x/2/b.mp4'],
      5,
    ]);
    expect(r(paths, 3), [
      ['/x/2/b.mp4'],
      12,
    ]);
    expect(r(paths, 4), [<String>[], 21]);
    // Not what was picked: no guess.
    expect(r(['/x/0/c.jpg'], 0), isNull);
  });

  test('the receiver knows the tail of what it was getting', () {
    final failed = [f('a', 1), f('b', 2), f('c', 3)];
    expect(tailStart(failed, [f('b', 2), f('c', 3)]), 1);
    expect(tailStart(failed, failed), 0);
    expect(tailStart(failed, [f('c', 3)]), 2);
    expect(tailStart(failed, [f('c', 4)]), isNull);
    expect(tailStart(failed, [f('b', 2)]), isNull);
    expect(tailStart(failed, [f('x', 1), ...failed]), isNull);
    expect(tailStart(failed, []), isNull);
  });

  test('whole within what arrived', () {
    final files = [f('a', 10), f('b', 10), f('c', 10)];
    expect(wholeWithin(files, 0), 0);
    expect(wholeWithin(files, 15), 1);
    expect(wholeWithin(files, 20), 2);
    expect(wholeWithin(files, 30), 3);
  });
}
