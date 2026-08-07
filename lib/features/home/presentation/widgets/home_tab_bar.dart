part of '../page/home_page.dart';

class _HomeTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final List<Widget> pages;

  const _HomeTabBar({
    required this.tabController,
    required this.tabs,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: ColorValues.utilityInfo(context).withAlpha(51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorValues.utilityInfo(context).withAlpha(170),
            width: 1,
          ),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: ColorValues.utilityBrand500(context),
            borderRadius: BorderRadius.circular(16),
          ),
          physics: AlwaysScrollableScrollPhysics(),
          labelColor: ColorValues.textWhite(context),
          controller: tabController,
          tabs: tabs.map((e) => _HomeTab(title: e)).toList(),
        ),
      ),
      Expanded(
        child: TabBarView(controller: tabController, children: pages),
      ),
    ],
  );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
