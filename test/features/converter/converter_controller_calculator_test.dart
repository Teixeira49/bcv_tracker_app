import 'package:bcv_tracker_app/features/converter/domain/entities/convertible_currency.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
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
      BcvCurrencies(date: '2024-01-01', currencies: []);

  @override
  Future<List<Currency>> getCurrentDollar() async => [];
}

void main() {
  late ConverterController controller;

  const vesRate = Currency(
    name: 'Bolivares',
    keyName: 'VES',
    platform: 'Banco Central de Venezuela',
    value: 1.0,
  );

  const usdRate = Currency(
    name: 'Dollar',
    keyName: 'USD',
    platform: 'Test',
    value: 36.5,
  );

  // A market the backend knows about but has no rate for yet. `Currency.empty`
  // ships the same `value: 0.00`, so this is not a synthetic case.
  const zeroRate = Currency(
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
    controller = Get.put(ConverterController());
  });

  tearDown(() => Get.reset());

  void arrangeCurrencies({
    Currency from = vesRate,
    Currency to = usdRate,
    double fromConverted = 1.0,
    double toConverted = 36.5,
  }) {
    controller.fromCurrency = ConvertibleCurrency(
      currency: from,
      convertedValue: fromConverted,
    );
    controller.toCurrency = ConvertibleCurrency(
      currency: to,
      convertedValue: toConverted,
    );
  }

  group('calculator()', () {
    test('empty string sets both converted values to 0.0', () {
      arrangeCurrencies();
      controller.calculator('');
      expect(controller.fromCurrency.convertedValue, 0.0);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('"." is treated as "0" and produces 0.0', () {
      arrangeCurrencies();
      controller.calculator('.');
      expect(controller.fromCurrency.convertedValue, 0.0);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('comma is replaced with dot before parsing', () {
      arrangeCurrencies(); // VES(1.0) → USD(36.5)
      controller.calculator('1,5');
      expect(controller.fromCurrency.convertedValue, 1.5);
      expect(
        controller.toCurrency.convertedValue,
        closeTo(1.5 * 1.0 / 36.5, 0.0001),
      );
    });

    test('non-numeric input does not throw and uses 0.0', () {
      arrangeCurrencies();
      expect(() => controller.calculator('abc'), returnsNormally);
      expect(controller.fromCurrency.convertedValue, 0.0);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('VES→USD: result = amount * fromRate / toRate', () {
      arrangeCurrencies(from: vesRate, to: usdRate); // 1.0 / 36.5
      controller.calculator('100');
      expect(controller.fromCurrency.convertedValue, 100.0);
      expect(
        controller.toCurrency.convertedValue,
        closeTo(100.0 * 1.0 / 36.5, 0.0001),
      );
    });

    test('USD→VES: result = amount * fromRate / toRate', () {
      arrangeCurrencies(from: usdRate, to: vesRate); // 36.5 / 1.0
      controller.calculator('1');
      expect(controller.fromCurrency.convertedValue, 1.0);
      expect(
        controller.toCurrency.convertedValue,
        closeTo(1.0 * 36.5 / 1.0, 0.0001),
      );
    });

    test('input "0" produces 0.0 without throwing', () {
      arrangeCurrencies();
      expect(() => controller.calculator('0'), returnsNormally);
      expect(controller.fromCurrency.convertedValue, 0.0);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('equal rates produce result equal to the input amount', () {
      const sameRate = Currency(
        name: 'Euro',
        keyName: 'EUR',
        platform: 'Test',
        value: 5.0,
      );
      arrangeCurrencies(from: sameRate, to: sameRate);
      controller.calculator('42');
      expect(
        controller.toCurrency.convertedValue,
        closeTo(42.0, 0.0001), // 42 * 5.0 / 5.0
      );
    });

    test('fromCurrency keeps its currency reference after calculation', () {
      arrangeCurrencies(from: vesRate, to: usdRate);
      controller.calculator('50');
      expect(controller.fromCurrency.currency.keyName, 'VES');
    });

    test('toCurrency keeps its currency reference after calculation', () {
      arrangeCurrencies(from: vesRate, to: usdRate);
      controller.calculator('50');
      expect(controller.toCurrency.currency.keyName, 'USD');
    });
  });

  // Dividing doubles by zero does not throw in Dart: it evaluates to
  // `Infinity`, or to `NaN` when the dividend is zero as well. Both used to
  // reach `convertedValue` and get printed verbatim by the view.
  group('calculator() with an unusable rate', () {
    test('a zero destination rate does not produce Infinity', () {
      arrangeCurrencies(from: vesRate, to: zeroRate);
      controller.calculator('100');

      expect(controller.toCurrency.convertedValue.isFinite, isTrue);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('a zero source rate does not produce a meaningless result', () {
      arrangeCurrencies(from: zeroRate, to: usdRate);
      controller.calculator('100');

      expect(controller.toCurrency.convertedValue.isFinite, isTrue);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('both rates at zero do not produce NaN', () {
      arrangeCurrencies(from: zeroRate, to: zeroRate);
      controller.calculator('100');

      expect(controller.toCurrency.convertedValue.isNaN, isFalse);
      expect(controller.toCurrency.convertedValue, 0.0);
    });

    test('the typed amount is still echoed on the input side', () {
      // The user's own number must not be swallowed by the guard: only the
      // conversion is unavailable, not the input.
      arrangeCurrencies(from: vesRate, to: zeroRate);
      controller.calculator('100');

      expect(controller.fromCurrency.convertedValue, 100.0);
    });

    test('an unusable rate raises isConversionUnavailable', () {
      arrangeCurrencies(from: vesRate, to: zeroRate);
      expect(controller.isConversionUnavailable, isTrue);

      arrangeCurrencies(from: zeroRate, to: usdRate);
      expect(controller.isConversionUnavailable, isTrue);
    });

    test('a normal pair leaves isConversionUnavailable down', () {
      arrangeCurrencies(from: vesRate, to: usdRate);
      controller.calculator('100');

      expect(controller.isConversionUnavailable, isFalse);
      expect(controller.toCurrency.convertedValue.isFinite, isTrue);
    });

    test('swapping into a zero rate does not produce Infinity', () {
      // swapCurrencies() re-invokes calculator() with the converted value, so
      // it walks the same division.
      arrangeCurrencies(from: zeroRate, to: usdRate);
      controller.swapCurrencies();

      expect(controller.toCurrency.convertedValue.isFinite, isTrue);
      expect(controller.toCurrency.currency.keyName, 'ZRO');
    });

    test('selecting an output against a zero source does not divide by it', () {
      // The reverse calculation of selectCurrency() divides by the source rate.
      // Picking VES as output keeps the zero-rate currency as the source, so
      // the pivot rule does not replace it and the division is reached.
      arrangeCurrencies(from: zeroRate, to: usdRate);
      controller.selectCurrency(vesRate, isInput: false);

      expect(controller.fromCurrency.convertedValue.isFinite, isTrue);
      expect(controller.fromCurrency.convertedValue, 0.0);
    });
  });
}
