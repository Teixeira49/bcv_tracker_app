---
description: Obliga a que toda implementación futura (una fuente/mercado nuevo, un endpoint consumido, un controlador o un helper de cálculo) incluya sus propios tests en el MISMO PR, para que la cobertura no se degrade respecto a la suite existente. Aplica cada vez que se toque la capa de datos, un controller de GetX o la lógica de cálculo.
paths:
  - "test/**"
  - "lib/shared/data/**"
  - "lib/**/controller/**"
  - "lib/core/helpers/**"
---

# Cobertura de Tests Obligatoria

La app consume un backend que a su vez depende de fuentes externas frágiles (HTML del BCV, JSONs de terceros P2P) y hace **cálculo financiero** encima de esos datos: promedios, conversión pivote en VES, formateo de fechas y montos. La suite de `test/` es la mayor red de seguridad contra regresiones silenciosas — un redondeo mal aplicado no lanza excepciones, solo muestra un número equivocado. Esta regla evita que esa red se desactualice: **todo lo nuevo nace con sus tests**, en el mismo cambio.

El riesgo concreto que evita: cambiar el parseo de una respuesta, el mapeo de un mercado o la fórmula del convertidor **sin** tests, de modo que un cambio posterior en el backend o en la normalización rompa lo que el usuario ve sin que nada lo detecte.

## Cuándo aplica

Cada vez que un cambio:
- **agregue o modifique un endpoint consumido** (`lib/shared/data/datasource/dollar_api/`, incluido `dollar_endpoints.dart`), o
- **sume o modifique un mercado/fuente de tasa** o su normalización (`lib/shared/data/mapper/`, `lib/core/constants/market_constants.dart`), o
- **cambie la deserialización** de un modelo o su conversión a entidad (`lib/shared/data/model/`, `.fromJson()` / `.toEntity()`), o
- **cambie la lógica de un controlador** que transforme datos (`HomeController`, `ConverterController`, `CurrencyRepository`, `SettingsController`), o
- **toque un helper de cálculo o formateo** (`lib/core/helpers/`: promedios, parseo de fechas, formato de montos).

Cambios puramente visuales que no alteran datos ni estado (ajustar un padding, cambiar un color del tema) no requieren tests nuevos, pero **no deben romper** los existentes.

## Checklist obligatorio (en el MISMO PR)

### 1. Fuente / mercado nuevo o modificado
Replica el patrón de los tests existentes (`test/shared/data/currency_normalizer_test.dart`, `test/shared/domain/market_selection_test.dart`):
- **Mapeo feliz**: dado un payload representativo del backend, el modelo produce la `Currency` / `BcvCurrencies` esperada (código, nombre, valor, plataforma, fecha).
- **Payload degradado**: campos ausentes, `null` o con tipo inesperado no revientan la app; se descartan o degradan de forma controlada.
- Si el mercado participa en promedios o en la selección de mercados seguidos, cúbrelo también.

### 2. Endpoint consumido, nuevo o modificado
Replica `test/shared/data/dollar_api_rest_test.dart`:
- Un **fake de `HttpManager`** que devuelva una respuesta enlatada, **sin tocar la red**. Ningún test puede depender de que el backend esté levantado.
- Afirma el **contrato saliente**: la ruta y el método que realmente se envían (el fake los registra en `sentEndpoint` / `sentMethod`).
- Afirma la **forma de la respuesta** parseada y los **casos de error**: no-2xx, timeout y cuerpo vacío deben propagar la `ApiException` correcta, no una excepción cruda de Dio.

### 3. Controlador de GetX nuevo o modificado
Replica `test/features/converter/converter_controller_calculator_test.dart`:
- Inyecta **dependencias falsas** con `Get.put`/`Get.replace` (fakes de `IDollarRepository` / `CurrencyRepository`), y limpia con `Get.reset()` en el `tearDown`.
- Afirma el **estado observable** resultante (`.value` de los `.obs`), no el widget.
- Cubre los casos límite del cálculo: monto cero, monto vacío, tasa ausente, divisa no disponible y **decimales largos** (el redondeo se aplica al formatear, nunca al calcular).

### 4. Helper de cálculo o formateo
Replica `test/core/helpers/`: entrada → salida esperada, incluyendo los bordes (lista vacía, fecha malformada, valores negativos). Son funciones puras: no necesitan fakes ni `Get`.

### 5. Widget test (cuando aplique)
No se exige un widget test por cada cambio de UI, pero **sí** cuando el widget contenga lógica propia (un formulario que valida, un selector que filtra). Si el widget solo pinta lo que el controller le pasa, cubre el controller.

## Verificación

- **La suite debe quedar en verde**: `flutter test` sin fallos, localmente y en CI.
- **El análisis estático también**: `flutter analyze` sin nuevos errores.
- **CI obligatorio, en dos puntos**: el workflow de validación de PR (`.github/workflows/pr-validation.yml`, GitHub Actions, #27) corre `flutter analyze` y `flutter test` en **cada PR** hacia `development`/`master` — una PR con tests en rojo no se puede fusionar; y `codemagic.yaml` los vuelve a correr antes de construir, así que un build con tests en rojo tampoco distribuye. El inventario de lo cubierto vive en [`docs/lista_de_tests.md`](../../docs/lista_de_tests.md).
- No reduzcas la cobertura existente: no borres ni marques con `skip` tests para que pase el build.

```bash
flutter analyze
flutter test
flutter test --coverage   # opcional, genera coverage/lcov.info (gitignored)
```

## Regla de oro

Si agregas o cambias una fuente, un endpoint, un controlador o un helper de cálculo y **no** agregas sus tests en el mismo PR, el cambio está incompleto.
