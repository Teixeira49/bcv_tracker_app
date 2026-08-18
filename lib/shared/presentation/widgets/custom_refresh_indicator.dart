import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:flutter/material.dart';

/// Which pull-to-refresh affordance [CustomRefreshIndicator] draws.
enum CustomRefreshIndicatorType {
  /// Material's own spinner.
  classic,

  /// The platform's spinner — Material on Android, Cupertino on iOS.
  adaptive,

  /// No spinner at all: the gesture still refreshes, but the screen shows its own
  /// loading state instead. Used where a shimmer is already saying it.
  noSpinner,
}

/// Pull-to-refresh in one place, with a choice of affordance.
///
/// Wraps the platform indicators so [indicatorType] is the only decision a screen
/// makes, and so `onRefresh` has one signature across the app.
class CustomRefreshIndicator extends StatelessWidget {
  /// Wraps [child] in a refresh gesture that calls `onRefresh`.
  const CustomRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.indicatorType = CustomRefreshIndicatorType.classic,
    super.key,
  });

  factory CustomRefreshIndicator.adaptive({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return CustomRefreshIndicator(
      indicatorType: CustomRefreshIndicatorType.adaptive,
      onRefresh: onRefresh,
      child: child,
    );
  }

  factory CustomRefreshIndicator.noSpinner({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return CustomRefreshIndicator(
      indicatorType: CustomRefreshIndicatorType.noSpinner,
      onRefresh: onRefresh,
      child: child,
    );
  }

  final Future<void> Function() onRefresh;
  final Widget child;
  final CustomRefreshIndicatorType indicatorType;

  @override
  Widget build(BuildContext context) {
    if (indicatorType == CustomRefreshIndicatorType.noSpinner) {
      return RefreshIndicator.noSpinner(onRefresh: onRefresh, child: child);
    }
    if (indicatorType == CustomRefreshIndicatorType.adaptive) {
      return RefreshIndicator.adaptive(
        color: ColorValues.textBrandTitle(context),
        backgroundColor: ColorValues.bgPrimary(context),
        onRefresh: onRefresh,
        child: child,
      );
    }
    return RefreshIndicator(
      color: ColorValues.textBrandTitle(context),
      backgroundColor: ColorValues.bgPrimary(context),
      onRefresh: onRefresh,
      child: child,
    );
  }
}
