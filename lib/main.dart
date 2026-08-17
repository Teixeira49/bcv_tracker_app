import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/bindings/initial_bindings.dart';
import 'config/enviroment/enviroment.dart';
import 'config/routes/pages.dart';
import 'core/constants/constants.dart';
import 'core/i18n/app_translations.dart';
import 'features/splash/presentation/page/configuration_error_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loading is delegated to Environment, which never throws: an unreadable
  // `.env` is a configuration problem to report, not a crash before the first
  // frame. See Environment.load for why `isOptional` alone did not cover it.
  await Environment.load();

  // Validated before anything can use it: without a backend URL every screen
  // would fail later as a generic network error that never names the variable.
  final EnvironmentError? configError = Environment.validate();
  if (configError != null) {
    runApp(ConfigurationErrorApp(error: configError));
    return;
  }

  // Awaited on purpose: the theme and the language have to be in memory before
  // the first frame, or the app paints its defaults and then jumps to what the
  // user chose. See `InitialBinding.initServices` for why this cannot live in
  // the binding, and `SettingsController` for what used to hide the flicker.
  await InitialBinding.initServices();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// Minimal app shown when the configuration is unusable.
///
/// It brings up translations and the theme so the page reads like the rest of
/// the app, but registers no bindings: every dependency below `InitialBinding`
/// needs the backend URL that is precisely what is missing.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.error, super.key});

  final EnvironmentError error;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appTitle,
      home: ConfigurationErrorPage(error: error),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Registered and fully loaded by `InitialBinding.initServices()`, awaited
    // in `main` before this widget can exist — so this `find` cannot miss.
    final SettingsController settings = Get.find<SettingsController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appTitle,
      initialBinding: InitialBinding(),
      // Named routes: the splash is the entry point and every screen resolves
      // through `AppPages.routes`. `initialBinding` still runs — adding
      // `getPages`/`initialRoute` does not displace it.
      initialRoute: AppPages.initPage,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Straight from the settings service, which `main` finished loading
      // before `runApp`. Passing the stored values here — rather than calling
      // `Get.changeThemeMode` / `Get.updateLocale` during startup — is what
      // makes the very first frame correct: `GetMaterialApp.initState` assigns
      // `Get.locale` from this argument, so a locale applied earlier would have
      // been overwritten right here (#59).
      //
      // Runtime changes still work through the framework: GetX resolves
      // `ctrl.themeMode ?? themeMode` and `Get.locale ?? locale`, so the
      // setters take precedence over these starting values.
      themeMode: settings.startupThemeMode,
      // `null` means "no stored choice, follow the device" — today's behaviour,
      // kept deliberately. #98 is where that decision gets revisited.
      locale: settings.startupLocale ?? Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
    );
  }
}
