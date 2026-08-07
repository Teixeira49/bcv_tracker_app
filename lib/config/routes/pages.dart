import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:get/get.dart';

import '../../features/dashboard/presentation/page/dashboard_page.dart';
import '../../features/splash/presentation/page/splash_page.dart';

class AppPages {
  static const initPage = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    // The splash → home transition lives here, on the route, not at the call
    // site: `Get.offAllNamed(AppRoutes.home)` from the splash inherits it.
    GetPage(
      name: AppRoutes.home,
      page: () => DashboardPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
