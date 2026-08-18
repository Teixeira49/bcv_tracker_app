# Marca — iconos y logos de la app

Los archivos originales de la identidad visual. **De aquí sale todo lo demás**:
los iconos de Android, iOS y web se *generan*, no se editan.

| Archivo | Qué es |
|---|---|
| `dt_icon.svg` | **El origen.** Icono: anillo + dólar, sin wordmark |
| `dt_icon.png` | El mismo icono compuesto, 1000×1000, blanco sobre `#08253A` |
| `dt_logo.svg` | Logo completo: icono + wordmark «DOLAR TRACKER» |
| `dt_logo.png` | El mismo logo compuesto, 1400×1400 |
| `app_icon.png` | **Generado.** 1024², compuesto — lo consume `flutter_launcher_icons` |
| `app_icon_foreground.png` | **Generado.** 1024², transparente — capa del icono adaptativo |
| `dt_wordmark.svg` | **Generado.** Solo «DOLAR TRACKER», con el viewBox ajustado a su caja |

Y fuera de esta carpeta, del mismo maestro: los `LaunchImage*.png` del arranque
de iOS (ver [La pantalla de arranque nativa](#la-pantalla-de-arranque-nativa-102)).

## Regenerar

Solo cuando cambie el arte, **y en este orden**:

```bash
flutter test tool/generate_app_icon.dart   # maestros + iconos web
dart run flutter_launcher_icons             # Android e iOS
```

El primero rasteriza `dt_icon.svg` a 1024 y escribe además `web/favicon.png` y
`web/icons/*`. El segundo deriva las densidades de Android e iOS.

**El paso web lo hace el script, no la herramienta.** `flutter_launcher_icons`
aborta su paso web porque este proyecto no tiene `web/index.html`, y de paso
dejaba `favicon.png` en 16×16; por eso está en `generate: false` en el
`pubspec.yaml`.

## Los SVG están aplanados a propósito

`flutter_svg` 2.x renderiza con `vector_graphics`, al que le faltan dos cosas
que traían los exports de diseño — y ninguna avisa, simplemente no dibuja:

| | Qué pasaba |
|---|---|
| `<text>` | «DOLAR TRACKER» salía como **dos barras negras sólidas**, una por palabra |
| `<use>` → `<image>` en `<defs>` | El anillo con el dólar **no se dibujaba** |

Los dos archivos ya vienen corregidos en el repo. Si diseño reexporta, hay que
volver a pasarlos por:

```bash
python3 tool/flatten_brand_svg.py assets/brand/dt_logo.svg
python3 tool/flatten_brand_svg.py assets/brand/dt_icon.svg
python3 tool/make_wordmark_svg.py                 # regenera dt_wordmark.svg
```

`dt_wordmark.svg` existe aparte porque **el splash anima el icono y el texto
por separado**: el icono entra solo y sube cuando el texto aparece debajo. Sale
de los contornos de la misma fuente, no de recortar el logo, así que el tipo es
idéntico en los dos archivos. Su `viewBox` va ajustado a la caja del texto, y el
splash usa esa proporción para saber cuánto tiene que subir el icono — si se
regenera con otro texto, ese número cambia.

El script convierte el `<text>` a trazados **leyendo los contornos reales de la
fuente** con `fonttools` —no los redibuja a mano, así que el wordmark es
exactamente Arial Narrow Bold— e incrusta la imagen en el sitio del `<use>`. Es
idempotente: pasarlo dos veces no hace nada la segunda.

Comprobar que un SVG está listo para Flutter:

```bash
grep -c '<text\|<use' assets/brand/dt_logo.svg   # 0 -> listo
```

## El techo de nitidez

Aplanarlos no los hace vectoriales del todo: el anillo con el dólar sigue
siendo un PNG incrustado.

| Archivo | Vectorial de verdad | Bitmap incrustado |
|---|---|---|
| `dt_icon.svg` | el anillo (3 trazados) | el dólar, **206×378** |
| `dt_logo.svg` | el wordmark (12 trazados) | anillo + dólar, **812×812** |

**Para el icono da igual**: a 1024 px el dólar se amplía un 1,02 %, que no se
ve. **Para el splash importa**: estirar 812 px hasta el ancho de un móvil a 3x
es ~3,2× de ampliación. Se ve aceptable, pero es el límite de estos archivos.

Lo que lo quitaría del todo es reexportar con el anillo y el dólar
**convertidos a trazados** (*Expand* / *Convert to Curves*). Eso además haría
viable un Lottie, que hoy no lo es: incrustar un bitmap en un Lottie es un GIF
caro, sin recoloreado ni animación de trazo.

## La pantalla de arranque nativa (#102)

Hay **tres** pantallas al abrir la app, no dos, y la primera no es de Flutter:

| # | Quién la pinta | Qué se ve |
|---|---|---|
| 1 | El sistema operativo, mientras arranca el proceso | `#08253A` plano + el icono |
| 2 | Flutter (`SplashPage`) | El degradado `#070E15 → #02466D`, icono y wordmark animados |
| 3 | Flutter (`DashboardPage`) | Home |

La 1 era **blanca** (la plantilla de `flutter create` sin tocar), y ese corte
blanco → azul es lo que hacía que el arranque pareciera dos apps encadenadas.

### Se mantienen a mano, no con `flutter_native_splash`

Decisión de #102, y **distinta** a la del icono, que sí se genera. `#08253A` no
cae en medio del degradado por casualidad: está entre sus dos extremos, así que
el paso de 1 a 2 es un escalón pequeño en vez de un corte; y como Android 12+
dibuja el icono adaptativo encima, el fondo del arranque tiene que ser el mismo
lienzo para el que se diseñó el icono. Son cinco archivos, ninguna dependencia
nueva, y cada uno lleva escrito en un comentario por qué dice lo que dice —
`flutter_native_splash` los sobrescribe y se lleva esos comentarios por delante.

| Archivo | Cubre |
|---|---|
| `android/…/res/values/brand_colors.xml` | `brand_launch_background`. Aparte de `colors.xml`, que lo escribe `flutter_launcher_icons` |
| `android/…/res/drawable/launch_background.xml` | API ≤20, y el **fallback** de 12+ |
| `android/…/res/drawable-v21/launch_background.xml` | API 21–30 |
| `android/…/res/values-v31/styles.xml` | Android 12+, modo claro |
| `android/…/res/values-night-v31/styles.xml` | Android 12+, modo **oscuro** |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | El color, declarado una sola vez |
| `ios/…/LaunchImage.imageset/LaunchImage{,@2x,@3x}.png` | **Generado**, transparente |

### Dos cosas que se creyeron y resultaron falsas

Medidas en un emulador API 36, poniendo un magenta en el drawable de ≤11 para
ver de dónde salía el color de verdad:

1. **«Android 12 ignora `windowBackground`.»** No: cuando
   `windowSplashScreenBackground` no está declarado, **cae en él**. Por eso el
   arranque salió magenta y no negro del sistema.
2. **`values-v31` no cubre el modo oscuro.** El calificador de modo noche va por
   delante de `vNN`, así que un dispositivo en oscuro resuelve `LaunchTheme`
   desde `values-night/` y se queda sin `windowSplashScreenBackground`. Sin
   `values-night-v31` el arranque en oscuro salió **magenta**; con él, navy. Es
   el archivo más fácil de no escribir de los cinco.

### El splash de Flutter se queda en 3 s

#102 dejaba abierto acortarlo ahora que la pantalla 1 ya no es un destello
ajeno. **No se acorta:** la animación de #10 dura 2200 ms y
`Constants.splashDuration` es lo que la deja terminar antes de navegar. Bajar de
~2,5 s la recortaría, y #10 acaba de dejarla como se quería. Si algún día se
acorta, hay que bajar también `_duration` en `splash_body.dart`.

## El color

`#08253A`, tomado del propio arte. **No pertenece a la paleta de `DESIGN.md`**,
que viste la interfaz; esta es la marca. Vive en tres sitios, y los tres tienen
que decir lo mismo:

| Dónde | Para qué |
|---|---|
| `adaptive_icon_background` en `pubspec.yaml` | El icono adaptativo de Android |
| `navy` en `tool/generate_app_icon.dart` | Componer los PNG maestros y los de web |
| `brand_launch_background` en `values/brand_colors.xml` | El arranque nativo de Android |
| `backgroundColor` en `LaunchScreen.storyboard` | El arranque nativo de iOS |

No están unificados porque son cuatro lenguajes distintos (YAML, Dart, XML de
recursos, XIB) y ninguno puede leer al otro. Si el navy cambia, cambian los
cuatro.
