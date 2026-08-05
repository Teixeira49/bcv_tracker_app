part of '../page/converter_page.dart';

class _CurrencySelectorDialog extends StatelessWidget {
  const _CurrencySelectorDialog({required this.isInput});

  final bool isInput;

  @override
  Widget build(BuildContext context) => BaseModal(
    title: AppMessages.selectCurrency,
    maxHeight: MediaQuery.of(context).size.height * 0.5,
    child: _CurrencySelectorDialogBody(isInput: isInput),
  );
}

class _CurrencySelectorDialogBody extends StatelessWidget {
  const _CurrencySelectorDialogBody({required this.isInput});

  final bool isInput;

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CurrenciesCategoryTitleWidget(
            label: AppMessages.originalCurrency,
            includeDivider: false,
          ),
          SizedBox(height: 6),
          _CurrencyTileButton(
            currency: controller.pivotCurrency,
            onTap: () => changeCurrency(
              context: context,
              controller: controller,
              currency: controller.pivotCurrency,
              isInput: isInput,
            ),
          ),
          if (controller.currencies.isNotEmpty)
            _CurrenciesCategoryTitleWidget(label: AppMessages.mainMarkets),
          if (controller.currencies.isNotEmpty) SizedBox(height: 6),
          // Use the consolidated list
          ...controller.currencies.map(
            (e) => _CurrencyTileButton(
              currency: e,
              onTap: () => changeCurrency(
                context: context,
                controller: controller,
                currency: e,
                isInput: isInput,
              ),
            ),
          ),
        ],
      );
    },
  );

  void changeCurrency({
    required BuildContext context,
    required ConverterController controller,
    required Currency currency,
    required bool isInput,
  }) {
    bool? validator = controller.selectCurrency(currency, isInput: isInput);
    if (validator != null && validator) Get.back<void>();
  }
}
