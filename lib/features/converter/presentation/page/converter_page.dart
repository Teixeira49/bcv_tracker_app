import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/helpers/amount_input_formatter.dart';
import '../../../../core/helpers/currency_helpers.dart';
import '../../../../core/helpers/search_text.dart';
import '../../../../shared/domain/entities/currency.dart';
// import '../../../../shared/presentation/controller/currency_controller.dart';
import '../../../../shared/presentation/widgets/app_state_view.dart';
import '../../../../shared/presentation/widgets/base_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../../../../shared/presentation/widgets/custom_refresh_indicator.dart';
import '../../../../shared/presentation/widgets/custom_skeletonizer.dart';
import '../../domain/entities/convertible_currency.dart';
import '../controller/converter_controller.dart';

part '../widget/converter_body.dart';
part '../widget/converter_buttons.dart';
part '../widget/converter_modals.dart';
part '../widget/converter_widgets.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) => BaseLayout(
    title: AppMessages.converterView,
    margins: const EdgeInsets.all(16),
    child: _ConverterBody(),
  );
}
