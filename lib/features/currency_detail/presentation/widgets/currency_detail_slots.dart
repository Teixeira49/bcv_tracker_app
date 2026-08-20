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
// 6. **State of record goes in `CurrencyDetailController`**, not in a
//    `StatefulWidget`: a chart range or a converter amount has to survive the
//    rebuilds the sheet does while being dragged. A widget may still own the
//    plumbing that binds to it — the converter keeps a `TextEditingController`
//    seeded from the controller and written only towards it — but the value
//    anyone else reads lives on the controller.
// 7. **Take the rate from the slot's `currency`, not from the controller**,
//    even though they hold the same thing at runtime: the sheet renders what it
//    was handed, and a section that reads a second source is a sheet that shows
//    one rate and operates on another the day the two drift.

/// The empty sliver every unfilled slot renders.
const Widget _noSection = SliverToBoxAdapter(child: SizedBox.shrink());

/// Historical evolution of the rate — **reserved for [#5](https://github.com/Teixeira49/bcv_tracker_app/issues/5)**.
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

/// Share and save — **reserved for [#7](https://github.com/Teixeira49/bcv_tracker_app/issues/7)**.
///
/// A row of actions on the rate: share it as text or image, pin it as a
/// favourite. Saving needs somewhere to persist to — `SettingsController` and
/// its `SharedPreferences` are the app's only persistence today, so the list of
/// saved rates belongs there rather than in a new store.
///
/// Placed under the facts so the sheet reads as *information first, actions
/// after*.
///
/// **Still empty after [#103](https://github.com/Teixeira49/bcv_tracker_app/issues/103).** That issue's one action —hand the rate to the
/// full converter— is not an action *on the rate*, it is a continuation of the
/// quick converter, so it lives in that section's heading row instead of here.
/// See [_OpenInConverterButton].
///
/// See the contract at the top of this file before filling it in.
class CurrencyDetailActionsSlot extends StatelessWidget {
  const CurrencyDetailActionsSlot({super.key, required this.currency});

  /// The rate the actions operate on.
  final Currency currency;

  @override
  Widget build(BuildContext context) => _noSection;
}

/// Sends the detailed rate to the full converter (#103).
///
/// **Sits in the heading row of the converter section, opposite its title.**
/// That is what `CurrencyDetailSection.trailing` is for — a control *of* the
/// section rather than content *in* it — and it puts the button where the thing
/// it continues already is: finish the quick sum, then carry it over. A row of
/// its own above the converter said the same thing further from it, and cost a
/// section heading of its own to say it.
class _OpenInConverterButton extends StatelessWidget {
  const _OpenInConverterButton({required this.rate});

  final Currency rate;

  /// Index of the converter tab in `DashboardPage.pages`.
  ///
  /// Tabs are **not routes** (`navigation-convention.md`): getting to the
  /// converter is moving `NavigationController.selectedIndex`, never
  /// `Get.toNamed`.
  static const int _converterTabIndex = 1;

  /// Carries the rate, the amount and the direction to the full converter, then
  /// gets out of the way.
  ///
  /// **The order of the three steps is load, close, switch, and it matters.**
  /// Closing the sheet runs `CurrencyDetailController.dismiss`, which wipes the
  /// amount — so the handoff has to read it first or it arrives empty. And the
  /// tab changes last because the sheet is a route on top of the dashboard:
  /// switching underneath it would happen behind a panel the user is still
  /// looking at.
  ///
  /// This widget resolves both controllers, which is the presentation layer
  /// wiring two features together — the place wiring belongs. Neither
  /// controller learns about the other, and the arithmetic stays where it
  /// already was: `CurrencyConversion` is shared, so what crosses here is a
  /// **selection**, not a calculation.
  void _openInConverter() {
    final CurrencyDetailController detail =
        Get.find<CurrencyDetailController>();

    Get.find<ConverterController>().preloadFromDetail(
      rate: rate,
      amount: detail.amountInput,
      reversed: detail.isReversed,
    );

    Get.back<void>();
    Get.find<NavigationController>().changeIndex(_converterTabIndex);
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: _openInConverter,
    child: Text(AppMessages.openInConverterAction),
  );
}

/// Converter dedicated to this rate — **filled by [#39](https://github.com/Teixeira49/bcv_tracker_app/issues/39)**.
///
/// An amount field that converts against [currency] only: the sheet already
/// fixed which currency this is about, so offering a selector here would be
/// asking a question the context answered. The direction flips between "this
/// rate into bolívares" and back.
///
/// The maths are **not** reimplemented. Both this and the full converter call
/// `CurrencyConversion`, which is what makes #39's "exactly the same result"
/// verifiable instead of asserted — a test runs an amount through both and
/// compares.
///
/// Last section of the sheet: it is the one a keyboard covers, and the sheet
/// expands to its maximum extent to make room.
class CurrencyDetailConverterSlot extends StatelessWidget {
  const CurrencyDetailConverterSlot({super.key, required this.currency});

