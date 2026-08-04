---
description: Obliga a registrar toda dependencia de GetX (controladores, repositorios, datasources, servicios) en lib/config/bindings/initial_bindings.dart y a resolverlas con Get.find(); prohíbe instanciar controladores o repositorios a mano dentro de widgets. Aplica cada vez que se cree un controlador, repositorio o servicio nuevo.
---

# Inyección de Dependencias (GetX)

`lib/config/bindings/initial_bindings.dart` es el **único** lugar donde se registran dependencias. Un solo archivo describe el grafo completo de la app: qué existe, con qué ciclo de vida y de qué depende cada cosa.

El riesgo que evita: un `HomeController()` instanciado dentro de un widget crea una **segunda** instancia paralela a la registrada. Las dos escuchan al mismo `CurrencyRepository`, pero solo una está enlazada a la vista — y el bug se manifiesta como "la pantalla no se actualiza", muy lejos de su causa.

## Regla

1. **Todo registro va en `InitialBinding.dependencies()`**. No hay bindings por página ni registros dispersos: no crees `HomeBinding`, `ConverterBinding`, etc.
2. **Resolver siempre con `Get.find<T>()`** (o `Get.find()` cuando el tipo se infiere). Nunca `Controller()` a mano en un widget, un `initState` o un callback.
3. **Registra contra la abstracción, no la implementación**, cuando exista interfaz: `Get.lazyPut<IDollarRepository>(() => DollarRepository(dollarApi: Get.find()), fenix: true)`. Los consumidores dependen de `IDollarRepository`, no de `DollarRepository`.
4. **Elige el ciclo de vida a conciencia**:

   | Necesidad | Cómo registrarlo |
   |---|---|
   | Controlador de una vista, se puede reconstruir | `Get.lazyPut<T>(() => T(), fenix: true)` |
   | Estado compartido que debe sobrevivir a toda la app | `Get.put<T>(T(), permanent: true)` |
   | Servicio persistente con inicialización asíncrona | `extends GetxService` + `Get.putAsync` |

   `fenix: true` permite que la dependencia se recree tras ser descartada; es el default de esta app para controladores y repositorios.
5. **El orden importa cuando hay dependencias entre registros.** `Get.lazyPut` difiere la construcción, así que `Get.find()` dentro de la factory se resuelve al primer uso; pero si necesitas la instancia **durante** el binding (como `SettingsController` para construir `CurrencyRepository`), regístrala antes y resuélvela explícitamente.
6. **Las suscripciones cruzadas entre servicios también viven aquí.** Los `ever()` que conectan un observable de un servicio con otro (p. ej. recargar tasas cuando cambia la selección de mercados) se declaran en el binding, no dentro de un widget: así el cableado de la app se lee en un solo sitio.
7. **Un controlador no llama a `Get.put` de otro controlador.** Si `A` necesita `B`, `B` se registra en el binding y `A` hace `Get.find<B>()`.

## Ejemplo

**❌ Antes** — instancia paralela, invisible para el resto de la app:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = HomeController();   // ← nueva instancia, no la registrada
    return Obx(() => Text('${controller.averageCurrencies.length}'));
  }
}
```

**✅ Después** — se resuelve la instancia del binding:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Obx(() => Text('${controller.averageCurrencies.length}'));
  }
}
```

Y en `initial_bindings.dart`:

```dart
Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
```

## Al agregar una dependencia nueva

En el **mismo** cambio:

1. Regístrala en `InitialBinding.dependencies()`, junto a sus pares y respetando el orden si depende de otra.
2. Si es un repositorio o datasource, define primero su **interfaz** en `shared/domain/repositories/` (o `data/datasource/`) y registra la implementación contra ella.
3. Si mantiene estado compartido y debe sobrevivir a la navegación, decide entre `permanent: true` y `GetxService`, y **justifícalo en el PR**: cada dependencia permanente es memoria que no se libera nunca.
4. Verifica que los tests puedan sustituirla: los tests inyectan fakes con `Get.put`/`Get.replace` y limpian con `Get.reset()` (ver `test-coverage.md`). Una dependencia que solo se puede construir de una forma es una dependencia no testeable.

## Excepción

Los tests **sí** registran dependencias fuera del binding: es su forma de inyectar fakes. Deben limpiar el contenedor en el `tearDown` con `Get.reset()` para no filtrar estado entre casos.
