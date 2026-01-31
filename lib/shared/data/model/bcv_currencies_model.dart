import '../../domain/entities/bcv_currencies.dart';
import 'currency_model.dart';

class BcvCurrenciesModel extends BcvCurrencies {
  BcvCurrenciesModel({required super.date, required super.currencies});

  factory BcvCurrenciesModel.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    final currencies = (json['currencies'] as List)
        .map((e) => CurrencyModel.fromJson(e))
        .toList();
    return BcvCurrenciesModel(date: date, currencies: currencies);
  }

  BcvCurrencies toEntity() {
    return BcvCurrencies(date: date, currencies: currencies);
  }
}
