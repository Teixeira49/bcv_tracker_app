part of '../page/converter_page.dart';

class _CurrencyInputCard extends StatelessWidget {
  final ConvertibleCurrency currency;
  final bool isInput;

  const _CurrencyInputCard({required this.currency, this.isInput = true});

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) => CustomSkeletonizer(
      isLoading: controller.isLoading,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: ColorValues.utilityBrand50(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorValues.utilityInfo(context).withAlpha(100),
            width: 1.25,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorValues.utilityBrand50(context).withAlpha(50),
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurrencyInputSelectorCard(
              currency: currency.currency,
              isInput: isInput,
            ),
            const SizedBox(height: 24),
            _CurrencyInputFieldCard(
              currencyCode: currency.keyName,
              isInput: isInput,
              amount: currency.convertedValue.toString(),
            ),
            // A market with no rate yields 0.0 instead of a conversion, and a
            // bare 0 reads like a legitimate result. Only the output card says
            // so: repeating it on both sides is noise.
            if (!isInput && controller.isConversionUnavailable) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: ColorValues.textWarningPrimary(context),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppMessages.conversionUnavailable,
                      style: TextStyle(
                        color: ColorValues.textWarningPrimary(context),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _CurrencyInputSelectorCard extends StatelessWidget {
  const _CurrencyInputSelectorCard({
    required this.currency,
    required this.isInput,
  });

  final Currency currency;
  final bool isInput;

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 20,
      children: [
        _SelectCurrencyButton(currencyCode: currency.keyName, isInput: isInput),
        Flexible(
          child: Text(
            currency.keyName != 'VES'
                ? '${CurrencyHelpers.castCurrencyDisplayName(currency)} - ${currency.platform}'
                : controller.getRoundedCurrency(),
            style: TextStyle(
              color: ColorValues.textQuaternary(context),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

class _CurrencyInputFieldCard extends StatefulWidget {
  const _CurrencyInputFieldCard({
    required this.currencyCode,
    required this.isInput,
    required this.amount,
  });

  final String currencyCode;
  final bool isInput;
  final String amount;

  @override
  State<_CurrencyInputFieldCard> createState() =>
      _CurrencyInputFieldCardState();
}

class _CurrencyInputFieldCardState extends State<_CurrencyInputFieldCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.amount);
  }

  @override
  void didUpdateWidget(covariant _CurrencyInputFieldCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount != _controller.text) {
      final double newAmount = double.tryParse(widget.amount) ?? 0.0;
      final double currentTextValue =
          double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;

      // Only update if the values are actually different (e.g. from a swap or external change)
      // This prevents overwriting "10." with "10.0" while typing
      if ((newAmount - currentTextValue).abs() > 0.001) {
        // Check if it's 0.0 and text is empty, keep empty if desired?
        // But requirement says "conversion resets", so 0.0 is likely desired to show.
        // However, if we want to show "0" instead of "0.0" for integers:
        String textToSet = widget.amount;
        if (widget.amount.endsWith('.0')) {
          textToSet = widget.amount.substring(0, widget.amount.length - 2);
        }

        _controller.text = textToSet == '0' ? '' : textToSet;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) => Row(
      children: [
        Text(
          CurrencyHelpers.castCurrencySymbolText(
            currencyCode: widget.currencyCode,
          ),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: widget.isInput
              ? TextFormField(
                  controller: _controller,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 40,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '0',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  // The keyboard type is only a hint to the on-screen keyboard;
                  // a hardware one, a paste or a dictation would otherwise put
                  // letters here and the amount would silently become 0.
                  inputFormatters: const <TextInputFormatter>[
                    AmountInputFormatter(),
                  ],
                  onChanged: (value) {
                    //_controller.text = value;
                    if (value.isNotEmpty) {
                      controller.calculator(value);
                    }
                  },
                )
              : Text(
                  widget.amount,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 40,
                  ),
                ),
        ),
      ],
    ),
  );
}

class _CircleCurrencyTypeWidget extends StatelessWidget {
  const _CircleCurrencyTypeWidget({required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final currencyAsset = CurrencyHelpers.castCurrencySymbolIcon(
      currencyCode: currencyCode,
    );
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.white, //ColorValues.borderTertiary(context),
      child: currencyAsset != ''
          ? ClipOval(child: SvgPicture.asset(currencyAsset, fit: BoxFit.cover))
          : Text(
              currencyCode.substring(0, 2),
              style: TextStyle(
                color: ColorValues.textPrimary(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class _CurrenciesCategoryTitleWidget extends StatelessWidget {
  final String label;
  final bool includeDivider;

  const _CurrenciesCategoryTitleWidget({
    required this.label,
    this.includeDivider = true,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (includeDivider) const Divider(),
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ],
  );
}
