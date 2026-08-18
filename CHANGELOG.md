# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
y el proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).

## [1.1.0] - 2026-08-18

Primera versión que añade funcionalidad para el usuario tras la `v1.0.1`, que
había dejado la app funcionando y con red de pruebas. Tocar una tasa abre su
detalle, se puede convertir desde ahí y buscar una moneda por nombre o mercado;
y el arranque lleva la marca desde el primer fotograma.

### Added
- Detalle de moneda como hoja inferior, abierto desde las tarjetas de Home, con
  cabecera, tabla de datos y los huecos reservados para el histórico y las
  acciones.
- Conversor rápido dentro del detalle, fijado a esa tasa y con inversión de
  sentido; comparte la aritmética con el conversor completo (`CurrencyConversion`).
- Acción «abrir en el conversor», que pasa la tasa al conversor completo
  llevándose el monto y el sentido.
- Buscador en el selector de divisas: filtra por código, nombre y mercado,
  ignorando mayúsculas y acentos, con estado propio de «sin resultados».
- Splash con el logo de marca animado (icono y wordmark por separado) y pantalla
  de arranque **nativa** con el navy de marca en Android e iOS.
- `lib/` documentado con dartdoc: 75 de 75 tipos públicos, y una regla de
  cobertura para que no retroceda.

### Changed
- **iOS requiere ahora 15.0** (antes 13.0), porque `firebase_core: ^4.10.0`
  arrastra el Firebase iOS SDK 12.14.0. No cae ningún dispositivo (iOS 15 soporta
  el mismo hardware que iOS 13) y iOS no se ha publicado nunca; ver la sección de
  compatibilidad del release note.
- El selector de divisas pasa de diálogo centrado a hoja inferior, con contenedor
  compartido (`BaseBottomSheet`) y una sola cadena de gestos.
- `SettingsController` pasa a ser un `GetxService` inicializado con `Get.putAsync`
  y esperado antes de `runApp`: el tema y el idioma guardados están puestos en el
  primer frame.
- Los códigos de idioma `en_EN` y `ja_JA` se corrigen a `en_US` y `ja_JP`, con
  migración de las instalaciones que guardaban los antiguos.
- La conversión pivote sale del controlador a `shared/domain/conversion.dart`.
- Las notas del tester en Firebase salen de `release_notes.json` en vez de
  `Build #N – rama master`.
- Flutter fijado en 3.38.3 en los cuatro sitios que deben moverse juntos, en vez
  de seguir `stable`.

### Fixed
- En una instalación nueva, el selector de idioma mostraba «Español» mientras la
  app se veía en el idioma del dispositivo, y tocar ese idioma no hacía nada.
- El conversor redondea al mostrar y no al calcular, así que un resultado ya no
  aparece con catorce decimales ni pierde precisión al invertirse.
- El campo de monto filtra lo que acepta, incluso desde un teclado físico o un
  pegado.
- «Dólar» se escribe con tilde en español en las tarjetas de Home y en el selector.
- El botón de intercambio se queda en la costura entre las tarjetas del conversor
  aunque la de salida crezca, y el conversor no desborda al abrirse el teclado.
- El contenido de las hojas inferiores tiene su propio `Material`, así que la
  tinta de los toques se pinta donde debe.
- La pestaña de Home ya no destruye el servicio de ajustes de toda la app al
  descartarse.

## [1.0.1] - 2026-08-07

Primera versión de producción funcional tras `v1.0.0` (que solo contenía el
andamiaje inicial). Restaura la carga de tasas, endurece la app y añade la red
de pruebas y CI.

### Added
- Mensajes de error diferenciados por tipo de fallo (sin conexión, timeout,
  servidor, respuesta inesperada…), traducidos en los 10 idiomas.
- Estados de error y vacío con branding (icono/logo, paleta del proyecto y
  botón de reintento) compartidos por Home y Converter.
- Migración a Material 3 (`ColorScheme` por tema, componentes on-brand)
  preservando el aspecto de la app.
- `DESIGN.md` como fuente del sistema de diseño, con tokens y reglas de agentes
  en `.agents/`.
- Logging estructurado con redacción de URLs (sin filtrar tokens).
- Validación de PR en CI (GitHub Actions: `flutter analyze` + `flutter test`) y
  golden tests de las pantallas en tema claro y oscuro.
- Suite de tests para controladores, repositorios, datasource, helpers, i18n y
  estados de pantalla.
- Validación de `CURRENCY_BACK` al arrancar, con error claro si falta o no es
  una URL válida.

### Changed
- `saved-currencies` se consume vía **POST con Body por mercado**
  (`MarketSelection`), tras la migración del backend.
- Navegación mediante rutas nombradas de GetX; GetX importado por su API
  pública.
- Análisis estático estricto y eliminación de dependencias declaradas sin usar.

### Fixed
- Las tasas del tab promedio vuelven a cargar (el backend pasó `saved-currencies`
  de GET a POST).
- El conversor ya no divide por una tasa inutilizable (evita `Infinity`/`NaN`).
- Un código de idioma desconocido ya no rompe la pantalla de Ajustes.
- Validación de certificado TLS restaurada: no se aceptan certificados
  inválidos.
- Traducciones de nombres de divisa corregidas.
- Restaurado el alfa del color de *warning*.
- La lista de divisas del BCV se convierte correctamente en `toEntity()`.
- Un `.env` ilegible se reporta en vez de tumbar el arranque.

[1.1.0]: https://github.com/Teixeira49/bcv_tracker_app/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/Teixeira49/bcv_tracker_app/compare/v1.0.0...v1.0.1
