---
name: flutter-design
description: Aesthetic direction and Material Design 3 execution for this Flutter app. Use whenever building a screen or widget from scratch, reshaping an existing one, choosing colors, typography, spacing or motion, converting a mockup to Flutter, writing UI copy, or judging whether a screen reads as generic. Also use when a design brief is vague and someone has to commit to a direction. Covers judgment (what should this look like and why) and execution (ColorScheme, textTheme, the 8pt grid); it does not cover architecture or state.
license: Derived work — Apache-2.0 and MIT. See the attribution block below and the two LICENSE files in this directory.
metadata:
  derived_from:
    - "anthropics/skills — skills/frontend-design (Apache-2.0)"
    - "majiayu000/claude-skill-registry — skills/data/flutter-mobile-design (MIT)"
  last_modified: "2026-08-04 12:00:00 (GMT+8)"
---

# Flutter Design

> ## Atribución
>
> Obra derivada que funde dos skills, ninguna de las cuales servía sola: una está escrita para páginas web, la otra mezcla diseño con una arquitectura que este proyecto no usa.
>
> - **`frontend-design`** — Copyright © Anthropic, licencia **Apache License 2.0** ([`LICENSE-Apache-2.0.txt`](LICENSE-Apache-2.0.txt)). De aquí viene el criterio: la calibración anti-slop, el proceso de dos pasadas, la contención y toda la sección de escritura.
> - **`flutter-mobile-design`** — Copyright © 2024 majiayu000, licencia **MIT** ([`LICENSE-MIT.txt`](LICENSE-MIT.txt)). De aquí viene la ejecución: `ColorScheme` semántico, escala tipográfica de M3, moción, layout y las convenciones de plataforma.
>
> **Cambios respecto a los originales** (declararlos lo exige Apache-2.0 §4):
>
> 1. Se eliminó todo lo específico de web: el *hero* como tesis, los reveals al hacer scroll y la advertencia sobre especificidad de selectores CSS.
> 2. Se eliminaron por completo `Architecture & State Management` y `Project Structure` de `flutter-mobile-design`, que recomendaban Riverpod y BLoC. En este repo eso lo gobierna [`getx-architecture`](../getx-architecture/SKILL.md) y las reglas de `.agents/rules/`.
> 3. Se resolvieron dos contradicciones internas de los originales, documentadas más abajo donde aplican.
> 4. Se ancló todo a los tokens reales de la app: `AppColors`, `WidthValues` y `AppMessages`.

## Goal

Decidir **qué debería parecer** una pantalla y ejecutarlo en Material 3 sin que se lea como generado. Dos mitades que van juntas: el criterio para comprometerse con una dirección, y los mecanismos de Flutter para llevarla a cabo.

Dónde encaja frente a las otras dos skills de diseño:

| Skill | Momento |
|---|---|
| **`flutter-design`** (esta) | Antes: qué debería ser algo que aún no existe |
| `flutter-ui` | Durante: los tokens y los patrones de widget con los que se construye |
| `design-polish` | Después: si una pantalla que ya existe funciona, comprobado en dispositivo |

## Ancla la pantalla antes de diseñarla

Si el brief no fija qué es esto, fíjalo tú antes de tocar nada: nombra el asunto concreto, su audiencia y **el único trabajo de la pantalla**, y di en voz alta qué elegiste. Si tienes memoria de preferencias del usuario o de diseños anteriores del proyecto, úsala como pista.

Las decisiones distintivas salen del mundo del propio asunto — sus materiales, instrumentos y vocabulario. En esta app ese mundo es concreto: alguien comprueba un tipo de cambio, muchas veces al día, a menudo con prisa y con mala conexión. No es una app de exploración ni de descubrimiento. Un número legible al primer vistazo vale más que cualquier ornamento.

Responde también, del original `Design Thinking`:

