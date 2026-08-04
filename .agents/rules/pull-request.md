---
description: Flujo, título y descripción para crear Pull Requests, integrando el issue de GitHub de la rama y los commits. Aplica cada vez que se vaya a preparar o disparar una PR en este repositorio.
---

# Pull Requests

Esta regla define cómo preparar y disparar Pull Requests. Cubre tres cosas: el **nivel de disparo** (cuánta autonomía tiene la IA para subir la PR), el **título** y la **descripción**. La descripción se construye a partir del **issue de GitHub vinculado a la rama** (si existe) y de los **commits de la rama**. Este proyecto no usa Jira: el issue se vincula a la rama con el mecanismo nativo de GitHub (linked branch / keyword de cierre), **no por el nombre** (ver `branch-naming.md`). Una rama puede **no tener** issue vinculado; en ese caso la regla degrada con elegancia y arma la PR solo con los commits (ver "Paso 1b").

## Paso 0 — Leer la configuración

Antes de cualquier acción de PR, lee el archivo de configuración del repositorio:

```
.claude/pr-config.json
```

De ahí se obtienen:

- `triggerMode`: nivel de disparo (`"manual"` | `"ask"` | `"auto"`).
- `draftsDir`: carpeta donde se guardan los markdown de PR. Por defecto `docs/pull-requests/`.
- `reviewers`: lista de reviewers candidatos del equipo (puede estar vacía).
- `branchProjectCode`: iniciales del proyecto usadas en el ID de rama (ver `branch-naming.md`). `DTA`.
- `baseBranch`: rama destino por defecto de las PR (todo lo que no sea hotfix). `development`.
- `productionBranch`: rama de producción, destino de los hotfixes. `master`.
- `assignSelf`: si es `true`, **toda** PR se auto-asigna al autor (ver "Asignación automática"). Por defecto `true`.
- `selfAssignee`: usuario de GitHub que se asigna cuando `assignSelf` es `true`. Si falta, se usa `@me` (el usuario autenticado en `gh`).
- `labelsByType`: mapa `tipo-de-rama → label` que se aplica automáticamente a cada PR (ver "Labels").

En este repositorio el archivo ya existe con `triggerMode: "ask"`, `draftsDir: "docs/pull-requests/"`, `reviewers: []`, `branchProjectCode: "DTA"`, `baseBranch: "development"`, `productionBranch: "master"`, `assignSelf: true`, `selfAssignee: "Teixeira49"` y el mapa `labelsByType`. Si por algún motivo no existiera, asume esos mismos valores por defecto e informa al usuario de que conviene crearlo.

> `docs/` está en `.gitignore` (salvo `docs/release/`), así que los borradores de PR son **locales**: el documento canónico de la PR vive en GitHub, no en el repo.

## Información requerida

Antes de ejecutar, verifica que tengas:

1. **Nombre de la rama** — ejemplo: `feat/DTA-014`. Si no se indica, usa la rama actual (`git branch --show-current`). Debe seguir el formato `<tipo>/<branchProjectCode>-<numero>` de `branch-naming.md`.

## Paso 1 — Resolver el issue vinculado a la rama

El issue **no se busca por título** (el título del issue no coincide con el nombre de la rama). Para descubrir el número de issue vinculado, intenta estas fuentes **en orden** y quédate con el primer `#N` que encuentres:

1. **Keyword de cierre en los commits de la rama** (fuente principal, es lo que recomienda `branch-naming.md`):
   ```bash
   git log <base>..<nombre-de-rama> --format=%B \
     | grep -ioE '(close[sd]?|fix(e[sd])?|resolve[sd]?) #[0-9]+' | head -n1
   ```
   (`<base>` es `productionBranch` para `hotfix/`, o `baseBranch` en cualquier otro caso.)

2. **Si ya existe una PR abierta para la rama**, consulta sus issues vinculados vía GraphQL (el campo `closingIssuesReferences` aún no está expuesto en `gh pr view --json`):
   ```bash
   gh api graphql -f owner='<owner>' -f repo='<repo>' -F pr=<numero-pr> -f query='
   query ($owner: String!, $repo: String!, $pr: Int!) {
     repository(owner: $owner, name: $repo) {
       pullRequest(number: $pr) {
         closingIssuesReferences(first: 10) { nodes { number } }
       }
     }
   }' --jq '.data.repository.pullRequest.closingIssuesReferences.nodes[].number'
   ```

