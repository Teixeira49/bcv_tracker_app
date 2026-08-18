import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/entities/currency.dart';

/// Feeds the Home screen from [CurrencyRepository].
///
/// **Holds no state of its own.** Every getter unwraps an observable the service
/// owns, and `onInit` bridges each one to `update()` so the `GetBuilder`s in the
/// view repaint. That is the architecture's boundary: the view never names an
/// `Rx` type, and there is exactly one copy of the rates in the app.
///
/// A consequence worth knowing before adding reactive state to the service: **if
/// you add an observable here and forget its `ever`, the screen silently stops
/// refreshing.** Nothing fails; it just never updates. See
/// `.agents/skills/getx-architecture`.
class HomeController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();

  /// Parallel market rates for the average tab, unwrapped.
  ///
  /// While [hasAverageData] is `false` these are the skeleton placeholders, not
  /// rates — the view shimmers them rather than reading their numbers.
  List<Currency> get averageCurrencies => _repository.averageCurrencies;

  /// Official rates for the BCV tab. Same placeholder contract, flagged by
  /// [hasBcvData].
  List<Currency> get bcvCurrencies => _repository.bcvCurrencies;

  /// Effective date of the official rates, as the BCV published it.
  String get bcvCurrentDate => _repository.bcvCurrentDate.value;

  /// Whether a refresh is in flight, for the shimmer and the pull-to-refresh.
  bool get isLoading => _repository.isLoading.value;

  /// Detail of the last failed refresh, or `null` if the last one succeeded.
  String? get errorMessage => _repository.errorMessage.value;

  /// Whether each tab already has real rates to render (see [CurrencyRepository]).
  bool get hasAverageData => _repository.hasAverageData.value;

  /// See [hasAverageData]; its counterpart for the BCV tab.
  bool get hasBcvData => _repository.hasBcvData.value;

  /// Wires the service's observables to `update()`.
  ///
  /// Four workers, one per value the view reads. They are **not disposed**, which
  /// is the leak catalogued in
  /// [#45](https://github.com/Teixeira49/bcv_tracker_app/issues/45): `get` 4.7.3
  /// disposes none on its own and this controller is registered `fenix`, so a
  /// listener accumulates on every recreation against a `permanent` service. Any
  /// new worker added here belongs in an `onClose` that this class still owes.
  @override
  void onInit() {
    super.onInit();
    // Listen to repository changes to update the UI
    ever(_repository.averageCurrencies, (_) => update());
    ever(_repository.bcvCurrencies, (_) => update());
    ever(_repository.isLoading, (_) => update());
    ever(_repository.errorMessage, (_) => update());
  }

  /// Refetches both sides. Bound to pull-to-refresh and to the error state's
  /// retry; the service is what decides what a partial failure means.
  Future<void> refreshHomeData() async {
    await _repository.refreshData();
  }
}
