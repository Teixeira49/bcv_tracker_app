import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme_mode';
const _favMarketKey = 'fav_market';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsController controller;

  setUp(() {
    Get.testMode = true;
    controller = SettingsController();
  });

  tearDown(() => Get.reset());

  group('setFavMarket()', () {
    test('persists the chosen market and updates the observable', () async {
      SharedPreferences.setMockInitialValues({});
      controller.setFavMarket(1);

      expect(controller.favMarketIndex.value, 1);
      // The write is async; let it settle.
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(_favMarketKey), 1);
    });

    test('does nothing when the market is already selected', () async {
      SharedPreferences.setMockInitialValues({});
      controller.favMarketIndex.value = 2;

      controller.setFavMarket(2);
      await Future<void>.delayed(Duration.zero);

      // No write happened: the early return skipped SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(_favMarketKey), isNull);
    });
  });

  group('setFavTheme()', () {
    // setFavTheme ends in Get.changeThemeMode, which reassembles the app, so it
    // only works inside a mounted GetMaterialApp.
    testWidgets('persists the theme and updates the observable', (
      tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      SharedPreferences.setMockInitialValues({});

      controller.setFavTheme(ThemeMode.dark);
      await tester.pump();

      expect(controller.favBrightness.value, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_themeKey), 'dark');
    });

    testWidgets('does nothing when the theme is already selected', (
      tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      SharedPreferences.setMockInitialValues({});
      controller.favBrightness.value = ThemeMode.light;

      controller.setFavTheme(ThemeMode.light);
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_themeKey), isNull);
    });
  });

  group('defaults', () {
    test('starts on the default language, system theme and first market', () {
      expect(
        controller.favLanguageCode.value,
        SettingsController.defaultLanguage.code,
      );
      expect(controller.favBrightness.value, ThemeMode.system);
      expect(controller.favMarketIndex.value, 0);
    });
  });
}
