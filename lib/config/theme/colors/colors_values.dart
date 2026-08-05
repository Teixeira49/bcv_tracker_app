import 'package:flutter/material.dart';
import 'colors_constants.dart'; // Asegúrate de que este import apunte a tu archivo

class ColorValues {
  // -------------------------------------------------------
  // <---------------- Text color values ------------------>
  // -------------------------------------------------------

  static final _textPrimary = _ColorScheme(
    light: Colors.black,
    dark: Colors.white,
    onBrandLight: Colors.white,
    onBrandDark: AppColors.grey[50],
  );

  static final _textPrimaryInv = _ColorScheme(
    light: Colors.white,
    dark: Colors.black,
  );

  static final _textSecondary = _ColorScheme(
    light: AppColors.grey.shade700,
    dark: AppColors.grey.shade300,
    onBrandLight: AppColors.primary.shade200,
    onBrandDark: AppColors.grey.shade300,
  );

  static final _textTertiary = _ColorScheme(
    light: AppColors.grey.shade600,
    dark: AppColors.grey.shade400,
    onBrandLight: AppColors.primary.shade200,
    onBrandDark: AppColors.grey.shade400,
  );

  static final _textQuaternary = _ColorScheme(
    light: AppColors.grey,
    dark: AppColors.grey.shade400,
    onBrandLight: AppColors.primary.shade300,
    onBrandDark: AppColors.grey.shade400,
  );

  static final _textDisabled = _ColorScheme(
    light: AppColors.grey.shade400,
    dark: AppColors.grey.shade600,
  );

  static final _textBrandPrimary = _ColorScheme(
    light: AppColors.primary,
    dark: AppColors.primary.shade100, // Más claro en modo oscuro para contraste
  );

  static final _textBrandSecondary = _ColorScheme(
    light: AppColors.primary.shade700,
    dark: AppColors.primary.shade200,
  );

