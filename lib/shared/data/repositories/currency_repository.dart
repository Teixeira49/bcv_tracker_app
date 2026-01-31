import 'package:get/get.dart';
import '../../domain/entities/currency.dart';

class CurrencyRepository extends GetxService {
  final RxList<Currency> averageCurrencies = List.generate(5, (e) => Currency.emptySkeletonizer).obs;
  final RxList<Currency> bcvCurrencies = List.generate(5, (e) => Currency.emptySkeletonizer).obs;
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    getAveragedCurrencies();
    getBCVCurrencies();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.wait([getAveragedCurrencies(), getBCVCurrencies()]);
    isLoading.value = false;
  }

  Future<void> getAveragedCurrencies() async {
    // Simulate API call
    averageCurrencies.assignAll([
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'USD',
        value: '349.49',
        tendency: 0.24,
        imgUrl: 'https://exchangemonitor.net/assets/img/rates/ve/bcv.png',
      ),
      Currency(
        name: 'Binance',
        keyName: 'USDT',
        value: '501.67',
        tendency: -0.24,
        imgUrl:
            'https://public.bnbstatic.com/20190405/eb2349c3-b2f8-4a93-a286-8f86a62ea9d8.png',
      ),
      Currency(
        name: 'Binance',
        keyName: 'USDC',
        value: '540.67',
        tendency: 0,
        imgUrl:
            'https://public.bnbstatic.com/20190405/eb2349c3-b2f8-4a93-a286-8f86a62ea9d8.png',
      ),
    ]);
  }

  Future<void> getBCVCurrencies() async {
    // Simulate API call
    bcvCurrencies.assignAll([
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'USD',
        value: '349.49',
      ),
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'EUR',
        value: '450.49',
      ),
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'TRY',
        value: '590.49',
      ),
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'CNY',
        value: '51.49',
      ),
      Currency(
        name: 'Banco Central de Venezuela',
        keyName: 'RUB',
        value: '8.49',
      ),
    ]);
  }
}
