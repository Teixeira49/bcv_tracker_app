import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/converter/presentation/controller/converter_controller.dart';
import '../../features/currency_detail/presentation/controller/currency_detail_controller.dart';
import '../../features/home/presentation/controller/home_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../../shared/data/datasource/datasource.dart';
import '../../shared/data/repositories/currency_repository.dart';
import '../../shared/data/repositories/dollar_repositories.dart';
import '../../shared/domain/repositories/dollar_repositories.dart';
import '../../shared/presentation/controller/settings_controller.dart';
import '../enviroment/enviroment.dart';

/// The app's whole dependency graph, in one file.
///
/// Everything is registered here and resolved with `Get.find()`; nothing constructs
/// a controller inside a widget, because a second instance would listen to the same
/// service while only the registered one is bound to the view — and the bug
/// surfaces as "the screen does not update", far from its cause. See
/// `.agents/rules/dependency-injection.md`.
///
/// **Two entry points, and the split is load-bearing.** [dependencies] is called by
/// `GetMaterialApp` from its `initState` and **not awaited**, so anything the first
/// frame has to read cannot be registered there. That goes in [initServices],
/// which `main` awaits before `runApp`.
class InitialBinding extends Bindings {
  /// Services that must be **fully constructed before the first frame**.
  ///
  /// Awaited by `main` ahead of `runApp`, and deliberately not part of
  /// [dependencies]: GetX calls `initialBinding?.dependencies()` from
  /// `GetMaterialApp.initState` **without awaiting it**
  /// (`get_material_app.dart:226`), so an asynchronous registration declared
  /// there is fire-and-forget — the first screen builds while it is still in
  /// flight, and `Get.find` on it throws because `Get.putAsync` only registers
  /// the instance once its builder resolves.
  ///
  /// So the split is not stylistic. Anything the first frame *reads* is
  /// registered here; everything else stays in [dependencies]. Registration
  /// still happens in this one file, which is what
  /// `.agents/rules/dependency-injection.md` asks for.
  /// [deviceLocale] overrides the device's language, which the settings service
  /// follows until the user picks one (#98). A parameter so a test can name it
  /// instead of inheriting whatever the host machine is set to; production
  /// leaves it out and the service reads `Get.deviceLocale`.
  static Future<void> initServices({Locale? deviceLocale}) async {
    // `permanent`: settings outlive every route, and re-reading the disk on a
    // rebuild would reopen the very window #59 closed.
    await Get.putAsync<SettingsController>(
      () => SettingsController().init(deviceLocale: deviceLocale),
      permanent: true,
    );
  }

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
    // `SettingsController` is not registered here: it is a service the first
    // frame reads, so it goes through `initServices()` above. The `lazyPut`
    // that used to sit on this line was inert anyway — `main` had already
    // registered the instance with `Get.put`, which is the double registration
    // #45 catalogued.

    // New Injections
    Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ConverterController>(() => ConverterController(), fenix: true);
    // Holds the rate the detail sheet has open (#38). `fenix` because the sheet
    // is a modal: the controller is discarded between openings and rebuilt on
    // the next tap.
    Get.lazyPut<CurrencyDetailController>(
      () => CurrencyDetailController(),
      fenix: true,
    );
  }
}
