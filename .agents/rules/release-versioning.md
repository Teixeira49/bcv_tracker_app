---
description: Versionado SemVer del proyecto, bump de pubspec.yaml, creación de GitHub Releases y mantenimiento del CHANGELOG a partir de un PR aprobado y mergeado. Aplica cada vez que se vaya a lanzar una versión nueva de la app.
paths:
  - "pubspec.yaml"
  - "CHANGELOG.md"
  - "docs/release/**"
---

# Versionado y Releases

Esta regla define cómo se versiona la app (SemVer), cómo se crea el **GitHub Release** de cada versión y cómo se mantiene el **CHANGELOG**. Todo esto se dispara **solo** cuando un feature ya está en un **PR aprobado, cerrado y mergeado**: el usuario indicará "trae el PR #N" (o su URL) y a partir de ese PR real se documentan los cambios para constatar que se hicieron.

A diferencia del backend, aquí la versión **también vive en el código**: `pubspec.yaml` (`version: X.Y.Z+build`) es la fuente de la que Codemagic saca `--build-name`. Un release sin bump de `pubspec.yaml` produce binarios etiquetados con la versión anterior.

## Cuándo se dispara

- **Únicamente** cuando el usuario pide lanzar una versión a partir de un PR que ya está **mergeado**.
- Nunca se lanza una versión desde código sin mergear, desde un PR abierto o rechazado, ni por iniciativa propia.
- El PR es la **fuente de verdad**: la versión, el release note y la entrada del CHANGELOG se redactan a partir de lo que ese PR realmente cambió.

## Paso 0 — Leer la configuración

Lee `.claude/pr-config.json` (misma fuente que `pull-request.md`). De ahí se usan:

- `triggerMode`: nivel de disparo (`"manual"` | `"ask"` | `"auto"`) — gobierna la **publicación del GitHub Release** (ver Paso 6).
- `productionBranch`: rama de producción; es el **target del tag** del release (`master`).

Si el archivo no existe, asume `triggerMode: "manual"` y `productionBranch: "master"`.

## Paso 1 — Traer y validar el PR mergeado

Con el número/URL que dio el usuario, trae el PR y **verifica** que cumple las condiciones antes de documentar nada:

```bash
gh pr view <N> --json number,title,body,state,mergedAt,mergeCommit,labels,reviewDecision,url,headRefName
```

Debe cumplirse:

- `state` = `MERGED` (cerrado **y** mergeado — un PR solo cerrado sin merge **no** cuenta).
- `reviewDecision` = `APPROVED` (aprobado).

Si alguna condición no se cumple, **detente** e informa al usuario; no crees release, no toques `pubspec.yaml` ni el CHANGELOG.

De `body`, `title`, `labels`, `headRefName` (tipo de la rama) y los commits del PR sale el material para la versión, el release note y el CHANGELOG. Para el detalle de cambios:

```bash
gh pr view <N> --json commits --jq '.commits[].messageHeadline'
```

Si `gh` no está disponible, usa el conector MCP de GitHub si existe; si tampoco, pídele al usuario que pegue el título, cuerpo, estado (mergeado/aprobado) y commits del PR.

## Paso 2 — SemVer: determinar la versión

El proyecto usa **Semantic Versioning**: `MAJOR.MINOR.PATCH` (tags con prefijo `v`, ej. `v1.0.0`).

Regla de incremento, coherente con `commit-convention.md`:

| Cambio predominante del PR | Parte que sube | Ejemplo |
|---|---|---|
| Breaking change (`!` o footer `BREAKING CHANGE:`) | **MAJOR** (`X`.0.0) | `v1.0.0` → `v2.0.0` |
| `feat` (nueva funcionalidad, no-breaking) | **MINOR** (`x.Y`.0) | `v1.0.0` → `v1.1.0` |
| `fix`, `perf`, `refactor`, `docs`, `build`, `chore`, etc. | **PATCH** (`x.y.Z`) | `v1.0.0` → `v1.0.1` |

En una app instalada, cuenta como **breaking** lo que rompe instalaciones existentes aunque no cambie ninguna API pública: un formato incompatible en lo persistido con `SharedPreferences`, subir el `minSdkVersion` de Android o el deployment target de iOS, o exigir una versión de backend que la anterior no soportaba.

Procedimiento:

1. Obtén la última versión publicada:
   ```bash
   git tag --sort=-v:refname | head -n1        # o: gh release list
   grep '^version:' pubspec.yaml                # versión declarada en el código
   ```
   Ambas deben coincidir en la parte SemVer; si no, avisa antes de continuar.
