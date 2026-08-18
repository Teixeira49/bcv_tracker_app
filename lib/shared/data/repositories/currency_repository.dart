import 'package:get/get.dart';
import '../../../core/i18n/app_messages.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_error_messages.dart';
import '../../../core/network/api_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/dollar_repositories.dart';
import '../mapper/currency_normalizer.dart';

/// The app's live exchange-rate state, shared by every feature.
///
/// A **`GetxService` registered `permanent`** in `initial_bindings.dart`, and the
/// only place `Rx` rate state lives. Home, the converter and the detail sheet all
/// observe this one instance rather than fetching for themselves, which is what
/// keeps two screens from showing two different numbers for the same rate.
///
/// **Feature controllers do not expose these observables.** They read them and
/// bridge changes with `ever(...) => update()`, so views use `GetBuilder` and
/// never name an `Rx` type. That boundary is a retained decision — the audit
/// proposed granular `Obx` and it was declined in
/// [#60](https://github.com/Teixeira49/bcv_tracker_app/issues/60) — and its price
/// is that **every worker must be disposed in `onClose`**
/// ([#45](https://github.com/Teixeira49/bcv_tracker_app/issues/45)): `get` 4.7.3
/// disposes none on its own, and this service outliving its observers means
/// listeners otherwise accumulate on each `fenix` recreation.
///
/// See `.agents/skills/getx-architecture`.
class CurrencyRepository extends GetxService {
  final IDollarRepository _dollarRepository = Get.find<IDollarRepository>();

  /// Parallel market rates, one per market and currency.
  ///
  /// Starts as five [Currency.emptySkeletonizer] placeholders so the first frame
  /// can draw a shimmering list the right shape. They are **not data** — check
  /// [hasAverageData] before treating them as such, which is also why widget
  /// tests clear these lists instead of letting the placeholder image resolve.
  final RxList<Currency> averageCurrencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;

  /// Official BCV rates. Same placeholder contract as [averageCurrencies], with
  /// [hasBcvData] as its flag.
  final RxList<Currency> bcvCurrencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;

  /// Effective date the BCV reported, as published — empty until the first
  /// successful refresh.
  ///
  /// Kept as the raw string for the reason `BcvCurrencies.date` explains: it
  /// names a day for Venezuela, and converting it to a local `DateTime` moves it
  /// a day west of Caracas.
  final RxString bcvCurrentDate = ''.obs;

  /// Whether a refresh is in flight. Drives the shimmer and disables retry.
  final RxBool isLoading = false.obs;

  /// Detail of the last failed refresh, or `null` when the last one succeeded.
  ///
  /// Without this the failures only reached the console: a broken contract (the
  /// 404 after the `/api/v1` move, a source answering 502) left the UI showing
  /// the skeleton placeholders forever, with no way for the user to tell.
  final RxnString errorMessage = RxnString();

  /// Whether each list already holds real rates. While `false` it still holds
  /// the `emptySkeletonizer` placeholders, which must not be shown as data.
  ///
  /// A flag rather than an `isEmpty` check, because the lists are **never**
  /// empty: they start full of placeholders, so emptiness cannot distinguish
  /// "still loading" from "loaded and genuinely nothing there".
  final RxBool hasAverageData = false.obs;

  /// See [hasAverageData]; this is its counterpart for [bcvCurrencies].
  final RxBool hasBcvData = false.obs;

  /// Kicks off the first fetch.
  ///
  /// `onReady` rather than `onInit` deliberately: it runs after the first frame,
  /// so the shimmering placeholders are already on screen when the request
  /// starts instead of the app opening on a blank panel.
  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  /// Refetches both sides and republishes the state.
  ///
  /// **A partial failure is a real outcome, not an error.** The two requests hit
  /// different upstream sources, so one can answer while the other is down; the
  /// side that succeeded is published and [errorMessage] describes the side that
  /// did not. Awaiting them together without `eagerError` is what makes that
  /// possible — see the comment in the body.
  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      // eagerError is off by default: both fetches complete even if one fails,
      // so a partial refresh still lands its data before the error surfaces.
      await Future.wait([getAveragedCurrencies(), getBCVCurrencies()]);
      errorMessage.value = null;
    } catch (e, s) {
      // The cause is logged here, at the boundary where it becomes UI state:
      // `errorMessage` gets the user-facing text, the log keeps the real
      // exception and stack for diagnosis.
      errorMessage.value = _describe(e);
      AppLogger.error(
        'Error fetching data: $e',
        name: 'CurrencyRepository.refreshData',
        error: e,
        stackTrace: s,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches the parallel rates, normalises them and publishes them.
  ///
  /// Public so [refreshData] can await the two sides independently and let one
  /// succeed while the other fails. Throws whatever the repository throws — the
  /// caller is what decides that a partial failure is still a usable state.
  Future<void> getAveragedCurrencies() async {
    final List<Currency> result = await _dollarRepository.getCurrentDollar();
    // saved-currencies answers with every market the backend knows, one row per
    // P2P side and, from the database, occasional repeats; see
    // [CurrencyNormalizer].
    averageCurrencies.assignAll(CurrencyNormalizer.forAverageTab(result));
    hasAverageData.value = true;
  }

  /// Fetches the official rates and their effective date, and publishes both.
  ///
  /// The counterpart of [getAveragedCurrencies], with the same contract: it throws
  /// rather than swallowing, so [refreshData] can report which side went down.
  Future<void> getBCVCurrencies() async {
    // The currentBCVDollar endpoint returns every official BCV rate plus the
    // effective date reported by the institution.
    final BcvCurrencies result = await _dollarRepository.getCurrentBCVDollar();
    bcvCurrencies.assignAll(result.currencies);
    bcvCurrentDate.value = result.date ?? '';
    hasBcvData.value = true;
  }

  /// User-facing message for a failure. An [ApiException] is mapped by its kind
  /// and HTTP code to a translated app message (`apiErrorMessage`); the
  /// backend's own developer-oriented text stays in the log (#19). Anything
  /// unexpected degrades to a controlled generic message, never a raw
  /// `toString()`.
  String _describe(Object error) =>
      error is ApiException ? apiErrorMessage(error) : AppMessages.errorGeneric;
}
