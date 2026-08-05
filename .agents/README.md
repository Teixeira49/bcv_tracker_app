# `.agents/` — Tooling agéntico de BCV Tracker App

Este directorio versiona las **convenciones y capacidades para asistentes de IA** (Claude Code y compatibles) de la app. Al clonar el repo, todo el equipo trabaja con las mismas reglas sin configuración extra.

Es la contraparte del directorio `.agents/` del backend ([`bcv_tracker_backend`](https://github.com/Teixeira49/bcv_tracker_backend)): el flujo `issue → rama → commits → PR → release` es **idéntico en ambos repos** (mismo mapeo `type → gitmoji → label`), y lo que cambia son las reglas técnicas, adaptadas aquí a Flutter, Dart y GetX.

```
.agents/
├── rules/    # Convenciones obligatorias del repositorio
└── skills/   # Capacidades instalables (guías de Flutter/Dart para el asistente)

.claude/
├── pr-config.json     # Config compartida que leen las reglas
├── rules/             # 16 symlinks → ../../.agents/rules/<nombre>.md
└── skills/            # 24 symlinks → ../../.agents/skills/<nombre>
```

## Por qué `.claude/skills/` son symlinks

Claude Code descubre las skills de proyecto **solo** desde `.claude/skills/<nombre>/SKILL.md`; `.agents/` no es una ruta que conozca. Sin los enlaces, las 24 skills serían documentos inertes que solo funcionan si alguien apunta al agente a la ruta a mano.

La documentación de Claude Code contempla exactamente este caso: *"A `<skill-name>` entry in the enterprise, personal, or project locations can be a symlink to a directory elsewhere on disk."* Por eso el enlace es **por skill**, no del directorio completo.

```bash
# al añadir una skill nueva a .agents/skills/, enlázala también:
ln -s ../../.agents/skills/<nombre> .claude/skills/<nombre>
```

Los enlaces son **relativos**, así que funcionan en cualquier clon. `.agents/skills/` sigue siendo la única fuente: se edita ahí y no hay copias que sincronizar.

> En Windows, crear symlinks exige Modo Desarrollador o permisos de administrador. Quien no los tenga verá los enlaces como archivos de texto con la ruta dentro; las skills seguirán siendo legibles desde `.agents/skills/`, solo no se autocargarán.

## Las reglas también se enlazan, pero con `paths:`

`.claude/rules/*.md` se carga **en cada sesión**, y las 18 reglas suman 1.944 líneas (~29 mil tokens): cargarlas todas siempre inundaría el contexto, y la propia documentación advierte que eso *reduce* la adherencia.

La salida es el frontmatter `paths:`, que hace que una regla se cargue **solo al leer archivos que coincidan**. El reparto:

- **4 sin `paths:` → siempre en contexto** (718 líneas, ~10 mil tokens): `issue-convention`, `branch-naming`, `commit-convention` y `pull-request`. Son procedimientos de git y GitHub: ningún archivo los dispara, así que no hay patrón que darles.
- **14 con `paths:` → bajo demanda**: editar `lib/core/i18n/` trae la regla de i18n y nada más; tocar `pubspec.yaml` trae las tres de versionado.

El `paths:` vive en el frontmatter de `.agents/rules/*.md` junto al `description:`. Otros agentes lo ignoran sin problema; Claude Code lo usa para no cargar lo que no toca.

Las tres cifras de arriba son **derivadas**, así que envejecen en cuanto una regla crece — ya pasó dos veces, y la segunda fue al escribir esta misma sección. Recalcúlalas al editar cualquier regla:

```bash
cat .agents/rules/*.md | wc -l                                             # total
for f in .agents/rules/*.md; do grep -q '^paths:' "$f" || cat "$f"; done | wc -l  # incondicional
```

Y para comprobar que ninguna regla quedó con un `paths:` que no empareja con nada —el fallo que dejó a `release-notes.md` inalcanzable— basta con listar los patrones y probarlos contra el árbol.

> Si algún día `pull-request.md` (333 líneas) molesta en contexto, la salida que sugiere la documentación es convertir los procedimientos en skills: una skill se carga por su descripción, no siempre.

---

## `rules/` — Convenciones del repositorio

Reglas que el asistente debe respetar. Cada archivo lleva un `description` en el frontmatter que indica cuándo aplica.

### Flujo de trabajo (compartidas con el backend)

| Regla | Para qué sirve |
|---|---|
| [`issue-convention.md`](rules/issue-convention.md) | Formato de issues: título `[<emoji> <type>]: <subject>`, User Story, criterios de aceptación, auto-label y auto-asignación |
| [`branch-naming.md`](rules/branch-naming.md) | Nomenclatura de ramas (`<tipo>/DTA-<núm>`) y vínculo con el issue vía *linked branch* |
| [`commit-convention.md`](rules/commit-convention.md) | Conventional Commits + gitmoji (estilo extensión *vivaxy*) |
| [`pull-request.md`](rules/pull-request.md) | Flujo, título, plantilla y disparo de las PR (lee `.claude/pr-config.json`) |
| [`release-versioning.md`](rules/release-versioning.md) | SemVer, bump de `pubspec.yaml`, GitHub Releases y `CHANGELOG.md` |
| [`version-value-proposal.md`](rules/version-value-proposal.md) | Contrasta el número mecánico de SemVer con el valor real entregado al usuario antes de proponerlo |
| [`release-notes.md`](rules/release-notes.md) | `release_notes.json` para Codemagic: formato, locales, límites de las tiendas, y cómo se reparte la historia con el CHANGELOG |
| [`version-sources.md`](rules/version-sources.md) | Los once sitios donde aparece la versión: cuál se edita, cuáles derivan y no se tocan |

### Reglas técnicas de la app (Flutter / Dart / GetX)

| Regla | Para qué sirve |
|---|---|
| [`entities-vs-models.md`](rules/entities-vs-models.md) | Los modelos de `shared/data/model/` **nunca** llegan a la UI ni a los controladores: se convierten con `.toEntity()` en la frontera |
| [`dependency-injection.md`](rules/dependency-injection.md) | Toda dependencia de GetX se registra en `initial_bindings.dart` y se resuelve con `Get.find()` |
| [`navigation-convention.md`](rules/navigation-convention.md) | Navegación con rutas nombradas (`Get.toNamed` / `Get.offAllNamed`), nunca con `Navigator` ni pasando widgets |
| [`i18n-convention.md`](rules/i18n-convention.md) | Cero literales en la UI: todo vía `AppMessages`, con la clave presente en los 10 idiomas |
| [`constants-centralization.md`](rules/constants-centralization.md) | Prohíbe valores "mágicos"; centraliza constantes en `core/constants/` y `config/theme/` |
| [`environment-variables.md`](rules/environment-variables.md) | Sincroniza `Environment`, `.env.example`, README y `codemagic.yaml` al tocar variables de entorno |
| [`test-coverage.md`](rules/test-coverage.md) | Toda fuente, endpoint, controlador o helper de cálculo nace con sus tests en el mismo PR |
| [`documentation-convention.md`](rules/documentation-convention.md) | Todo lo público nace documentado con dartdoc, explicando el porqué y no el qué |
| [`logging-convention.md`](rules/logging-convention.md) | Todo pasa por `AppLogger` con niveles; cada `catch` de un límite registra su causa; en release nada sensible ni URLs en crudo |
| [`design-system.md`](rules/design-system.md) | `DESIGN.md` es la fuente de verdad visual; un token nuevo se declara ahí primero y luego en `config/theme/`; verificar en claro y oscuro |

---

## `skills/` — Capacidades instalables

24 skills de seis orígenes distintos. Cada una es un `SKILL.md` (objetivo, proceso, restricciones) con `references/` opcionales; su procedencia y licencia quedan registradas en **[`ATTRIBUTION.md`](ATTRIBUTION.md)** y, en formato máquina-legible, en **[`skills-lock.json`](../skills-lock.json)** (raíz del repo: `source`, `sourceType`, `license`, `skillPath` y hash SHA-256 por skill).

| Origen | Licencia | Skills |
|---|---|---|
| [`Poorgramer-Zack/dart-expert-skills`](https://github.com/Poorgramer-Zack/dart-expert-skills) | ⚠️ **sin declarar** | 15 |
| [`ngxtm/devkit`](https://github.com/ngxtm/devkit) | MIT | 1 |
| [`dhruvanbhalara/skills`](https://github.com/dhruvanbhalara/skills) | MIT | 2 |
| [`ChunkyTofuStudios/flutter-skills`](https://github.com/ChunkyTofuStudios/flutter-skills) | MIT | 2 |
| [`vercel-labs/skills`](https://github.com/vercel-labs/skills) | MIT | 1 |
| [`anthropics/skills`](https://github.com/anthropics/skills) | Apache-2.0 (por skill) | 1 |
| Derivada de `anthropics/skills` + [`majiayu000/claude-skill-registry`](https://github.com/majiayu000/claude-skill-registry) | Apache-2.0 AND MIT | 1 |
| Propia | Apache-2.0 | 1 |

El catálogo de `dart-expert-skills` trae 37 skills. Se revisaron una por una contra el código de la app y se conservaron 15; las 22 restantes se descartaron por proponer stacks que este proyecto no usa (Riverpod, BLoC, Provider, GoRouter, AutoRoute, Supabase, Serverpod, Freezed…) o funcionalidades que no tiene (login, monetización, SQL local, web).

> ⚠️ **`dart-expert-skills` no declara licencia**, así que esas 15 están aquí sin permiso expreso de redistribución. Hay un [issue upstream abierto](https://github.com/Poorgramer-Zack/dart-expert-skills/issues/6) pidiéndola. Si el autor declina o no responde, se retiran o se sustituyen. Detalle en [`ATTRIBUTION.md`](ATTRIBUTION.md).

### 🏠 Escrita para este proyecto

**`getx-architecture`** — el catálogo externo **no tiene ninguna skill de GetX** (sus tres opciones de estado eran Provider, Riverpod y BLoC), así que esta se escribió a partir del código de la app. Cubre lo que las reglas prescriben pero no explican: `Obx` vs `GetBuilder` vs workers y por qué aquí domina `GetBuilder`; el patrón de estado reactivo en `CurrencyRepository` con getters planos en los controladores; ciclo de vida (`onInit`/`onReady`/`onClose`), `fenix` vs `permanent` vs `GetxService`; en qué capa va cada cosa; y cómo testear un controlador con fakes y `Get.reset()`.

Documenta además dos deudas verificadas contra el código: los `Worker` de `ever()` no se liberan (en `get` 4.7.3 no hay descarte automático y `onClose()` es un no-op vacío, así que cada recreación de un controlador `fenix` deja listeners colgando de un servicio `permanent`), y `main.dart` registra `SettingsController` por duplicado con el binding.

Al ser propia, **no la toca `npx skills update`**: en el lockfile figura con `sourceType: "local"`.

### 🧭 Navegación y UI

Este bloque cubre dos huecos que el catálogo original dejaba abiertos: no tenía **ninguna** guía de navegación con GetX, y su material de UI estaba enterrado dentro de `flutter-expert`.

| Skill | Para qué |
|---|---|
| `getx-navigation` | Rutas nombradas, argumentos, `GetMiddleware`, tabs-vs-rutas, cierre de diálogos. **Adaptada**: el original exigía un `Binding` por ruta, incompatible con nuestro binding único |
| `flutter-ui` | Design tokens obligatorios, const-first, renderizado perezoso, estados de UI y accesibilidad. **Adaptada**: traduce sus nombres genéricos a `AppColors`/`WidthValues` |
| `flutter-fix-layout-issues` | Modelo de constraints y catálogo de overflows. Se empareja con el riesgo de textos largos en alemán y ruso (`i18n-convention.md`) |
| `design-polish` | Pasada de diseño evidencia-en-mano: tono establecido, jerarquía visual, anti-patrones de "esto parece generado". **Solo Android**, y arrastra `android-emulator` |
| `android-emulator` | Dependencia de `design-polish`: capturas, taps y volcado del árbol de accesibilidad vía `scripts/emu.sh` |

> `design-polish` compila, arranca emulador y lanza un subagente evaluador por pantalla: es para una pasada de diseño deliberada, no para ajustar un padding. Y como la app también va a iOS, lo que salga de ahí hay que revisarlo en el simulador de Apple.

### 🧰 Soporte — meta-skills

No hablan de Flutter: sirven para sostener el propio tooling y para asesorar en diseño.

| Skill | Para qué | Nota |
|---|---|---|
| `find-skills` | Descubrir e instalar skills del ecosistema con `npx skills` | **Adaptada**: instalar aquí no termina con `npx skills add` — hay que comprobar licencia, registrar y enlazar |
| `skill-creator` | Crear y mejorar skills, con evals y optimización de descripciones | Sin adaptar. 248 KB de 868 KB del directorio: es la más pesada de las 24 |
| `flutter-design` | Dirección estética **y** ejecución en Material 3: tipografía, color semántico, moción, y escritura de la copy | **Obra derivada**: funde el criterio de `frontend-design` (Apache-2.0) con la ejecución de `flutter-mobile-design` (MIT) |

Las tres reparten el terreno del diseño: `flutter-design` decide **qué debería parecer** algo que no existe, `flutter-ui` da **los tokens** con los que se construye, y `design-polish` comprueba **si una pantalla existente funciona**.

`flutter-design` sustituye al `frontend-design` que estaba vendorizado. Se retiró por dos motivos que se resuelven de una vez: estaba escrita para páginas web, y al llamarse igual que la skill incluida de serie en Claude Code la sobreescribía y se habría ido quedando atrás. Al nombrarla distinto, la de serie sigue disponible para trabajo web genérico y la nuestra gobierna el diseño de esta app.

> ⚠️ `skill-creator` también viene incluida de serie en Claude Code, y **una skill de proyecto sobreescribe a la incluida con el mismo nombre**. Hoy es idéntica al upstream, así que no hay diferencia; pero la copia del repo se congela mientras la de serie se actualiza. Conviene revisarla contra `anthropics/skills` cada cierto tiempo. `flutter-design` ya no tiene ese problema: al ser obra derivada con nombre propio, no sobreescribe nada.

### Alineadas con el stack actual

| Skill | Qué respalda en este repo |
|---|---|
| `effective-dart` | Dart 3.7–3.10; el SDK del proyecto es `^3.9.0` |
| `flutter-expert` | Arquitectura, performance, layout, theming, localización, HTTP/JSON (17 referencias) — **adaptada**, ver abajo |
| `flutter-testing` | Unit, widget, golden e integración; respalda `test-coverage.md` |
| `flutter-shared-preferences` | La persistencia de `SettingsController` |
| `codemagic` | Los tres workflows de `codemagic.yaml` |
| `github-actions` | Checks de PR en GitHub, complementarios al build de Codemagic |
| `marionette` | E2E dirigido por IA sobre la app en debug (hueco que `test-coverage.md` no cubre) |
| `flutter-animate` | Transiciones y shimmer; encaja con `skeletonizer` |
| `flutter-isolate` | Parseo pesado fuera del hilo de UI cuando llegue el histórico |
| `flutter-responsive` | Los `MediaQuery`/`LayoutBuilder` de `base_layout` y los modales |
| `fl-chart` | El histórico y los gráficos que promete el README y aún no existen |
| `firebase` | Hoy `firebase_core` + App Distribution; mañana Analytics y Crashlytics |
| `sentry-flutter` | Reporte de errores en producción (aún no integrado) |
| `flutter-deeplink` | App Links / Universal Links (aún no implementados) |
| `openapi-to-dart` | Migrar contratos del backend desde su OpenAPI |

### ⚠️ Pendientes de adaptar al stack

Estas cuatro se conservan por su contenido, pero **sus ejemplos usan paquetes que este proyecto no usa**. Adáptalas antes de seguirlas al pie de la letra:

| Skill | Qué hay que reescribir |
|---|---|
| `sentry-flutter` | Monta `SentryNavigatorObserver` sobre GoRouter (7 menciones) → pasarlo a un observer de GetX |
| `flutter-deeplink` | Integra los links con GoRouter (7 menciones) → pasarlo a las rutas nombradas de `AppRoutes`; se solapa con `getx-navigation`, que ya está adaptada |
| `openapi-to-dart` | Genera los modelos con Freezed (23 menciones) → aquí el mapeo es manual, `fromJson`/`toEntity` |
| `flutter-responsive` | Empuja `screenutil`, `sizer` y `responsive_framework` (26 menciones) → reescribir a Flutter puro sobre el grid de 8 pt de `WidthValues`. Se solapa con las secciones 5 y 6 de `flutter-ui`, que no dependen de paquetes externos: evalúa si merece quedarse |

### 🎨 Material 3: decidido, no hecho

La app **va a migrar a Material 3**. Hoy sigue en Material 2: `ThemeData` sin `useMaterial3`, paletas `MaterialColor` en `AppColors` y una barra inferior propia (`CustomBottomNavigatorBar`).

Eso cambia el papel de dos skills:

- **`flutter-expert/references/theming.md`** deja de ser un conflicto y pasa a ser **la guía de migración**: `ColorScheme.fromSeed`, retirada de `accentColor`, y el árbol de decisión de widgets legacy (`FlatButton`→`TextButton`, `ToggleButtons`→`SegmentedButton`). Su recomendación de cambiar `BottomNavigationBar` por `NavigationBar` **no aplica**: la barra de esta app es propia.
- **`flutter-ui`** recomienda `context.colorScheme`, que asume M3. Hasta que la migración ocurra, la vía sigue siendo `AppColors`.

> La migración es un cambio de código con impacto visual en toda la app: necesita su **propio issue y su propia rama**, no entra en el trabajo de tooling de `chore/DTA-001`.

### ✅ Ya adaptadas

- **`getx-navigation`** — el original exigía un `Binding` por ruta (`binding: HomeBinding()` en cada `GetPage`), incompatible con el binding único de `initial_bindings.dart`. Corregido, alineado a `AppRoutes`/`AppPages`, y ampliado con paso de argumentos, la distinción tabs-vs-rutas y las tres desviaciones vivas del repo.
- **`flutter-ui`** — lleva una tabla que traduce sus tokens genéricos (`AppSpacing`, `AppRadius`) a los de la app (`WidthValues.spacingMd`, `radiusMd`) y avisa de que `WidthValues` está declarado pero sin usar.
- **`design-polish`** — notas de alcance: solo Android pese a que la app va también a iOS, coste real del flujo, y obligación de pasar los textos por `AppMessages` y los valores visuales por `AppColors`/`WidthValues`.
- **`android-emulator`** — se excluyó `tests/` (76 KB de suite bats del propio script, sin utilidad aguas abajo).
- **`flutter-expert`** — `references/architecture.md` tenía la capa de presentación en `LoginBloc`/`BlocConsumer`/`context.go`; está reescrita a `GetxController`/`Obx`/`Get.offAllNamed`, y lleva un aviso de que la app **no** es Clean Architecture (no hay capa de UseCases). `references/architecture-decision-matrix.md` lleva un aviso al inicio: su tabla califica a GetX como apto para *"rapid prototyping"*, lo cual no describe a este código, y proponer una migración de stack está fuera de alcance salvo issue propio.
- **`firebase`** — se eliminó `references/serverpod-mini.md`, un documento de Serverpod BFF traspapelado upstream. Sus referencias de `auth`, `database`, `storage` y `messaging` describen productos que la app no usa todavía; consérvalas o bórralas cuando se decida el alcance de Firebase.

> Ambas figuran en `skills-lock.json` con el campo `localModifications`. Un `npx skills update` las sobrescribiría: hay que reaplicar los cambios a mano tras actualizar.

> ⚠️ Las reglas de `rules/` mandan sobre las skills. Si una skill sugiere GoRouter, Riverpod o Freezed, gana `navigation-convention.md` / `entities-vs-models.md` / la arquitectura GetX del proyecto.

### Actualizar o añadir skills

Las skills se gestionan con el CLI `npx skills` (mismo flujo que el backend) o copiándolas del repo de origen. En cualquier caso, **commitea los cambios de `.agents/skills/` junto con `skills-lock.json`**:

```bash
npx skills find <query>     # buscar skills en el ecosistema
npx skills add <package>    # instalar una skill
npx skills check            # ver actualizaciones disponibles
npx skills update           # actualizar las skills instaladas
```

Si copias una skill a mano, regenera su entrada del lockfile con el SHA-256 de su `SKILL.md`.

---

## Configuración: `.claude/pr-config.json`

Config compartida que las reglas leen para operar de forma consistente:

| Clave | Valor actual | Para qué |
|---|---|---|
| `branchProjectCode` | `DTA` | Iniciales del proyecto en el ID de rama (el backend usa `DT`) |
| `baseBranch` | `development` | Rama de integración: destino por defecto de las PR |
| `productionBranch` | `master` | Producción y rama por defecto de GitHub; origen y destino de los hotfixes |
| `triggerMode` | `ask` | Nivel de autonomía para subir PR y releases (`manual` \| `ask` \| `auto`) |
| `draftsDir` | `docs/pull-requests/` | Borradores de PR (locales: `docs/` está gitignored) |
| `reviewers` | `[]` | Reviewers candidatos del equipo |
| `assignSelf` / `selfAssignee` | `true` / `Teixeira49` | Auto-asignación de las PR |
| `labelsByType` | ver archivo | Mapa `tipo-de-rama → label` de GitHub |

---

## Qué se versiona y qué se ignora

- ✅ **Se versiona**: `.agents/` (rules y skills), `.claude/pr-config.json` y `skills-lock.json`.
- 🚫 **Se ignora** (ver [`.gitignore`](../.gitignore)): config personal/local del asistente (`.claude/settings.local.json`, `.claude/*.local.json`, `.mcp.local.json`), `.env`, `docs/` (salvo `docs/release/`) y artefactos de build.
- **Nunca** subas credenciales, URLs reales de backend ni claves dentro de `.claude/` o `.agents/`.

## Cómo usarlas

1. Clona el repo: las reglas y las skills ya están disponibles, sin setup extra.
2. Abre un asistente compatible desde la raíz del proyecto; leerá `.agents/` y `.claude/pr-config.json`.
3. Al crear issues, ramas, commits, PR o releases, el asistente aplica las reglas de `rules/`.
4. Para una tarea técnica concreta (tests, animaciones, gráficos, CI), consulta la skill correspondiente en `skills/`.
5. Si el asistente no las carga solo, apúntale al archivo: *"sigue `.agents/rules/commit-convention.md`"*.
