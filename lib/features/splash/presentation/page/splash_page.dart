import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/icons/icons_constants.dart';
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
      // Clears the stack and lands on home. The fadeIn transition lives on the
      // home `GetPage` (see `AppPages`), not here.
      Get.offAllNamed<void>(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _SplashBody());
}
