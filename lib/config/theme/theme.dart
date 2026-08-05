import 'package:flutter/material.dart';

import 'colors/colors_constants.dart';

/// Light and dark [ThemeData] for the app, on **Material 3**.
///
/// The app draws almost all of its colour from `ColorValues` (context-based,
/// four modes) and from custom widgets, not from `ThemeData` — so the job of
/// these themes is narrow: give Material's own components (dialogs, tabs,
/// switches, inputs, cards) a `ColorScheme` and shapes that match the brand,
/// instead of Material 3's stock defaults.
///
/// The migration (#44) was **architecture-first**: adopt M3's colour model
/// (`ColorScheme` derived from the brand palette, `useMaterial3: true`) while
/// keeping the product looking the same. The custom-styled surfaces are
/// untouched; the Material components are themed here to the brand so they read
/// as intentional, not stock. The visual identity is documented in `DESIGN.md`.
class AppTheme {
  AppTheme._();

  /// The app's rounding language (`DESIGN.md` → rounded.md). Cards and dialogs
  /// use it so Material 3 does not impose its own 28dp dialog corners.
  static const double _radius = 16;

  static final ThemeData lightTheme = _build(Brightness.light);
  static final ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    // Seed a coherent Material 3 tonal scheme from the brand blue, then pin the
    // brand roles so primary/secondary/accent/error stay exactly the palette —
    // the generated tones only fill the surface/neutral roles the app rarely
    // reads directly.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          error: AppColors.error,
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,

      // Cards stay flat with the brand rounding — the app's aesthetic is depth
      // by border and blur, not by shadow (see DESIGN.md → Elevation & Depth).
      cardTheme: CardThemeData(
        elevation: 0,
        shape: shape,
        clipBehavior: Clip.antiAlias,
      ),

      // Dialogs keep the 16dp corners of the app instead of M3's 28dp default;
      // `BaseModal` already sets its own background/elevation.
      dialogTheme: DialogThemeData(shape: shape),

      // The custom tab bar sets its own indicator and colours; silence the M3
      // divider and ripple so they do not creep in.
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
      ),

      // The M3 switch has a different anatomy than M2's; keep it on-brand
      // (amber accent thumb, blue track) so it reads as part of the app.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.accent : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
      ),
    );
  }
}
