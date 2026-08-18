/// App-wide values that are neither colours, copy, nor configuration.
///
/// Durations, date formats and the app title: things with a business meaning that
/// would otherwise be magic numbers scattered across widgets. Anything that
/// changes per environment is **not** here — that is `Environment` and the `.env`
/// file (`.agents/rules/environment-variables.md`).
class Constants {
  const Constants._();

  static const String appTitle = 'BCV Tracker';

  static const int splashDuration = 3;

  static const String bcvFormatDate = 'yyyy-MM-dd';

  static const String defaultFormatDate = 'yyyy-MM-dd HH:mm';

  /// The app logo (foreground layer), used as the branded illustration of the
  /// empty state. Declared as an asset in `pubspec.yaml`.
  static const String appLogoAsset = 'assets/images/foreground_icon_app.png';

  /// Decimals shown for a converted amount.
  ///
  /// Two, because that is how a bolívar price is quoted — the converter used to
  /// print the raw `double` and showed `864.0962999999999`, which is the
  /// arithmetic, not the answer.
  ///
  /// **Deliberately a single constant.** Turning this into something the user
  /// picks in settings should be a `SettingsController` read wired into
  /// [CurrencyHelpers.castAmount]'s `decimals` argument, not a hunt through the
  /// widgets — every call site already routes through here. The rounding is
  /// applied **only when formatting**; `ConverterController` keeps the full
  /// precision, so raising this never has to recompute anything.
  static const int converterAmountDecimals = 2;
}
