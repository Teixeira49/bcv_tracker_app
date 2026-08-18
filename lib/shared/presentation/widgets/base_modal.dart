import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/theme/colors/colors_values.dart';

/// A centred dialog in the app's dressing.
///
/// The **centred** half of the modal story: use this for a short, self-contained
/// choice like Settings, and `BaseBottomSheet` for anything that scrolls or that
/// belongs to something the user tapped. `DESIGN.md` states which applies where.
/// Opened through `showBlurredDialog`, never `Get.dialog` by hand, and closed
/// with `Get.back()`.
class BaseModal extends StatelessWidget {
  /// Builds the dialog around [child].
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
          onPressed: () => Get.back<void>(),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(padding: internalMargin, child: child),
          ],
        ),
      ),
    ),
  );
}
