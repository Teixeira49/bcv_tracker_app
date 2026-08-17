import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/language.dart';

/// The user's settings — theme, language, favourite market — for the whole
/// session.
///
/// A **`GetxService`**, not a controller: it belongs to no view, outlives every
/// screen and is the same role `CurrencyRepository` already plays. The name is
/// kept for continuity with the rest of the codebase.
///
/// **Why the initialisation is asynchronous and awaited (#59).** Reading
/// `SharedPreferences` is a disk round-trip. It used to be started from
/// `onInit` and never awaited, so theme and locale landed at some point *after*
/// the first frame and the app briefly showed defaults before jumping to the
/// user's choice. Nobody saw it because the three-second splash was longer than
/// a disk read — an accidental protection that would have disappeared the day
/// someone shortened the splash. Now `main` awaits [init] before `runApp`, and
/// `MyApp` reads [startupThemeMode] and [startupLocale] straight into
/// `GetMaterialApp`: the first frame is already correct, with no window to
/// flicker in.
///
/// **Why loading no longer calls `Get.changeThemeMode` / `Get.updateLocale`.**
/// Those apply a *change* to a running app, and at startup there is nothing
/// running yet — worse, `GetMaterialApp.initState` assigns `Get.locale` from
/// its own `locale:` argument, so a locale set before `runApp` was overwritten
/// on the spot. Startup goes through the constructor arguments; the setters
/// below still use the framework calls, which is what they are for.
class SettingsController extends GetxService {
  /// One reactive style throughout: explicit type, `final`, `.obs`.
  final RxInt favMarketIndex = 0.obs;
  final Rx<ThemeMode> favBrightness = ThemeMode.system.obs;
  final RxString favLanguageCode = defaultLanguage.code.obs;

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';
  static const String _favMarketKey = 'fav_market';

  /// Whether the user has ever chosen a language on this install.
  ///
  /// Not the same question as "is [favLanguageCode] the default": the default
  /// is also a legitimate choice, and telling the two apart is what lets the
  /// app follow the device until the user says otherwise. See [startupLocale].
  bool _hasStoredLanguage = false;

  /// The language the app falls back to, and the first entry of
  /// [languageOptions].
  ///
  /// Declared apart so the fallback is guaranteed to be **in** the list: the
  /// alternative is looking it up by code, which is the very lookup that can
  /// fail and the reason this constant exists.
  static const LanguageOption defaultLanguage = LanguageOption(
    code: 'es_ES',
    name: 'Español',
    flag: '🇪🇸',
  );

  final List<LanguageOption> languageOptions = const <LanguageOption>[
    defaultLanguage,
    LanguageOption(code: 'en_EN', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'pt_PT', name: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'zh_CN', name: '简体中文', flag: '🇨🇳'),
    LanguageOption(code: 'fr_FR', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'de_DE', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'it_IT', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'ja_JA', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'ko_KR', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'ru_RU', name: 'Русский', flag: '🇷🇺'),
  ];

  /// The option the language selector must show: the one matching
  /// [favLanguageCode], or [defaultLanguage] when the stored code is not one
  /// this build knows.
  ///
  /// `favLanguageCode` comes from `SharedPreferences`, so its value is whatever
  /// *any* past version of the app wrote there, while [languageOptions] is a
  /// fixed list of the current code. When the two stop agreeing, the selector
  /// used to throw `StateError` and take the settings screen down with it —
  /// the one screen where the user could have picked a language to get out of
  /// the problem.
  LanguageOption get selectedLanguage => languageOptions.firstWhere(
    (LanguageOption language) => language.code == favLanguageCode.value,
    orElse: () => defaultLanguage,
  );

  /// Whether [code] is one of the languages this build ships.
  bool isKnownLanguage(String code) =>
      languageOptions.any((LanguageOption language) => language.code == code);

  /// The theme `GetMaterialApp` must be built with.
  ///
  /// Read once, before the first frame. Later changes go through
  /// [setFavTheme] and `Get.changeThemeMode`, which GetX resolves ahead of this
  /// value — so this is the starting point, not a permanent override.
  ThemeMode get startupThemeMode => favBrightness.value;

  /// The locale the first frame must use, or `null` to follow the device.
  ///
  /// `null` when nothing was stored, which preserves the behaviour the app has
  /// today: a fresh install follows `Get.deviceLocale`. That the selector then
  /// shows a language the interface is not in is a separate defect, tracked in
  /// [#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98) — deciding
  /// between following the device and imposing the default is a product call,
  /// and this refactor deliberately changes no behaviour. When it is made, this
  /// getter is the single place it lands.
  Locale? get startupLocale =>
      _hasStoredLanguage ? localeOf(favLanguageCode.value) : null;

  /// Builds the [Locale] a `xx_YY` settings code names.
  ///
  /// Tolerates a code with no country part. Every entry of [languageOptions]
  /// has one, so today this cannot be reached through the UI — but the code
  /// also arrives from `SharedPreferences`, written by *any* past version of
  /// the app, and the previous `code.split('_')[1]` would have thrown a
  /// `RangeError` **during startup**, before any screen existed to report it.
  /// A crash on launch is not an acceptable answer to a bad preference.
  static Locale localeOf(String code) {
    final List<String> parts = code
        .split('_')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return localeOf(defaultLanguage.code);
    }
    return parts.length >= 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  /// Loads the stored settings and returns itself, for `Get.putAsync`.
  ///
  /// Returning `this` is what lets the registration be awaited: `Get.putAsync`
  /// registers the value its builder resolves to, so nothing can `Get.find`
  /// this service until the preferences are in memory. That is the whole point
  /// of #59 — the state is never observable half-loaded.
  Future<SettingsController> init() async {
    await loadPreferences();
    return this;
  }

  /// Reads the three settings from `SharedPreferences` into the observables.
  ///
  /// Pure state: no `Get.changeThemeMode`, no `Get.updateLocale`. See the class
  /// doc for why applying them here was both redundant and, for the locale,
  /// actively undone by `GetMaterialApp`.
  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int? marketIndex = prefs.getInt(_favMarketKey);
    if (marketIndex != null) {
      favMarketIndex.value = marketIndex;
    }

    final String? themeName = prefs.getString(_themeKey);
    if (themeName != null) {
      favBrightness.value = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      );
    }

    final String? langCode = prefs.getString(_langKey);
    if (langCode != null) {
      favLanguageCode.value = await restoreLanguageCode(prefs, langCode);
      _hasStoredLanguage = true;
    }
  }

  /// Normalises a language code read from `SharedPreferences` against the
  /// languages this build ships, and returns the one the app must use.
  ///
  /// An unrecognised code is **written back** as the default, so the fallback
  /// happens once instead of on every launch.
  ///
  /// Kept apart from [loadPreferences] because it is the decision, and the part
  /// worth testing on its own.
  Future<String> restoreLanguageCode(
    SharedPreferences prefs,
    String stored,
  ) async {
    if (isKnownLanguage(stored)) return stored;

    await prefs.setString(_langKey, defaultLanguage.code);
    return defaultLanguage.code;
  }

  Future<void> setFavMarket(int index) async {
    if (favMarketIndex.value == index) return;

    favMarketIndex.value = index;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_favMarketKey, index);
  }

  Future<void> setFavLanguage(String code) async {
    if (favLanguageCode.value == code) return;

    favLanguageCode.value = code;
    _hasStoredLanguage = true;
    Get.updateLocale(localeOf(code));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  Future<void> setFavTheme(ThemeMode themeMode) async {
    if (favBrightness.value == themeMode) return;

    favBrightness.value = themeMode;
    Get.changeThemeMode(themeMode);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }
}
