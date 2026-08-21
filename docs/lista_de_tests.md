# Lista de Tests — BCV Tracker

Este documento es el **inventario de la suite**: primero lo que ya está cubierto, después lo que queda por hacer (roadmap). Mantenlo al día al agregar tests — la regla [`test-coverage.md`](../.agents/rules/test-coverage.md) exige que toda fuente, endpoint, controlador o helper de cálculo nuevo nazca con sus tests, y el check de PR de #27 (`flutter test` en GitHub Actions) lo hace cumplir en cada PR.

## Cobertura actual (54 archivos, 414 tests)

| Área | Archivo | Qué cubre |
|---|---|---|
| **Helpers** | `test/core/helpers/backend_date_test.dart` | Parseo y formateo de fechas del backend |
| | `test/core/helpers/currency_helpers_average_test.dart` | Cálculo de promedios y mapeo de códigos |
| | `test/core/helpers/currency_helpers_parse_date_test.dart` | Formato de fechas para la UI |
| | `test/core/helpers/currency_helpers_detail_test.dart` | **(#38, #39, #37 incremental)** `isOfficialRate`, `castTendency`, `castOptionalDate`, los nombres traducidos de lira/yuan/rublo, y la precisión adaptativa de `castAmount` — incluido el techo configurable: muestra los decimales que la cifra tiene, redondea en el techo, nunca baja del suelo de dos, no rellena con ceros, **subir el techo nunca muestra menos dígitos que bajarlo**, y un techo fuera de rango se acota en vez de obedecerse |
| | `test/core/helpers/currency_helpers_detail_test.dart` | **(#38)** `isOfficialRate`, `castTendency`, `castOptionalDate` y los nombres traducidos de lira/yuan/rublo |
| | `test/core/helpers/currency_helpers_locale_test.dart` | **(#63)** El formateo por locale: coma en los **seis** idiomas que la usan y punto en inglés, japonés y coreano —los tres que el issue pedía comprobar explícitamente, porque `NumberFormat` cae al defecto en silencio con un locale que no conoce—; que **agrupa donde la cifra solo se lee y no donde vuelve al campo de texto**; el **ciclo completo** escribir → convertir → mostrar → reparsear en un locale con coma, también con techo alto de decimales; que cambiar de idioma cambia la siguiente lectura; y que sin locale asignado no revienta; que **los diez códigos publicados son formateables** y que uno desconocido cae al defecto en vez de lanzar dentro del `build` |
| | `test/core/helpers/search_text_test.dart` | **(#41)** Plegado de mayúsculas y acentos, y coincidencia por nombre o mercado; incluye los scripts no latinos |
| | `test/core/helpers/amount_input_formatter_test.dart` | **(#40)** Qué acepta y qué rechaza el campo de monto: dígitos, un separador, y nada de letras, símbolos o pegados a medio parsear |
| **Datos / mapeo** | `test/shared/data/currency_normalizer_test.dart` | Normalización del promedio (dedup, merge buy/sell) |
| | `test/shared/data/bcv_currencies_model_test.dart` | `toEntity()` convierte la lista, no filtra modelos |
| | `test/shared/data/dollar_api_rest_test.dart` | Datasource: contrato saliente y `ApiException` (mock de `HttpManager`) |
| **Repositorios** | `test/shared/data/dollar_repository_test.dart` | **(#28)** Devuelve entidades; propaga `ApiException` |
| | `test/shared/data/currency_repository_test.dart` | **(#28)** `refreshData` éxito, error, fallo parcial, `isLoading` |
| **Controllers** | `test/features/converter/converter_controller_calculator_test.dart` | Cálculo pivote, división por cero, swap, selectCurrency |
| | `test/features/home/home_controller_test.dart` | **(#28)** Getters puente y `refreshHomeData` (éxito/error) |
| | `test/navigation/navigation_controller_test.dart` | **(#28)** `changeIndex`, observabilidad del índice |
| | `test/shared/presentation/settings_controller_language_test.dart` | Idioma: `orElse`, normalización de código guardado |
| | `test/shared/presentation/settings_controller_test.dart` | **(#28)** Tema y mercado favorito: persistencia y no-op |
| | `test/features/currency_detail/currency_detail_controller_test.dart` | **(#38)** Rate abierta y limpiada, y disposición del worker (#45) |
| | `test/features/currency_detail/currency_detail_converter_test.dart` | **(#39)** Conversor embebido: sentido y su inversa, coma decimal, tasa cero sin `Infinity`, limpieza al cerrar — y que el resultado **coincide con el conversor completo** |
| **Widgets** | `test/features/home/home_page_test.dart` | **(#28)** Home: estado de error, sin-error, frame |
| | `test/features/converter/converter_page_test.dart` | **(#28)** Cuerpo del conversor: render e input |
| | `test/features/splash/splash_page_test.dart` | **(#10)** El splash usa el logo de marca, lo pinta de blanco, limita su tamaño en tablets, y su entrada: el texto empieza invisible y el icono sube al aparecer |
| | `test/features/currency_detail/currency_detail_sheet_test.dart` | **(#38)** Cabecera, tabla de detalles, degradación sin `change`/`createDate`, avatar y huecos reservados |
| | `test/features/home/home_currency_detail_tap_test.dart` | **(#38)** Tocar una tarjeta abre el detalle de esa tasa; inerte con placeholders |
| | `test/shared/presentation/widgets/base_bottom_sheet_test.dart` | **(#40)** Contenedor compartido: anclaje, una sola cadena de scroll, cierre por arrastre y por botón, barra fija, teclado y semántica |
| | `test/features/converter/currency_selector_sheet_test.dart` | **(#40, #41)** El selector como hoja inferior: altura, categorías, scroll, selección de origen y destino, texto ampliado — y el buscador: filtrado en vivo, acentos (también contra la copy real de `AppMessages`, #104), sin resultados, borrado y elegir un resultado |
| | `test/features/converter/converter_keyboard_test.dart` | **(#40)** El conversor con el teclado abierto: sin desbordes y encogiendo con el body; el campo filtra lo que un teclado físico puede mandar |
| | `test/features/converter/converter_swap_button_test.dart` | **(#40, #63)** El botón de intercambio no se despega de la costura aunque la tarjeta de salida crezca; el resultado se redondea al mostrar, no al calcular; y **las dos mitades usan el mismo separador** — la regresión que la revisión encontró, con la cifra de cola larga tras el intercambio |
| | `test/features/converter/converter_preload_from_detail_test.dart` | **(#103)** El traspaso del detalle al conversor completo: la tasa llega seleccionada con su mercado, el sentido y el monto cruzan tal cual, la regla pivote se mantiene, y —la mitad que importa— cambiar de pestaña o abrir y cerrar el detalle **no** toca la selección del usuario |
| | `test/features/settings/settings_page_test.dart` | **(#37)** La pantalla de ajustes: el menú agrupado y el valor actual de cada opción, que no ofrece el engranaje que lleva a sí misma, que cada valor queda **pegado a su chevron** (regresión de `Flexible` vs `Expanded`), y las tres subpantallas de elección — los diez idiomas listados, aplicar y persistir idioma, mercado y tema, que la subpantalla **no** se cierra al elegir (el repintado es la confirmación), la **rejilla del tema** —dos tarjetas por fila en celdas iguales (la impar no se estira), borde de 2 px en la seleccionada y `Semantics(selected:)` para el lector de pantalla— y que **las cuatro subpantallas abren con su frase explicativa**, por encima de las opciones. **(incremental)** El contador de decimales: arranca en 2, cada paso persiste, los dos extremos se apagan y sostienen, el ejemplo se calcula con el formateador real, y el menú muestra la cifra como valor actual con sus cuatro entradas |
| | `test/features/settings/app_version_test.dart` | **(#43)** La versión: que **lee** versión y build pero **solo muestra la versión**, que el menú muestra **la del paquete instalado** y no una constante (el fake dice 9.9.9 y el `pubspec` otra cosa), que la fila **copia y no navega** y su icono lo dice, que tocarla deja la cadena en el portapapeles y lo confirma, y que **«Acerca de» muestra exactamente el mismo dato** — el criterio duro del issue. Y las tres ramas del servicio, inyectando el **lector** y no el resultado: un lector que falla deja el marcador, uno que nunca contesta no bloquea a nadie, y una respuesta tardía todavía llega. Más que **sin versión no se copia nada ni se finge que se copió** |
| | `test/features/settings/settings_about_page_test.dart` | **(#42)** «Acerca de»: las nueve fuentes con su tipo de referencia, que **cada fila abre su propio origen y no otro**, que los nombres de mercado no se traducen, licencia y ambos repositorios, que el enlace de la documentación sigue al backend configurado (y no a uno fijo), el formulario de issue —no la lista—, que todas las filas llevan el icono de «sale de la app» y ninguna el chevron, que **el bloque dice de qué es lista** (la nota que la primera versión aceptaba y no pintaba), que un enlace rechazado por la plataforma **se reporta** en vez de no hacer nada, y que la pantalla entra a 360 dp con la escala tipográfica al doble en alemán |
| | `test/core/helpers/external_link_test.dart` | **(#42)** La única puerta de salida: abre `https` y `http` (que es lo que `Environment` acepta), **rechaza `tel:`, `intent:`, `javascript:`, `file:`, basura y las que parsean con esquema válido pero sin host (`https:`, `https:javascript:alert(1)`) sin llegar a la plataforma**, normaliza el esquema a minúsculas, degrada a `false` ante una `PlatformException` y **deja escapar cualquier otra excepción**, que sería un error de programación |
| | `test/shared/presentation/widgets/base_layout_test.dart` | **(#37)** La franja de marca: el engranaje empuja la ruta de ajustes en vez de abrir un diálogo, una pantalla apilada cambia el logo por la flecha de volver y esconde el engranaje, y el engranaje queda **pegado al borde derecho** con título corto y con título que envuelve — la medición que los goldens no pueden dar, porque ocultan el texto como bloques |
| | `test/features/currency_detail/currency_detail_open_in_converter_test.dart` | **(#103)** El botón: los tres pasos y su orden (cargar, cerrar, cambiar de pestaña), que el monto tecleado sobrevive al cierre, y que un detalle invertido traslada también el sentido |
| **Goldens** | `test/shared/presentation/widgets/app_state_view_golden_test.dart` | **(#35)** Estados de error y vacío, claro y oscuro |
| | `test/shared/presentation/widgets/performance_indicator_widget_golden_test.dart` | **(#35)** Indicador de variación, claro y oscuro |
| | `test/features/home/home_page_golden_test.dart` | **(#35)** Home, pestañas promedio y BCV, claro y oscuro |
| | `test/features/converter/converter_page_golden_test.dart` | **(#35)** Cuerpo del conversor, claro y oscuro |
| | `test/features/currency_detail/currency_detail_sheet_golden_test.dart` | **(#38)** Modal de detalle, tasa paralela y oficial, claro y oscuro |
| | `test/features/converter/currency_selector_sheet_golden_test.dart` | **(#40)** Selector de divisas como hoja inferior, claro y oscuro |
| | `test/features/settings/settings_page_golden_test.dart` | **(#37, #42)** El menú de ajustes, la subpantalla de idioma, la **rejilla del tema**, el **contador de decimales** y **«Acerca de»**, claro y oscuro — esta última es la que cazó que las tarjetas se pintaban debajo del panel por usar `Ink` en vez de un `Material` propio |
| **Config / i18n** | `test/config/enviroment/environment_test.dart` + `environment_empty_env_test.dart` | Validación de `CURRENCY_BACK`, `.env` ausente/vacío |
| | `test/core/i18n/translation_parity_test.dart` | **(#36)** Paridad de claves en los 10 idiomas |
| | `test/core/i18n/search_folds_published_names_test.dart` | **(#104, #41)** La tilde de «Dólar» en `es_ES`, que buscar sin tilde encuentra el nombre publicado, y que la tabla de plegado cubre los diacríticos que la app realmente envía |
| | `test/config/routes/app_pages_test.dart` | Registro de rutas nombradas |
| | `test/config/theme/colors_constants_test.dart` | Opacidad de la paleta (alpha de 8 dígitos) |
| | `test/shared/presentation/settings_controller_device_language_test.dart` | **(#98)** El primer arranque: la app sigue al dispositivo y el selector muestra ESE idioma, `es_VE`→`es_ES` y `en_GB`→`en_US` por el paso de solo-idioma, un idioma no publicado cae al defecto, seguir al dispositivo no se persiste, tocar el idioma ya mostrado sí lo aplica y lo guarda, y la migración de `en_EN`/`ja_JA` conserva el idioma en vez de perderlo |
| | `test/shared/presentation/settings_controller_startup_test.dart` | **(#59)** El arranque asíncrono del servicio de ajustes: `Get.find` devuelve el estado ya cargado en el mismo turno, registro único y permanente, un `langCode` malformado no tumba el lanzamiento, y el **primer frame** ya lleva el tema y el idioma guardados — incluida la razón por la que el locale se pasa y no se aplica |
| **Tooling / CI** | `test/tool/release_notes_txt_test.dart` | **(#93)** La derivación de `release_notes.json` al `.txt` que lee Firebase: elección de idioma, fallback, y que **nunca** produce notas vacías (JSON roto, entrada sin texto, sin `en-US`). Valida además el `release_notes.json` real contra el límite de 500 caracteres de Google Play y los `<`/`>` que Apple rechaza |

> Todos los tests **mockean la red**: ninguno llama al backend real (fakes de `HttpManager` / `IDollarApi` / `IDollarRepository`). Las imágenes de red en los widget tests se evitan vaciando los placeholders del skeleton.

---

## Roadmap — lo que queda por cubrir

> Los tests de `ConverterController.calculator()` ya están implementados en
> `test/features/converter/converter_controller_calculator_test.dart`.

---

## Unit Tests — `CurrencyHelpers`

> Archivo sugerido: `test/core/helpers/currency_helpers_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 1 | `castCurrencySymbolText` símbolo correcto por código | Verifica que `USD`→`$`, `EUR`→`€`, `VES`→`Bs.S`, `TRY`→`₺`, `CNY`→`¥`, `RUB`→`₽`, `BTC`→`₿`, `USDT`→`₮`, `USDC`→`¢` |
| 2 | `castCurrencySymbolText` código desconocido | Retorna `''` para un código no reconocido |
| 3 | `castCurrencySymbolIcon` path correcto por código | Cada código retorna el asset correcto (`flagVenezuelaIcon`, `cryptoBTCIcon`, etc.) |
| 4 | `castCurrencySymbolIcon` código desconocido | Retorna `''` |
| 5 | `castCurrencyCountry` mapeo completo | Verifica `countryName`, `currencyCode`, `currencySymbol` para `USD`, `EUR`, `TRY`, `CNY`, `RUB` |
| 6 | `castCurrencyCountry` código desconocido | Retorna país con `countryName: 'Desconocido'` y `currencyCode: '-'` |
| 7 | `getAverageValue` calcula promedio correctamente | Lista con múltiples currencies del mismo `keyName`, verifica `sum / count` |
| 8 | `getAverageValue` lista vacía retorna `0.0` | Sin lanzar excepción |
| 9 | `getAverageValue` sin coincidencias retorna `0.0` | Ningún elemento tiene el `currencyCode` buscado; división por 0 |
| 10 | `completeCurrencyExchange` concatena el par | `'USD'` → `'USD/VES'` |
| 11 | `parseDate` formatea fecha ISO válida | Fecha conocida produce el string esperado |
| 12 | `parseDate` con `addDayName: false` omite el nombre del día | El resultado no contiene el prefijo del día |
| 13 | `getDayName` retorna nombre correcto del 1 al 7 | Lunes=1 ... Domingo=7 |
| 14 | `getDayName` fuera de rango retorna `''` | Valores `0`, `8`, `-1` |

---

## Unit Tests — Modelos

> Archivo sugerido: `test/shared/data/model/currency_model_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 15 | `CurrencyModel.fromJson` JSON completo | Todos los campos mapeados correctamente |
| 16 | `CurrencyModel.fromJson` campo faltante lanza excepción | Omitir `'name'`, `'code'`, `'value'`, etc. |
| 17 | `CurrencyModel.toEntity` retorna `Currency` con valores idénticos | Compara campo a campo |
| 18 | `BcvCurrenciesModel.fromJson` deserializa lista anidada | `currencies` es lista de `CurrencyModel` |
| 19 | `BcvCurrenciesModel.toEntity` retorna `BcvCurrencies` con fecha y lista correctas | |

---

## Unit Tests — `ConvertibleCurrency`

> Archivo sugerido: `test/features/converter/domain/convertible_currency_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 20 | `originalValue` delega a `currency.value` | Verifica que es la misma referencia |
| 21 | `copyWith` conserva campos no modificados | Solo cambia `convertedValue`, `currency` queda igual |
| 22 | Equatable: mismas props → iguales | Dos instancias con misma `currency` y `convertedValue` |
| 23 | Equatable: distinta `convertedValue` → distintos | |

---

## Unit Tests — `ConverterController` (resto de métodos)

> Archivo sugerido: `test/features/converter/converter_controller_test.dart`

### `selectCurrency()`

| # | Test | Descripción |
|---|------|-------------|
| 24 | Seleccionar la misma moneda retorna `null` | Sin cambios en estado |
| 25 | Seleccionar la moneda del otro lado ejecuta swap y retorna `true` | `fromCurrency` y `toCurrency` se intercambian |
| 26 | Dos no-VES con `isInput: true` fuerza VES como `toCurrency` | Pivot rule |
| 27 | Dos no-VES con `isInput: false` fuerza VES como `fromCurrency` | Pivot rule |
| 28 | `isInput: true` setea `fromCurrency` y recalcula | `toCurrency.convertedValue` cambia |
| 29 | `isInput: false` setea `toCurrency` con cálculo inverso | `fromAmount = (1.0 * toRate) / fromRate` |

### `swapCurrencies()`

| # | Test | Descripción |
|---|------|-------------|
| 30 | Después del swap, `from` y `to` están intercambiados | |
| 31 | Se recalcula automáticamente tras el swap | `toCurrency.convertedValue` refleja el nuevo cálculo |

### `_updateCurrenciesAndInit()`

| # | Test | Descripción |
|---|------|-------------|
| 32 | No añade duplicados si `averageCurrencies` y `bcvCurrencies` comparten composite key | Lista `currencies` no tiene entradas repetidas |
| 33 | Selección inicial usa VES como `fromCurrency` | `pivotCurrency.keyName == 'VES'` |
| 34 | Selección inicial usa la primera no-VES como `toCurrency` | |
| 35 | No reinicializa si `fromCurrency.keyName` ya es válido | Estado previo se conserva |

### `getRoundedCurrency()`

| # | Test | Descripción |
|---|------|-------------|
| 36 | Formato correcto `"X ≈ Y"` | Verifica el separador `≈` y los valores de `originalValue` |

---

## Unit Tests — `SettingsController`

> Archivo sugerido: `test/shared/presentation/controller/settings_controller_test.dart`
> Requiere mock de `SharedPreferences` (`SharedPreferences.setMockInitialValues`).

| # | Test | Descripción |
|---|------|-------------|
| 37 | `setFavMarket` no persiste si el índice ya es el activo | `SharedPreferences` no debe recibir `setInt` |
| 38 | `setFavMarket` persiste el nuevo índice | Valor en prefs == índice nuevo |
| 39 | `setFavLanguage` no cambia locale si ya es el código activo | |
| 40 | `setFavLanguage` actualiza `favLanguageCode` y llama `Get.updateLocale` | |
| 41 | `setFavTheme` no escribe en prefs si el tema no cambió | |
| 42 | `setFavTheme` persiste el nombre del nuevo `ThemeMode` | |
| 43 | `_loadPreferences` carga valores previos de prefs al inicio | Simular prefs pre-pobladas |
| 44 | `_loadPreferences` usa `ThemeMode.system` si no hay valor guardado | |

---

## Integration Tests — `CurrencyRepository`

> Archivo sugerido: `test/shared/data/repositories/currency_repository_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 45 | `refreshData` pone `isLoading` en `true` antes de las llamadas | Observable cambia antes del `await` |
| 46 | `refreshData` pone `isLoading` en `false` al finalizar (éxito) | |
| 47 | `refreshData` pone `isLoading` en `false` al finalizar (error) | No queda en `true` si el datasource falla |
| 48 | `getAveragedCurrencies` asigna correctamente la lista de `averageCurrencies` | |
| 49 | `getAveragedCurrencies` no lanza excepción si el datasource falla | Silencia el error |
| 50 | `getBCVCurrencies` asigna `bcvCurrencies` y `bcvCurrentDate` | |
| 51 | `getBCVCurrencies` no lanza excepción si el datasource falla | |

---

## Widget Tests

> Archivo sugerido: `test/features/home/home_page_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 52 | Muestra skeleton cuando `isLoading == true` | `CustomSkeletonizer` visible |
| 53 | Muestra datos reales cuando `isLoading == false` y datos disponibles | |
| 54 | `GetBuilder` se reconstruye cuando `averageCurrencies` cambia | |

> Archivo sugerido: `test/features/converter/converter_page_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 55 | El campo de texto dispara `calculator` con el valor ingresado | |
| 56 | El botón de swap intercambia los labels de las monedas | |
| 57 | El modal de selección llama a `selectCurrency` con el parámetro correcto | |

---

## Golden Tests (snapshot)

> Archivo sugerido: `test/shared/presentation/widgets/golden_test.dart`

| # | Test | Widget | Descripción |
|---|------|---------|-------------|
| 58 | `PerformanceIndicatorWidget` tendencia positiva | `tendency > 0` | Flecha e color verde |
| 59 | `PerformanceIndicatorWidget` tendencia negativa | `tendency < 0` | Flecha e color rojo |
| 60 | `PerformanceIndicatorWidget` tendencia neutral | `tendency == 0` | Sin flecha o color neutro |
| 61 | `CustomSkeletonizer` activo | `enabled: true` | Efecto shimmer visible |
| 62 | `CustomSkeletonizer` inactivo | `enabled: false` | Contenido real visible |

---

## Notas de Setup

```dart
// Para tests de controllers con GetX:
setUp(() => Get.testMode = true);
tearDown(() => Get.reset());

// Para tests de SettingsController:
SharedPreferences.setMockInitialValues({});

// Para tests que requieren mocktail (agregar a dev_dependencies):
// mocktail: ^0.3.0
```