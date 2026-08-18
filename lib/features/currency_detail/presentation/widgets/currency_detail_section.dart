import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';

/// A titled block of the currency detail sheet.
///
/// Deliberately **public and standalone** (not a `part` of
/// `currency_detail_sheet.dart`): the sheet is designed to grow with sections
/// that do not exist yet — the chart (#5), the actions (#7) and the dedicated
/// converter (#39). Each of those arrives in its own file and composes this
/// shell, so every section keeps the same title, card and rhythm without
/// copying the decoration around.
///
/// It renders a box, not a sliver. Wrap it in a `SliverToBoxAdapter` to place
/// it in the sheet's `CustomScrollView`.
class CurrencyDetailSection extends StatelessWidget {
  const CurrencyDetailSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  /// Section heading. Must come from `AppMessages` (see `i18n-convention.md`).
  final String title;

  /// Body of the section, laid out inside the card.
  final Widget child;

  /// Optional control aligned to the end of the heading row (a "see more", a
  /// range selector for the chart). Kept out of the card so it reads as a
  /// control of the section, not as content.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      WidthValues.spacingMd,
      WidthValues.spacingXs,
      WidthValues.spacingMd,
      WidthValues.spacingXs,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.textTertiary(context),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: WidthValues.spacingXs),
        Card(
          margin: EdgeInsets.zero,
          color: ColorValues.utilityBrand50(context),
          child: Padding(
            padding: EdgeInsets.all(WidthValues.spacingMd),
            child: child,
          ),
        ),
      ],
    ),
  );
}

/// One `label → value` line inside a [CurrencyDetailSection].
///
/// Both sides are `Expanded` on purpose: German and Russian labels are far
/// longer than the Spanish ones this was laid out with, and a fixed-width label
/// would overflow there (see `i18n-convention.md`, rule 6). With the flex split
/// each side wraps instead.
class CurrencyDetailFactRow extends StatelessWidget {
  const CurrencyDetailFactRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  final String label;

  /// Already formatted for display. Formatting belongs to `CurrencyHelpers` or
  /// to the controller, never to this widget.
  final String value;

  /// Overrides the value colour, for facts that carry a semantic tone (a
  /// negative variation, an expired date).
  final Color? valueColor;

  /// Skips the trailing separator, so the last row of a card does not draw a
  /// divider against its own padding.
  final bool isLast;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: ColorValues.textTertiary(context),
              ),
            ),
          ),
          SizedBox(width: WidthValues.spacingXs),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? ColorValues.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
      if (!isLast)
        Padding(
          padding: EdgeInsets.symmetric(vertical: WidthValues.spacingXxs),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ColorValues.borderPrimary(context),
          ),
        ),
    ],
  );
}
