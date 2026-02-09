part of '../page/converter_page.dart';

class _ConverterBody extends StatelessWidget {
  const _ConverterBody();

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) {
      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshConverterData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  _CurrencyInputCard(currency: controller.fromCurrency),
                  const SizedBox(height: 32),
                  _CurrencyInputCard(
                    currency: controller.toCurrency,
                    isInput: false,
                  ),
                  SizedBox(height: 16),
                ],
              ),
              _SwapCurrencyButton(),
            ],
          ),
        ),
      );
    },
  );
}
