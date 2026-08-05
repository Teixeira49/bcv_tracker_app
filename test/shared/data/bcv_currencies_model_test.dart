import 'dart:convert';

import 'package:bcv_tracker_app/shared/data/model/bcv_currencies_model.dart';
import 'package:bcv_tracker_app/shared/data/model/currency_model.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

/// A `BcvResponseData` payload with two rates, shaped like the backend's.
Map<String, dynamic> _payload() =>
    json.decode(
          '{"date":"2026-07-23T00:00:00-04:00","currencies":['
          '{"code":"USD","name":"Dolar","platform":"Banco Central de Venezuela",'
          '"value":737.88,"change":33.08,"createDate":"2026-01-29T18:38:47.617316",'
          '"updateDate":"2026-07-23T03:46:17.336191","platform_img":"https://logo.test/bcv.png"},'
          '{"code":"EUR","name":"Euro","platform":"Banco Central de Venezuela",'
          '"value":812.10,"change":-1.2,"createDate":null,"updateDate":null,'
          '"platform_img":""}]}',
        )
        as Map<String, dynamic>;

void main() {
  group('BcvCurrenciesModel.toEntity()', () {
    test('converts every element of the list, not just the wrapper', () {
      final entity = BcvCurrenciesModel.fromJson(_payload()).toEntity();

      // Checked by runtime type on purpose. `CurrencyModel extends Currency`,
      // so `isA<Currency>()` and any value comparison pass just as happily with
      // the leak present — the only thing that tells them apart is the exact
      // type of the object that crossed the boundary.
      for (final Currency currency in entity.currencies) {
        expect(currency.runtimeType, Currency);
        expect(currency, isNot(isA<CurrencyModel>()));
      }
    });

    test('keeps the mapped values while changing the type', () {
      final entity = BcvCurrenciesModel.fromJson(_payload()).toEntity();

      expect(entity.date, '2026-07-23T00:00:00-04:00');
      expect(entity.currencies, hasLength(2));

      final usd = entity.currencies.first;
      expect(usd.keyName, 'USD');
      expect(usd.value, 737.88);
      expect(usd.tendency, 33.08);
      expect(usd.imgUrl, 'https://logo.test/bcv.png');
      expect(
        usd.updateDate!.toUtc(),
        DateTime.utc(2026, 7, 23, 3, 46, 17, 336, 191),
      );

      final eur = entity.currencies.last;
      expect(eur.keyName, 'EUR');
      expect(eur.createDate, isNull);
      // An empty logo becomes null so the UI falls back to the initials.
      expect(eur.imgUrl, isNull);
    });

    test('the returned object is the entity, not the model', () {
      final entity = BcvCurrenciesModel.fromJson(_payload()).toEntity();

      expect(entity.runtimeType, BcvCurrencies);
      expect(entity, isNot(isA<BcvCurrenciesModel>()));
    });

    test('a degraded payload with no currencies converts to an empty list', () {
      final entity = BcvCurrenciesModel.fromJson(
        json.decode('{"date":null}') as Map<String, dynamic>,
      ).toEntity();

      expect(entity.date, isNull);
      expect(entity.currencies, isEmpty);
    });

    test('rows that are not objects are dropped instead of throwing', () {
      final entity = BcvCurrenciesModel.fromJson(
        json.decode('{"date":null,"currencies":[null,42,"nope"]}')
            as Map<String, dynamic>,
      ).toEntity();

      expect(entity.currencies, isEmpty);
    });
  });

  group('CurrencyModel.toEntity()', () {
    test('returns an entity, since the list conversion leans on it', () {
      final model = CurrencyModel.fromJson(
        json.decode(
              '{"code":"USD","name":"Dolar","platform":"BCV","value":1.0,'
              '"change":0,"createDate":null,"updateDate":null,"platform_img":""}',
            )
            as Map<String, dynamic>,
      );

      expect(model.toEntity().runtimeType, Currency);
    });
  });
}
