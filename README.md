<p align="center">
  <img src="assets/images/foreground_icon_app.png" alt="BCV Tracker Logo" width="150">
</p>

# BCV Tracker App

**BCV Tracker** es una aplicación móvil desarrollada con Flutter diseñada para monitorear y gestionar las tasas de cambio oficiales proporcionadas por el Banco Central de Venezuela (BCV). La aplicación ofrece una interfaz intuitiva y herramientas útiles para usuarios que necesitan mantenerse al día con las fluctuaciones cambiarias.

## 🚀 Features Implementados

- **Dashboard de Tasas:** Visualización en tiempo real de las tasas de cambio oficiales.
- **Convertidor de Divisas:** Herramienta integrada para realizar conversiones rápidas entre Bolívares (VES) y otras divisas.
- **Histórico y Gráficos:** Seguimiento de la evolución de los precios.
- **Soporte Multi-idioma:** Localización completa en múltiples idiomas:
  - Español, Inglés, Portugués, Francés, Alemán, Italiano, Ruso, Coreano y Japonés.
- **Modo Offline:** Persistencia de datos para consulta de las últimas tasas descargadas sin conexión.
- **Arquitectura Limpia:** Estructura de proyecto modular y escalable.

## 🛠️ Instalación del Repositorio

Para obtener una copia local del proyecto, sigue estos pasos:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Teixeira49/bcv_tracker_app.git
   cd bcv_tracker_app
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configuración de Variables de Entorno:**
   Crea un archivo `.env` en la raíz del proyecto basándote en el archivo de ejemplo o agrega las siguientes variables necesarias para la conexión con el backend:
   ```env
   API_URL=http://tu-direccion-ip-o-dominio:puerto
   ```

## 🏗️ Compilación del Proyecto

### Requisito Indispensable: Backend
Esta aplicación depende directamente de su servicio backend para obtener los datos actualizados. Debes tener desplegado el backend que se encuentra en el siguiente repositorio:
👉 [BCV Tracker Backend](https://github.com/Teixeira49/bcv_tracker_backend)

---

### Android 🤖
- **Versión Mínima de SDK:** 23 (Android 6.0 Marshmallow).
- **Requisitos:** Android Studio instalado y configurado con el SDK de Android.
- **Comando para compilar APK:**
  ```bash
  flutter build apk --release
  ```

### iOS 🍎
- **Versión Mínima de iOS:** 12.0.
- **Requisitos:** macOS con Xcode instalado y CocoaPods.
- **Pasos adicionales:**
  ```bash
  cd ios
  pod install
  cd ..
  ```
- **Comando para compilar:**
  ```bash
  flutter build ios --release
  ```

---

**Versión actual del proyecto:** 1.0.0+1
**SDK de Dart compatible:** ^3.9.0
