import 'package:flutter/material.dart';

enum CustomRefreshIndicatorType {
  classic,
  adaptive,
  noSpinner;
}

class CustomRefreshIndicator extends StatelessWidget {
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
      return RefreshIndicator.noSpinner(
        onRefresh: onRefresh,
        child: child,
      );
    }
    if (indicatorType == CustomRefreshIndicatorType.adaptive) {
      return RefreshIndicator.adaptive(
        color: Colors.blueAccent,
        onRefresh: onRefresh,
        child: child,
      );
    }
    return RefreshIndicator(
      color: Colors.blueAccent,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
