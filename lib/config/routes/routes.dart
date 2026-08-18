/// Names of the app's routes, and the only place they are spelled out.
///
/// Navigation references a constant here — `Get.toNamed(AppRoutes.home)` — never a
/// literal and never a widget: passing a widget couples the caller to the
/// destination's constructor and leaves that screen out of the routing table
/// entirely. See `.agents/rules/navigation-convention.md`.
///
/// **Only two, and that is correct.** Tabs are not routes (they move
/// `NavigationController.selectedIndex`) and neither are modals — the settings
/// dialog, the currency detail and the currency selector are all opened directly
/// and closed with `Get.back()`. The price is that a modal is not reachable by
/// deep link; when one needs to be, it gains a `GetPage` here that resolves its
/// data from a route parameter.
abstract class AppRoutes {
  /// The entry point. Shows the brand, then replaces itself with [home].
  static const splash = '/splash';

  /// The dashboard: the tab bar and both tabs.
  static const home = '/home';
}
