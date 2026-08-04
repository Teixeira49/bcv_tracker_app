<p align="center">
  <img src="assets/images/foreground_icon_app.png" alt="BCV Tracker Logo" width="150">
</p>

# BCV Tracker App

**BCV Tracker** es una aplicación móvil desarrollada con Flutter diseñada para monitorear y gestionar las tasas de cambio oficiales proporcionadas por el Banco Central de Venezuela (BCV). La aplicación ofrece una interfaz intuitiva y herramientas útiles para usuarios que necesitan mantenerse al día con las fluctuaciones cambiarias.

## 🚀 Features Implementados

- **Dashboard de Tasas:** Visualización en tiempo real de las tasas de cambio oficiales del BCV y del promedio de mercados.
- **Selección de Mercados:** Elige desde los ajustes qué mercados quieres seguir.
- **Convertidor de Divisas:** Conversión entre Bolívares (VES) y otras divisas, con VES como moneda pivote.
- **Soporte Multi-idioma:** Localización en 10 idiomas — español, inglés, portugués, francés, alemán, italiano, ruso, coreano, japonés y chino simplificado.
- **Tema Claro y Oscuro:** Con opción de seguir el tema del sistema.
- **Arquitectura Feature-First:** Estructura modular por capas sobre GetX.

## 🧭 Planificado

Lo siguiente **todavía no está implementado**. Cada punto enlaza a su issue:

- **Histórico y Gráficos** — evolución diaria del dólar ([#5](https://github.com/Teixeira49/bcv_tracker_app/issues/5)).
- **Modo Offline** — caché local de las últimas tasas ([#17](https://github.com/Teixeira49/bcv_tracker_app/issues/17)). Hoy `SharedPreferences` solo guarda preferencias de usuario, no tasas.

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
   Copia la plantilla pública y completa los valores reales:
   ```bash
   cp .env.example .env
   ```

   | Variable | Descripción |
   |---|---|
   | `CURRENCY_BACK` | URL base del backend de tasas, **sin barra final**. Los paths son absolutos (`/api/v1/...`), así que una barra final construiría `//api/v1/...` y el backend respondería un 308 en vez de servir el recurso. |

   ```env
   CURRENCY_BACK=https://tu-backend.example.com
   ```

   > `.env` está en `.gitignore`: nunca lo commitees ni pongas en `.env.example` una URL real o una IP de despliegue. Ver [`.agents/rules/environment-variables.md`](.agents/rules/environment-variables.md).

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

## 🤝 Contribuir

Antes de abrir un PR, lee la [**Guía de Contribución**](CONTRIBUTING.md): arquitectura, reglas de implementación y el flujo `issue → rama → commits → PR → release`.

### 🤖 Tooling agéntico

Este repositorio versiona convenciones y capacidades para desarrollo asistido por IA en [`.agents/`](.agents/), más la config compartida en `.claude/pr-config.json` y el lockfile `skills-lock.json`. Al clonar, todo el equipo dispone de las mismas reglas sin configuración extra.

```
.agents/
├── rules/    # 16 convenciones obligatorias (issues, ramas, commits, PR, releases,
│             #  versionado y las reglas técnicas de Flutter/Dart/GetX)
└── skills/   # 24 skills, de 6 orígenes (ver .agents/ATTRIBUTION.md)
```

Las convenciones de flujo de trabajo son **idénticas a las del backend** (mismo mapeo `type → gitmoji → label`), y las técnicas están adaptadas a esta app. El índice completo está en [`.agents/README.md`](.agents/README.md), la procedencia y licencia de cada skill en [`.agents/ATTRIBUTION.md`](.agents/ATTRIBUTION.md), y el resumen en [CONTRIBUTING.md → Tooling Agéntico](CONTRIBUTING.md#-tooling-agéntico-agents-y-claude).

---

**Versión actual del proyecto:** 1.0.0+1
**SDK de Dart compatible:** ^3.9.0
