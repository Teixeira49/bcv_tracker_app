// lib/app/config/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- Colores Base (Opcional, pero útil para consistencia) ---
  // Puedes definir tus paletas de colores aquí si quieres
  static const Color _primaryColorLight = Colors.blue;
  static const Color _primaryColorDark = Colors.blueGrey; // O un azul más oscuro

  static const Color _accentColorLight = Colors.amber;
  static const Color _accentColorDark = Colors.orangeAccent;

  static const Color _backgroundColorLight = Color(0xFFF5F5F5); // Un gris claro
  static const Color _backgroundColorDark = Color(0xFF121212);  // Un gris muy oscuro (común para temas oscuros)

  static const Color _scaffoldBackgroundColorLight = Colors.white;
  static const Color _scaffoldBackgroundColorDark = Color(0xFF1E1E1E); // Un poco más claro que el fondo

  static const Color _textColorLight = Colors.black;
  static const Color _textColorDark = Colors.white;

  // --- Tema Claro ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColorLight,
    // primarySwatch: _createMaterialColor(_primaryColorLight), // Opcional para generar tonos
    colorScheme: ColorScheme.light(
      primary: _primaryColorLight,
      secondary: _accentColorLight,
      surface: _backgroundColorLight,
      background: _scaffoldBackgroundColorLight,
      error: Colors.red,
      onPrimary: Colors.white, // Color del texto/iconos sobre el color primario
      onSecondary: Colors.black,
      onSurface: _textColorLight,
      onBackground: _textColorLight,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _scaffoldBackgroundColorLight,
    appBarTheme: AppBarTheme(
      color: _primaryColorLight,
      elevation: 4.0,
      iconTheme: const IconThemeData(color: Colors.white), // Color de iconos en AppBar
      titleTextStyle: const TextStyle( // Estilo del título en AppBar
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: _textColorLight),
      displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: _textColorLight),
      bodyLarge: TextStyle(fontSize: 16.0, color: _textColorLight),
      bodyMedium: TextStyle(fontSize: 14.0, color: _textColorLight),
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white), // Para botones
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: _primaryColorLight,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColorLight,
        foregroundColor: Colors.white, // Color del texto/icono
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _primaryColorLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _accentColorLight, width: 2.0),
      ),
      labelStyle: TextStyle(color: _primaryColorLight),
    ),
    // ... más personalizaciones para el tema claro
  );


  // --- Tema Oscuro ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColorDark,
    // primarySwatch: _createMaterialColor(_primaryColorDark),
    colorScheme: ColorScheme.dark(
      primary: _primaryColorDark,
      secondary: _accentColorDark,
      surface: _backgroundColorDark,
      background: _scaffoldBackgroundColorDark,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: _textColorDark,
      onBackground: _textColorDark,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _scaffoldBackgroundColorDark,
    appBarTheme: AppBarTheme(
      color: _primaryColorDark,
      elevation: 4.0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: _textColorDark),
      displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: _textColorDark),
      bodyLarge: TextStyle(fontSize: 16.0, color: _textColorDark),
      bodyMedium: TextStyle(fontSize: 14.0, color: _textColorDark),
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: _primaryColorDark,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColorDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _primaryColorDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _accentColorDark, width: 2.0),
      ),
      labelStyle: TextStyle(color: _primaryColorDark),
    ),
    // ... más personalizaciones para el tema oscuro
  );

// Helper para crear MaterialColor a partir de un solo color (opcional)
// static MaterialColor _createMaterialColor(Color color) {
//   List strengths = <double>[.05];
//   Map<int, Color> swatch = {};
//   final int r = color.red, g = color.green, b = color.blue;

//   for (int i = 1; i < 10; i++) {
//     strengths.add(0.1 * i);
//   }
//   strengths.forEach((strength) {
//     final double ds = 0.5 - strength;
//     swatch[(strength * 1000).round()] = Color.fromRGBO(
//       r + ((ds < 0 ? r : (255 - r)) * ds).round(),
//       g + ((ds < 0 ? g : (255 - g)) * ds).round(),
//       b + ((ds < 0 ? b : (255 - b)) * ds).round(),
//       1,
//     );
//   });
//   return MaterialColor(color.value, swatch);
// }
}

