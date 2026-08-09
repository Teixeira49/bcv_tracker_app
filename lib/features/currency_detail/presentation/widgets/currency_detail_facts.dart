part of '../page/currency_detail_sheet.dart';

/// Everything the entity already carries, stated in full.
///
/// The Home card shows the four fields that fit; this is the rest. `createDate`
/// and `updateDate` in particular travel in every payload and, until #38, were
/// never rendered anywhere.
///
/// Rows the backend did not fill are **not** hidden — they render the `--`
/// placeholder — because a missing timestamp is information: it says the source
/// did not report when it last moved. The single exception is `registeredSince`,
/// dropped when absent, since "when the app first saw this rate" is context
/// rather than data about the rate itself.
class _CurrencyDetailFacts extends StatelessWidget {
  const _CurrencyDetailFacts({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value, Color? color})>
    facts = <({String label, String value, Color? color})>[
      (label: AppMessages.marketLabel, value: currency.platform, color: null),
      (
        label: AppMessages.currencyPairLabel,
        value: CurrencyHelpers.completeCurrencyExchange(currency.keyName),
        color: null,
      ),
      (
        label: AppMessages.currencyCodeLabel,
        value: CurrencyHelpers.castCurrencyDisplayCode(currency.keyName),
        color: null,
      ),
      (
        label: AppMessages.rateTypeLabel,
        value: CurrencyHelpers.isOfficialRate(currency)
            ? AppMessages.officialRate
            : AppMessages.parallelRate,
        color: null,
      ),
      (
        label: AppMessages.variationLabel,
        value: CurrencyHelpers.castTendency(value: currency.tendency),
        color: _tendencyColor(context),
      ),
      (
        label: AppMessages.lastUpdate,
        value: CurrencyHelpers.castOptionalDate(date: currency.updateDate),
        color: null,
      ),
      if (currency.createDate != null)
        (
          label: AppMessages.registeredSince,
          value: CurrencyHelpers.castOptionalDate(date: currency.createDate),
          color: null,
        ),
    ];

    return CurrencyDetailSection(
      title: AppMessages.currencyDetailsSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < facts.length; i++)
            CurrencyDetailFactRow(
              label: facts[i].label,
              value: facts[i].value,
              valueColor: facts[i].color,
              isLast: i == facts.length - 1,
            ),
        ],
      ),
    );
  }

  /// Same reading as `PerformanceIndicatorWidget`: up is good, down is bad, flat
  /// is a warning. `null` gets the neutral text colour — there is no movement to
  /// qualify, only a placeholder.
  Color? _tendencyColor(BuildContext context) {
    final double? tendency = currency.tendency;
    if (tendency == null) {
      return null;
    }
    if (tendency == 0) {
      return ColorValues.textWarningPrimary(context);
    }
    return tendency > 0
        ? ColorValues.textSuccessPrimary(context)
        : ColorValues.textErrorPrimary(context);
  }
}
