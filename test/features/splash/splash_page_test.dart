import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:bcv_tracker_app/config/theme/icons/icons_constants.dart';
import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/features/splash/presentation/page/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The splash: the logo it draws (#10) and how it animates in.
///
/// A golden would not help here. The CI goldens obscure text as blocks, so the
/// thing that was broken — a stretched bitmap versus crisp artwork — is exactly
/// what they cannot show, and an animation has no single frame to pin.
Future<void> _pumpSplash(WidgetTester tester, Size screen) async {
  Get.testMode = true;
  // La ventana de test mide 800x600: envolver en un `MediaQuery` a mano decía
  // un tamaño y el layout usaba otro. Se cambia la vista de verdad.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = screen;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      // Destino de pega: el splash navega a `/home` al vencer su temporizador,
      // y montar la Home real traería sus controladores a un test que va del
      // logo. Lo que importa es que la ruta exista para que el timer drene.
      getPages: <GetPage<void>>[
        GetPage<void>(name: AppRoutes.home, page: () => const SizedBox()),
      ],
      home: const SplashPage(),
    ),
  );
  await tester.pump();
}

/// The `SvgPicture` drawing [asset].
SvgPicture _picture(WidgetTester tester, String asset) => tester
    .widgetList<SvgPicture>(find.byType(SvgPicture))
    .firstWhere(
      (SvgPicture p) => (p.bytesLoader as SvgAssetLoader).assetName == asset,
    );

Rect _rect(WidgetTester tester, String asset) =>
    tester.getRect(find.byWidget(_picture(tester, asset)));

/// Runs the entrance out, then the navigation timer, so the binding does not
/// complain about either still being pending at teardown.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2400));
  await tester.pump(const Duration(seconds: Constants.splashDuration));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('draws the brand icon and wordmark, not the old raster logo', (
    tester,
  ) async {
    await _pumpSplash(tester, const Size(360, 720));

    // The logo the splash used to draw wrapped a 613×407 bitmap, which is what
    // looked blurry stretched across the screen. These two are flattened
    // vector art — see `assets/brand/README.md`.
    expect(AppIcons.brandIcon, 'assets/brand/dt_icon.svg');
    expect(AppIcons.brandWordmark, 'assets/brand/dt_wordmark.svg');
    expect(find.byType(SvgPicture), findsNWidgets(2));

    await _settle(tester);
  });

  testWidgets('paints both white, because the artwork is black', (
    tester,
  ) async {
    await _pumpSplash(tester, const Size(360, 720));

    // Without the filter the logo disappears into its own dark gradient.
    const ColorFilter white = ColorFilter.mode(Colors.white, BlendMode.srcIn);
    expect(_picture(tester, AppIcons.brandIcon).colorFilter, white);
    expect(_picture(tester, AppIcons.brandWordmark).colorFilter, white);

    await _settle(tester);
  });

  testWidgets('the icon sizes to the screen, and stops growing on a tablet', (
    tester,
  ) async {
    await _pumpSplash(tester, const Size(360, 720));
    expect(_picture(tester, AppIcons.brandIcon).width, 360 * 0.42);
    await _settle(tester);

    await _pumpSplash(tester, const Size(820, 1180));
    // 42 % of 820 would be 344: past the resolution of the bitmap the SVG
    // still carries inside, which is what #10 is about.
    expect(_picture(tester, AppIcons.brandIcon).width, 240);
    await _settle(tester);
  });

  testWidgets('the wordmark starts invisible and ends visible', (tester) async {
    await _pumpSplash(tester, const Size(360, 720));

    // `FadeTransition` no monta un widget `Opacity`: su opacidad vive en la
    // animación, así que se lee de ahí.
    double fadeOf(String asset) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byWidget(_picture(tester, asset)),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    expect(fadeOf(AppIcons.brandWordmark), 0);

    await tester.pump(const Duration(milliseconds: 2400));
    expect(fadeOf(AppIcons.brandWordmark), 1);

    await tester.pump(const Duration(seconds: Constants.splashDuration));
    await tester.pump();
  });

  testWidgets('the icon starts centred alone and rises as the text arrives', (
    tester,
  ) async {
    const Size screen = Size(360, 720);
    await _pumpSplash(tester, screen);

    // Alone on screen, the icon is centred: the wordmark already occupies its
    // slot, so the column is offset down by half of it to compensate.
    final Rect start = _rect(tester, AppIcons.brandIcon);
    expect(start.center.dy, moreOrLessEquals(screen.height / 2, epsilon: 1));

    await tester.pump(const Duration(milliseconds: 2400));

    // ...and then it moves up to make room for the text, which is the whole
    // point of the entrance.
    final Rect end = _rect(tester, AppIcons.brandIcon);
    expect(end.center.dy, lessThan(start.center.dy));
    // It rises exactly half the text block, no more: what ends up centred is
    // the pair, icon and wordmark together.
    final Rect word = _rect(tester, AppIcons.brandWordmark);
    expect(
      (end.top + word.bottom) / 2,
      moreOrLessEquals(screen.height / 2, epsilon: 2),
    );

    await tester.pump(const Duration(seconds: Constants.splashDuration));
    await tester.pump();
  });
}
