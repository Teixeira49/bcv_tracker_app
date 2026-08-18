# Release Notes - v1.1.0 🚀

**Fecha de lanzamiento:** 18 de Agosto de 2026

## Visión General

`v1.0.1` dejó la app funcionando y con red de pruebas. `v1.1.0` es la primera
versión que **añade cosas que el usuario puede hacer**, y son tres:

1. **Tocar una tasa y verla entera.** Las tarjetas de Home abren un detalle con
   mercado, par, tipo de tasa, variación y fechas — datos que la tarjeta no cabía
   mostrar.
2. **Convertir sin salir de ahí**, y llevarse la cuenta al conversor completo si
   se quiere seguir con otras divisas.
3. **Buscar una moneda** por nombre o por mercado, en vez de recorrer la lista.

Y el arranque deja de parecer dos aplicaciones encadenadas: la pantalla que pinta
el sistema operativo ya lleva la marca, el logo entra animado, y el tema y el
idioma guardados están puestos **desde el primer fotograma**.

Por debajo, la versión cierra tres defectos que se notaban y no se entendían: el
selector de idioma decía «Español» mientras la app estaba en inglés, el conversor
mostraba resultados con catorce decimales, y las tasas del promedio se ordenaban
por un plegado de acentos que nunca se ejecutaba porque ningún nombre llevaba
tilde.

## Registro de Cambios

### Nuevas funcionalidades

