import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../config/theme/colors/colors_values.dart';

/// Shimmer placeholder in the brand's colours.
///
/// Wraps `skeletonizer` so the shimmer is one decision instead of a per-screen
/// choice of greys. Its input is a **real widget tree filled with placeholder
/// data** — `Currency.emptySkeletonizer`, not empty strings — because the shimmer
/// traces the shape of what is coming, and a blank field collapses to nothing.
class CustomSkeletonizer extends StatelessWidget {
  /// Shimmers [child] while [isLoading]; renders it untouched otherwise.
  const CustomSkeletonizer({
    super.key,
    required this.isLoading,
    this.color,
    this.highlightColor,
    required this.child,
  });

  final bool isLoading;
  final Color? color;
  final Color? highlightColor;
  final Widget child;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    enableSwitchAnimation: true,
    effect: ShimmerEffect(
      baseColor: color ?? ColorValues.utilityBrand50(context),
      highlightColor: highlightColor ?? ColorValues.utilityBrand100(context),
      duration: Duration(seconds: 2),
    ),
    child: Skeleton.leaf(child: child),
  );
}
