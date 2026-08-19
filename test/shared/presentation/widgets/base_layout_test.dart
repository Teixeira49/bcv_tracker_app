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
}) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      home: Scaffold(
        body: BaseLayout(
          title: 'Test',
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
}
