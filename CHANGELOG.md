# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
y el proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).

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

[1.0.1]: https://github.com/Teixeira49/bcv_tracker_app/compare/v1.0.0...v1.0.1
