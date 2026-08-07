---
description: Obliga a registrar a través del único logger del proyecto (AppLogger), con niveles, prohibiendo print/debugPrint/dart:developer suelto, y a que todo catch de un límite del sistema registre su causa antes de traducirla a estado de UI. En release no se registra información sensible ni URLs en crudo. Aplica al tocar la capa de red, los repositorios o un controlador que transforme un error en estado visible.
paths:
  - "lib/core/logging/**"
  - "lib/core/network/**"
  - "lib/shared/data/**"
  - "lib/**/controller/**"
---

# Logging

La app registra a través de **un único logger**: `AppLogger` (`lib/core/logging/app_logger.dart`). No hay `print`, no hay `debugPrint`, no hay `dart:developer log` suelto — todo pasa por ahí, con niveles.

El riesgo que evita: los `catch` de los límites del sistema (red, parseo del contrato, refresco de datos) absorben la excepción y la convierten en estado de UI. Sin logging, el motivo real —el `message` y el `statusCode` que `ApiException` sí trae— se pierde en el momento en que se vuelve un texto de error en pantalla, y un fallo reportado por un usuario hay que diagnosticarlo a ciegas.

## Regla

1. **Un solo logger.** `AppLogger.debug/info/warning/error`. Nunca `print`, `debugPrint` ni `dart:developer log` directo. El lint `avoid_print` bloquea el primero; esta regla cubre el resto.
2. **Todo `catch` de un límite del sistema registra la causa** antes de traducirla a estado de UI o de volver a lanzarla. "Límite del sistema" es: la capa de red (`HttpManager`, `DollarApiRest`), los repositorios (`DollarRepository`, `CurrencyRepository`) y cualquier controlador que transforme un error en estado visible. El log lleva el `error` y el `stackTrace`; la UI lleva el mensaje para el usuario. Son dos cosas distintas y van a sitios distintos.
3. **El nivel expresa gravedad**, y se elige a conciencia:

   | Nivel | Cuándo |
   |---|---|
   | `debug` | Trazas de desarrollo: una petición saliente, una transición de estado. Se silencian en release. |
   | `info` | Hitos normales del ciclo de vida que ayudan a leer un log, sin ser un problema. |
   | `warning` | Algo salió mal pero la app se recupera o degrada: un parseo que falla, un timeout, un valor inesperado del backend. |
   | `error` | Un fallo que el usuario nota: el refresco de tasas que no completa, una excepción no recuperable. |

4. **En release no se registra información sensible.** `AppLogger.minLevel` es `warning` en release, así que los `debug`/`info` —los que más probablemente llevan una URL o un payload— no llegan al build distribuido. Y **una URL nunca se registra en crudo**: pasa por `AppLogger.redactUri`, que quita el `user:pass@` y el query string donde viviría un token. Nada de credenciales, claves ni datos personales en el log, en ningún nivel.
5. **El nivel es configuración, no decisión de cada llamada.** `AppLogger.minLevel` gobierna el umbral en un solo sitio; un call site no sube ni baja verbosidad por su cuenta.

## Ejemplo

**❌ Antes** — la causa se pierde:

```dart
try {
  await _fetch();
} catch (e) {
  errorMessage.value = 'No se pudieron cargar las tasas';   // ← el porqué se evaporó
}
```

**✅ Después** — el usuario ve un mensaje, el log guarda la causa:

```dart
try {
  await _fetch();
} catch (e, s) {
  errorMessage.value = 'No se pudieron cargar las tasas';
  AppLogger.error('Rate refresh failed', name: 'CurrencyRepository', error: e, stackTrace: s);
}
```

## Fuera de alcance

- **El envío remoto** de estos errores (Crashlytics) es #34, no esta regla. `AppLogger` es el punto único donde ese envío se enchufará el día que se haga: una razón más para que todo pase por él.

## Verificación

```bash
# Nada debe registrar fuera del logger
grep -rn "print(\|debugPrint(\|dart:developer" lib/ | grep -v "app_logger.dart"
# → vacío (salvo el propio AppLogger, que envuelve dart:developer)

flutter analyze   # avoid_print está activo y es fatal en CI
```
