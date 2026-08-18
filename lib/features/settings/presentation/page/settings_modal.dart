import 'package:bcv_tracker_app/shared/presentation/widgets/custom_badged.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/domain/entities/language.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../../../../shared/presentation/widgets/base_modal.dart';

part '../widgets/settings_body.dart';

part '../widgets/settings_buttons.dart';

part '../widgets/settings_inputs.dart';

part '../widgets/settings_widgets.dart';

/// Language, theme and default market, in a centred dialog.
///
/// A **modal, not a route**: opened with `showBlurredDialog` and closed with
/// `Get.back()`, so it is not registered in `AppPages`. Its selectors read
/// `SettingsController` with `Obx` rather than `GetBuilder` — the controller is a
/// `GetxService` since
/// [#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59) and `GetBuilder`
/// is bound to `GetxController`.
class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      title: AppMessages.settingsView,
      internalMargin: const EdgeInsets.only(
        right: 20,
        left: 20,
        top: 6,
        bottom: 20,
      ),
      child: _SettingsBody(),
    );
  }
}
