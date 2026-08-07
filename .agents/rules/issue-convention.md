---
description: Formato obligatorio para crear issues de GitHub (título con gitmoji + type, cuerpo con User Story y descripción formal, auto-etiquetado y auto-asignación). Aplica cada vez que se vaya a crear un issue en este repositorio.
---

# Formato de Issues

Al crear cualquier issue de GitHub, usa el formato definido en esta regla. El `type` y el `emoji` se toman de la **misma tabla que los commits** (`commit-convention.md`), para mantener coherencia en todo el flujo: issue → rama → commits → PR.

> Convención compartida con `bcv_tracker_backend`: el mapeo `type → gitmoji → label` es idéntico en ambos repos.

## Estructura del título

```
[<emoji> <type>]: <subject>
```

- El `type` y el `emoji` van juntos **entre corchetes**, en minúsculas el `type` y el gitmoji como carácter Unicode (`✨`).
- Después del corchete de cierre: dos puntos, un espacio y el `subject`.
- El `subject` describe el objetivo del issue en presente, sin punto final, en minúscula inicial.
- Mantén el título por debajo de ~72 caracteres cuando sea posible.

Ejemplos:

```
[🐛 fix]: el convertidor redondea mal los montos con decimales largos
[✨ feat]: permitir elegir qué mercados se siguen desde ajustes
[📝 docs]: documentar la variable CURRENCY_BACK en el README
[♻️ refactor]: mover la normalización de tasas al mapper compartido
```

## Mapeo obligatorio type → gitmoji

Usa SIEMPRE este emoji por tipo (idéntico a `commit-convention.md`, no elijas otros):

| type       | emoji | descripción                                                              |
|------------|-------|--------------------------------------------------------------------------|
| `feat`     | ✨    | Una nueva funcionalidad                                                  |
| `fix`      | 🐛    | Corrección de un bug                                                     |
| `docs`     | 📝    | Cambios solo en documentación                                            |
| `style`    | 💄    | Cambios que no afectan el significado del código (formato, espacios)     |
| `refactor` | ♻️    | Cambio de código que no corrige bug ni añade funcionalidad               |
| `perf`     | ⚡    | Cambio de código que mejora el rendimiento                               |
| `test`     | ✅    | Añadir o corregir tests                                                  |
| `build`    | 👷    | Cambios en el sistema de build o dependencias externas                   |
| `ci`       | 💚    | Cambios en archivos y scripts de configuración de CI                     |
| `chore`    | 🔧    | Otros cambios que no modifican `lib/` ni `test/`                         |
| `revert`   | ⏪    | Revierte un cambio anterior                                              |

## Estructura del cuerpo

El cuerpo del issue tiene **dos secciones obligatorias**: una User Story y una descripción formal de lo que ocurre. Cuando apliquen, añade también los criterios de aceptación.

```markdown
## User Story

Como <rol>, quiero <objetivo>, para <beneficio>.

## Descripción

<Descripción formal y clara de lo que ocurre o se necesita: contexto,
comportamiento actual vs. esperado (si es un bug), o el alcance de la
funcionalidad (si es un feat). Sé concreto y evita ambigüedad.>

## Criterios de aceptación

- ...
- ...
```

Ejemplo completo:

```markdown
## User Story

Como usuario, quiero convertir montos con decimales largos sin perder
precisión, para confiar en el resultado que muestra el convertidor.

## Descripción

Al convertir desde una divisa con tasa de muchos decimales, el resultado
que muestra `ConverterPage` se redondea antes de aplicar la tasa pivote
(VES), de modo que el monto final difiere del cálculo correcto a partir
del tercer decimal. Se espera que el redondeo ocurra solo al formatear
para mostrar, nunca durante el cálculo.

## Criterios de aceptación

- El cálculo pivote opera con el valor completo de la tasa, sin redondeo previo.
- El redondeo se aplica únicamente al formatear el texto que ve el usuario.
- Existe un test en `test/features/converter/` que cubre el caso de decimales largos.
```

### Para bugs de UI

Cuando el issue reporte un defecto visible en pantalla, añade en la descripción:

- **Plataforma y versión**: Android/iOS y versión del SO donde se reproduce.
- **Tema e idioma**: si el fallo depende de claro/oscuro o de un idioma concreto (los textos largos en alemán o ruso rompen layouts que en español entran).
- **Captura o grabación**, cuando el defecto sea visual.

## Etiquetas automáticas según el `type`

Al crear el issue, **asigna automáticamente** la etiqueta que corresponda al `type` indicado en el título. Usa este mapeo:

| type       | label sugerida    |
|------------|-------------------|
| `feat`     | `enhancement`     |
| `fix`      | `bug`             |
| `docs`     | `documentation`   |
| `style`    | `style`           |
| `refactor` | `refactor`        |
| `perf`     | `performance`     |
| `test`     | `test`            |
| `build`    | `build`           |
| `ci`       | `ci`              |
| `chore`    | `chore`           |
| `revert`   | `revert`          |

- Si la etiqueta no existe todavía en el repositorio, créala antes de asignarla (`gh label create "<label>"`) o, si no es posible, informa al usuario para que la cree. A la fecha de escribir esta regla faltan `style` y `revert`.
- Puedes añadir etiquetas extra si aportan contexto (ej. `security`, `performance`, un scope), pero la etiqueta derivada del `type` **siempre** debe estar presente.

## Auto-asignación

Todo issue creado se **auto-asigna a quien lo crea** (`@me`) por defecto, salvo que el usuario indique otro responsable.

## Cómo crear el issue

Prioriza **GitHub CLI**:

```bash
gh issue create \
  --title "[<emoji> <type>]: <subject>" \
  --body "<cuerpo con User Story + Descripción + Criterios de aceptación>" \
  --label "<label-del-type>" \
  --assignee "@me"
```

Ejemplo:

```bash
gh issue create \
  --title "[🐛 fix]: el convertidor redondea mal los montos con decimales largos" \
  --body "## User Story

Como usuario, quiero convertir montos con decimales largos sin perder precisión, para confiar en el resultado que muestra el convertidor.

## Descripción

El cálculo pivote redondea la tasa antes de aplicarla...

## Criterios de aceptación
- El cálculo pivote opera con el valor completo de la tasa.
- Existe un test en test/features/converter/ que cubre el caso." \
  --label "bug" \
  --assignee "@me"
```

Si `gh` no está disponible, usa el conector MCP de GitHub si existe; si tampoco, informa al usuario que debe crear el issue manualmente respetando este formato.

## Notas

- El `type` del issue debe ser coherente con el `tipo` de la rama que luego lo respalde (`branch-naming.md`), el `type` de los commits (`commit-convention.md`) y el título de la PR (`pull-request.md`).
- ⚠️ **Relación con `branch-naming.md`**: el nombre de la rama (`feat/DTA-001`) **no** deriva del título del issue ni al revés. El vínculo issue↔rama lo maneja GitHub (linked branch), no el nombre.
