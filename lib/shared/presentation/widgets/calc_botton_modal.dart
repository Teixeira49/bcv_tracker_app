import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../controller/calc_controller.dart';

class CalcBottomModal extends StatelessWidget {
  CalcBottomModal({super.key, required this.currencies}) {
    final CalcController controller = Get.put(
      CalcController(),
      permanent: false,
    );
    controller.initializeWithCurrencies(currencies);
  }

  final List<Currency> currencies;

  static Future<void> show(
    BuildContext context, {
    required CalcBottomModal dialog,
  }) async {
    await showModalBottomSheet(context: context, builder: (context) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final CalcController controller = Get.find<CalcController>();

    print("ITEMS: ${controller.getAvailableCurrencies}");
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(controller.getChangeOrder()),
                  Switch(
                    value: controller.getCalcVes,
                    onChanged: controller.toggleValue,
                    activeColor: Color(0xFF02466D),
                    focusColor: Color(0xff070e15),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Valor",
                        suffixText: controller.getCalculateResult(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: controller.getCalcCurrency,
                      items: controller.getAvailableCurrencies
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.keyName,
                              child: Text(e.keyName),
                            ),
                          )
                          .toList(),
                      onChanged: controller.setCalcCurrency,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                controller.getCalculateResult(),
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
