import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:flutter/material.dart';

import 'custom_badged.dart';

class PerformanceIndicatorWidget extends StatelessWidget {
  final double value;

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
