import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../config/theme/colors/colors_values.dart';

class CustomSkeletonizer extends StatelessWidget {
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
    child: Skeleton.leaf(
      child: child,
    )
  );
}
