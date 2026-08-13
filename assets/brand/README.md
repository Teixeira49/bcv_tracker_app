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

## Dos cosas que no son obvias

### 1. Flutter no dibuja estos SVG tal cual

`flutter_svg` 2.x renderiza con `vector_graphics`, que **no resuelve un `<use>`
apuntando a un `<image>` dentro de `<defs>`** ni soporta `<text>`. Los dos SVG
nuevos usan ambas cosas, así que en Flutter:

| Archivo | Lo que Flutter pinta realmente |
|---|---|
| `dt_icon.svg` | El anillo, **sin el dólar** |
| `dt_logo.svg` | Dos barras negras y nada más |

Comprobarlo:

```bash
grep -c '<use' assets/brand/dt_logo.svg          # 1  -> el arte no se dibuja
grep -oE '<(path|text|image)' assets/brand/dt_icon.svg | sort | uniq -c
```

El generador lo esquiva reescribiendo el `<use>` como `<image>` en memoria (ver
`_inlineUsedImages` en `tool/generate_app_icon.dart`); el archivo en disco queda
como lo exportó diseño. **`logo_center.svg` y `logo_full.svg`, los antiguos, sí
funcionan** porque llevan `<image>` directo y ningún `<text>`.

### 2. Ninguno es vectorial del todo

Los cuatro incrustan un PNG en base64, así que tienen un techo de nitidez:

| Archivo | Vectorial de verdad | Bitmap incrustado |
|---|---|---|
| `dt_icon.svg` | el anillo (3 paths) | el dólar, **206×378** |
| `dt_logo.svg` | el wordmark (`<text>`) | anillo + dólar, **812×812** |

**Para el icono da igual**: a 1024 px el dólar se amplía un 1,02 %, que no se
ve. **Para el splash no**: estirar 812 px hasta el ancho de un móvil a 3x es
~3,2× de ampliación, y por eso el logo del splash sigue pendiente en
[#10](https://github.com/Teixeira49/bcv_tracker_app/issues/10).

Lo que lo desbloquea todo —splash nítido a cualquier tamaño, y un Lottie viable—
es reexportar con el anillo y el dólar **convertidos a trazados** (*Expand* /
*Convert to Curves* antes de exportar), y sin `<text>`.

## El color

`#08253A`, tomado del propio arte. **No pertenece a la paleta de `DESIGN.md`**,
que viste la interfaz; esta es la marca. Se declara una sola vez, en
`adaptive_icon_background` del `pubspec.yaml`, y el generador lo usa para
componer los PNG.
