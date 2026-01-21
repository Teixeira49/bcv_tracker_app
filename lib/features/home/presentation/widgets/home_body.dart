part of '../page/home_page.dart';

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DollarBCVController>(
      builder: (controllerBCV) => GetBuilder<CurrentDollarController>(
        builder: (controllerCurrent) => _HomeTabBar(
          tabController: _tabController,
          tabs: ["Promedio", "BCV"],
          pages: [_HomeBodyAverageCurrency(), _HomeBodyBCVCurrency()],
        ),
      ),
    );
  }
}

class _HomeBodyAverageCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<DollarBCVController>(
    builder: (controllerBCV) => GetBuilder<CurrentDollarController>(
      builder: (controllerCurrent) => CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          controllerBCV.getCurrentDollar();
          controllerCurrent.getCurrentDollar();
        },
        child: ListView(
          children: [
            _CurrencyDollarAverageCard(),
            SizedBox(height: 4),
            _DollarCurrencyCard(),
            SizedBox(height: 4),
            _DollarCurrencyCard(),
            SizedBox(height: 4),
            _DollarCurrencyCard(),
          ],
        ),
      ),
    ),
  );
}

class _HomeBodyBCVCurrency extends StatelessWidget {
  final tempList = [
    {'value': 344.49, 'code': 'USD'},
    {'value': 344.49, 'code': 'EUR'},
    {'value': 344.49, 'code': 'TRY'},
    {'value': 344.49, 'code': 'CNY'},
    {'value': 344.49, 'code': 'RUB'},
  ];

  @override
  Widget build(BuildContext context) => GetBuilder<DollarBCVController>(
    builder: (controllerBCV) => GetBuilder<CurrentDollarController>(
      builder: (controllerCurrent) => CustomRefreshIndicator.adaptive(
        onRefresh: () async {
          controllerBCV.getCurrentDollar();
          controllerCurrent.getCurrentDollar();
        },
        child: ListView(
          children: [
            _BCVAdvisorCard(),
            SizedBox(height: 16),
            ...tempList.map(
              (e) => _BCVDollarCard(
                value: e['value'] as double,
                currencyCode: e['code'] as String,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
