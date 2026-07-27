import 'currency.dart';

class BcvCurrencies {
  /// Effective date reported by the BCV. Optional in the backend contract
  /// (`BcvResponseData.date`): it is `null` when no platform date is stored yet.
  final String? date;
  final List<Currency> currencies;

  BcvCurrencies({required this.date, required this.currencies});
}
