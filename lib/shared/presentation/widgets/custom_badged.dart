import 'package:flutter/material.dart';

/// A rounded, coloured pill around [child].
///
/// The app's one badge shape. Used for the variation indicator and the rate-type
/// label, so those two cannot drift apart in radius or padding.
class CustomBadged extends StatelessWidget {
  /// Wraps [child] in a pill of [color].
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

/// [CustomBadged] that responds to a tap.
///
/// A separate class rather than a nullable `onTap` on [CustomBadged]: a pill that
/// might be tappable is a pill whose ink and semantics are conditional, and the
/// two read very differently to assistive tech.
class CustomBadgedButton extends StatelessWidget {
  /// Wraps [child] in a tappable pill of [color].
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
