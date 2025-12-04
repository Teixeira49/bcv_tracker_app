import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../../../../shared/presentation/widgets/calc_botton_modal.dart';
import '../../../../shared/presentation/widgets/custom_refresh_indicator.dart';
import '../controller/current_dollar_controller.dart';
import '../controller/dollar_bcv_controller.dart';

part '../widgets/home_body.dart';

part '../widgets/home_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<DollarBCVController>(
    builder: (controller) => Scaffold(
      appBar: AppBar(
        title: _HomeAppBarTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: _HomeBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF02466D),
        foregroundColor: Colors.white,
        onPressed: () async {
          if (controller.currentDollar.isNotEmpty) {
            CalcBottomModal.show(
              context,
              dialog: CalcBottomModal(currencies: controller.currentDollar),
            );
          }
        },
        child: Icon(Icons.calculate_outlined),
      ),
    ),
  );
}
