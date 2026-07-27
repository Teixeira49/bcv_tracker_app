import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/shared/domain/entities/market.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Markets.catalog', () {
    test('asks every market in a mode its type allows', () {
      // Asking for a mode outside these sets answers 422; the sets mirror
      // ALLOWED_MODES of api/models/market_request.py.
      const fiat = {
        Markets.modeLiveDollar,
        Markets.modeLiveAll,
        Markets.modeDbDollar,
        Markets.modeDbAll,
      };
      const crypto = {Markets.modeAverage, Markets.modeBoth, Markets.modeDbAll};
      const exchangeMonitor = {
        Markets.modeEmOwn,
        Markets.modeEmOwnMonitor,
        Markets.modeDbAll,
      };

      const allowedByKey = <String, Set<String>>{
        Markets.bcvKey: fiat,
        Markets.yadioKey: fiat,
        Markets.airtmKey: fiat,
        Markets.dolarApiKey: fiat,
        Markets.binanceKey: crypto,
        Markets.bybitKey: crypto,
        Markets.okxKey: crypto,
        Markets.bitgetKey: crypto,
        Markets.exchangeMonitorKey: exchangeMonitor,
      };

      expect(
        Markets.catalog.map((market) => market.key).toSet(),
        allowedByKey.keys.toSet(),
        reason: 'the catalogue must cover every market of the backend',
      );
      for (final market in Markets.catalog) {
        expect(
          allowedByKey[market.key],
          contains(market.mode),
          reason: '${market.key} cannot be asked in ${market.mode}',
        );
      }
    });

    test('has one entry per key and per platform', () {
      expect(
        Markets.catalog.map((market) => market.key).toSet(),
        hasLength(Markets.catalog.length),
      );
      expect(
        Markets.catalog.map((market) => market.platform).toSet(),
        hasLength(Markets.catalog.length),
      );
    });
  });

  group('Markets.selectionOf()', () {
    test('keeps the catalogue order, not the order of the keys', () {
      final selection = Markets.selectionOf({
        Markets.bybitKey,
        Markets.bcvKey,
        Markets.yadioKey,
      });

      expect(selection.markets.map((market) => market.key), [
        Markets.bcvKey,
        Markets.yadioKey,
        Markets.bybitKey,
      ]);
    });

    test('ignores a key it does not know', () {
      // A preference saved by an older version must not break the request.
      final selection = Markets.selectionOf({Markets.bcvKey, 'mercado-viejo'});

      expect(selection.markets.map((market) => market.key), [Markets.bcvKey]);
    });

    test('an empty set produces an empty selection', () {
      expect(Markets.selectionOf(const {}).isEmpty, isTrue);
    });
  });

  group('MarketSelection', () {
    test('serializes as the markets map of the Body', () {
      expect(Markets.defaultSelection.toJson(), {
        'markets': {
          Markets.bcvKey: Markets.modeDbDollar,
          Markets.exchangeMonitorKey: Markets.modeEmOwnMonitor,
          Markets.yadioKey: Markets.modeLiveDollar,
          Markets.binanceKey: Markets.modeAverage,
          Markets.bybitKey: Markets.modeAverage,
        },
      });
    });

    test('exposes the platforms its markets answer with', () {
      expect(Markets.defaultSelection.platforms, {
        Markets.bcv,
        Markets.exchangeMonitor,
        Markets.yadio,
        Markets.binance,
        Markets.bybit,
      });
    });

    test('a market keeps its platform name apart from its Body key', () {
      const market = Market(
        key: Markets.bcvKey,
        platform: Markets.bcv,
        mode: Markets.modeDbDollar,
      );

      expect(market.key, 'bcv');
      expect(market.platform, 'Banco Central de Venezuela');
      expect(market.copyWith(mode: Markets.modeDbAll).mode, Markets.modeDbAll);
    });
  });
}
