import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/app_state_view.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/base_bottom_sheet.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/base_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Enough rows that the list has to scroll inside the sheet — the situation #40
/// is about. The parallel markets are restricted to `Markets.averageTab`
/// because `CurrencyNormalizer` drops everything else; the length comes from the
/// BCV side, which is not filtered. `imgUrl` is null throughout so no tile
/// resolves a network image.
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

  static final List<Currency> official = <Currency>[
    for (final (String code, double value) in <(String, double)>[
      ('USD', 150.12),
      ('EUR', 163.45),
      ('TRY', 4.31),
      ('CNY', 20.85),
      ('RUB', 9.25),
    ])
      Currency(
        name: 'Moneda',
        keyName: code,
        platform: Markets.bcv,
        value: value,
      ),
  ];

  @override
  Future<List<Currency>> getCurrentDollar() async => average;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: official);
}

Future<void> _pumpConverter(WidgetTester tester) async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final CurrencyRepository repo = Get.put(CurrencyRepository());
  // #37's increment made the decimals ceiling a setting, so both converters
  // now resolve `SettingsController`. Registered first, as
  // `test-coverage.md` asks: fakes in dependency order.
  Get.put(SettingsController());
  Get.put(ConverterController());

  // The skeleton placeholders carry a `placehold.co` URL; `onReady`'s refresh
  // replaces them with the fixtures above.
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

