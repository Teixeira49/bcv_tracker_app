import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/widgets/base_bottom_sheet.dart';
import '../controller/currency_detail_controller.dart';
import 'currency_detail_sheet.dart';

/// Opens the detail of [currency] as a bottom sheet.
///
/// The single entry point of the feature: whoever wants to show a rate calls
/// this and does not touch `CurrencyDetailController`, `Get.bottomSheet` or the
/// sheet widget. Today that is the two Home cards; #38 leaves open whether the
/// converter offers it too, and adding it there is this one call.
///
/// A modal, not a named route, matching how the converter's currency selector
/// is presented — see the note on [CurrencyDetailSheet] about what that costs
/// for deep links. The route settings live in [showAppBottomSheet], shared with
/// every other sheet.
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

  return showAppBottomSheet<void>(
    context: context,
    // The rate comes from the controller, not captured here: a section added
    // later that updates it (a refresh landing while the sheet is open) must
    // repaint the sheet, and a captured value never would.
    sheet: GetBuilder<CurrencyDetailController>(
      builder: (CurrencyDetailController controller) => controller.hasCurrency
          ? CurrencyDetailSheet(currency: controller.currency!)
          : const SizedBox.shrink(),
    ),
  ).whenComplete(controller.dismiss);
}