  /// The rate to convert against.
  final Currency currency;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: GetBuilder<CurrencyDetailController>(
      builder: (CurrencyDetailController controller) => CurrencyDetailSection(
        title: AppMessages.quickConverterSection,
        // Opposite the title, in the heading row: the way out to the full
        // converter, carrying whatever was typed here (#103).
        trailing: _OpenInConverterButton(rate: currency),
        child: _CurrencyDetailConverterBody(
          controller: controller,
          rate: currency,
        ),
      ),
    ),
  );
}

/// The amount in, the result out, and the button that swaps them.
class _CurrencyDetailConverterBody extends StatefulWidget {
  const _CurrencyDetailConverterBody({
    required this.controller,
    required this.rate,
  });

  final CurrencyDetailController controller;

  /// The rate the sheet is detailing. Passed down rather than read off the
  /// controller so the section converts exactly what the sheet shows.
  final Currency rate;

  @override
  State<_CurrencyDetailConverterBody> createState() =>
      _CurrencyDetailConverterBodyState();
}

class _CurrencyDetailConverterBodyState
    extends State<_CurrencyDetailConverterBody> {
  /// Owns the field's text; the value of record lives on the controller.
  ///
  /// The two are seeded once and then only ever written **towards** the
  /// controller. Writing back would fight the typing: `1.` parses to the same
  /// number as `1.0` but is not the same text, and replacing it would move the
  /// caret out from under the user.
  late final TextEditingController _amount = TextEditingController(
    text: widget.controller.amountInput,
  );

  @override
  void didUpdateWidget(covariant _CurrencyDetailConverterBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The controller changed the amount without the field doing it: a swap
    // carried the result over, or the sheet was dismissed. Typing never lands
    // here — `onChanged` writes the same text the field already holds — so this
    // cannot fight the caret.
    final String owned = widget.controller.amountInput;
    if (owned != _amount.text) {
      _amount.value = TextEditingValue(
        text: owned,
        selection: TextSelection.collapsed(offset: owned.length),
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyDetailController controller = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ConverterRow(
          currency: controller.fromCurrencyFor(widget.rate),
          child: TextField(
            controller: _amount,
            onChanged: controller.setAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // The same guard the full converter got in #40: the keyboard type
            // is a hint to the on-screen keyboard, not a constraint on what a
            // hardware one, a paste or a dictation can send.
            inputFormatters: const <TextInputFormatter>[AmountInputFormatter()],
            // Flutter scrolls the *caret* into view when the keyboard opens,
            // which left the field visible and the result right under the fold:
            // you typed an amount and could not see the answer. This asks for
            // the swap button and the result row to be kept on screen with it.
            scrollPadding: EdgeInsets.only(bottom: WidthValues.spacing7xl),
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: AppMessages.amountLabel,
            ),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ColorValues.textPrimary(context),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: IconButton(
            onPressed: () => controller.toggleDirection(widget.rate),
            tooltip: AppMessages.invertConversionAction,
            icon: const Icon(Icons.swap_vert_rounded),
            color: ColorValues.fgBrandSecondary(context),
          ),
        ),
        _ConverterRow(
          currency: controller.toCurrencyFor(widget.rate),
          child: Text(
            CurrencyHelpers.castAmount(
              value: controller.convertedValueFor(widget.rate),
              maxDecimals: controller.amountDecimals,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ColorValues.textPrimary(context),
            ),
          ),
        ),
        // Only on the side that shows a result: saying it twice is noise, and
        // a bare 0 there would read as a legitimate conversion.
        if (!controller.canConvertFor(widget.rate)) ...<Widget>[
          SizedBox(height: WidthValues.spacingXs),
          Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 16,
                color: ColorValues.textWarningPrimary(context),
              ),
              SizedBox(width: WidthValues.spacingXs),
              Flexible(
                child: Text(
                  AppMessages.conversionUnavailable,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorValues.textWarningPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// One side of the conversion: which currency it is, and the figure.
class _ConverterRow extends StatelessWidget {
  const _ConverterRow({required this.currency, required this.child});

  final Currency currency;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Text(
        CurrencyHelpers.castCurrencySymbolText(currencyCode: currency.keyName),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ColorValues.textSecondary(context),
        ),
      ),
      SizedBox(width: WidthValues.spacingXs),
      Flexible(
        child: Text(
          CurrencyHelpers.castCurrencyDisplayCode(currency.keyName),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: ColorValues.textTertiary(context),
          ),
        ),
      ),
      SizedBox(width: WidthValues.spacingXs),
      Expanded(flex: 3, child: child),
    ],
  );
}
