import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/app/activity.dart';
import 'package:linksy/app/linksy_controller.dart';
import 'package:linksy/core/demo_node.dart';
import 'package:linksy/core/linksy_node.dart';
import 'package:linksy/core/models.dart';

/// The demo node, with its events and offers in the test's hands.
class _Node extends DemoNode {
  _Node(String dir) : super(name: 'Test Phone', downloadDir: dir);

  final out = StreamController<LinksyEvent>.broadcast();
  final offers = <List<String>>[];
  final answers = <(String, bool)>[];
  final cancelled = <String>[];
  var reachable = true;
  var next = 0;

  @override
  Stream<LinksyEvent> get events => out.stream;

  @override
  Future<String> sendFiles(String id, List<String> paths) =>
      sendBundle(id, paths, const []);

  @override
  Future<String> sendBundle(
    String id,
    List<String> paths,
    List<AppBundle> apps,
  ) async {
    if (!reachable) {
      throw const LinksyException("device isn't reachable right now");
    }
    offers.add(paths);
    return 'offer-${next++}';
  }

  @override
  Future<void> respond(String requestId, {required bool accept}) async =>
      answers.add((requestId, accept));

  @override
  Future<void> cancel(String transferId) async => cancelled.add(transferId);
}

void main() {
  const mb = 1 << 20;
  late Directory dir;
  late _Node node;
  late LinksyController c;
  late DeviceInfo peer;
  late List<LinksyEvent> prompted;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('app.linksy/platform'),
          (call) async => call.method == 'prefs' ? {'onboarded': '1'} : null,
        );
    dir = await Directory.systemTemp.createTemp('resume');
    node = _Node(dir.path);
    c = LinksyController(node, ActivityStore(null));
    await c.start();
    await c.refresh();
    peer = c.devices.firstWhere((v) => v.trusted).device;
    prompted = [];
    c.prompts.listen(prompted.add);
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Activity entry(String id) =>
      c.activityFor(peer.id).firstWhere((a) => a.id == id);

  test(
    'a send cut off goes again from the first file not surely there',
    () async {
      final files = [
        for (var i = 0; i < 10; i++)
          OfferedFile(path: 'p$i.jpg', size: 20 * mb),
      ];
      final paths = [for (final f in files) '/picked/${f.path}'];
      await c.sendFiles(peer.id, paths);
      final id = node.offers.length == 1 ? 'offer-0' : fail('not offered');
      node.out.add(
        TransferStarted(id, peer: peer, files: files, total: 200 * mb),
      );
      node.out.add(
        TransferProgress(transfer: id, bytes: 150 * mb, total: 200 * mb),
      );
      node.out.add(
        const TransferFailed(
          transfer: 'offer-0',
          reason: 'stream write failed: connection lost',
        ),
      );
      await settle();
      expect(entry(id).status, ActivityStatus.active);
      expect(entry(id).reason, isNotNull);

      // Back a second later: 150 MB went out, files up to 98 MB are there
      // for sure (52 MB in flight), so from the fifth one on.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(node.offers.last, paths.sublist(4));
      node.out.add(
        TransferStarted(
          'offer-1',
          peer: peer,
          files: files.sublist(4),
          total: 120 * mb,
        ),
      );
      node.out.add(
        TransferProgress(transfer: 'offer-1', bytes: 60 * mb, total: 120 * mb),
      );
      await settle();
      expect(c.activityFor(peer.id).where((a) => a.id == 'offer-1'), isEmpty);
      expect(entry(id).bytes, 140 * mb);
      expect(entry(id).total, 200 * mb);
      expect(entry(id).reason, isNull);
      node.out.add(const TransferComplete(transfer: 'offer-1', saved: []));
      await settle();
      expect(entry(id).status, ActivityStatus.done);
    },
  );

  test('a send stopped by its receiver is not sent again', () async {
    await c.sendFiles(peer.id, ['/picked/a.jpg']);
    node.out.add(
      TransferStarted(
        'offer-0',
        peer: peer,
        files: const [OfferedFile(path: 'a.jpg', size: 5)],
        total: 5,
      ),
    );
    node.out.add(
      const TransferFailed(
        transfer: 'offer-0',
        reason: 'stream write failed: sending stopped by peer: error 0',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(node.offers, hasLength(1));
    expect(entry('offer-0').status, ActivityStatus.failed);
  });

  test('cancelled while waiting for the device, it ends there', () async {
    await c.sendFiles(peer.id, ['/picked/a.jpg']);
    node.out.add(
      TransferStarted(
        'offer-0',
        peer: peer,
        files: const [OfferedFile(path: 'a.jpg', size: 5)],
        total: 5,
      ),
    );
    node.out.add(
      const TransferFailed(transfer: 'offer-0', reason: 'connection lost'),
    );
    await settle();
    await c.cancel('offer-0');
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(node.offers, hasLength(1));
    expect(entry('offer-0').status, ActivityStatus.failed);
  });

  test(
    'the receiver takes the rest without asking, and keeps what came',
    () async {
      final files = [
        const OfferedFile(path: 'a.jpg', size: 4),
        const OfferedFile(path: 'b.jpg', size: 4),
        const OfferedFile(path: 'c.jpg', size: 4),
      ];
      node.out.add(
        TransferRequest(transfer: 't1', from: peer, files: files, total: 12),
      );
      await settle();
      await c.respond('t1', accept: true);
      node.out.add(
        TransferStarted(
          't1',
          peer: peer,
          incoming: true,
          files: files,
          total: 12,
        ),
      );
      // a and b arrived whole, c half
      File('${dir.path}/a.jpg').writeAsStringSync('aaaa');
      File('${dir.path}/b.jpg').writeAsStringSync('bbbb');
      File('${dir.path}/c.jpg.linksy-part').writeAsStringSync('cc');
      node.out.add(
        const TransferProgress(transfer: 't1', bytes: 10, total: 12),
      );
      node.out.add(
        const TransferFailed(
          transfer: 't1',
          reason: 'protocol error: connection lost',
        ),
      );
      await settle();
      expect(entry('t1').status, ActivityStatus.active);

      // The sender offers b and c again (b may not be whole, it can't tell).
      node.out.add(
        TransferRequest(
          transfer: 't2',
          from: peer,
          files: files.sublist(1),
          total: 8,
        ),
      );
      await settle();
      expect(node.answers.last, ('t2', true));
    // Nor is it put to the user.
    expect(prompted.whereType<TransferRequest>().map((r) => r.transfer), [
      't1',
    ]);
      expect(c.activityFor(peer.id).where((a) => a.id == 't2'), isEmpty);
      // b goes back to its part: the core finds it whole and sends none of it.
      expect(File('${dir.path}/b.jpg').existsSync(), isFalse);
      expect(File('${dir.path}/b.jpg.linksy-part').readAsStringSync(), 'bbbb');
      expect(File('${dir.path}/a.jpg').existsSync(), isTrue);

      node.out.add(
        TransferStarted(
          't2',
          peer: peer,
          incoming: true,
          files: files.sublist(1),
          total: 8,
        ),
      );
      node.out.add(const TransferProgress(transfer: 't2', bytes: 8, total: 8));
      await settle();
      expect(entry('t1').bytes, 12);
      node.out.add(
        TransferComplete(
          transfer: 't2',
          saved: ['${dir.path}/b.jpg', '${dir.path}/c.jpg'],
        ),
      );
      await settle();
      expect(entry('t1').status, ActivityStatus.done);
      // a, which wasn't offered again, is saved with the rest.
      expect(entry('t1').saved, [
        '${dir.path}/a.jpg',
        '${dir.path}/b.jpg',
        '${dir.path}/c.jpg',
      ]);
    },
  );

  test('an offer that is not the rest asks as usual', () async {
    final files = [
      const OfferedFile(path: 'a.jpg', size: 4),
      const OfferedFile(path: 'b.jpg', size: 4),
    ];
    node.out.add(
      TransferRequest(transfer: 't1', from: peer, files: files, total: 8),
    );
    await settle();
    await c.respond('t1', accept: true);
    node.out.add(
      TransferStarted('t1', peer: peer, incoming: true, files: files, total: 8),
    );
    node.out.add(
      const TransferFailed(transfer: 't1', reason: 'connection lost'),
    );
    await settle();
    node.out.add(
      const TransferRequest(
        transfer: 't2',
        from: DeviceInfo(id: 'x', name: 'x', kind: DeviceKind.phone, os: ''),
        files: [OfferedFile(path: 'z.jpg', size: 1)],
        total: 1,
      ),
    );
    await settle();
    expect(node.answers.where((a) => a.$1 == 't2'), isEmpty);
  });
}
