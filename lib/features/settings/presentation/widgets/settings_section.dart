import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';

/// A titled group of settings entries.
///
/// Deliberately **public and standalone**, the same shape as
/// `CurrencyDetailSection`: the menu exists to be added to — notifications
/// ([#13](https://github.com/Teixeira49/bcv_tracker_app/issues/13)),
/// accessibility (#33), analytics consent (#34), about — and each of those
/// arrives as an entry inside one of these, not as another hand-built column.
/// That is the acceptance criterion #37 states as "adding a setting is adding
/// an entry, without redesigning the screen".
///
/// It renders a box, not a sliver. The menu places it in a `ListView`.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// Group heading. Must come from `AppMessages` (see `i18n-convention.md`).
  final String title;

  /// The entries of the group, usually [SettingsMenuTile]s.
  ///
  /// A separator is drawn **between** them by this widget rather than by each
  /// entry: an entry does not know whether it is the last one, and the card it
  /// sits in should not end on a divider against its own padding.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: WidthValues.spacingMd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: WidthValues.spacingXs,
            bottom: WidthValues.spacingXs,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorValues.textTertiary(context),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          color: ColorValues.utilityBrand50(context),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: WidthValues.spacingMd,
                    endIndent: WidthValues.spacingMd,
                    color: ColorValues.borderPrimary(context),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// One row of the settings menu: what the setting is, what it does, what it is
/// currently set to, and a tap that opens where it is chosen.
///
/// [value] is the criterion that the dialog #37 replaces could not meet — its
/// three selectors showed the current state only by which button looked
/// pressed, and the language dropdown by what it happened to display. A menu
/// answers "what is this set to?" without being opened.
class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.description,
  });

  /// Leading glyph, drawn in a tinted square so the rows scan as a list.
  final IconData icon;

  /// Name of the setting. From `AppMessages`.
  final String title;

  /// What the setting is set to **right now**, already resolved for display:
  /// the language's own name, the market's tab label, the theme's label. This
  /// widget formats nothing.
  final String value;

  /// One line saying what the setting decides. Optional, because an entry whose
  /// name already says it (a future "About") should not be padded with a
  /// restatement.
  final String? description;

  /// Opens the sub-screen where the choice is made.
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
          Container(
            padding: EdgeInsets.all(WidthValues.spacingXs),
            decoration: BoxDecoration(
              color: ColorValues.utilityBrandSecondary100(context),
              borderRadius: BorderRadius.circular(WidthValues.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ColorValues.fgBrandPrimary(context),
            ),
          ),
          SizedBox(width: WidthValues.spacingSm),
          // The flex split, rather than a fixed width, is what keeps the row
          // upright in German and Russian — both sides wrap instead of one
          // pushing the other out (`i18n-convention.md`, rule 6).
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.textPrimary(context),
                  ),
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: WidthValues.spacingXxs),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorValues.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: WidthValues.spacingXs),
          Flexible(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorValues.textBrandSecondary(context),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: ColorValues.textTertiary(context),
          ),
        ],
      ),
    ),
  );
}
