import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../controller/currency_detail_controller.dart';
import 'currency_detail_sheet.dart';

/// Opens the detail of [currency] as a bottom sheet.
///
/// The single entry point of the feature: whoever wants to show a rate calls
/// this and does not touch `CurrencyDetailController`, `Get.bottomSheet` or the
/// sheet widget. Today that is the two Home cards; #38 leaves open whether the
/// converter offers it too, and adding it there is this one call.
///
/// `Get.bottomSheet` rather than a named route, matching how `SettingsModal`
/// and the converter's currency selector are already presented — see the note
/// on [CurrencyDetailSheet] about what that costs for deep links.
///
/// Two settings carry the behaviour #38 asks for:
///
/// - `isScrollControlled: true` lets the sheet be taller than the Material
///   default of half the screen, which is what makes room for the sections
///   still to come.
/// - `enableDrag: false` hands **all** dragging to the `DraggableScrollableSheet`
///   inside. The route's own drag gesture and the sheet's would otherwise both
///   claim the same vertical swipe, and the sheet would jump or close while the
///   user was scrolling its content.
///
/// The list behind keeps its scroll position because this stacks a route over
/// the Home instead of rebuilding it.
Future<void> showCurrencyDetailSheet({
  required BuildContext context,
  required Currency currency,
}) {
  final CurrencyDetailController controller =
      Get.find<CurrencyDetailController>();
  controller.open(currency);

  return Get.bottomSheet<void>(
    // The rate comes from the controller, not captured here: a section added
    // later that updates it (a refresh landing while the sheet is open) must
    // repaint the sheet, and a captured value never would.
    GetBuilder<CurrencyDetailController>(
      builder: (CurrencyDetailController controller) => controller.hasCurrency
          ? CurrencyDetailSheet(currency: controller.currency!)
          : const SizedBox.shrink(),
    ),
    isScrollControlled: true,
    enableDrag: false,
    // The sheet paints its own rounded, bordered surface; a background here
    // would draw a square one behind it.
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: ColorValues.textBlack(context).withAlpha(120),
  ).whenComplete(controller.dismiss);
}
