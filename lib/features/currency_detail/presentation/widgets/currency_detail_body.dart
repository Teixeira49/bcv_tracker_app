part of '../page/currency_detail_sheet.dart';

/// The sheet's surface and its single scrollable.
///
/// Two decisions hold this together, and both exist so the view can grow:
///
/// 1. **One `DraggableScrollableSheet`, one `CustomScrollView`.** The drag that
///    resizes the sheet and the scroll that moves its content are the *same*
///    gesture chain, because the scroll view uses the controller the sheet
///    hands out. Nesting a second scrollable inside a section — a `ListView`
///    for a fact list, a horizontal chart with its own vertical scroll — breaks
///    that chain and produces the classic "the sheet closes when I meant to
///    scroll". Sections are **slivers**, never scroll views.
/// 2. **No fixed heights.** Every sliver sizes itself from its content, so a
///    user with the system font enlarged gets a taller sheet instead of a
///    clipped one. The only fixed extent in here is the grab bar, which holds
///    no text.
class _CurrencyDetailBody extends StatelessWidget {
  const _CurrencyDetailBody({required this.currency});

  final Currency currency;

  /// Fraction of the screen the sheet opens at.
  ///
  /// Measured against the content #38 ships — header plus the seven detail
  /// rows — so the sheet opens showing all of it and no more: a third of empty
  /// panel under the last row reads as something failing to load. The sections
  /// still to come expand into [_maxExtent] instead, and anyone who enlarges
  /// the system font simply scrolls.
  static const double _initialExtent = 0.58;

  /// Dragging below this closes the sheet (`shouldCloseOnMinExtent`).
  static const double _minExtent = 0.35;

  /// Leaves the status bar and a sliver of the list uncovered when fully
  /// expanded, so it never reads as a page that replaced the Home.
  static const double _maxExtent = 0.94;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: _initialExtent,
    minChildSize: _minExtent,
    maxChildSize: _maxExtent,
    // `expand: false` keeps the sheet at its own height instead of filling the
    // route: without it the transparent area above the sheet would swallow the
    // taps meant to dismiss it.
    expand: false,
    snap: true,
    snapSizes: const <double>[_initialExtent],
    builder: (context, scrollController) => _CurrencyDetailSurface(
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          const _CurrencyDetailGrabBar(),
          SliverToBoxAdapter(child: _CurrencyDetailHeader(currency: currency)),
          // Order follows #38: header, details, chart, actions, converter.
          SliverToBoxAdapter(child: _CurrencyDetailFacts(currency: currency)),
          CurrencyDetailChartSlot(currency: currency),
          CurrencyDetailActionsSlot(currency: currency),
          CurrencyDetailConverterSlot(currency: currency),
          const _CurrencyDetailFooterSpace(),
        ],
      ),
    ),
  );
}

/// The rounded, bordered panel the sheet content sits on.
///
/// Matches the app's depth language (`DESIGN.md` → Elevation & Depth): the
/// separation from the page behind comes from an `info`-tinted border and a
/// soft glow of the same tone, not from a heavy Material shadow.
class _CurrencyDetailSurface extends StatelessWidget {
  const _CurrencyDetailSurface({required this.child});

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
      // without it a screen reader lands on the rate's figures with no idea
      // that a detail view opened over the list.
      child: ClipRRect(
        borderRadius: radius,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: AppMessages.currencyDetailTitle,
          child: child,
        ),
      ),
    );
  }
}

/// Breathing room under the last section.
///
/// Sized from `viewPadding` so the final section clears the gesture bar on
/// devices that have one, and from the grid otherwise.
class _CurrencyDetailFooterSpace extends StatelessWidget {
  const _CurrencyDetailFooterSpace();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(
      height: WidthValues.spacingLg + MediaQuery.of(context).viewPadding.bottom,
    ),
  );
}
