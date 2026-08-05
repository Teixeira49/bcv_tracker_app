// lib/app/config/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- Tema Claro ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // ... más personalizaciones para el tema claro
  );

  // --- Tema Oscuro ---
  static final ThemeData darkTheme = ThemeData(brightness: Brightness.dark);
}
