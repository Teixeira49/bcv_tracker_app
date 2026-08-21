import 'package:bcv_tracker_app/config/bindings/initial_bindings.dart';
import 'package:bcv_tracker_app/shared/domain/entities/language.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _langKey = 'language_code';

/// The first launch, where #98 lived.
///
/// The app rendered in the device's language while the settings selector
/// displayed "Español", and tapping "Español" did nothing — so the user could
/// not choose the language the selector was telling them they already had.
/// Three pieces disagreeing: `favLanguageCode` started at the default and fed
/// the selector, `Get.deviceLocale` fed the screen, and nothing reconciled them
/// because `loadPreferences` only applied a locale when one was stored.
///
/// The decision taken: **the app follows the device** until the user picks a
/// language. The selector then has to say so, which is what these pin.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<SettingsController> freshInstallOn(Locale device) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await InitialBinding.initServices(deviceLocale: device);
    return Get.find<SettingsController>();
  }

  group('a fresh install follows the device', () {
    test('the selector shows the language the interface is in', () async {
      // The exact scenario reported: a phone in English, a fresh install.
      final SettingsController settings = await freshInstallOn(
        const Locale('en', 'US'),
      );

      // What the screen renders...
      expect(settings.startupLocale, const Locale('en', 'US'));
      // ...and what the selector displays. One value, so they cannot disagree.
      expect(settings.selectedLanguage.name, 'English');
      expect(settings.favLanguageCode.value, 'en_US');
    });

    test('a Venezuelan phone gets Spanish, not by coincidence', () async {
      // `es_VE` is not in `languageOptions` and never will be — this is the
      // language-code pass earning its place. Without it the app's own audience
      // would fall through to the default and only *look* correct.
      final SettingsController settings = await freshInstallOn(
        const Locale('es', 'VE'),
      );

      expect(settings.favLanguageCode.value, 'es_ES');
      expect(settings.selectedLanguage.name, 'Español');
    });

    test('a British phone gets English, not Spanish', () async {
      final SettingsController settings = await freshInstallOn(
        const Locale('en', 'GB'),
      );

      expect(settings.favLanguageCode.value, 'en_US');
    });

    test('a Brazilian phone gets Portuguese', () async {
      final SettingsController settings = await freshInstallOn(
        const Locale('pt', 'BR'),
      );

      expect(settings.favLanguageCode.value, 'pt_PT');
    });

    test('a language we do not publish falls back to Spanish', () async {
      // The issue's third row: the app must land on its own default, **not**
      // render in Czech via `fallbackLocale`.
      final SettingsController settings = await freshInstallOn(
        const Locale('cs', 'CZ'),
      );

      expect(settings.favLanguageCode.value, 'es_ES');
      expect(settings.startupLocale, const Locale('es', 'ES'));
    });

    test('no device locale at all is not a crash', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await InitialBinding.initServices(deviceLocale: null);

      // `Get.deviceLocale` can be null before the binding reports one.
      expect(Get.find<SettingsController>().favLanguageCode.value, isNotNull);
    });

    test('following the device is not written to disk', () async {
      // It is a default, not a decision. Persisting it would freeze the app to
      // whatever language the phone happened to be in on first launch.
      final SettingsController settings = await freshInstallOn(
        const Locale('de', 'DE'),
      );

      expect(settings.favLanguageCode.value, 'de_DE');
      expect(settings.hasStoredLanguage, isFalse);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_langKey), isNull);
    });
  });

  group('resolveDeviceLanguage', () {
    late final SettingsController settings = SettingsController();

    test('prefers an exact match over the language-only one', () {
      expect(settings.resolveDeviceLanguage(const Locale('zh', 'CN')), 'zh_CN');
      expect(settings.resolveDeviceLanguage(const Locale('pt', 'PT')), 'pt_PT');
    });

    test('a bare language code still resolves', () {
      expect(settings.resolveDeviceLanguage(const Locale('ru')), 'ru_RU');
      expect(settings.resolveDeviceLanguage(const Locale('ko')), 'ko_KR');
    });

    test('Japanese resolves to ja_JP, the code the translations use', () {
      // Would have produced the invalid `ja_JA` before #98 corrected the list.
      expect(settings.resolveDeviceLanguage(const Locale('ja', 'JP')), 'ja_JP');
    });

    test('an unpublished language is the default, never null', () {
      expect(settings.resolveDeviceLanguage(const Locale('ar', 'EG')), 'es_ES');
      expect(settings.resolveDeviceLanguage(null), 'es_ES');
    });
  });

  group('choosing a language always applies it', () {
    testWidgets('tapping the language the selector already shows works', (
      WidgetTester tester,
    ) async {
      // The visible half of #98: `setFavLanguage` opened with
      // `if (favLanguageCode.value == code) return;`, so on a fresh install
      // tapping the displayed language left through the guard having applied
      // and saved nothing.
      // The app is pumped first: awaiting anything before the first frame
      // trips the test binding's warm-up assertion.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('en', 'US'), home: SizedBox()),
      );
      await InitialBinding.initServices(deviceLocale: const Locale('en', 'US'));
      final SettingsController settings = Get.find<SettingsController>();

      expect(settings.favLanguageCode.value, 'en_US');
      expect(settings.hasStoredLanguage, isFalse);

      await settings.setFavLanguage('en_US');
      await tester.pump();

      // It is now a decision, not a coincidence — which is what stops a later
      // change of the phone's language from moving the app.
      expect(settings.hasStoredLanguage, isTrue);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_langKey), 'en_US');
    });

    testWidgets('switching to a different language applies and persists', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('en', 'US'), home: SizedBox()),
      );
      await InitialBinding.initServices(deviceLocale: const Locale('en', 'US'));
      final SettingsController settings = Get.find<SettingsController>();

      // `runAsync`: a real language change ends in `Get.updateLocale`, which
      // reassembles the whole app — and a reassemble inside the fake clock
      // trips the binding's warm-up assertion.
      await tester.runAsync(() => settings.setFavLanguage('it_IT'));
      await tester.pump();

      expect(settings.favLanguageCode.value, 'it_IT');
      expect(settings.selectedLanguage.name, 'Italiano');
      expect(Get.locale, const Locale('it', 'IT'));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_langKey), 'it_IT');
    });

    testWidgets('a stored choice survives the phone changing language', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _langKey: 'it_IT',
      });
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));

      // The device says French; the user said Italian, on purpose.
      await InitialBinding.initServices(deviceLocale: const Locale('fr', 'FR'));

      final SettingsController settings = Get.find<SettingsController>();
      expect(settings.favLanguageCode.value, 'it_IT');
      expect(settings.startupLocale, const Locale('it', 'IT'));
    });
  });

  group('the corrected locale codes (en_US, ja_JP)', () {
    test('every option matches a locale AppTranslations registers', () {
      // The reason the codes were corrected: `en_EN` and `ja_JA` only worked
      // because GetX falls back on the language code alone, and an invalid code
      // was being persisted and handed to `intl`.
      final Set<String> registered = <String>{
        'en_US',
        'es_ES',
        'pt_PT',
        'zh_CN',
        'fr_FR',
        'de_DE',
        'it_IT',
        'ja_JP',
        'ko_KR',
        'ru_RU',
      };

      final List<String> codes = SettingsController().languageOptions
          .map((LanguageOption option) => option.code)
          .toList();

      expect(codes.toSet(), registered);
      expect(codes, hasLength(10), reason: 'no duplicates');
    });

    test(
      'an install carrying en_EN keeps English instead of losing it',
      () async {
        // The trap in renaming an identifier: `en_EN` is not an unknown code, it
        // is this build's own former one. Dropping it to the default would take
        // away a language the user chose deliberately.
        SharedPreferences.setMockInitialValues(<String, Object>{
          _langKey: 'en_EN',
        });

        await InitialBinding.initServices(
          deviceLocale: const Locale('es', 'VE'),
        );
        final SettingsController settings = Get.find<SettingsController>();

        expect(settings.favLanguageCode.value, 'en_US');
        expect(settings.selectedLanguage.name, 'English');
        expect(settings.startupLocale, const Locale('en', 'US'));
        // Rewritten once, so the migration does not run on every launch.
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(_langKey), 'en_US');
      },
    );

    test('an install carrying ja_JA keeps Japanese', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _langKey: 'ja_JA',
      });

      await InitialBinding.initServices(deviceLocale: const Locale('es', 'VE'));

      expect(Get.find<SettingsController>().favLanguageCode.value, 'ja_JP');
    });

    test('a genuinely unknown code still degrades to the default', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _langKey: 'xx_XX',
      });

      await InitialBinding.initServices(deviceLocale: const Locale('en', 'US'));

      expect(
        Get.find<SettingsController>().favLanguageCode.value,
        SettingsController.defaultLanguage.code,
      );
    });
  });
}
