part of '../page/converter_page.dart';

class _ConverterBody extends StatelessWidget {
  const _ConverterBody();

  @override
  Widget build(BuildContext context) => GetBuilder<ConverterController>(
    builder: (controller) {
      final String? error = controller.errorMessage;

      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshConverterData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // The same failure the Home shows: when the rates could not be loaded
          // there is nothing to convert with, so the error state replaces the
          // inputs (and offers a retry) instead of showing an empty converter.
          child: error != null
              ? AppStateView.error(
                  message: error,
                  onRetry: controller.refreshConverterData,
                  isBusy: controller.isLoading,
                )
              // The swap button is a **child of the column**, between the two
              // cards, rather than centred in a `Stack` around them.
              //
              // Centred in a stack it sat on the middle of the whole column,
              // which is the seam between the cards only while both are the
              // same height — a coincidence, not a rule. The output card grows
              // whenever its amount wraps to a second line or the
              // "no rate" warning appears, and the button drifted down with it.
              //
              // It takes no `SizedBox` around it: its own 56 px are the gap,
              // so the circle meets both cards and cannot come loose from the
              // seam whatever they measure.
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: WidthValues.spacingMd),
                    _CurrencyInputCard(currency: controller.fromCurrency),
                    _SwapCurrencyButton(),
                    _CurrencyInputCard(
                      currency: controller.toCurrency,
                      isInput: false,
                    ),
                    SizedBox(height: WidthValues.spacingMd),
                  ],
                ),
        ),
      );
    },
  );
}
