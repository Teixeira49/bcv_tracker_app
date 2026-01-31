import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/language.dart';

class SettingsController extends GetxController {
  RxInt favMarketIndex = 0.obs;
  var favBrightness = ThemeMode.system.obs;
  var favLanguageCode = 'es_ES'.obs;

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';
  static const String _favMarketKey = 'fav_market';

  List<LanguageOption> languageOptions = [
    LanguageOption(code: 'es_ES', name: 'Español', flag: '🇪🇸'),
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

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() async {
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
      favLanguageCode.value = langCode;
      var localeParts = langCode.split('_');
      Get.updateLocale(Locale(localeParts[0], localeParts[1]));
    }
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
