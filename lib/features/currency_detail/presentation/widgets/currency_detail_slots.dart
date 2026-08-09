part of '../page/currency_detail_sheet.dart';

// -----------------------------------------------------------------------------
// Reserved sections of the currency detail sheet
// -----------------------------------------------------------------------------
//
// #38 builds the container and the two sections that only need data the app
// already has. The other three were left out **because they are not ready
// yet**, not because they do not belong here: each has its own issue, and this
// file is where they land.
//
// Every slot is already wired into the sheet's sliver list in its final
// position, holds the rate it has to render, and renders nothing. Filling one
// means replacing the body of its `build` — no change to the sheet, to the
// order of the sections, or to whoever opens it.
//
// ## The contract a slot has to honour
//
// 1. **Return a sliver.** The sheet's `CustomScrollView` takes slivers; a box
//    widget goes inside a `SliverToBoxAdapter`.
// 2. **Never nest a scroll view.** The sheet's drag and its scroll are the same
//    gesture chain (see `_CurrencyDetailBody`). A `ListView`, a
//    `SingleChildScrollView` or a chart with its own vertical scroll breaks it
//    and the sheet starts closing when the user meant to scroll. Lay content
//    out with `Column`, or emit several slivers.
// 3. **Compose `CurrencyDetailSection`** so the title, the card and the rhythm
//    match the rest of the sheet.
// 4. **Render nothing when there is no data.** #38 requires the detail to look
//    complete without these sections; an empty chart card is worse than no
//    chart. Return the empty sliver instead of a placeholder.
// 5. **No text literals.** Every label goes through `AppMessages` in the ten
//    languages (`i18n-convention.md`).
// 6. **State goes in `CurrencyDetailController`**, not in a `StatefulWidget`:
//    a chart range or a converter amount has to survive the rebuilds the sheet
//    does while being dragged.

/// The empty sliver every unfilled slot renders.
const Widget _noSection = SliverToBoxAdapter(child: SizedBox.shrink());

/// Historical evolution of the rate — **reserved for [#5]**.
///
/// Blocked upstream: there is no historical endpoint yet
/// (`bcv_tracker_backend#14`). When it exists, the series is fetched by
/// `CurrencyDetailController` (which already owns the sheet's lifecycle) and
/// rendered here, keyed by [currency] `keyName` + `platform` — the pair that
/// identifies a rate across markets.
///
/// Sits between the header and the facts on purpose: the chart answers "where
/// is this going", which is what someone opening a rate looks for first; the
/// table underneath answers "what exactly is this".
///
/// See the contract at the top of this file before filling it in.
class CurrencyDetailChartSlot extends StatelessWidget {
  const CurrencyDetailChartSlot({super.key, required this.currency});

  /// The rate to chart. Handed over by the sheet; a snapshot, not a live value.
  final Currency currency;

  @override
  Widget build(BuildContext context) => _noSection;
}

/// Share and save — **reserved for [#7]**.
///
/// A row of actions on the rate: share it as text or image, pin it as a
/// favourite. Saving needs somewhere to persist to — `SettingsController` and
/// its `SharedPreferences` are the app's only persistence today, so the list of
/// saved rates belongs there rather than in a new store.
///
/// Placed under the facts so the sheet reads as *information first, actions
/// after*.
///
/// See the contract at the top of this file before filling it in.
class CurrencyDetailActionsSlot extends StatelessWidget {
  const CurrencyDetailActionsSlot({super.key, required this.currency});

  /// The rate the actions operate on.
  final Currency currency;

  @override
  Widget build(BuildContext context) => _noSection;
}

/// Converter dedicated to this rate — **reserved for [#39]**.
///
/// An embedded amount field that converts against [currency] only, without
/// making the user pick the pair the way the Converter tab does. The pivot maths
/// already exist in `ConverterController`; the section should reuse them rather
/// than recompute a rate, so a fix to the rounding lands in both places at once.
///
/// Last section of the sheet: it is the one that grows tallest and the one a
/// keyboard covers, and the sheet expands to `_maxExtent` to make room.
///
/// See the contract at the top of this file before filling it in — point 2
/// matters most here, since a text field inside the sheet scrolls into view
/// through the same controller.
class CurrencyDetailConverterSlot extends StatelessWidget {
  const CurrencyDetailConverterSlot({super.key, required this.currency});

  /// The rate to convert against.
  final Currency currency;

  @override
  Widget build(BuildContext context) => _noSection;
}
