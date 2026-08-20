import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/helpers/currency_helpers.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../widgets/settings_counter.dart';

/// Where the converter's decimals ceiling is set.
///
/// **The increment #37 carries beyond its own scope**, added on the same branch
/// at the author's request: the issue reorganised the settings that existed,
/// and this is the first genuinely new one the reorganised menu had to absorb.
/// That it cost one menu entry, one route and one page — with nothing on the
/// menu rearranged — is the acceptance criterion "adding a setting is adding an
/// entry" being collected rather than asserted.
///
/// It is a **counter**, not a list: nine values where the user wants "one
/// more", not "the seventh one". `SettingsOptionsPage` does not fit and is not
/// stretched to; [SettingsCounter] is the third shape a setting can take here.
///
/// The worked example under the counter is the part that earns the screen. A
/// ceiling is abstract — "seven decimals" means nothing until a figure is shown
/// at seven — and this one is rendered through `CurrencyHelpers.castAmount`
/// itself, so the preview cannot drift from what the converter will do. It also
/// demonstrates the rule that is easiest to misread: raising the ceiling adds
/// digits only while the figure has them.
class SettingsDecimalsPage extends StatelessWidget {
  const SettingsDecimalsPage({super.key});

  /// The figure the example is worked on.
  ///
  /// Chosen to have more decimals than the highest ceiling offers, so every
  /// step of the counter changes the line — a sample that ran out of digits
  /// half way up would look like the setting had stopped working.
  static const double _sampleAmount = 1234.567890123456;

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: ColorValues.bgPrimary(context),
      body: BaseLayout(
        title: AppMessages.converterDecimals,
        showBackButton: true,
        showSettingsAction: false,
        margins: EdgeInsets.fromLTRB(
          WidthValues.spacingMd,
          WidthValues.spacingLg,
          WidthValues.spacingMd,
          WidthValues.spacingNone,
        ),
        child: Obx(
          () => ListView(
            padding: EdgeInsets.only(bottom: WidthValues.spacing4xl),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: WidthValues.spacingXs,
                  right: WidthValues.spacingXs,
                  bottom: WidthValues.spacingMd,
                ),
                child: Text(
                  AppMessages.converterDecimalsIntro,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: ColorValues.textTertiary(context),
                  ),
                ),
              ),
              SettingsCounter(
                value: controller.favDecimals.value,
                min: Constants.converterMinDecimals,
                max: Constants.converterMaxDecimals,
                onChanged: controller.setFavDecimals,
              ),
              SizedBox(height: WidthValues.spacingMd),
              _DecimalsExample(decimals: controller.favDecimals.value),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sample amount, rendered exactly as the converter would render it.
class _DecimalsExample extends StatelessWidget {
  const _DecimalsExample({required this.decimals});

  final int decimals;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: WidthValues.spacingXs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppMessages.decimalsExample,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorValues.textTertiary(context),
          ),
        ),
        SizedBox(height: WidthValues.spacingXxs),
        Text(
          // Through the real formatter, not a `toStringAsFixed` written here:
          // a preview that computed its own answer could promise a rendering
          // the converter does not deliver.
          CurrencyHelpers.castAmount(
            value: SettingsDecimalsPage._sampleAmount,
            maxDecimals: decimals,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColorValues.textBrandSecondary(context),
          ),
        ),
      ],
    ),
  );
}
