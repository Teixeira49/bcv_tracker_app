import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

Currency _rate(String platform, String code, double value) =>
    Currency(name: code, keyName: code, platform: platform, value: value);

void main() {
  group('getAverageValue()', () {
    test('averages every dollar-equivalent quote of the parallel market', () {
      final average = CurrencyHelpers.getAverageValue(
        currencies: [
          _rate(Markets.yadio, 'USD', 840),
          _rate(Markets.binance, 'USDT', 860),
          _rate(Markets.bybit, 'USDC', 880),
          _rate(Markets.exchangeMonitor, Markets.emAverageCode, 820),
        ],
      );

      expect(average, 850.0);
    });

    test('leaves the official BCV rate out of the average', () {
      final average = CurrencyHelpers.getAverageValue(
        currencies: [
          // Far below the market: averaging it in used to drag the figure down.
          _rate(Markets.bcv, 'USD', 737),
          _rate(Markets.yadio, 'USD', 840),
          _rate(Markets.binance, 'USDT', 860),
        ],
      );

      expect(average, 850.0);
    });

    test('returns 0 instead of NaN when nothing matches', () {
      // The skeleton placeholders match no code: the previous 0/0 rendered
      // "Bs.S NaN" on the average card while the first refresh was in flight.
      expect(
        CurrencyHelpers.getAverageValue(
          currencies: [_rate('platform', 'keyName', 1.0)],
        ),
        0.0,
      );
      expect(CurrencyHelpers.getAverageValue(currencies: []), 0.0);
    });
  });

  group('castCurrencyDisplayCode()', () {
    test('maps the Exchange Monitor codes to the dollar', () {
      expect(CurrencyHelpers.castCurrencyDisplayCode(Markets.emOwnCode), 'USD');
      expect(
        CurrencyHelpers.castCurrencyDisplayCode(Markets.emAverageCode),
        'USD',
      );
      expect(
        CurrencyHelpers.completeCurrencyExchange(Markets.emAverageCode),
        'USD/VES',
      );
      // The dollar symbol reaches those rates too, instead of an empty string.
      expect(
        CurrencyHelpers.castCurrencySymbolText(
          currencyCode: Markets.emAverageCode,
        ),
        '\$',
      );
    });

    test('leaves a regular code untouched', () {
      expect(CurrencyHelpers.castCurrencyDisplayCode('USDT'), 'USDT');
      expect(CurrencyHelpers.completeCurrencyExchange('USDT'), 'USDT/VES');
    });
  });
}
