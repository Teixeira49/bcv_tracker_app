import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:flutter/material.dart';

import 'custom_badged.dart';

/// The signed percentage badge on a rate — an arrow, a figure and a colour.
///
/// Only rendered when the source actually reported a change: a rate whose
/// `tendency` is `null` shows **no badge at all**, because `0%` reads as "the rate
/// held" and that is a claim the source did not make. Callers decide; this widget
/// takes a non-null [value].
///
/// Guarded by a golden test in light and dark, since the three states are colour
/// decisions.
class PerformanceIndicatorWidget extends StatelessWidget {
  /// The change to show, as a percentage. Zero renders the neutral state, which is
  /// a real answer — not the same as an absent one.
  final double value;

  /// Shows [value] as a badge.
  const PerformanceIndicatorWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) => CustomBadged(
    color: selectValueBadged(context),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        _PerformanceArrow(value: value),
        Text(
          '${value.toStringAsFixed(4)}%',
          style: TextStyle(color: selectValueColor(context)),
        ),
      ],
    ),
  );

  Color selectValueBadged(BuildContext context) {
    if (value == 0) {
      return ColorValues.borderWarningSolid(context);
    }
    return value > 0
        ? ColorValues.borderSuccessSolid(context)
        : ColorValues.borderErrorSolid(context);
  }

  Color selectValueColor(BuildContext context) {
    if (value == 0) {
      return ColorValues.textWarningPrimary(context);
    }
    return value > 0
        ? ColorValues.fgSuccessPrimary(context)
        : ColorValues.textErrorPrimary(context);
  }
}

class _PerformanceArrow extends StatelessWidget {
  final double value;

  const _PerformanceArrow({required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return Icon(
        Icons.remove,
        color: ColorValues.textWarningPrimary(context),
        size: 16,
      );
    }

    return Icon(
      value > 0 ? Icons.arrow_upward : Icons.arrow_downward,
      color: value > 0
          ? ColorValues.fgSuccessPrimary(context)
          : ColorValues.textErrorPrimary(context),
      size: 16,
    );
  }
}
