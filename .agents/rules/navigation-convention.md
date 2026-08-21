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

   **Un modal no es una pantalla**: los puntos 3 y 5 no le aplican. El detalle de moneda ([#38](https://github.com/Teixeira49/bcv_tracker_app/issues/38)) y el selector de divisas del conversor ([#40](https://github.com/Teixeira49/bcv_tracker_app/issues/40)) son hojas inferiores: ninguno está en `AppPages` y ambos reciben sus datos por constructor. Lo que sí exige la regla es un **único punto de entrada por modal** —`showCurrencyDetailSheet`, `showCurrencySelectorSheet`—, no `Get.bottomSheet` esparcido por los widgets. El costo, consciente: un modal no es alcanzable por deep link — cuando eso haga falta, se registra un `GetPage` que resuelva el dato desde un parámetro de ruta y renderice el mismo widget.

   **Y esa decisión se revisa cuando la superficie crece.** Los ajustes eran el tercer modal de esta lista hasta [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37): un `AlertDialog` con tres selectores, uno de ellos un desplegable de diez idiomas. Lo que lo movió a ruta no fue el aspecto sino el techo — un diálogo no crece, y las opciones en cola (#13, #33, #34, «acerca de») no caben en él a ninguna escala tipográfica. La señal a vigilar es esa: **si un modal tiene que listar, agrupar o crecer, ya es una pantalla**, y el precio de moverlo tarde es rehacer su contenido además de su contenedor.

   **Las hojas inferiores comparten contenedor**: `shared/presentation/widgets/base_bottom_sheet.dart` (`BaseBottomSheet` + `showAppBottomSheet`). No abras una hoja con `Get.bottomSheet` a mano ni construyas otro `DraggableScrollableSheet`: el contenido entra como **slivers**, porque el arrastre que redimensiona y el scroll que mueve el contenido son la misma cadena de gestos. Anidar un `ListView` dentro la rompe y la hoja se cierra cuando el usuario quería desplazar.
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

Son **ocho** rutas: `splash`, `home`, y los ajustes con sus cinco subpantallas (`/settings`, `/settings/market`, `/settings/language`, `/settings/theme`, `/settings/decimals`, `/settings/about`). Las cuatro últimas anidan el nombre bajo `/settings` a propósito: dice que se llega desde el menú, que es lo que debería significar un deep link a `/settings/language`.

`/settings/decimals` es el incremental de #37 y la primera ruta añadida **a través** del menú en vez de con él — que es exactamente la forma que pedía el último criterio de aceptación: un ajuste llega como una entrada y una página, sin rediseñar nada. `/settings/about` (#42) es la segunda, y prueba que la forma aguanta algo que **no** es un ajuste: la pantalla no configura nada, y aun así entra como una entrada más.

## Al agregar una pantalla

En el **mismo** cambio:

1. Constante en `AppRoutes` (`static const detail = '/detail';`).
2. `GetPage` en `AppPages.routes`, con su `transition` si aplica.
3. Si la pantalla necesita un controlador propio, regístralo en `initial_bindings.dart` (ver `dependency-injection.md`).
4. Los textos de la pantalla, vía `AppMessages` y en los 10 idiomas (ver `i18n-convention.md`).
