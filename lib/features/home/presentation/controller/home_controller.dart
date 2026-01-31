import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/entities/currency.dart';

class HomeController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();

  List<Currency> get averageCurrencies => _repository.averageCurrencies;
  List<Currency> get bcvCurrencies => _repository.bcvCurrencies;
  bool get isLoading => _repository.isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Listen to repository changes to update the UI
    ever(_repository.averageCurrencies, (_) => update());
    ever(_repository.bcvCurrencies, (_) => update());
    ever(_repository.isLoading, (_) => update());
  }

  Future<void> refreshHomeData() async {
    await _repository.refreshData();
  }
}
