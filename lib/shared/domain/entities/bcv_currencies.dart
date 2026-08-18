import 'currency.dart';

/// The official rates, with the one date that applies to all of them.
///
/// A separate entity from a plain `List<Currency>` because the BCV publishes a
/// **single effective date for the whole set**, not one per rate: it fixes a rate
/// for a business day. Folding that date into each [Currency] would repeat it
/// eight times and invite the four copies to drift.
///
/// Built from `BcvCurrenciesModel.toEntity()`.
class BcvCurrencies {
  /// Effective date reported by the BCV. Optional in the backend contract
  /// (`BcvResponseData.date`): it is `null` when no platform date is stored yet.
  ///
  /// A **string**, not a `DateTime`, and deliberately so: it names a *day for
  /// Venezuela*, not an instant. Parsing it to a local `DateTime` would move it
  /// to the previous day for anyone west of Caracas, which is why
  /// `CurrencyHelpers.parseDate` goes through `BackendDate.asPublished` and keeps
  /// the wall clock.
  final String? date;

  /// The official rates for [date] — the dollar, but also the euro, the yuan,
  /// the lira and the rouble.
  final List<Currency> currencies;

  /// Groups [currencies] under the [date] they are all effective on.
  BcvCurrencies({required this.date, required this.currencies});
}
