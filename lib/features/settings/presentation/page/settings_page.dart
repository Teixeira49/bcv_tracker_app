import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../widgets/settings_choices.dart';
import '../widgets/settings_section.dart';

part '../widgets/settings_menu.dart';

/// The settings menu: every preference the app has, grouped, each showing what
/// it is currently set to.
///
/// **A screen since [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37);
/// it used to be `SettingsModal`, a centred `AlertDialog`.** The dialog held
/// three selectors stacked in a column, one of them a dropdown over ten
/// languages, with no grouping and nothing saying what any of them did. What
/// broke it was not the look but the arithmetic: a dialog is capped at part of
/// the screen, and the settings queued behind this one — notifications
/// ([#13](https://github.com/Teixeira49/bcv_tracker_app/issues/13)),
/// accessibility (#33), analytics consent (#34), about and version — do not fit
/// in it at any font scale.
///
/// So the shape is the point: a section per theme, a row per setting, and the
/// choice itself on its own route. Adding a setting is adding a
/// [SettingsMenuTile] — and a `GetPage` if it needs a list to pick from — with
/// nothing else on this screen to rearrange.
///
/// It registers **no controller of its own**. Everything on it is
/// `SettingsController`, the app-wide service; a controller here would be a
/// second object holding the same three values.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorValues.bgPrimary(context),
    body: BaseLayout(
      title: AppMessages.settingsView,
      showBackButton: true,
      // The gear that opens this screen is the one control it must not offer.
      showSettingsAction: false,
      margins: EdgeInsets.fromLTRB(
        WidthValues.spacingMd,
        WidthValues.spacingLg,
        WidthValues.spacingMd,
        WidthValues.spacingNone,
      ),
      child: const _SettingsMenu(),
    ),
  );
}
