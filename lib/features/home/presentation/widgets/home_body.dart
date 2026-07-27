part of '../page/home_page.dart';

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();
    int startIndex = settingsController.favMarketIndex.value;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: startIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HomeTabBar(
      tabController: _tabController,
      tabs: [AppMessages.averageSection, AppMessages.officialSection],
      pages: [_HomeBodyAverageCurrency(), _HomeBodyBCVCurrency()],
    );
  }
}

class _HomeBodyAverageCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) {
      final String? error = controller.errorMessage;
      // While the first refresh has not succeeded the list still holds the
      // skeleton placeholders, so showing them once loading stopped would pass
      // fake rates off as real ones.
      final bool showCurrencies = controller.hasAverageData || error == null;

      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshHomeData();
        },
        child: ListView(
          // Keeps pull-to-refresh usable when the list is too short to scroll,
          // which is exactly the case in the error state.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (error != null) ...[
              _ErrorAdvisorCard(message: error),
              SizedBox(height: 8),
            ],
            if (showCurrencies) ...[
              _CurrencyDollarAverageCard(),
              for (var e in controller.averageCurrencies) ...[
                SizedBox(height: 8),
                _DollarCurrencyCard(currency: e),
              ],
            ],
            SizedBox(height: 48),
          ],
        ),
      );
    },
  );
}

class _HomeBodyBCVCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    builder: (controller) {
      final String? error = controller.errorMessage;
      final bool showCurrencies = controller.hasBcvData || error == null;

      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshHomeData();
        },
        child: ListView(
          // Keeps pull-to-refresh usable when the list is too short to scroll,
          // which is exactly the case in the error state.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (error != null) ...[
              _ErrorAdvisorCard(message: error),
              SizedBox(height: 8),
            ],
            if (showCurrencies) ...[
              _BCVAdvisorCard(),
              SizedBox(height: 16),
              ...controller.bcvCurrencies.map(
                (e) => _BCVDollarCard(currency: e),
              ),
            ],
          ],
        ),
      );
    },
  );
}
