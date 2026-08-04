---
description: Nomenclatura de ramas de git y su issue de GitHub asociado. Aplica cada vez que se vaya a crear una rama nueva en este repositorio.
---

# Nomenclatura de Ramas

Este proyecto no usa Jira: el ID de cada rama lo genera y lleva la cuenta el propio repositorio (no un ticket externo). Cada rama se vincula a un issue de GitHub, pero **el nombre de la rama no depende del issue** ni al revés (ver "Vínculo con el issue de GitHub" más abajo).

## Paso 0 — Leer la configuración

Antes de crear una rama, lee `.claude/pr-config.json` si existe. Usa:

- `baseBranch`: rama base por defecto para todo lo que no sea hotfix.
- `productionBranch`: rama de producción de la que salen los hotfixes.
- `branchProjectCode`: iniciales del proyecto para el ID de rama.

En este repositorio el archivo ya existe en `.claude/pr-config.json` con `branchProjectCode: "DTA"` (DolarTracker App, para distinguir la serie de ramas de la del backend, que usa `DT`), `baseBranch: "development"` y `productionBranch: "master"`.

> **Sobre las ramas de este repo:** hay dos de larga vida. **`master`** es producción y la rama por defecto de GitHub; **`development`** es la rama de integración, creada desde `master`, y es donde se mergea el trabajo del día a día. También existe una rama remota `main`, pero solo contiene el commit inicial y **no** es la rama de producción: no la uses como base ni como destino.

## Base de la rama

- **Hotfix**: se saca **directamente de producción** (`productionBranch`).
- **Todo lo demás** (`fix`, `feat`, etc.): se saca de `baseBranch`.

```bash
git checkout <base>
git pull
git checkout -b <nombre-de-rama>
```

Donde `<base>` es `productionBranch` (`master`) para hotfix, o `baseBranch` (`development`) en cualquier otro caso. Un hotfix sale de producción precisamente para poder llegar a producción sin arrastrar lo que aún esté cocinándose en `development`; después se propaga a `development` para que la corrección no se pierda en el siguiente merge.

## Nomenclatura

```
<tipo>/<branchProjectCode>-<numero>
```

- **tipo**: `feat`, `fix`, `hotfix`, `refactor`, `docs`, `chore`, `build`, `test`, etc. (en minúsculas), coherente con `commit-convention.md`.
- **branchProjectCode**: iniciales del proyecto, `DTA`.
- **numero**: ID secuencial de **una sola serie compartida entre todos los tipos** (no hay una numeración separada para `feat` vs `fix`), con al menos 3 dígitos: `001`, `002`, ... `010`, ... `999`, `1000`...

Ejemplos:
```
feat/DTA-001
fix/DTA-002
feat/DTA-014
```

## Cómo obtener el siguiente número

Antes de crear una rama, calcula el ID más alto ya usado (local y remoto) y usa el siguiente:

```bash
CODE=DTA
git branch --list "*/${CODE}-*"
git ls-remote --heads origin | grep -E "${CODE}-[0-9]+"
```

Extrae el número de cada nombre encontrado (`<tipo>/<CODE>-<numero>`), toma el máximo de todos (sin importar el tipo) y súmale 1. Si no hay ninguna rama previa con ese código, empieza en `001`.

> Las ramas anteriores a esta convención (`feat/api-v2-migration`, `fix/api-v1-migration`) **no** llevan ID y quedan fuera del conteo: no las renombres, solo no las tomes como referencia. La serie `DTA-###` arranca en `001`.

## Vínculo con el issue de GitHub

Cada rama debe estar respaldada por un issue de GitHub, pero el vínculo **no se hace por el nombre** (ni el issue se titula como la rama, ni la rama incluye el título del issue). El issue se crea con su propio formato descriptivo (ver `issue-convention.md`) y la relación issue↔rama se establece con el mecanismo nativo de GitHub: **linked branches** (sección *Development* del issue).

### Mecanismo recomendado: `gh issue develop`

GitHub registra el vínculo issue↔rama en su base de datos (aparece en la sección *Development* del issue), independientemente de cómo se llame la rama. La forma más directa de crearlo es con la CLI:

```bash
gh issue develop <numero-issue> --name "<nombre-de-rama>" --base <base> --checkout
```

- `<numero-issue>`: el número del issue de GitHub (ej. `23`), **no** el ID interno `DTA-###`.
- `--name`: el nombre de rama según la nomenclatura de arriba (`<tipo>/<branchProjectCode>-<numero>`). Si se omite, GitHub genera uno a partir del título del issue.
- `--base`: `productionBranch` para hotfix, o `baseBranch` en cualquier otro caso.
- `--checkout`: cambia a la rama recién creada.

Esto crea la rama, la vincula al issue y la deja lista para trabajar en un solo paso.

### Procedimiento

1. Asegúrate de que exista el issue (créalo con `issue-convention.md` si aún no existe; si falta el objetivo y los criterios de aceptación, pídeselos al usuario).
2. Determina el `<nombre-de-rama>` según la nomenclatura de arriba y la `<base>` correcta.
3. Crea y vincula la rama:
   ```bash
   git checkout <base> && git pull
   gh issue develop <numero-issue> --name "<nombre-de-rama>" --base <base> --checkout
   ```
4. Al abrir la PR desde esa rama (`gh pr create`), el vínculo se propaga y la PR queda enlazada al issue automáticamente.

### Refuerzo con keywords de cierre

Para que el issue se **cierre solo** al mergear, incluye en el cuerpo o los commits de la PR una keyword de cierre referenciando el número del issue:

```
Closes #23
```

Keywords válidas: `close`/`closes`/`closed`, `fix`/`fixes`/`fixed`, `resolve`/`resolves`/`resolved`.

> ⚠️ **Las keywords solo cierran el issue cuando la PR apunta a la rama por defecto del repositorio**, que aquí es `master`. Como el trabajo normal se mergea a `development`, una PR de feature/fix **no** cerrará su issue al mergearse: lo hará más adelante, cuando `development` llegue a `master`. Incluye la keyword igualmente —deja el vínculo registrado y la trazabilidad visible en el issue—, pero **cierra el issue a mano** al mergear a `development` si el trabajo ya está terminado:
>
> ```bash
> gh issue close <N> --comment "Mergeado en development vía PR #<M>"
> ```

### Si `gh` no está disponible

Usa el conector MCP de GitHub si existe. Si tampoco, crea la rama con `git checkout -b <nombre-de-rama>` y vincúlala manualmente desde la sección *Development* del issue en la web; avisa al usuario que debe hacer ese enlace para no perder la trazabilidad.

## Notas

- El `tipo` de rama debe ser coherente con el `type` del issue (`issue-convention.md`), de los commits (`commit-convention.md`) y del título de la PR (`pull-request.md`).
- No incluyas texto descriptivo en el nombre de la rama: solo `<tipo>/<branchProjectCode>-<numero>`. El objetivo, la User Story y los criterios de aceptación viven en el issue (`issue-convention.md`), no en el nombre de la rama.
- El ID interno `DTA-###` identifica la rama dentro del repo; el vínculo formal con el issue lo maneja GitHub (linked branch), no el nombre.
