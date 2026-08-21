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

/// One option as a **card in a two-column grid**, the alternative to
/// [SettingsOptionTile]'s row.
///
/// Used where the options are few and each carries an icon that tells them
/// apart at a glance — the theme. There the icon does the work reading the
/// label would, and two columns put every choice on screen without scrolling.
/// The ten languages stay a list: a grid makes a set you *read* sweep in
/// zigzag. `DESIGN.md` → *settingsChoiceCard* holds the rule.
///
/// The selected card is marked by a **2 px brand border** as well as by tint
/// and weight. Thickness survives what colour does not — greyscale, a dimmed
/// screen, the ~8 % of men with a colour vision deficiency — and `DESIGN.md`
/// rules out leaning on tone alone. For assistive tech the state travels in
/// [Semantics.selected], which no amount of pixels conveys.
class SettingsOptionCard<T> extends StatelessWidget {
  const SettingsOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final SettingsOption<T> option;

  /// Whether [option] is the value currently stored.
  final bool isSelected;

  final VoidCallback onTap;

  /// Border of the selected card, against 1 px unselected.
  ///
  /// The card grows no larger when picked: Flutter draws the border inside the
  /// box, so the extra point eats into the padding rather than nudging its
  /// neighbour — which is what would make the grid twitch on every tap.
  static const double _selectedBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final Color accent = ColorValues.textBrandSecondary(context);

    return Semantics(
      selected: isSelected,
      button: true,
      // A `Card`, i.e. a `Material` of its own — **not** an `Ink`. `Ink` paints
      // its decoration onto the nearest enclosing `Material`, which here is the
      // one `Scaffold` provides, and a `Material` paints its ink layer *below*
      // its children: `BaseLayout`'s opaque panel and its wave are children, so
      // the card backgrounds landed underneath them and only the icon and the
      // label were visible. Caught by the golden references, which is the kind
      // of defect they exist for.
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected
            ? ColorValues.utilityBrandSecondary100(context)
            : ColorValues.utilityBrand50(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WidthValues.radiusMd),
          side: BorderSide(
            color: isSelected ? accent : ColorValues.borderPrimary(context),
            width: isSelected ? _selectedBorderWidth : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WidthValues.radiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: WidthValues.spacingXs,
              vertical: WidthValues.spacingMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (option.leading != null) ...<Widget>[
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 28,
                      color: isSelected
                          ? accent
                          : ColorValues.textTertiary(context),
                    ),
                    child: option.leading!,
                  ),
                  SizedBox(height: WidthValues.spacingXs),
                ],
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  // Two lines, because the cell is half the screen and the
                  // German and Russian theme labels do not fit one
                  // (`i18n-convention.md`, rule 6).
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? accent
                        : ColorValues.textPrimary(context),
                  ),
                ),
                if (option.description != null) ...<Widget>[
                  SizedBox(height: WidthValues.spacingXxs),
                  Text(
                    option.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorValues.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
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
            // The row's size, not the catalogue's: `SettingsChoices` declares
            // which icon, each layout declares how big.
            IconTheme.merge(
              data: IconThemeData(
                size: 20,
                color: isSelected
                    ? ColorValues.fgBrandPrimary(context)
                    : ColorValues.textTertiary(context),
              ),
              child: option.leading!,
            ),
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
