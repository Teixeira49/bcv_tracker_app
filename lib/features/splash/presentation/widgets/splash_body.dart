part of '../page/splash_page.dart';

/// El splash: el icono entra solo y, al aparecer el wordmark debajo, sube.
///
/// **El wordmark ocupa su sitio desde el principio, invisible.** La primera
/// versión abría el hueco con un `SizeTransition`, que recorta a su hijo: el
/// texto se veía cortado por la mitad mientras crecía, como si estuviera roto.
/// Reservando el espacio y desplazando la columna entera, el texto solo aparece
/// —nunca se recorta— y el icono sube exactamente la mitad del bloque de texto,
/// que es lo que hace falta para que empiece centrado en pantalla.
class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  /// Termina holgadamente antes de que [Constants.splashDuration] navegue a
  /// Home; si algún día se acorta esa espera, esto tiene que caber dentro.
  static const Duration _duration = Duration(milliseconds: 2200);

  /// Ancho del icono como fracción de la pantalla, y su tope.
  ///
  /// Menor que el del logo completo que había antes: aquí el icono es solo una
  /// parte del conjunto. El tope hace lo mismo que hacía allí — en una tablet
  /// evita que crezca por encima de la resolución del bitmap que el SVG lleva
  /// dentro (#10).
  static const double _iconFraction = 0.42;
  static const double _iconMaxWidth = 240;

  /// El wordmark es más ancho que el icono, como en el logo completo.
  static const double _wordmarkToIcon = 1.5;

  /// Separación entre el icono y el texto, en unidades de ancho de icono.
  static const double _gapToIcon = 0.14;

  /// Proporción del wordmark, tomada del `viewBox` de `dt_wordmark.svg`
  /// (14642×1516). Se necesita para saber cuánto alto ocupa el texto y, con
  /// ello, cuánto tiene que subir el icono. Si se regenera el asset con otro
  /// texto, este número cambia — lo dice el propio archivo.
  static const double _wordmarkAspect = 14642 / 1516;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  late final Animation<double> _iconFade = _curve(0, 0.40, Curves.easeOut);
  late final Animation<double> _iconScale = Tween<double>(
    begin: 0.82,
    end: 1,
  ).animate(_curve(0, 0.50, Curves.easeOutBack));

  /// Sube el conjunto hasta su sitio definitivo. Antes de esto, la columna va
  /// desplazada hacia abajo para que el icono quede centrado él solo.
  late final Animation<double> _rise = _curve(0.50, 0.90, Curves.easeOutCubic);
  late final Animation<double> _wordmarkFade = _curve(0.58, 1, Curves.easeOut);

  Animation<double> _curve(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double icon = math.min(
      MediaQuery.of(context).size.width * _iconFraction,
      _iconMaxWidth,
    );
    // El arte viene negro y el fondo es azul oscuro: sin esto desaparecería
    // contra su propio degradado.
    final ColorFilter white = ColorFilter.mode(
      ColorValues.textWhite(context),
      BlendMode.srcIn,
    );

    final double wordmarkWidth = icon * _wordmarkToIcon;
    // Alto del bloque que el texto reserva desde el primer fotograma. La
    // columna arranca desplazada hacia abajo justo la mitad, de modo que el
    // icono empieza centrado en pantalla aunque el hueco ya esté ahí.
    final double textBlock =
        icon * _gapToIcon + wordmarkWidth / _wordmarkAspect;

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
      child: AnimatedBuilder(
        animation: _rise,
        builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: Offset(0, textBlock / 2 * (1 - _rise.value)),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _iconFade,
              child: ScaleTransition(
                scale: _iconScale,
                child: SvgPicture.asset(
                  AppIcons.brandIcon,
                  width: icon,
                  height: icon,
                  fit: BoxFit.contain,
                  colorFilter: white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: icon * _gapToIcon),
              child: FadeTransition(
                opacity: _wordmarkFade,
                child: SvgPicture.asset(
                  AppIcons.brandWordmark,
                  width: wordmarkWidth,
                  fit: BoxFit.contain,
                  colorFilter: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
