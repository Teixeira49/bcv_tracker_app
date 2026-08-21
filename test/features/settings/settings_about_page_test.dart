import 'package:bcv_tracker_app/config/enviroment/enviroment.dart';
import 'package:bcv_tracker_app/config/routes/pages.dart';
import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:bcv_tracker_app/core/constants/app_links.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/settings/presentation/page/settings_about_page.dart';
import 'package:bcv_tracker_app/features/settings/presentation/widgets/about_widgets.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records what the screen asked the platform to open.
class _FakeLauncher extends UrlLauncherPlatform {
  final List<String> launched = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

/// The About screen (#42).
///
/// What is worth testing here is **not** that fourteen rows render — it is that
/// each one points where it claims to. A screen whose whole purpose is
/// attribution fails silently if a row opens the wrong site, and nothing about
/// the layout would look different.
late _FakeLauncher launcher; // ignore: library_private_types_in_public_api
late UrlLauncherPlatform originalLauncher;

Future<void> _pumpAbout(WidgetTester tester) async {
  Get.testMode = true;
  // Tall enough for the whole screen to lay out. A `ListView` builds lazily,
  // so on the default 800×600 window the project and credits blocks do not
  // exist at all — and a test that scrolled to reach them would be asserting
  // the scroll, not the links.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(500, 2000);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      initialRoute: AppRoutes.settingsAbout,
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps the row labelled [label] and lets the launch future resolve.
Future<void> _tapRow(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    originalLauncher = UrlLauncherPlatform.instance;
    launcher = _FakeLauncher();
    UrlLauncherPlatform.instance = launcher;
    // The API docs row is composed from the configured backend, so the test
    // has to configure one. Loaded through `dotenv` like every other
    // environment test, rather than through a seam that would let this pass
    // while the real lookup was broken.
    dotenv.testLoad(
      fileInput: '${Environment.currencyBackKey}=https://api.example.test',
    );
    Environment.debugSetEnvFileAvailable(true);
  });

  tearDown(() {
    UrlLauncherPlatform.instance = originalLauncher;
    dotenv.clean();
    Environment.debugSetEnvFileAvailable(false);
    Get.reset();
  });

  group('the data sources block', () {
    testWidgets('lists every market the app can show, with its kind', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      expect(find.byType(SettingsAboutPage), findsOneWidget);
      expect(Markets.sources.length, 9);

      for (final MarketSource source in Markets.sources) {
        expect(
          find.text(source.name),
          findsOneWidget,
          reason: '${source.name} is missing from the sources list.',
        );
      }

      // The classification is the point of the block: a rate an institution
      // sets and one that emerged from trading are different answers to "how
      // much is the dollar".
      expect(find.text(AppMessages.marketKindOfficial), findsOneWidget);
      expect(find.text(AppMessages.marketKindPeerToPeer), findsNWidgets(5));
      expect(find.text(AppMessages.marketKindAggregator), findsNWidgets(3));
    });

    testWidgets('every market row opens its own source, not another', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      for (final MarketSource source in Markets.sources) {
        await _tapRow(tester, source.name);

        expect(
          launcher.launched.last,
          source.url,
          reason: 'Tapping ${source.name} opened the wrong address.',
        );
      }

      expect(launcher.launched.length, Markets.sources.length);
    });

    testWidgets('the market names are not translated', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      // They are institutions and brands (`i18n-convention.md`, rule 9), so
      // they read the same whatever the interface language is.
      expect(find.text('Banco Central de Venezuela'), findsOneWidget);
      expect(find.text('Binance'), findsOneWidget);
      expect(find.text('DolarAPI'), findsOneWidget);
    });
  });

  group('the project block', () {
    testWidgets('links the licence and both repositories', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      for (final (String label, String url) in <(String, String)>[
        (AppMessages.licenseLabel, AppLinks.licenseUrl),
        (AppMessages.appRepositoryLabel, AppLinks.repository),
        (AppMessages.backendRepositoryLabel, AppLinks.backendRepository),
      ]) {
        await _tapRow(tester, label);
        expect(launcher.launched.last, url, reason: '"$label" points wrong.');
      }

      // Apache 2.0, matching the `LICENSE` at the root of the repository.
      expect(find.text(AppLinks.licenseName), findsOneWidget);
    });

    testWidgets('the API docs link follows the configured backend', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      await _tapRow(tester, AppMessages.apiDocsLabel);

      // Hardcoding the production host would send a tester reading a staging
      // build to the wrong documentation.
      expect(launcher.launched.last, 'https://api.example.test/docs');
    });
  });

  group('the credits block', () {
    testWidgets('names the author and offers a way to report a problem', (
      WidgetTester tester,
    ) async {
      await _pumpAbout(tester);

      await _tapRow(tester, AppMessages.reportIssueLabel);

      // The issue **form**, not the issue list: someone tapping this wants to
      // write one, not read forty.
      expect(launcher.launched.last, endsWith('/issues/new'));
      expect(find.text('Teixeira49'), findsOneWidget);
    });
  });

  testWidgets('every row that leaves the app says so', (
    WidgetTester tester,
  ) async {
    await _pumpAbout(tester);

    // The open-in-new icon is the only thing separating these rows from the
    // settings rows above, which drill down and carry a chevron.
    final int links = tester.widgetList(find.byType(AboutLinkTile)).length;
    expect(links, Markets.sources.length + 4 + 2);
    expect(find.byIcon(Icons.open_in_new_rounded), findsNWidgets(links));
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });
}
