import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/page/currency_detail_sheet.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/widgets/currency_detail_section.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/performance_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Renders the sheet on its own, the way `Get.bottomSheet` does: bounded
/// height, real translations. No repository and no controller are involved —
/// the sheet is fed the rate the card already had.
Future<void> _pumpSheet(WidgetTester tester, Currency currency) async {
  // The converter section (#39) reads its amount and direction from the
  // controller, so the sheet now needs it registered — as the app does in
  // `initial_bindings.dart`.
  Get.testMode = true;
  // #37's increment made the decimals ceiling a setting, so both converters
  // now resolve `SettingsController`. Registered first, as
  // `test-coverage.md` asks: fakes in dependency order.
  Get.put(SettingsController());
  Get.put(CurrencyDetailController());

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: Scaffold(
        body: SizedBox(
          height: 800,
          child: CurrencyDetailSheet(currency: currency),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// A rate with everything the contract can carry.
Currency _fullRate() => Currency(
  name: 'Dólar estadounidense',
  keyName: 'USD',
  platform: Markets.binance,
  value: 152.3068,
  tendency: 1.24,
  createDate: DateTime(2026, 3, 12, 8),
  updateDate: DateTime(2026, 8, 1, 10, 30),
);

/// What `bcv/with-memory` actually sends: no `change`, no `createDate`.
Currency _officialRate() => Currency(
  name: 'Euro',
  keyName: 'EUR',
  platform: Markets.bcv,
  value: 163.45,
  updateDate: DateTime(2026, 8, 1, 10, 30),
);

void main() {
  tearDown(Get.reset);

  testWidgets('the header states the rate the card handed over', (
    tester,
  ) async {
    final Currency currency = _fullRate();
    await _pumpSheet(tester, currency);

    expect(
      find.text(CurrencyHelpers.castCurrencyDisplayName(currency)),
      findsOneWidget,
    );
    expect(find.text(Markets.binance), findsWidgets);
    expect(
      find.text(CurrencyHelpers.castCurrency(value: currency.value)),
      findsOneWidget,
    );
    expect(find.text('USD/VES'), findsWidgets);
  });

  testWidgets('the detail section lists the fields the card cannot show', (
    tester,
  ) async {
    await _pumpSheet(tester, _fullRate());

    // Scroll the sheet's single scroll view: at the opening extent the last
    // rows sit below the fold, which is exactly the behaviour under test.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();

    expect(find.text(AppMessages.currencyDetailsSection), findsOneWidget);
    expect(find.text(AppMessages.marketLabel), findsOneWidget);
    expect(find.text(AppMessages.currencyPairLabel), findsOneWidget);
    expect(find.text(AppMessages.currencyCodeLabel), findsOneWidget);
    expect(find.text(AppMessages.rateTypeLabel), findsOneWidget);
    expect(find.text(AppMessages.variationLabel), findsOneWidget);
    expect(find.text(AppMessages.lastUpdate), findsOneWidget);
    expect(find.text(AppMessages.registeredSince), findsOneWidget);
    // A parallel market, and the label says so without naming a currency.
    expect(find.text(AppMessages.parallelRate), findsOneWidget);
    expect(find.text('+1.2400%'), findsOneWidget);
  });

  testWidgets(
    'an official rate with no change degrades instead of showing 0%',
    (tester) async {
      await _pumpSheet(tester, _officialRate());

      // No variation badge in the header: the source reported no change, and a
      // 0% badge would read as "the rate held".
      expect(find.byType(PerformanceIndicatorWidget), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();

      expect(find.text(AppMessages.officialRate), findsOneWidget);
      expect(find.text(CurrencyHelpers.emptyValuePlaceholder), findsOneWidget);
      // `createDate` is absent, so the row is dropped rather than dashed out.
      expect(find.text(AppMessages.registeredSince), findsNothing);
    },
  );

  testWidgets('an official rate leads with the flag, not the platform seal', (
    tester,
  ) async {
    // The BCV sends the same seal as `platform_img` for its dollar, its euro
    // and its rouble, so the logo identifies nothing here — the flag does, and
    // it is what the BCV card already shows.
    await _pumpSheet(
      tester,
      Currency(
        name: 'Rublo',
        keyName: 'RUB',
        platform: Markets.bcv,
        value: 9.25,
        imgUrl: 'https://example.invalid/bcv.png',
      ),
    );

    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.byType(Image), findsNothing);
    // And the name is translated rather than the backend's Spanish "Rublo".
    expect(find.text('Rublo'), findsNothing);
    expect(find.text(AppMessages.russianRuble), findsOneWidget);
  });

  testWidgets('a parallel rate leads with the platform logo', (tester) async {
    // On the average tab every row quotes the same dollar, so the market is
    // what tells them apart — the same reading as the card that opened it.
    await _pumpSheet(
      tester,
      Currency(
        name: 'Dólar estadounidense',
        keyName: 'USD',
        platform: Markets.binance,
        value: 152.30,
        imgUrl: 'https://example.invalid/binance.png',
      ),
    );

    final CircleAvatar avatar = tester.widget<CircleAvatar>(
      find.byType(CircleAvatar),
    );
    expect(avatar.backgroundImage, isA<NetworkImage>());
    expect(find.byType(SvgPicture), findsNothing);

    // The test binding answers 400 to every request by design, so the logo
    // never decodes. Consuming the failure keeps the test about which provider
    // the avatar picked, which is all this asserts.
    await tester.pump(const Duration(milliseconds: 10));
    tester.takeException();
  });

  testWidgets('the three reserved sections are wired in and render nothing', (
    tester,
  ) async {
    await _pumpSheet(tester, _fullRate());

    // Their presence is the contract #5, #7 and #39 build against: the slots
    // hold their final position in the sliver list and already carry the rate.
    // `skipOffstage: false` because a sliver with no geometry is off-stage by
    // definition — which is precisely what "renders nothing" means for the two
    // still empty.
    for (final Type slot in <Type>[
      CurrencyDetailChartSlot,
      CurrencyDetailActionsSlot,
      CurrencyDetailConverterSlot,
    ]) {
      expect(find.byType(slot, skipOffstage: false), findsOneWidget);
    }

    // Two sections on screen: the detail table and the converter #39 filled.
    // The chart (#5) and the actions (#7) still paint nothing, so the sheet
    // stays complete without them — which is what #38 asked for. #103 added no
    // third section: its one action rides in the converter's heading row.
    expect(
      find.byType(CurrencyDetailSection, skipOffstage: false),
      findsNWidgets(2),
    );
    // And it is there, opposite the converter's title. `skipOffstage: false`
    // because at this height that heading sits past the fold.
    expect(
      find.text(AppMessages.openInConverterAction, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text(AppMessages.currencyDetailsSection), findsOneWidget);
    // `skipOffstage: false`: the converter is the last section, so in this
    // harness it sits just below the fold. Being built is what matters here —
    // that it is reachable is the sheet's scrolling, tested elsewhere.
    expect(
      find.text(AppMessages.quickConverterSection, skipOffstage: false),
      findsOneWidget,
    );
  });
}
