---
description: Al agregar o modificar una clase pública, un controlador, un datasource o una entidad, obliga a documentarlo igual que el resto (dartdoc con el porqué, no el qué) en el MISMO cambio. Aplica cada vez que se toque la capa de datos, un controlador de GetX o una API compartida.
---

# Documentación Uniforme del Código

La documentación de este proyecto vive en **dartdoc** (`///`) sobre el código, y su estándar no es "describir lo que hace la línea" sino **explicar la decisión**: por qué el campo es opcional, qué contrato del backend se está respetando, qué pasa si el dato no llega. Los comentarios existentes del repo ya siguen ese tono — el de `CurrencyModel._parseImgUrl`, `DollarEndpoints` o `Environment.currency` explican una restricción real del backend, no la sintaxis de Dart.

El riesgo que evita: una clase nueva que se agrega **después** de un pase de documentación queda con lagunas, y la próxima persona que la toque —o el próximo agente— repite el error que el comentario ausente habría evitado.

## Cuándo aplica

Cada vez que un cambio:
- **agregue o modifique una clase o método público** en `lib/shared/`, `lib/core/` o `lib/config/`, o
- **agregue o modifique un endpoint consumido** (`DollarEndpoints`) o la deserialización de un modelo, o
- **agregue o modifique un controlador de GetX** o un observable expuesto a las vistas, o
- **sume una entidad de dominio** o un campo a una existente.

## Checklist obligatorio (en el MISMO PR)

### 1. Clase o método público nuevo/modificado
- **Dartdoc de una línea** que diga qué representa, en el mismo tono que el resto (`/// Catalogue of the markets the app can request, and the modes it uses.`).
- Para lógica no trivial (parseo, normalización, cálculo pivote, promedios, persistencia), amplía con un párrafo que explique **el porqué**: qué garantiza el backend, qué pasa con los valores ausentes, qué error se propaga.
- **Tipos veraces**: la firma debe declarar lo que realmente devuelve. Nada de `dynamic` donde se conoce el tipo, ni un no-nullable que en la práctica puede ser `null`.

### 2. Endpoint o modelo nuevo/modificado
Replica el patrón de `DollarEndpoints` y `CurrencyModel`:
- En el endpoint: qué recurso sirve, **qué versión del backend** lo introdujo y si cambió de método/forma (`**POST since backend v3.0.0**: ...`).
- En `fromJson`: qué campos son **opcionales en el contrato** y por eso no se pueden desreferenciar; qué normalización se aplica y por qué (zona horaria, cadena vacía → `null`).
- Si el cambio responde a algo que hace el backend, **nómbralo**: el archivo o el modelo del repo `bcv_tracker_backend` que define ese contrato. Es lo que permite auditar la app contra su fuente.

### 3. Controlador de GetX nuevo/modificado
- Dartdoc en la clase: qué vista alimenta y de qué servicio observa datos.
- Dartdoc en cada observable público (`.obs`) que la vista consume: qué representa y cuándo cambia.
- Si registra un `ever()`/`worker`, documenta **qué lo dispara**: es control de flujo invisible desde la vista.

### 4. Entidad de dominio
- Dartdoc en la clase y en los campos cuyo significado no sea evidente (`tendency`, `keyName` vs `name`).
- Documenta las constantes estáticas especiales (`empty`, `emptySkeletonizer`, `pivotCurrency`): para qué existe cada una y dónde se usa. Sin eso, la siguiente persona añade una cuarta.

## Qué NO documentar

- Getters y setters triviales, `copyWith`, `toString`.
- Lo que el nombre ya dice (`/// Returns the name.` sobre `String get name`).
- Comentarios que repiten el código línea a línea.
- Bloques de código comentado: se borran, para eso está git.

## Documentación fuera del código

Cuando el cambio afecte a alguien que no está leyendo ese archivo, actualiza también:

- **`README.md`**: features visibles, requisitos de build, variables de entorno (ver `environment-variables.md`).
- **`CLAUDE.md`**: arquitectura, flujo de datos, dónde se registra qué. Si un cambio contradice lo que dice `CLAUDE.md`, el archivo se actualiza en el mismo PR — un mapa desactualizado es peor que ninguno.
- **`.agents/rules/`**: si el cambio establece una convención nueva, escríbela como regla en vez de dejarla en la memoria del PR.

## Verificación rápida

```bash
# El analizador reporta APIs públicas sin documentar si activas el lint
# `public_member_api_docs` en analysis_options.yaml (hoy no está activo).
flutter analyze

# Genera la documentación y revisa que no falten piezas
dart doc .
```

## Excepción

Cambios puramente internos que no exponen superficie pública (un helper privado dentro de un widget, un `_parseX` de un solo uso) no requieren dartdoc completo, pero **sí** un comentario si encapsulan una decisión no obvia.
