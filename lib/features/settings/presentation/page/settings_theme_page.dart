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
///
/// **The one sub-screen laid out as a grid**, and the reason is what the three
/// options are: a sun, a moon and a half-lit dial say *light*, *dark* and
/// *system* before the label is read, so cards two per row put the whole choice
/// on screen and let the icon carry it. The ten languages are the opposite case
/// — a set that is read, which a grid makes sweep in zigzag — and stay a list.
/// `DESIGN.md` → *settingsChoiceCard*.
class SettingsThemePage extends StatelessWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => SettingsOptionsPage<ThemeMode>(
        title: AppMessages.theme,
        intro: AppMessages.themeIntro,
        options: SettingsChoices.themes(),
        selected: controller.favBrightness.value,
        onSelected: controller.setFavTheme,
        layout: SettingsOptionsLayout.grid,
      ),
    );
  }
}
