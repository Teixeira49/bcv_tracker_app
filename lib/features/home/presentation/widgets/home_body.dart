part of '../page/home_page.dart';

class _HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      GetBuilder<DollarBCVController>(
        builder: (controllerBCV) =>
            GetBuilder<CurrentDollarController>(
              builder: (controllerCurrent) =>
                  BaseLayout(
                    appBar: _RoundedHomeAppBarWidget(),
                    margins: EdgeInsets.all(16),
                    child: CustomRefreshIndicator.adaptive(
                      onRefresh: () async {
                        controllerBCV.getCurrentDollar();
                        controllerCurrent.getCurrentDollar();
                      },
                      child: ListView(
                        children: [
                          SizedBox(height: 100),
                          _CurrentDollarCard(),
                          SizedBox(height: 4),
                          _BCVDollarCard(),
                        ],
                      ),
                    ),
                  ),),
      );
}
