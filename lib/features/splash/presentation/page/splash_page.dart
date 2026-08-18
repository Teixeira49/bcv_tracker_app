import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/icons/icons_constants.dart';
import '../../../../core/constants/constants.dart';

part '../widgets/splash_body.dart';

/// The first Flutter screen: the brand, then Home.
///
/// It is the **second** of three screens on launch, not the first — the OS paints a
/// native one before Flutter draws anything, and matching the two is what
/// [#102](https://github.com/Teixeira49/bcv_tracker_app/issues/102) did.
///
/// Waits `Constants.splashDuration` and then `Get.offAllNamed(AppRoutes.home)`,
/// clearing the stack so back does not return here. The fade belongs to the home
/// route, not to this call. The wait also has to outlast the entry animation in
/// `_SplashBody` (2200 ms): shortening one means shortening both.
///
/// It no longer covers anything functional. Until
/// [#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59) it accidentally
/// hid the window in which the saved theme and language had not loaded yet; those
/// are now awaited before the first frame, so this is a welcome screen and nothing
/// more.
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
