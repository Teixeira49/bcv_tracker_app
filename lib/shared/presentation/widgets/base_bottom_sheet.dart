import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/theme/colors/colors_values.dart';
import '../../../config/theme/width/width_values.dart';
import '../../../core/i18n/app_messages.dart';

/// Container of the app's draggable bottom sheets.
///
/// Introduced with the currency detail ([#38]) and extracted here when the
/// converter's currency selector moved to the same shape ([#40]) — the issue
/// itself asked for the container to be shared if the two ended up alike, and
/// they did. `BaseModal` (an `AlertDialog`) stays for the centred dialogs:
/// this is not a replacement for it, it is the other half of the pair.
///
/// ## The one rule
///
/// **One `DraggableScrollableSheet`, one `CustomScrollView`.** The drag that
/// resizes the sheet and the scroll that moves its content are the same gesture
/// chain, because the scroll view uses the controller the sheet hands out.
/// Nesting a second scrollable inside — a `ListView` for a list of options, a
/// chart with its own vertical scroll — breaks that chain and produces the
/// classic "the sheet closed when I meant to scroll". Content arrives as
/// [slivers]; a box widget goes inside a `SliverToBoxAdapter`, a long list in a
/// `SliverList`.
///
/// ## What it provides
///
/// - The rounded, `info`-bordered surface of `DESIGN.md` → Elevation & Depth.
/// - A pinned grab bar with the handle and a close button, so there is always
///   something to grab and a way out that does not depend on the gesture.
/// - Bottom breathing room sized from `viewPadding`, clearing the gesture bar.
/// - A `Semantics` container naming the sheet, so a screen reader announces
///   what opened instead of dropping the user into loose text.
///
/// ## Keyboard
///
/// Nothing to do here: GetX's own route already wraps the sheet in
/// `EdgeInsets.only(bottom: viewInsets.bottom)`, so the sheet rides above the
/// keyboard and the extents below are fractions of the height that is left.
/// **Do not add that padding again** — it would apply twice and leave a gap the
/// height of the keyboard. A sheet that opens with a field focused (the search
/// of [#41]) will want a larger [initialExtent], since that fraction is taken
/// from the reduced height.
class BaseBottomSheet extends StatelessWidget {
  const BaseBottomSheet({
    super.key,
    required this.semanticsLabel,
    required this.slivers,
    this.initialExtent = defaultInitialExtent,
    this.minExtent = defaultMinExtent,
    this.maxExtent = defaultMaxExtent,
  });

  /// Announced by assistive tech as the name of the sheet. From `AppMessages`.
  final String semanticsLabel;

  /// The content, as slivers. See the rule above.
  final List<Widget> slivers;

  /// Fraction of the available height the sheet opens at.
  ///
  /// Pick it from the content the sheet actually has: a panel that opens a
  /// third empty reads as something failing to load, and one that opens full
  /// reads as a screen rather than a detail of what is behind it.
  final double initialExtent;

  /// Dragging below this closes the sheet.
  final double minExtent;

  /// How far a drag can expand it. Below 1.0 on purpose: leaving the status bar
  /// and a sliver of the page uncovered keeps it a sheet and not a screen.
  final double maxExtent;

  static const double defaultInitialExtent = 0.58;
  static const double defaultMinExtent = 0.35;
  static const double defaultMaxExtent = 0.94;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: initialExtent,
    minChildSize: minExtent,
    maxChildSize: maxExtent,
    // `expand: false` keeps the sheet at its own height instead of filling the
    // route: without it the transparent area above would swallow the taps meant
    // to dismiss it.
    expand: false,
    snap: true,
    snapSizes: <double>[initialExtent],
    builder: (BuildContext context, ScrollController scrollController) =>
        _BaseBottomSheetSurface(
          semanticsLabel: semanticsLabel,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              const _BaseBottomSheetGrabBar(),
              ...slivers,
              const _BaseBottomSheetFooterSpace(),
            ],
          ),
        ),
  );
}

