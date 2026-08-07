# Release Notes - v1.0.1 🚀

**Fecha de lanzamiento:** 07 de Agosto de 2026

## Visión General

`v1.0.1` es la primera versión de producción realmente funcional de BCV Tracker
tras la `v1.0.0`, que solo contenía el andamiaje inicial y la licencia. Esta
promoción trae al fin todo el trabajo acumulado en `development`: **restaura la
carga de tasas** (el backend migró `saved-currencies` a POST y la app se había
quedado sin datos en el tab promedio), **hace la app resistente a fallos** con
mensajes de error claros y estados con branding, y **levanta la red de seguridad**
del proyecto (tests, golden tests y validación en CI). Para el usuario, la app
vuelve a mostrar las tasas y deja de romperse cuando algo va mal.

## Registro de Cambios

### UI/UX
- Estados de **error** y **vacío** rediseñados con el branding (icono/logo,
  paleta del proyecto y botón de reintento), compartidos por Home y Converter.
- Migración a **Material 3** preservando el aspecto (ColorScheme por tema,
  componentes on-brand).
- Mensajes de error **comprensibles y traducidos** según el tipo de fallo.

### Datos / Red
- `saved-currencies` se consume vía **POST con Body por mercado**
  (`MarketSelection`), acorde al nuevo contrato del backend.
- El conversor ya no divide por una tasa inutilizable (`Infinity`/`NaN`).
- Validación de **certificado TLS** restaurada; `CURRENCY_BACK` validada al
  arrancar; logging estructurado con redacción de URLs.

### Ingeniería / Estructura
- Rutas nombradas de GetX; GetX importado por su API pública; dependencias
  muertas eliminadas; análisis estático estricto.
- `DESIGN.md` como fuente del sistema de diseño y convenciones de agentes en
  `.agents/`.

### Calidad
- **CI de validación de PR** (GitHub Actions: analyze + test) en cada PR.
- Suite de tests (controladores, repositorios, datasource, helpers, i18n) y
  **golden tests** de las pantallas en tema claro y oscuro.

### i18n
- Corregidas traducciones de nombres de divisa; paridad de claves verificada por
  test en los 10 idiomas.

## Compatibilidad

- **Requiere** un backend que sirva `saved-currencies` como **POST** con el Body
  `MarketSelection` (contrato v1 actual de `bcv_tracker_backend`). Una instalación
  apuntando a un backend anterior (GET) no cargará el tab promedio.
- Sin cambios en `minSdkVersion` ni en el deployment target de iOS.
- Sin migraciones de datos locales (`SharedPreferences`).

## Próximos Pasos

- Selección dinámica de mercados seguidos desde Ajustes (línea del Body por
  mercado, #71 del backend).
- Mostrar la versión de la app en Ajustes (`package_info_plus`).

*BCV Tracker - Monitorizando la economía con precisión y elegancia.*
