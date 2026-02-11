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
