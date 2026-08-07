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

      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshHomeData();
        },
        child: ListView(
          // Keeps pull-to-refresh usable when the list is too short to scroll,
          // which is exactly the case in the error state.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (error != null)
              AppStateView.error(
                message: error,
                onRetry: controller.refreshHomeData,
                isBusy: controller.isLoading,
              )
            else if (controller.hasAverageData &&
                controller.averageCurrencies.isEmpty)
              AppStateView.empty(onRetry: controller.refreshHomeData)
            else ...[
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

      return CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          await controller.refreshHomeData();
        },
        child: ListView(
          // Keeps pull-to-refresh usable when the list is too short to scroll,
          // which is exactly the case in the error state.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (error != null)
              AppStateView.error(
                message: error,
                onRetry: controller.refreshHomeData,
                isBusy: controller.isLoading,
              )
            else if (controller.hasBcvData && controller.bcvCurrencies.isEmpty)
              AppStateView.empty(onRetry: controller.refreshHomeData)
            else ...[
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