3. **Linked branch de GitHub** (cubre las ramas creadas con `gh issue develop` que aún **no** tienen PR ni keyword de cierre). GitHub guarda el vínculo rama→issue en `Issue.linkedBranches`, pero **no hay búsqueda inversa** (de rama a issue): hay que recorrer los issues y quedarse con el que tenga esta rama enlazada. Además, el vínculo aparece en `linkedBranches` **solo mientras no exista PR** (al abrir la PR, el vínculo migra a `closingIssuesReferences`, por eso este paso es el complemento del paso 2).

   ```bash
   # owner/repo del repositorio actual
   read -r OWNER REPO <<< "$(gh repo view --json owner,name --jq '.owner.login + " " + .name')"
   BRANCH='<nombre-de-rama>'

   gh api graphql -f owner="$OWNER" -f repo="$REPO" -f query='
   query ($owner: String!, $repo: String!) {
     repository(owner: $owner, name: $repo) {
       issues(first: 100, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
         nodes {
           number
           linkedBranches(first: 20) { nodes { ref { name } } }
         }
       }
     }
   }' --jq ".data.repository.issues.nodes[] | select([.linkedBranches.nodes[].ref.name] | index(\"$BRANCH\")) | .number" | head -n1
   ```

   Devuelve el número del issue cuyo linked branch coincide exactamente con `BRANCH`. Si el repo tiene más de 100 issues abiertos y no aparece nada, considera paginar (`after`) o incluir `states: [OPEN, CLOSED]`; ante la duda, pasa al paso 4.

4. **Preguntar al usuario** por el número de issue, como último recurso antes de darlo por no vinculado.

Con el `#N` resuelto, trae el contenido del issue:
```bash
gh issue view <N> --json number,title,body,state,url
```
Extrae `body` (User Story + descripción + criterios de aceptación, según `issue-convention.md`) y `url` para referenciarlo en la PR.

Si `gh` no está disponible o falla, informa al usuario y pídele que pegue manualmente el objetivo y los criterios de aceptación, o pasa al Paso 1b si tampoco hay issue.

## Paso 1b — Cuando la PR no tiene issue vinculado

Si tras el Paso 1 no hay ningún issue asociado, **no bloquees el flujo**: maneja la ausencia de forma inteligente y déjala explícita.

1. **Avisa** al usuario que la rama no tiene issue vinculado.
2. **Ofrece crear uno** siguiendo `issue-convention.md` y vincularlo (con `Closes #N` en la PR). Comportamiento por `triggerMode`:
   - `manual` / `ask`: pregunta si prefiere (a) crear el issue ahora y vincularlo, o (b) continuar sin issue. Respeta su elección.
   - `auto`: continúa **sin** issue (no interrumpe el flujo automático), pero registra en el chat que la PR queda sin vincular.
3. Si se continúa sin issue, **arma la PR solo con los commits + el diff**:
   - La `<descripción-breve>` del título y el resumen de la descripción se redactan a partir de los **commits** (no del objetivo de un issue).
   - En la sección de issue relacionado de la plantilla, escribe explícitamente `Sin issue vinculado` en lugar de un `#N`.
   - No añadas ninguna keyword de cierre (`Closes #N`) al cuerpo de la PR.
4. El resto del flujo (título, plantilla, modos, subida) continúa igual.

## Paso 2 — Obtener los commits de la rama

Ejecuta vía Bash, usando como base `productionBranch` si la rama es `hotfix/`, o `baseBranch` en cualquier otro caso (mismo criterio que la sección "Rama destino"):

```bash
git log <base>..<nombre_de_rama> --oneline --no-merges
```

Usa los mensajes de commit para entender qué cambios se realizaron y redactar la descripción.

## Paso 3 — Resolver el template de descripción

Si existe `.github/pull_request_template.md` en el repo, **léelo y úsalo como base** (fuente única de verdad). Si no existe, usa la plantilla embebida en la sección "Descripción de la PR" de esta regla.

## Paso 4 — Siempre: escribir el markdown de la PR

Independientemente del modo, **siempre** generas un archivo markdown con el contenido completo de la PR (título + descripción) y lo guardas en `draftsDir` con el nombre de la rama:

