---
description: Cómo proponer el incremento de versión por el valor entregado al usuario y no solo por el tipo de los commits. Aplica cada vez que se vaya a decidir el número de una versión nueva, antes de escribir el release note o el CHANGELOG.
paths:
  - "pubspec.yaml"
  - "CHANGELOG.md"
  - "docs/release/**"
---

# Propuesta de Versión por Valor de Producto

[`release-versioning.md`](release-versioning.md) define el incremento por el **tipo de commit predominante**: breaking → MAJOR, `feat` → MINOR, el resto → PATCH. Esa tabla es la base y no se sustituye: garantiza que dos personas distintas lleguen al mismo número.

Pero el tipo de commit describe **cómo se escribió el código**, no **qué recibe el usuario**. Y son cosas distintas más a menudo de lo que parece:

- Un `feat` detrás de un flag apagado no entrega nada. Mecánicamente es MINOR; para el usuario es un PATCH.
- Catorce `fix` que en conjunto hacen que la app por fin sirva sin conexión son, mecánicamente, un PATCH. Para el usuario es la versión más importante del trimestre.
- Un `refactor` que cambia el formato de lo guardado en `SharedPreferences` no añade funcionalidad, pero **rompe las instalaciones existentes**: es MAJOR.

Esta regla añade un segundo paso: después de calcular el número mecánico, **contrástalo con el valor entregado** y propón el que corresponda, con el razonamiento a la vista.

## Procedimiento

### 1. Calcula el número mecánico

Según la tabla de `release-versioning.md`. Ese es el punto de partida y el valor por defecto.

### 2. Escribe la frase de valor

Antes de mirar la lista de commits otra vez, responde en **una sola frase, en lenguaje de usuario**:

> *Con esta versión, el usuario puede / ya no sufre / obtiene…*

Es la misma frase que abrirá `release_notes.json` ([`release-notes.md`](release-notes.md)). Si no consigues escribirla sin nombrar una clase, un endpoint o un número de PR, el usuario no percibe la versión: es un PATCH, por muchos `feat` que lleve dentro.

### 3. Contrasta y ajusta

| Situación | Mecánico | Propuesto | Por qué |
|---|---|---|---|
| `feat` detrás de flag apagado, o sin UI que lo exponga | MINOR | **PATCH** | No se entrega nada todavía |
| Varios `fix` que juntos habilitan un uso que antes no existía | PATCH | **MINOR** | El usuario gana una capacidad, no una corrección |
| `refactor`/`build` que cambia datos persistidos, `minSdkVersion`, deployment target o exige un backend incompatible | PATCH | **MAJOR** | Rompe instalaciones o dispositivos existentes |
| `feat` visible pero marginal (un ajuste más en Ajustes) | MINOR | MINOR | Coincide |
| `perf` que hace usable algo que antes no lo era | PATCH | **MINOR** | Un cambio de grado que se convierte en cambio de tipo |
| Solo `docs`, `ci`, `chore`, `test` | PATCH | **no publicar** | Nada que anunciar; espera a acumular |

**Regla de asimetría:** subir de nivel exige justificación; bajar también. Nunca ajustes en silencio — si te apartas del número mecánico, el motivo va en la propuesta y en el release note.

### 4. Propón al usuario

La confirmación de la versión es un gate obligatorio en cualquier `triggerMode`, incluido `auto` (`release-versioning.md`, Paso 2). Preséntala así:

```
💡 Versión propuesta: v1.2.0  (mecánica: v1.1.2)

   Valor: el usuario puede seguir solo los mercados que le interesan y las
   tasas dejan de desaparecer al perder conexión.

   Por qué se sube de PATCH a MINOR: los 9 commits son `fix`, pero juntos
   habilitan el uso sin conexión, que antes no existía. Para el usuario es
   una capacidad nueva, no una corrección.

   Desde v1.1.1 · PR #58 · 9 commits
```

Si el usuario indica otro número, se usa el suyo sin discutir: la versión es una decisión de producto y esto es una propuesta, no un veredicto.

## Lo que esta regla NO autoriza

- **Inflar versiones por marketing.** Saltar a v2.0.0 «porque suena mejor» rompe el contrato de SemVer: MAJOR significa incompatibilidad, no importancia.
- **Saltarse números** (`v1.1.0` → `v1.5.0`) para aparentar ritmo.
- **Bajar un breaking change a MINOR** para evitar el salto de MAJOR. Si rompe instalaciones existentes, es MAJOR aunque incomode. En una app instalada, el coste de mentir aquí lo paga el usuario cuya app deja de funcionar tras actualizar.
- **Publicar sin valor.** Si el paso 2 no produce una frase, la respuesta correcta suele ser no publicar todavía.

## En una app instalada, «breaking» es más amplio de lo que parece

No hay API pública que romper, así que el criterio es **qué deja de funcionar en un teléfono que ya tiene la app**:

- Formato incompatible de lo persistido en `SharedPreferences` (claves de tema, idioma, mercados seguidos) sin migración.
- Subir `minSdkVersion` (hoy 23) o el deployment target de iOS (hoy 12.0): dispositivos que dejan de recibir la actualización.
- Exigir una versión de backend que la anterior no soportaba — si el usuario no actualiza, o si el backend aún no está desplegado, la app queda inservible.
- Retirar un mercado o una divisa que la gente estaba consultando.

Cualquiera de esos es MAJOR, y además **tiene que salir en las notas de versión**: el usuario merece enterarse antes de actualizar, no después.

## Relación con las otras reglas

- [`release-versioning.md`](release-versioning.md) — el flujo completo y la tabla mecánica de SemVer. Esta regla se inserta en su Paso 2.
- [`release-notes.md`](release-notes.md) — la frase de valor del paso 2 es la primera línea de `release_notes.json`.
- [`commit-convention.md`](commit-convention.md) — de donde sale el tipo predominante que da el número mecánico.
