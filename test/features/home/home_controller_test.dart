import 'package:bcv_tracker_app/features/home/presentation/controller/home_controller.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeDollarRepository implements IDollarRepository {
  _FakeDollarRepository({this.bcvThrows});

  final Object? bcvThrows;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async {
    if (bcvThrows != null) throw bcvThrows!;
    return BcvCurrencies(date: '2026-07-23', currencies: const [_usd]);
  }

  @override
  Future<List<Currency>> getCurrentDollar() async => const [];
}

const _usd = Currency(
  name: 'Dolar',
  keyName: 'USD',
  platform: 'Banco Central de Venezuela',
  value: 737.88,
);

void main() {
  late CurrencyRepository repository;
  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    Get.put<IDollarRepository>(_FakeDollarRepository());
    repository = Get.put(CurrencyRepository());
    controller = Get.put(HomeController());
  });

  tearDown(() => Get.reset());

  group('HomeController delegation', () {
    test('unwrapped getters read straight from the repository', () {
      repository.isLoading.value = true;
      repository.errorMessage.value = 'boom';
      repository.bcvCurrentDate.value = '2026-07-23';
      repository.hasAverageData.value = true;
      repository.hasBcvData.value = false;

      expect(controller.isLoading, isTrue);
      expect(controller.errorMessage, 'boom');
      expect(controller.bcvCurrentDate, '2026-07-23');
      expect(controller.hasAverageData, isTrue);
      expect(controller.hasBcvData, isFalse);
    });

    test('currency getters expose the repository lists', () {
      repository.bcvCurrencies.assignAll(const [_usd]);
      expect(controller.bcvCurrencies, contains(_usd));
    });

    test('errorMessage is null when the last refresh succeeded', () {
      repository.errorMessage.value = null;
      expect(controller.errorMessage, isNull);
    });
  });

  group('refreshHomeData()', () {
    test('drives a repository refresh and lands its data', () async {
      await controller.refreshHomeData();

      expect(controller.hasBcvData, isTrue);
      expect(controller.bcvCurrentDate, '2026-07-23');
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test(
      'a failing refresh surfaces the error through the controller',
      () async {
        Get.reset();
        Get.testMode = true;
        Get.put<IDollarRepository>(
          _FakeDollarRepository(bcvThrows: StateError('down')),
        );
        Get.put(CurrencyRepository());
        final failing = Get.put(HomeController());

        await failing.refreshHomeData();

        expect(failing.errorMessage, isNotNull);
        expect(failing.isLoading, isFalse);
      },
    );
  });
}
