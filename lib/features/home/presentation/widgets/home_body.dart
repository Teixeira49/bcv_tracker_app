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
  Widget build(BuildContext context) => GetBuilder<CurrencyController>(
    builder: (controller) => CustomRefreshIndicator.adaptive(
      onRefresh: () async {
        //controllerBCV.getCurrentDollar();
        //controllerCurrent.getCurrentDollar();
      },
      child: ListView(
        children: [
          _CurrencyDollarAverageCard(),
          for (var e in controller.averageCurrencies) ...[
            SizedBox(height: 8),
            _DollarCurrencyCard(currency: e),
          ],
        ],
      ),
    ),
  );
}

class _HomeBodyBCVCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<CurrencyController>(
    builder: (controller) => CustomRefreshIndicator.adaptive(
      onRefresh: () async {
        //controllerBCV.getCurrentDollar();
        //controllerCurrent.getCurrentDollar();
      },
      child: ListView(
        children: [
          _BCVAdvisorCard(),
          SizedBox(height: 16),
          ...controller.bcvCurrencies.map((e) => _BCVDollarCard(currency: e)),
        ],
      ),
    ),
  );
}
