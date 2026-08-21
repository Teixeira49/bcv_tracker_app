part of '../page/settings_page.dart';

/// The rows of the menu, grouped.
///
/// Two groups today — what the app *does* and what the app *looks like* — and
/// the split is what makes the menu survive growth: notifications and analytics
/// consent join `preferencesSection`, accessibility joins `appearanceSection`,
/// and neither forces a redesign.
///
/// Reads the settings service through `Obx` rather than `GetBuilder`.
/// `SettingsController` is a `GetxService` since
/// [#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59) and never
/// calls `update()`, so a `GetBuilder` here would locate the instance and then
/// never rebuild — the trap `settings_widgets.dart` documented before this
/// screen replaced it. The whole menu sits in one `Obx` on purpose: all three
/// values are on the same three rows, so splitting it would buy a rebuild of
/// two rows instead of three.
class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu();

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => ListView(
        // Clears the last card from the bottom edge of the panel.
        padding: EdgeInsets.only(bottom: WidthValues.spacing4xl),
        children: <Widget>[
          SettingsSection(
            title: AppMessages.preferencesSection,
            children: <Widget>[
              SettingsMenuTile(
                icon: Icons.storefront_rounded,
                title: AppMessages.defaultMarket,
                description: AppMessages.defaultMarketDescription,
                value: SettingsChoices.marketLabel(
                  controller.favMarketIndex.value,
                ),
                onTap: () => Get.toNamed<void>(AppRoutes.settingsMarket),
              ),
              SettingsMenuTile(
                icon: Icons.tag_rounded,
                title: AppMessages.converterDecimals,
                description: AppMessages.converterDecimalsDescription,
                // The count itself is the value: "5" is what the setting is
                // set to, and no label reads better than the number.
                value: '${controller.favDecimals.value}',
                onTap: () => Get.toNamed<void>(AppRoutes.settingsDecimals),
              ),
              SettingsMenuTile(
                icon: Icons.translate_rounded,
                title: AppMessages.language,
                description: AppMessages.languageDescription,
                // The service's own resolution, not a lookup written here: it
                // falls back to the default when the stored code is one this
                // build no longer ships, which is the crash #98 fixed.
                value: controller.selectedLanguage.name,
                onTap: () => Get.toNamed<void>(AppRoutes.settingsLanguage),
              ),
            ],
          ),
          SettingsSection(
            title: AppMessages.appearanceSection,
            children: <Widget>[
              SettingsMenuTile(
                icon: Icons.palette_outlined,
                title: AppMessages.theme,
                description: AppMessages.themeDescription,
                value: SettingsChoices.themeLabel(
                  controller.favBrightness.value,
                ),
                onTap: () => Get.toNamed<void>(AppRoutes.settingsTheme),
              ),
            ],
          ),
          // A third group, and not a fourth row in «Preferencias»: «Acerca de»
          // sets nothing. Mixing a destination in among the settings would make
          // the value column meaningless for one row — and this is where #43
          // puts the version, which is the same kind of thing.
          SettingsSection(
            title: AppMessages.informationSection,
            children: <Widget>[
              SettingsMenuTile(
                icon: Icons.info_outline_rounded,
                title: AppMessages.aboutView,
                description: AppMessages.aboutDescription,
                // No `value`: this row reports no state, it opens a screen.
                onTap: () => Get.toNamed<void>(AppRoutes.settingsAbout),
              ),
              SettingsMenuTile(
                icon: Icons.sell_outlined,
                title: AppMessages.appVersion,
                description: AppMessages.appVersionDescription,
                // The installed package's own figure, never a constant (#43).
                value: Get.find<AppInfoService>().versionLabel,
                // Copies rather than navigates, so it ends in a copy icon: a
                // chevron would promise a screen that does not exist.
                trailingIcon: Icons.copy_rounded,
                onTap: () => copyVersion(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
