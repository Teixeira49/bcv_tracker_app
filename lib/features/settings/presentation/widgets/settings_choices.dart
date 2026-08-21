import 'package:flutter/material.dart';

import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/domain/entities/language.dart';
import 'settings_option_tile.dart';

/// The choices each setting offers, and the label each stored value carries.
///
/// One place, because the menu and the sub-screen ask the same question from
/// two sides: the menu needs "what is index 1 called?" to show the current
/// value, and the sub-screen needs the whole list. Split across the two
/// widgets, the market that reads `BCV` on the menu could come to read
/// `Oficial` on the screen that sets it, and nothing would fail.
///
/// **Methods, not constants.** Every label goes through `AppMessages`, which
/// resolves against the active locale at call time; a `const` list built once
/// would keep the language the app started in — which is precisely the setting
/// one of these lists changes.
///
/// This is presentation, not domain: what lives here is copy and display order.
/// The values themselves — the tab index, the theme mode, the language code —
/// belong to `SettingsController`, which is where they are stored.
abstract class SettingsChoices {
  const SettingsChoices._();

  /// The tab the app opens on, as `SettingsController` stores it: `0` is the
  /// parallel average, `1` the official BCV list. Named here because the two
  /// numbers were until now written literally into the selector's `onTap`. They
  /// are `TabController` indices — `_HomeBody` builds with them — which is why
  /// this is not an enum: the persisted value has always been the tab.
  static const int averageMarketIndex = 0;
  static const int officialMarketIndex = 1;

  /// The two markets the home screen can open on.
  static List<SettingsOption<int>> markets() => <SettingsOption<int>>[
    SettingsOption<int>(
      value: averageMarketIndex,
      label: AppMessages.averageSection,
    ),
    SettingsOption<int>(
      value: officialMarketIndex,
      label: AppMessages.officialSection,
    ),
  ];

  /// The label of the market stored as [index].
  ///
  /// Anything other than the two known indices falls back to the average, the
  /// same value `SettingsController` defaults to — a preference written by a
  /// future build should not leave the menu with a blank line.
  static String marketLabel(int index) => index == officialMarketIndex
      ? AppMessages.officialSection
      : AppMessages.averageSection;

  /// Light, dark, and following the system.
  ///
  /// The icons are the ones the dialog used, kept on purpose: the screen is a
  /// new container for a choice the user already recognises. They are also what
  /// earns this set the grid layout — a sun, a moon and a half-lit dial are
  /// read before their labels are.
  ///
  /// Declared with **no size and no colour**, deliberately: the catalogue says
  /// *which* icon, the widget that draws it says how big and in what state. The
  /// row wants 20 pt and the grid card 28, and an explicit `size:` here would
  /// win over both — an `IconTheme` cannot override what the widget states
  /// itself.
  static List<SettingsOption<ThemeMode>> themes() =>
      <SettingsOption<ThemeMode>>[
        SettingsOption<ThemeMode>(
          value: ThemeMode.light,
          label: AppMessages.lightTheme,
          leading: const Icon(Icons.light_mode),
        ),
        SettingsOption<ThemeMode>(
          value: ThemeMode.dark,
          label: AppMessages.darkTheme,
          leading: const Icon(Icons.dark_mode),
        ),
        SettingsOption<ThemeMode>(
          value: ThemeMode.system,
          label: AppMessages.systemTheme,
          leading: const Icon(Icons.settings_brightness),
        ),
      ];

  /// The label of [mode].
  static String themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => AppMessages.lightTheme,
    ThemeMode.dark => AppMessages.darkTheme,
    ThemeMode.system => AppMessages.systemTheme,
  };

  /// The languages this build ships, as rows.
  ///
  /// [options] comes from `SettingsController.languageOptions` rather than
  /// being repeated here: that list is the one whose codes have to match the
  /// keys `AppTranslations` registers, and a second copy is a second thing to
  /// keep in step (see #98 for what an out-of-step code costs).
  ///
  /// The names are **not** translated — a language is listed in itself, so that
  /// someone who cannot read the current interface can still find their own.
  static List<SettingsOption<String>> languages(List<LanguageOption> options) =>
      options
          .map(
            (LanguageOption language) => SettingsOption<String>(
              value: language.code,
              label: language.name,
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          )
          .toList();
}
