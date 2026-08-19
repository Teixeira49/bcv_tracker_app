import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../widgets/settings_choices.dart';
import 'settings_options_page.dart';

/// Where the interface language is chosen, out of the ten this build ships.
///
/// The screen #37 was mostly about: ten options in a `DropdownButtonFormField`
/// inside a dialog meant a popup over a popup, each row the height of a menu
/// item, and the current language visible only as the dropdown's own text. Ten
/// rows on a screen are ten rows on a screen.
///
/// Selecting persists — including selecting the language already shown. That is
/// deliberate and it is `SettingsController.setFavLanguage`'s doing, not this
/// screen's: until the user picks one the app *follows the device*
/// ([#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98)), and tapping
/// the highlighted row is how "the phone is in English" becomes "I want
/// English".
class SettingsLanguagePage extends StatelessWidget {
  const SettingsLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => SettingsOptionsPage<String>(
        title: AppMessages.language,
        options: SettingsChoices.languages(controller.languageOptions),
        // The stored code, not `selectedLanguage.code`: the two agree whenever
        // the stored value is one this build ships, and when they do not, this
        // is the one that leaves every row unticked instead of ticking Spanish
        // and claiming a choice the user never made.
        selected: controller.favLanguageCode.value,
        onSelected: controller.setFavLanguage,
      ),
    );
  }
}
