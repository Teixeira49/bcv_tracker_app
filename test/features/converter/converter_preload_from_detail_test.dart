import 'package:bcv_tracker_app/features/converter/domain/entities/convertible_currency.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/navigation/navigation_controller.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2026-08-01', currencies: <Currency>[]);

  @override
  Future<List<Currency>> getCurrentDollar() async => <Currency>[];
}

/// The handoff from the rate detail to the full converter (#103).
///
/// #39 left the decision open and #103 took it: arriving from the detail
/// **preloads** the converter with that rate, and carries the amount and the
/// direction across, because the user story is about continuing a calculation
/// rather than starting one.
///
/// The half that matters most here is the **negative** one. Preloading
/// overwrites a pair the user may have chosen deliberately, and the only thing
/// that makes that acceptable is that it happens on an explicit tap and nowhere
/// else. "Entering the converter by the tab does not touch the selection" is the
/// kind of guarantee a later change removes without noticing, so it is pinned.
void main() {
  late ConverterController converter;

  const Currency ves = Currency(
    name: 'Bolivares',
    keyName: 'VES',
    platform: 'Banco Central de Venezuela',
    value: 1.0,
  );

  const Currency usdBcv = Currency(
    name: 'Dolar',
    keyName: 'USD',
    platform: 'Banco Central de Venezuela',
    value: 40.0,
  );

  const Currency euro = Currency(
    name: 'Euro',
    keyName: 'EUR',
    platform: 'Banco Central de Venezuela',
    value: 50.0,
  );

  /// A market the backend knows and has no rate for yet — `Currency.empty`
  /// ships the same `value: 0.00`, so this is not synthetic.
  const Currency noRate = Currency(
    name: 'No data',
    keyName: 'ZRO',
    platform: 'Test',
    value: 0.0,
  );

  setUp(() {
    Get.testMode = true;
    Get.put<IDollarRepository>(_FakeDollarRepository());
    Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
    // #37's increment made the decimals ceiling a setting, so both converters
    // now resolve `SettingsController`. Registered first, as
    // `test-coverage.md` asks: fakes in dependency order.
    Get.put(SettingsController());
    converter = Get.put(ConverterController());
  });

  tearDown(Get.reset);

  /// Leaves the converter holding a pair the user picked on purpose.
  void userChose({required Currency from, required Currency to}) {
    converter.fromCurrency = ConvertibleCurrency(
      currency: from,
      convertedValue: 7.0,
    );
    converter.toCurrency = ConvertibleCurrency(
      currency: to,
      convertedValue: 350.0,
    );
  }

  group('preloadFromDetail — the rate arrives selected', () {
    test('unreversed puts the rate in and the bolívar out', () {
      converter.preloadFromDetail(rate: usdBcv, amount: '2');

      expect(converter.fromCurrency.currency, usdBcv);
      expect(converter.toCurrency.currency.keyName, 'VES');
      expect(converter.fromCurrency.convertedValue, 2.0);
      expect(converter.toCurrency.convertedValue, 80.0);
    });

    test('reversed mirrors the detail sheet: bolívar in, rate out', () {
      converter.preloadFromDetail(rate: usdBcv, amount: '80', reversed: true);

      expect(converter.fromCurrency.currency.keyName, 'VES');
      expect(converter.toCurrency.currency, usdBcv);
      expect(converter.toCurrency.convertedValue, 2.0);
    });

    test('the market is kept, not just the currency code', () {
      // Two markets quote the same code at different rates. Handing over only
      // `keyName` would land the user on a different number than the one they
      // were looking at.
      const Currency usdOther = Currency(
        name: 'Dolar',
        keyName: 'USD',
        platform: 'Yadio.io',
        value: 41.5,
      );

      converter.preloadFromDetail(rate: usdOther, amount: '1');

      expect(converter.fromCurrency.currency.platform, 'Yadio.io');
      expect(converter.toCurrency.convertedValue, 41.5);
    });

    test('the pivot rule still holds: one side is always VES', () {
      converter.preloadFromDetail(rate: euro, amount: '1');

      expect(
        converter.fromCurrency.currency.keyName == 'VES' ||
            converter.toCurrency.currency.keyName == 'VES',
        isTrue,
      );
    });
  });

  group('the amount crosses over as typed', () {
    test('an empty field arrives empty, not as a stale number', () {
      userChose(from: ves, to: euro);

      converter.preloadFromDetail(rate: usdBcv);

      expect(converter.fromCurrency.convertedValue, 0.0);
      expect(converter.toCurrency.convertedValue, 0.0);
    });

    test('a decimal comma is parsed, because `calculator` does it', () {
      // Routed through `calculator` rather than parsed here on purpose: one
      // implementation of "what does this string mean", not two.
      converter.preloadFromDetail(rate: usdBcv, amount: '1,5');

      expect(converter.fromCurrency.convertedValue, 1.5);
      expect(converter.toCurrency.convertedValue, 60.0);
    });

    test('a lone separator is 0, not a crash', () {
      converter.preloadFromDetail(rate: usdBcv, amount: '.');

      expect(converter.toCurrency.convertedValue, 0.0);
    });

    test('a market with no rate does not produce Infinity', () {
      converter.preloadFromDetail(rate: noRate, amount: '10', reversed: true);

      expect(converter.toCurrency.convertedValue, 0.0);
      expect(converter.toCurrency.convertedValue.isFinite, isTrue);
      // And the view is told why, instead of painting a meaningless figure.
      expect(converter.isConversionUnavailable, isTrue);
    });
  });

  group('and only from there — the tab must not preload', () {
    test('changing to the converter tab leaves the selection untouched', () {
      userChose(from: ves, to: euro);
      final NavigationController navigation = Get.put(NavigationController());

      navigation.changeIndex(1);

      expect(converter.fromCurrency.currency, ves);
      expect(converter.toCurrency.currency, euro);
      expect(converter.fromCurrency.convertedValue, 7.0);
      expect(
        converter.toCurrency.convertedValue,
        350.0,
        reason:
            'switching tabs is not arriving from the detail; the pair the user '
            'chose has to survive it',
      );
    });

    test('opening and closing a detail sheet on its own changes nothing', () {
      // The sheet is a modal, so it can be opened and dismissed without ever
      // reaching the action. Only the tap hands anything over.
      userChose(from: ves, to: euro);
      final CurrencyDetailController detail = Get.put(
        CurrencyDetailController(),
      );

      detail.open(usdBcv);
      detail.setAmount('999');
      detail.dismiss();

      expect(converter.fromCurrency.currency, ves);
      expect(converter.toCurrency.currency, euro);
    });
  });

  group('what the detail hands over is what the detail was showing', () {
    test('the amount and the direction come from the detail controller', () {
      // Mirrors what the button does, without pumping the sheet: the button is
      // three calls, and this is the middle one — the contract between the two
      // controllers.
      final CurrencyDetailController detail = Get.put(
        CurrencyDetailController(),
      );
      detail.open(usdBcv);
      detail.setAmount('3');

      converter.preloadFromDetail(
        rate: usdBcv,
        amount: detail.amountInput,
        reversed: detail.isReversed,
      );

      expect(converter.fromCurrency.currency, usdBcv);
      expect(converter.toCurrency.convertedValue, 120.0);
    });

    test('a flipped detail hands over the figure the user was reading', () {
      // `toggleDirection` carries the displayed result across with its currency,
      // so after flipping, the detail reads "120,00 Bs -> 3 USD". Handing that
      // over has to land on 3 again: the round trip is what proves the two
      // converters agree, and it is why the amount travels as the raw string
      // rather than as a number this side re-derives.
      final CurrencyDetailController detail = Get.put(
        CurrencyDetailController(),
      );
      detail.open(usdBcv);
      detail.setAmount('3');
      detail.toggleDirection(usdBcv);

      expect(detail.isReversed, isTrue);
      expect(detail.amountInput, '120.00');

      converter.preloadFromDetail(
        rate: usdBcv,
        amount: detail.amountInput,
        reversed: detail.isReversed,
      );

      expect(converter.fromCurrency.currency.keyName, 'VES');
      expect(converter.toCurrency.currency, usdBcv);
      expect(converter.toCurrency.convertedValue, closeTo(3.0, 1e-9));
    });

    test('the detail is read before it is cleared', () {
      // `dismiss()` wipes the amount, which is why the button loads first and
      // closes second. Reading after the close would hand over an empty string.
      final CurrencyDetailController detail = Get.put(
        CurrencyDetailController(),
      );
      detail.open(usdBcv);
      detail.setAmount('5');

      final String captured = detail.amountInput;
      detail.dismiss();

      expect(detail.amountInput, isEmpty);
      expect(captured, '5');
    });
  });
}
