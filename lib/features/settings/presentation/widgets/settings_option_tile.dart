import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';

/// One choice offered by a `SettingsOptionsPage`.
///
/// [T] is whatever the setting is stored as — an `int` tab index, a `String`
/// language code, a `ThemeMode`. Nothing here interprets it: it is compared for
/// equality and handed back on tap, so a new single-choice setting needs no
/// change to this file.
class SettingsOption<T> {
  const SettingsOption({
    required this.value,
    required this.label,
    this.leading,
    this.description,
  });

  /// What gets persisted when this row is tapped.
  final T value;

  /// The row's label. From `AppMessages`, **except** the language names, which
  /// are written in the language they name and are therefore not translated
  /// (`i18n-convention.md`, rule 9).
  final String label;

  /// Optional glyph at the start of the row — a flag for a language, an icon
  /// for a theme.
  final Widget? leading;

  /// Optional second line, for a choice whose label does not say enough on its
  /// own.
  final String? description;
}

/// One row of a `SettingsOptionsPage`.
///
/// The tick is drawn only on the selected row rather than a radio button on
/// every row: with ten languages, ten empty circles are ten pieces of furniture
/// carrying one bit of information. Selection is also carried by the label's
/// colour and weight, so it does not rest on the icon alone.
class SettingsOptionTile<T> extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final SettingsOption<T> option;

  /// Whether [option] is the value currently stored.
  final bool isSelected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: WidthValues.spacingMd,
        vertical: WidthValues.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          if (option.leading != null) ...<Widget>[
            option.leading!,
            SizedBox(width: WidthValues.spacingSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? ColorValues.textBrandSecondary(context)
                        : ColorValues.textPrimary(context),
                  ),
                ),
                if (option.description != null) ...<Widget>[
                  SizedBox(height: WidthValues.spacingXxs),
                  Text(
                    option.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorValues.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 20,
              color: ColorValues.fgBrandPrimary(context),
            ),
        ],
      ),
    ),
  );
}
