import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/features/home/presentation/page/home_page.dart';
import 'package:bcv_tracker_app/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../shared/presentation/widgets/custom_bottom_navigator_bar.dart';

/// The two tabs and the bar that switches them.
///
/// Uses an **`IndexedStack`**, so both pages stay mounted and each keeps its scroll
/// position, its text field and its controller state while the other is showing.
/// That is what makes leaving the converter and coming back to a half-finished
/// calculation work, and it is the reason tabs are not routes.
class DashboardPage extends GetView<NavigationController> {
  final List<Widget> pages = [const HomePage(), const ConverterPage()];

  final List<Map<String, dynamic>> pagesMap = [
    {'title': 'Home', 'icon': Icons.home_outlined, 'active_icon': Icons.home},
    {
      'title': 'Converter',
      'icon': Icons.calculate_outlined,
      'active_icon': Icons.calculate,
    },
  ];

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Obx(
      () =>
          IndexedStack(index: controller.selectedIndex.value, children: pages),
    ),
    backgroundColor: ColorValues.bgPrimary(context),
    extendBody: true,
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: CustomBottomNavigatorBar(
      navigationController: controller,
      pageButtons: pagesMap,
    ),
  );
}
