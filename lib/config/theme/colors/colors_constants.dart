import 'package:flutter/material.dart';

/// The brand palette, as raw `MaterialColor` swatches.
///
/// The **lowest** layer of colour: literal values and nothing else. Widgets do not
/// read this — they read `ColorValues`, which picks a shade per theme. That split
/// is what makes light and dark a single decision per token instead of a
/// conditional at every call site.
///
/// No `Color(0xFF...)` exists outside `lib/config/theme/`; the 137 uses in the app
/// all resolve through here. `DESIGN.md` declares these tokens first and this file
/// implements them — see `.agents/rules/design-system.md`.
///
/// The launch-screen navy `#08253A` is deliberately **not** here: it belongs to the
/// brand's artwork rather than to the interface palette, and lives in
/// `assets/brand/`.
class AppColors {
  AppColors._();

  // --- PRIMARY (Azul Profundo) ---
  static const int _primaryValue = 0xFF02466D;
  static const MaterialColor primary = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFEFF5FF), // original 0xFFEFF9FE
      100: Color(0xFFD6EFFE),
      200: Color(0xFFA4DDFD),
      300: Color(0xFF72CAFC),
      400: Color(0xFF40B7FB),
      500: Color(_primaryValue),
      600: Color(0xFF013B5C),
      700: Color(0xFF01314C),
      800: Color(0xFF01263B),
      900: Color(0xFF001C2B),
    },
  );

  // --- SECONDARY (Azul Complementario) ---
  static const int _secondaryValue = 0xFF064469;
  static const MaterialColor secondary =
      MaterialColor(_secondaryValue, <int, Color>{
        50: Color(0xFFE1E9ED),
        100: Color(0xFFB4C9D8),
        200: Color(0xFF83A6BE),
        300: Color(0xFF5283A4),
        400: Color(0xFF2C6B90),
        500: Color(_secondaryValue),
        600: Color(0xFF053E61),
        700: Color(0xFF043657),
        800: Color(0xFF032D4D),
        900: Color(0xFF02203B),
      });

  // --- MIDNIGHT (Fondo Oscuro Premium) ---
  static const int _midnightValue = 0xFF070E15;
  static const MaterialColor midnight =
      MaterialColor(_midnightValue, <int, Color>{
        50: Color(0xFFF3F7FB),
        100: Color(0xFFE0EAF4),
        200: Color(0xFFBAD1E8),
        300: Color(0xFF93B7DB),
        400: Color(0xFF6D9ECE),
        500: Color(_midnightValue),
        600: Color(0xFF050B11),
        700: Color(0xFF04090E),
        800: Color(0xFF03070B),
        900: Color(0xFF020508),
      });

  // --- ACCENT / SECONDARY (Naranja) ---
  static const int _accentValue = 0xFFFFA726;
  static const MaterialColor accent = MaterialColor(_accentValue, <int, Color>{
    50: Color(0xFFFEF8EF),
    100: Color(0xFFFFEED6),
    200: Color(0xFFFFD9A3),
    300: Color(0xFFFEC570),
    400: Color(0xFFFFB03D),
    500: Color(_accentValue),
    600: Color(0xFFF99400),
    700: Color(0xFFCD7900),
    800: Color(0xFFA15F00),
    900: Color(0xFF754500),
  });

  // --- NEUTRAL / GREY ---
  static const int _greyValue = 0xFF808080;
  static const MaterialColor grey = MaterialColor(_greyValue, <int, Color>{
    50: Color(0xFFF7F7F7),
    100: Color(0xFFEAEAEA),
    200: Color(0xFFD1D1D1),
    300: Color(0xFFB7B7B7),
    400: Color(0xFF9E9E9E),
    500: Color(_greyValue),
    600: Color(0xFF6C6C6C),
    700: Color(0xFF595959),
    800: Color(0xFF464646),
    900: Color(0xFF333333),
  });

  // --- SEMANTIC: SUCCESS (Verde) ---
  static const int _successValue = 0xFF39E079; // 0xFF4CAF50
  static const MaterialColor success =
      MaterialColor(_successValue, <int, Color>{
        50: Color(0xFFE7FCEC),
        100: Color(0xFFC3F7D6),
        200: Color(0xFF9CF2BE),
        300: Color(0xFF75EDA6),
        400: Color(0xFF57E994),
        500: Color(_successValue),
        600: Color(0xFF33D368),
        700: Color(0xFF2CC555),
        800: Color(0xFF25B842),
        900: Color(0xFF1AA027),
      });

  // --- SEMANTIC: ERROR (Rojo) ---
  static const int _errorValue = 0xFFF44336;
  static const MaterialColor error = MaterialColor(_errorValue, <int, Color>{
    50: Color(0xFFFEF1F0),
    100: Color(0xFFFCDAD8),
    200: Color(0xFFFAADA7),
    300: Color(0xFFF78077),
    400: Color(0xFFF45347),
    500: Color(_errorValue),
    600: Color(0xFFF01C0D),
    700: Color(0xFFC5170A),
    800: Color(0xFF9B1208),
    900: Color(0xFF710D06),
  });

  // 8 digits, always: `0xAARRGGBB`. A 7-digit literal is still a valid int, so
  // the compiler stays silent while Dart reads the missing digit as alpha —
  // this one used to be `0xFFFF980`, which rendered at 6 % opacity.
  static const int _warningValue = 0xFFFF9800;
  static const MaterialColor warning =
      MaterialColor(_warningValue, <int, Color>{
        50: Color(0xFFFFF3E0),
        100: Color(0xFFFFE0B2),
        200: Color(0xFFFFCC80),
        300: Color(0xFFFFb74d),
        400: Color(0xFFFFA726),
        500: Color(_warningValue),
        600: Color(0xFFF57C00),
        700: Color(0xFFC25E00),
        800: Color(0xFF914100),
        900: Color(0xFF602300),
      });

  // --- SEMANTIC: INFO (Azul) ---
  static const int _infoValue = 0xFF1187CE;
  static const MaterialColor info = MaterialColor(_infoValue, <int, Color>{
    50: Color(0xFFE2F1FA),
    100: Color(0xFFB8DCF6),
    200: Color(0xFF8AC6F1),
    300: Color(0xFF5CB0EC),
    400: Color(0xFF3AA0E8),
    500: Color(_infoValue),
    600: Color(0xFF0F7FCA),
    700: Color(0xFF0C74C5),
    800: Color(0xFF0A6AC0),
    900: Color(0xFF0659B7),
  });
}
