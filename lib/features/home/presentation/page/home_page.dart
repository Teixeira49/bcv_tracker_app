import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/performance_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/currency_helpers.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../../../../shared/presentation/widgets/app_state_view.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../../../../shared/presentation/widgets/custom_badged.dart';
import '../../../../shared/presentation/widgets/custom_refresh_indicator.dart';
import '../../../../shared/presentation/widgets/custom_skeletonizer.dart';
import '../../../currency_detail/presentation/page/show_currency_detail_sheet.dart';
import '../controller/home_controller.dart';

part '../widgets/home_body.dart';

part '../widgets/home_tab_bar.dart';

part '../widgets/home_widgets.dart';

/// The rate list, in two tabs: the parallel average and the official BCV rates.
///
/// The app's landing screen. Which tab opens first is the user's saved preference
/// (`SettingsController.favMarketIndex`), and tapping a card opens the detail sheet
/// with a **snapshot** of that rate — this list already holds the freshest copy the
/// app has, so the sheet does not re-fetch.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BaseLayout(
    title: AppMessages.homeView,
    margins: const EdgeInsets.all(16),
    child: _HomeBody(),
  );
}
