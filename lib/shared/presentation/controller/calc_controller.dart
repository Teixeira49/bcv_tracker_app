import 'package:get/get.dart';

import '../../domain/entities/currency.dart';

class CalcController extends GetxController {
  var target = 0.00.obs;
  var result = 0.00.obs;
  var loading = false.obs;
  var calcVes = true.obs;
  var calcCurrencyValue = 0.00.obs;
  var calcCurrencyKeyName = "".obs;

  List<Currency> _availableCurrencies = [];

  void initializeWithCurrencies(List<Currency> currenciesFromWidget) {
    _availableCurrencies = List.from(currenciesFromWidget);

    if (_availableCurrencies.isNotEmpty) {
      calcCurrencyKeyName.value = _availableCurrencies.first.keyName;
      calcCurrencyValue.value = double.parse(
        _availableCurrencies.first.value
            .replaceAll(RegExp(r'[^\d.,]'), '')
            .replaceAll(",", "."),
      );
      print(
        "CalcController: Currency inicializada a ${calcCurrencyValue.value} desde la primera moneda: ${_availableCurrencies.first.name}",
      );
    } else {
      calcCurrencyValue.value = 0.00;
      print(
        "CalcController: La lista de monedas recibida está vacía. Currency establecida a 0.00.",
      );
    }
  }

  void calculateVes() {}

  void calculateCurrency() {}

  String getChangeOrder() =>
      getCalcVes ? "$getCalcCurrency - VES" : "VES - $getCalcCurrency";

  String getCalculateResult() => getCalcVes ? "VES" : getCalcCurrency;

  bool toggleValue(bool value) => calcVes.value = value;

  bool get getCalcVes => calcVes.value;

  String get getCalcCurrency => calcCurrencyKeyName.value;

  List<Currency> get getAvailableCurrencies => _availableCurrencies;

  setCalcCurrency(String? value) => calcCurrencyKeyName.value = value!;
}