```
<draftsDir>/<nombre-de-la-rama>.md
```

Ejemplo: rama `feat/DTA-014` → `docs/pull-requests/feat-DTA-014.md` (sustituye `/` por `-` en el nombre del archivo).

## Paso 5 — Comportamiento según `triggerMode`

### `manual`
Te detienes después de escribir el archivo. No subes nada. Informa la ruta del archivo generado y termina. No crear commits, no hacer push, no abrir PRs.

### `ask`
1. Muestra en el chat el **contenido completo** del markdown generado.
2. Muestra además la **rama destino** de la PR, la lista de **reviewers candidatos** (de `pr-config.json`) y las **labels sugeridas** (ver "Otras configuraciones").
3. Espera a que el usuario **apruebe por escrito** (ej. "apruebo", "súbela", "adelante"). Sin aprobación explícita escrita, NO subes la PR.
4. Tras la aprobación, sube la PR usando el archivo como descripción (ver "Cómo subir la PR").

### `auto`
1. Toma el archivo generado y úsalo como descripción de la PR.
2. Asigna labels automáticamente según el sentido lógico de los cambios (ver "Otras configuraciones").
3. Deja los **reviewers vacíos**, salvo que apliquen los configurados (ver "Reviewers").
4. Sube la PR sin pedir confirmación (ver "Cómo subir la PR").

> Nota de seguridad: subir una PR es una acción que publica contenido. En modo `auto` está pre-autorizada por esta configuración; en `ask` requiere tu visto bueno explícito en el chat.

## Rama destino (base) de la PR

La rama destino se determina por el tipo de la rama de trabajo, en línea con la nomenclatura de ramas del repositorio:

- Si la rama es de tipo **`hotfix`** (prefijo `hotfix/`) → la PR apunta a **producción** (`productionBranch`).
- **Cualquier otro tipo** (`fix/`, `feat/`, etc.) → la PR apunta a **`baseBranch`**.

Al crear la PR, especifica explícitamente la base:

```
gh pr create --base <rama-destino> --head <rama-de-trabajo> ...
```

Nunca abras una PR contra `master` salvo que la rama sea un **hotfix** o se trate del merge de release `development → master`; y nunca contra la rama remota `main` (contiene solo el commit inicial y no es producción). Ante la duda, usa `baseBranch` y avisa al usuario.

## Título de la PR

Formato:

```
[<icon> <type>: <branchProjectCode>-<numero>] - <descripción-breve>
```

`<branchProjectCode>-<numero>` se extrae directamente del nombre de la rama (ej. `DTA-014`). `type`/`icon` se infieren del **tipo de la rama** — ya no hace falta preguntarle a un issue tracker externo:

| Tipo de rama | Type | Icon |
|---|---|---|
| `feat` | `Feat` | ✨ |
| `fix` | `Fix` | 🛠️ |
| `hotfix` | `Hotfix` | 🚨 |
| `refactor` | `Refactor` | 🧹 |
| `docs` | `Doc` | 📝 |
| `chore` | `Chore` | 🗑️ |
| `build` | `Build` | ✅ |
| `test` | `Test` | 🧪 |
| cualquiera con `!` (breaking change) | `Break` | ❌ |

Reglas:
- El ID de la rama (ej. `DTA-014`) **siempre** se incluye en el título; es el identificador interno de la rama, independiente de que haya o no issue vinculado.
- `<descripción-breve>` se redacta a partir del **objetivo/User Story** del issue vinculado. Si la rama no tiene issue (ver Paso 1b), redáctala a partir de los **commits** de la rama. Por debajo de ~60 caracteres, en español salvo que el material fuente esté en otro idioma.
- Mantén el título completo por debajo de **72 caracteres** cuando sea posible.
- `Hotfix` se reserva para parches de emergencia; los bug fixes normales usan `Fix`.

Antes de guardar el archivo, **muestra la sugerencia de título por chat**:

```
💡 Título sugerido para la PR:
[<icon> <type>: <branchProjectCode>-<numero>] - <descripción-breve>
```

Si el usuario desea modificarlo, aplica los cambios antes de continuar.

