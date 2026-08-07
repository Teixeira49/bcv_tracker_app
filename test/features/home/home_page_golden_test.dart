import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/home/presentation/controller/home_controller.dart';
import 'package:bcv_tracker_app/features/home/presentation/page/home_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves fixed, offline rates so the Home cards render with real content. The
/// average fixtures use `imgUrl: null` (falls back to the currency initials, no
/// network image); the BCV fixtures render their local flag SVGs.
class _FakeDollarRepository implements IDollarRepository {
  static final _date = DateTime(2026, 8, 1, 10, 30);

  static List<Currency> get _average => [
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: 'Binance',
      value: 152.3068,
      tendency: 1.24,
      updateDate: _date,
    ),
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: 'Bybit',
      value: 151.8800,
      tendency: -0.53,
      updateDate: _date,
    ),
  ];

  static List<Currency> get _bcv => [
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: 'BCV',
      value: 150.1200,
      updateDate: _date,
    ),
    Currency(
      name: 'Euro',
      keyName: 'EUR',
      platform: 'BCV',
      value: 163.4500,
      updateDate: _date,
    ),
  ];

  @override
  Future<List<Currency>> getCurrentDollar() async => _average;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: _bcv);
}

/// Registers the fakes and selects the starting tab. `favMarketIndex` is set
/// synchronously (its real restore from `SharedPreferences` is async and would
/// not be ready when `_HomeBody.initState` reads it for the initial tab).
Future<void> _seedHome(int marketIndex) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues({});
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final repo = Get.put(CurrencyRepository());
  Get.put(SettingsController()).favMarketIndex.value = marketIndex;
  Get.put(HomeController());

  // Drop the skeleton placeholders (they carry a `placehold.co` image URL);
  // `onReady`'s refresh repopulates the lists with the offline fixtures above.
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();
}

/// Golden of the Home page on the given tab, in light and dark. The canvas is
/// wider than a phone on purpose: the CI goldens obscure text as blocks, which
/// are wider than the real glyphs, so a phone width would overflow the dense
/// rate rows. Proportions differ from the device, but layout, palette and the
/// variation colours — what this guards — are captured faithfully.
void _homeGolden(String description, String fileBase, int marketIndex) {
  const modes = <(String, bool)>[('light', false), ('dark', true)];
  for (final (mode, isDark) in modes) {
    final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      '$description — $mode',
      fileName: '${fileBase}_$mode',
      // The skeleton shimmer never settles, so avoid pumpAndSettle: a couple of
      // explicit pumps let `onReady`'s refresh land and stop the loading state.
      pumpBeforeTest: (tester) async {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));
      },
      pumpWidget: (tester, widget) async {
        await _seedHome(marketIndex);
        await tester.pumpWidget(
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: const Locale('es', 'ES'),
            fallbackLocale: const Locale('en', 'US'),
            theme: theme,
            home: Scaffold(body: widget),
          ),
        );
      },
      // `BaseLayout` sizes itself from `MediaQuery.size`, not from the incoming
      // constraints, so the MediaQuery is what pins the page size; the SizedBox
      // then gives Alchemist a bounded box to measure.
      builder: () => const MediaQuery(
        data: MediaQueryData(size: Size(600, 900)),
        child: SizedBox(width: 600, height: 900, child: HomePage()),
      ),
    );
  }
}

void main() {
  tearDown(Get.reset);

  _homeGolden('Home average tab', 'home_average_tab', 0);
  _homeGolden('Home BCV tab', 'home_bcv_tab', 1);
}
