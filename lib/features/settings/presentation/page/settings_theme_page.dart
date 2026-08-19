import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../widgets/settings_choices.dart';
import 'settings_options_page.dart';

/// Where light, dark or follow-the-system is chosen.
///
/// The screen repaints under the choice as it is made — `setFavTheme` calls
/// `Get.changeThemeMode`, which rebuilds the app around this route. That is why
/// the page stays open after a tap (see [SettingsOptionsPage]): the preview is
/// the whole point, and popping would replace it with the menu.
class SettingsThemePage extends StatelessWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => SettingsOptionsPage<ThemeMode>(
        title: AppMessages.theme,
        options: SettingsChoices.themes(),
        selected: controller.favBrightness.value,
        onSelected: controller.setFavTheme,
      ),
    );
  }
}