Ejemplos:
```
[✨ Feat: DTA-014] - Elegir mercados seguidos desde ajustes
[🛠️ Fix: DTA-021] - Corregir redondeo del convertidor
[📝 Doc: DTA-025] - Documentar el tooling agéntico
```

## Descripción de la PR

Plantilla base (usa `.github/pull_request_template.md` si existe; si no, esta):

```markdown
# Descripción

Incluye un resumen de los cambios y el problema relacionado (en caso de que hubiera uno). Enumere las dependencias necesarias para este cambio.

Issue de GitHub relacionado: usa una keyword de cierre con el número del issue (ej. `Closes #23`) si la rama tiene issue vinculado; si no, escribe `Sin issue vinculado`.

## Tipo de cambio

Marque con una x dentro de los `[]` los que apliquen

- [ ] ✨ Nueva funcionalidad (cambio no-breaking que agrega funcionalidad)
- [ ] 🛠️ Corrección de errores (cambio no-breaking que arregla un error)
- [ ] ❌ Cambio importante (arreglo o característica que haría que la funcionalidad existente no funcionara como se esperaba)
- [ ] 📝 Actualización de la documentación
- [ ] 🧹 Code refactoring (modificación de la estructura interna del código sin modificar las APIs)
- [ ] ✅ Build configuration change (modificación de los archivos para hacer deploy)
- [ ] 🗑️ Chore (actividades que no modifican la interacción con la app, por ejemplo, modificar el archivo de lints)

## ¿Cómo se ha probado esto?

Describa las pruebas que ejecutó para verificar los cambios. Proporcione instrucciones para que podamos reproducir. Indique también cualquier detalle relevante para su configuración de prueba

- [ ] Ejemplo A
- [ ] Ejemplo B

**Configuración de prueba**:

- Plataforma y versión de SO (Android / iOS)
- Dispositivo o emulador
- Tema (claro/oscuro) e idioma probados

## Lista de Verificación

- [ ] He agregado las nuevas dependencias (`pubspec.yaml`) en la descripción
- [ ] He agregado las nuevas variables de entorno (solo los nombres) a la descripción
- [ ] Mi código sigue las pautas de estilo de este proyecto
- [ ] He realizado una auto-revisión de mi código
- [ ] He comentado mi código, particularmente en áreas difíciles de entender
- [ ] He realizado los cambios correspondientes a la documentación
- [ ] `flutter analyze` no reporta nuevas advertencias
- [ ] `flutter test` pasa localmente con mis cambios
- [ ] La app compila y el flujo afectado se probó en un dispositivo o emulador real
- [ ] Si agregué copy nueva a la UI, la clave existe en los 10 idiomas (ver `i18n-convention.md`)
- [ ] Si agregué o modifiqué una fuente de datos, un controlador o un helper de cálculo, incluí sus tests en este mismo PR (ver `test-coverage.md`)
- [ ] No introduje modelos (`shared/data/model/`) en la UI ni en los controladores (ver `entities-vs-models.md`)
```

Pautas de llenado (usa el objetivo/criterios del issue vinculado —si existe— + los commits):
- **Descripción**: resumen claro de los cambios basado en el objetivo del issue y los commits; si no hay issue (Paso 1b), básate solo en los commits y el diff. Cuando aplique, una lista numerada de cambios concretos (qué se corrigió/eliminó/añadió y por qué). Incluye el ID de la rama (ej. `DTA-014`) y, si hay issue, la keyword de cierre (`Closes #N`).
- **Tipo de cambio**: marca con `x` solo el/los tipo(s) que correspondan según el tipo de la rama y los cambios reales.
- **¿Cómo se ha probado esto?**: lista los flujos relevantes que deben verificarse según los cambios; sustituye los ejemplos por pasos reales. Si el cambio toca UI, indica en qué tema e idioma se verificó.
- **Lista de Verificación**: marca con honestidad solo lo realmente cumplido; no marques pruebas que no se ejecutaron.
- **Capturas**: si el cambio es visible en pantalla, adjunta capturas antes/después.

## Otras configuraciones

### Labels
Toda PR se etiqueta automáticamente, **en cualquier `triggerMode`**, según el tipo de la rama:

