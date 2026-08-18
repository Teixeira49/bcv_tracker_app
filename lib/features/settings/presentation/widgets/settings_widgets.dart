part of '../page/settings_modal.dart';

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22));
}

/// The settings selectors read the service with `Obx`, not `GetBuilder`.
///
/// `SettingsController` is a `GetxService` since #59, and `GetBuilder<T>` is
/// bound to `T extends GetxController`, so it no longer type-checks. It was
/// also doing nothing: the service never calls `update()`, so the `GetBuilder`
/// wrapping these widgets never rebuilt on its own — it was an instance
/// locator with a rebuild mechanism attached that nothing ever triggered. The
/// `Obx` inside was already carrying the reactivity.
class _MarketSelector extends StatelessWidget {
  const _MarketSelector();

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MarketDefaultButton(
            label: AppMessages.averageSection,
            onTap: () => controller.setFavMarket(0),
            isSelected: controller.favMarketIndex.value == 0,
          ),
          _MarketDefaultButton(
            label: AppMessages.officialSection,
            onTap: () => controller.setFavMarket(1),
            isSelected: controller.favMarketIndex.value == 1,
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => Row(
        spacing: 8,
        children: [
          _ThemeButton(
            label: AppMessages.lightTheme,
            icon: Icons.light_mode,
            onTap: () => controller.setFavTheme(ThemeMode.light),
            isSelected: controller.favBrightness.value == ThemeMode.light,
          ),
          _ThemeButton(
            label: AppMessages.darkTheme,
            icon: Icons.dark_mode,
            onTap: () => controller.setFavTheme(ThemeMode.dark),
            isSelected: controller.favBrightness.value == ThemeMode.dark,
          ),
          _ThemeButton(
            label: AppMessages.systemTheme,
            icon: Icons.settings_brightness,
            onTap: () => controller.setFavTheme(ThemeMode.system),
            isSelected: controller.favBrightness.value == ThemeMode.system,
          ),
        ],
      ),
    );
  }
}
