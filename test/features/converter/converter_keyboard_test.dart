import 'package:bcv_tracker_app/core/constants/market_constants.dart';
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

/// What the converter does while the keyboard is up, and what it accepts into
/// the amount field.
class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<List<Currency>> getCurrentDollar() async => <Currency>[
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: Markets.binance,
      value: 152.30,
    ),
  ];

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: const <Currency>[]);
}

/// Brings up the converter inside the same `Scaffold` the dashboard gives it —
/// which is what resizes the body when the keyboard opens.
Future<void> _pumpConverter(WidgetTester tester) async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final CurrencyRepository repo = Get.put(CurrencyRepository());
  // #37's increment made the decimals ceiling a setting, so both converters
  // now resolve `SettingsController`. Registered first, as
  // `test-coverage.md` asks: fakes in dependency order.
  Get.put(SettingsController());
  Get.put(ConverterController());
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: const Scaffold(body: ConverterPage()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  tearDown(Get.reset);

  testWidgets('the page survives the keyboard opening', (tester) async {
    // `BaseLayout` used to size itself from `MediaQuery.size`, so its two
    // shares added up to the whole screen no matter how much room the Scaffold
    // had actually left. With a keyboard up that overflowed by exactly the
    // keyboard's height — the striped bar users saw on the converter.
    const double keyboard = 336;
    addTearDown(tester.view.resetViewInsets);

    await _pumpConverter(tester);
    expect(tester.takeException(), isNull);

    tester.view.viewInsets = FakeViewPadding(
      bottom: keyboard * tester.view.devicePixelRatio,
    );
    await tester.pump();
    await tester.pump();

    expect(
      tester.takeException(),
      isNull,
      reason: 'no RenderFlex may overflow while the keyboard is open',
    );
    // And the page really did shrink with the body, rather than keep painting
    // under the keyboard.
    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(
      tester.getSize(find.byType(ConverterPage)).height,
      lessThanOrEqualTo(screen.height - keyboard + 1),
    );
  });

  testWidgets('the amount field takes digits and one separator', (
    tester,
  ) async {
    await _pumpConverter(tester);
    final Finder field = find.byType(TextFormField).first;

    await tester.enterText(field, '12,5');
    await tester.pump();

    expect(find.text('12,5'), findsOneWidget);
  });

  testWidgets('the amount field refuses what a hardware keyboard can send', (
    tester,
  ) async {
    await _pumpConverter(tester);
    final Finder field = find.byType(TextFormField).first;

    await tester.enterText(field, '25');
    await tester.pump();
    // Letters reach the field on a hardware keyboard, a paste or a dictation;
    // the numeric `keyboardType` does not stop any of them.
    await tester.enterText(field, '25abc');
    await tester.pump();

    expect(find.text('25abc'), findsNothing);
    expect(find.text('25'), findsOneWidget);
    // The controller kept the amount it could parse instead of falling to 0.
    expect(Get.find<ConverterController>().fromCurrency.convertedValue, 25.0);
  });
}
