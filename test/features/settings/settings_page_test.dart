import 'package:bcv_tracker_app/config/routes/pages.dart';
import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_options_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/widgets/settings_option_tile.dart';
import 'package:bcv_tracker_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The settings screen #37 replaced the dialog with: the menu, the three choice
/// sub-screens, and the navigation between them.
///
/// Driven through the **real routing table** (`AppPages.routes`) rather than by
/// pumping each page in isolation, because half of what the issue asks for is
/// navigation: that the gear opens a screen, that each entry drills down, and
/// that the value shown on the menu is the one the sub-screen just stored.
/// Pumping the widgets directly would assert the layout and miss all of it.
const String _themeKey = 'theme_mode';
const String _langKey = 'language_code';
const String _favMarketKey = 'fav_market';

/// Brings up the settings route over a real `SettingsController` loaded from
/// [prefs].
///
/// The locale is pinned to Spanish so the expected copy is the Spanish copy;
/// the device locale is passed explicitly for the same reason #59 made it a
/// parameter — otherwise the test inherits whatever the host machine is set to.
Future<SettingsController> _pumpSettings(
  WidgetTester tester, {
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(prefs);

  final SettingsController controller = Get.put(
    SettingsController(),
    permanent: true,
  );
  await controller.loadPreferences(deviceLocale: const Locale('es', 'ES'));

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      initialRoute: AppRoutes.settings,
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

/// Taps the menu entry titled [title] and waits for the sub-screen.
Future<void> _openEntry(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

/// Taps a language row and lets the app rebuild around it.
///
/// `runAsync`, for the reason `settings_controller_device_language_test.dart`
/// already documents: a real language change ends in `Get.updateLocale`, which
/// awaits `forceAppUpdate` → `performReassemble` and schedules a warm-up frame
/// from inside it. Under the fake clock the reassemble is still in flight when
/// the next `pump` begins, and the binding asserts the scheduler is idle at
/// that point. Running the tap for real lets it finish first; the failure it
/// avoids is the harness and GetX both driving the pipeline, not a defect in
/// the screen.
Future<void> _tapLanguage(WidgetTester tester, String label) async {
  await tester.runAsync(() async {
    await tester.tap(find.text(label));
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  group('the menu', () {
    testWidgets('groups the settings by section', (WidgetTester tester) async {
      await _pumpSettings(tester);

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text(AppMessages.preferencesSection), findsOneWidget);
      expect(find.text(AppMessages.appearanceSection), findsOneWidget);
      expect(find.text(AppMessages.defaultMarket), findsOneWidget);
      expect(find.text(AppMessages.language), findsOneWidget);
      expect(find.text(AppMessages.theme), findsOneWidget);
    });

    testWidgets('shows what each setting is currently set to', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(
        tester,
        prefs: <String, Object>{
          _favMarketKey: 1,
          _langKey: 'en_US',
          _themeKey: 'dark',
        },
      );

      // The criterion the dialog could not meet: the state of all three
      // settings is readable without opening any of them.
      expect(find.text(AppMessages.officialSection), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text(AppMessages.darkTheme), findsOneWidget);
    });

    testWidgets('does not offer the gear that leads to itself', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.byIcon(Icons.settings), findsNothing);
      // ...and the strip offers the way back instead.
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    // The same defect the branded strip had, in the same shipped build: a
    // `Flexible` value next to an `Expanded` title. `Row` allots each flexible
    // child its share by flex factor before asking how much it wants, and what
    // a loose child declines strands at the end of the row instead of returning
    // to its neighbours — so the value and the chevron floated inward, away
    // from the card's edge. Measured rather than left to the goldens, which
    // obscure text as blocks and cannot show a few points of drift.
    testWidgets('aligns each current value against the end of its row', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(
        tester,
        prefs: <String, Object>{_favMarketKey: 1, _themeKey: 'dark'},
      );

      for (final String value in <String>[
        AppMessages.officialSection,
        AppMessages.darkTheme,
      ]) {
        final Finder tile = find.ancestor(
          of: find.text(value),
          matching: find.byType(SettingsMenuTile),
        );
        final Rect text = tester.getRect(find.text(value));
        final Rect chevron = tester.getRect(
          find.descendant(
            of: tile,
            matching: find.byIcon(Icons.chevron_right_rounded),
          ),
        );

        // Flush against the chevron: `TextAlign.end` only reaches the edge of
        // a box that itself reaches the edge of the row.
        expect(
          text.right,
          moreOrLessEquals(chevron.left, epsilon: 1),
          reason: 'The value "$value" is not aligned with its chevron.',
        );
      }
    });
  });

  group('the language sub-screen', () {
    testWidgets('lists the ten languages this build ships', (
      WidgetTester tester,
    ) async {
      final SettingsController controller = await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.language);

      expect(find.byType(SettingsOptionsPage<String>), findsOneWidget);
      expect(
        find.byType(SettingsOptionTile<String>),
        findsNWidgets(controller.languageOptions.length),
      );
      expect(controller.languageOptions.length, 10);
      // Each language named in itself, so someone who cannot read the current
      // interface can still find their own.
      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
    });

    testWidgets('applies and persists the chosen language', (
      WidgetTester tester,
    ) async {
      final SettingsController controller = await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.language);

      await _tapLanguage(tester, 'English');

      expect(controller.favLanguageCode.value, 'en_US');
      expect(Get.locale, const Locale('en', 'US'));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_langKey), 'en_US');
    });

    testWidgets('stays open after a choice, and the menu shows it on return', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.language);

      await _tapLanguage(tester, 'English');

      // Deliberate: the app has just repainted in the new language, and that
      // repaint is the confirmation. Popping would hide it.
      expect(find.byType(SettingsOptionsPage<String>), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });
  });

  group('the market sub-screen', () {
    testWidgets('offers both tabs and persists the choice', (
      WidgetTester tester,
    ) async {
      final SettingsController controller = await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.defaultMarket);

      expect(find.byType(SettingsOptionTile<int>), findsNWidgets(2));

      await tester.tap(find.text(AppMessages.officialSection));
      await tester.pumpAndSettle();

      expect(controller.favMarketIndex.value, 1);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(_favMarketKey), 1);
    });
  });

  group('the theme sub-screen', () {
    testWidgets('offers light, dark and system, and persists the choice', (
      WidgetTester tester,
    ) async {
      final SettingsController controller = await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.theme);

      // Cards in a grid, not rows: the three themes are told apart by their
      // icon before their label, which is what earns them the grid.
      expect(find.byType(SettingsOptionCard<ThemeMode>), findsNWidgets(3));
      expect(find.byType(SettingsOptionTile<ThemeMode>), findsNothing);

      await tester.tap(find.text(AppMessages.darkTheme));
      await tester.pumpAndSettle();

      expect(controller.favBrightness.value, ThemeMode.dark);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_themeKey), ThemeMode.dark.name);
    });

    testWidgets('lays the three cards out two per row, in equal cells', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);
      await _openEntry(tester, AppMessages.theme);

      Rect cardOf(String label) => tester.getRect(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(SettingsOptionCard<ThemeMode>),
        ),
      );

      final Rect light = cardOf(AppMessages.lightTheme);
      final Rect dark = cardOf(AppMessages.darkTheme);
      final Rect system = cardOf(AppMessages.systemTheme);

      // Two on the first row, side by side...
      expect(light.top, moreOrLessEquals(dark.top));
      expect(light.right, lessThan(dark.left));
      // ...and the third below, starting where the first one does.
      expect(system.top, greaterThan(light.bottom));
      expect(system.left, moreOrLessEquals(light.left));

      // Equal cells, including the odd one out: the lone card keeps the grid's
      // width instead of stretching across the row, which is what stops the
      // set from reading as three buttons of two different sizes.
      expect(system.width, moreOrLessEquals(light.width));
      expect(dark.width, moreOrLessEquals(light.width));
    });

    testWidgets('marks the selected card with a thicker brand border', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester, prefs: <String, Object>{_themeKey: 'dark'});
      await _openEntry(tester, AppMessages.theme);

      double borderOf(String label) {
        final Card card = tester.widget<Card>(
          find.descendant(
            of: find.ancestor(
              of: find.text(label),
              matching: find.byType(SettingsOptionCard<ThemeMode>),
            ),
            matching: find.byType(Card),
          ),
        );
        return (card.shape! as RoundedRectangleBorder).side.width;
      }

      // Not colour alone: thickness is what survives greyscale, a dimmed
      // screen and a colour vision deficiency (`DESIGN.md`, Do's and Don'ts).
      expect(borderOf(AppMessages.darkTheme), 2);
      expect(borderOf(AppMessages.lightTheme), 1);
    });

    testWidgets('tells assistive tech which card is selected', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester, prefs: <String, Object>{_themeKey: 'dark'});
      await _openEntry(tester, AppMessages.theme);

      // The half of the selected state no pixel conveys.
      // Read off the card's own `Semantics`, not off the merged node: the
      // merged one also carries whatever `InkWell` contributes, and this test
      // is about what the card declares.
      bool? selectedOf(String label) => tester
          .widget<Semantics>(
            find
                .descendant(
                  of: find.ancestor(
                    of: find.text(label),
                    matching: find.byType(SettingsOptionCard<ThemeMode>),
                  ),
                  matching: find.byType(Semantics),
                )
                .first,
          )
          .properties
          .selected;

      expect(selectedOf(AppMessages.darkTheme), isTrue);
      expect(selectedOf(AppMessages.lightTheme), isFalse);
    });
  });
}
