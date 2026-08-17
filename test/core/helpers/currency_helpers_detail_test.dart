import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

Currency _rate({required String platform}) => Currency(
  name: 'Dólar estadounidense',
  keyName: 'USD',
  platform: platform,
  value: 152.30,
);

/// The formatters the detail sheet (#38) added to `CurrencyHelpers`. They are
/// pure functions over optional contract fields, so the cases that matter are
/// the absent ones.
void main() {
  group('isOfficialRate', () {
    test('only the BCV publishes an official rate', () {
      expect(
        CurrencyHelpers.isOfficialRate(_rate(platform: Markets.bcv)),
        isTrue,
      );
      for (final String platform in <String>[
        Markets.binance,
        Markets.bybit,
        Markets.yadio,
        Markets.exchangeMonitor,
      ]) {
        expect(
          CurrencyHelpers.isOfficialRate(_rate(platform: platform)),
          isFalse,
          reason: '$platform quotes the parallel market',
        );
      }
    });

    test('an abbreviation is not the platform the backend reports', () {
      // Guards against matching on a substring or on 'BCV': the contract sends
      // the institution's full name, and a rename upstream must stop the label
      // rather than mislabel a rate.
      expect(CurrencyHelpers.isOfficialRate(_rate(platform: 'BCV')), isFalse);
    });
  });

  group('castTendency', () {
    test('signs a rise and leaves a fall with its own sign', () {
      expect(CurrencyHelpers.castTendency(value: 1.24), '+1.2400%');
      expect(CurrencyHelpers.castTendency(value: -0.53), '-0.5300%');
    });

    test('zero is a real reading and is shown as such', () {
      expect(CurrencyHelpers.castTendency(value: 0), '0.0000%');
    });

    test('a change the source never sent degrades, it does not become 0%', () {
      // `change` is optional in the contract; rendering `0%` would tell the
      // user the rate held when nothing is actually known about it.
      expect(
        CurrencyHelpers.castTendency(),
        CurrencyHelpers.emptyValuePlaceholder,
      );
    });

    test('keeps four decimals, matching the badge on the cards', () {
      expect(CurrencyHelpers.castTendency(value: 0.123456), '+0.1235%');
    });
  });

  group('castOptionalDate', () {
    test('formats an instant with the app default format', () {
      expect(
        CurrencyHelpers.castOptionalDate(date: DateTime(2026, 8, 1, 10, 30)),
        '2026-08-01 10:30',
      );
    });

    test('a missing timestamp degrades to the placeholder', () {
      expect(
        CurrencyHelpers.castOptionalDate(),
        CurrencyHelpers.emptyValuePlaceholder,
      );
    });

    test('the date placeholder is the same one, not a second literal', () {
      expect(
        CurrencyHelpers.emptyDatePlaceholder,
        CurrencyHelpers.emptyValuePlaceholder,
      );
    });
  });

  group('castCurrencyDisplayName', () {
    test('names the BCV currencies the sheet shows, translated', () {
      // The BCV card reads its label from `castCurrencyCountry`, so these three
      // never went through here until the detail sheet (#38) named them — and
      // fell back to the backend's Spanish "Rublo" in the other nine languages.
      const Map<String, String> expected = <String, String>{
        'TRY': 'turkishLira',
        'CNY': 'chineseYuan',
        'RUB': 'russianRuble',
      };
      expected.forEach((String code, String key) {
        final Currency currency = Currency(
          name: 'Rublo',
          keyName: code,
          platform: Markets.bcv,
          value: 9.25,
        );
        // Untranslated, `.tr` returns the key itself: enough to assert that the
        // helper routes to `AppMessages` instead of the backend's own name.
        expect(CurrencyHelpers.castCurrencyDisplayName(currency), key);
      });
    });

    test('an unknown code still falls back to the name the backend sent', () {
      final Currency currency = Currency(
        name: 'Peso chileno',
        keyName: 'CLP',
        platform: Markets.bcv,
        value: 0.16,
      );
      expect(CurrencyHelpers.castCurrencyDisplayName(currency), 'Peso chileno');
    });
  });

  group('castAmount', () {
    test('two decimals, as a bolívar price is quoted', () {
      expect(CurrencyHelpers.castAmount(value: 864.0962999999999), '864.10');
      expect(CurrencyHelpers.castAmount(value: 2.5), '2.50');
      expect(CurrencyHelpers.castAmount(value: 0), '0.00');
    });

    test('keeps a small amount legible instead of erasing it', () {
      // A few bolívares are thousandths of a dollar. `0.00` there is not a
      // rounding, it is the figure gone — and the detail sheet then carries
      // that figure across when the direction is reversed.
      expect(CurrencyHelpers.castAmount(value: 0.0013137), '0.001314');
      expect(CurrencyHelpers.castAmount(value: 0.0000040), '0.000004000');
    });

    test('only expands when the default would have shown nothing', () {
      // 0.005 rounds to 0.01, which is a real figure, so it is left alone.
      expect(CurrencyHelpers.castAmount(value: 0.005), '0.01');
      expect(CurrencyHelpers.castAmount(value: 0.994), '0.99');
    });

    test('a negative amount keeps its sign and its digits', () {
      expect(CurrencyHelpers.castAmount(value: -0.0013137), '-0.001314');
    });

    test('a non-finite value never reaches the screen', () {
      expect(CurrencyHelpers.castAmount(value: double.infinity), '0.00');
      expect(CurrencyHelpers.castAmount(value: double.nan), '0.00');
    });

    test('the base precision stays a parameter, for a future setting', () {
      expect(CurrencyHelpers.castAmount(value: 2.5, decimals: 4), '2.5000');
    });
  });
}
