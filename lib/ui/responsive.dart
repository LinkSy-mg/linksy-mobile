import 'package:flutter/material.dart' show showModalBottomSheet;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Linksy on every screen: a phone either way up, a tablet, an unfolded
/// phone. Pages read best at a phone's width, so on a wider screen they keep
/// to a column ([readable]) or put two side by side ([sideBySide]).

/// A column of text and cards reads best no wider than this.
const readableWidth = 680.0;

/// A sheet no wider than this, centred on a wide screen.
const sheetWidth = 640.0;

/// Wide and not tall: room for two panes, a page's header beside its
/// content, a touchpad beside its buttons.
bool sideBySide(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.width >= 600 && size.width > size.height;
}

/// The room either side of a [readableWidth] column on this screen, at
/// least [least]: a list stays a phone's width, centred.
double readableSide(BuildContext context, {double least = 16, double? width}) {
  final w = width ?? MediaQuery.sizeOf(context).width;
  return math.max(least, (w - readableWidth) / 2);
}

/// [child] no wider than [readableWidth], centred along the top.
class Readable extends StatelessWidget {
  const Readable({super.key, required this.child, this.width = readableWidth});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: child,
    ),
  );
}

/// [slivers] in a [readableWidth] column, centred. Their own 16 dp edge
/// stays; on a wide screen the rest of the room goes either side.
class ReadableSlivers extends StatelessWidget {
  const ReadableSlivers({super.key, required this.slivers});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: readableSide(context) - 16),
    sliver: SliverMainAxisGroup(slivers: slivers),
  );
}

/// A bottom sheet, as [showModalBottomSheet]. On a wide screen the sheet is
/// centred, away from the edges, so it doesn't keep their insets (a camera
/// cutout sideways would push its content off centre).
Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool? showDragHandle,
  Color? backgroundColor,
  Color? barrierColor,
  BoxConstraints? constraints,
  bool isDismissible = true,
  bool enableDrag = true,
}) => showModalBottomSheet<T>(
  context: context,
  // Sideways a phone is short: a sheet may take the height it needs, not
  // the usual 9/16 of it, which hid the end of even a short one.
  isScrollControlled: isScrollControlled || _short(context),
  useSafeArea: _short(context),
  showDragHandle: showDragHandle,
  backgroundColor: backgroundColor,
  barrierColor: barrierColor,
  constraints: constraints,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  builder: (context) {
    final media = MediaQuery.of(context);
    final width = constraints?.maxWidth ?? sheetWidth;
    if (media.size.width - width < 2 * media.padding.horizontal) {
      return builder(context);
    }
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(left: 0, right: 0),
        viewPadding: media.viewPadding.copyWith(left: 0, right: 0),
      ),
      child: Builder(builder: builder),
    );
  },
);

bool _short(BuildContext context) => MediaQuery.sizeOf(context).height < 560;

/// Wide: [pane] as a card on the left, [page] scrolling beside it. The two
/// start at the same top, keep the page's 16 dp edges, and together are no
/// wider than the pane and a readable column, centred.
class SidePanes extends StatelessWidget {
  const SidePanes({super.key, required this.pane, required this.page});

  final Widget pane;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final insets = MediaQuery.paddingOf(context);
    final paneWidth = math.min(size.width * .4, 400.0);
    final room = size.width - insets.horizontal;
    final margin = math.max(0.0, (room - 16 - paneWidth - readableWidth) / 2);
    return Padding(
      padding: EdgeInsets.only(
        left: insets.left + margin,
        right: insets.right + margin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              insets.top + 16,
              0,
              insets.bottom + 16,
            ),
            child: SizedBox(
              width: paneWidth,
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeTop: true,
                removeRight: true,
                removeBottom: true,
                child: pane,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: insets.top),
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeTop: true,
                removeRight: true,
                child: page,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
