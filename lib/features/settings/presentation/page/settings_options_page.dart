import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../widgets/settings_option_tile.dart';

/// The screen where a single-choice setting is picked from a list.
///
/// One widget for the three sub-screens
/// [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37) asks for,
/// because they differ only in their list: language (ten rows), market (two)
/// and theme (three). Written generically so the next single-choice setting is
/// a `GetPage` and a list, not another screen.
///
/// **It does not close on selection, deliberately.** Language and theme repaint
/// the entire app the instant they are applied, and that repaint *is* the
/// confirmation — popping on top of it stacks a route transition over a full
/// rebuild and hides the very feedback the tap produced. The user goes back
/// when they are done, which is also what lets them compare two themes without
/// entering the screen twice.
///
/// It renders whatever [selected] says and reports taps through [onSelected];
/// the reactivity belongs to the caller, which wraps this in an `Obx` over
/// `SettingsController` (see `getx-architecture`: the service holds the `Rx`,
/// the view never names it).
class SettingsOptionsPage<T> extends StatelessWidget {
  const SettingsOptionsPage({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// Screen heading, shown in the branded strip. From `AppMessages`.
  final String title;

  /// The choices, in display order.
  final List<SettingsOption<T>> options;

  /// The value currently stored. Exactly one row is expected to match it; if
  /// none does, no row is ticked — the honest rendering of a stored value this
  /// build no longer offers.
  final T selected;

  /// Applies the choice. The setter that persists it lives on
  /// `SettingsController`; this page only reports the tap.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorValues.bgPrimary(context),
    body: BaseLayout(
      title: title,
      showBackButton: true,
      showSettingsAction: false,
      margins: EdgeInsets.fromLTRB(
        WidthValues.spacingMd,
        WidthValues.spacingLg,
        WidthValues.spacingMd,
        WidthValues.spacingNone,
      ),
      child: ListView(
        // Room under the last row: the panel ends at the screen edge and a list
        // that stops flush against it reads as cut off.
        padding: EdgeInsets.only(bottom: WidthValues.spacing4xl),
        children: <Widget>[
          Card(
            margin: EdgeInsets.zero,
            color: ColorValues.utilityBrand50(context),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < options.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: WidthValues.spacingMd,
                      endIndent: WidthValues.spacingMd,
                      color: ColorValues.borderPrimary(context),
                    ),
                  SettingsOptionTile<T>(
                    option: options[i],
                    isSelected: options[i].value == selected,
                    onTap: () => onSelected(options[i].value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
