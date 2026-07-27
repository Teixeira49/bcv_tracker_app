import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/entities/currency.dart';

class HomeController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();

  List<Currency> get averageCurrencies => _repository.averageCurrencies;
  List<Currency> get bcvCurrencies => _repository.bcvCurrencies;
  String get bcvCurrentDate => _repository.bcvCurrentDate.value;
  bool get isLoading => _repository.isLoading.value;

  /// Detail of the last failed refresh, or `null` if the last one succeeded.
  String? get errorMessage => _repository.errorMessage.value;

  /// Whether each tab already has real rates to render (see [CurrencyRepository]).
  bool get hasAverageData => _repository.hasAverageData.value;
  bool get hasBcvData => _repository.hasBcvData.value;

  @override
  void onInit() {
    super.onInit();
    // Listen to repository changes to update the UI
    ever(_repository.averageCurrencies, (_) => update());
    ever(_repository.bcvCurrencies, (_) => update());
    ever(_repository.isLoading, (_) => update());
    ever(_repository.errorMessage, (_) => update());
  }

  Future<void> refreshHomeData() async {
    await _repository.refreshData();
  }
}