/// Lets the sheet's entry animation finish. Not `pumpAndSettle`: the skeleton
/// shimmer never settles.
Future<void> _settleSheet(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Taps the selector of the "from" (`isInput`) or "to" card.
Future<void> _openSelector(WidgetTester tester, {required bool isInput}) async {
  await tester.tap(find.byIcon(Icons.keyboard_arrow_down).at(isInput ? 0 : 1));
  await _settleSheet(tester);
}

/// The sheet's own scroll view.
///
/// `.first` because the search field brings a `Scrollable` of its own (every
/// `EditableText` has one) and it is nested inside this one; tree order puts
/// the outer one first.
Finder get _sheetScrollable => find
    .descendant(
      of: find.byType(BaseBottomSheet),
      matching: find.byType(Scrollable),
    )
    .first;

/// Taps a row that the sheet already shows at its opening extent.
///
/// Reaching a row below the fold is covered by its own test; doing it here too
/// would drag the sheet, and a drag that first expands the panel and then
/// scrolls is not what these two are about.
Future<void> _tapRow(WidgetTester tester, String label) async {
  final Finder row = find.text(label);
  expect(row, findsOneWidget, reason: '"$label" should be visible on opening');
  await tester.tap(row);
  await _settleSheet(tester);
}

void main() {
  tearDown(Get.reset);

  testWidgets('the selector opens as a bottom sheet, not as a dialog', (
    tester,
  ) async {
    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    expect(find.byType(BaseBottomSheet), findsOneWidget);
    // The centred dialog it replaced. `BaseModal` is still in the codebase —
    // #37 took its last caller away when settings became a screen, and kept the
    // widget for the next short, interrupting decision — so this asserts the
    // selector stopped using it, not that the widget is gone.
    expect(find.byType(BaseModal), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('it rises from the bottom edge and takes more than half', (
    tester,
  ) async {
    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final Rect sheet = tester.getRect(find.byType(BaseBottomSheet));

    // Anchored to the bottom edge...
    expect(sheet.bottom, moreOrLessEquals(screen.height, epsilon: 1));
    // ...and taller than the half screen the `AlertDialog` was capped at, which
    // is the point of #40.
    expect(sheet.height, greaterThan(screen.height * 0.5));
  });

  testWidgets('the categories of the dialog are preserved', (tester) async {
    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    expect(find.text(AppMessages.selectCurrency), findsWidgets);
    expect(find.text(AppMessages.originalCurrency), findsOneWidget);
    expect(find.text(AppMessages.mainMarkets), findsOneWidget);
    // The base currency has its own heading, above the markets.
    expect(find.text('VES Bolivares'), findsOneWidget);
  });

  testWidgets('the whole list is reachable by scrolling inside the sheet', (
    tester,
  ) async {
    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    // Last row of the merged list, well below the fold when the sheet opens.
    final Finder last = find.text('RUB ${AppMessages.russianRuble}');
    expect(last, findsNothing);

    await tester.scrollUntilVisible(last, 100, scrollable: _sheetScrollable);

    expect(last, findsOneWidget);
    // Scrolling the content did not dismiss the sheet — the drag and the scroll
    // are one gesture chain, which is why the route has `enableDrag: false`.
    expect(find.byType(BaseBottomSheet), findsOneWidget);
  });

  testWidgets('choosing a market changes the origin and closes the sheet', (
    tester,
  ) async {
    await _pumpConverter(tester);
    final ConverterController controller = Get.find<ConverterController>();
    await _openSelector(tester, isInput: true);

    await _tapRow(tester, Markets.exchangeMonitor);

    expect(controller.fromCurrency.currency.platform, Markets.exchangeMonitor);
    expect(find.byType(BaseBottomSheet), findsNothing);
  });

  testWidgets(
    'choosing a market changes the destination and closes the sheet',
    (tester) async {
      await _pumpConverter(tester);
      final ConverterController controller = Get.find<ConverterController>();
      await _openSelector(tester, isInput: false);

      await _tapRow(tester, Markets.exchangeMonitor);

      expect(controller.toCurrency.currency.platform, Markets.exchangeMonitor);
      expect(find.byType(BaseBottomSheet), findsNothing);
    },
  );

  group('search (#41)', () {
    /// The search box — scoped to the sheet, because the converter behind it
    /// has two amount fields and a `TextFormField` builds a `TextField`.
    final Finder searchField = find.descendant(
      of: find.byType(BaseBottomSheet),
      matching: find.byType(TextField),
    );

    /// Types into the search box and lets the filter run.
    Future<void> search(WidgetTester tester, String query) async {
      await tester.enterText(searchField, query);
      await tester.pump();
    }

    testWidgets('the field is in the header, empty and not focused', (
      tester,
    ) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);

      expect(find.text(AppMessages.searchCurrencyHint), findsOneWidget);
      // Deliberately not auto-focused: the keyboard would cover the list the
      // sheet exists to show, and most openings are "pick the one I can see".
      expect(
        tester.testTextInput.isVisible,
        isFalse,
        reason: 'opening the selector must not raise the keyboard',
      );
    });

    testWidgets('typing filters the list in place', (tester) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);
      expect(find.text(Markets.yadio), findsOneWidget);

      await search(tester, 'binance');

      expect(find.text(Markets.binance), findsOneWidget);
      expect(find.text(Markets.yadio), findsNothing);
      expect(find.text(AppMessages.originalCurrency), findsNothing);
    });

    testWidgets('it ignores case and accents', (tester) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);

      // The rate is named "Dólar estadounidense"; nobody types the accent to
      // search, and on a phone keyboard it is extra work.
      await search(tester, 'DOLAR');

      expect(find.textContaining(Markets.exchangeMonitor), findsWidgets);
      expect(find.byType(AppStateView), findsNothing);
    });

    testWidgets('and it does so against the name the app really publishes', (
      tester,
    ) async {
      // The test above folds the accent of a name written by the fixture. This
      // one folds the accent of `AppMessages.eeuuDollar` — the copy a user
      // reads — which is what #104 made possible: before the Spanish map
      // spelled «Dólar» with its accent there was nothing accented on screen to
      // search, and #41's criterion could not be shown, only argued.
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);

      final String published = AppMessages.eeuuDollar;
      expect(
        published,
        contains('ó'),
        reason:
            'the sheet renders es_ES here, so the dollar must arrive accented '
            'for this test to prove anything',
      );
      final Finder row = find.text('USD $published');
      expect(row, findsWidgets);

      await search(tester, 'dolar');

      expect(
        row,
        findsWidgets,
        reason: 'typing "dolar" must keep "$published" on screen',
      );
      expect(find.byType(AppStateView), findsNothing);
    });

    testWidgets('it matches the market as well as the currency', (
      tester,
    ) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);

      await search(tester, 'bybit');

      expect(find.text(Markets.bybit), findsOneWidget);
      expect(find.text(Markets.binance), findsNothing);
    });

    testWidgets('no match shows a state, not a blank panel', (tester) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);

      await search(tester, 'zzzz');

      expect(find.byType(AppStateView), findsOneWidget);
      expect(find.text(AppMessages.noSearchResultsTitle), findsOneWidget);
      // The query is quoted back through GetX's parameters, not concatenated.
      expect(find.textContaining('zzzz'), findsWidgets);
      // No retry: the data is fine, the filter is what excluded everything.
      expect(find.text(AppMessages.retryAction), findsNothing);
    });

    testWidgets('the clear button brings the whole list back', (tester) async {
      await _pumpConverter(tester);
      await _openSelector(tester, isInput: true);
      await search(tester, 'binance');
      expect(find.text(Markets.yadio), findsNothing);

      await tester.tap(find.byTooltip(AppMessages.clearSearchAction));
      await tester.pump();

      expect(find.text(Markets.yadio), findsOneWidget);
      expect(find.text(AppMessages.originalCurrency), findsOneWidget);
    });

    testWidgets('a filtered row can still be chosen', (tester) async {
      await _pumpConverter(tester);
      final ConverterController controller = Get.find<ConverterController>();
      await _openSelector(tester, isInput: true);

      // The point of the feature: reach a row that was below the fold without
      // scrolling to it.
      await search(tester, 'bybit');
      await _tapRow(tester, Markets.bybit);

      expect(controller.fromCurrency.currency.platform, Markets.bybit);
      expect(find.byType(BaseBottomSheet), findsNothing);
    });
  });

  testWidgets('it holds together with the system text enlarged', (
    tester,
  ) async {
    // An acceptance criterion of #40, and the reason the sheet fixes no
    // heights: the rows have to wrap and the list has to grow, not clip. A
    // `RenderFlex` overflow surfaces here as a thrown exception.
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    expect(find.byType(BaseBottomSheet), findsOneWidget);
    expect(find.text(AppMessages.mainMarkets), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
      reason: 'no row may overflow at 1.6x text',
    );
  });

  testWidgets('re-choosing the current currency leaves the sheet open', (
    tester,
  ) async {
    await _pumpConverter(tester);
    await _openSelector(tester, isInput: true);

    // The origin starts on the pivot. `selectCurrency` returns null when nothing
    // changes, and closing on that would look like the tap did something.
    await tester.tap(find.text('VES Bolivares'));
    await _settleSheet(tester);

    expect(find.byType(BaseBottomSheet), findsOneWidget);
  });
}
