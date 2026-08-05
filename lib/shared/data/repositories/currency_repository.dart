import 'dart:developer';

import 'package:get/get.dart';
import '../../../core/network/api_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/dollar_repositories.dart';
import '../mapper/currency_normalizer.dart';

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

  /// Detail of the last failed refresh, or `null` when the last one succeeded.
  ///
  /// Without this the failures only reached the console: a broken contract (the
  /// 404 after the `/api/v1` move, a source answering 502) left the UI showing
  /// the skeleton placeholders forever, with no way for the user to tell.
  final RxnString errorMessage = RxnString();

  /// Whether each list already holds real rates. While `false` it still holds
  /// the `emptySkeletonizer` placeholders, which must not be shown as data.
  final RxBool hasAverageData = false.obs;
  final RxBool hasBcvData = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      // eagerError is off by default: both fetches complete even if one fails,
      // so a partial refresh still lands its data before the error surfaces.
      await Future.wait([getAveragedCurrencies(), getBCVCurrencies()]);
      errorMessage.value = null;
    } catch (e, s) {
      errorMessage.value = _describe(e);
      log(
        'Error fetching data: $e',
        name: 'CurrencyRepository.refreshData()',
        error: e,
        stackTrace: s,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAveragedCurrencies() async {
    final List<Currency> result = await _dollarRepository.getCurrentDollar();
    // saved-currencies answers with every market the backend knows, one row per
    // P2P side and, from the database, occasional repeats; see
    // [CurrencyNormalizer].
    averageCurrencies.assignAll(CurrencyNormalizer.forAverageTab(result));
    hasAverageData.value = true;
  }

  Future<void> getBCVCurrencies() async {
    // The currentBCVDollar endpoint returns every official BCV rate plus the
    // effective date reported by the institution.
    final BcvCurrencies result = await _dollarRepository.getCurrentBCVDollar();
    bcvCurrencies.assignAll(result.currencies);
    bcvCurrentDate.value = result.date ?? '';
    hasBcvData.value = true;
  }

  /// User-facing detail of a failure: [ApiException] already carries the
  /// `message` of the backend error envelope.
  String _describe(Object error) =>
      error is ApiException ? error.message : error.toString();
}
