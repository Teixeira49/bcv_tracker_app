import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/page/currency_detail_sheet.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/widgets/currency_detail_section.dart';
import 'package:bcv_tracker_app/navigation/navigation_controller.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The button that hands the detailed rate to the full converter (#103).
///
/// It lives in the heading row of the converter section, opposite the title:
/// a control *of* that section rather than an action on the rate, which is why
/// `CurrencyDetailActionsSlot` stays reserved for #7.
///
/// `converter_preload_from_detail_test.dart` covers what the converter does with
/// the handoff. This covers the **three steps the button performs and their
/// order**, which is the part that is easy to get wrong and impossible to see
/// afterwards: load, close, switch tab. Closing runs
/// `CurrencyDetailController.dismiss`, which wipes the amount, so reading it
/// after the close hands over an empty string — a bug that would look like "the
/// amount just does not carry over sometimes".
Currency _rate(double value) => Currency(
  name: 'Dólar estadounidense',
  keyName: 'USD',
  platform: Markets.binance,
  value: value,
);

class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<List<Currency>> getCurrentDollar() async => <Currency>[];

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: null, currencies: const <Currency>[]);
}

/// Registers everything the action resolves, in dependency order, and pumps the
/// sheet the way `showCurrencyDetailSheet` does — as a **route**, so the tap can
/// actually pop it.
Future<void> _pumpSheetAsRoute(WidgetTester tester, Currency rate) async {
  // A tall surface so the whole sheet fits and nothing has to be scrolled into
  // view. Dragging the sheet's own scroll view programmatically trips
  // `Scrollable`'s `_hold == null` assertion — its drag and its scroll are one
  // gesture chain by design (see `base_bottom_sheet.dart`), and these tests are
  // about the button, not about the gesture.
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
  Get.put(ConverterController());
  Get.put(NavigationController());
  Get.put(CurrencyDetailController()).open(rate);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => Get.to<void>(
              () => Scaffold(
                body: SizedBox(
                  height: 1800,
                  child: CurrencyDetailSheet(currency: rate),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Taps the action.
Future<void> _tapOpenInConverter(WidgetTester tester) async {
  await tester.tap(find.text(AppMessages.openInConverterAction));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  testWidgets('the action is in the sheet, labelled from AppMessages', (
    WidgetTester tester,
  ) async {
    await _pumpSheetAsRoute(tester, _rate(152.30));

    expect(find.text(AppMessages.openInConverterAction), findsOneWidget);

    // In the heading row of the converter section, opposite its title — not in
    // a section of its own. `CurrencyDetailActionsSlot` stays empty for #7.
    final Finder heading = find.ancestor(
      of: find.text(AppMessages.quickConverterSection),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(
        of: heading.first,
        matching: find.text(AppMessages.openInConverterAction),
      ),
      findsOneWidget,
    );
    expect(find.byType(CurrencyDetailSection), findsNWidgets(2));
  });

  testWidgets('tapping it loads the rate, closes the sheet and switches tab', (
    WidgetTester tester,
  ) async {
    final Currency rate = _rate(40.0);
    await _pumpSheetAsRoute(tester, rate);

    final ConverterController converter = Get.find<ConverterController>();
    final NavigationController navigation = Get.find<NavigationController>();
    expect(navigation.selectedIndex.value, 0);

    await _tapOpenInConverter(tester);

    // 1. The rate is selected in the full converter...
    expect(converter.fromCurrency.currency, rate);
    expect(converter.toCurrency.currency.keyName, 'VES');
    // 2. ...the sheet is gone...
    expect(find.byType(CurrencyDetailSheet), findsNothing);
    // 3. ...and the converter tab is the one showing.
    expect(navigation.selectedIndex.value, 1);
  });

  testWidgets('the amount typed in the sheet survives the close', (
    WidgetTester tester,
  ) async {
    // The whole reason the button loads before it closes. If the order were
    // reversed this would arrive as 0 — and only for a user who had typed
    // something, which is every user the button is for.
    final Currency rate = _rate(40.0);
    await _pumpSheetAsRoute(tester, rate);

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.pump();

    await _tapOpenInConverter(tester);

    final ConverterController converter = Get.find<ConverterController>();
    expect(converter.fromCurrency.convertedValue, 3.0);
    expect(converter.toCurrency.convertedValue, 120.0);
    // That `dismiss()` then clears the sheet's own state is not asserted here:
    // this harness pushes the sheet with `Get.to`, and the clearing is wired by
    // `showCurrencyDetailSheet`, the real entry point. `currency_detail_
    // controller_test.dart` covers it, and the controller test covers the
    // read-before-clear ordering directly.
  });

  testWidgets('a flipped sheet hands the direction over too', (
    WidgetTester tester,
  ) async {
    final Currency rate = _rate(40.0);
    await _pumpSheetAsRoute(tester, rate);

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.pump();
    await tester.tap(find.byTooltip(AppMessages.invertConversionAction));
    await tester.pumpAndSettle();

    await _tapOpenInConverter(tester);

    final ConverterController converter = Get.find<ConverterController>();
    // Reversed: bolívares in, the rate out — and the round trip lands back on
    // the 3 the user started from, which is what "continue where I was" means.
    expect(converter.fromCurrency.currency.keyName, 'VES');
    expect(converter.toCurrency.currency, rate);
    expect(converter.toCurrency.convertedValue, closeTo(3.0, 1e-9));
  });
}
