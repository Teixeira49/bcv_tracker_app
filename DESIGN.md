---
version: alpha
name: BCV Tracker
description: >-
  Sistema de diseño de una app financiera de consulta de tasas de cambio del
  BCV. Identidad seria y de confianza: azul profundo institucional, un acento
  ámbar para la acción, y un modo oscuro "midnight" de primera. Denso pero
  legible: el número —la tasa— es el protagonista de cada pantalla.
colors:
  primary: "#02466D"
  secondary: "#064469"
  accent: "#FFA726"
  neutral: "#808080"
  midnight: "#070E15"
  success: "#39E079"
  error: "#F44336"
  warning: "#FF9800"
  info: "#1187CE"
typography:
  displayLarge:
    fontFamily: Roboto
    fontSize: 40px
    fontWeight: 700
    lineHeight: 1.1
  headlineMedium:
    fontFamily: Roboto
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.2
  headlineSmall:
    fontFamily: Roboto
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.2
  titleLarge:
    fontFamily: Roboto
    fontSize: 22px
    fontWeight: 700
    lineHeight: 1.25
  titleMedium:
    fontFamily: Roboto
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  bodyLarge:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.4
  bodyMedium:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.4
  labelMedium:
    fontFamily: Roboto
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.3
  labelSmall:
    fontFamily: Roboto
    fontSize: 10px
    fontWeight: 500
    lineHeight: 1.3
rounded:
  none: 0px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 20px
  xl: 24px
  full: 9999px
spacing:
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
components:
  card:
    backgroundColor: "{colors.neutral}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  primaryButton:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.accent}"
    rounded: "{rounded.md}"
  bottomNav:
    backgroundColor: "{colors.midnight}"
    textColor: "{colors.accent}"
    rounded: "{rounded.md}"
  bottomSheet:
    backgroundColor: "{colors.neutral}"
    borderColor: "{colors.info}"
    rounded: "{rounded.xl}"
    padding: "{spacing.md}"
  settingsTile:
    backgroundColor: "{colors.neutral}"
    textColor: "{colors.secondary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  settingsChoiceCard:
    backgroundColor: "{colors.neutral}"
    borderColor: "{colors.primary}"
    textColor: "{colors.secondary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  settingsCounter:
    backgroundColor: "{colors.neutral}"
    textColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  aboutLinkRow:
    backgroundColor: "{colors.neutral}"
    textColor: "{colors.secondary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  errorState:
    textColor: "{colors.error}"
    rounded: "{rounded.sm}"
  emptyState:
    textColor: "{colors.warning}"
    rounded: "{rounded.sm}"
---

# BCV Tracker — Sistema de Diseño

> **Fuente de verdad de las decisiones visuales.** Los tokens del front matter son normativos; la implementación en Flutter vive en `lib/config/theme/` y debe coincidir con lo declarado aquí. Antes de construir UI nueva, lee este archivo; ver `.agents/rules/design-system.md`.

## Overview

BCV Tracker es una app de consulta financiera: alguien la abre para decidir cuánto cobra o cuánto paga. El diseño existe para que ese número —la tasa— se lea de un vistazo, con confianza y sin ruido.

- **Personalidad:** seria, institucional, precisa. Más cerca de una app bancaria que de una de consumo. Nada juguetón; nada que reste credibilidad al dato.
- **Audiencia:** venezolanos que siguen el dólar a diario, en condiciones de red variables. El diseño asume que el dato puede fallar o tardar, y trata los estados de error y vacío como parte del producto, no como una excepción fea.
- **Respuesta emocional:** calma y control. El azul profundo transmite estabilidad; el ámbar marca la acción sin gritar; el modo oscuro "midnight" hace la lectura nocturna cómoda.
- **Densidad:** media-alta. Se muestran varias tasas por pantalla, así que la jerarquía tipográfica y el espaciado del grid de 8 pt hacen el trabajo de separar sin encerrar cada dato en una caja.

