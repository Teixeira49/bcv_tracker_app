import 'package:bcv_tracker_app/core/network/api_exception.dart';
import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar_api.dart';
import 'package:bcv_tracker_app/shared/data/model/model.dart';
import 'package:bcv_tracker_app/shared/data/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

/// A datasource fake: returns canned models or throws, never touches the
/// network. What it was asked is recorded so the repository's contract can be
/// asserted.
class _FakeDollarApi implements IDollarApi {
  _FakeDollarApi({this.bcv, this.saved, this.throwsOn});

  final BcvCurrenciesModel? bcv;
  final List<CurrencyModel>? saved;

  /// If set, both calls throw this instead of returning.
  final Object? throwsOn;

  int bcvCalls = 0;
  int savedCalls = 0;

  @override
  Future<BcvCurrenciesModel> getCurrentBCVDollar() async {
    bcvCalls++;
    if (throwsOn != null) throw throwsOn!;
    return bcv!;
  }

  @override
  Future<List<CurrencyModel>> getCurrentDollar() async {
    savedCalls++;
    if (throwsOn != null) throw throwsOn!;
    return saved!;
  }
}

CurrencyModel _model(String code) => CurrencyModel.fromJson({
  'code': code,
  'name': code,
  'platform': 'Test',
  'value': 1.0,
  'change': 0,
  'createDate': null,
  'updateDate': null,
  'platform_img': '',
});

void main() {
  group('DollarRepository.getCurrentBCVDollar()', () {
    test('returns a domain entity, converted from the model', () async {
      final api = _FakeDollarApi(
        bcv: BcvCurrenciesModel(
          date: '2026-07-23',
          currencies: [_model('USD')],
        ),
      );
      final repo = DollarRepository(dollarApi: api);

      final result = await repo.getCurrentBCVDollar();

      expect(api.bcvCalls, 1);
      expect(result.date, '2026-07-23');
      // The boundary must hand over entities, not the models it deserialised.
      expect(result.runtimeType, BcvCurrencies);
      expect(result.currencies.first.runtimeType, Currency);
    });

    test('propagates an ApiException from the datasource', () async {
      final repo = DollarRepository(
        dollarApi: _FakeDollarApi(
          throwsOn: const ApiException.network('backend down'),
        ),
      );

      await expectLater(
        repo.getCurrentBCVDollar(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'backend down',
          ),
        ),
      );
    });
  });

  group('DollarRepository.getCurrentDollar()', () {
    test('maps every model to an entity', () async {
      final api = _FakeDollarApi(saved: [_model('USD'), _model('EUR')]);
      final repo = DollarRepository(dollarApi: api);

      final result = await repo.getCurrentDollar();

      expect(api.savedCalls, 1);
      expect(result, hasLength(2));
      expect(result.every((c) => c.runtimeType == Currency), isTrue);
    });

    test('propagates an ApiException from the datasource', () async {
      final repo = DollarRepository(
        dollarApi: _FakeDollarApi(
          throwsOn: const ApiException.malformed('bad contract'),
        ),
      );

      await expectLater(repo.getCurrentDollar(), throwsA(isA<ApiException>()));
    });
  });
}
