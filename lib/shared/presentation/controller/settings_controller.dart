import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/market_constants.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/market.dart';

class SettingsController extends GetxController {
  RxInt favMarketIndex = 0.obs;
  var favBrightness = ThemeMode.system.obs;
  var favLanguageCode = 'es_ES'.obs;

  /// Keys of the markets the average tab asks for.
  ///
  /// Since backend v3.0.0 a market left out of the request is `off`, so this is
  /// all it takes to let the user pick which ones to follow.
  final RxSet<String> selectedMarketKeys = Markets.defaultKeys.toSet().obs;

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';
  static const String _favMarketKey = 'fav_market';
  static const String _marketsKey = 'selected_markets';

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
      favBrightness.value = ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemeMode.system,
      );
    }
    Get.changeThemeMode(favBrightness.value);

    // Cargar Idioma
    final langCode = prefs.getString(_langKey);
    if (langCode != null) {
      favLanguageCode.value = langCode;
      var localeParts = langCode.split('_');
      Get.updateLocale(Locale(localeParts[0], localeParts[1]));
    }

    // Cargar mercados seguidos. Se descartan las claves que el catálogo ya no
    // conoce y una selección vacía, para no dejar la pestaña sin tasas.
    final markets = prefs.getStringList(_marketsKey);
    if (markets != null) {
      final known = markets
          .where((key) => Markets.catalog.any((market) => market.key == key))
          .toSet();
      if (known.isNotEmpty) {
        selectedMarketKeys.assignAll(known);
      }
    }
  }

  /// Markets to request, resolved against the catalogue.
  MarketSelection get marketSelection =>
      Markets.selectionOf(selectedMarketKeys);

  bool isMarketSelected(String key) => selectedMarketKeys.contains(key);

  /// Adds or removes a market. Removing the last one is refused: an empty
  /// selection would leave the average tab with nothing to show.
  void setMarketSelected(String key, bool selected) {
    if (selected == isMarketSelected(key)) return;
    if (!selected && selectedMarketKeys.length == 1) return;

    if (selected) {
      selectedMarketKeys.add(key);
    } else {
      selectedMarketKeys.remove(key);
    }
    _persistMarkets();
  }

  void _persistMarkets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_marketsKey, selectedMarketKeys.toList());
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