## Colors

La paleta se ancla en un **azul profundo** de marca, un **acento ámbar** para la acción, y una base neutra gris para el modo claro y "midnight" para el oscuro. Los estados semánticos (éxito/error/aviso/info) completan el conjunto.

- **Primary (#02466D):** azul BCV profundo. Marca, texto de encabezado sobre claro, y fondo de acción.
- **Secondary (#064469):** azul complementario, un grado más apagado; superficies y bordes de marca.
- **Accent (#FFA726):** ámbar. El **único** color de acción destacada — icono activo del bottom bar, etiqueta del botón primario, aviso de estado vacío. Se usa con moderación; si todo es acento, nada lo es.
- **Neutral (#808080):** gris. Base de las superficies del modo claro, texto secundario, bordes y metadatos.
- **Midnight (#070E15):** casi negro azulado. Base de las superficies del modo oscuro.
- **Success (#39E079) / Error (#F44336) / Warning (#FF9800) / Info (#1187CE):** estados. `info` tiñe también los bordes y sombras sutiles de las tarjetas.

### Los cuatro modos — decisión

El schema de `colors` es un mapa plano *token → color*, pero esta app asigna hasta **cuatro variantes por token semántico**: `light`, `dark`, `onBrandLight`, `onBrandDark` (ver `_ColorScheme` en `lib/config/theme/colors/colors_values.dart`).

**Decisión:** el front matter declara la **paleta de marca** —los nueve colores fuente de arriba, agnósticos de modo, tomados literalmente de `lib/config/theme/colors/colors_constants.dart`—. La **asignación semántica por modo** (qué tono de la paleta pinta el fondo, el texto o el borde en claro vs. oscuro) es responsabilidad de `colors_values.dart` y se documenta aquí en prosa, **no** se duplica en el front matter. Por qué:

- El modo oscuro **no es una derivación** del claro: sus tonos están escogidos a mano (base `midnight`, no un `primary` oscurecido). Un esquema "claro normativo + derivación" mentiría sobre cómo se construye el oscuro.
- Sufijar cada token (`bgPrimaryLight`/`bgPrimaryDark`/…) multiplicaría por cuatro un inventario de ~50 tokens semánticos y volvería el archivo ilegible para lo que aporta.
- Con la paleta como normativa, el linter comprueba el contraste WCAG de los colores fuente, que es donde vive la identidad; la fidelidad de cada superficie se verifica contra `colors_values.dart` y, a futuro, con los golden tests de #35.

**Mapeo semántico (resumen; el detalle exacto está en `colors_values.dart`):**

| Rol | Modo claro | Modo oscuro |
|---|---|---|
| Fondo de página | `neutral` claro (grey.50/100) | `midnight` (700/800) |
| Superficie de tarjeta | blanco/grey muy claro | `midnight` un grado más claro |
| Texto primario | `primary` / casi negro | blanco / grey muy claro |
| Texto secundario | `neutral` (grey.600) | grey claro |
| Acción / marca (fg) | `primary` / `secondary` | tonos claros de `primary` |
| Bordes sutiles | `info` con alpha | `info` con alpha |
| Marca sobre superficie (`fgBrandMark`) | `primary` | blanco |

**Sobre `fgBrandMark`.** El arte de la marca es monocromo y quien lo pinta elige el color — así lo hace ya el splash con un `colorFilter`. Sobre las superficies **oscuras** de la app (la franja, el splash) el blanco es correcto; sobre una **clara** desaparece. «Acerca de» fue el primer sitio que puso el logo sobre la superficie clara y lo dejó al descubierto: blanco sobre blanco. El token invierte la tinta por modo en vez de fijar un color, que es lo que permite reutilizar el mismo asset en las dos.

En claro es **`primary` y no `midnight`**: el degradado de la franja va de `midnight` a `primary`, así que la marca sobre una superficie clara tiene que leerse como parte de esa misma familia. `midnight` contrasta igual de bien, pero sale casi negro — un color que la app no usa para nada propio.

## Typography

No hay fuente propia: se usa la **de plataforma** (Roboto en Android, San Francisco en iOS vía el fallback de Material). Los tokens fijan **Roboto** como referencia de la escala; el peso y el tamaño son lo normativo, no la familia.

La escala se derivó de los tamaños que hoy están dispersos por los widgets (nueve valores distintos, de 10 a 40 px). Roles:

- **displayLarge (40/700):** el monto del conversor. Es el número más grande de la app, y su tamaño es deliberado: el resultado de la conversión es el producto.
- **headlineMedium (28/700) / headlineSmall (24/700):** títulos de pantalla y de sección. `headlineSmall` es el título de `BaseLayout`.
- **titleLarge (22/700):** título de modal (`BaseModal`).
- **titleMedium (20/600):** subtítulos y encabezados de tarjeta.
- **bodyLarge (16/400) / bodyMedium (14/400):** el cuerpo. `bodyMedium` es el tamaño de trabajo de la mayoría de las etiquetas y valores.
- **labelMedium (12/500) / labelSmall (10/500):** metadatos, fechas, pies de tarjeta.

> Estos tokens **aún no se consumen** desde el código (hay 25 `fontSize:` a mano). Adoptarlos —crear un `textTheme` y migrar los widgets— es trabajo de #44, no de esta issue.

## Layout

El proyecto usa un **grid de 8 pt** (`_WidthConstants._gridSystem = 8`): todo espaciado es múltiplo de 8. La escala de `spacing` declara el subconjunto de uso común; la escala completa (hasta 480 px) vive en `lib/config/theme/width/`.

- **xs (8) / sm (12) / md (16):** gaps entre elementos y padding interno. `md` (16) es el padding de tarjeta por defecto.
- **lg (24) / xl (32):** separación entre bloques y padding de contenedores amplios.

Regla: si un valor de espaciado no está en la escala, la pregunta es si el diseño debería usar uno que sí. `WidthValues` ya declara la escala; los `EdgeInsets` con números sueltos son deuda que #44 migra.

## Elevation & Depth

La app es **plana con profundidad sutil**, no material pesado. La jerarquía se logra con color y borde antes que con sombra.

- **Tarjetas:** borde de 1–1.25 px teñido con `info` a baja opacidad, más una sombra muy suave del mismo tono. La separación viene del borde, no de una sombra marcada.
- **Modales y diálogos:** se elevan sobre un fondo difuminado (`BackdropFilter`) en vez de una sombra dura — el foco se logra desenfocando lo de atrás.
- **Bottom bar:** flota sobre el contenido con `BackdropFilter` y un borde `info`, no con una barra opaca anclada.

No hay una escala numérica de elevación (`z-1`…`z-5`): la profundidad es cualitativa y se describe por componente.

## Shapes

Esquinas redondeadas, coherentes con la escala `rounded` (grid de 8 pt):

- **md (16):** el radio por defecto. Tarjetas, botones grandes, el contenedor del tab bar y la mayoría de las superficies usan `BorderRadius.circular(16)`.
- **sm (12) / xs (8):** elementos más pequeños y avisos de estado.
- **lg (20) / xl (24):** superficies amplias cuando se busca un gesto más suave.
- **full (9999):** elementos circulares — avatares de divisa, indicadores.

Nada de esquinas vivas (`none`/0) salvo divisores. La redondez es parte del tono "cuidado" de la app.

## Components

Los tokens de `components` fijan las relaciones color→rol de los componentes recurrentes; el layout exacto vive en el widget.

- **card:** fondo neutro, acento `info` en el borde, radio `md`. Es la unidad base: cada tasa, cada sección, es una tarjeta.
- **primaryButton:** fondo `primary`, etiqueta `accent`. La acción principal.
- **bottomNav:** tinte `info`, icono activo `accent`. Es un componente **propio** (`CustomBottomNavigatorBar`), no un `BottomNavigationBar`/`NavigationBar` de Material — decisión que #44 debe confirmar al migrar a M3.
- **bottomSheet:** panel que sube desde el borde inferior, arrastrable. Radio `xl` (24) —mayor que el `md` de las tarjetas, porque es una superficie amplia y el gesto pide una esquina más suave—, borde `info` de 1.25 px y un halo suave del mismo tono, la misma profundidad por borde que el resto. Lleva una barra fija con el asa y el botón de cerrar, **sin texto**: su alto es fijo y no podría crecer con la escala tipográfica del sistema. Implementado en `shared/presentation/widgets/base_bottom_sheet.dart` y usado por el detalle de moneda (#38) y el selector del conversor (#40).

  **Cuándo hoja inferior y cuándo diálogo:** una hoja inferior para contenido que se recorre —una lista, una ficha con secciones— porque queda al alcance del pulgar y aprovecha la altura; un diálogo centrado (`BaseModal`) para una decisión corta que interrumpe. El selector de divisas era lo primero dentro de lo segundo, y por eso cambió en #40.

  **Y cuándo ninguna de las dos.** Los ajustes eran un diálogo hasta #37. Lo que los sacó de ahí no fue el alcance del pulgar sino el techo: un diálogo no crece, y lo que se recorre *y* se agrupa *y* tiene que admitir opciones nuevas —notificaciones, accesibilidad, consentimiento, «acerca de»— ya no es un modal de ningún tipo, es una pantalla con su ruta. La pregunta a hacerse antes de elegir contenedor: ¿esto va a listar más cosas dentro de seis meses? Si la respuesta es sí, empieza por la pantalla.

- **settingsTile:** la fila del menú de ajustes (#37). Tarjeta neutra de radio `md` agrupada por sección, icono de marca en un cuadro teñido a la izquierda, título y una línea de descripción, y **el valor actual en `secondary` alineado a la derecha** — ese valor es el componente: un menú que no dice a qué está puesta cada opción obliga a entrar en las tres para saberlo. La misma tarjeta, sin icono ni descripción y con una marca de verificación, es la fila de las subpantallas de elección.
- **settingsChoiceCard:** la opción como **tarjeta en rejilla de dos columnas**, no como fila (#37). Icono arriba, etiqueta debajo, ambos centrados; la seleccionada se remarca con borde de marca de 2 px, fondo teñido y la etiqueta en `secondary` y en negrita.

  **Cuándo rejilla y cuándo lista**, que es la decisión real: rejilla cuando las opciones son **pocas y cada una tiene un icono que la distingue de un vistazo** —el tema: claro, oscuro, sistema—, porque ahí el icono hace el trabajo que haría leer la etiqueta y dos columnas ponen las tres a la vista sin desplazar. Lista cuando son **muchas o se leen** —los diez idiomas—, donde una rejilla obliga a barrer en zigzag lo que se lee mejor en columna. Con un número impar la última celda queda vacía a propósito: mantener el tamaño de celda es lo que hace que se lea como rejilla y no como botones sueltos de anchos distintos.

  El borde de 2 px, y no solo el color, es deliberado: el estado seleccionado no puede depender únicamente del tono (ver *Do's and Don'ts*), y el grosor se percibe en escala de grises. Para lectores de pantalla la selección viaja además en `Semantics(selected:)`, que es lo que ningún píxel comunica.
- **settingsCounter:** la tercera forma que toma un ajuste, para un **número acotado** (#37, incremental). Tarjeta neutra de radio `md` con dos botones tonales en los extremos y la cifra al centro en `titleLarge` — el número es el contenido de la pantalla, así que recibe el tamaño que recibiría el resultado del conversor.

  **Cuándo contador y cuándo lista:** contador cuando el valor es un número dentro de un rango y el usuario piensa en «uno más», no en «el séptimo» — nueve valores en una lista serían nueve filas idénticas salvo por un dígito. Lista o rejilla cuando las opciones son cosas distintas entre sí, no puntos de una escala.

  **En los extremos los botones se apagan, no desaparecen.** Un control que se va obliga a buscar qué cambió; uno atenuado dice «hasta aquí llega», que es la respuesta real. Además `onPressed: null` es lo que hace que `IconButton` se anuncie como deshabilitado a las tecnologías de asistencia, así que lo que se ve y lo que se lee coinciden.

  Bajo el contador va un **ejemplo trabajado**: la misma cifra renderizada con el ajuste puesto. Un techo es abstracto —«siete decimales» no significa nada hasta ver una cifra con siete— y el ejemplo se calcula con el formateador real, no con uno escrito para la vista, para que no pueda prometer algo que el conversor no hará.
- **aboutLinkRow:** la fila que **sale de la app** (#42). Misma tarjeta y mismo ritmo que `settingsTile`, con una diferencia deliberada y única: termina en un icono de *abrir en nuevo* en vez de un chevron.

  Ese icono es todo el componente. Un chevron promete «profundizas en la app» y un enlace externo promete «te vas al navegador»; son afordancias distintas y la pantalla de «Acerca de» pone catorce de las segundas justo debajo del menú lleno de las primeras. Si las dos filas terminaran igual, el usuario descubriría la diferencia perdiendo el sitio.

  El valor a la derecha —el tipo de referencia del mercado, el nombre de la licencia— usa el mismo `secondary` que el valor actual de `settingsTile`, porque responde a la misma pregunta: qué es esto que estoy mirando.

- **errorState / emptyState:** acento `error` vs. `warning`, radio `sm`. Hoy son tarjetas mínimas (`_ErrorAdvisorCard`); #11 los rediseña como componentes compartidos con branding, e #18 define qué dice cada uno según la causa.

## Do's and Don'ts

**Do**

- Declara un token **aquí primero**, luego impleméntalo en `lib/config/theme/`. El orden importa: el diseño se decide en este archivo, no en un widget.
- Usa la escala de 8 pt para todo espaciado y radio. Si necesitas un valor fuera de la escala, revisa el diseño antes que la escala.
- Reserva `accent` (ámbar) para la acción. Un solo acento por pantalla.
- Verifica cada pantalla en **claro y oscuro**; el modo oscuro no es un detalle, es la mitad del producto.
- En texto que puede alargarse (alemán, ruso), usa `Flexible`/`overflow` — el ancho del español no es el peor caso.

**Don't**

- No escribas un `Color(0xFF…)`, un `fontSize:` ni un `EdgeInsets` con número suelto en un widget. Va contra `constants-centralization.md` y contra este documento.
- No inventes un tono nuevo "parecido" a uno existente. Si falta, se declara aquí.
- No uses `accent` para texto largo ni fondos grandes: es un acento, no un color de superficie.
- No trates los estados de error/vacío como una excepción fea: son parte del diseño (#11).

---

## Mantenimiento

- **Dirección del flujo:** `lib/config/theme/` se mantiene **a mano**, con este documento como checklist de revisión. **No** se genera desde los tokens. Motivo: no hay un export oficial de design.md a Flutter (`export` emite Tailwind/DTCG/CSS, no `ThemeData`), y la capa semántica de cuatro modos de `colors_values.dart` es más rica que el mapa plano de `colors`; un generador perdería esa fidelidad. Al cambiar un token aquí, actualiza su equivalente en `config/theme/` en el mismo PR.
- **Verificación:** `npx @google/design.md lint DESIGN.md` valida la estructura (incluido contraste WCAG). `npx @google/design.md diff` compara versiones. El spec está en **alpha** y cambiará; por eso `version: alpha` está fijado y no se construyen automatismos frágiles encima todavía.
