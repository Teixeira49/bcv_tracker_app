part of '../page/home_page.dart';

class _DollarCurrencyCard extends StatelessWidget {
  const _DollarCurrencyCard({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) => CustomSkeletonizer(
      isLoading: controller.isLoading,
      child: Card(
        color: ColorValues.utilityBrand50(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: ColorValues.borderTertiary(context),
                backgroundImage: currency.imgUrl == null
                    ? null
                    : NetworkImage(currency.imgUrl!),
                child: currency.imgUrl == null
                    ? Text(
                        currency.keyName.substring(0, 2),
                        style: TextStyle(
                          color: ColorValues.textPrimary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                currency.platform,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                CurrencyHelpers.castCurrencyDisplayName(currency),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: PerformanceIndicatorWidget(
                value: currency.tendency ?? 0,
              ),
            ),
            ListTile(
              title: Text(
                AppMessages.currencyValue,
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelpers.castCurrency(value: currency.value),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  Text(
                    CurrencyHelpers.completeCurrencyExchange(currency.keyName),
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(indent: 16, endIndent: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppMessages.lastUpdate),
                  Text(
                    currency.updateDate != null
                        ? CurrencyHelpers.formatDate(date: currency.updateDate!)
                        : CurrencyHelpers.emptyDatePlaceholder,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

class _BCVDollarCard extends StatelessWidget {
  const _BCVDollarCard({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final currencyCountry = CurrencyHelpers.castCurrencyCountry(
      currencyCode: currency.keyName,
    );
    return GetBuilder<HomeController>(
      builder: (controller) => CustomSkeletonizer(
        isLoading: controller.isLoading,
        child: Card(
          color: ColorValues.utilityBrand50(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorValues.borderTertiary(context),
                    child: ClipOval(
                      child: SvgPicture.asset(
                        currencyCountry.countryFlag,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    currencyCountry.currencyCountryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SvgPicture.asset(
                    currencyCountry.currencySymbol,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      ColorValues.textPrimary(context),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Divider(indent: 16, endIndent: 16),
                ListTile(
                  title: Text(
                    AppMessages.moneyValue,
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyHelpers.castCurrency(value: currency.value),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        CurrencyHelpers.completeCurrencyExchange(
                          currency.keyName,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the last refresh failed, with the detail reported by the backend
/// error envelope and a way to retry.
class _ErrorAdvisorCard extends StatelessWidget {
  const _ErrorAdvisorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) => CustomBadged(
      borderRadius: 12,
      color: ColorValues.textErrorPrimary(context),
      hMargin: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppMessages.loadingError,
                    style: TextStyle(
                      color: ColorValues.textErrorPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorValues.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: controller.isLoading
                  ? null
                  : controller.refreshHomeData,
              child: Text(
                AppMessages.retryAction,
                style: TextStyle(color: ColorValues.textErrorPrimary(context)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BCVAdvisorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) => CustomSkeletonizer(
      isLoading: controller.isLoading,
      color: ColorValues.utilityInfo(context).withAlpha(51),
      highlightColor: ColorValues.utilityInfo(context).withAlpha(145),
      child: CustomBadged(
        borderRadius: 12,
        color: ColorValues.utilityInfo(context),
        hMargin: 3,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppMessages.currencyDate,
                style: TextStyle(
                  color: ColorValues.textBrandTitle(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyHelpers.parseDate(date: controller.bcvCurrentDate),
                style: TextStyle(color: ColorValues.textBrandTitle(context)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CurrencyDollarAverageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) => CustomSkeletonizer(
      isLoading: controller.isLoading,
      color: ColorValues.utilityInfo(context).withAlpha(51),
      highlightColor: ColorValues.utilityInfo(context).withAlpha(145),
      child: CustomBadged(
        borderRadius: 12,
        color: ColorValues.utilityInfo(context),
        hMargin: 3,
        child: Padding(
          padding: EdgeInsets.only(right: 4, top: 8, left: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppMessages.averageValue,
                    style: TextStyle(
                      color: ColorValues.textBrandTitle(context),
                    ),
                  ),
                  Text(
                    'Bs.S ${CurrencyHelpers.getAverageValue(currencies: controller.averageCurrencies).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: ColorValues.textBrandTitle(context),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.settings),
                color: ColorValues.textBrandTitle(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
