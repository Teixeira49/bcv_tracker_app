import 'package:bcv_tracker_app/core/network/api_exception.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// A repository fake: returns entities or throws, no network.
class _FakeDollarRepository implements IDollarRepository {
  _FakeDollarRepository({this.bcv, this.saved, this.bcvThrows});

  final BcvCurrencies? bcv;
  final List<Currency>? saved;
  final Object? bcvThrows;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async {
    if (bcvThrows != null) throw bcvThrows!;
    return bcv ?? BcvCurrencies(date: null, currencies: const []);
  }

  @override
  Future<List<Currency>> getCurrentDollar() async {
    return saved ?? const [];
  }
}

const _bcvUsd = Currency(
  name: 'Dolar',
  keyName: 'USD',
  platform: 'Banco Central de Venezuela',
  value: 737.88,
);

CurrencyRepository _repositoryWith(_FakeDollarRepository fake) {
  Get.put<IDollarRepository>(fake);
  return Get.put(CurrencyRepository());
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  group('refreshData() success', () {
    test('populates BCV data and clears the error', () async {
      final repo = _repositoryWith(
        _FakeDollarRepository(
          bcv: BcvCurrencies(date: '2026-07-23', currencies: [_bcvUsd]),
          saved: const [],
        ),
      );

      await repo.refreshData();

      expect(repo.bcvCurrencies, contains(_bcvUsd));
      expect(repo.bcvCurrentDate.value, '2026-07-23');
      expect(repo.hasBcvData.value, isTrue);
      expect(repo.hasAverageData.value, isTrue);
      expect(repo.errorMessage.value, isNull);
      expect(repo.isLoading.value, isFalse);
    });

    test('a null BCV date becomes an empty string, not "null"', () async {
      final repo = _repositoryWith(
        _FakeDollarRepository(
          bcv: BcvCurrencies(date: null, currencies: const []),
          saved: const [],
        ),
      );

      await repo.refreshData();

      expect(repo.bcvCurrentDate.value, '');
    });
  });

  group('refreshData() error paths', () {
    test('an ApiException surfaces as errorMessage, loading resets', () async {
      final repo = _repositoryWith(
        _FakeDollarRepository(
          bcvThrows: const ApiException.network(
            'El portal del BCV no responde',
          ),
          saved: const [],
        ),
      );

      await repo.refreshData();

      // ApiException carries the backend message; the repo hands that to the UI.
      expect(repo.errorMessage.value, 'El portal del BCV no responde');
      expect(repo.isLoading.value, isFalse);
    });

    test('a partial failure still lands the side that succeeded', () async {
      // eagerError is off: the BCV fetch fails but the average fetch completes,
      // so its data is present even though an error is reported.
      final repo = _repositoryWith(
        _FakeDollarRepository(
          bcvThrows: const ApiException.malformed('bad BCV contract'),
          saved: const [],
        ),
      );

      await repo.refreshData();

      expect(repo.hasAverageData.value, isTrue);
      expect(repo.errorMessage.value, isNotNull);
    });

    test('a non-ApiException degrades to its toString', () async {
      final repo = _repositoryWith(
        _FakeDollarRepository(
          bcvThrows: StateError('unexpected'),
          saved: const [],
        ),
      );

      await repo.refreshData();

      expect(repo.errorMessage.value, contains('unexpected'));
      expect(repo.isLoading.value, isFalse);
    });
  });
}
