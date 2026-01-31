import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../domain/entities/convertible_currency.dart';

class ConverterController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();

  bool get isLoading => _repository.isLoading.value;

  // Single consolidated list of currencies
  final RxList<Currency> currencies = List.generate(5, (e) => Currency.emptySkeletonizer).obs;

  Future<void> refreshConverterData() async {
    await _repository.refreshData();
  }

  Currency pivotCurrency = Currency(
    keyName: 'VES',
    name: 'Banco Central de Venezuela',
    value: '1.00',
  );

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
  }

  void _updateCurrenciesAndInit() {
    // Merge lists directly without extra filtering logic in UI
    final Set<String> addedKeys = {};
    final List<Currency> mergedList = [];

    // 1. Add Pivot if not already handled?
    // Usually pivot is distinct, but let's assume it should be available for selection.
    // In original code, pivot was separate.
    // Plan says "Merge average and bcv". Pivot is usually VES.

    // 2. Add Average Currencies
    for (var c in _repository.averageCurrencies) {
      if (addedKeys.add(c.keyName)) {
        mergedList.add(c);
      }
    }

    // 3. Add BCV Currencies (excluding duplicates)
    for (var c in _repository.bcvCurrencies) {
      if (addedKeys.add(c.keyName)) {
        mergedList.add(c);
      }
    }

     currencies.assignAll(mergedList);
    _initializeSelection();
  }

  void _initializeSelection() {
    // If already initialized, don't overwrite unless empty
    if (fromCurrency.currency.keyName.isNotEmpty &&
        fromCurrency.currency != Currency.emptySkeletonizer)
      return;

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
        convertedValue: double.parse(initialTo.value),
      );

      toCurrency = ConvertibleCurrency(
        currency: initialTo,
        convertedValue: 1.0,
      );

      // Format/Calculate
      calculator(fromCurrency.convertedValue.toString());
    }
  }

  String getRoundedCurrency() =>
      "${fromCurrency.originalValue} ≈ ${toCurrency.originalValue}";

  bool? selectCurrency(Currency selected, {required bool isInput}) {
    final Currency current = isInput
        ? fromCurrency.currency
        : toCurrency.currency;
    final Currency other = isInput
        ? toCurrency.currency
        : fromCurrency.currency;

    // 1. Same currency selected? Do nothing.
    if (current.keyName == selected.keyName) return null;

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

      // Reverse Calculation: From = (ToAmount * ToRate) / FromRate
      final double toAmount = 1.0;
      final double toRate = double.parse(newTo.value.replaceAll(',', '.'));
      final double fromRate = double.parse(newFrom.value.replaceAll(',', '.'));

      final double fromAmount = (toAmount * toRate) / fromRate;
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

    String formattedValue = value.replaceAll(',', '.');
    if (formattedValue == '.') formattedValue = '0';

    final double amount = double.tryParse(formattedValue) ?? 0.0;

    fromCurrency = fromCurrency.copyWith(convertedValue: amount);

    final double fromRate = double.parse(
      fromCurrency.currency.value.replaceAll(',', '.'),
    );
    final double toRate = double.parse(
      toCurrency.currency.value.replaceAll(',', '.'),
    );

    final double result = (amount * fromRate) / toRate;

    toCurrency = toCurrency.copyWith(convertedValue: result);
    update();
  }
}
