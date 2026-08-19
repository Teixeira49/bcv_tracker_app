---
description: El nivel de documentación que no puede retroceder — invariante medible de cobertura de dartdoc en lib/, dónde es más estricto, qué está exento y por qué, y qué hacer al añadir o modificar código. Aplica al tocar cualquier .dart de lib/.
paths:
  - "lib/**/*.dart"
  - "analysis_options.yaml"
  - "CONTRIBUTING.md"
---

# Cobertura de Documentación

`documentation-convention.md` dice **cómo** se escribe un docstring y **qué no** documentar. Esta dice **qué no se puede perder**. La relación entre las dos es la misma que hay entre una guía de estilo de tests y [`test-coverage.md`](test-coverage.md): una describe la forma, la otra el mínimo exigible.

El riesgo concreto que evita es el que la propia convención ya nombra, y que un pase de documentación no arregla por sí solo:

> una clase nueva que se agrega **después** de un pase de documentación queda con lagunas, y la próxima persona que la toque —o el próximo agente— repite el error que el comentario ausente habría evitado.

Nada del tooling lo impide. Una clase sin docstring compila, `flutter analyze` sigue limpio y CI sigue verde. La única cosa que sostiene el nivel es esta regla, aplicada en la revisión.

## El invariante

[#4](https://github.com/Teixeira49/bcv_tracker_app/issues/4) llevó `lib/` de 31 de 75 tipos públicos documentados a **75 de 75**, y `dart doc` de 8 avisos a **0**. Eso es el suelo, no el techo — y el suelo sube: hoy son **84 de 84**, tras las diez clases que #37 añadió a `features/settings/`.

| Ámbito | Exigencia | Estado |
|---|---|---|
| **Todo `lib/`** | Cada **tipo** público (`class`, `mixin`, `enum`, `extension`, `typedef`) con docstring | 84/84 |
| **`shared/domain/` y `shared/data/`** | Además, cada **miembro** público con docstring | 0 huecos |
| **Todo `lib/`** | `dart doc` sin avisos ni errores | 0 avisos |

Las capas de contrato son más estrictas porque es donde un dato sin documentar cuesta de verdad: un campo que el backend declara opcional y que alguien desreferencia, una normalización que se repite porque nadie sabía que ya estaba hecha, un `.toEntity()` que parece redundante y no lo es.

**Si tu cambio baja cualquiera de esas tres cifras, está incompleto.**

## Exenciones, declaradas aquí y en ningún otro sitio

Tres clases están **exentas a nivel de miembro**, a propósito:

| Clase | Miembros | Por qué |
|---|---|---|
| `ColorValues` | 77 accesores de color | El nombre *es* la documentación |
| `AppMessages` | 79 getters de i18n | Idem: la clave y el getter son la misma palabra |
| `AppIcons` | 17 rutas de asset | Idem |

Son **173 de los 307** miembros públicos sin docstring del proyecto. Comentarlos uno a uno produciría exactamente el ruido que `documentation-convention.md` prohíbe (`/// El color blanco del texto` sobre `textWhite`), y ese ruido tapa las líneas que sí informan.

Lo que estas tres clases llevan es un docstring **de clase** que explica el registro completo: la separación en dos capas del color, la regla de los diez idiomas, por qué centralizar rutas de asset. Eso es lo que hay que mantener al día.

> ⚠️ **La exención no es una invitación a ampliarla.** Vale para un registro mecánico —muchos miembros, todos del mismo tipo, cada nombre autoexplicativo— y para nada más. Un miembro que encierra una decisión, un borde o un contrato del backend se documenta, esté donde esté. Si crees que tu caso es una cuarta exención, la discusión va en la PR, y esta tabla se amplía en el mismo commit o no se amplía.

### Por eso `public_member_api_docs` está apagado

Activar el lint forzaría esos 173 comentarios. Y como CI corre `flutter analyze` **sin** `--no-fatal-*`, no sería un aviso con el que se pueda convivir: sería el build roto hasta escribirlos todos. La decisión se tomó en #4 y se mantiene.

El lint sigue siendo la mejor forma de **medir**. Cómo activarlo un momento sin dejarlo puesto, y la trampa del YAML que hace que reporte `0` cuando en realidad no se aplicó, está en [`CONTRIBUTING.md`](../../CONTRIBUTING.md#-documentación-del-código) — no se repite aquí para que haya un solo sitio que actualizar.

## Cuándo aplica, y qué hacer

### 1. Añades un tipo público
Lleva docstring **en el mismo commit**. Una línea de qué representa y qué papel juega en su capa; un párrafo más si encierra una decisión. Si está en `shared/domain/` o `shared/data/`, también cada miembro público.

### 2. Añades un miembro público a un tipo de las capas de contrato
Lleva docstring. Para una entidad, lo que hay que decir casi nunca es qué contiene el campo —eso lo dice el nombre— sino **qué pasa cuando no está**: por qué es opcional en el contrato, qué se muestra en su lugar, qué no se puede desreferenciar.

### 3. Cambias lo que hace un símbolo ya documentado
**Su docstring entra en el mismo diff.** Esto es la mitad de la regla y la que ningún script puede medir: un comentario que describe el comportamiento anterior **miente con autoridad**, y es peor que la ausencia — quien lo lee no vuelve a comprobar el código.

Señales de que un docstring quedó rancio:

- Nombra un símbolo que renombraste o borraste.
- Explica un caso borde que tu cambio eliminó, o calla uno que introdujo.
- Cita un issue como pendiente cuando ya se cerró (o al revés).
- Da un número —«los diez idiomas», «75 claves», «dos secciones»— que tu cambio movió.

### 4. Borras código
Borra su docstring con él, y comprueba que ningún otro lo referencia con `[Corchetes]`: `dart doc` avisa de la referencia huérfana, y el invariante de cero avisos es lo que hace que ese aviso se vea.

### 5. Mueves o renombras un tipo
Las referencias `[Corchetes]` de otros archivos solo resuelven si el símbolo está importado ahí. Al mover algo, `dart doc` es lo que dice qué se rompió.

## Verificación

```bash
flutter analyze     # limpio
flutter test        # verde
dart doc .          # "Found 0 warnings and 0 errors."
```

Y la cobertura de tipos, que es el número que no puede bajar de 84/84 — el script está en [`CONTRIBUTING.md`](../../CONTRIBUTING.md#medir-la-cobertura), junto al de miembros.

`dart doc` escribe en `doc/api/`, que está gitignored: bórralo después si te molesta, pero no lo commitees.

## Lo que esta regla **no** tiene

**No hay nada que haga fallar la PR por una cobertura que baje.** Se evaluó un test en `test/` —el patrón que `translation_parity_test.dart` ya usa para la paridad de i18n, que sí falla el build— y se decidió dejar esta regla como documento por ahora.

Conviene ser honesto sobre lo que eso implica: el invariante de arriba lo sostiene **la revisión de la PR**, no el tooling. Si empieza a retroceder, la respuesta no es reescribir esta regla con más énfasis, es convertirla en un test.

## Relación con las otras reglas

- [`documentation-convention.md`](documentation-convention.md) — **cómo** se escribe: el tono, el checklist por tipo de cambio, y la lista de lo que no se documenta. Esta regla es su contraparte cuantitativa.
- [`test-coverage.md`](test-coverage.md) — la misma idea aplicada a los tests, y el modelo del que esta regla toma la forma.
- [`entities-vs-models.md`](entities-vs-models.md) — los cuatro puntos que toca un campo nuevo. El paso 1 y el 2 incluyen su docstring; esta regla es lo que lo exige.
