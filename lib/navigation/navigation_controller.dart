import 'package:get/get.dart';

/// Which tab of the dashboard is showing.
///
/// **Tabs are not routes.** `DashboardPage` keeps both pages alive in an
/// `IndexedStack` and switches between them by this index, so moving between Home
/// and the converter preserves each one's scroll position and state — and never
/// touches the navigation stack. Changing tab is `changeIndex`, never
/// `Get.toNamed`; see `.agents/rules/navigation-convention.md`.
///
/// The index maps to `DashboardPage.pages`: `0` Home, `1` the converter.
class NavigationController extends GetxController {
  /// Index of the visible tab. Observed directly with `Obx` by the dashboard and
  /// the bottom bar, which are the only two widgets that care.
  var selectedIndex = 0.obs;

  /// Shows the tab at [index].
  ///
  /// Also the way in from elsewhere: the detail sheet's "open in the converter"
  /// action calls this after loading the rate
  /// ([#103](https://github.com/Teixeira49/bcv_tracker_app/issues/103)).
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
