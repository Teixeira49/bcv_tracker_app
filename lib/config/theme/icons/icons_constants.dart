class AppIcons {
  static const String imagesRoute = 'assets/images';
  static const String iconsRoute = 'assets/icons';

  // ---------------------------------------------------------------------------
  // Main icons

  /// Logo completo —icono y wordmark— para el splash.
  ///
  /// Vive en `assets/brand/` con el resto de la marca, y **está aplanado**: el
  /// export de diseño traía el wordmark como `<text>` y el anillo tras un
  /// `<use>`, y `flutter_svg` no dibuja ninguno de los dos. Ver
  /// `assets/brand/README.md` antes de sustituirlo por un export nuevo.
  ///
  /// El arte es negro; quien lo pinta decide el color con un `colorFilter`.
  static const String mainLogo = 'assets/brand/dt_logo.svg';

  /// Solo el icono, sin wordmark. Mismo origen y mismas condiciones.
  static const String brandIcon = 'assets/brand/dt_icon.svg';

  static const String onlyLogo = 'assets/logo_center.svg';

  // ---------------------------------------------------------------------------
  // Country Icons

  static const String flagEEUUIcon = '$iconsRoute/flags/flag_united_states.svg';

  static const String flagTurkeyIcon = '$iconsRoute/flags/flag_turkey.svg';

  static const String flagChinaIcon = '$iconsRoute/flags/flag_china.svg';

  static const String flagRussiaIcon = '$iconsRoute/flags/flag_russia.svg';

  static const String flagEuropeIcon = '$iconsRoute/flags/flag_europe.svg';

  static const String flagVenezuelaIcon =
      '$iconsRoute/flags/flag_venezuela.svg';

  // ---------------------------------------------------------------------------
  // Currencies Icons

  static const String usdCurrencyIcon = '$iconsRoute/symbol_eeuu_currency.svg';

  static const String eurCurrencyIcon =
      '$iconsRoute/symbol_european_currency.svg';

  static const String tryCurrencyIcon =
      '$iconsRoute/symbol_turkey_currency.svg';

  static const String cnyCurrencyIcon = '$iconsRoute/symbol_china_currency.svg';

  static const String rubCurrencyIcon =
      '$iconsRoute/symbol_russian_currency.svg';

  static const String cryptoBTCIcon = '$iconsRoute/crypto_bitcoin_logo.svg';

  static const String cryptoUSDCIcon = '$iconsRoute/crypto_usdc_logo.svg';

  static const String cryptoUSDTIcon = '$iconsRoute/crypto_usdt_logo.svg';
}
