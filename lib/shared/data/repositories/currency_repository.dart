import 'dart:developer';

import 'package:get/get.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/dollar_repositories.dart';

class CurrencyRepository extends GetxService {
  final IDollarRepository _dollarRepository = Get.find<IDollarRepository>();

  final RxList<Currency> averageCurrencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;
  final RxList<Currency> bcvCurrencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;
  final RxString bcvCurrentDate = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([getAveragedCurrencies(), getBCVCurrencies()]);
    } catch (e, s) {
      log(
        "Error fetching data: $e",
        name: "CurrencyRepository.refreshData()",
        error: e,
        stackTrace: s,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAveragedCurrencies() async {
    try {
      final List<Currency> result = await _dollarRepository.getCurrentDollar();
      averageCurrencies.assignAll(result);
    } catch (e, s) {
      log(
        "Error getting average currencies: $e",
        name: "CurrencyRepository.getAveragedCurrencies()",
        error: e,
        stackTrace: s,
      );
      // Optionally keep existing data or show error state
    }
  }

  Future<void> getBCVCurrencies() async {
    try {
      // Logic for BCV needs to check requirements.
      // The currentBCVDollar endpoint might return list of all bank rates (Official)
      // We assign it to bcvCurrencies.
      final BcvCurrencies result = await _dollarRepository
          .getCurrentBCVDollar();
      bcvCurrencies.assignAll(result.currencies);
      bcvCurrentDate.value = result.date;
    } catch (e, s) {
      log(
        "Error getting BCV currencies: $e",
        name: "CurrencyRepository.getAveragedCurrencies()",
        error: e,
        stackTrace: s,
      );
    }
  }
}
