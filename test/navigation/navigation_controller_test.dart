import 'package:bcv_tracker_app/navigation/navigation_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late NavigationController controller;

  setUp(() {
    Get.testMode = true;
    controller = NavigationController();
  });

  tearDown(() => Get.reset());

  test('starts on the first tab', () {
    expect(controller.selectedIndex.value, 0);
  });

  test('changeIndex moves the selected tab', () {
    controller.changeIndex(1);
    expect(controller.selectedIndex.value, 1);

    controller.changeIndex(0);
    expect(controller.selectedIndex.value, 0);
  });

  test('the selected index is observable', () {
    final seen = <int>[];
    // A tab switch must notify, or the dashboard's IndexedStack never moves.
    controller.selectedIndex.listen(seen.add);

    controller.changeIndex(1);
    controller.changeIndex(1); // same value: RxInt does not re-notify

    expect(seen, [1]);
  });
}