1. **Label por tipo (obligatoria):** aplica la label de `labelsByType[<tipo-de-rama>]` de `.claude/pr-config.json`. El mapa actual es:

   | Tipo de rama | Label |
   |---|---|
   | `feat` | `enhancement` |
   | `fix` / `hotfix` | `bug` |
   | `refactor` | `refactor` |
   | `docs` | `documentation` |
   | `chore` | `chore` |
   | `build` | `build` |
   | `test` | `test` |
   | `ci` | `ci` |
   | `style` | `style` |
   | `perf` | `performance` |

2. **Labels adicionales por contexto:** añade también las que tengan sentido con la naturaleza real del cambio, infiriéndolas de los archivos tocados, los commits y, sobre todo, **las labels del issue vinculado** (p. ej. un issue con `security` o `performance` propaga esa label a la PR).

3. Si una label del mapa no existe en el repo, créala con `gh label create` (o avisa) antes de aplicarla; nunca falles la subida por una label faltante.

Comportamiento por modo:
- `auto`: aplica las labels sin preguntar.
- `ask`: **propón** las labels en el chat junto con la PR; aplícalas al subir tras la aprobación.

### Asignación (assignee)
- Si `assignSelf` es `true` (por defecto), **toda** PR se auto-asigna a `selfAssignee` (o `@me` si no está definido), en cualquier `triggerMode`. Es la persona responsable de dar seguimiento/probar la PR.
- El *assignee* es independiente del *reviewer*: uno indica responsable, el otro revisor.

### Reviewers
- Los reviewers candidatos del equipo viven en `.claude/pr-config.json`, en la clave `reviewers` (un array que puede contener varios nombres/usuarios de GitHub).
- En modo `ask`: muestra esa lista de candidatos para que el usuario elija.
- En modo `auto`: deja los reviewers **vacíos por defecto**. Solo añade un reviewer si su nombre/usuario coincide con alguno de la lista `reviewers` configurada y tiene sentido para el cambio. Si la lista está vacía o no hay coincidencia, no asignes reviewers.
- Nota: GitHub no permite asignarse a uno mismo como reviewer de la propia PR; por eso el auto-seguimiento se hace vía *assignee*, no vía *reviewer*.

## Cómo subir la PR (modos `ask` aprobado y `auto`)

Usa la herramienta disponible, priorizando **GitHub CLI**:

1. Si `gh` está disponible, usa:
   ```
   gh pr create --base <rama-destino> --title "<título>" --body-file "<ruta-del-md>" \
     --assignee "<selfAssignee|@me>" \
     --label "<label-por-tipo>" [--label "<label-adicional>" ...] \
     [--reviewer "<reviewer>" ...]
   ```
   El cuerpo de la PR debe ser el archivo markdown generado (`--body-file`), no texto reescrito. La `<rama-destino>` se determina según la sección "Rama destino (base) de la PR".
   - `--assignee`: si `assignSelf` es `true`, incluye SIEMPRE `selfAssignee` (o `@me`). Ver "Asignación (assignee)".
   - `--label`: incluye SIEMPRE la label de `labelsByType[<tipo-de-rama>]`, más las adicionales por contexto. Ver "Labels".
   - Si la PR ya existe, aplica lo mismo con `gh pr edit <n> --add-assignee ... --add-label ...`.
2. Si `gh` no está disponible pero hay un conector MCP de GitHub configurado, úsalo para crear la PR con el mismo título, cuerpo, labels y reviewers.
3. Si no hay ninguna de las dos, deja el archivo escrito (como en modo `manual`) e informa al usuario que no fue posible subir automáticamente.

Si la rama tiene issue vinculado, asegúrate de que el cuerpo de la PR incluya la keyword de cierre (`Closes #N`) para dejar el vínculo registrado; si no lo tiene (Paso 1b), no la incluyas.

⚠️ Las keywords **solo surten efecto** cuando la PR apunta a la rama por defecto (`master`), y eso es lo que se quiere: **un issue se cierra cuando el trabajo llega a `master`, no al mergear a `development`** — ver `branch-naming.md`.

Así que incluye `Closes #N` igualmente: queda registrada y dispara sola en la promoción de release. Tras mergear a `development`, **no cierres el issue**: deja el comentario con rama, PR, commit de merge y el estado de los criterios de aceptación (plantilla en `branch-naming.md`).

Tras subir, devuelve la URL de la PR creada.