/* CHange theme:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr)), // Asumiendo que tienes traducciones
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text('theme_options'.tr, style: Get.textTheme.titleLarge),
          const SizedBox(height: 10),
          ListTile(
            title: Text('light_theme'.tr),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: Get.theme.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light, // O gestiona un estado en un controller
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  Get.changeThemeMode(value);
                }
              },
            ),
            onTap: () => Get.changeThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: Text('dark_theme'.tr),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: Get.theme.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  Get.changeThemeMode(value);
                }
              },
            ),
            onTap: () => Get.changeThemeMode(ThemeMode.dark),
          ),
          ListTile(
            title: Text('system_default'.tr),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: Get.isDarkMode ? ThemeMode.dark : (Get.isLightMode ? ThemeMode.light : ThemeMode.system), // Un poco más complejo determinar el 'system' actual
                                                                                                                     // Podrías necesitar un controlador para el estado del radio button
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  Get.changeThemeMode(value);
                }
              },
            ),
            onTap: () => Get.changeThemeMode(ThemeMode.system),
          ),
          const Divider(),
          // Ejemplo de cómo obtener el estado actual del tema
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              Get.isDarkMode
                ? 'current_theme_dark'.tr
                : 'current_theme_light'.tr,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// En tu controlador de settings o donde cambies el tema
    void _setThemeModePreference(ThemeMode mode) async {
      final prefs = await SharedPreferences.getInstance(); // Obtén SharedPreferences (podrías tenerlo inyectado)
      await prefs.setString('theme_mode', mode.name); // mode.name da 'light', 'dark', 'system'
    }

    // Al cambiar:
    Get.changeThemeMode(newMode);
    _setThemeModePreference(newMode);

    // En main() o un método de inicialización que se ejecute antes de runApp

    Future<ThemeMode> _getInitialThemeMode() async {
      final prefs = await SharedPreferences.getInstance();
      final String? themeModeName = prefs.getString('theme_mode');
      if (themeModeName == null) return ThemeMode.system; // Por defecto

      switch (themeModeName) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    }

    // Luego en MyApp o donde configuras GetMaterialApp
    // Necesitarías que MyApp sea un StatefulWidget o usar un FutureBuilder
    // para esperar a _getInitialThemeMode() si no lo haces antes de runApp.
    // O, más simple con GetX, puedes tener un ThemeController:

    // --- Usando un ThemeController (Recomendado para persistencia) ---

    // 1. Crea un ThemeController
    // lib/app/core/theme/theme_controller.dart
    import 'package:flutter/material.dart';
    import 'package:get/get.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    class ThemeController extends GetxController {
      static const _themeModeKey = 'theme_mode';
      final SharedPreferences _prefs;

      ThemeController(this._prefs);

      final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
      ThemeMode get currentThemeMode => _themeMode.value;

      @override
      void onInit() {
        super.onInit();
        _loadThemeMode();
      }

      void _loadThemeMode() {
        final String? themeName = _prefs.getString(_themeModeKey);
        if (themeName != null) {
          _themeMode.value = ThemeMode.values.firstWhere(
            (e) => e.name == themeName,
            orElse: () => ThemeMode.system,
          );
        }
        // Aplicar el tema cargado a GetX
        Get.changeThemeMode(_themeMode.value);
      }

      Future<void> changeThemeMode(ThemeMode mode) async {
        await _prefs.setString(_themeModeKey, mode.name);
        _themeMode.value = mode;
        Get.changeThemeMode(mode);
      }
    }

    // 2. Registra el ThemeController en InitialBinding
    // En lib/app/config/bindings/initial_binding.dart
    // ...
    // Get.lazyPut(() => ThemeController(Get.find<SharedPreferences>()), fenix: true);
    // ...
    // ¡Asegúrate de que SharedPreferences esté registrado ANTES que ThemeController!

    // 3. En main.dart, GetMaterialApp puede seguir usando ThemeMode.system inicialmente,
    //    y el ThemeController se encargará de aplicar el tema persistido en su onInit.
    //    O podrías hacer que GetMaterialApp.themeMode dependa del ThemeController:
    //
    // class MyApp extends StatelessWidget {
    //   const MyApp({super.key});
    //   @override
    //   Widget build(BuildContext context) {
    //     // Asegúrate de que InitialBinding (y por lo tanto ThemeController) se haya ejecutado.
    //     // Si ThemeController se registra en InitialBinding, ya debería estar disponible aquí.
    //     final ThemeController themeController = Get.find<ThemeController>(); // Si lo registraste como no lazy o ya lo accediste
    //
    //     return Obx(() => // Para que reaccione si ThemeController cambia themeMode observable
    //       GetMaterialApp(
    //         // ...
    //         theme: AppTheme.lightTheme,
    //         darkTheme: AppTheme.darkTheme,
    //         themeMode: themeController.currentThemeMode, // Usa el valor del controlador
    //         // ...
    //       ),
    //     );
    //   }
    // }
    // Sin embargo, la forma más simple es dejar que ThemeController.onInit llame a Get.changeThemeMode()
    // y mantener themeMode: ThemeMode.system en GetMaterialApp inicialmente.



 */