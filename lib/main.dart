import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/bindings/initial_bindings.dart';
import 'config/language/translation.dart';
import 'config/routes/pages.dart';

void main() async {
  await dotenv.load(
    fileName: ".env",
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tu Aplicación',

      // --- Inyección de Dependencias Global ---
      initialBinding: InitialBinding(), // Aquí se registra tu binding global

      // --- Rutas ---
      initialRoute: AppPages.initPage, // La ruta inicial de tu app
      getPages: AppPages.routes,      // Tu lista de GetPage

      // --- Tema ---
      //theme: AppTheme.lightTheme,
      //darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // O el que prefieras

      // Si no quieres que GetX maneje el locale, puedes quitar esto.
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'US'),
      translations: AppTranslations(), // Si usas GetX para traducciones

      // builder: (context, child) { // Puedes tener un builder global si es necesario
      //   return MediaQuery(
      //     data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)), // Ejemplo
      //     child: child!,
      //   );
      // },
    );
  }
}
