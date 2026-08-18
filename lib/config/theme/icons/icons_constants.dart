/// Asset paths for every icon, flag and logo the app draws.
///
/// Paths in one place so a renamed or moved asset breaks in a single file instead
/// of at each `SvgPicture.asset` call — a wrong path is a runtime failure in
/// Flutter, not a compile error, so centralising is the only thing that makes it
/// catchable.
///
/// The individual constants carry no docstrings on purpose: the name and the path
/// together already say everything (`flagVenezuelaIcon`), and
/// `.agents/rules/documentation-convention.md` rules out comments that repeat the
/// code.
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

  /// Solo el wordmark «DOLAR TRACKER», con el viewBox ajustado a su caja.
  ///
  /// Existe aparte de [mainLogo] porque el splash anima las dos piezas por
  /// separado. Lo genera `tool/make_wordmark_svg.py` desde los contornos de la
  /// misma fuente, así que el tipo es idéntico al del logo completo.
  static const String brandWordmark = 'assets/brand/dt_wordmark.svg';

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