2. Calcula la versión siguiente según la tabla (usa el cambio de mayor peso si el PR mezcla varios tipos). Ese es el número **mecánico**.
3. **Contrástalo con el valor entregado** siguiendo [`version-value-proposal.md`](version-value-proposal.md). El tipo de commit describe cómo se escribió el código, no lo que recibe el usuario: un `feat` tras un flag apagado no entrega nada, y varios `fix` que juntos habilitan un uso nuevo sí. Si te apartas del número mecánico, el motivo va en la propuesta.
4. **Confirma con el usuario** el número propuesto **siempre**, antes de crear archivos o el release:
   ```
   💡 Versión propuesta: vX.Y.Z (mecánica: vA.B.C)
      Valor: <la frase de usuario>
      <por qué se ajustó, si se ajustó>
   ```
   Si el usuario indica otro número, úsalo. La confirmación de la versión es un gate obligatorio incluso en `triggerMode: auto`; lo que `auto` automatiza es la publicación del release, no la elección de la versión.

## Paso 3 — Bump de `pubspec.yaml`

Actualiza la línea `version:` de `pubspec.yaml` a la versión confirmada:

```yaml
version: X.Y.Z+<build>
```

- La parte **antes** del `+` es el SemVer (`--build-name` en Codemagic) y debe coincidir exactamente con el tag `vX.Y.Z`.
- La parte **después** del `+` es el build number. Codemagic usa `${CM_BUILD_NUMBER}` en CI, así que el valor del archivo solo importa para builds locales: increméntalo en 1 en cada release para que un `flutter build` local no repita build number.
- El build number **nunca baja**, ni siquiera si el SemVer sube: las tiendas rechazan un build number repetido o menor.
- Este cambio va en un commit `🔧 chore: bump version to X.Y.Z` (o dentro del PR de release si el usuario trabaja así).

> ⚠️ **`pubspec.yaml` es la única fuente que se edita.** Android, iOS y `codemagic.yaml` derivan la versión de ahí; tocarlos a mano es lo que produce un binario que dice una cosa en la tienda y otra en el tag. El mapa completo de los once sitios donde aparece la versión —cuáles son derivados, cuál es ruido del target de tests y cuáles hay que actualizar sí o sí, incluido el `README.md`— está en [`version-sources.md`](version-sources.md).

## Paso 4 — Escribir el release note en `docs/release/`

Siempre generas un markdown con las notas del release y lo guardas en:

```
docs/release/RELEASE_v<X.Y.Z>.md
```

> `docs/` está en `.gitignore` **salvo `docs/release/`**, que sí se versiona (ver `.gitignore`). Si la carpeta no existe, créala.

Secciones:

**Obligatorias**
- **Título** con versión y emoji + subtítulo del release (ej. `# Release Notes - v1.1.0 🚀`).
- **Fecha de lanzamiento**: la fecha de merge del PR (`mergedAt`), en formato `DD de Mes de AAAA` (español).
- **Visión General**: resumen en prosa de lo que aporta la versión.
- **Registro de Cambios**: los cambios reales del PR, agrupados por categoría (UI/UX, Ingeniería/Estructura, Documentación, etc.), en viñetas. Deriva de los commits y del cuerpo del PR.

**Opcionales** (inclúyelas solo si aplican al cambio; no rellenes de más)
- **Evolución de la Arquitectura**: tabla comparativa y/o diagramas Mermaid (antes/después) cuando el cambio sea estructural.
- **Comparativa Visual**: tablas side-by-side de capturas cuando haya cambios visibles de UI (es una app: si la versión se ve distinta, muéstralo).
- **Compatibilidad**: versión mínima de backend requerida, cambios de `minSdkVersion`/deployment target, o migraciones de datos locales, cuando apliquen.
- **Próximos Pasos**: roadmap breve.

Cierra con la línea de firma del proyecto (ej. `*DolarTracker - Monitorizando la economía con precisión y elegancia.*`).

## Paso 5 — Actualizar el `CHANGELOG.md`

