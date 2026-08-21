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

  /// Decimals a converted amount **always** shows.
  ///
  /// Two, because that is how a bolívar price is quoted — the converter used to
  /// print the raw `double` and showed `864.0962999999999`, which is the
  /// arithmetic, not the answer.
  ///
  /// This is the floor, not the whole answer: since #37's increment the user
  /// picks a **ceiling** between this and [converterMaxDecimals], and a figure
  /// is shown with as many decimals as it genuinely has, between the two. A
  /// value with fewer is padded to this; one with more is rounded at the
  /// ceiling.
  ///
  /// **Deliberately a single constant.** Making the precision a setting was a
  /// `SettingsController` read wired into `CurrencyHelpers.castAmount`'s
  /// argument, exactly as this comment predicted — no hunt through the widgets,
  /// because every call site already routed through here. The rounding is
  /// applied **only when formatting**; `ConverterController` keeps the full
  /// precision, so raising the ceiling never has to recompute anything.
  static const int converterAmountDecimals = 2;

  /// Lowest ceiling the decimals setting offers, and the same value as the
  /// floor: at the minimum the converter behaves exactly as it did before the
  /// setting existed.
  static const int converterMinDecimals = converterAmountDecimals;

  /// Highest ceiling the decimals setting offers.
  ///
  /// Ten, which is past what any rate published to this app justifies and short
  /// of where a `double` stops being able to back the digits it prints. It is a
  /// ceiling on the *request*, not on what gets shown: a figure with four real
  /// decimals still shows four.
  static const int converterMaxDecimals = 10;
}
