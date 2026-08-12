---
description: Prohíbe strings literales en la UI y obliga a que toda copy pase por AppMessages con su clave presente en los 10 idiomas. Aplica cada vez que se añada o modifique texto visible en pantalla.
paths:
  - "lib/core/i18n/**"
  - "lib/**/page/**"
  - "lib/**/{widget,widgets}/**"
---

# Internacionalización

Toda la copy visible de la app pasa por **GetX Translations**. Un texto nuevo no está terminado hasta que existe en **los 10 idiomas**: español, inglés, portugués, francés, alemán, italiano, ruso, coreano, japonés y chino.

El riesgo que evita: una clave añadida solo a `es_es.dart` no falla al compilar ni lanza excepción — GetX renderiza **la clave cruda** (`selectMarkets`) en pantalla para los otros nueve idiomas. El defecto solo se ve cambiando el idioma a mano, así que se descubre en producción.

## Las tres capas

| Archivo | Rol |
|---|---|
| `lib/core/i18n/languages/<locale>.dart` | El mapa `clave → traducción` de cada idioma (10 archivos) |
| `lib/core/i18n/languages/_languages.dart` | Barrel que reexporta los 10 mapas |
| `lib/core/i18n/app_translations.dart` | `AppTranslations extends Translations`, ensambla los mapas por locale |
| `lib/core/i18n/app_messages.dart` | `AppMessages`, los getters tipados que consume la UI |

## Regla

1. **Cero strings literales en la UI.** Ningún `Text('Convertir')` ni `hintText: 'Monto'` en `lib/features/` o `lib/shared/presentation/`. Siempre `Text(AppMessages.converterView)`.
2. **La UI consume `AppMessages`, no `.tr` directo.** `'homeView'.tr` esparcido por los widgets deja claves sueltas sin autocompletado y sin un inventario central. El único archivo que escribe `.tr` es `app_messages.dart`.
3. **Una clave nueva se agrega a los 10 archivos, en el mismo commit.** Sin excepciones y sin "luego traduzco": una traducción provisional en inglés es preferible a la clave cruda en pantalla.
4. **Nomenclatura de claves**: `lowerCamelCase`, descriptiva del significado y no del lugar (`selectCurrency`, no `homeSecondLabel`). Mantén la clave igual en los 10 archivos; solo cambia el valor.
5. **Orden estable.** Agrega la clave en la **misma posición relativa** en los 10 archivos. Facilita revisar el diff y detectar de un vistazo el idioma que quedó fuera.
6. **Los textos largos rompen layouts.** El alemán y el ruso son notablemente más largos que el español, y el japonés/chino más cortos. Al añadir copy a un espacio ajustado, verifica en el idioma más largo y usa `Flexible`/`overflow` en vez de asumir el ancho del español.
7. **Nada de concatenar traducciones.** `AppMessages.lastUpdate + ' ' + fecha` produce un orden de palabras incorrecto en varios idiomas. Usa `@` de GetX con parámetros o una clave completa por caso.
8. **Formato de números y fechas con `intl`,** según el locale activo, no con interpolación manual: el separador decimal cambia entre idiomas y una tasa mal puntuada es un error de datos, no de estilo.
9. **Lo que no es copy no se traduce**: códigos de divisa (`USD`, `VES`), nombres de plataforma que son marcas (`Binance`, `BCV`) y las claves técnicas se quedan como están.

## Ejemplo

**❌ Antes**:

```dart
Text('Seleccionar mercados'),
```

**✅ Después**:

```dart
// lib/core/i18n/app_messages.dart
static String get selectMarkets => 'selectMarkets'.tr;

// lib/core/i18n/languages/es_es.dart  (y los otros 9, misma clave)
"selectMarkets": "Seleccionar mercados",

// widget
Text(AppMessages.selectMarkets),
```

## Verificación

Antes de commitear copy nueva, comprueba que ningún idioma quedó atrás:

```bash
python3 - <<'PY'
import re, glob, os
files = sorted(f for f in glob.glob("lib/core/i18n/languages/*.dart")
               if not f.endswith("_languages.dart"))
keys = {os.path.basename(f): set(re.findall(r'''["']([A-Za-z0-9_]+)["']\s*:''',
        open(f, encoding="utf-8").read())) for f in files}
union = set().union(*keys.values())
ok = True
for name, ks in sorted(keys.items()):
    missing = union - ks
    if missing:
        ok = False
        print(f"{name}: faltan {sorted(missing)}")
print(f"{len(union)} claves — {'paridad OK' if ok else 'DESINCRONIZADO'}")
PY
```

A la última actualización de esta regla los 10 archivos están en paridad con **74 claves**, y `AppMessages` expone exactamente esas. Si el script reporta una diferencia, el cambio está incompleto.

Además, si la clave nueva no se expone en `AppMessages`, no la uses: agrégala primero como getter.
