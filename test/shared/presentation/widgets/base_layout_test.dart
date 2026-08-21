import 'package:bcv_tracker_app/config/routes/pages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_page.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/base_layout.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/base_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/app_info_fake.dart';

/// The branded strip, and what its two controls do since #37.
///
/// The gear is the entry point to settings from every top-level screen, so
/// where it leads is behaviour worth pinning: it used to open a dialog over the
/// current screen and now pushes a route, and the two are indistinguishable
/// from a screenshot.

/// A page carrying the strip, mounted over the real routing table so `Get.toNamed`
/// resolves the settings route exactly as the app does.
Future<void> _pumpLayout(
  WidgetTester tester, {
  bool showBackButton = false,
  bool showSettingsAction = true,
  String title = 'Test',
}) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);
  await putFakeAppInfo();

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      home: Scaffold(
        body: BaseLayout(
          title: title,
          margins: EdgeInsets.zero,
          showBackButton: showBackButton,
          showSettingsAction: showSettingsAction,
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  testWidgets('the gear pushes the settings route instead of a dialog', (
    WidgetTester tester,
  ) async {
    await _pumpLayout(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    // The dialog it replaced. `BaseModal` itself stays for centred dialogs —
    // #37 changed what settings *is*, not what `BaseModal` is for.
    expect(find.byType(BaseModal), findsNothing);
  });

  testWidgets('a pushed screen shows the back arrow in place of the brand', (
    WidgetTester tester,
  ) async {
    await _pumpLayout(tester, showBackButton: true, showSettingsAction: false);

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);
    // The logo and the arrow are exclusive: one strip, one thing at its start.
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('a top-level screen keeps the brand and the gear', (
    WidgetTester tester,
  ) async {
    await _pumpLayout(tester);

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  // The regression this pins was shipped and spotted by eye on a device, not by
  // the suite: the goldens obscure text as blocks, so a control drifting a few
  // points inward reads as noise in a diff. A measurement does not.
  //
  // The cause was a `Flexible` title followed by a `Spacer`. `Row` hands each
  // flexible child its share of the free space by flex factor *before* asking
  // how much it wants, and a loose child's leftover does not return to the
  // `Spacer` — it strands at the end of the row and pushes the gear off the
  // edge. Both titles below are checked because the short one is what makes the
  // slack largest.
  group('the gear stays flush against the end of the strip', () {
    /// Where the strip ends: `_buildFrame` positions its row with `right: 8`.
    double stripEnd(WidgetTester tester) =>
        tester.getRect(find.byType(Scaffold)).right - 8;

    Rect gearRect(WidgetTester tester) => tester.getRect(
      find
          .ancestor(
            of: find.byIcon(Icons.settings),
            matching: find.byType(IconButton),
          )
          .first,
    );

    testWidgets('with a short title', (WidgetTester tester) async {
      await _pumpLayout(tester, title: 'Inicio');

      expect(gearRect(tester).right, moreOrLessEquals(stripEnd(tester)));
    });

    testWidgets('with a title long enough to wrap', (
      WidgetTester tester,
    ) async {
      // Longer than any of the ten translations of a screen heading, which is
      // the case rule 6 of `i18n-convention.md` is about.
      await _pumpLayout(
        tester,
        title: 'Конвертер валют Центрального банка Венесуэлы',
      );

      expect(gearRect(tester).right, moreOrLessEquals(stripEnd(tester)));
    });
  });
}