- **Detalle de moneda como hoja inferior** ([#38]): se abre tocando cualquier
  tarjeta de Home, con cabecera, tabla de datos y las secciones reservadas para
  el histórico ([#5]) y las acciones ([#7]).
- **Conversor rápido dentro del detalle** ([#39]), fijado a esa tasa, con inversión
  de sentido. Comparte la aritmética con el conversor completo
  (`CurrencyConversion`), así que los dos dan el mismo número por construcción.
- **Abrir en el conversor** ([#103]): pasa la tasa al conversor completo llevándose
  el monto y el sentido, para continuar la cuenta en vez de reiniciarla.
- **Buscador en el selector de divisas** ([#41]): filtra por código, nombre y
  mercado, ignorando mayúsculas y acentos, con un estado propio de «sin
  resultados».

### UI/UX

- El **selector de divisas** pasa de diálogo centrado a **hoja inferior** ([#40]),
  con contenedor compartido (`BaseBottomSheet`) y una sola cadena de gestos entre
  el arrastre y el scroll.
- **Splash con el logo de marca** ([#10]): icono y wordmark animados por separado,
  renderizados desde el SVG y no desde un PNG estirado.
- **Pantalla de arranque nativa con la marca** ([#102]) en Android e iOS: el
  destello blanco del sistema desaparece y la transición al splash de Flutter deja
  de mostrar un cambio brusco de color.
- El **icono de la app** se regenera desde el vector, nítido en todas las
  densidades ([#10]).
- El botón de intercambio del conversor se queda en la costura entre las tarjetas
  aunque la de salida crezca; el conversor ya no desborda al abrirse el teclado.

### Correcciones

- **El selector de idioma decía la verdad a medias** ([#98]): en una instalación
  nueva la app se veía en el idioma del dispositivo mientras el selector mostraba
  «Español», y tocar ese idioma no hacía nada. Ahora la app **sigue al
  dispositivo** hasta que el usuario elige, y el selector muestra el idioma que
  se está viendo. Los códigos `en_EN` y `ja_JA` se corrigen a `en_US` y `ja_JP`,
  **migrando** las instalaciones que ya guardaban los antiguos.
- **El conversor redondea al mostrar, no al calcular** ([#39]): `864.0962999999999`
  se muestra como `864.10` y la precisión se mantiene en el cálculo, incluso al
  invertir el sentido.
- El campo de monto **filtra lo que acepta** (dígitos y un separador), incluso
  desde un teclado físico o un pegado.
- «Dólar» se escribe **con tilde** en español ([#104]) en las tarjetas de Home y
  en el selector.
- El contenido de las hojas inferiores tiene su propio `Material`, así que la
  tinta de los toques se pinta donde debe.

### Ingeniería / Estructura

- **Los ajustes se cargan antes del primer frame** ([#59]): `SettingsController`
  pasa a ser un `GetxService` inicializado con `Get.putAsync` y esperado antes de
  `runApp`. El tema y el idioma guardados ya no aterrizan *después* de que la UI
  empiece a construirse — una ventana que los tres segundos del splash tapaban
  por accidente.
- La **conversión pivote** sale del controlador a `shared/domain/conversion.dart`
  ([#39]), que es lo que hace verificable que los dos conversores coincidan.
- Un **bug de ciclo de vida** que el refactor destapó: la pestaña de Home
  destruía el servicio de ajustes de toda la app al descartarse.

### CI / Distribución

- **Las notas del tester salen de `release_notes.json`** ([#93]): los tres
  workflows derivan un `.txt` del JSON y lo pasan al CLI de Firebase, en vez del
  `Build #N – rama master` que no decía nada. Si el JSON está mal, el build cae en
  segundos y no distribuye notas vacías.
- **Flutter fijado en 3.38.3** en los cuatro sitios que tienen que moverse juntos,
  en vez de seguir `stable` — que ya hizo que CI corriera por delante de las
  máquinas de desarrollo.
- `all-platforms-firebase` adjunta el `.sha1` del APK, que era el único de los
  tres que no lo hacía.

### Documentación

- **Todo `lib/` documentado con dartdoc** ([#4]): de 31 de 75 tipos públicos a
  **75 de 75**, y `dart doc` de 8 avisos a **0**.
- **Regla de cobertura de documentación** ([#112]) para que ese nivel no retroceda
  en silencio, con el invariante, las tres exenciones declaradas y qué hacer
  cuando un docstring se queda rancio.
- `assets/brand/README.md` documenta las tres pantallas del arranque y los cuatro
  sitios donde vive el navy de marca.

## Evolución de la Arquitectura

| | v1.0.1 | v1.1.0 |
|---|---|---|
| Aritmética de conversión | En `ConverterController` | En `shared/domain/conversion.dart`, compartida por los dos conversores |
| Ajustes | `GetxController`, cargados en `onInit` sin esperar | `GetxService` con `Get.putAsync`, **esperado antes de `runApp`** |
| Registro de dependencias | Solo `dependencies()` | `dependencies()` + `initServices()`, porque GetX **no espera** al primero |
| Hojas inferiores | No había | `BaseBottomSheet` compartido, contenido en slivers |
| Idioma inicial | `Get.deviceLocale` en la UI, `es_ES` en el selector | Un solo valor: el dispositivo resuelto dentro de `favLanguageCode` |
| Tipos documentados | 31 / 75 | **75 / 75** |
| Tests | 226 | **337** |

## Compatibilidad

### ⚠️ iOS requiere ahora **15.0** (antes 13.0)

`firebase_core: ^4.10.0` arrastra el **Firebase iOS SDK 12.14.0**, que exige iOS
15, así que el deployment target subió de `13.0` a `15.0`. **No fue una decisión
del proyecto**: entró como efecto de un `pod install`, y revertirlo rompería la
resolución de pods.

**Por qué esta versión es `1.1.0` y no `2.0.0`.** `version-value-proposal.md`
clasifica una subida del deployment target como MAJOR, porque deja dispositivos
sin actualización. Ese motivo no puede aplicar aquí, y conviene que quede escrito:

- **iOS nunca se ha publicado.** El bundle identifier sigue siendo
  `com.example.bcvTrackerApp` ([#22] bloquea la subida a las tiendas) y los dos
  workflows de iOS están desactivados (`triggering: events: []`). No hay ninguna
  instalación de iOS que pueda quedarse atrás.
- **No cae ningún dispositivo.** iOS 15 soporta el mismo hardware que iOS 13
  (iPhone 6s en adelante). Solo afectaría a quien no haya actualizado el sistema
  — en una plataforma donde la app no existe.

La desviación se documenta aquí en vez de ajustarse en silencio, como exige la
regla de asimetría. El seguimiento del requisito queda en [#114].

### Sin cambios en el resto

- **Android**: `minSdkVersion` sigue en 23. Ningún dispositivo pierde soporte.
- **Backend**: mismo contrato que `v1.0.1` (`saved-currencies` vía POST con
  `MarketSelection`).
- **Datos locales**: las claves de `SharedPreferences` no cambian. Los valores de
  idioma `en_EN` y `ja_JA` **se migran** a `en_US` y `ja_JP` en el primer arranque,
  así que una instalación existente conserva el idioma que había elegido.

## Próximos Pasos

- **[#22]** — identificadores de bundle reales, que es lo que desbloquea publicar.
- **[#5]** y **[#7]** — el histórico y las acciones del detalle, cuyos huecos esta
  versión ya deja cableados en su sitio.
- **[#45]** — la disposición de workers de GetX, hoy una obligación de convención
  en cada controlador nuevo.

[#4]: https://github.com/Teixeira49/bcv_tracker_app/issues/4
[#5]: https://github.com/Teixeira49/bcv_tracker_app/issues/5
[#7]: https://github.com/Teixeira49/bcv_tracker_app/issues/7
[#10]: https://github.com/Teixeira49/bcv_tracker_app/issues/10
[#22]: https://github.com/Teixeira49/bcv_tracker_app/issues/22
[#38]: https://github.com/Teixeira49/bcv_tracker_app/issues/38
[#39]: https://github.com/Teixeira49/bcv_tracker_app/issues/39
[#40]: https://github.com/Teixeira49/bcv_tracker_app/issues/40
[#41]: https://github.com/Teixeira49/bcv_tracker_app/issues/41
[#45]: https://github.com/Teixeira49/bcv_tracker_app/issues/45
[#59]: https://github.com/Teixeira49/bcv_tracker_app/issues/59
[#93]: https://github.com/Teixeira49/bcv_tracker_app/issues/93
[#98]: https://github.com/Teixeira49/bcv_tracker_app/issues/98
[#102]: https://github.com/Teixeira49/bcv_tracker_app/issues/102
[#103]: https://github.com/Teixeira49/bcv_tracker_app/issues/103
[#104]: https://github.com/Teixeira49/bcv_tracker_app/issues/104
[#112]: https://github.com/Teixeira49/bcv_tracker_app/issues/112
[#114]: https://github.com/Teixeira49/bcv_tracker_app/issues/114

---

*DolarTracker - Monitorizando la economía con precisión y elegancia.*
