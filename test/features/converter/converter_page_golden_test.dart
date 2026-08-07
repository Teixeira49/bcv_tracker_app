import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves one offline USD rate so the converter initialises its VES↔USD pair
/// with real content (no network image: `imgUrl` is null).
class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<List<Currency>> getCurrentDollar() async => [
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: 'Binance',
      value: 152.3068,
      tendency: 1.24,
      updateDate: DateTime(2026, 8, 1, 10, 30),
    ),
  ];

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: const []);
}

Future<void> _seedConverter() async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues({});
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final repo = Get.put(CurrencyRepository());
  Get.put(SettingsController());
  Get.put(ConverterController());

  // Drop the skeleton placeholders (they carry a `placehold.co` image URL);
  // `onReady`'s refresh repopulates the list with the offline fixture above.
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();
}

/// Golden of the converter body (VES↔USD), in light and dark. The canvas is
/// wider than a phone for the same reason as the Home golden: obscured CI text
/// renders wider than real glyphs.
void _converterGolden(String description, String fileBase) {
  const modes = <(String, bool)>[('light', false), ('dark', true)];
  for (final (mode, isDark) in modes) {
    final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      '$description — $mode',
      fileName: '${fileBase}_$mode',
      pumpBeforeTest: (tester) async {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));
      },
      pumpWidget: (tester, widget) async {
        await _seedConverter();
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
      builder: () => const MediaQuery(
        data: MediaQueryData(size: Size(600, 900)),
        child: SizedBox(width: 600, height: 900, child: ConverterPage()),
      ),
    );
  }
}

void main() {
  tearDown(Get.reset);

  _converterGolden('Converter body', 'converter_body');
}
