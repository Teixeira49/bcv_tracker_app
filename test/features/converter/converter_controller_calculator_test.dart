import 'package:bcv_tracker_app/features/converter/domain/entities/convertible_currency.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/entities/market.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2024-01-01', currencies: []);

  @override
  Future<List<Currency>> getCurrentDollar(MarketSelection selection) async =>
      [];
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

  setUp(() {
    Get.testMode = true;
    Get.put<IDollarRepository>(_FakeDollarRepository());
    Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
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
}
