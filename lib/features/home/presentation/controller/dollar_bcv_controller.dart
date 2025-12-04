import 'package:get/get.dart';

import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/domain/use_cases/get_current_bcv_dollar_use_case.dart';

class DollarBCVController extends GetxController {
  DollarBCVController({required this.getCurrentBCVDollarUseCase});

  final GetCurrentBCVDollarUseCase getCurrentBCVDollarUseCase;

  List<Currency> currentDollar = List.generate(5, (index) => Currency.emptySkeletonizer);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    getCurrentDollar();
  }

  Future<void> getCurrentDollar() async {
    try {
      initLoadState();
      currentDollar = await getCurrentBCVDollarUseCase.execute();
      update();
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void initLoadState() {
    isLoading.value = true;
    currentDollar = List.generate(5, (index) => Currency.emptySkeletonizer);
    errorMessage.value = '';
    update();
  }
}
