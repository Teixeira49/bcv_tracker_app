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
/// `BaseModal` is untouched — this changed the selector's container, not the
/// widget. It served the settings dialog until #37 turned that into a screen,
/// and now waits for the next short, interrupting decision the app needs.
class CurrencySelectorSheet extends StatefulWidget {
  const CurrencySelectorSheet({super.key, required this.isInput});

  /// `true` while choosing the currency being converted **from**.
  final bool isInput;

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

/// Holds the search query (#41).
///
/// Local state, not `ConverterController`: what is typed into a filter belongs
/// to the modal that shows it and dies with it, and parking it on the
/// controller would mean remembering to clear it on every close. It survives
/// the rebuilds the sheet performs while being dragged because the element is
/// reused — the same reason `_CurrencyInputFieldCard` owns its own
/// `TextEditingController`.
class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  final TextEditingController _search = TextEditingController();

  /// Opens taller than a detail sheet: this is a list to browse, and the point
  /// of #40 is that it uses more usable height than the dialog it replaces.
  static const double _initialExtent = 0.72;

  String get _query => _search.text;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// The rates that match the query, **in the order they already had**.
  ///
  /// Filtering with `where` rather than re-sorting is what satisfies #41's
  /// "favourites keep their order inside the results": the order is decided
  /// upstream, so when #31 sorts favourites first the results inherit that for
  /// free and this needs no change.
  List<Currency> _matching(List<Currency> currencies) => currencies
      .where(
        (Currency currency) => SearchText.matches(_query, <String>[
          // What the row shows, which is what the user is reading while they
          // type: the code and the name on the title, the market underneath.
          // #41 defers a dedicated ISO-code search — relevance ordering, exact
          // matches first — and that is still deferred; this only means the
          // code is not invisible to a filter that sits above it.
          CurrencyHelpers.castCurrencyDisplayCode(currency.keyName),
          CurrencyHelpers.castCurrencyDisplayName(currency),
          currency.platform,
        ]),
      )
      .toList();

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (ConverterController controller) {
      final List<Currency> matches = _matching(controller.currencies);
      final bool pivotMatches = SearchText.matches(_query, <String>[
        CurrencyHelpers.castCurrencyDisplayCode(
          controller.pivotCurrency.keyName,
        ),
        CurrencyHelpers.castCurrencyDisplayName(controller.pivotCurrency),
        controller.pivotCurrency.platform,
      ]);
      final bool nothingFound = matches.isEmpty && !pivotMatches;

      return BaseBottomSheet(
        semanticsLabel: AppMessages.selectCurrency,
        initialExtent: _initialExtent,
        slivers: <Widget>[
          SliverToBoxAdapter(child: _CurrencySelectorTitle()),
          SliverToBoxAdapter(
            child: _CurrencySearchField(
              controller: _search,
              onChanged: (_) => setState(() {}),
            ),
          ),
          // The categories are the ones the dialog had: the base currency
          // first, the markets after. #31 (favourites) adds to this list; it
          // does not replace it.
          if (pivotMatches)
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
          if (matches.isNotEmpty)
            SliverToBoxAdapter(
              child: _CurrencySelectorCategory(label: AppMessages.mainMarkets),
            ),
          // A `SliverList`, not a `Column` in an adapter: the rows are built as
          // they scroll into view, and it keeps the sheet on the single scroll
          // chain `BaseBottomSheet` requires.
          SliverList.builder(
            itemCount: matches.length,
            itemBuilder: (BuildContext context, int index) {
              final Currency currency = matches[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: WidthValues.spacingMd,
                ),
                child: _CurrencyTileButton(
                  currency: currency,
                  onTap: () =>
                      _select(controller: controller, currency: currency),
                ),
              );
            },
          ),
          // A state, not a blank panel: the list is empty because the filter
          // excluded everything, and saying so is the difference between "no
          // match" and "something broke".
          if (nothingFound)
            SliverToBoxAdapter(
              child: AppStateView.noResults(
                message: AppMessages.noSearchResultsMessage(_query.trim()),
              ),
            ),
        ],
      );
    },
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
      isInput: widget.isInput,
    );
    if (accepted != null && accepted) {
      Get.back<void>();
    }
  }
}

/// The search box (#41).
///
/// **Not auto-focused, deliberately** — #41 left the decision open. Opening the
/// keyboard on arrival would cover the list the sheet exists to show, and most
/// openings are "pick the one I can see", not "search". The user taps the field
/// when they want to type, and the sheet rides above the keyboard from there.
class _CurrencySearchField extends StatelessWidget {
  const _CurrencySearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      WidthValues.spacingMd,
      WidthValues.spacingXxs,
      WidthValues.spacingMd,
      WidthValues.spacingXs,
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: AppMessages.searchCurrencyHint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        // Only once there is something to clear: an X on an empty field is a
        // control that does nothing.
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: AppMessages.clearSearchAction,
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: ColorValues.utilityBrand50(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidthValues.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
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
