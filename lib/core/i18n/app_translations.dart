import 'package:bcv_tracker_app/core/i18n/languages/_languages.dart';
import 'package:get/get.dart';

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
