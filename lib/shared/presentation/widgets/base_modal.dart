import 'package:flutter/material.dart';

import '../../../config/theme/colors/colors_values.dart';

class BaseModal extends StatelessWidget {
  const BaseModal({
    super.key,
    required this.title,
    this.externalMargin = const EdgeInsets.all(0),
    this.internalMargin = const EdgeInsets.only(
      right: 20,
      left: 20,
      top: 6,
      bottom: 16,
    ),
    required this.child,
    this.maxWidth,
    this.maxHeight,
  });

  final String title;
  final EdgeInsets externalMargin;
  final EdgeInsets internalMargin;
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    contentPadding: externalMargin,
    backgroundColor: ColorValues.bgPrimaryAlter(context),
    elevation: 16,
    shadowColor: ColorValues.utilityBrand500(context),
    content: SizedBox(
      width: maxWidth ?? double.infinity,
      height: maxHeight,
      child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Padding(padding: internalMargin, child: child),
        ],
      ),
    ),
        )
  );
}
