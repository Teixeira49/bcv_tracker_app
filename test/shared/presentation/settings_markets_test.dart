import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds the controller and lets its asynchronous preference load finish.
Future<SettingsController> _loaded() async {
  final controller = SettingsController();
  controller.onInit();
  await Future<void>.delayed(Duration.zero);
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('followed markets', () {
    test('starts on the catalogue default', () async {
      final controller = await _loaded();

      expect(controller.selectedMarketKeys, Markets.defaultKeys);
      expect(
        controller.marketSelection.markets.map((market) => market.key),
        Markets.defaultSelection.markets.map((market) => market.key),
      );
    });

    test('following a market adds it to the request', () async {
      final controller = await _loaded();

      controller.setMarketSelected(Markets.okxKey, true);

      expect(controller.isMarketSelected(Markets.okxKey), isTrue);
      expect(
        controller.marketSelection.toJson(),
        containsPair(
          'markets',
          containsPair(Markets.okxKey, Markets.modeAverage),
        ),
      );
    });

    test('dropping a market takes it out of the request', () async {
      final controller = await _loaded();

      controller.setMarketSelected(Markets.bybitKey, false);

      expect(controller.isMarketSelected(Markets.bybitKey), isFalse);
      expect(
        (controller.marketSelection.toJson()['markets'] as Map),
        isNot(contains(Markets.bybitKey)),
      );
    });

    test('refuses to drop the last market', () async {
      final controller = await _loaded();
      for (final key in Markets.defaultKeys.skip(1)) {
        controller.setMarketSelected(key, false);
      }

      final last = controller.selectedMarketKeys.single;
      controller.setMarketSelected(last, false);

      // An empty selection would answer an empty list and leave the tab blank.
      expect(controller.selectedMarketKeys, {last});
    });

    test('remembers the choice', () async {
      final controller = await _loaded();
      controller.setMarketSelected(Markets.okxKey, true);
      controller.setMarketSelected(Markets.bcvKey, false);
      await Future<void>.delayed(Duration.zero);

      final reopened = await _loaded();

      expect(reopened.selectedMarketKeys, controller.selectedMarketKeys);
    });

    test('ignores a saved market the catalogue no longer knows', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'selected_markets': <String>[Markets.bcvKey, 'mercado-viejo'],
      });

      final controller = await _loaded();

      expect(controller.selectedMarketKeys, {Markets.bcvKey});
    });

    test('falls back to the default if nothing saved is known', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'selected_markets': <String>['mercado-viejo'],
      });

      final controller = await _loaded();

      expect(controller.selectedMarketKeys, Markets.defaultKeys);
    });
  });
}