  static final _textBrandTertiary = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary.shade400,
  );

  static final _textBrandTitle = _ColorScheme(
    light: AppColors.secondary,
    dark: AppColors.primary.shade400,
  );

  static final _textErrorPrimary = _ColorScheme(
    light: AppColors.error.shade600,
    dark: AppColors.error.shade400,
  );

  static final _textWarningPrimary = _ColorScheme(
    light: AppColors.warning.shade600,
    dark: AppColors.warning.shade400,
  );

  static final _textSuccessPrimary = _ColorScheme(
    light: AppColors.success.shade600,
    dark: AppColors.success.shade400,
  );

  static final _textWhite = _ColorScheme(
    light: Colors.white,
    dark: Colors.white,
  );

  static final _textWhite70 = _ColorScheme(
    light: Colors.white70,
    dark: Colors.white70,
  );

  static final _textBlack = _ColorScheme(
    light: Colors.black,
    dark: Colors.black,
  );

  // --- Getters de Texto ---
  static Color textPrimary(BuildContext context) =>
      _textPrimary.getColor(context);

  static Color textPrimaryInv(BuildContext context) =>
      _textPrimaryInv.getColor(context);

  static Color textPrimaryOnBrand(BuildContext context) =>
      _textPrimary.getOnBrandColor(context);

  static Color textSecondary(BuildContext context) =>
      _textSecondary.getColor(context);

  static Color textSecondaryOnBrand(BuildContext context) =>
      _textSecondary.getOnBrandColor(context);

  static Color textTertiary(BuildContext context) =>
      _textTertiary.getColor(context);

  static Color textTertiaryOnBrand(BuildContext context) =>
      _textTertiary.getOnBrandColor(context);

  static Color textQuaternary(BuildContext context) =>
      _textQuaternary.getColor(context);

  static Color textQuaternaryOnBrand(BuildContext context) =>
      _textQuaternary.getOnBrandColor(context);

  static Color textBrandTitle(BuildContext context) =>
      _textBrandTitle.getColor(context);

  static Color textDisabled(BuildContext context) =>
      _textDisabled.getColor(context);

  static Color textBrandPrimary(BuildContext context) =>
      _textBrandPrimary.getColor(context);

  static Color textBrandSecondary(BuildContext context) =>
      _textBrandSecondary.getColor(context);

  static Color textBrandTertiary(BuildContext context) =>
      _textBrandTertiary.getColor(context);

  static Color textErrorPrimary(BuildContext context) =>
      _textErrorPrimary.getColor(context);

  static Color textWarningPrimary(BuildContext context) =>
      _textWarningPrimary.getColor(context);

  static Color textSuccessPrimary(BuildContext context) =>
      _textSuccessPrimary.getColor(context);

  static Color textWhite(BuildContext context) => _textWhite.getColor(context);

  static Color textWhite70(BuildContext context) =>
      _textWhite70.getColor(context);

  static Color textBlack(BuildContext context) => _textBlack.getColor(context);

  // ---------------------------------------------------------
  // <---------------- Border color values ------------------>
  // ---------------------------------------------------------

  static final _borderPrimary = _ColorScheme(
    light: AppColors.grey.shade300,
    dark:
        AppColors.midnight.shade700, // Usamos Midnight para bordes en dark mode
  );

  static final _borderSecondary = _ColorScheme(
    light: AppColors.grey.shade200,
    dark: AppColors.midnight.shade800,
  );

  static final _borderTertiary = _ColorScheme(
    light: AppColors.grey.shade100,
    dark: AppColors.midnight.shade800,
  );

  static final _borderDisabled = _ColorScheme(
    light: AppColors.grey.shade300,
    dark: AppColors.grey.shade700,
  );

  static final _borderBrand = _ColorScheme(
    light: AppColors.primary.shade300,
    dark: AppColors.primary.shade400,
    altLight: AppColors.primary.shade300,
    altDark: AppColors.grey.shade100,
  );

  static final _borderBrandSolid = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary,
  );

  static final _borderError = _ColorScheme(
    light: AppColors.error.shade300,
    dark: AppColors.error.shade400,
  );

  static final _borderErrorSolid = _ColorScheme(
    light: AppColors.error.shade600,
    dark: AppColors.error,
  );

  static final _borderWarning = _ColorScheme(
    light: AppColors.warning.shade300,
    dark: AppColors.warning.shade400,
  );

  static final _borderWarningSolid = _ColorScheme(
    light: AppColors.warning.shade600,
    dark: AppColors.warning,
  );

  static final _borderSuccess = _ColorScheme(
    light: AppColors.success.shade300,
    dark: AppColors.success.shade400,
  );

  static final _borderSuccessSolid = _ColorScheme(
    light: AppColors.success.shade600,
    dark: AppColors.success,
  );

  // --- Getters de Borde ---
  static Color borderPrimary(BuildContext context) =>
      _borderPrimary.getColor(context);

  static Color borderSecondary(BuildContext context) =>
      _borderSecondary.getColor(context);

  static Color borderTertiary(BuildContext context) =>
      _borderTertiary.getColor(context);

  static Color borderDisabled(BuildContext context) =>
      _borderDisabled.getColor(context);

  static Color borderBrand(BuildContext context) =>
      _borderBrand.getColor(context);

  static Color borderBrandSolid(BuildContext context) =>
      _borderBrandSolid.getColor(context);

  static Color borderError(BuildContext context) =>
      _borderError.getColor(context);

  static Color borderErrorSolid(BuildContext context) =>
      _borderErrorSolid.getColor(context);

  static Color borderWarning(BuildContext context) =>
      _borderWarning.getColor(context);

  static Color borderWarningSolid(BuildContext context) =>
      _borderWarningSolid.getColor(context);

  static Color borderSuccess(BuildContext context) =>
      _borderSuccess.getColor(context);

  static Color borderSuccessSolid(BuildContext context) =>
      _borderSuccessSolid.getColor(context);

  // -------------------------------------------------------------
  // <---------------- Foreground color values ------------------>
  // -------------------------------------------------------------

  static final _fgPrimary = _ColorScheme(
    light: AppColors.grey.shade900,
    dark: Colors.white,
  );

  static final _fgSecondary = _ColorScheme(
    light: AppColors.grey.shade400,
    dark: AppColors.grey.shade300,
  );

  static final _fgDisabled = _ColorScheme(
    light: AppColors.grey.shade400,
    dark: AppColors.grey.shade700,
  );

  static final _fgBrandPrimary = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary.shade300,
  );

  static final _fgBrandSecondary = _ColorScheme(
    light: AppColors.primary,
    dark: AppColors.primary.shade400,
  );

  static final _fgErrorPrimary = _ColorScheme(
    light: AppColors.error.shade600,
    dark: AppColors.error,
  );

  static final _fgWarningPrimary = _ColorScheme(
    light: AppColors.warning.shade600,
    dark: AppColors.warning,
  );

  static final _fgSuccessPrimary = _ColorScheme(
    light: AppColors.success.shade600,
    dark: AppColors.success,
  );

  static final _fgWhite = _ColorScheme(light: Colors.white, dark: Colors.white);

  // --- Getters Foreground ---
  static Color fgPrimary(BuildContext context) => _fgPrimary.getColor(context);

  static Color fgSecondary(BuildContext context) =>
      _fgSecondary.getColor(context);

  static Color fgDisabled(BuildContext context) =>
      _fgDisabled.getColor(context);

  static Color fgBrandPrimary(BuildContext context) =>
      _fgBrandPrimary.getColor(context);

  static Color fgBrandSecondary(BuildContext context) =>
      _fgBrandSecondary.getColor(context);

  static Color fgErrorPrimary(BuildContext context) =>
      _fgErrorPrimary.getColor(context);

  static Color fgWarningPrimary(BuildContext context) =>
      _fgWarningPrimary.getColor(context);

  static Color fgSuccessPrimary(BuildContext context) =>
      _fgSuccessPrimary.getColor(context);

  static Color fgWhite(BuildContext context) => _fgWhite.getColor(context);

  // -------------------------------------------------------------
  // <---------------- Background color values ------------------>
  // -------------------------------------------------------------
  // Aquí usamos "Midnight" para el modo oscuro

  static final _bgPrimary = _ColorScheme(
    light: Colors.white,
    dark: AppColors.midnight, // Fondo principal oscuro (Deep Navy)
  );

  static final _bgPrimarySolid = _ColorScheme(
    light: AppColors.grey.shade900,
    dark: AppColors.midnight.shade900,
  );

  static final _bgPrimaryAlter = _ColorScheme(
    light: Colors.white,
    dark: AppColors.primary.shade900,
  );

  static final _bgSecondary = _ColorScheme(
    light: AppColors.grey.shade50,
    dark: AppColors.midnight.shade800, // Un poco más claro que el fondo base
  );

  static final _bgTertiary = _ColorScheme(
    light: AppColors.grey.shade100,
    dark: AppColors.midnight.shade700,
  );

  static final _bgActive = _ColorScheme(
    light: AppColors.grey.shade50,
    dark: AppColors.midnight.shade600,
  );

  static final _bgDisabled = _ColorScheme(
    light: AppColors.grey.shade100,
    dark: AppColors.midnight.shade800,
  );

  static final _bgOverlay = _ColorScheme(
    light: AppColors.grey.shade900.withValues(alpha: 0.8),
    dark: AppColors.midnight.shade900.withValues(alpha: 0.8),
  );

  static final _bgBrandPrimary = _ColorScheme(
    light: AppColors.primary.shade50,
    dark: AppColors.primary.shade900,
  );

  static final _bgBrandSolid = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary.shade600,
  );

  static final _bgErrorPrimary = _ColorScheme(
    light: AppColors.error.shade50,
    dark: AppColors.error.shade900,
  );

  static final _bgErrorSolid = _ColorScheme(
    light: AppColors.error.shade600,
    dark: AppColors.error.shade600,
  );

  static final _bgWarningPrimary = _ColorScheme(
    light: AppColors.warning.shade50,
    dark: AppColors.warning.shade900,
  );

  static final _bgWarningSolid = _ColorScheme(
    light: AppColors.warning.shade400,
    dark: AppColors.warning.shade400,
  );

  static final _bgSuccessPrimary = _ColorScheme(
    light: AppColors.success.shade50,
    dark: AppColors.success.shade900,
  );

  static final _bgSuccessSolid = _ColorScheme(
    light: AppColors.success.shade600,
    dark: AppColors.success.shade600,
  );

  static final _bgCurveInit = _ColorScheme(
    light: AppColors.midnight.shade50,
    dark: AppColors.midnight.shade600,
  );

  static final _bgCurveEnd = _ColorScheme(
    light: AppColors.midnight.shade200,
    dark: AppColors.midnight.shade800,
  );

  // --- Getters Background ---
  static Color bgPrimary(BuildContext context) => _bgPrimary.getColor(context);

  static Color bgPrimaryAlter(BuildContext context) =>
      _bgPrimaryAlter.getColor(context);

  static Color bgPrimarySolid(BuildContext context) =>
      _bgPrimarySolid.getColor(context);

  static Color bgSecondary(BuildContext context) =>
      _bgSecondary.getColor(context);

  static Color bgTertiary(BuildContext context) =>
      _bgTertiary.getColor(context);

  static Color bgActive(BuildContext context) => _bgActive.getColor(context);

  static Color bgDisabled(BuildContext context) =>
      _bgDisabled.getColor(context);

  static Color bgOverlay(BuildContext context) => _bgOverlay.getColor(context);

  static Color bgBrandPrimary(BuildContext context) =>
      _bgBrandPrimary.getColor(context);

  static Color bgBrandSolid(BuildContext context) =>
      _bgBrandSolid.getColor(context);

  static Color bgErrorPrimary(BuildContext context) =>
      _bgErrorPrimary.getColor(context);

  static Color bgErrorSolid(BuildContext context) =>
      _bgErrorSolid.getColor(context);

  static Color bgWarningPrimary(BuildContext context) =>
      _bgWarningPrimary.getColor(context);

  static Color bgWarningSolid(BuildContext context) =>
      _bgWarningSolid.getColor(context);

  static Color bgSuccessPrimary(BuildContext context) =>
      _bgSuccessPrimary.getColor(context);

  static Color bgSuccessSolid(BuildContext context) =>
      _bgSuccessSolid.getColor(context);

  static Color bgCurveInit(BuildContext context) =>
      _bgCurveInit.getColor(context);

  static Color bgCurveEnd(BuildContext context) =>
      _bgCurveEnd.getColor(context);

  // ----------------------------------------------------------
  // <---------------- Utility color values ------------------>
  // ----------------------------------------------------------

  // Mapeamos solo Primary (Brand) y Accent (BrandSecond)

  static final _utilityBrand50 = _ColorScheme(
    light: AppColors.primary.shade50,
    dark: AppColors.primary.shade900,
  );

  static final _utilityBrand100 = _ColorScheme(
    light: AppColors.primary.shade100,
    dark: AppColors.primary.shade800,
  );

  static final _utilityBrand500 = _ColorScheme(
    light: AppColors.primary,
    dark: AppColors.primary,
  );

  static final _utilityBrand800 = _ColorScheme(
    light: AppColors.primary.shade800,
    dark: AppColors.primary.shade800,
  );

  static final _utilityBrandAccent500 = _ColorScheme(
    light: AppColors.accent,
    dark: AppColors.accent,
  );

  static final _utilityBrandSecondary500 = _ColorScheme(
    light: AppColors.secondary,
    dark: AppColors.secondary,
  );

  static final _utilityBrandSecondary100 = _ColorScheme(
    light: AppColors.secondary.shade100,
    dark: AppColors.secondary.shade800,
  );

  static final _utilityMidNight = _ColorScheme(
    light: AppColors.midnight,
    dark: AppColors.midnight,
  );

  static final _utilityInfo = _ColorScheme(
    light: AppColors.info,
    dark: AppColors.info,
  );

  // Getters simplificados para Utility

  static Color utilityBrand50(BuildContext context) =>
      _utilityBrand50.getColor(context);

  static Color utilityBrand100(BuildContext context) =>
      _utilityBrand100.getColor(context);

  static Color utilityBrand500(BuildContext context) =>
      _utilityBrand500.getColor(context);

  static Color utilityBrand800(BuildContext context) =>
      _utilityBrand800.getColor(context);

  static Color utilityBrandSecondary100(BuildContext context) =>
      _utilityBrandSecondary100.getColor(context);

  static Color utilityBrandSecondary500(BuildContext context) =>
      _utilityBrandSecondary500.getColor(context);

  static Color utilityBrandAccent500(BuildContext context) =>
      _utilityBrandAccent500.getColor(context);

  static Color utilityMidNight(BuildContext context) =>
      _utilityMidNight.getColor(context);

  static Color utilityInfo(BuildContext context) =>
      _utilityInfo.getColor(context);

  static Color utilityGrey50(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.grey.shade900
      : AppColors.grey.shade50;

  static Color utilityGrey500(BuildContext context) => AppColors.grey;

  static Color utilityGrey900(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.grey.shade50
      : AppColors.grey.shade900;

  // ---------------------------------------------------------
  // <---------------- Button color values ------------------>
  // ---------------------------------------------------------

  static final _buttonPrimaryBg = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary.shade500,
  );

  static final _buttonPrimaryFg = _ColorScheme(
    light: Colors.white,
    dark: Colors.white,
  );

  static final _buttonSecondaryBg = _ColorScheme(
    light: Colors.white,
    dark: AppColors.midnight.shade800, // Boton secundario sobre fondo oscuro
  );

  static final _buttonSecondaryFg = _ColorScheme(
    light: AppColors.grey.shade700,
    dark: AppColors.grey.shade300,
  );

  static final _buttonSecondaryBorder = _ColorScheme(
    light: AppColors.grey.shade300,
    dark: AppColors.midnight.shade600,
  );

  // --- Getters Buttons ---
  static Color buttonPrimaryBg(BuildContext context) =>
      _buttonPrimaryBg.getColor(context);

  static Color buttonPrimaryFg(BuildContext context) =>
      _buttonPrimaryFg.getColor(context);

  static Color buttonSecondaryBg(BuildContext context) =>
      _buttonSecondaryBg.getColor(context);

  static Color buttonSecondaryFg(BuildContext context) =>
      _buttonSecondaryFg.getColor(context);

  static Color buttonSecondaryBorder(BuildContext context) =>
      _buttonSecondaryBorder.getColor(context);

  // -------------------------------------------------------
  // <---------------- Icon color values ------------------>
  // -------------------------------------------------------

  static final _featuredIconFgBrand = _ColorScheme(
    light: AppColors.primary.shade600,
    dark: AppColors.primary.shade200,
  );

  static Color featuredIconFgBrand(BuildContext context) =>
      _featuredIconFgBrand.getColor(context);
}

// ---------------------------------------------------------
// <---------------- Helper Class ------------------------->
// ---------------------------------------------------------

class _ColorScheme {
  final Color light;
  final Color dark;
  final Color? onBrandLight;
  final Color? onBrandDark;
  final Color? altLight;
  final Color? altDark;

  _ColorScheme({
    required this.light,
    required this.dark,
    this.onBrandLight,
    this.onBrandDark,
    this.altLight,
    this.altDark,
  });

  Color getColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  Color getOnBrandColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? (onBrandDark ?? dark)
        : (onBrandLight ?? light);
  }

  Color getAltColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? (altDark ?? dark)
        : (altLight ?? light);
  }
}
