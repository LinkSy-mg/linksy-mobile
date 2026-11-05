import 'package:flutter/foundation.dart';

import '../../app/platform.dart';
import '../../core/models.dart';
import 'selection.dart';
import 'send_flow.dart';

/// What's on this phone, read once for the page's shelves and their See all.
class PhoneLibrary extends ChangeNotifier {
  PhoneLibrary(this.flow);

  final SendFlow flow;

  static const _page = 240;

  var albums = const <PhoneAlbum>[];
  String? album;
  final media = <PhoneMedia>[];
  bool more = true;
  bool _loading = false;
  bool _disposed = false;

  /// Null until read.
  List<PhoneApp>? apps;

  /// Updates are picked once, the first time Apps is opened.
  bool _updatesPicked = false;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadPhotos() async {
    if (media.isEmpty) {
      LinksyPlatform.phoneAlbums().then((found) {
        albums = found.map(PhoneAlbum.fromMap).toList();
        _changed();
      });
    }
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_loading || !more) return;
    _loading = true;
    final asked = album;
    final page = await LinksyPlatform.phoneMedia(
      album: asked,
      before: media.isEmpty ? null : media.last.taken.millisecondsSinceEpoch,
      limit: _page,
    );
    _loading = false;
    if (asked != album) return;
    media.addAll(page.map(PhoneMedia.fromMap));
    more = page.length == _page;
    _changed();
  }

  void pickAlbum(String? id) {
    album = id;
    media.clear();
    more = true;
    _loading = false;
    _changed();
    loadMore();
  }

  /// Reads the apps and asks the other phone what it has of them.
  Future<void> loadApps() async {
    if (apps != null) return;
    final found = (await LinksyPlatform.phoneApps()).map(PhoneApp.fromMap);
    apps = found.toList();
    _changed();
    await flow.ask([for (final a in found.take(256)) a.probe]);
    _changed();
  }

  AppThere there(PhoneApp a) => flow.reply?.apps[a.package] ?? AppThere.unknown;

  /// An update is what you came for: picked, once, when Apps opens.
  void pickUpdates() {
    if (_updatesPicked || flow.reply == null) return;
    _updatesPicked = true;
    final chosen = flow.selection;
    for (final a in apps ?? const <PhoneApp>[]) {
      if (there(a) == AppThere.older && !chosen.hasApp(a)) chosen.toggleApp(a);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
