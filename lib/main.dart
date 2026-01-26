import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/bindings/initial_bindings.dart';
import 'core/constants/constants.dart';
import 'core/i18n/app_translations.dart';

void main() async {
  await dotenv.load(
    fileName: ".env",
  );
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SettingsController());
  runApp(const MyApp());
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
