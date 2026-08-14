part of '../page/splash_page.dart';

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  /// Ancho del logo como fracción de la pantalla, y su tope.
  ///
  /// La fracción es la que tenía el splash; el tope es nuevo y hace dos cosas a
  /// la vez. En una tablet, un logo de 640 px se comía la pantalla **y** era el
  /// tamaño al que más se notaba el bitmap que el SVG lleva dentro (#10):
  /// cuanto más grande se pinta, más se amplía. Con el tope se queda por debajo
  /// de su resolución nativa en cualquier dispositivo.
  static const double _widthFraction = 0.8;
  static const double _maxWidth = 420;

  @override
  Widget build(BuildContext context) {
    final double size = math.min(
      MediaQuery.of(context).size.width * _widthFraction,
      _maxWidth,
    );

    return Container(
      alignment: AlignmentGeometry.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorValues.utilityMidNight(context),
            ColorValues.utilityBrand500(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SvgPicture.asset(
        AppIcons.mainLogo,
        // `contain`, no `cover`: el logo es cuadrado y la caja también, así que
        // hoy dan lo mismo — pero `cover` recortaría el wordmark en cuanto una
        // de las dos deje de serlo.
        fit: BoxFit.contain,
        width: size,
        height: size,
        // El arte viene negro y el fondo es azul oscuro: sin esto el logo
        // desaparece contra su propio degradado.
        colorFilter: ColorFilter.mode(
          ColorValues.textWhite(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
