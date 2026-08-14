import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:bcv_tracker_app/config/theme/icons/icons_constants.dart';
import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The splash's logo (#10).
///
/// A golden would not help here: the CI goldens obscure text as blocks, so the
/// very thing that was broken — a stretched bitmap versus crisp artwork — is
/// exactly what they cannot show. These assert the decisions instead.
Future<SvgPicture> _pumpSplash(WidgetTester tester, Size screen) async {
  Get.testMode = true;
  await tester.pumpWidget(
    GetMaterialApp(
      // Destino de pega: el splash navega a `/home` al vencer su temporizador,
      // y montar la Home real traería sus controladores a un test que va del
      // logo. Lo que importa es que la ruta exista para que el timer drene.
      getPages: <GetPage<void>>[
        GetPage<void>(name: AppRoutes.home, page: () => const SizedBox()),
      ],
      home: MediaQuery(
        data: MediaQueryData(size: screen),
        child: SizedBox(
          width: screen.width,
          height: screen.height,
          child: const SplashPage(),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  return tester.widget<SvgPicture>(find.byType(SvgPicture));
}

/// `SplashPage` schedules the jump to home in `initState`; letting it run keeps
/// the binding from complaining about a pending timer at teardown.
Future<void> _drainSplashTimer(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: Constants.splashDuration));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('draws the brand logo, not the old raster one', (tester) async {
    final SvgPicture logo = await _pumpSplash(tester, const Size(360, 720));

    // The previous asset wrapped a 613x407 bitmap, which is what looked blurry
    // stretched across the screen.
    expect(AppIcons.mainLogo, 'assets/brand/dt_logo.svg');
    expect(logo.bytesLoader, isA<SvgAssetLoader>());
    expect((logo.bytesLoader as SvgAssetLoader).assetName, AppIcons.mainLogo);

    await _drainSplashTimer(tester);
  });

  testWidgets('paints it white, because the artwork is black', (tester) async {
    final SvgPicture logo = await _pumpSplash(tester, const Size(360, 720));

    // Without the filter the logo disappears into its own dark gradient.
    expect(
      logo.colorFilter,
      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );

    await _drainSplashTimer(tester);
  });

  testWidgets('sizes to the screen on a phone', (tester) async {
    final SvgPicture logo = await _pumpSplash(tester, const Size(360, 720));

    expect(logo.width, 360 * 0.8);

    await _drainSplashTimer(tester);
  });

  testWidgets('and stops growing on a tablet', (tester) async {
    final SvgPicture logo = await _pumpSplash(tester, const Size(820, 1180));

    // 80% of 820 would be 656: big enough to eat the screen, and past the
    // resolution of the bitmap the SVG still carries inside.
    expect(logo.width, lessThan(820 * 0.8));
    expect(logo.width, 420);

    await _drainSplashTimer(tester);
  });
}
