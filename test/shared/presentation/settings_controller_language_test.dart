import 'package:bcv_tracker_app/shared/domain/entities/language.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _langKey = 'language_code';

void main() {
  // `SharedPreferences` needs the binding for its method channel.
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsController controller;

  setUp(() {
    Get.testMode = true;
    controller = SettingsController();
  });

  tearDown(() => Get.reset());

  group('selectedLanguage', () {
    test('falls back to the default for a code this build does not know', () {
      // The scenario the issue is about: `en_EN` is what today's build stores,
      // and the day someone corrects it to `en_US` every install that had it
      // saved would hit a `firstWhere` with no match.
      controller.favLanguageCode.value = 'en_US';

      expect(() => controller.selectedLanguage, returnsNormally);
      expect(
        controller.selectedLanguage.code,
        SettingsController.defaultLanguage.code,
      );
    });

    test('falls back for a value that is not a locale at all', () {
      controller.favLanguageCode.value = 'nonsense';

      expect(controller.selectedLanguage.code, 'es_ES');
    });

    test('returns the matching option for a known code', () {
      controller.favLanguageCode.value = 'ja_JA';

      expect(controller.selectedLanguage.code, 'ja_JA');
      expect(controller.selectedLanguage.name, '日本語');
    });

    test('the fallback is an element of languageOptions', () {
      // `DropdownButtonFormField` asserts its value is one of its items, and
      // `LanguageOption` does not override `==`, so this has to hold by
      // identity — not just by code.
      expect(
        controller.languageOptions,
        contains(same(SettingsController.defaultLanguage)),
      );
    });
  });

  group('restoreLanguageCode()', () {
    Future<SharedPreferences> prefsWith(Map<String, Object> values) {
      SharedPreferences.setMockInitialValues(values);
      return SharedPreferences.getInstance();
    }

    test('normalises an unknown stored code and writes it back', () async {
      final prefs = await prefsWith({_langKey: 'en_EN_OLD'});

      final resolved = await controller.restoreLanguageCode(prefs, 'en_EN_OLD');

      expect(resolved, 'es_ES');
      // Rewritten so the fallback happens once, not on every launch.
      expect(prefs.getString(_langKey), 'es_ES');
    });

    test('leaves a known stored code untouched, on disk too', () async {
      final prefs = await prefsWith({_langKey: 'fr_FR'});

      final resolved = await controller.restoreLanguageCode(prefs, 'fr_FR');

      expect(resolved, 'fr_FR');
      expect(prefs.getString(_langKey), 'fr_FR');
    });

    test('a stored code with no underscore comes back with a region', () async {
      // `loadPreferences` splits the locale on `_` and indexes at [1]. A bare
      // language code used to be a RangeError waiting in that same method;
      // normalising against the known list removes the shape mismatch too.
      final prefs = await prefsWith({_langKey: 'es'});

      final resolved = await controller.restoreLanguageCode(prefs, 'es');

      expect(resolved, 'es_ES');
      expect(resolved.split('_').length, 2);
    });

    test('every option this build ships survives a round trip', () async {
      final prefs = await prefsWith({});

      for (final LanguageOption option in controller.languageOptions) {
        expect(
          await controller.restoreLanguageCode(prefs, option.code),
          option.code,
        );
      }
    });
  });

  group('isKnownLanguage()', () {
    test('recognises every option this build ships', () {
      for (final LanguageOption option in controller.languageOptions) {
        expect(controller.isKnownLanguage(option.code), isTrue);
      }
    });

    test('rejects a code outside the list', () {
      expect(controller.isKnownLanguage('en_US'), isFalse);
      expect(controller.isKnownLanguage(''), isFalse);
    });
  });
}
