part of '../page/settings_modal.dart';

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22));
}

class _MarketSelector extends StatelessWidget {
  const _MarketSelector();

  @override
  Widget build(BuildContext context) => GetBuilder<SettingsController>(
    builder: (SettingsController controller) => Obx(
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
    ),
  );
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) => GetBuilder<SettingsController>(
    builder: (SettingsController controller) => Obx(
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
    ),
  );
}
