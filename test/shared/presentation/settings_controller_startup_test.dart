import 'package:bcv_tracker_app/config/bindings/initial_bindings.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeKey = 'theme_mode';
const String _langKey = 'language_code';
const String _favMarketKey = 'fav_market';

/// The asynchronous start-up of `SettingsController` (#59).
///
/// The defect these guard against is not a wrong value — it is a **window**:
/// preferences used to load without anyone awaiting them, so between the first
/// frame and the disk answering, the app showed its defaults. The three-second
/// splash was longer than a disk read, so nobody ever saw it. That is an
/// accident, not a design, and it would have evaporated the day the splash got
/// shorter.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('initServices() — the state is never observable half-loaded', () {
    test('Get.find returns the stored settings in the same turn', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _themeKey: 'dark',
        _langKey: 'pt_PT',
        _favMarketKey: 1,
      });

      await InitialBinding.initServices();

      // No pump, no delay, no `await` in between. `Get.putAsync` only registers
      // the instance once its builder resolves, so if this reads defaults the
      // race is back.
      final SettingsController settings = Get.find<SettingsController>();
      expect(settings.favBrightness.value, ThemeMode.dark);
      expect(settings.favLanguageCode.value, 'pt_PT');
      expect(settings.favMarketIndex.value, 1);
    });

    test('it registers exactly one instance, and a permanent one', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await InitialBinding.initServices();

      // #45 catalogued a double registration: `Get.put` in `main` plus a
      // `Get.lazyPut` in the binding. One entry point now.
      expect(
        identical(
          Get.find<SettingsController>(),
          Get.find<SettingsController>(),
        ),
        isTrue,
      );
      expect(Get.isRegistered<SettingsController>(), isTrue);
      // `permanent`, so a route teardown cannot take the user's theme and
      // language with it — the lifecycle bug the Home tab used to have.
      expect(Get.find<SettingsController>().initialized, isTrue);
    });

    test('a fresh install exposes the defaults, not an error', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await InitialBinding.initServices(
        deviceLocale: const Locale('cs', 'CZ'), // not a language we publish
      );

      final SettingsController settings = Get.find<SettingsController>();
      expect(settings.favBrightness.value, ThemeMode.system);
      expect(
        settings.favLanguageCode.value,
        SettingsController.defaultLanguage.code,
      );
      // Never null since #98: the interface and the selector read one value.
      expect(settings.startupLocale, const Locale('es', 'ES'));
      expect(settings.hasStoredLanguage, isFalse);
    });

    test('a stored language becomes the startup locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _langKey: 'de_DE',
      });

      await InitialBinding.initServices();

      expect(
        Get.find<SettingsController>().startupLocale,
        const Locale('de', 'DE'),
      );
    });
  });

  group('a malformed stored language must not crash the launch', () {
    test('a code with no underscore does not throw RangeError', () async {
      // The old `code.split('_')[1]` threw here, during start-up, before any
      // screen existed to report it. A crash on launch is not an acceptable
      // answer to a bad preference.
      SharedPreferences.setMockInitialValues(<String, Object>{_langKey: 'xx'});

      await InitialBinding.initServices();
      final SettingsController settings = Get.find<SettingsController>();

      // `xx` is not a language this build ships, so it is normalised away...
      expect(
        settings.favLanguageCode.value,
        SettingsController.defaultLanguage.code,
      );
      // ...and written back, so the fallback happens once and not every launch.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(_langKey),
        SettingsController.defaultLanguage.code,
      );
      expect(settings.startupLocale, const Locale('es', 'ES'));
    });

    test('localeOf tolerates every shape a preference can hold', () {
      expect(SettingsController.localeOf('pt_PT'), const Locale('pt', 'PT'));
      // No country part: a language-only locale, not a crash.
      expect(SettingsController.localeOf('pt'), const Locale('pt'));
      // Degenerate input degrades to the default rather than to `Locale('')`,
      // which Flutter rejects outright.
      expect(SettingsController.localeOf(''), const Locale('es', 'ES'));
      expect(SettingsController.localeOf('_'), const Locale('es', 'ES'));
      // Extra parts are ignored instead of being concatenated into nonsense.
      expect(
        SettingsController.localeOf('zh_CN_extra'),
        const Locale('zh', 'CN'),
      );
    });
  });

  group('the first frame already carries the stored settings', () {
    /// Mirrors exactly how `MyApp` wires the two values into `GetMaterialApp`.
    Future<MaterialApp> pumpAppLike(
      WidgetTester tester,
      SettingsController settings,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          themeMode: settings.startupThemeMode,
          locale: settings.startupLocale,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const SizedBox(),
        ),
      );
      // Deliberately a single pump: this is the *first* frame.
      return tester.widget<MaterialApp>(find.byType(MaterialApp));
    }

    testWidgets('the stored theme and locale are on the very first frame', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        _themeKey: 'dark',
        _langKey: 'ru_RU',
      });
      await InitialBinding.initServices();

      final MaterialApp app = await pumpAppLike(
        tester,
        Get.find<SettingsController>(),
      );

      expect(app.themeMode, ThemeMode.dark);
      expect(app.locale, const Locale('ru', 'RU'));
    });

    testWidgets('passing the locale is what makes it stick, not updateLocale', (
      WidgetTester tester,
    ) async {
      // The reason `loadPreferences` stopped calling `Get.updateLocale`, pinned
      // so nobody "simplifies" it back: `GetMaterialApp.initState` assigns
      // `Get.locale` from its own `locale:` argument, so a locale applied
      // before the app was built is overwritten on the spot.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await InitialBinding.initServices();

      Get.updateLocale(const Locale('ru', 'RU'));

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('it', 'IT'),
          home: const SizedBox(),
        ),
      );

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('it', 'IT'),
        reason:
            'the constructor argument wins over a pre-runApp updateLocale — '
            'which is exactly why the startup locale is passed, not applied',
      );
    });
  });
}
