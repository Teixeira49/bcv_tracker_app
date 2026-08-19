import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../widgets/settings_choices.dart';
import 'settings_options_page.dart';

/// Where the market the app opens on is chosen.
///
/// Two rows, and it is still a screen rather than a control inlined in the
/// menu: the menu's job is to state what everything is set to, and a screen per
/// choice is what keeps that true when the list grows. This is the one that
/// will grow — #37 names the followed-markets selection as what comes next, and
/// that arrives as more rows here, not as a new screen.
class SettingsMarketPage extends StatelessWidget {
  const SettingsMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => SettingsOptionsPage<int>(
        title: AppMessages.defaultMarket,
        options: SettingsChoices.markets(),
        selected: controller.favMarketIndex.value,
        onSelected: controller.setFavMarket,
      ),
    );
  }
}
