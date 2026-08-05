import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:get/get.dart';

import '../../features/converter/presentation/controller/converter_controller.dart';
import '../../features/home/presentation/controller/home_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../../shared/data/datasource/datasource.dart';
import '../../shared/data/repositories/currency_repository.dart';
import '../../shared/data/repositories/dollar_repositories.dart';
import '../../shared/domain/repositories/dollar_repositories.dart';
import '../../shared/presentation/controller/settings_controller.dart';
import '../enviroment/enviroment.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.lazyPut<SplashPage>(() => SplashPage(), fenix: true);
    Get.lazyPut<IDollarApi>(
      () => DollarApiRest(apiUrl: Environment.currency),
      fenix: true,
    );
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
    Get.lazyPut<IDollarRepository>(
      () => DollarRepository(dollarApi: Get.find()),
      fenix: true,
    );
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);

    // New Injections
    Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ConverterController>(() => ConverterController(), fenix: true);
  }
}
