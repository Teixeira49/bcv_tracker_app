import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/language.dart';

class SettingsController extends GetxController {
  RxInt favMarketIndex = 0.obs;
  var favBrightness = ThemeMode.system.obs;
  var favLanguageCode = defaultLanguage.code.obs;

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';
  static const String _favMarketKey = 'fav_market';

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

  List<LanguageOption> languageOptions = [
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

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar Marcado
    final marketIndex = prefs.getInt(_favMarketKey);
    if (marketIndex != null) {
      favMarketIndex.value = marketIndex;
    }
    
    // Cargar Tema
    final themeName = prefs.getString(_themeKey);
    if (themeName != null) {
      favBrightness.value = ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system);
    }
    Get.changeThemeMode(favBrightness.value);

    // Cargar Idioma
    final langCode = prefs.getString(_langKey);
    if (langCode != null) {
      final String resolved = await restoreLanguageCode(prefs, langCode);

      favLanguageCode.value = resolved;
      var localeParts = resolved.split('_');
      Get.updateLocale(Locale(localeParts[0], localeParts[1]));
    }
  }

  /// Normalises a language code read from `SharedPreferences` against the
  /// languages this build ships, and returns the one the app must use.
  ///
  /// An unrecognised code is **written back** as the default, so the fallback
  /// happens once instead of on every launch. Normalising here also guarantees
  /// the `xx_YY` shape the caller assumes when it splits the locale: a stored
  /// code without an underscore would otherwise throw on `localeParts[1]`.
  ///
  /// Kept apart from [loadPreferences] because that one ends in
  /// `Get.updateLocale`, a framework-wide side effect; this is the decision,
  /// and it is the part worth testing.
  Future<String> restoreLanguageCode(
    SharedPreferences prefs,
    String stored,
  ) async {
    if (isKnownLanguage(stored)) return stored;

    await prefs.setString(_langKey, defaultLanguage.code);
    return defaultLanguage.code;
  }

  void setFavMarket(int index) async {
    if (favMarketIndex.value == index) return;

    favMarketIndex.value = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_favMarketKey, index);
  }


  void setFavLanguage(String code) async {
    if (favLanguageCode.value == code) return;

    favLanguageCode.value = code;
    var localeParts = code.split('_');
    Get.updateLocale(Locale(localeParts[0], localeParts[1]));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  void setFavTheme(ThemeMode themeMode) async {
    if (favBrightness.value == themeMode) return;

    favBrightness.value = themeMode;
    Get.changeThemeMode(themeMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }
}
