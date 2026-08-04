# Atribución de las skills de `.agents/skills/`

Este directorio contiene material de terceros. Aquí queda registrado de dónde viene cada skill y bajo qué licencia, para cumplir con las condiciones de redistribución y para que cualquiera pueda auditar la procedencia. El detalle máquina-legible (commit de origen y hash SHA-256 por skill) vive en [`skills-lock.json`](../skills-lock.json).

Este repositorio se distribuye bajo **Apache License 2.0** (ver [`LICENSE`](../LICENSE)). Las skills de terceros conservan la licencia de su origen; la licencia del repo no se les aplica.

---

## Por origen

### `ngxtm/devkit` — MIT

> Copyright (c) ngxtm. Licencia MIT — https://github.com/ngxtm/devkit/blob/main/LICENSE

| Skill | Ruta de origen | Modificada |
|---|---|---|
| `getx-navigation` | `rules/flutter/getx-navigation/` | Sí — ver abajo |

### `dhruvanbhalara/skills` — MIT

> Copyright (c) Dhruvan Bhalara. Licencia MIT — https://github.com/dhruvanbhalara/skills/blob/main/LICENSE

| Skill | Ruta de origen | Modificada |
|---|---|---|
| `flutter-ui` | `skills/flutter/flutter-ui/` | Sí — ver abajo |
| `flutter-fix-layout-issues` | `skills/flutter/flutter-fix-layout-issues/` | No |

### `ChunkyTofuStudios/flutter-skills` — MIT

> Copyright (c) Chunky Tofu Studios. Licencia MIT — https://github.com/ChunkyTofuStudios/flutter-skills/blob/main/LICENSE

| Skill | Ruta de origen | Modificada |
|---|---|---|
| `design-polish` | `skills/design-polish/` | Sí — ver abajo |
| `android-emulator` | `skills/android-emulator/` | Sí — se excluyó `tests/` (suite bats del propio script, sin utilidad aguas abajo) |

### `vercel-labs/skills` — MIT

> Copyright (c) Vercel Labs. Licencia MIT — https://github.com/vercel-labs/skills/blob/main/LICENSE

| Skill | Ruta de origen | Modificada |
|---|---|---|
| `find-skills` | `skills/find-skills/` | Sí — nota sobre el flujo de instalación de este repo |

### `anthropics/skills` — Apache-2.0 (por skill)

> Copyright (c) Anthropic. **El repositorio no declara licencia a nivel raíz**, pero cada skill incluye su propio `LICENSE.txt` con la Apache License 2.0, que es la concesión efectiva y viaja con el archivo — exactamente lo que Apache-2.0 exige. Es la situación más limpia de las cinco fuentes.

| Skill | Ruta de origen | Modificada |
|---|---|---|
| `skill-creator` | `skills/skill-creator/` | No |

> `frontend-design` **se retiró**: su contenido útil vive fusionado en `flutter-design` (ver abajo). Al no reusar el nombre, deja además de sobreescribir a la skill homónima incluida de serie en Claude Code.

### `Poorgramer-Zack/dart-expert-skills` — ⚠️ sin licencia declarada

> El repositorio de origen **no publica ningún archivo de licencia** (ni `LICENSE`, ni mención en el README) a fecha de 2026-08-03, commit `01677fb`. Sin una licencia explícita, el default legal es *todos los derechos reservados*: no hay concesión formal de redistribución.
>
> Se ha abierto un issue upstream pidiendo que declaren una. **Mientras no la haya, estas 15 skills están aquí sin permiso expreso.** Si el autor declina o no responde, la decisión es retirarlas o sustituirlas por equivalentes con licencia clara.

| Skills | Ruta de origen |
|---|---|
| `codemagic`, `effective-dart`, `firebase`, `fl-chart`, `flutter-animate`, `flutter-deeplink`, `flutter-expert`, `flutter-isolate`, `flutter-responsive`, `flutter-shared-preferences`, `flutter-testing`, `github-actions`, `marionette`, `openapi-to-dart`, `sentry-flutter` | `skills/<nombre>/` |

