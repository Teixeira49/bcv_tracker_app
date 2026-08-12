import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The converter embedded in the currency detail (#39).
///
/// Its headline criterion is that the result matches the full converter
/// *exactly*, so the last group does not assert a formula — it runs the same
/// amounts through both controllers and compares.
Currency _rate(double value) => Currency(
  name: 'Dólar estadounidense',
  keyName: 'USD',
  platform: Markets.binance,
  value: value,
);

class _FakeDollarRepository implements IDollarRepository {
  _FakeDollarRepository(this.rates);

  final List<Currency> rates;

  @override
  Future<List<Currency>> getCurrentDollar() async => rates;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: null, currencies: const <Currency>[]);
}

void main() {
  late CurrencyDetailController controller;

  setUp(() {
    Get.testMode = true;
    controller = Get.put(CurrencyDetailController());
  });

  tearDown(Get.reset);

  group('direction', () {
    test('starts on "this rate into bolívares"', () {
      final Currency rate = _rate(152.30);
      controller.open(rate);

      expect(controller.isReversed, isFalse);
      expect(controller.fromCurrencyFor(rate), same(rate));
      expect(controller.toCurrencyFor(rate).keyName, 'VES');
    });

    test('reverses, keeping the amount that was typed', () {
      final Currency rate = _rate(152.30);
      controller.open(rate);
      controller.setAmount('10');

      controller.toggleDirection();

      expect(controller.isReversed, isTrue);
      expect(controller.fromCurrencyFor(rate).keyName, 'VES');
      expect(controller.toCurrencyFor(rate), same(rate));
      // The user asked "and the other way round?" about the same quantity.
      expect(controller.amountInput, '10');
    });

    test('the two directions are inverses of each other', () {
      final Currency rate = _rate(152.30);
      controller.open(rate);
      controller.setAmount('1');

      final double forward = controller.convertedValueFor(rate);
      controller.toggleDirection();
      final double back = controller.convertedValueFor(rate);

      expect(forward, closeTo(152.30, 1e-9));
      expect(back, closeTo(1 / 152.30, 1e-9));
    });
  });

  group('amount', () {
    test('an empty field converts to zero rather than throwing', () {
      final Currency rate = _rate(152.30);
      controller.open(rate);

      expect(controller.convertedValueFor(rate), 0.0);
    });

    test('accepts the comma as a decimal mark', () {
      // `AmountInputFormatter` lets both marks through, so the parser has to
      // read both — they are the decimal mark in different languages the app
      // ships.
      final Currency rate = _rate(2.0);
      controller.open(rate);

      controller.setAmount('1,5');
      expect(controller.convertedValueFor(rate), closeTo(3.0, 1e-9));
    });

    test('a rate of zero yields no conversion instead of Infinity', () {
      // #15: dividing doubles by zero does not throw in Dart, it yields
      // `Infinity`, and `toString()` would print it verbatim on screen.
      final Currency broken = _rate(0.0);
      controller.open(broken);
      controller.setAmount('10');
      controller.toggleDirection();

      expect(controller.canConvertFor(broken), isFalse);
      expect(controller.convertedValueFor(broken), 0.0);
      expect(controller.convertedValueFor(broken).isFinite, isTrue);
    });
  });

  group('lifecycle', () {
    test('dismiss clears the amount and the direction with the rate', () {
      final Currency rate = _rate(152.30);
      controller.open(rate);
      controller.setAmount('99');
      controller.toggleDirection();

      controller.dismiss();

      // Nothing stale may flash on the next open — not the rate, not what was
      // typed against it.
      expect(controller.hasCurrency, isFalse);
      expect(controller.amountInput, '');
      expect(controller.isReversed, isFalse);
    });
  });

  group('agrees with the full converter', () {
    /// Runs [amount] through `ConverterController` with VES as the origin and
    /// [rate] as the destination, and returns what it produced.
    Future<double> throughFullConverter(Currency rate, String amount) async {
      Get.put<IDollarRepository>(_FakeDollarRepository(<Currency>[rate]));
      Get.put(CurrencyRepository());
      final ConverterController full = Get.put(ConverterController());

      // `_initializeSelection` leaves both sides on the pivot; pick the rate as
      // the destination so the pair is VES → rate.
      full.selectCurrency(rate, isInput: false);
      full.fromCurrency = full.fromCurrency.copyWith(
        currency: Currency.pivotCurrency,
      );
      full.calculator(amount);
      return full.toCurrency.convertedValue;
    }

    test(
      'for the same pair and amount, both produce the same number',
      () async {
        // The criterion of #39, checked rather than promised: the embedded
        // converter and the full one run the same `CurrencyConversion`, so a
        // divergence here means someone copied the formula again.
        for (final (double value, String amount) in <(double, String)>[
          (152.3068, '1'),
          (152.3068, '250,75'),
          (0.0001, '1000'),
          (987654.321, '3.5'),
        ]) {
          final Currency rate = _rate(value);

          controller
            ..dismiss()
            ..open(rate)
            ..setAmount(amount)
            ..toggleDirection(); // VES → rate, the same pair as below
          final double embedded = controller.convertedValueFor(rate);

          final double full = await throughFullConverter(rate, amount);
          Get.delete<ConverterController>();
          Get.delete<CurrencyRepository>();
          Get.delete<IDollarRepository>();

          expect(
            embedded,
            full,
            reason: 'rate $value, amount "$amount" diverged between the two',
          );
        }
      },
    );
  });
}
