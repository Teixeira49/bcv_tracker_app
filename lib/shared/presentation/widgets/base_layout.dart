import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/show_blurred_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/colors/colors_values.dart';
import '../../../config/theme/icons/icons_constants.dart';
import '../../../features/settings/presentation/page/settings_modal.dart';

class BaseLayout extends StatelessWidget {
  final Widget? child;
  final String? title;
  final EdgeInsetsGeometry margins;

  const BaseLayout({super.key, this.child, required this.margins, this.title});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (child != null) _BaseBody(margins: margins, child: child!),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.045,
        left: 16,
        right: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            SvgPicture.asset(
              AppIcons.onlyLogo,
              colorFilter: ColorFilter.mode(
                ColorValues.textWhite70(context),
                BlendMode.srcIn,
              ),
              height: 24,
            ),
            Text(
              title ?? Constants.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorValues.textWhite70(context),
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () => showBlurredDialog(
                context: context,
                builder: (context) => SettingsModal(),
              ),
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

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorValues.utilityMidNight(context),
          ColorValues.utilityBrand500(context),
        ],
      ),
    ),
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Column(
      children: [
        SizedBox.fromSize(size: MediaQuery.of(context).size * 0.10),
        Container(
          height: MediaQuery.of(context).size.height * 0.90,
          width: MediaQuery.of(context).size.width,
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
  bool shouldReclip(_RoundedBaseBodyClipPath oldClipper) =>
      oldClipper != this;
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
