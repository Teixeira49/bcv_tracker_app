import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/shared/data/mapper/currency_normalizer.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/entities/market.dart';
import 'package:flutter_test/flutter_test.dart';

/// Markets requested out of the box: BCV, Exchange Monitor, Yadio, Binance and
/// Bybit. OKX, Bitget, Airtm and DolarAPI stay out unless the user adds them.
final MarketSelection _selection = Markets.defaultSelection;

Currency _rate({
  required String platform,
  required String code,
  required String name,
  required double value,
  double? tendency,
  DateTime? updateDate,
}) => Currency(
  name: name,
  keyName: code,
  platform: platform,
  value: value,
  tendency: tendency,
  createDate: DateTime(2026, 1, 1),
  updateDate: updateDate ?? DateTime(2026, 7, 23),
);

void main() {
  group('forAverageTab()', () {
    test('drops the markets outside the allowlist', () {
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.okx,
          code: 'USDT',
          name: 'Tether-sell',
          value: 865,
        ),
        _rate(
          platform: Markets.bitget,
          code: 'USDT',
          name: 'Tether-sell',
          value: 857,
        ),
        _rate(
          platform: Markets.airtm,
          code: 'USD',
          name: 'Dolar-sell',
          value: 826,
        ),
        _rate(
          platform: Markets.dolarApi,
          code: 'USD',
          name: 'Paralelo',
          value: 850,
        ),
        _rate(platform: Markets.yadio, code: 'USD', name: 'Dolar', value: 844),
      ], _selection);

      expect(result.map((c) => c.platform), [Markets.yadio]);
    });

    test('merges the buy and sell sides into one averaged rate', () {
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.binance,
          code: 'USDT',
          name: 'Tether-buy',
          value: 860.0,
          tendency: 1.0,
          updateDate: DateTime(2026, 7, 23, 10),
        ),
        _rate(
          platform: Markets.binance,
          code: 'USDT',
          name: 'Tether-sell',
          value: 870.0,
          tendency: 3.0,
          updateDate: DateTime(2026, 7, 23, 12),
        ),
      ], _selection);

      expect(result, hasLength(1));
      expect(result.single.name, 'Tether');
      expect(result.single.value, 865.0);
      expect(result.single.tendency, 2.0);
      // The merged rate keeps the freshest timestamp of the pair.
      expect(result.single.updateDate, DateTime(2026, 7, 23, 12));
      expect(result.single.createDate, isNotNull);
    });

    test('a lone side still loses its suffix', () {
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.binance,
          code: 'USDC',
          name: 'Usd coin-sell',
          value: 853,
        ),
      ], _selection);

      expect(result.single.name, 'Usd coin');
      expect(result.single.value, 853);
    });

    test('drops repeated database rows keeping the first', () {
      // The backend keys rates by (code, platform) and orders by descending id,
      // so repeats of the same triple are older snapshots.
      final result = CurrencyNormalizer.forAverageTab([
        _rate(platform: Markets.yadio, code: 'USD', name: 'Dolar', value: 844),
        _rate(platform: Markets.yadio, code: 'USD', name: 'Dolar', value: 800),
      ], _selection);

      expect(result, hasLength(1));
      expect(result.single.value, 844);
    });

    test('orders by market instead of by database id', () {
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.bybit,
          code: 'USDT',
          name: 'Tether-sell',
          value: 856,
        ),
        _rate(platform: Markets.yadio, code: 'USD', name: 'Dolar', value: 844),
        _rate(
          platform: Markets.exchangeMonitor,
          code: Markets.emAverageCode,
          name: 'Promedio',
          value: 803,
        ),
        _rate(platform: Markets.bcv, code: 'USD', name: 'Dolar', value: 737),
        _rate(
          platform: Markets.binance,
          code: 'USDT',
          name: 'Tether-sell',
          value: 860,
        ),
      ], _selection);

      expect(
        result.map((c) => c.platform),
        _selection.markets.map((market) => market.platform),
      );
    });

    test('keeps only the estimated average of Exchange Monitor', () {
      // No mode returns just the average: own+monitor brings the own value too,
      // and the old contract trimmed it with enforce_em_average.
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.exchangeMonitor,
          code: Markets.emOwnCode,
          name: 'Exchange monitor',
          value: 814,
        ),
        _rate(
          platform: Markets.exchangeMonitor,
          code: Markets.emAverageCode,
          name: 'Promedio',
          value: 803,
        ),
      ], _selection);

      expect(result, hasLength(1));
      expect(result.single.keyName, Markets.emAverageCode);
    });

    test('keeps the own value when the average is not there', () {
      // A market asked in `own` must not vanish from the list.
      final result = CurrencyNormalizer.forAverageTab([
        _rate(
          platform: Markets.exchangeMonitor,
          code: Markets.emOwnCode,
          name: 'Exchange monitor',
          value: 814,
        ),
      ], _selection);

      expect(result.single.keyName, Markets.emOwnCode);
    });

    test('an empty payload does not throw', () {
      expect(CurrencyNormalizer.forAverageTab([], _selection), isEmpty);
    });
  });
}
