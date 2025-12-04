import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/home/presentation/controller/current_dollar_controller.dart';
import '../../features/home/presentation/controller/dollar_bcv_controller.dart';
import '../../shared/data/datasource/datasource.dart';
import '../../shared/data/repositories/dollar_repositories.dart';
import '../../shared/domain/repositories/dollar_repositories.dart';
import '../../shared/domain/use_cases/get_current_dollar_use_case.dart';
import '../../shared/domain/use_cases/use_cases.dart';
import '../../shared/presentation/controller/calc_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.lazyPut<SplashPage>(() => SplashPage(), fenix: true);
    Get.lazyPut<IDollarApi>(
      () => DollarApiRest(
        apiUrl: 'https://www.bcv.org.ve',//dotenv.env['MAIN_TAX']!,
        secondApiUrl: 'https://www.bancodevenezuela.com',//dotenv.env['CURRENT_TAX']!,
      ),
      fenix: true,
    );
    Get.lazyPut<IDollarRepository>(
      () => DollarRepository(dollarApi: Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetCurrentBCVDollarUseCase>(
      () => GetCurrentBCVDollarUseCase(dollarRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<DollarBCVController>(
      () => DollarBCVController(getCurrentBCVDollarUseCase: Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetCurrentDollarUseCase>(
      () => GetCurrentDollarUseCase(dollarRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<CurrentDollarController>(
      () => CurrentDollarController(getCurrentDollarUseCase: Get.find()),
      fenix: true,
    );
    Get.lazyPut<CalcController>(() => CalcController(), fenix: true);
  }
}
