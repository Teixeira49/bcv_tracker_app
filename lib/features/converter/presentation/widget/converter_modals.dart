part of '../page/converter_page.dart';

/// Opens the currency selector as a bottom sheet.
///
/// The single entry point of the selector: `_SelectCurrencyButton` calls this
/// and does not touch `Get.bottomSheet` or the sheet widget, so the two callers
/// (origin and destination) cannot drift apart, and #39 — the converter
/// embedded in the currency detail — has one call to reuse.
///
/// [isInput] says which side of the conversion is being changed; it is the only
/// thing that differs between the two.
Future<void> showCurrencySelectorSheet({
  required BuildContext context,
  required bool isInput,
}) => showAppBottomSheet<void>(
  context: context,
  sheet: CurrencySelectorSheet(isInput: isInput),
);

/// The currency selector.
///
/// Public so the golden references can render it on its own, and mirroring
/// `CurrencyDetailSheet`. **Open it through [showCurrencySelectorSheet]**, not
/// by constructing it: that is the app's rule for every modal (see
/// `navigation-convention.md`).
///
/// **Was a centred `AlertDialog`** (`BaseModal`, capped at half the screen)
/// until #40: with nine markets the list was long, it floated in the middle of
/// the screen away from the thumb, and it could only be dismissed by tapping
/// outside or on the cross. As a bottom sheet it rises from the edge, takes the
/// height it needs and closes with a drag.
///
/// `BaseModal` is untouched and still serves the settings dialog — this changed
/// the selector's container, not the widget.
class CurrencySelectorSheet extends StatelessWidget {
  const CurrencySelectorSheet({super.key, required this.isInput});

  /// `true` while choosing the currency being converted **from**.
  final bool isInput;

  /// Opens taller than a detail sheet: this is a list to browse, and the point
  /// of #40 is that it uses more usable height than the dialog it replaces.
  static const double _initialExtent = 0.72;

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (ConverterController controller) => BaseBottomSheet(
      semanticsLabel: AppMessages.selectCurrency,
      initialExtent: _initialExtent,
      slivers: <Widget>[
        SliverToBoxAdapter(child: _CurrencySelectorTitle()),
        // The categories are the ones the dialog had: the base currency first,
        // the markets after. #31 (favourites) and #41 (search) add to this
        // list; they do not replace it.
        SliverToBoxAdapter(
          child: _CurrencySelectorCategory(
            label: AppMessages.originalCurrency,
            child: _CurrencyTileButton(
              currency: controller.pivotCurrency,
              onTap: () => _select(
                controller: controller,
                currency: controller.pivotCurrency,
              ),
            ),
          ),
        ),
        if (controller.currencies.isNotEmpty)
          SliverToBoxAdapter(
            child: _CurrencySelectorCategory(label: AppMessages.mainMarkets),
          ),
        // A `SliverList`, not a `Column` in an adapter: the rows are built as
        // they scroll into view, and it keeps the sheet on the single scroll
        // chain `BaseBottomSheet` requires.
        SliverList.builder(
          itemCount: controller.currencies.length,
          itemBuilder: (BuildContext context, int index) {
            final Currency currency = controller.currencies[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: WidthValues.spacingMd),
              child: _CurrencyTileButton(
                currency: currency,
                onTap: () =>
                    _select(controller: controller, currency: currency),
              ),
            );
          },
        ),
      ],
    ),
  );

  /// Applies the choice and closes only if the controller accepted it.
  ///
  /// `selectCurrency` returns `null` when the tap changes nothing and `false`
  /// when the pair would be invalid; closing on either would look like the
  /// selection worked.
  void _select({
    required ConverterController controller,
    required Currency currency,
  }) {
    final bool? accepted = controller.selectCurrency(
      currency,
      isInput: isInput,
    );
    if (accepted != null && accepted) {
      Get.back<void>();
    }
  }
}

/// Heading of the sheet.
///
/// The dialog carried its title in `BaseModal`; a bottom sheet's pinned bar
/// holds no text (it has a fixed extent and could not grow with the system font
/// scale), so the title scrolls with the content instead.
class _CurrencySelectorTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      WidthValues.spacingMd,
      WidthValues.spacingXxs,
      WidthValues.spacingMd,
      WidthValues.spacingXs,
    ),
    child: Text(
      AppMessages.selectCurrency,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: ColorValues.textPrimary(context),
      ),
    ),
  );
}

/// A category label and, optionally, the single row that belongs to it.
///
/// Wraps `_CurrenciesCategoryTitleWidget` with the sheet's horizontal padding,
/// which the dialog got for free from `BaseModal`'s content margin.
class _CurrencySelectorCategory extends StatelessWidget {
  const _CurrencySelectorCategory({required this.label, this.child});

  final String label;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: WidthValues.spacingMd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _CurrenciesCategoryTitleWidget(label: label, includeDivider: false),
        if (child != null) ...<Widget>[
          SizedBox(height: WidthValues.spacingXxs),
          child!,
        ],
      ],
    ),
  );
}
