---
description: Obliga a consultar DESIGN.md (la fuente de verdad del sistema de diseño) antes de construir o reformar UI, y a declarar un token nuevo primero en DESIGN.md y después en lib/config/theme/. Aplica al tocar cualquier page/widget, el tema o los tokens de diseño.
paths:
  - "DESIGN.md"
  - "lib/config/theme/**"
  - "lib/**/page/**"
  - "lib/**/{widget,widgets}/**"
---

# Sistema de Diseño

La identidad visual de la app vive en **[`DESIGN.md`](../../DESIGN.md)** (raíz): tokens legibles por máquina (color, tipografía, espaciado, radios, componentes) en el front matter YAML, y el razonamiento en prosa. Es la **fuente de verdad**; `lib/config/theme/` es su implementación.

El riesgo que evita: cada pantalla nueva —y el backlog está lleno de superficie nueva (#11, #37, #38, #40, #42)— vuelve a decidir tamaños, espaciados y radios desde cero, y la identidad se diluye en 23 `fontSize` a mano y `EdgeInsets` con números sueltos. `DESIGN.md` es el sitio donde esa decisión se toma una vez.

## Regla

1. **Antes de construir o reformar UI, lee `DESIGN.md`.** No inventes un tamaño, un color o un radio "parecido" a uno que ya existe: búscalo ahí.
2. **Un token nuevo se declara primero en `DESIGN.md`, luego en Dart.** El orden importa: el diseño se decide en el documento, no en un widget. Si un color, un nivel tipográfico o un radio no está en `DESIGN.md`, se agrega ahí —con su razonamiento en la prosa— y en el mismo PR se implementa en `lib/config/theme/`.
3. **`config/theme/` se mantiene a mano, con `DESIGN.md` como checklist.** No se genera desde los tokens (no hay export oficial a Flutter, y la capa semántica de cuatro modos de `colors_values.dart` es más rica que el mapa plano de `colors`). Al cambiar un token en `DESIGN.md`, actualiza su equivalente en `config/theme/` en el mismo PR, y viceversa: los dos no pueden divergir.
4. **Los cuatro modos de color** (`light`, `dark`, `onBrandLight`, `onBrandDark`) viven en `colors_values.dart`; `DESIGN.md` declara la **paleta de marca** normativa y documenta el mapeo por modo en prosa. No dupliques las cuatro variantes en el front matter.
5. **Verifica en claro y oscuro.** El modo oscuro no es un detalle: es la mitad del producto. Y en texto que puede alargarse (alemán, ruso), usa `Flexible`/`overflow`.

## Relación con otras reglas

- **`constants-centralization.md`** es el "cómo" en Dart (constantes en `core/constants/` y `config/theme/`, cero valores mágicos); `DESIGN.md` es el "qué y por qué" del diseño. Se complementan: un token vive declarado en `DESIGN.md` e implementado como constante en `config/theme/`.
- **`i18n-convention.md`**: el texto de la UI pasa por `AppMessages`; su **tamaño y peso** los fija la escala tipográfica de `DESIGN.md`.

## Verificación

```bash
# Valida estructura y contraste WCAG de los tokens
npx @google/design.md lint DESIGN.md      # debe salir con 0 errores

# Compara cambios de token entre versiones
npx @google/design.md diff <viejo> DESIGN.md
```

El spec está en **alpha**; `version: alpha` está fijado en el front matter y no se construyen automatismos frágiles encima todavía.
