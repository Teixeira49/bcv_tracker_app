import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/custom_skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// [rate] drives how tall the output card gets: a rate that makes the converted
/// amount long enough to wrap is what used to push the swap button down.
class _FakeDollarRepository implements IDollarRepository {
  _FakeDollarRepository({required this.rate});

  final double rate;

  @override
  Future<List<Currency>> getCurrentDollar() async => <Currency>[
    Currency(
      name: 'Dólar estadounidense',
      keyName: 'USD',
      platform: Markets.binance,
      value: rate,
    ),
  ];

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: const <Currency>[]);
}

Future<void> _pumpConverter(WidgetTester tester, {double rate = 152.30}) async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository(rate: rate));
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

/// The two conversion cards, top first.
///
/// The card widget is private, but each one wraps itself in a
/// `CustomSkeletonizer`, which is not. So does the swap button — it is dropped
/// by width, being the only narrow one.
List<Rect> _cards(WidgetTester tester) {
  final List<Rect> rects = <Rect>[
    for (final Element element in find.byType(CustomSkeletonizer).evaluate())
      if (element.renderObject case final RenderBox box when box.hasSize)
        if (box.size.width > 100) box.localToGlobal(Offset.zero) & box.size,
  ];
  rects.sort((Rect a, Rect b) => a.top.compareTo(b.top));
  return rects;
}

/// Distance from the swap button's centre to the seam between the two cards.
double _driftFromSeam(WidgetTester tester) {
  final List<Rect> cards = _cards(tester);
  expect(cards.length, greaterThanOrEqualTo(2), reason: 'two cards on screen');
  final double seam = (cards[0].bottom + cards[1].top) / 2;
  return (tester.getCenter(find.byType(FloatingActionButton)).dy - seam).abs();
}

void main() {
  tearDown(Get.reset);

  testWidgets('the swap button sits on the seam between the cards', (
    tester,
  ) async {
    await _pumpConverter(tester);

    expect(_driftFromSeam(tester), lessThan(1));
  });

  testWidgets('and stays there when the output card grows taller', (
    tester,
  ) async {
    await _pumpConverter(tester);

    // The input field is single-line and scrolls, but the result is a `Text`
    // that wraps — so a long amount grows only the output card. Centred in a
    // `Stack`, the button followed the column's midpoint and drifted down by
    // half of that extra height; that is the regression under test.
    await tester.enterText(find.byType(TextFormField).first, '999999999999');
    await tester.pump();

    final List<Rect> cards = _cards(tester);
    expect(
      cards[1].height,
      greaterThan(cards[0].height),
      reason: 'the fixture must actually make the output card taller',
    );
    expect(_driftFromSeam(tester), lessThan(1));
  });

  testWidgets('the result is rounded for display, not in the arithmetic', (
    tester,
  ) async {
    await _pumpConverter(tester);
    final ConverterController controller = Get.find<ConverterController>();

    // A real pair, so the division leaves the long tail the card used to print
    // raw (`864.0962999999999` and the like).
    controller.selectCurrency(controller.currencies.first, isInput: false);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, '1');
    await tester.pump();

    final double kept = controller.toCurrency.convertedValue;
    expect(
      kept.toString().length,
      greaterThan(Constants.converterAmountDecimals + 2),
      reason: 'the controller must still hold the full value',
    );
    expect(find.text(kept.toString()), findsNothing);
    expect(
      find.text(kept.toStringAsFixed(Constants.converterAmountDecimals)),
      findsOneWidget,
    );
  });
}
