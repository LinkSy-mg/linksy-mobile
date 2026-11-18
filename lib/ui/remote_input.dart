import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// TV remotes (the Shield's), game pads (a Retroid Pocket's own buttons, a
/// controller on a TV) and keyboards: the D-pad or the stick moves between
/// controls, the centre button or A picks, B goes back.
///
/// Android hands these to Flutter as keys: the D-pad as the arrows (the left
/// stick too, once Android turns it into D-pad presses), its centre button
/// as [LogicalKeyboardKey.select], a pad's buttons as the game buttons.
abstract final class RemoteKeys {
  /// Picks the focused control: the remote's centre button, A, Enter, Space.
  static bool activates(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.gameButtonA;

  /// Same as holding a finger on it: the remote's menu button, X or Y.
  static bool holds(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.contextMenu ||
      key == LogicalKeyboardKey.gameButtonX ||
      key == LogicalKeyboardKey.gameButtonY;

  /// How long the centre button or A is held for a long press.
  static const hold = Duration(milliseconds: 500);

  /// Added to the app's own (MaterialApp `shortcuts`), over Flutter's
  /// defaults, which already move focus with the arrows and pick with
  /// Select, Enter, Space and A.
  static Map<ShortcutActivator, Intent> get shortcuts => {
    ...WidgetsApp.defaultShortcuts,
    // B is Back. Android would turn an unused B into Back on its own, but
    // not on every pad, and not while Flutter says it used the key.
    const SingleActivator(LogicalKeyboardKey.gameButtonB): const BackIntent(),
    // The shoulder buttons page through long lists.
    const SingleActivator(
      LogicalKeyboardKey.gameButtonLeft1,
    ): const ScrollIntent(
      direction: AxisDirection.up,
      type: ScrollIncrementType.page,
    ),
    const SingleActivator(
      LogicalKeyboardKey.gameButtonRight1,
    ): const ScrollIntent(
      direction: AxisDirection.down,
      type: ScrollIncrementType.page,
    ),
    const SingleActivator(LogicalKeyboardKey.pageUp): const ScrollIntent(
      direction: AxisDirection.up,
      type: ScrollIncrementType.page,
    ),
    const SingleActivator(LogicalKeyboardKey.pageDown): const ScrollIntent(
      direction: AxisDirection.down,
      type: ScrollIncrementType.page,
    ),
  };

  static Map<Type, Action<Intent>> get actions => {
    ...WidgetsApp.defaultActions,
    BackIntent: BackAction(),
  };
}

/// Back, as Android's own button: closes a sheet or dialog, leaves a page,
/// and on the home screen does what Back does there.
class BackIntent extends Intent {
  const BackIntent();
}

/// Through the focused control's own navigator, so a page's [PopScope] gets
/// its say (home's island closes, home itself goes to the background).
class BackAction extends ContextAction<BackIntent> {
  @override
  Object? invoke(BackIntent intent, [BuildContext? context]) {
    final at = context ?? primaryFocus?.context;
    if (at != null && at.mounted) Navigator.maybePop(at);
    return null;
  }
}
