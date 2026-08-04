---
description: Prohíbe usar los modelos de la capa de datos (shared/data/model/) en la UI o en los controladores; obliga a convertirlos a entidades de dominio con .toEntity() en la frontera. Aplica cada vez que se deserialice una respuesta del backend o se añada un campo a una entidad.
paths:
  - "lib/shared/data/model/**"
  - "lib/shared/data/datasource/**"
  - "lib/shared/domain/entities/**"
  - "lib/features/*/domain/entities/**"
---

# Entidades vs. Modelos

La app separa **modelos** (capa de datos) de **entidades** (dominio):

| Capa | Dónde vive | Qué es |
|---|---|---|
| **Modelo** | `lib/shared/data/model/` | Espejo del contrato JSON del backend. Sabe de `fromJson`, de claves como `platform_img` y de que `change` puede venir `null`. |
| **Entidad** | `lib/shared/domain/entities/`, `lib/features/*/domain/entities/` | El concepto del negocio (`Currency`, `BcvCurrencies`, `Market`, `Language`). No sabe nada de JSON ni de HTTP. |

El modelo **extiende** la entidad (`class CurrencyModel extends Currency`), así que el compilador acepta pasar un `CurrencyModel` donde se espera un `Currency`. Precisamente por eso hace falta esta regla: nada te impide filtrar un modelo hasta la UI, y el día que el backend renombre un campo, el cambio se propaga hasta el widget.

## Regla

1. **Los controladores y los widgets solo manejan entidades.** Ni un `import` de `shared/data/model/` fuera de `lib/shared/data/`.
2. **La conversión ocurre en la frontera**: el datasource deserializa con `Model.fromJson()` y devuelve entidades vía `.toEntity()` antes de entregar los datos al repositorio. De ahí en adelante, todo es dominio.
3. **`.toEntity()` es obligatorio aunque el modelo herede de la entidad.** Devolver el modelo "porque igual compila" deja un objeto de la capa de datos vivo en el dominio.
4. **La normalización se hace en el modelo, una sola vez.** Fechas del backend a hora local (`BackendDate.toLocal`), cadenas vacías a `null` (`platform_img`), números que llegan como `num` a `double`. La UI nunca debe normalizar nada de lo que vino de la red.
5. **Todo campo opcional del contrato se lee con fallback.** `json['name'] as String? ?? ''`, `(json['value'] as num?)?.toDouble() ?? 0.0`. Nunca un cast directo sobre un campo que el backend documenta como opcional: un `null` inesperado no puede tumbar la pantalla.
6. **Los tipos de UI no entran al dominio.** Una entidad no importa `package:flutter/material.dart`: nada de `Color`, `IconData` o `Widget` dentro de `domain/`. Esa traducción vive en `config/theme/` o en el widget.

## Ejemplo

**❌ Antes** — el modelo se cuela hasta el controlador:

```dart
// datasource
Future<List<CurrencyModel>> getCurrentDollar(MarketSelection selection) async {
  final response = await _http.request(endpoint: DollarEndpoints.currencies);
  return (response.data['data'] as List)
      .map((json) => CurrencyModel.fromJson(json))
      .toList();                                   // ← modelos, no entidades
}

// controller
final rates = <CurrencyModel>[].obs;               // ← la capa de datos en el estado
```

**✅ Después** — la frontera convierte, el dominio queda limpio:

```dart
// datasource
Future<List<Currency>> getCurrentDollar(MarketSelection selection) async {
  final response = await _http.request(endpoint: DollarEndpoints.currencies);
  return (response.data['data'] as List)
      .map((json) => CurrencyModel.fromJson(json).toEntity())
      .toList();                                   // ← entidades
}

// controller
final rates = <Currency>[].obs;
```

## Al agregar un campo

Un campo nuevo del backend toca **cuatro** puntos, en este orden:

1. La **entidad** (`Currency`): el campo, el constructor `const`, `copyWith` y las constantes estáticas (`empty`, `emptySkeletonizer`, `pivotCurrency`) — si olvidas una de esas, el skeleton o el estado vacío quedan inconsistentes.
2. El **modelo**: lectura en `fromJson` con fallback + normalización, y el campo en `toEntity()`.
3. Los **tests** de mapeo (`test/shared/data/`), incluyendo el caso en que el campo no viene (ver `test-coverage.md`).
4. La **UI**, solo al final, consumiendo la entidad.

Si el campo se añade al modelo pero no a `toEntity()`, el dato llega hasta la frontera y se pierde ahí, sin error visible: es el fallo más común de esta capa.

## Excepción

Los tests de la capa de datos (`test/shared/data/`) **sí** importan los modelos: es justamente lo que están verificando.