El `CHANGELOG.md` sigue el formato **[Keep a Changelog](https://keepachangelog.com/)** emparejado con SemVer. Agrega una entrada **nueva y concisa** para la versión (no dupliques todo el release note; el detalle vive en `docs/release/`).

- Si el archivo no existe, está vacío o no tiene cabecera, inicialízalo:
  ```markdown
  # Changelog

  Todos los cambios notables de este proyecto se documentan en este archivo.

  El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
  y el proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).
  ```
- Inserta la versión nueva **arriba** (orden descendente, la más reciente primero):
  ```markdown
  ## [X.Y.Z] - AAAA-MM-DD

  ### Added
  - <lo nuevo agregado>

  ### Changed
  - <cambios en funcionalidad existente>

  ### Fixed
  - <bugs corregidos>

  ### Removed
  - <lo que se eliminó>
  ```
- Usa la fecha de merge del PR (`AAAA-MM-DD`). Incluye solo las subsecciones (`Added`, `Changed`, `Fixed`, `Removed`, `Deprecated`, `Security`) que apliquen; omite las vacías.

> El CHANGELOG es técnico y para desarrolladores. Las notas que **ve el usuario** en TestFlight, las tiendas y Firebase son un tercer documento, `release_notes.json`, con otra voz y otros límites de longitud: ver [`release-notes.md`](release-notes.md). Los tres salen del mismo PR y no pueden contradecirse.
- Al final del archivo, mantén los enlaces de comparación por versión cuando sea posible:
  ```markdown
  [X.Y.Z]: https://github.com/Teixeira49/bcv_tracker_app/compare/vA.B.C...vX.Y.Z
  ```

## Paso 6 — Promover `development` a `master`

El trabajo del día a día se acumula en `development` (`baseBranch`); producción es `master` (`productionBranch`). Un release es, en la práctica, **promover `development` a `master`**:

```bash
gh pr create --base master --head development \
  --title "[🚀 Release: vX.Y.Z] - <subtítulo>" \
  --body-file docs/release/RELEASE_v<X.Y.Z>.md
```

- El bump de `pubspec.yaml` (Paso 3) debe ir **dentro** de esa promoción, no después: el tag tiene que apuntar a un commit donde la versión del código ya sea la nueva.
- Esta PR es la excepción a la regla de "nunca apuntes a `master`" de `pull-request.md`; la otra es un `hotfix/`.
- **Este merge es el que cierra los issues.** Al llegar a `master`, las keywords `Closes #N` de todas las PR acumuladas surten efecto de golpe, porque `master` es la rama por defecto. Es el momento previsto por la política del repositorio: un issue se cierra cuando su trabajo está en producción (ver `branch-naming.md`).
- Tras el merge, comprueba que se cerró lo que debía: `gh issue list --state closed --limit 20`. Si algún issue del release sigue abierto, es que su PR no llevaba la keyword — ciérralo a mano indicando la versión que lo entregó.
- Un **hotfix** salta este paso: va directo a `master`, y después se propaga a `development` para que la corrección no se pierda.

## Paso 7 — Crear el GitHub Release (según `triggerMode`)

El release usa el tag `vX.Y.Z` sobre `productionBranch` y su cuerpo es el markdown de `docs/release/`. Créalo **después** de que la promoción del Paso 6 esté mergeada.

Comando base (prioriza GitHub CLI):

```bash
gh release create v<X.Y.Z> \
  --target <productionBranch> \
  --title "v<X.Y.Z> - <subtítulo del release>" \
  --notes-file docs/release/RELEASE_v<X.Y.Z>.md
```

Comportamiento por modo:

### `manual`
Escribe el release note (Paso 4) y actualiza el CHANGELOG (Paso 5), pero **no** abre la PR de promoción (Paso 6) ni crea el release en GitHub. Informa las rutas de los archivos generados y termina. No hagas push de tags ni publiques nada.

### `ask`
1. Muestra en el chat: la **versión** confirmada, el **bump de `pubspec.yaml`**, el **contenido** del release note, la **entrada** del CHANGELOG y el **tag/target**.
2. Espera aprobación **escrita** del usuario.
3. Tras aprobar, crea el release **publicado** con el comando de arriba.

### `auto`
Crea el release **publicado** directamente con el comando de arriba (la versión ya fue confirmada en el Paso 2). Registra en el chat el tag y la URL resultante.

> Nota de seguridad: crear/publicar un GitHub Release es una acción que publica contenido. En `auto` está pre-autorizada por esta configuración; en `ask` requiere tu visto bueno explícito; en `manual` no se publica.

Si `gh` no está disponible, usa el conector MCP de GitHub si existe; si tampoco, deja los archivos escritos (como en `manual`) e informa que el release debe crearse manualmente. Tras crearlo, devuelve la URL del release.

## Paso 8 — Distribución de binarios

El release de GitHub documenta la versión; **no** produce los binarios. La distribución la hace Codemagic (`codemagic.yaml`) hacia Firebase App Distribution, tomando `--build-name` de `pubspec.yaml` y `--build-number` de `CM_BUILD_NUMBER`.

- Verifica que el workflow de Codemagic haya corrido sobre el commit del tag antes de anunciar la versión.
- Si el release requiere subida a Play Store / App Store, indícalo explícitamente en el release note: no es automático.

## Notas

- Un release = una versión = un tag `vX.Y.Z` = una línea `version:` en `pubspec.yaml`. No reutilices tags existentes; si el tag ya existe, detente y avisa.
- El `type` predominante del PR (y de la rama, `branch-naming.md`) debe ser coherente con el incremento SemVer elegido.
- El nombre del archivo de release siempre lleva el prefijo `v` y la versión completa: `RELEASE_v<X.Y.Z>.md`.
- El CHANGELOG es el resumen navegable; el release note en `docs/release/` es el documento extenso. Mantén ambos consistentes con lo que el PR realmente cambió.
