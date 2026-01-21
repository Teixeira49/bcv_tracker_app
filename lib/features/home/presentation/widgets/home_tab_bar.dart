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
          color: Color(0xFF1187CE).withAlpha(51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF1187CE).withAlpha(170), width: 1),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Color(0xFF02466D),
            borderRadius: BorderRadius.circular(16),
          ),
          physics: AlwaysScrollableScrollPhysics(),
          labelColor: Colors.white,
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
        children: [Text(title)],
      ),
    );
  }
}