### Propias de este repositorio — Apache 2.0

| Skill | Nota |
|---|---|
| `getx-architecture` | Escrita a partir del código de la app. El catálogo externo no tiene ninguna skill de GetX. |

### Obra derivada — Apache-2.0 AND MIT

**`flutter-design`** funde dos skills que por separado no servían: `frontend-design` (Anthropic, Apache-2.0) está escrita para páginas web, y `flutter-mobile-design` (majiayu000, MIT) mezcla diseño con arquitectura Riverpod/BLoC.

Ambas licencias permiten obra derivada, con condiciones que **sí** hay que cumplir y están cumplidas:

- Los dos avisos de copyright viajan íntegros dentro de la skill: [`LICENSE-Apache-2.0.txt`](skills/flutter-design/LICENSE-Apache-2.0.txt) y [`LICENSE-MIT.txt`](skills/flutter-design/LICENSE-MIT.txt).
- Los **cambios están declarados** en la cabecera del `SKILL.md`, como exige Apache-2.0 §4(b): qué se eliminó (web, arquitectura), qué contradicciones se resolvieron y a qué tokens se reancló.
- El lockfile registra `sourceType: derived` con el `sourceCommit` de cada origen.

| Se conservó de `frontend-design` | Se conservó de `flutter-mobile-design` |
|---|---|
| Calibración anti-slop (los tres looks), proceso de dos pasadas, contención, y toda la sección de escritura en la interfaz | `ColorScheme` semántico, escala tipográfica de M3, moción, layout, convenciones de iOS/Android y checklists |

---

## Modificaciones locales

Las skills marcadas como modificadas **divergen de su origen**. Un `npx skills update` las sobrescribiría: hay que reaplicar los cambios a mano. En `skills-lock.json` llevan el campo `localModifications`.

| Skill | Qué se cambió |
|---|---|
| `getx-navigation` | Se corrigió "Bindings Everywhere" (un `Binding` por ruta) por el binding único de `initial_bindings.dart`; se alinearon los nombres a `AppRoutes`/`AppPages`; se añadieron argumentos de ruta, la distinción tabs-vs-rutas y la deuda conocida del repo |
| `flutter-ui` | Tabla de equivalencias de tokens (`AppSpacing`→`WidthValues.spacingMd`, etc.), estado real de `WidthValues` y aviso de que la app aún es Material 2 |
| `design-polish` | Notas de alcance: solo Android, coste del flujo, y obligación de pasar textos por `AppMessages` y valores por `AppColors`/`WidthValues` |
| `android-emulator` | Se excluyó el directorio `tests/` |
| `find-skills` | Nota de que una instalación con `npx skills add` no basta en este repo: hay que comprobar la licencia, registrar la skill en `skills-lock.json` y en este archivo, y crear el symlink en `.claude/skills/` |
| `flutter-expert` | `references/architecture.md` reescrito de BLoC/GoRouter a GetX + aviso de que la app no es Clean Architecture; aviso en `references/architecture-decision-matrix.md` sobre su calificación de GetX |
| `firebase` | Se eliminó `references/serverpod-mini.md`, documento de Serverpod traspapelado upstream |

## Al añadir una skill nueva

1. Comprueba la licencia del origen **antes** de copiarla: `gh api repos/<owner>/<repo>/license --jq '.license.spdx_id'`. Si devuelve 404, no hay permiso de redistribución — decídelo explícitamente en vez de por omisión.
2. Añádela a este archivo, bajo su origen.
3. Colócala en `.agents/skills/<nombre>/` — nunca directamente en `.claude/skills/`.
4. Regenera `skills-lock.json` con `source`, `license`, `sourceCommit` y el hash SHA-256 de su `SKILL.md`.
5. Crea el symlink para que Claude Code la descubra: `ln -s ../../.agents/skills/<nombre> .claude/skills/<nombre>`.
6. Si la adaptas, anota qué cambiaste aquí y en `localModifications` del lockfile.
