/// Names of the app's routes, and the only place they are spelled out.
///
/// Navigation references a constant here — `Get.toNamed(AppRoutes.home)` — never a
/// literal and never a widget: passing a widget couples the caller to the
/// destination's constructor and leaves that screen out of the routing table
/// entirely. See `.agents/rules/navigation-convention.md`.
///
/// Tabs are not routes (they move `NavigationController.selectedIndex`) and
/// neither are modals — the currency detail and the currency selector are opened
/// directly and closed with `Get.back()`. The price is that a modal is not
/// reachable by deep link; when one needs to be, it gains a `GetPage` here that
/// resolves its data from a route parameter.
///
/// **Settings used to be one of those modals** and stopped being one in
/// [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37): a dialog has
/// nowhere to grow, and the settings still queued (notifications #13,
/// accessibility #33, analytics consent #34, about) would not have fitted in a
/// centred `AlertDialog`. It is now a screen with its own route, and each choice
/// with a list behind it — market, language, theme — has a sub-route of its own.
abstract class AppRoutes {
  /// The entry point. Shows the brand, then replaces itself with [home].
  static const splash = '/splash';

  /// The dashboard: the tab bar and both tabs.
  static const home = '/home';

  /// The settings menu, stacked over the dashboard by the strip's gear.
  static const settings = '/settings';

  /// Where the market the app opens on is chosen.
  ///
  /// The three below are **children of [settings] by name**, and that is the
  /// whole reason the path is nested: it says the screen is reached from the
  /// menu and cannot be entered any other way, which is what a deep link into
  /// `/settings/language` should mean.
  static const settingsMarket = '/settings/market';

  /// Where the interface language is chosen, out of the ten this build ships.
  static const settingsLanguage = '/settings/language';

  /// Where light / dark / follow-the-system is chosen.
  static const settingsTheme = '/settings/theme';

  /// Where the converter's decimals ceiling is set.
  ///
  /// #37's increment, and the first route added *through* the menu rather than
  /// with it — which is the shape the issue's last acceptance criterion asked
  /// for: a setting arrives as an entry and a page, with nothing rearranged.
  static const settingsDecimals = '/settings/decimals';

  /// Who made the app, where its rates come from and under what licence.
  ///
  /// A sub-route of `/settings` like the rest, though it sets nothing: it is
  /// reached from the same menu and belongs to the same shelf. The alternative
  /// —a top-level `/about`— would say it is a destination of its own, and
  /// nothing in the app points there.
  static const settingsAbout = '/settings/about';
}
