import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:get/get.dart';

import '../../features/dashboard/presentation/page/dashboard_page.dart';
import '../../features/splash/presentation/page/splash_page.dart';

/// The routing table `GetMaterialApp` is built with.
///
/// Every constant in [AppRoutes] has exactly one `GetPage` here. **Transitions
/// belong on the page, not at the call site**: the splash calls a bare
/// `Get.offAllNamed(AppRoutes.home)` and inherits the fade declared below, so the
/// animation cannot differ between two places that navigate to the same screen.
class AppPages {
  /// Route the app opens on.
  static const initPage = AppRoutes.splash;

  /// Every screen the app can navigate to, by name.
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
