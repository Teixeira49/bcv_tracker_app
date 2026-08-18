import 'package:bcv_tracker_app/core/i18n/languages/_languages.dart';
import 'package:get/get.dart';

/// Assembles the ten language maps for GetX.
///
/// The single registration point: [keys] is what `GetMaterialApp(translations:)`
/// receives, and it is also what `translation_parity_test.dart` reads — testing the
/// registration rather than the files means the suite also fails if a language map
/// stops being wired in, not only if a key goes missing.
///
/// The locale codes here are the contract. `SettingsController.languageOptions`
/// must match them exactly, which it did not until
/// [#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98) corrected `en_EN`
/// and `ja_JA`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUs,
    'es_ES': esEs,
    'pt_PT': ptPt,
    'zh_CN': zhCn,
    'fr_FR': frFr,
    'de_DE': deDe,
    'it_IT': itIt,
    'ja_JP': jaJp,
    'ko_KR': koKr,
    'ru_RU': ruRu,
  };
}
