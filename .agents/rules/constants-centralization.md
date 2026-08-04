---
description: Prohíbe los valores "mágicos" en el código y obliga a centralizar constantes en lib/core/constants/ y lib/config/theme/. Aplica cada vez que se introduzca o modifique un literal reutilizable (números, strings, duraciones, paddings, colores, rutas de endpoint, claves de preferencias).
---

# Centralización de Constantes

Para mantener el código legible, consistente y fácil de ajustar, **no se escriben valores "mágicos" directamente en el código**. Todo literal con significado de negocio, de configuración o de diseño se declara como constante y se referencia desde ahí.

En una app Flutter esto pesa el doble: un `16.0` repetido en veinte widgets es una decisión de diseño que nadie puede cambiar de una vez, y un `'off'` suelto en un controlador es un contrato con el backend que el compilador no vigila.

## Dónde vive cada constante

| Tipo de valor | Archivo | Clase / acceso |
|---|---|---|
| Valores de negocio y de app (título, duraciones, formatos de fecha) | `lib/core/constants/constants.dart` | `Constants` |
| Catálogo de mercados y modos del contrato con el backend | `lib/core/constants/market_constants.dart` | `Markets` |
| Rutas de endpoint y versión de API | `lib/shared/data/datasource/dollar_api/dollar_endpoints.dart` | `DollarEndpoints` |
| Nombres de rutas de navegación | `lib/config/routes/routes.dart` | `AppRoutes` |
| Colores y paletas | `lib/config/theme/colors/colors_constants.dart` | `AppColors` |
| Espaciados, radios y tamaños (grid de 8 pt) | `lib/config/theme/width/width_values.dart` | `WidthValues` (`spacingMd`, `radiusLg`, …) |
| Iconos y assets del tema | `lib/config/theme/icons/icons_constants.dart` | `AppIcons` |
| Textos visibles | `lib/core/i18n/` | `AppMessages` (ver `i18n-convention.md`) |

## Reglas de Implementación

1. **Cero literales mágicos**: si un número, string, duración o flag tiene significado (no es un `0`/`1`/`''` trivial de control de flujo) y/o puede reutilizarse, declara una constante en lugar de incrustarlo.
2. **Un único punto de verdad**: si el mismo valor aparece en más de un lugar, debe existir una sola constante y todos los usos la referencian. No se duplica el literal.
3. **Nomenclatura Dart**: `lowerCamelCase` como miembro `static const` de la clase correspondiente (`splashDuration`, `bcvFormatDate`, `modeLiveAll`). No uses `UPPER_SNAKE_CASE`: `flutter_lints` marca `constant_identifier_names`.
4. **Clases de constantes con constructor privado**: `const Constants._();` — son espacios de nombres, no tipos instanciables. Sigue el patrón de `Constants`, `Markets` y `AppColors`.
5. **`const` sobre `final` siempre que el valor se conozca en compilación.** Además de expresar intención, permite que Flutter reutilice los widgets sin reconstruirlos.
6. **Espaciados y radios salen del grid de 8 pt** (`lib/config/theme/width/`), no de números sueltos en el `EdgeInsets`. Si necesitas un valor que no está en la escala, la pregunta es si el diseño debería usar uno que sí está.
7. **Colores desde `AppColors` y, cuando exista, desde el `Theme`.** Nada de `Color(0xFF02466D)` en un widget: rompe el tema claro/oscuro sin que nadie lo note hasta cambiar de modo.
8. **Las claves de `SharedPreferences` son constantes.** Un typo en una clave escrita a mano no falla: simplemente lee `null` y el usuario pierde su preferencia en silencio.
9. **Alcance del cambio**: al tocar código que ya contiene un literal mágico relacionado con lo que estás modificando, aprovéchalo para extraerlo a la constante (regla del boy-scout), siempre que no desvíe el objetivo del PR.

## Ejemplo

**❌ Antes** — duración, formato y color incrustados:

```dart
Future.delayed(const Duration(seconds: 3), () { ... });
DateFormat('yyyy-MM-dd').format(date);
Container(color: const Color(0xFF02466D), padding: const EdgeInsets.all(16));
```

**✅ Después** — todo referenciado:

```dart
Future.delayed(const Duration(seconds: Constants.splashDuration), () { ... });
DateFormat(Constants.bcvFormatDate).format(date);
Container(
  color: AppColors.primary,
  padding: EdgeInsets.all(WidthValues.spacingMd),
);
```

## Deuda conocida

A la fecha de escribir esta regla:

- **Colores: al día.** No hay ni un `Color(0xFF...)` fuera de `lib/config/theme/`; los 137 usos pasan por `AppColors`.
- **Espaciados: pendiente.** `WidthValues` está definido pero **sin usar**: los 22 `EdgeInsets` de la app llevan números sueltos. Al tocar un widget, migra sus paddings a la escala (regla del boy-scout), sin desviar el objetivo del PR.

## Excepciones

Esta regla no aplica a:

- Literales triviales de control de flujo sin significado de negocio (índices `0`/`1`, cadena vacía como acumulador, `null`).
- Valores locales de un solo uso dentro de una función cuyo significado ya es evidente por el contexto inmediato y no se reutilizan.
- Constantes que ya provienen de la librería estándar o del framework (`Duration.zero`, `Colors.transparent`).
- Valores que dependen del **entorno** (URLs de backend, claves): esos no son constantes de código, van en variables de entorno — ver `environment-variables.md`.
