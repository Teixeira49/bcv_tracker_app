# Guía de Contribución - BCV Tracker App 🤝

¡Gracias por tu interés en contribuir a **BCV Tracker**! Este documento detalla las reglas de implementación, la estructura arquitectónica y el flujo de trabajo para mantener el proyecto limpio, escalable y eficiente.

Las convenciones de este repositorio son **las mismas del backend** ([`bcv_tracker_backend`](https://github.com/Teixeira49/bcv_tracker_backend)) en todo lo que toca al flujo de trabajo (issues, ramas, commits, PR, releases), y están adaptadas a Flutter/Dart/GetX en lo técnico. Viven versionadas en [`.agents/rules/`](.agents/rules/).

---

## 🏛️ Guía de Arquitectura

El proyecto usa una estructura **feature-first** con separación de capas. Sigue este esquema al agregar funcionalidades:

### 1. `lib/features/<feature>/`
Módulos autocontenidos (`splash`, `home`, `converter`, `settings`, `dashboard`), cada uno con:
- **`presentation/controller/`** — controladores de GetX. Contienen la lógica de la vista y exponen estado reactivo (`.obs`). **Cero widgets aquí.**
- **`presentation/page/` y `presentation/widget/`** — la UI. **Cero lógica de negocio**: los widgets leen el estado del controlador con `Obx`/`GetBuilder` y disparan acciones.
- **`domain/entities/`** — entidades propias del feature.

### 2. `lib/shared/`
- **`domain/entities/`** — entidades del dominio (`Currency`, `BcvCurrencies`, `Market`, `Language`). No saben nada de JSON ni de HTTP.
- **`domain/repositories/`** — interfaces (`IDollarRepository`).
- **`data/datasource/`** — acceso a la red (`DollarApiRest`, sobre Dio). Es la **frontera**: deserializa y devuelve entidades.
- **`data/model/`** — espejo del contrato JSON del backend (`.fromJson()` / `.toEntity()`). **Nunca salen de esta capa.**
- **`data/repositories/`** — implementaciones y estado compartido (`CurrencyRepository`, un `GetxService`).

### 3. `lib/core/`
Utilidades transversales: cliente HTTP (`network/`), internacionalización (`i18n/`), constantes (`constants/`) y helpers de cálculo y formato (`helpers/`).

### 4. `lib/config/`
Rutas (`routes/`), tema (`theme/`), carga de entorno (`enviroment/`) y **el grafo de dependencias** (`bindings/initial_bindings.dart`).

### Flujo de datos

```
REST API
  → DollarApiRest (datasource, Dio)
  → DollarRepository (implementa IDollarRepository)
  → CurrencyRepository (GetxService, estado compartido)
  → HomeController / ConverterController (observan con ever())
  → Vistas (Obx / GetBuilder)
```

---

## 🛠️ Reglas de Implementación

Cada punto tiene su regla detallada en [`.agents/rules/`](.agents/rules/):

1. **Entidades, nunca modelos, fuera de la capa de datos** — convierte con `.toEntity()` en la frontera → [`entities-vs-models.md`](.agents/rules/entities-vs-models.md)
2. **Inyección de dependencias solo en `initial_bindings.dart`** — resuelve con `Get.find()`, nunca instancies un controlador en un widget → [`dependency-injection.md`](.agents/rules/dependency-injection.md)
3. **Navegación con rutas nombradas** — `Get.toNamed` / `Get.offAllNamed`, nunca `Navigator` → [`navigation-convention.md`](.agents/rules/navigation-convention.md)
4. **Cero strings literales en la UI** — todo vía `AppMessages`, con la clave en los 10 idiomas → [`i18n-convention.md`](.agents/rules/i18n-convention.md)
5. **Cero valores mágicos** — constantes en `core/constants/` y `config/theme/` → [`constants-centralization.md`](.agents/rules/constants-centralization.md)
6. **Variables de entorno sincronizadas** — `Environment`, `.env.example`, README y `codemagic.yaml` → [`environment-variables.md`](.agents/rules/environment-variables.md)
7. **Tests en el mismo PR** — toda fuente, endpoint, controlador o helper de cálculo nace con sus tests → [`test-coverage.md`](.agents/rules/test-coverage.md)
8. **Documentación en el mismo PR** — dartdoc que explique el porqué → [`documentation-convention.md`](.agents/rules/documentation-convention.md)
9. **Formateo**: `dart format .` antes de commitear. `flutter analyze` debe quedar sin nuevas advertencias.

---

## 🔄 Flujo de Trabajo (Workflow)

### Ramas de larga vida

| Rama | Rol |
|---|---|
| `master` | **Producción** y rama por defecto de GitHub. Solo recibe merges de release (`development → master`) y de `hotfix/`. |
| `development` | **Integración.** Destino por defecto de todas las PR de trabajo. |

```
feat/DTA-00X ─┐
fix/DTA-00Y  ─┼──▶ development ──(release)──▶ master ──▶ tag vX.Y.Z
                                    ▲                      │
                     hotfix/DTA-00Z ┴──────────────────────┘
```

> La rama remota `main` solo contiene el commit inicial: no es producción, no la uses.

### Pasos

1. **Crea el issue** con el formato del repositorio → [`issue-convention.md`](.agents/rules/issue-convention.md)
   ```bash
   gh issue create --title "[✨ feat]: <objetivo>" --body "..." --label enhancement --assignee "@me"
   ```
2. **Crea y vincula la rama** (`<tipo>/DTA-<núm>`) → [`branch-naming.md`](.agents/rules/branch-naming.md)
   ```bash
   gh issue develop <n> --name "feat/DTA-002" --base development --checkout
   ```
3. **Instala dependencias y configura el entorno**:
   ```bash
   flutter pub get
   cp .env.example .env    # y completa CURRENCY_BACK
   ```
4. **Implementa** siguiendo las guías de arquitectura de arriba.
5. **Commitea** con Conventional Commits + gitmoji → [`commit-convention.md`](.agents/rules/commit-convention.md)
   ```
   ✨ feat(converter): add pivot conversion for non-VES pairs
   ```
6. **Prueba localmente** — no basta con que compile:
   ```bash
   flutter analyze
   flutter test
   flutter run             # verifica el flujo en un dispositivo o emulador
   ```
7. **Abre el PR** con la plantilla del repositorio, incluyendo `Closes #N` → [`pull-request.md`](.agents/rules/pull-request.md)

---

## 🏷️ Versionado y Changelog

El proyecto sigue **[Semantic Versioning](https://semver.org/lang/es/)** (`MAJOR.MINOR.PATCH`, con tags `vX.Y.Z`) y mantiene un historial formal en `CHANGELOG.md` con el formato **[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)**.

### Cómo elegir el incremento (SemVer)

| Cambio predominante | Parte que sube | Ejemplo |
|---|---|---|
| Breaking change (`!` o footer `BREAKING CHANGE:`) | **MAJOR** | `v1.0.0` → `v2.0.0` |
| `feat` (nueva funcionalidad no-breaking) | **MINOR** | `v1.0.0` → `v1.1.0` |
| `fix`, `perf`, `refactor`, `docs`, `build`, `chore`… | **PATCH** | `v1.0.0` → `v1.0.1` |

En una app instalada cuenta como **breaking** lo que rompe instalaciones existentes: un formato incompatible en lo persistido con `SharedPreferences`, subir el `minSdkVersion`/deployment target, o exigir una versión de backend que la anterior no soportaba.

### Proceso de release

El changelog **no se edita en cada commit**: se actualiza al **lanzar una versión**, a partir de un **PR ya aprobado y mergeado**. Por cada release:

1. Se determina la versión nueva según la tabla SemVer.
2. Se actualiza `version:` en **`pubspec.yaml`**, la única fuente que se edita — Android, iOS y `codemagic.yaml` la derivan (ver [`version-sources.md`](.agents/rules/version-sources.md)); el build number nunca baja.
3. Se escribe la nota detallada en `docs/release/RELEASE_v<X.Y.Z>.md`.
4. Se agrega una entrada concisa al tope de `CHANGELOG.md`.
5. Se promueve `development → master` con una PR de release (la única, junto a los hotfix, que apunta a producción).
6. Se crea el **GitHub Release** con el tag `vX.Y.Z` sobre `master`.

El detalle completo, con los gates de confirmación, vive en [`.agents/rules/release-versioning.md`](.agents/rules/release-versioning.md).

---

## 🌐 Nuevos Mercados o Divisas

Si deseas agregar un mercado nuevo:

1. Añade el mercado y sus modos permitidos a `Markets` (`lib/core/constants/market_constants.dart`), respetando el contrato del backend.
2. Verifica que el endpoint exista en `DollarEndpoints`; si el contrato cambió, documenta la versión de backend que lo introdujo.
3. Ajusta la deserialización en `shared/data/model/` y la normalización en `shared/data/mapper/`.
4. Expón el mercado en la selección de ajustes (`SettingsController`) y añade su copy en los 10 idiomas.
5. Agrega los tests de mapeo y de selección en el mismo PR.

---

## 🤖 Tooling Agéntico (`.agents/` y `.claude/`)

Este repositorio versiona un conjunto de **convenciones y capacidades para asistentes de IA** (Claude Code y compatibles), de forma que todo el equipo desarrolle con las mismas reglas y atajos sin configuración adicional. Al clonar el repo ya vienen incluidos.

```
.agents/
├── rules/    # Convenciones obligatorias del repositorio
└── skills/   # Capacidades instalables (guías de Flutter/Dart)

.claude/
├── pr-config.json     # Config compartida que leen las reglas
└── skills/            # 21 symlinks → ../../.agents/skills/<nombre>
```

Las skills viven **solo** en `.agents/skills/`; `.claude/skills/` son symlinks relativos, uno por skill, porque Claude Code únicamente descubre skills de proyecto desde esa ruta. Así no hay copias que sincronizar: se edita en `.agents/` y basta. Al añadir una skill nueva, crea también su enlace:

```bash
ln -s ../../.agents/skills/<nombre> .claude/skills/<nombre>
```

Las reglas **no** se enlazan: `.claude/rules/` se carga en cada sesión y 16 reglas saturarían el contexto. Se consultan desde `CLAUDE.md` / `AGENTS.md`.

- **`rules/`** — las 16 convenciones listadas arriba, en el flujo `issue → rama → commits → PR → release` más las reglas técnicas de la app.
- **`skills/`** — 21 skills de cuatro orígenes: 15 de [`dart-expert-skills`](https://github.com/Poorgramer-Zack/dart-expert-skills) (de 37, revisadas una por una contra el código), 5 traídas para cubrir navegación y UI ([`ngxtm/devkit`](https://github.com/ngxtm/devkit), [`dhruvanbhalara/skills`](https://github.com/dhruvanbhalara/skills), [`ChunkyTofuStudios/flutter-skills`](https://github.com/ChunkyTofuStudios/flutter-skills), todas MIT) y **`getx-architecture`, escrita en este repo** porque ningún catálogo externo cubre GetX. Procedencia y licencia en [`.agents/ATTRIBUTION.md`](.agents/ATTRIBUTION.md) y en `skills-lock.json`.
- **`CLAUDE.md` y `AGENTS.md`** — instrucciones de agente, **byte-idénticas** (`diff CLAUDE.md AGENTS.md`). Claude Code lee `CLAUDE.md` e ignora `AGENTS.md`; otros agentes leen `AGENTS.md`. Al editar una, copia sobre la otra en el mismo commit.
- **`.claude/pr-config.json`** — config compartida que leen las reglas: `branchProjectCode: "DTA"`, `baseBranch: "development"`, `productionBranch: "master"`, `triggerMode: "ask"`, `assignSelf` y el mapa `labelsByType`.

> ⚠️ Las **reglas mandan sobre las skills**. Cinco de las skills conservadas todavía traen ejemplos con paquetes ajenos al stack (GoRouter en `sentry-flutter` y `flutter-deeplink`, Freezed en `openapi-to-dart`, BLoC/Riverpod en `flutter-expert`, `screenutil` en `flutter-responsive`); están marcadas como pendientes de adaptar en `.agents/README.md`. Si una skill contradice una regla, gana la regla.

**El índice completo — qué contiene cada regla, cada skill y cómo usarlas — está en [`.agents/README.md`](.agents/README.md).**

### Qué se versiona y qué se ignora

- ✅ **Se versiona**: `.agents/` (rules y skills), `.claude/pr-config.json` y `skills-lock.json`.
- 🚫 **Se ignora** (ver `.gitignore`): config personal/local del asistente (`.claude/settings.local.json`, `.claude/*.local.json`, `.mcp.local.json`), `.env`, `docs/` (salvo `docs/release/`) y artefactos de build.
- **Nunca** subas credenciales, URLs reales de backend ni claves dentro de `.claude/` o `.agents/`.

---

¡Feliz codificación! Si tienes dudas, abre un **Issue** para discutir tu propuesta antes de empezar.
