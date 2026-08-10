import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Golden references for the converter's currency selector (#40), in light and
/// dark: the bottom sheet that replaced the centred dialog.
///
/// The sheet is rendered directly rather than opened through its route —
/// Alchemist snapshots the render object of the scenario, and a pushed route
/// lives above it in the navigator overlay, so it would not be captured.
///
/// Fixtures use `imgUrl: null`, so the rows fall back to the bundled flags
/// instead of resolving a network image.
class _FakeDollarRepository implements IDollarRepository {
  static final List<Currency> average = <Currency>[
    for (final (String platform, double value) in <(String, double)>[
      (Markets.exchangeMonitor, 153.10),
      (Markets.yadio, 150.90),
      (Markets.binance, 152.30),
      (Markets.bybit, 151.88),
    ])
      Currency(
        name: 'Dólar estadounidense',
        keyName: 'USD',
        platform: platform,
        value: value,
      ),
  ];

  @override
  Future<List<Currency>> getCurrentDollar() async => average;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async => BcvCurrencies(
    date: '2026-08-01',
    currencies: <Currency>[
      Currency(
        name: 'Dólar estadounidense',
        keyName: 'USD',
        platform: Markets.bcv,
        value: 150.12,
      ),
    ],
  );
}

Future<void> _seed() async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final CurrencyRepository repo = Get.put(CurrencyRepository());
  Get.put(ConverterController());
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();
}

void main() {
  tearDown(Get.reset);

  const modes = <(String, bool)>[('light', false), ('dark', true)];
  for (final (mode, isDark) in modes) {
    final ThemeData theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      'Currency selector sheet — $mode',
      fileName: 'currency_selector_sheet_$mode',
      // A couple of explicit pumps let `onReady`'s refresh land; the skeleton
      // shimmer never settles, so `pumpAndSettle` is out.
      pumpBeforeTest: (WidgetTester tester) async {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));
      },
      pumpWidget: (WidgetTester tester, Widget widget) async {
        await _seed();
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
      builder: () => GoldenTestGroup(
        columns: 1,
        children: <Widget>[
          GoldenTestScenario(
            name: 'selecting the origin',
            // Wider and taller than a phone for the same reason as the other
            // goldens: obscured text is wider than the glyphs it replaces, so
            // the rows wrap and the sheet needs the room to be captured whole.
            child: SizedBox(
              width: 420,
              height: 1000,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: const CurrencySelectorSheet(isInput: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
