part of '../page/converter_page.dart';

class _SwapCurrencyButton extends StatelessWidget {
  const _SwapCurrencyButton();

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) => CustomSkeletonizer(
      isLoading: controller.isLoading,
      child: FloatingActionButton(
        onPressed: () => controller.swapCurrencies(),
        backgroundColor: ColorValues.utilityBrand500(context),
        foregroundColor: ColorValues.textWhite(context),
        elevation: 2,
        child: Icon(Icons.swap_vert, size: 36),
      ),
    ),
  );
}

class _SelectCurrencyButton extends StatelessWidget {
  const _SelectCurrencyButton({
    required this.currencyCode,
    required this.isInput,
  });

  final String currencyCode;
  final bool isInput;

  @override
  Widget build(BuildContext context) => Material(
    color: ColorValues.utilityBrand100(context),
    borderRadius: BorderRadius.circular(30),
    child: InkWell(
      onTap: () => showBlurredDialog<void>(
        context: context,
        builder: (context) => _CurrencySelectorDialog(isInput: isInput),
      ),
      hoverColor: ColorValues.utilityBrand800(context).withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _CircleCurrencyTypeWidget(currencyCode: currencyCode),
            const SizedBox(width: 10),
            Text(
              currencyCode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorValues.textBrandTitle(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: ColorValues.textBrandTitle(context),
              size: 22,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CurrencyTileButton extends StatelessWidget {
  const _CurrencyTileButton({required this.currency, required this.onTap});

  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) {
      bool isActive = isCurrencyActive(currency, controller);
      return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: isActive
            ? BoxDecoration(
                border: Border.all(
                  color: ColorValues.utilityInfo(context).withAlpha(120),
                  width: 1.0,
                ),
                color: ColorValues.utilityInfo(context).withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: ListTile(
          trailing: _getIcon(context, isActive),
          leading: _CircleCurrencyTypeWidget(currencyCode: currency.keyName),
          title: Text(
            '${CurrencyHelpers.castCurrencyDisplayCode(currency.keyName)} '
            '${CurrencyHelpers.castCurrencyDisplayName(currency)}',
          ),
          subtitle: Text(currency.platform),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
        ),
      );
    },
  );

  Icon? _getIcon(BuildContext context, bool isActive) => isActive
      ? Icon(
          Icons.check_circle,
          size: 22,
          color: ColorValues.utilityBrandSecondary500(context),
        )
      : null;

  bool isCurrencyActive(Currency currency, ConverterController controller) =>
      (currency.keyName == controller.fromCurrency.keyName &&
          controller.fromCurrency.platform == currency.platform) ||
      (currency.keyName == controller.toCurrency.keyName &&
          controller.toCurrency.platform == currency.platform);
}
