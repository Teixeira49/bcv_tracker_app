import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/conversion.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../domain/entities/convertible_currency.dart';

class ConverterController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();

  bool get isLoading => _repository.isLoading.value;

  /// Detail of the last failed refresh, or `null` when the last one succeeded —
  /// the same failure the Home shows, so the converter states stay consistent.
  String? get errorMessage => _repository.errorMessage.value;

  // Single consolidated list of currencies
  final RxList<Currency> currencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;

  Future<void> refreshConverterData() async {
    await _repository.refreshData();
  }

  Currency pivotCurrency = Currency.pivotCurrency;

  final Rx<ConvertibleCurrency> _fromCurrency = ConvertibleCurrency(
    currency: Currency.emptySkeletonizer,
    convertedValue: 0.0,
  ).obs;

  ConvertibleCurrency get fromCurrency => _fromCurrency.value;

  set fromCurrency(ConvertibleCurrency value) => _fromCurrency.value = value;

  final Rx<ConvertibleCurrency> _toCurrency = ConvertibleCurrency(
    currency: Currency.emptySkeletonizer,
    convertedValue: 0.0,
  ).obs;

  ConvertibleCurrency get toCurrency => _toCurrency.value;

  set toCurrency(ConvertibleCurrency value) => _toCurrency.value = value;

  @override
  void onInit() {
    super.onInit();

    // Listen to repository changes to initialize
    ever(_repository.averageCurrencies, (_) => _updateCurrenciesAndInit());
    ever(_repository.bcvCurrencies, (_) => _updateCurrenciesAndInit());

    _updateCurrenciesAndInit();

    ever(_repository.isLoading, (_) => update());
    ever(_repository.errorMessage, (_) => update());
  }

  void _updateCurrenciesAndInit() {
    // Use a composite key for uniqueness based on keyName, platform, and name.
    final Set<String> addedKeys = {};
    final List<Currency> mergedList = [];

    // Helper to create a unique composite key for each currency.
    String compositeKey(Currency c) => '${c.keyName}-${c.platform}-${c.name}';

    // 1. Add Average Currencies
    for (var c in _repository.averageCurrencies) {
      if (addedKeys.add(compositeKey(c))) {
        mergedList.add(c);
      }
    }

    // 2. Add BCV Currencies (excluding duplicates)
    for (var c in _repository.bcvCurrencies) {
      if (addedKeys.add(compositeKey(c))) {
        mergedList.add(c);
      }
    }

    currencies.assignAll(mergedList);
    _initializeSelection();
  }

  void _initializeSelection() {
    // If already initialized, don't overwrite unless empty
    if (fromCurrency.currency.keyName.isNotEmpty &&
        fromCurrency.currency != Currency.emptySkeletonizer) {
      return;
    }

    if (currencies.isNotEmpty) {
      // Default: VES as from, First from list (usually USD) as to.
      // Assuming first item in currencies is the main average USD.

      // Select first available currency that is NOT VES for 'to'

      final initialTo = currencies.firstWhere(
        (c) => c.keyName != 'VES',
        orElse: () => currencies.last,
      );

      fromCurrency = ConvertibleCurrency(
        currency: pivotCurrency,
        convertedValue: initialTo.value,
      );

      toCurrency = ConvertibleCurrency(
        currency: pivotCurrency,
        convertedValue: initialTo.value,
      );

      // Format/Calculate
      calculator(fromCurrency.convertedValue.toString());
    }
  }

  String getRoundedCurrency() =>
      '${fromCurrency.originalValue} ≈ ${toCurrency.originalValue}';

  /// Whether the pair currently selected cannot produce a conversion.
  ///
  /// A rate of `0.0` reaches the app through ordinary paths — [Currency.empty]
  /// declares `value: 0.00`, and the backend answers with a market that has no
  /// data yet — and dividing doubles by zero does not throw in Dart: it yields
  /// `Infinity`, or `NaN` when the dividend is zero too. The views read this
  /// getter to say so instead of painting a meaningless number.
  bool get isConversionUnavailable => !CurrencyConversion.canConvert(
    fromRate: fromCurrency.currency.value,
    toRate: toCurrency.currency.value,
  );

  bool? selectCurrency(Currency selected, {required bool isInput}) {
    final Currency current = isInput
        ? fromCurrency.currency
        : toCurrency.currency;
    final Currency other = isInput
        ? toCurrency.currency
        : fromCurrency.currency;

    // 1. Same currency selected? Do nothing.
    if (current.keyName == selected.keyName &&
        current.platform == selected.platform) {
      return null;
    }

    // 2. Selected the other side's currency? Swap.
    if (other.keyName == selected.keyName) {
      swapCurrencies();
      return true;
    }

    // 3. Define new configuration
    Currency newFrom = isInput ? selected : fromCurrency.currency;
    Currency newTo = !isInput ? selected : toCurrency.currency;

    // 4. Pivot Rule: One must be Pivot (VES).
    if (newFrom.keyName != pivotCurrency.keyName &&
        newTo.keyName != pivotCurrency.keyName) {
      if (isInput) {
        newTo = pivotCurrency;
      } else {
        newFrom = pivotCurrency;
      }
    }

    // 5. Update state with specific logic
    if (!isInput) {
      // Logic: Set "To" to 1, calculate "From"
      toCurrency = ConvertibleCurrency(currency: newTo, convertedValue: 1.0);
      fromCurrency = fromCurrency.copyWith(currency: newFrom);

      // Reverse calculation: From = (ToAmount * ToRate) / FromRate. Same
      // shared maths as [calculator], read the other way round, so the guard
      // against a market with no rate comes for free.
      final double fromAmount = CurrencyConversion.convert(
        amount: 1.0,
        fromRate: newTo.value,
        toRate: newFrom.value,
      );
      fromCurrency = fromCurrency.copyWith(convertedValue: fromAmount);
    } else {
      // Logic: Reset "From" to 1 (standard behavior), calculate "To"
      fromCurrency = ConvertibleCurrency(
        currency: newFrom,
        convertedValue: 1.0,
      );
      toCurrency = toCurrency.copyWith(currency: newTo);

      calculator(fromCurrency.convertedValue.toString());
    }

    update();
    return true;
  }

  void swapCurrencies() {
    final ConvertibleCurrency temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    calculator(fromCurrency.convertedValue.toString());
  }

  void calculator(String value) {
    if (value.isEmpty) {
      fromCurrency = fromCurrency.copyWith(convertedValue: 0.0);
      toCurrency = toCurrency.copyWith(convertedValue: 0.0);
      update();
      return;
    }

    final double amount = CurrencyConversion.parseAmount(value);

    fromCurrency = fromCurrency.copyWith(convertedValue: amount);

    // Zero when the pair cannot convert, which is the honest placeholder;
    // [isConversionUnavailable] is what tells the user why.
    final double result = CurrencyConversion.convert(
      amount: amount,
      fromRate: fromCurrency.currency.value,
      toRate: toCurrency.currency.value,
    );

    toCurrency = toCurrency.copyWith(convertedValue: result);
    update();
  }
}
