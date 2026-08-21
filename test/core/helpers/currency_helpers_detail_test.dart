import 'package:bcv_tracker_app/core/constants/constants.dart';
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
      // Dos decimales desde #63, no cuatro: `+1.2400%` era más precisión de la
      // que un cambio diario carga, y cuatro caracteres que la vista salta
      // para llegar a lo que importa.
      expect(CurrencyHelpers.castTendency(value: 1.24), '+1.24%');
      expect(CurrencyHelpers.castTendency(value: -0.53), '-0.53%');
    });

    test('zero is a real reading and is shown as such', () {
      expect(CurrencyHelpers.castTendency(value: 0), '0.00%');
    });

    test('a move too small for two decimals still shows', () {
      // El techo de cuatro existe para esto: `0,00 %` afirmaría que la tasa se
      // mantuvo, y no se mantuvo.
      expect(CurrencyHelpers.castTendency(value: 0.0012), '+0.0012%');
    });

    test('a change the source never sent degrades, it does not become 0%', () {
      // `change` is optional in the contract; rendering `0%` would tell the
      // user the rate held when nothing is actually known about it.
      expect(
        CurrencyHelpers.castTendency(),
        CurrencyHelpers.emptyValuePlaceholder,
      );
    });

    test('rounds at four, which is where the badge stops too', () {
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
      // Was `0.000004000` before #37's decimals setting: the rescue still
      // expands to four significant digits, and the padding zeros are then
      // dropped by the same rule that keeps `152.3068` from becoming
      // `152.3068000000`. The parsed value is identical, which is what the
      // detail sheet's carry-across depends on.
      expect(CurrencyHelpers.castAmount(value: 0.0000040), '0.000004');
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
  });

  // #37's increment: the user picks a ceiling between 2 and 10, and the figure
  // shows as many decimals as it genuinely has between the floor and it.
  group('castAmount with a raised ceiling', () {
    test('shows the decimals the figure actually has, up to the ceiling', () {
      expect(
        CurrencyHelpers.castAmount(value: 152.3068, maxDecimals: 6),
        '152.3068',
      );
      expect(
        CurrencyHelpers.castAmount(value: 864.0962999999999, maxDecimals: 6),
        '864.0963',
      );
    });

    test('rounds at the ceiling', () {
      expect(
        CurrencyHelpers.castAmount(value: 864.0962999999999, maxDecimals: 4),
        '864.0963',
      );
      expect(
        CurrencyHelpers.castAmount(value: 864.0962999999999, maxDecimals: 2),
        '864.10',
      );
    });

    test('never drops below the two-decimal floor', () {
      // The whole point of the floor: a price with no decimals still has two.
      expect(CurrencyHelpers.castAmount(value: 100, maxDecimals: 10), '100.00');
      expect(CurrencyHelpers.castAmount(value: 2.5, maxDecimals: 10), '2.50');
      expect(CurrencyHelpers.castAmount(value: 0, maxDecimals: 10), '0.00');
    });

    test('does not pad a figure that has no such precision', () {
      // `152.3068000000` is ten decimals of nothing. Raising the setting must
      // not add noise to a figure that does not carry it.
      expect(
        CurrencyHelpers.castAmount(value: 152.3068, maxDecimals: 10),
        '152.3068',
      );
    });

    test('raising the ceiling never shows fewer digits than lowering it', () {
      // The trap the expansion is measured against the floor to avoid: with
      // the rescue clamped to the ceiling, asking for five decimals on a tiny
      // figure would have shown `0.00131` where two decimals showed
      // `0.001314` — a setting called "more decimals" showing fewer.
      final String atFloor = CurrencyHelpers.castAmount(value: 0.0013137);
      expect(atFloor, '0.001314');
      for (int ceiling = 2; ceiling <= 10; ceiling++) {
        final String raised = CurrencyHelpers.castAmount(
          value: 0.0013137,
          maxDecimals: ceiling,
        );
        expect(
          _decimalsOf(raised),
          greaterThanOrEqualTo(_decimalsOf(atFloor)),
          reason: 'ceiling $ceiling showed fewer decimals than the floor did.',
        );
      }
      // ...and a ceiling above the rescue is honoured on its own terms.
      expect(
        CurrencyHelpers.castAmount(value: 0.0013137, maxDecimals: 8),
        '0.0013137',
      );
    });

    test('a ceiling outside the offered range is clamped, not obeyed', () {
      // The setter clamps too, but a value written by a future build — or by a
      // hand-edited preference — must not reach `toStringAsFixed`, which
      // throws outside 0..20.
      expect(CurrencyHelpers.castAmount(value: 2.5, maxDecimals: 0), '2.50');
      expect(
        CurrencyHelpers.castAmount(value: 864.0962999999999, maxDecimals: 99),
        CurrencyHelpers.castAmount(
          value: 864.0962999999999,
          maxDecimals: Constants.converterMaxDecimals,
        ),
      );
    });
  });
}

/// Decimals in an already-formatted amount.
int _decimalsOf(String amount) {
  final int dot = amount.indexOf('.');
  return dot < 0 ? 0 : amount.length - dot - 1;
}
