---
description: Formato y contenido de las notas de versión que consume Codemagic (release_notes.json), y cómo se derivan del mismo material que el CHANGELOG sin duplicarlo. Aplica cada vez que se prepara una versión para distribuir a testers o a las tiendas.
---

# Notas de Versión

Un release produce **tres documentos con la misma historia y tres audiencias distintas**. No son copias: cada uno se escribe para quien lo lee.

| Documento | Quién lo lee | Voz | Dónde vive |
|---|---|---|---|
| `docs/release/RELEASE_v<X.Y.Z>.md` | El equipo | Extensa: qué cambió, por qué, diagramas si el cambio es estructural | Versionado en el repo |
| `CHANGELOG.md` | Desarrolladores, ahora y dentro de un año | Concisa y técnica, formato [Keep a Changelog](https://keepachangelog.com/) (`Added`/`Changed`/`Fixed`) | Versionado en el repo |
| `release_notes.json` | **El usuario final** en TestFlight, App Store, Google Play y Firebase | Lo que gana el usuario, en su idioma. Ni un nombre de clase, ni un número de PR | Raíz del repo |

La regla de oro que los une: **los tres salen del mismo PR mergeado**, así que no pueden contradecirse. Y la que los separa: si una línea del `CHANGELOG` se puede copiar tal cual a las notas de la tienda, casi seguro está mal escrita en uno de los dos sitios.

```
PR mergeado
  ├─→ docs/release/RELEASE_vX.Y.Z.md   (el detalle completo)
  ├─→ CHANGELOG.md                      (el resumen navegable, técnico)
  └─→ release_notes.json                (el valor, para el usuario)
```

## El archivo que lee Codemagic

Codemagic recoge automáticamente un archivo llamado **`release_notes.json`** (o `release_notes.txt`) situado en el **directorio de trabajo del proyecto**, que aquí es la raíz del repositorio. No hay que declararlo en `codemagic.yaml`.

```json
[
  {
    "language": "en-US",
    "text": "Rates now refresh in the background, so the home screen no longer\nshows placeholders after losing connection.\n\n• Pick which markets you follow from Settings\n• Faster conversion between non-VES pairs"
  },
  {
    "language": "es-ES",
    "text": "Las tasas se actualizan en segundo plano: la pantalla de inicio ya no\nse queda con los recuadros vacíos al perder conexión.\n\n• Elige qué mercados sigues desde Ajustes\n• Conversión más rápida entre pares que no son VES"
  }
]
```

Para el envío a revisión de App Store, cada entrada admite además `description`, `keywords`, `promotional_text`, `marketing_url` y `support_url`. No los rellenes salvo que la versión cambie de verdad la ficha de la tienda.

### Reglas del formato

1. **`en-US` es obligatoria.** Es la entrada que Codemagic publica en el correo de build, en Slack y en **Firebase App Distribution**. Sin ella, esos tres canales se quedan sin notas.
2. **Guiones, no guiones bajos**: `es-ES`, no `es_ES`. Es el código de locale de las tiendas, no el de nuestros archivos de i18n.
3. **Apple rechaza `<` y `>`** dentro de las notas. Nada de `<b>`, y cuidado con escribir `>` como viñeta.
4. **Ni markdown ni enlaces ni imágenes**: ambas tiendas renderizan texto plano. Sí admiten emoji y saltos de línea.
5. **Límites de longitud, y el orden en que se escriben:**
   - Google Play: **500 caracteres por idioma**.
   - App Store "What's New" y TestFlight "What to Test": **4.000 caracteres**.

   Escribe **primero la versión de 500** y expándela si hace falta. Comprimir 4.000 a 500 produce un texto amputado; ampliar 500 bien escritos es trivial.

## ⚠️ Hoy la app no recoge este archivo

Codemagic solo publica `release_notes.json` automáticamente cuando la distribución va por su bloque **`publishing:`**. Los tres workflows de `codemagic.yaml` invocan el CLI de Firebase a mano en un paso de script:

```yaml
firebase appdistribution:distribute \
  --release-notes "Build #${CM_BUILD_NUMBER:-1} – rama ${CM_BRANCH:-master}"
```

Esa cadena no dice nada al tester: repite el número de build que ya se ve en la consola. Mientras siga así, `release_notes.json` **se ignora**. Hay dos salidas, y conviene decidirla antes de la primera versión que se quiera anunciar de verdad:

- **Pasar el archivo a mano** — cambio mínimo, funciona con el script actual:
  ```yaml
  --release-notes-file release_notes.txt
  ```
  (el CLI de Firebase toma texto plano, no el JSON multi-idioma)
- **Migrar al bloque `publishing: firebase:`** de Codemagic — entonces las notas, el correo y Slack salen del `release_notes.json` sin tocar nada más.

## Qué idiomas escribir

La app tiene 10 idiomas de interfaz, pero **las notas de versión no son la interfaz**: son texto de marketing y cada idioma es trabajo de redacción real, no de traducción mecánica. El mínimo viable es `en-US` (obligatoria) y `es-ES` (el público principal de la app). Añade más solo si alguien va a escribirlas bien.

> ⚠️ **No tomes los locales de `SettingsController`.** Sus `languageOptions` no son códigos de tienda, y dos de ellos ni siquiera son locales válidos: la app ofrece `en_EN` y `ja_JA`, mientras `AppTranslations` registra `en_US` y `ja_JP`. Hoy la UI no se rompe por eso —GetX resuelve por código de idioma solo, así que `ja_JA` acaba encontrando el mapa de `ja_JP`—, pero el valor inválido se persiste en `SharedPreferences` y se pasa a `intl` para formatear fechas y montos. Para las notas usa siempre el código de la tienda: `en-US`, `es-ES`, `pt-PT`, `ja-JP`.

## Cómo se escriben

Del PR mergeado sale el material; la traducción a valor es tuya:

| En el CHANGELOG | En las notas de versión |
|---|---|
| `Fixed: CurrencyNormalizer deduplicated P2P rows twice` | *Las tasas P2P ya no aparecen repetidas en el promedio* |
| `Added: MarketSelection body for /saved-currencies` | *Elige desde Ajustes qué mercados quieres seguir* |
| `Changed: migrated rate fetching to POST /api/v3` | — *(nada: el usuario no ve esto)* |

Tres criterios:

1. **Empieza por lo que el usuario notará al abrir la app.** Si la versión no cambia nada perceptible, dilo en una línea honesta ("mejoras de rendimiento y corrección de errores") en vez de inventar tres viñetas.
2. **No enumeres commits.** Una versión con 14 commits puede ser una sola frase para el usuario.
3. **Si no consigues escribir una frase de valor**, la versión probablemente es un PATCH — ver [`version-value-proposal.md`](version-value-proposal.md).

## Checklist antes de publicar

- [ ] Existe `release_notes.json` en la raíz, con entrada `en-US`.
- [ ] Ningún idioma pasa de 500 caracteres si la versión va a Google Play.
- [ ] Sin `<`, `>`, markdown ni enlaces.
- [ ] El contenido es coherente con `CHANGELOG.md` y con `docs/release/RELEASE_v<X.Y.Z>.md`, y ninguno contradice lo que el PR realmente cambió.
- [ ] Los códigos de locale llevan guion y existen (`es-ES`, `ja-JP`).
- [ ] Si la distribución sigue yendo por script, las notas se pasan con `--release-notes-file`; si no, no llegan.

## Relación con las otras reglas

- [`release-versioning.md`](release-versioning.md) — el flujo completo del release: SemVer, bump de `pubspec.yaml`, CHANGELOG, promoción a `master` y GitHub Release. Las notas de versión son el Paso 4 visto desde el usuario.
- [`version-value-proposal.md`](version-value-proposal.md) — cómo se propone el número de versión por el valor entregado, no solo por el tipo de los commits.
