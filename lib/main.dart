import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'config/bindings/initial_bindings.dart';
import 'config/enviroment/enviroment.dart';
import 'core/constants/constants.dart';
import 'core/i18n/app_translations.dart';
import 'features/splash/presentation/page/configuration_error_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // `isOptional` keeps a missing `.env` from throwing: from the app's point of
  // view an absent file is the same situation as an undefined variable, and the
  // check below reports it as such instead of crashing with a stack trace.
  await dotenv.load(fileName: '.env', isOptional: true);

  // Validated before anything can use it: without a backend URL every screen
  // would fail later as a generic network error that never names the variable.
  final EnvironmentError? configError = Environment.validate();
  if (configError != null) {
    runApp(ConfigurationErrorApp(error: configError));
    return;
  }

  Get.put(SettingsController());
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appTitle,
      initialBinding: InitialBinding(),
      home: SplashPage(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
    );
  }
}
