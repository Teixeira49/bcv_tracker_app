import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../dashboard/presentation/page/dashboard_page.dart';
import '../../../../config/theme/icons.dart';
import '../../../../core/constants/constants.dart';

part '../widgets/splash_body.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: Constants.splashDuration), () {
      Get.offAll(
        () => DashboardPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _SplashBody(),
      );
}
