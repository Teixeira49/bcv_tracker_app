import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../features/home/presentation/page/home_page.dart';
import '../../features/splash/presentation/page/splash_page.dart';

class AppPages {
  static const initPage = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
  ];
}
