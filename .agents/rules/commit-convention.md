---
description: Formato obligatorio de mensajes de commit (Conventional Commits + gitmoji, estilo extensión vivaxy de VSCode). Aplica a TODOS los commits del repositorio.
---

# Formato de Commits

Al crear cualquier commit, usa **Conventional Commits con gitmoji**, replicando exactamente el formato de la extensión de VSCode "Conventional Commits" (vivaxy) con su configuración por defecto (`gitmoji: true`, `emojiFormat: "code"`).

> Esta convención es **idéntica a la del backend** (`bcv_tracker_backend`), a propósito: ambos repos comparten el mismo mapeo `type → gitmoji → label` para que el flujo issue → rama → commits → PR se lea igual en los dos.

## Estructura de la cabecera

```
<emoji> type(scope): subject
```

- El **gitmoji va primero**, como carácter Unicode (`✨`). GitHub y la mayoría de clientes Git lo renderizan directamente.
- Luego el `type` en minúsculas, seguido del `scope` opcional entre paréntesis.
- Dos puntos y un espacio, luego el `subject`.
- El `subject` va en imperativo y presente ("add", "fix", no "added"/"adds"), sin punto final, en minúscula inicial.
- Un espacio entre el emoji y el `type`.

En esta app el `scope` suele ser el **feature** (`home`, `converter`, `settings`, `splash`, `dashboard`) o la capa compartida (`shared`, `core`, `config`, `i18n`, `theme`, `navigation`).

Ejemplos:

```
✨ feat(converter): add pivot conversion for non-VES pairs
🐛 fix(home): keep skeleton visible while rates are refetched
📝 docs: update env setup for CURRENCY_BACK
♻️ refactor(shared): move currency normalization to the mapper layer
💄 style(theme): align market card padding with the design tokens
```

## Mapeo obligatorio type → gitmoji

Usa SIEMPRE este emoji por tipo (no elijas otros):

| type       | emoji | descripción                                                              |
|------------|-------|--------------------------------------------------------------------------|
| `feat`     | ✨    | Una nueva funcionalidad                                                  |
| `fix`      | 🐛    | Corrección de un bug                                                     |
| `docs`     | 📝    | Cambios solo en documentación                                            |
| `style`    | 💄    | Cambios que no afectan el significado del código (formato, espacios)     |
| `refactor` | ♻️    | Cambio de código que no corrige bug ni añade funcionalidad               |
| `perf`     | ⚡    | Cambio de código que mejora el rendimiento                               |
| `test`     | ✅    | Añadir o corregir tests                                                  |
| `build`    | 👷    | Cambios en el sistema de build o dependencias externas (`pubspec.yaml`, Gradle, CocoaPods, `flutter_launcher_icons`, etc.) |
| `ci`       | 💚    | Cambios en archivos y scripts de configuración de CI (`codemagic.yaml`, workflows) |
| `chore`    | 🔧    | Otros cambios que no modifican `lib/` ni `test/`                         |
| `revert`   | ⏪    | Revierte un commit anterior                                              |

> ⚠️ `💄 style` es para **formato de código** (resultado de `dart format`, orden de imports, espacios). Un cambio de **diseño visual** de la UI no es `style`: es `feat` si añade UI nueva, `fix` si corrige un defecto visual, o `refactor` si reorganiza widgets sin cambiar lo que ve el usuario.

## Reglas adicionales

- **Breaking changes**: añade `!` después del type/scope y, si aplica, un footer `BREAKING CHANGE: <descripción>`.
  ```
  ✨ feat(shared)!: drop v1 currency payload support

  BREAKING CHANGE: the app now requires a backend serving /api/v3
  ```
  En una app móvil, "breaking" incluye lo que **rompe instalaciones existentes**: cambiar la forma de los datos persistidos en `SharedPreferences`, subir el `minSdkVersion`/deployment target, o exigir una versión de backend incompatible con la anterior.
- **Body** (opcional): déjalo separado de la cabecera por una línea en blanco.
- **Footer** (opcional): referencias a issues (`Closes #123`), breaking changes, etc.
- Mantén la cabecera por debajo de ~72 caracteres cuando sea posible.
- Un commit = un cambio lógico coherente. No mezcles features y fixes no relacionados.
- Escribe el `subject` en inglés (es la convención vigente en el historial de este repo).

## Antes de hacer commit

- Verifica con `git status` y `git diff --staged` que solo estás incluyendo lo que pertenece a este commit.
- Elige el `type` por el cambio predominante; si dudas entre `feat` y `fix`, recuerda: `feat` = nueva capacidad, `fix` = corregir comportamiento existente.
- Comprueba que el árbol queda limpio antes de commitear:
  ```bash
  flutter analyze
  flutter test
  ```
- **Nunca** incluyas en el commit `.env`, `build/`, `.dart_tool/` ni artefactos locales (ver `.gitignore`).
- Si añades copy nueva a la UI, el commit debe traer la clave en **los 10 idiomas** (ver `i18n-convention.md`); un commit que agregue texto en un solo idioma está incompleto.