- **Plataforma**: la app va a Android **e** iOS. Las convenciones difieren (ver abajo).
- **Tono**: M3 admite varias personalidades — vibrante, sobria, expresiva, mínima, cálida. Elige una y sostenla.
- **Diferenciación**: ¿cuál es el elemento firma por el que se recordaría esta pantalla?

## Principios

**La tipografía carga la personalidad.** Empareja las familias de display y de cuerpo deliberadamente, con una escala clara y pesos intencionados. El tratamiento tipográfico debería ser parte memorable del diseño, no un vehículo neutro para el contenido.

**La estructura es información.** Numeraciones, filetes, etiquetas y divisores deben codificar algo cierto sobre el contenido, no decorarlo. Los marcadores `01 / 02 / 03` solo valen si el contenido *es* una secuencia. Pregúntate si tiene sentido antes de incorporarlo.

**La moción, deliberada.** Piensa dónde y si una animación sirve al asunto. Un momento orquestado aterriza mejor que efectos dispersos. Y a veces menos es más: la animación de sobra es una de las cosas que hacen que un diseño se sienta generado por IA.

**Haz coincidir la complejidad con la visión.** Las direcciones maximalistas exigen ejecución elaborada; las mínimas exigen precisión en espaciado, tipo y detalle. La elegancia es ejecutar bien la visión elegida.

**El texto es material de diseño.** Un brief rara vez trae copy real y te toca escribirlo. El copy puede hacer que un diseño se sienta tan de plantilla como el diseño mismo — ver la sección de escritura al final.

## Calibración: en qué se agrupa el diseño generado por IA

Ahora mismo tiende a caer en tres looks:

1. Fondo crema (cerca de `#F4F1EA`) con display serif de alto contraste y acento terracota.
2. Fondo casi negro con un único acento verde ácido o vermellón.
3. Layout tipo broadsheet, filetes de un píxel, radio cero y columnas densas de periódico.

Los tres son legítimos para algún brief, pero son **defaults, no elecciones**, y aparecen sin importar el asunto. Donde el brief fije una dirección, síguela al pie de la letra — sus palabras siempre ganan, incluso si pide uno de estos tres. Donde deje un eje libre, no gastes esa libertad en el default.

### Prohibido

- Estéticas genéricas: paletas cliché —el gradiente morado sobre blanco es el ejemplo canónico—, layouts predecibles y componentes cortados con molde sin carácter propio del contexto.
- Código Flutter de plantilla. Cada implementación debería sentirse hecha para su propósito, con M3 aplicado con criterio.

> **Contradicción resuelta (1).** El original prohibía los gradientes morados y, tres secciones más abajo, su propio ejemplo de tema usaba `seedColor: Colors.deepPurple`. Copiar las dos cosas sería absurdo, así que se conserva la prohibición —que es el instinto correcto— y **se sustituye el ejemplo** por la paleta real de la app. El ejemplo pasa a ser verdadero y deja de contradecir la regla.

## Tipografía

Usa la escala de M3 a través de `Theme.of(context).textTheme` en lugar de tamaños sueltos, y respeta el escalado de fuente del sistema.

> **Contradicción resuelta (2).** El original prohibía "familias sobreutilizadas (Inter, Roboto, Arial, fuentes del sistema)". En web es buen consejo; **en Flutter móvil es un error**: Roboto *es* la fuente de plataforma en Android, San Francisco en iOS, y Material 3 se apoya en la tipografía del sistema a propósito. Se conserva el objetivo del original y se estrecha su afirmación al mínimo:
>
> **Lo que es slop no es la fuente del sistema: es no haber elegido.** Dos fallos opuestos y ambos reales —
> - Usar la del sistema **por inercia**, sin haber mirado si el asunto pedía otra cosa.
> - Importar una display face **para parecer diseñado**, cuando la de plataforma era la decisión correcta.
>
> En una app que se consulta a diario y muestra cifras, la fuente de plataforma suele ser la elección deliberada correcta: es la que el usuario ya lee sin esfuerzo. Si te apartas de ella, que sea por un motivo que puedas decir en una frase.

## Color

