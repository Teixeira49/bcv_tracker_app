import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Currency _rate(String platform) => Currency(
  name: 'Dólar estadounidense',
  keyName: 'USD',
  platform: platform,
  value: 152.30,
);

void main() {
  late CurrencyDetailController controller;

  setUp(() {
    Get.testMode = true;
    controller = Get.put(CurrencyDetailController());
  });

  tearDown(Get.reset);

  test('starts with nothing on display', () {
    expect(controller.hasCurrency, isFalse);
    expect(controller.currency, isNull);
  });

  test('open points the sheet at the rate it was handed', () {
    final Currency rate = _rate(Markets.binance);
    controller.open(rate);

    expect(controller.hasCurrency, isTrue);
    // The very same instance: the sheet renders the card's snapshot, it does
    // not re-fetch or rebuild the entity.
    expect(controller.currency, same(rate));
  });

  test('opening another rate replaces the first', () {
    controller.open(_rate(Markets.binance));
    controller.open(_rate(Markets.bybit));

    expect(controller.currency?.platform, Markets.bybit);
  });

  test('dismiss clears the rate so none flashes on the next open', () {
    controller.open(_rate(Markets.binance));
    controller.dismiss();

    expect(controller.hasCurrency, isFalse);
    expect(controller.currency, isNull);
  });

  test('the worker is disposed with the controller', () {
    // #45: `get` 4.7.3 disposes no workers on its own and this controller is
    // registered with `fenix`, so it is rebuilt on every open. A worker that
    // outlived its controller would accumulate one listener per opening.
    controller.open(_rate(Markets.binance));
    controller.onClose();

    // Past onClose the observable must move nothing: if the worker were still
    // alive, `update()` would run on a disposed controller and throw.
    expect(() => controller.open(_rate(Markets.bybit)), returnsNormally);
  });
}
