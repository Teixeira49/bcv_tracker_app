import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/i18n/app_messages.dart';

/// A bounded whole-number setting, adjusted one step at a time.
///
/// The third shape a setting can take on this screen, after the list of rows
/// and the grid of cards: neither fits a range of nine values where the user
/// wants "one more", not "the seventh one". Written generically — [min], [max]
/// and [value] — so the next bounded number is a page, not another control.
///
/// **The buttons go dead at the ends rather than disappearing.** A control that
/// vanishes at the limit makes the user hunt for what changed; one that greys
/// out says "this is as far as it goes", which is the actual answer. `null` on
/// `onPressed` is also what makes `IconButton` report itself as disabled to
/// assistive tech, so the two agree.
class SettingsCounter extends StatelessWidget {
  const SettingsCounter({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  /// The number as it currently stands.
  final int value;

  /// Lowest and highest value the counter offers, both inclusive.
  final int min;
  final int max;

  /// Reports the new value. Never called with anything outside [min]..[max] —
  /// the buttons are disabled at the ends — but the setter it reaches clamps
  /// anyway, because this is not the only caller it will ever have.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: ColorValues.utilityBrand50(context),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: WidthValues.spacingMd,
        vertical: WidthValues.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _CounterButton(
            icon: Icons.remove_rounded,
            tooltip: AppMessages.decreaseAction,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          // The number is the point of the screen, so it gets the size the
          // converter's own result would get (`DESIGN.md` → titleLarge).
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ColorValues.textPrimary(context),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            tooltip: AppMessages.increaseAction,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    ),
  );
}

/// One end of a [SettingsCounter].
class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;

  /// `null` disables the button, which is how the counter says it has reached
  /// an end.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: isEnabled
            ? ColorValues.utilityBrandSecondary100(context)
            : ColorValues.bgDisabled(context),
        foregroundColor: isEnabled
            ? ColorValues.fgBrandPrimary(context)
            : ColorValues.fgDisabled(context),
      ),
    );
  }
}