/// Opens [sheet] as a modal bottom sheet.
///
/// Every sheet in the app goes through here so the route settings stay in one
/// place. Two of them carry the behaviour and are not negotiable:
///
/// - `isScrollControlled: true` lets the sheet be taller than Material's
///   default of half the screen, which is the whole point of the shape.
/// - `enableDrag: false` hands **all** dragging to the [BaseBottomSheet]
///   inside. The route's own drag gesture and the sheet's would otherwise both
///   claim the same vertical swipe, and the sheet jumps or closes while the
///   user is scrolling its content.
///
/// Close it with `Get.back()`, like every other modal (see
/// `navigation-convention.md`). Features expose their own named entry point —
/// `showCurrencyDetailSheet`, `showCurrencySelectorSheet` — instead of calling
/// this directly from a widget.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget sheet,
}) => Get.bottomSheet<T>(
  sheet,
  isScrollControlled: true,
  enableDrag: false,
  // The sheet paints its own rounded, bordered surface; a background here would
  // draw a square one behind it.
  backgroundColor: Colors.transparent,
  elevation: 0,
  barrierColor: ColorValues.textBlack(context).withAlpha(120),
);

/// The rounded, bordered panel the content sits on.
///
/// Matches the app's depth language (`DESIGN.md` → Elevation & Depth): the
/// separation from the page behind comes from an `info`-tinted border and a soft
/// glow of the same tone, not from a heavy Material shadow.
class _BaseBottomSheetSurface extends StatelessWidget {
  const _BaseBottomSheetSurface({
    required this.semanticsLabel,
    required this.child,
  });

  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.vertical(
      top: Radius.circular(WidthValues.radiusXl),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorValues.bgPrimary(context),
        borderRadius: radius,
        border: Border.all(
          color: ColorValues.utilityInfo(context).withAlpha(120),
          width: 1.25,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorValues.utilityInfo(context).withAlpha(90),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // Clips the scrolling content to the rounded top instead of letting it
      // paint over the corners. The `Semantics` names the sheet as a whole:
      // without it a screen reader lands on loose text with no idea that a
      // panel opened over the page.
      child: ClipRRect(
        borderRadius: radius,
        // The content gets its own `Material`, **inside** the decoration.
        //
        // Anything that paints ink — a `ListTile`, an `InkWell` — draws it on
        // the nearest `Material` ancestor. Without this that ancestor is
        // outside the sheet, so the background above would paint over every
        // ripple: the rows of the currency selector highlighted on tap and the
        // user saw nothing. Flutter asserts on exactly this arrangement from
        // 3.39 on; the invisible ink was there before the assertion was.
        //
        // Transparent because the colour is already on the `DecoratedBox`, which
        // is also what carries the border and the glow a `Material` cannot.
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: semanticsLabel,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Pinned bar at the top: the drag handle and the close button.
///
/// Pinned rather than scrolled away so there is always something to grab and a
/// way out that does not depend on the gesture. It carries **no text on
/// purpose**: a fixed-extent sliver cannot grow with the system font scale, and
/// text is the only thing in a sheet that would need to.
class _BaseBottomSheetGrabBar extends StatelessWidget {
  const _BaseBottomSheetGrabBar();

  @override
  Widget build(BuildContext context) => const SliverPersistentHeader(
    pinned: true,
    delegate: _BaseBottomSheetGrabBarDelegate(),
  );
}

class _BaseBottomSheetGrabBarDelegate extends SliverPersistentHeaderDelegate {
  const _BaseBottomSheetGrabBarDelegate();

  /// Fits a 40×40 tap target plus the handle above it. Fixed, see the note on
  /// [_BaseBottomSheetGrabBar].
  static const double _height = 48;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      // Opaque: the bar stays pinned while the content scrolls under it.
      color: ColorValues.bgPrimary(context),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: WidthValues.spacingXs),
              child: Container(
                width: WidthValues.spacingLg + WidthValues.spacingMd,
                height: WidthValues.spacingXxs,
                decoration: BoxDecoration(
                  color: ColorValues.fgSecondary(context).withAlpha(140),
                  borderRadius: BorderRadius.circular(WidthValues.radiusFull),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: WidthValues.spacingXs),
              child: IconButton(
                onPressed: () => Get.back<void>(),
                tooltip: AppMessages.closeAction,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                icon: Icon(
                  Icons.close,
                  color: ColorValues.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _BaseBottomSheetGrabBarDelegate oldDelegate) =>
      false;
}

/// Breathing room under the last section.
///
/// Sized from `viewPadding` so the final row clears the gesture bar on devices
/// that have one, and from the grid otherwise.
class _BaseBottomSheetFooterSpace extends StatelessWidget {
  const _BaseBottomSheetFooterSpace();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(
      height: WidthValues.spacingLg + MediaQuery.of(context).viewPadding.bottom,
    ),
  );
}
