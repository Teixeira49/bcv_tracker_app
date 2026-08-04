---
description: Dónde vive el número de versión de la app, cuál es la única fuente de verdad y qué archivos NO se tocan porque lo derivan. Aplica cada vez que se suba la versión, se prepare un build o alguien proponga editar la versión en Android, iOS o el README.
---

# Fuentes de la Versión

La versión de la app aparece en once sitios. **Solo uno se edita.** El resto la deriva, y editarlos a mano es la forma más rápida de acabar con un binario que dice `1.2.0` en la tienda, `1.1.0` en Ajustes y `1.0.0` en el tag.

## La única fuente de verdad

```yaml
# pubspec.yaml
version: 1.0.0+1
#        ^^^^^ ^
#        |     └── build number  → --build-number → versionCode / CFBundleVersion
#        └──────── SemVer        → --build-name   → versionName  / CFBundleShortVersionString
```

Todo lo demás sale de ahí, directa o indirectamente.

## El mapa completo

### ✅ Derivados — **no los toques**

| Sitio | Cómo lo obtiene |
|---|---|
| `android/app/build.gradle.kts:32-33` | `versionCode = flutter.versionCode`, `versionName = flutter.versionName` |
| `android/local.properties` | Lo **regenera** el tooling de Flutter en cada build. Está gitignored (`android/.gitignore`); si lo ves rancio, ignóralo o bórralo |
| `ios/Runner/Info.plist` | `CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)`, `CFBundleVersion = $(FLUTTER_BUILD_NUMBER)` |
| `ios/Runner.xcodeproj/project.pbxproj`, target **Runner** | `CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)"` + `INFOPLIST_FILE = Runner/Info.plist` |
| `codemagic.yaml`, 4 comandos de build en 3 workflows (líneas 52, 141, 228 y 234 — `all-platforms-firebase` compila Android e iOS) | `--build-name=$(grep "^version:" pubspec.yaml \| awk '{print $2}' \| cut -d'+' -f1)` |

Si alguien abre Xcode y escribe la versión en la pestaña *General*, Xcode escribe `MARKETING_VERSION` en el `.pbxproj` y a partir de ahí iOS deja de seguir a `pubspec.yaml` sin que nada avise. Es el fallo clásico: **la versión se cambia en `pubspec.yaml`, nunca en Xcode ni en Gradle.**

### ⚪ Ruido conocido — ignóralo

`ios/Runner.xcodeproj/project.pbxproj` tiene `MARKETING_VERSION = 1.0` y `CURRENT_PROJECT_VERSION = 1` hardcodeados en tres configuraciones. Pertenecen al target **`RunnerTests`** (bundle `…RunnerTests`, con `BUNDLE_LOADER`/`TEST_HOST`), que es el paquete de pruebas unitarias y **nunca se publica**. Es scaffolding por defecto de Flutter. No los sincronices: tocarlos no aporta nada y ensucia el diff.

### ✋ Manuales — hay que actualizarlos

| Sitio | Cuándo | Nota |
|---|---|---|
| `pubspec.yaml` | Siempre | La fuente |
| Tag git `vX.Y.Z` | Al hacer el release | Debe apuntar a un commit donde `pubspec.yaml` ya tenga la versión nueva |
| GitHub Release | Al hacer el release | Mismo tag |
| `CHANGELOG.md` | Al hacer el release | Aún no existe; lo crea el primer release que siga la regla |
| `docs/release/RELEASE_v<X.Y.Z>.md` | Al hacer el release | |
| `release_notes.json` | Al distribuir | Ver [`release-notes.md`](release-notes.md) |
| **`README.md`** | Al hacer el release | Línea `**Versión actual del proyecto:** X.Y.Z+N`. Está hardcodeada y **nada la sincroniza**: se queda rancia en cuanto se publique la primera versión nueva |

## El build number en CI no sale de `pubspec.yaml`

Los cuatro comandos de build usan `--build-number=${CM_BUILD_NUMBER:-1}`, el contador de Codemagic. Consecuencia práctica:

- El `+N` de `pubspec.yaml` **solo afecta a los builds locales**. En CI se ignora.
- Aun así, súbelo en cada release: si no, un `flutter build` local repite build number y las tiendas rechazan un binario con build number repetido o menor.
- **El build number nunca baja**, ni cuando el SemVer sube. `1.2.0+15` → `2.0.0+16`, jamás `2.0.0+1`.
- Si algún día se publica directo a las tiendas desde CI, hay que garantizar que `CM_BUILD_NUMBER` sea monótono y no se reinicie al recrear la app en Codemagic.

## Verificación

```bash
# lo que declara la fuente
grep '^version:' pubspec.yaml

# nadie debería haber hardcodeado la versión en el target Runner
grep -n 'MARKETING_VERSION' ios/Runner.xcodeproj/project.pbxproj
# → solo debe aparecer en bloques con PRODUCT_BUNDLE_IDENTIFIER = ...RunnerTests

# Android debe seguir derivando
grep -n 'versionCode\|versionName' android/app/build.gradle.kts
# → flutter.versionCode / flutter.versionName, nunca literales

# el tag y el código deben coincidir
git tag --sort=-v:refname | head -n1
```

## La app no muestra su versión

Hoy no hay ninguna pantalla que enseñe la versión, ni la dependencia `package_info_plus`. Para una app que se distribuye por Firebase App Distribution eso tiene un coste concreto: **un tester que reporta un fallo no puede decirte en qué build lo vio**, y tú no puedes distinguir si ya lo arreglaste.

No es obligatorio, pero si se añade —el sitio natural es Ajustes— la versión debe leerse **en tiempo de ejecución** con `package_info_plus`, nunca escribirse a mano en una constante: una constante es un sitio más que se desincroniza, exactamente lo que esta regla existe para evitar.

## Al subir la versión

En el mismo cambio:

1. `pubspec.yaml` — SemVer confirmado con el usuario (ver [`version-value-proposal.md`](version-value-proposal.md)) y build number +1.
2. `README.md` — la línea de versión actual.
3. `CHANGELOG.md` y `docs/release/` — ver [`release-versioning.md`](release-versioning.md).
4. **Nada** en `android/`, `ios/` ni `codemagic.yaml`. Si el diff los toca, algo va mal.
5. El tag y el GitHub Release, después de que el bump esté mergeado en `master`.
