import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/constants.dart';
import '../../domain/entities/language.dart';

/// The user's settings — theme, language, favourite market and the converter's
/// decimals ceiling — for the whole session.
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

  /// Most decimals the converter may show, between
  /// [Constants.converterMinDecimals] and [Constants.converterMaxDecimals].
  ///
  /// A **ceiling**, not a count: `CurrencyHelpers.castAmount` shows a figure
  /// with as many decimals as it genuinely has, never fewer than two and never
  /// more than this. At the minimum the converter formats exactly as it did
  /// before the setting existed, which is what makes the default safe.
  ///
  /// It changes nothing about the arithmetic. `ConverterController` keeps the
  /// full `double`; this is read at the point of display, so moving it never
  /// recomputes a conversion.
  final RxInt favDecimals = Constants.converterMinDecimals.obs;

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';
  static const String _favMarketKey = 'fav_market';
  static const String _decimalsKey = 'converter_decimals';

  /// Whether the user has ever chosen a language on this install.
  ///
  /// Not the same question as "is [favLanguageCode] the default": the default
  /// is also a legitimate choice, and telling the two apart is what decides
  /// whether the app keeps following the device. Exposed because the settings
  /// screen's behaviour depends on it — see [setFavLanguage].
  bool get hasStoredLanguage => _hasStoredLanguage;
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

  /// The ten languages this build ships, by **store-shaped locale code**.
  ///
  /// Every code here matches a key `AppTranslations` registers, exactly. Two of
  /// them used not to: the selector offered `en_EN` and `ja_JA` while the
  /// translations were filed under `en_US` and `ja_JP`, and it only worked
  /// because GetX resolves on the language code alone when the full match
  /// fails. Harmless on screen, but the invalid value was persisted to
  /// `SharedPreferences` and handed to `intl` to format dates and amounts —
  /// and it made "does the device locale match a language we publish?" a
  /// question that could not be answered by comparison. #98 needs that
  /// question answered, so the codes were corrected; [_legacyLanguageCodes]
  /// carries the installs that already stored the old ones.
  final List<LanguageOption> languageOptions = const <LanguageOption>[
    defaultLanguage,
    LanguageOption(code: 'en_US', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'pt_PT', name: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'zh_CN', name: '简体中文', flag: '🇨🇳'),
    LanguageOption(code: 'fr_FR', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'de_DE', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'it_IT', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'ja_JP', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'ko_KR', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'ru_RU', name: 'Русский', flag: '🇷🇺'),
  ];

  /// Codes past versions wrote, mapped to the ones this build uses.
  ///
  /// Without this, an install that had chosen English would hit
  /// [restoreLanguageCode]'s "unknown code" branch and be **moved to Spanish**
  /// — a correction to an internal identifier taking away a choice the user
  /// made on purpose. Translated instead, and rewritten once.
  static const Map<String, String> _legacyLanguageCodes = <String, String>{
    'en_EN': 'en_US',
    'ja_JA': 'ja_JP',
  };

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

  /// The locale the first frame must use. Never `null`.
  ///
  /// It reads [favLanguageCode] unconditionally, and that is the fix for #98.
  /// The interface and the selector are now driven by **one** value, so they
  /// cannot disagree — which is exactly what they used to do: a fresh install
  /// rendered in the device's language while the selector displayed "Español",
  /// because the code fed the selector and `Get.deviceLocale` fed the screen,
  /// and nothing reconciled them.
  ///
  /// On a fresh install [favLanguageCode] is already the device's language,
  /// resolved by [resolveDeviceLanguage] — the app follows the device, which is
  /// what it effectively did before. The difference is that the selector now
  /// says so.
  Locale get startupLocale => localeOf(favLanguageCode.value);

  /// The shipped language that best matches [device], or the default.
  ///
  /// Two passes, and the second is the one that matters here. An exact
  /// `xx_YY` hit is rare in the field: this app's own audience runs `es_VE`,
  /// not `es_ES`, and English-speaking devices are as likely to be `en_GB` as
  /// `en_US`. Matching on the language code alone is what makes "follow the
  /// device" mean anything — without it, a Venezuelan phone would fall through
  /// to the default and only *look* right by coincidence.
  ///
  /// A device in a language this build does not publish gets
  /// [defaultLanguage], not the interface in that language: the app has ten
  /// translations and Spanish is the one to land on when none of them fits.
  String resolveDeviceLanguage(Locale? device) {
    if (device == null) {
      return defaultLanguage.code;
    }

    final String? country = device.countryCode;
    if (country != null && country.isNotEmpty) {
      final String exact = '${device.languageCode}_$country';
      if (isKnownLanguage(exact)) {
        return exact;
      }
    }

    for (final LanguageOption option in languageOptions) {
      if (option.code.split('_').first == device.languageCode) {
        return option.code;
      }
    }
    return defaultLanguage.code;
  }

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
  /// [deviceLocale] defaults to `Get.deviceLocale` and is a parameter so a test
  /// can name the device's language instead of inheriting the host's.
  Future<SettingsController> init({Locale? deviceLocale}) async {
    await loadPreferences(deviceLocale: deviceLocale ?? Get.deviceLocale);
    return this;
  }

  /// Reads the four settings from `SharedPreferences` into the observables.
  ///
  /// Pure state: no `Get.changeThemeMode`, no `Get.updateLocale`. See the class
  /// doc for why applying them here was both redundant and, for the locale,
  /// actively undone by `GetMaterialApp`.
  Future<void> loadPreferences({Locale? deviceLocale}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int? marketIndex = prefs.getInt(_favMarketKey);
    if (marketIndex != null) {
      favMarketIndex.value = marketIndex;
    }

    // Clamped on the way in, not only on the way out: the stored value is
    // whatever *any* build wrote there, and an out-of-range ceiling would
    // surface as an absurd rendering on the converter, which is not where a bad
    // preference should show up. (Until #63 the failure was louder — the value
    // reached `toStringAsFixed`, which throws above 20; `NumberFormat` merely
    // obeys.)
    final int? decimals = prefs.getInt(_decimalsKey);
    if (decimals != null) {
      favDecimals.value = decimals.clamp(
        Constants.converterMinDecimals,
        Constants.converterMaxDecimals,
      );
    }

    final String? themeName = prefs.getString(_themeKey);
    if (themeName != null) {
      favBrightness.value = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      );
    }

    // The language is the one setting with a meaningful "never chosen" state,
    // and #98 is what happens when that state is ignored: the app followed the
    // device while the selector kept displaying the default. Resolving the
    // device's language into `favLanguageCode` collapses the two sources into
    // one, so the screen and the selector are the same answer by construction.
    final String? langCode = prefs.getString(_langKey);
    if (langCode != null) {
      favLanguageCode.value = await restoreLanguageCode(prefs, langCode);
      _hasStoredLanguage = true;
    } else {
      favLanguageCode.value = resolveDeviceLanguage(deviceLocale);
      // Deliberately **not** persisted. Following the device is a default, not
      // a decision, and writing it down would freeze the app to whatever
      // language the phone happened to be in on first launch.
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

    // A renamed code is not an unknown one. `en_EN` and `ja_JA` were this
    // build's own identifiers until #98 corrected them, so an install carrying
    // one gets translated and rewritten — not dropped to Spanish, which would
    // take away a choice the user made deliberately.
    final String? migrated = _legacyLanguageCodes[stored];
    if (migrated != null) {
      await prefs.setString(_langKey, migrated);
      return migrated;
    }

    await prefs.setString(_langKey, defaultLanguage.code);
    return defaultLanguage.code;
  }

  Future<void> setFavMarket(int index) async {
    if (favMarketIndex.value == index) return;

    favMarketIndex.value = index;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_favMarketKey, index);
  }

  /// Applies and persists a language chosen in the selector.
  ///
  /// **No early return on "already selected".** It used to open with
  /// `if (favLanguageCode.value == code) return;`, and since the value started
  /// at the default, tapping "Español" on a fresh install left through it
  /// without ever applying anything — the user could not choose the language
  /// the selector was showing them. That is the visible half of #98.
  ///
  /// The guard that replaces it compares against the **effective** locale
  /// rather than against this object's own field, so it can only skip work that
  /// has genuinely already happened. Persisting is unconditional and that is
  /// the point: it turns "the phone is in English" into "the user wants
  /// English", so a later change of the phone's language no longer moves the
  /// app. Choosing the language you were already being shown is a real action.
  Future<void> setFavLanguage(String code) async {
    favLanguageCode.value = code;
    _hasStoredLanguage = true;

    final Locale next = localeOf(code);
    if (Get.locale != next) {
      Get.updateLocale(next);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  /// Applies and persists a new decimals ceiling, clamped to the offered range.
  ///
  /// The counter on the settings screen already stops at both ends, so the
  /// clamp here is not for it: it is for every other caller this setter will
  /// ever have. A ceiling outside `2..10` reaches `CurrencyHelpers.formatNumber`
  /// and comes back as a figure with twenty decimals — nonsense on the
  /// converter, produced by a screen the user left minutes ago.
  Future<void> setFavDecimals(int decimals) async {
    final int next = decimals.clamp(
      Constants.converterMinDecimals,
      Constants.converterMaxDecimals,
    );
    if (favDecimals.value == next) return;

    favDecimals.value = next;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_decimalsKey, next);
  }

  Future<void> setFavTheme(ThemeMode themeMode) async {
    if (favBrightness.value == themeMode) return;

    favBrightness.value = themeMode;
    Get.changeThemeMode(themeMode);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }
}
