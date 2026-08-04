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

---

## Modificaciones locales

Las skills marcadas como modificadas **divergen de su origen**. Un `npx skills update` las sobrescribiría: hay que reaplicar los cambios a mano. En `skills-lock.json` llevan el campo `localModifications`.

| Skill | Qué se cambió |
|---|---|
| `getx-navigation` | Se corrigió "Bindings Everywhere" (un `Binding` por ruta) por el binding único de `initial_bindings.dart`; se alinearon los nombres a `AppRoutes`/`AppPages`; se añadieron argumentos de ruta, la distinción tabs-vs-rutas y la deuda conocida del repo |
| `flutter-ui` | Tabla de equivalencias de tokens (`AppSpacing`→`WidthValues.spacingMd`, etc.), estado real de `WidthValues` y aviso de que la app aún es Material 2 |
| `design-polish` | Notas de alcance: solo Android, coste del flujo, y obligación de pasar textos por `AppMessages` y valores por `AppColors`/`WidthValues` |
| `android-emulator` | Se excluyó el directorio `tests/` |
| `flutter-expert` | `references/architecture.md` reescrito de BLoC/GoRouter a GetX + aviso de que la app no es Clean Architecture; aviso en `references/architecture-decision-matrix.md` sobre su calificación de GetX |
| `firebase` | Se eliminó `references/serverpod-mini.md`, documento de Serverpod traspapelado upstream |

## Al añadir una skill nueva

1. Comprueba la licencia del origen **antes** de copiarla: `gh api repos/<owner>/<repo>/license --jq '.license.spdx_id'`. Si devuelve 404, no hay permiso de redistribución — decídelo explícitamente en vez de por omisión.
2. Añádela a este archivo, bajo su origen.
3. Regenera `skills-lock.json` con el hash SHA-256 de su `SKILL.md`.
4. Si la adaptas, anota qué cambiaste aquí y en `localModifications` del lockfile.
