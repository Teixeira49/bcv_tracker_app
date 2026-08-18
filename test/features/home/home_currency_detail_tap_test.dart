import 'dart:async';

import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/page/currency_detail_sheet.dart';
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

/// Offline rates with `imgUrl: null`, so no card tries to resolve a network
/// image while the test runs.
class _FakeDollarRepository implements IDollarRepository {
  static final DateTime _date = DateTime(2026, 8, 1, 10, 30);

  static final Currency average = Currency(
    name: 'Dólar estadounidense',
    keyName: 'USD',
    platform: Markets.binance,
    value: 152.3068,
    tendency: 1.24,
    updateDate: _date,
  );

  static final Currency official = Currency(
    name: 'Dólar estadounidense',
    keyName: 'USD',
    platform: Markets.bcv,
    value: 150.12,
    updateDate: _date,
  );

  @override
  Future<List<Currency>> getCurrentDollar() async => <Currency>[average];

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: <Currency>[official]);
}

/// Never answers, leaving the repository in the state it holds from launch
/// until the first response arrives: placeholders on screen, `hasXData` false.
class _PendingDollarRepository implements IDollarRepository {
  @override
  Future<List<Currency>> getCurrentDollar() =>
      Completer<List<Currency>>().future;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() =>
      Completer<BcvCurrencies>().future;
}

/// Brings up the Home over the fakes, on the tab given by [marketIndex].
Future<void> _pumpHome(WidgetTester tester, {int marketIndex = 0}) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final CurrencyRepository repo = Get.put(CurrencyRepository());
  Get.put(SettingsController()).favMarketIndex.value = marketIndex;
  Get.put(HomeController());
  Get.put(CurrencyDetailController());

  // The skeleton placeholders carry a `placehold.co` URL; `onReady`'s refresh
  // replaces them with the fixtures above.
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: const Scaffold(body: HomePage()),
    ),
  );

  // Explicit pumps, not pumpAndSettle: the skeleton shimmer never settles.
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Lets the bottom sheet's entry animation finish without waiting on the
/// shimmer that `pumpAndSettle` would never see end.
Future<void> _settleSheet(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets('tapping an average card opens the detail of that rate', (
    tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.text(Markets.binance));
    await _settleSheet(tester);

    expect(find.byType(CurrencyDetailSheet), findsOneWidget);
    // The sheet details the rate the card was showing, not another one.
    expect(
      Get.find<CurrencyDetailController>().currency?.platform,
      Markets.binance,
    );
    expect(find.text(AppMessages.currencyDetailsSection), findsOneWidget);
  });

  testWidgets('tapping a BCV card opens the detail of the official rate', (
    tester,
  ) async {
    await _pumpHome(tester, marketIndex: 1);

    await tester.tap(find.text(AppMessages.eeuuDollar).first);
    await _settleSheet(tester);

    expect(find.byType(CurrencyDetailSheet), findsOneWidget);
    expect(
      Get.find<CurrencyDetailController>().currency?.platform,
      Markets.bcv,
    );
  });

  testWidgets('closing the sheet clears the controller', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(Markets.binance));
    await _settleSheet(tester);
    expect(Get.find<CurrencyDetailController>().hasCurrency, isTrue);

    Get.back<void>();
    await _settleSheet(tester);

    expect(find.byType(CurrencyDetailSheet), findsNothing);
    // `whenComplete` runs on dismissal however the sheet was closed — the
    // button, the drag or the barrier.
    expect(Get.find<CurrencyDetailController>().hasCurrency, isFalse);
  });

  testWidgets('the cards are inert while the tab still holds placeholders', (
    tester,
  ) async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // A refresh that never lands, so `hasAverageData` stays false — the state
    // the app is in from launch until the first response arrives.
    Get.put<IDollarRepository>(_PendingDollarRepository());
    final CurrencyRepository repo = Get.put(CurrencyRepository());
    Get.put(SettingsController());
    Get.put(HomeController());
    Get.put(CurrencyDetailController());
    // Stand-ins for the `emptySkeletonizer` placeholders, minus their
    // `placehold.co` image URL, which no test should try to fetch.
    repo.averageCurrencies.assignAll(<Currency>[_FakeDollarRepository.average]);
    repo.bcvCurrencies.clear();

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('es', 'ES'),
        home: const Scaffold(body: HomePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    // Detailing a placeholder would show a fabricated rate as if it were data,
    // so the card refuses the tap until the tab holds something real.
    // Every ink surface wrapping the rate, not just the card's own: nothing in
    // a placeholder card responds to a tap. (`ListTile` builds its own.)
    final Finder cardInk = find.ancestor(
      of: find.text(Markets.binance),
      matching: find.byType(InkWell),
    );
    expect(cardInk, findsWidgets);
    for (final InkWell ink in tester.widgetList<InkWell>(cardInk)) {
      expect(ink.onTap, isNull);
    }

    await tester.tap(cardInk.last, warnIfMissed: false);
    await _settleSheet(tester);
    expect(find.byType(CurrencyDetailSheet), findsNothing);
  });
}
