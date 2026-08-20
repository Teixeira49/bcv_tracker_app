import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../config/routes/routes.dart';
import '../../../config/theme/colors/colors_values.dart';
import '../../../config/theme/icons/icons_constants.dart';
import '../../../core/i18n/app_messages.dart';

/// The branded frame every top-level screen sits in.
///
/// Draws the dark strip with the logo, the title and the settings button, and
/// hosts [child] underneath. Screens compose this rather than each building their
/// own `Scaffold`, which is what keeps the strip identical between Home and the
/// converter.
///
/// It measures against its own **box**, not the screen. That is not incidental:
/// against `MediaQuery` the title kept its absolute offset while the body shrank
/// under the keyboard, and ended up clipped behind the panel.
///
/// ### The strip on a pushed screen
///
/// Since [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37) the frame
/// also serves screens that are **stacked over** the dashboard rather than
/// hosted by it — settings and its three choice sub-screens. Those pass
/// [showBackButton] and [showSettingsAction], and the strip is otherwise
/// identical: a pushed screen that dropped the gradient and the wave would read
/// as a different app, which is exactly what the settings dialog used to avoid
/// by being a dialog.
class BaseLayout extends StatelessWidget {
  /// Content below the branded strip. Null renders the frame alone, which is what
  /// the splash and the error page want.
  final Widget? child;

  /// Heading inside the strip. Must come from `AppMessages`
  /// (`.agents/rules/i18n-convention.md`).
  final String? title;

  /// Insets applied to [child], so each screen decides its own gutter without
  /// touching the frame.
  final EdgeInsetsGeometry margins;

  /// Replaces the brand mark with a back arrow that pops the route.
  ///
  /// The two are exclusive on purpose: the logo is what says "you are in the
  /// app", and a pushed screen has to say "you are one level down" instead.
  /// Showing both crowds a strip that also carries the title in ten languages.
  final bool showBackButton;

  /// Whether the strip offers the gear that opens settings.
  ///
  /// `false` on the settings screens themselves — an action that navigates to
  /// where you already are is a dead control, and on the sub-screens it would
  /// stack a second copy of the menu over the first.
  final bool showSettingsAction;

  /// Wraps [child] in the branded frame.
  const BaseLayout({
    super.key,
    this.child,
    required this.margins,
    this.title,
    this.showBackButton = false,
    this.showSettingsAction = true,
  });

  /// Where the title sits inside the branded strip, as a share of the height.
  /// Roughly centred in the strip `_BaseBody` reserves for it.
  static const double _titleTopShare = 0.045;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      // Same reason as `_BaseBody`: measured against the screen, the title kept
      // its absolute offset while the body shrank under the keyboard, and ended
      // up clipped behind the panel. Against the box it scales with it.
      final double height = constraints.hasBoundedHeight
          ? constraints.maxHeight
          : MediaQuery.of(context).size.height;
      return _buildFrame(context, height);
    },
  );

  Widget _buildFrame(BuildContext context, double height) => Stack(
    children: [
      if (child != null) _BaseBody(margins: margins, child: child!),
      Positioned(
        top: height * _titleTopShare,
        left: 16,
        right: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            if (showBackButton)
              IconButton(
                onPressed: Get.back<void>,
                tooltip: AppMessages.backAction,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: ColorValues.textWhite70(context),
                ),
              )
            else
              SvgPicture.asset(
                AppIcons.onlyLogo,
                colorFilter: ColorFilter.mode(
                  ColorValues.textWhite70(context),
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
            // `Expanded`, and it is doing two jobs at once — which is why it is
            // not a bare `Text` and not a `Flexible` either.
            //
            // Bounding it is what keeps a long title wrapping instead of
            // pushing the action off the row: "Configuración" is one of the
            // shortest headings this strip carries, and the Russian and German
            // settings sub-screens are far longer (`i18n-convention.md`, rule
            // 6).
            //
            // Taking **all** the leftover width is what keeps the action flush
            // right. A `Flexible` with a `Spacer` after it looked equivalent and
            // was not: `Row` splits the free space by flex factor *before* a
            // loose child decides how much of its share it wants, and what it
            // declines does not go back to the `Spacer` — it lands as slack at
            // the end of the row, dragging the gear inward. One tight child and
            // no `Spacer` leaves nothing to strand.
            Expanded(
              child: Text(
                title ?? Constants.appTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorValues.textWhite70(context),
                ),
              ),
            ),
            if (showSettingsAction)
              IconButton(
                // A route since #37, not a dialog: the menu grows with the
                // settings still queued, and a screen is where they fit.
                onPressed: () => Get.toNamed<void>(AppRoutes.settings),
                tooltip: AppMessages.settingsView,
                icon: Icon(
                  Icons.settings,
                  color: ColorValues.textWhite70(context),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _BaseBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margins;

  const _BaseBody({required this.child, required this.margins});

  /// Share of the height taken by the branded strip behind the title.
  static const double _headerShare = 0.10;

  /// Share taken by the rounded panel that holds the page.
  static const double _panelShare = 0.90;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      // Sized from the box this is given, **not** from `MediaQuery.size`.
      //
      // The two shares add up to the full height, so measuring the screen made
      // the column as tall as the device no matter how much room it actually
      // had. `DashboardPage`'s `Scaffold` resizes its body when the keyboard
      // opens, so on the converter — the only page with a field — the layout
      // overflowed by exactly the height of the keyboard, striped bar and all.
      // Reading the constraints makes the page shrink with the body instead,
      // and the scroll view inside brings the focused field into view.
      final Size size = Size(
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width,
        constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height,
      );

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorValues.utilityMidNight(context),
              ColorValues.utilityBrand500(context),
            ],
          ),
        ),
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(height: size.height * _headerShare),
            Container(
              height: size.height * _panelShare,
              width: size.width,
              decoration: BoxDecoration(
                color: ColorValues.bgPrimary(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                alignment: AlignmentGeometry.topCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _RoundedBaseBodyWidget(),
                  ),
                  Padding(padding: margins, child: child),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _RoundedBaseBodyClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Esto determina qué tan altas y bajas son las curvas
    const double waveHeight = 50.0;

    // para que la ola tenga espacio para subir.
    path.moveTo(0, waveHeight);

    // El punto de control (x1, y1) está hacia arriba (0) para jalar la curva.
    path.quadraticBezierTo(
      size.width * 0.25,
      0, // Punto de control (1/4 del ancho, pegado al techo)
      size.width * 0.5,
      waveHeight, // Punto final de esta curva (centro)
    );

    // El punto de control está hacia abajo (waveHeight * 2) para jalar la curva.
    path.quadraticBezierTo(
      size.width * 0.75,
      waveHeight * 2,
      // Punto de control (3/4 del ancho, hacia abajo)
      size.width,
      waveHeight, // Punto final (borde derecho)
    );

    path.lineTo(size.width, size.height); // Línea recta hacia abajo-derecha
    path.lineTo(0, size.height); // Línea recta hacia abajo-izquierda

    path.close();

    return path;
  }

  @override
  bool shouldReclip(_RoundedBaseBodyClipPath oldClipper) => oldClipper != this;
}

class _RoundedBaseBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _RoundedBaseBodyClipPath(),
    child: Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorValues.bgCurveInit(context),
            ColorValues.bgCurveEnd(context),
          ],
        ),
      ),
    ),
  );
}
