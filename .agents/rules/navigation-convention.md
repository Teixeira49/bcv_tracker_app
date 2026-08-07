---
description: Obliga a navegar con rutas nombradas de GetX (Get.toNamed / Get.offAllNamed) declaradas en lib/config/routes/, y prohíbe usar Navigator de Flutter o pasar widgets directamente. Aplica cada vez que se agregue una pantalla o se navegue entre vistas.
paths:
  - "lib/config/routes/**"
  - "lib/**/page/**"
  - "lib/**/{widget,widgets}/**"
  - "lib/navigation/**"
---

# Navegación

La app navega con **rutas nombradas de GetX**. Las rutas se declaran en `lib/config/routes/routes.dart` (`AppRoutes`, las constantes) y se registran en `lib/config/routes/pages.dart` (`AppPages.routes`, los `GetPage`). Navegar es referenciar una constante de `AppRoutes`, nunca construir la página en el sitio de la llamada.

El riesgo que evita: `Get.to(() => DetailPage(currency: c))` acopla el origen al constructor del destino y deja esa pantalla fuera de la tabla de rutas — no es alcanzable por deep link, no aparece en `AppPages` y cada cambio de firma obliga a tocar todos los sitios que navegan hacia ella.

## Regla

1. **Nunca uses `Navigator` de Flutter** (`Navigator.push`, `Navigator.of(context).pushNamed`, `MaterialPageRoute`) para navegar entre pantallas. GetX gestiona la pila; mezclar ambos deja rutas que GetX no conoce.
2. **Nunca pases un widget a los métodos de navegación.** Ni `Get.to(() => Page())` ni `Get.offAll(() => Page())`. Usa siempre la variante `*Named`.
3. **Toda pantalla tiene su constante y su `GetPage`.** Antes de navegar hacia una vista nueva, agrégala a `AppRoutes` **y** a `AppPages.routes`.
4. **Elige el método por intención**:

   | Intención | Método |
   |---|---|
   | Apilar una pantalla encima | `Get.toNamed(AppRoutes.x)` |
   | Reemplazar la actual | `Get.offNamed(AppRoutes.x)` |
   | Vaciar la pila y arrancar de nuevo (splash → home, logout) | `Get.offAllNamed(AppRoutes.x)` |
   | Volver atrás | `Get.back()` |

5. **Argumentos vía `arguments`, no vía constructor**: `Get.toNamed(AppRoutes.detail, arguments: currency)` y se leen con `Get.arguments` en el controlador de destino (no en el `build` del widget). Para parámetros que deban sobrevivir a un deep link, usa parámetros de ruta (`/detail/:code`) y `Get.parameters`.
6. **Cerrar diálogos y modales**: usa `Get.back()`, no `Navigator.pop(context)`. Un `Get.back()` cierra lo que GetX tenga arriba de la pila y mantiene una sola forma de retroceder en todo el código.
7. **Las pestañas del bottom bar no son navegación de pila.** Cambiar de tab es cambiar el índice de `NavigationController`; no se hace con `Get.toNamed`. La navegación por rutas se reserva para pantallas que se apilan sobre el dashboard.
8. **La navegación se dispara desde la capa de presentación** (widget o controlador), nunca desde `shared/data/` ni desde un repositorio.

## Ejemplo

**❌ Antes** — widget directo, ruta fuera de la tabla:

```dart
Get.offAll(
  () => DashboardPage(),
  transition: Transition.fadeIn,
);
```

**✅ Después** — ruta nombrada ya registrada en `AppPages`:

```dart
Get.offAllNamed(AppRoutes.home);
```

Y si la transición importa, se declara en el `GetPage`, no en el sitio de la llamada:

```dart
GetPage(
  name: AppRoutes.home,
  page: () => DashboardPage(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 500),
),
```

## Estado

Sin desviaciones. Las rutas nombradas están cableadas en `GetMaterialApp` (`getPages: AppPages.routes`, `initialRoute: AppPages.initPage`), el splash navega con `Get.offAllNamed(AppRoutes.home)` y los modales cierran con `Get.back()`. La regla describe lo que el código hace, no un objetivo (resuelto en [#58](https://github.com/Teixeira49/bcv_tracker_app/issues/58)).

## Al agregar una pantalla

En el **mismo** cambio:

1. Constante en `AppRoutes` (`static const detail = '/detail';`).
2. `GetPage` en `AppPages.routes`, con su `transition` si aplica.
3. Si la pantalla necesita un controlador propio, regístralo en `initial_bindings.dart` (ver `dependency-injection.md`).
4. Los textos de la pantalla, vía `AppMessages` y en los 10 idiomas (ver `i18n-convention.md`).