Material 3 gira alrededor de `ColorScheme` con acceso **semántico**, no por nombre de color:

| Rol | Para qué |
|---|---|
| `primary` / `onPrimary` | Acciones clave, FAB |
| `secondary` / `onSecondary` | Acciones menos prominentes |
| `tertiary` / `onTertiary` | Acentos por contraste |
| `surface` / `onSurface` | Tarjetas, hojas, diálogos |
| `error` / `onError` | Estados de error |

En esta app el `ColorScheme` se deriva de la paleta que ya existe en `lib/config/theme/colors/colors_constants.dart` (`AppColors.primary`, un azul profundo `0xFF02466D`), no de un seed inventado:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,      // la identidad de la app, no un color de ejemplo
    brightness: Brightness.light,
  ),
)
```

Y su gemelo con `Brightness.dark`: **la app tiene tema claro y oscuro, y toda decisión de color se valida en los dos.**

> Hoy la app sigue en Material 2 (`ThemeData` sin `useMaterial3`, paletas `MaterialColor`). La migración está decidida y vive en [#44](https://github.com/Teixeira49/bcv_tracker_app/issues/44); la guía paso a paso está en [`flutter-expert/references/theming.md`](../flutter-expert/references/theming.md). Hasta que ocurra, el acceso sigue siendo `AppColors`.

## Layout, espaciado y moción

El espaciado sale del **grid de 8 pt** ya declarado en `lib/config/theme/width/width_values.dart` (`WidthValues.spacingMd`, `radiusLg`…), no de números sueltos. Si necesitas un valor que no está en la escala, la pregunta es si el diseño debería usar uno que sí está.

> `WidthValues` está declarado y **ningún widget lo usa**: los 21 `EdgeInsets` de la app llevan números crudos. Cualquier pantalla que toques es una oportunidad de empezar a corregirlo — ver [`constants-centralization.md`](../../rules/constants-centralization.md).

Para animaciones, la skill de ejecución es [`flutter-animate`](../flutter-animate/SKILL.md). Aquí solo el criterio: sirve al asunto o se va.

## Proceso: dos pasadas

**Primera — planifica antes de escribir código.** Un sistema de tokens compacto:

- **Color**: 4–6 valores hex con nombre, derivados de la identidad de la app.
- **Tipo**: las familias para 2+ roles (display con contención, cuerpo, y una de utilidad para datos o captions si hace falta).
- **Layout**: el concepto en una frase, más un wireframe ASCII para comparar alternativas.
- **Firma**: el único elemento por el que esta pantalla se recordará.

**Segunda — revisa el plan contra el brief antes de construir.** Si alguna parte se lee como el default que producirías para cualquier pantalla parecida —pruébalo: recorre mentalmente un brief similar y mira si llegas al mismo sitio— revísala, y di qué cambiaste y por qué. Solo cuando hayas confirmado que el plan es específico de *esta* pantalla, escribe el código, siguiendo el plan revisado y derivando cada color y cada decisión tipográfica de él.

Haz la mayor parte de esta iteración pensando, y muestra ideas al usuario cuando tengas confianza de que le van a gustar.

## Contención y autocrítica

**Gasta la audacia en un solo sitio.** Que el elemento firma sea lo memorable y que todo lo demás alrededor esté quieto y disciplinado. Corta cualquier decoración que no sirva al brief. Y ojo: no arriesgar también es un riesgo.

Construye hasta un **suelo de calidad** sin anunciarlo. En esta app eso significa, concretamente:

- Funciona en las dos plataformas y en **tema claro y oscuro**.
- Sobrevive al **escalado de fuente** del sistema sin desbordarse.
- Sobrevive a los **10 idiomas**: el alemán y el ruso son notablemente más largos que el español, y son los que rompen layouts que en español entran. Usa `Flexible`/`overflow` en vez de asumir el ancho del español.
- Respeta la preferencia de **movimiento reducido**.
- Tiene `Semantics` donde hace falta. **Hoy no hay ni uno en `lib/`** — ver [#33](https://github.com/Teixeira49/bcv_tracker_app/issues/33).

Critica tu propio trabajo mientras construyes, con capturas si el entorno lo permite: una imagen vale mil tokens. Y el consejo de Chanel — antes de salir de casa, mírate al espejo y quítate un accesorio.

## Escribir en la interfaz

Las palabras están en un diseño por una razón: hacerlo más fácil de entender y por tanto de usar. Son material de diseño, no decoración. Antes de escribir nada, pregunta qué necesita decir la pantalla y cómo se dice mejor para ayudar a quien navega.

- **Escribe desde el lado del usuario.** Nombra las cosas por lo que la persona controla y reconoce, nunca por cómo está construido el sistema. Se gestionan *notificaciones*, no *config de webhooks*. Describe qué hace algo en términos llanos en vez de venderlo. Ser específico siempre gana a ser ingenioso.
- **Voz activa por defecto.** Un control dice exactamente qué pasa al usarlo: "Guardar cambios", no "Enviar". Y una acción **mantiene su nombre a lo largo del flujo**: si el botón dice "Publicar", el aviso dice "Publicado". El vocabulario de una interfaz es la señalización de quien la recorre; la coherencia es cómo se aprende el camino.
- **El fallo y el vacío son momentos de dirección, no de humor.** Explica qué salió mal y cómo arreglarlo, en la voz de la interfaz y no de una persona. Los errores no se disculpan y nunca son vagos sobre lo que pasó. Una pantalla vacía es una invitación a actuar.
- **Registro conversacional y afinado**: verbos llanos, mayúscula solo inicial, sin relleno. Que cada elemento haga exactamente un trabajo: una etiqueta etiqueta, un ejemplo demuestra, y nada hace dos cosas a la vez sin decirlo.

> Todo texto pasa por `AppMessages` y existe en **los 10 idiomas** en el mismo commit — [`i18n-convention.md`](../../rules/i18n-convention.md). Y no concatenes traducciones: el orden de las palabras cambia entre idiomas.

## Convenciones de plataforma

- **iOS**: gestos de retroceso por deslizamiento, hojas modales al estilo del sistema, tipografía y espaciado algo más generosos.
- **Android**: navegación con el botón atrás del sistema, ripple en los toques, Material You cuando aplique.

La app tiene barra inferior **propia** (`CustomBottomNavigatorBar`), no un `BottomNavigationBar` ni un `NavigationBar`. Cualquier recomendación genérica de migrar ese componente no aplica sin decidirlo primero — está en el alcance de #44.

## Fuera de alcance

- **Arquitectura y estado** — [`getx-architecture`](../getx-architecture/SKILL.md). Esta skill no propone Riverpod, BLoC ni Provider, y las referencias a esos paquetes se eliminaron de los originales a propósito.
- **Navegación y rutas** — [`getx-navigation`](../getx-navigation/SKILL.md).
- **Cambios de funcionalidad**: si el diseño exige mover una ruta o retirar una feature, eso es otra tarea con su propio issue. Señálalo, no lo hagas de callado.

## Checklist

- [ ] El asunto, la audiencia y el único trabajo de la pantalla están dichos explícitamente.
- [ ] El plan de tokens existe y pasó el test de "esto no es lo que produciría para cualquier pantalla parecida".
- [ ] Hay **un** elemento firma; el resto está quieto.
- [ ] Colores por rol semántico del `ColorScheme` (o `AppColors` hasta la migración), nunca literales.
- [ ] Espaciado y radios desde `WidthValues`.
- [ ] Tipografía desde `textTheme`; si te apartas de la fuente de plataforma, el motivo cabe en una frase.
- [ ] Validado en claro **y** oscuro, con escalado de fuente, y en español más alemán o ruso.
- [ ] Copy vía `AppMessages` en los 10 idiomas, en voz activa y con el mismo verbo en todo el flujo.
- [ ] `Semantics` donde aporta.
- [ ] Te quitaste un accesorio.
