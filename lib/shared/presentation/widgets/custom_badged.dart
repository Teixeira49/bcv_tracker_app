import 'package:flutter/material.dart';

class CustomBadged extends StatelessWidget {
  const CustomBadged({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 55,
    this.hMargin = 0,
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final double hMargin;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.symmetric(horizontal: hMargin),
    decoration: BoxDecoration(
      color: color.withAlpha(51),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withAlpha(170), width: 1),
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: child,
  );
}

class CustomBadgedButton extends StatelessWidget {
  const CustomBadgedButton({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 55,
    this.hMargin = 0,
    required this.onTap,
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final double hMargin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(borderRadius),
    onTap: onTap,
    child: CustomBadged(
      color: color,
      borderRadius: borderRadius,
      hMargin: hMargin,
      child: child,
    ),
  );
}
