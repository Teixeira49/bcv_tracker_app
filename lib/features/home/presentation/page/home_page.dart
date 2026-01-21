import 'package:bcv_tracker_app/shared/presentation/widgets/performance_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/helpers/currency_helpers.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../../../../shared/presentation/widgets/custom_badged.dart';
import '../../../../shared/presentation/widgets/custom_refresh_indicator.dart';
import '../controller/current_dollar_controller.dart';
import '../controller/dollar_bcv_controller.dart';

part '../widgets/home_body.dart';

part '../widgets/home_tab_bar.dart';

part '../widgets/home_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BaseLayout(
    title: "Home",
    margins: const EdgeInsets.all(16),
    child: _HomeBody(),
  );
}
