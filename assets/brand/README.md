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

## El color

`#08253A`, tomado del propio arte. **No pertenece a la paleta de `DESIGN.md`**,
que viste la interfaz; esta es la marca. Se declara una sola vez, en
`adaptive_icon_background` del `pubspec.yaml`, y el generador lo usa para
componer los PNG.
