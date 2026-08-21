import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_about_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_decimals_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_language_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_theme_page.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/app_info_fake.dart';

/// Golden references for the settings screen (#37), in light and dark: the menu
/// and its sub-screens — the language list that replaced the dialog's dropdown,
/// the theme grid, and the decimals counter the increment added.
///
/// The pages are rendered directly rather than reached through their routes —
/// Alchemist snapshots the render object of the scenario, and a pushed route
/// lives above it in the navigator overlay, so it would not be captured. What
/// this pins is the layout of the rows and the palette in both modes; the
/// navigation between them is covered by `settings_page_test.dart`.
Future<void> _seed() async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SettingsController settings = Get.put(
    SettingsController(),
    permanent: true,
  );
  // Loaded explicitly, from an empty store, so the references do not depend on
  // the host machine's language.
  await settings.loadPreferences(deviceLocale: const Locale('es', 'ES'));
  await putFakeAppInfo();
}

void main() {
  tearDown(Get.reset);

  const List<(String, bool)> modes = <(String, bool)>[
    ('light', false),
    ('dark', true),
  ];
  for (final (String mode, bool isDark) in modes) {
    final ThemeData theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      'Settings screen — $mode',
      fileName: 'settings_page_$mode',
      pumpWidget: (WidgetTester tester, Widget widget) async {
        await _seed();
        await tester.pumpWidget(
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: const Locale('es', 'ES'),
            fallbackLocale: const Locale('en', 'US'),
            theme: theme,
            home: widget,
          ),
        );
      },
      builder: () => GoldenTestGroup(
        columns: 2,
        children: <Widget>[
          GoldenTestScenario(
            name: 'the menu',
            // Wider and taller than a phone for the same reason as the other
            // goldens: obscured text is wider than the glyphs it replaces, so
            // the rows wrap and need the room to be captured whole.
            child: const SizedBox(
              width: 420,
              height: 900,
              child: SettingsPage(),
            ),
          ),
          GoldenTestScenario(
            name: 'choosing a language',
            child: const SizedBox(
              width: 420,
              height: 900,
              child: SettingsLanguagePage(),
            ),
          ),
          // The grid layout, which is the one case the measurements in
          // `settings_page_test.dart` cannot fully speak for: they pin the
          // geometry of the cells, this pins that the selected card actually
          // looks marked — border, tint and icon colour — in both modes.
          GoldenTestScenario(
            name: 'choosing a theme',
            child: const SizedBox(
              width: 420,
              height: 900,
              child: SettingsThemePage(),
            ),
          ),
          // #37's increment: the third shape a setting takes here — a counter
          // with a worked example, neither a row nor a card.
          GoldenTestScenario(
            name: 'setting the decimals',
            child: const SizedBox(
              width: 420,
              height: 900,
              child: SettingsDecimalsPage(),
            ),
          ),
          // #42. Taller than its siblings because the point of the screen is
          // the list of nine sources, and a reference that cut it off would
          // not guard the thing worth guarding.
          GoldenTestScenario(
            name: 'about',
            child: const SizedBox(
              width: 420,
              height: 1500,
              child: SettingsAboutPage(),
            ),
          ),
        ],
      ),
    );
  }
}
