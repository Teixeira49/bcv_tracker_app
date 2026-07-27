import '../../domain/entities/bcv_currencies.dart';
import 'currency_model.dart';

class BcvCurrenciesModel extends BcvCurrencies {
  BcvCurrenciesModel({required super.date, required super.currencies});

  /// Maps a `BcvResponseData` of the backend: `date` is optional and
  /// `currencies` may be absent if the source degraded.
  factory BcvCurrenciesModel.fromJson(Map<String, dynamic> json) {
    final rawCurrencies = json['currencies'];
    final currencies = rawCurrencies is List
        ? rawCurrencies
              .whereType<Map<String, dynamic>>()
              .map(CurrencyModel.fromJson)
              .toList()
        : <CurrencyModel>[];
    return BcvCurrenciesModel(
      date: json['date'] as String?,
      currencies: currencies,
    );
  }

  BcvCurrencies toEntity() {
    return BcvCurrencies(date: date, currencies: currencies);
  }
}
