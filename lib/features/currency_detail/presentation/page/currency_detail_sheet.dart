import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/helpers/currency_helpers.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/widgets/base_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/performance_indicator_widget.dart';
import '../widgets/currency_detail_section.dart';

part '../widgets/currency_detail_facts.dart';

part '../widgets/currency_detail_header.dart';

part '../widgets/currency_detail_slots.dart';

/// Detail view of a single rate, presented as a draggable bottom sheet.
///
/// It is a **modal, not a route**: it is opened with `showCurrencyDetailSheet`
/// and closed with `Get.back()`, the same shape the app uses for `SettingsModal`
/// and the converter's currency selector (see `navigation-convention.md`, rule
/// 6). The consequence, stated because #38 mentions it as a future use: the
/// sheet is **not addressable by a deep link** yet. Making it so means
/// registering a `GetPage` in `AppPages` whose page resolves the rate from a
/// route parameter and renders this same widget — nothing in here has to change
/// for that.
///
/// The rate is handed over by the card that opened it rather than fetched
/// again: the Home list already holds the freshest copy the app has, and a
/// second request would show a spinner over data the user is looking at.
///
/// ### Growing this view
///
/// [BaseBottomSheet] gives one scroll view driven by the drag controller, so
/// sections are added by appending a sliver — no nested scroll views, which is
/// what makes the drag and the scroll coexist. Three sections are already
/// placed and empty; see `currency_detail_slots.dart`.
class CurrencyDetailSheet extends StatelessWidget {
  const CurrencyDetailSheet({super.key, required this.currency});

  /// The rate to detail, as the card had it. A snapshot, not a live value.
  final Currency currency;

  /// Measured against the content #38 ships — header plus the seven detail
  /// rows — so the sheet opens showing all of it and no more. The sections
  /// still to come expand into the maximum extent instead, and anyone who
  /// enlarges the system font simply scrolls.
  static const double _initialExtent = 0.58;

  @override
  Widget build(BuildContext context) => BaseBottomSheet(
    semanticsLabel: AppMessages.currencyDetailTitle,
    initialExtent: _initialExtent,
    // Order follows #38: header, details, chart, actions, converter.
    slivers: <Widget>[
      SliverToBoxAdapter(child: _CurrencyDetailHeader(currency: currency)),
      SliverToBoxAdapter(child: _CurrencyDetailFacts(currency: currency)),
      CurrencyDetailChartSlot(currency: currency),
      CurrencyDetailActionsSlot(currency: currency),
      CurrencyDetailConverterSlot(currency: currency),
    ],
  );
}
