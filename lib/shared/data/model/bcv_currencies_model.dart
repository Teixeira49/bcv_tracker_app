import '../../domain/entities/bcv_currencies.dart';
import 'currency_model.dart';

/// Wire format of the official rates, and the seam back to `BcvCurrencies`.
///
/// **It extends the entity**, which is convenient and is also the trap: a model
/// satisfies every signature that asks for an entity, so the compiler cannot
/// tell you when one leaks upwards. [currencyModels] and [toEntity] exist
/// precisely to make that conversion checkable — see their own comments.
class BcvCurrenciesModel extends BcvCurrencies {
  /// Takes the deserialised rows at their real type.
  ///
  /// [currencies] is a `List<CurrencyModel>` on purpose: the inherited field is
  /// declared `List<Currency>`, and accepting that type here is what let models
  /// travel upward unnoticed. See [currencyModels].
  BcvCurrenciesModel({
    required super.date,
    required List<CurrencyModel> currencies,
  }) : currencyModels = currencies,
       super(currencies: currencies);

  /// The deserialised rows, kept at their real type.
  ///
  /// The inherited `currencies` is declared `List<Currency>`, which is exactly
  /// what hid the leak: a `List<CurrencyModel>` satisfies it, so the compiler
  /// could not tell whether [toEntity] had converted anything. Reading the
  /// models from here makes the conversion below type-checked instead of a
  /// convention someone has to remember.
  final List<CurrencyModel> currencyModels;

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

  /// Converts to the domain entity, **including every element of the list**.
  ///
  /// Handing `currencies` over untouched used to compile perfectly — a
  /// `List<CurrencyModel>` satisfies a `List<Currency>` because the model
  /// extends the entity — and let objects of the data layer travel all the way
  /// into `CurrencyRepository.bcvCurrencies`, which the whole BCV UI reads.
  /// Nothing would have failed until `CurrencyModel` grew state of its own.
  BcvCurrencies toEntity() {
    return BcvCurrencies(
      date: date,
      currencies: currencyModels
          .map((CurrencyModel model) => model.toEntity())
          .toList(),
    );
  }
}
