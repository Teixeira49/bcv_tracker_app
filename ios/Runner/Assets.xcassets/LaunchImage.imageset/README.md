# Launch Screen Assets

**Estos PNG se generan; no los reemplaces a mano ni desde Xcode.** Salen de
`assets/brand/dt_icon.svg`, el mismo maestro que el icono de la app:

```bash
flutter test tool/generate_app_icon.dart
```

Escribe los tres tamaños (180², 360², 540²) con **fondo transparente**. El color
del arranque lo pone `backgroundColor` en `ios/Runner/Base.lproj/LaunchScreen.storyboard`
y solo se declara ahí, de modo que la imagen no puede desincronizarse de él.
Hasta #102 estos archivos eran los tres PNG en blanco de la plantilla de
`flutter create`, sobre fondo blanco.

Si cambias el tamaño, cambia también `<image name="LaunchImage" .../>` en el
storyboard: es la medida que reserva la escena. Contexto completo y el
equivalente en Android en [`assets/brand/README.md`](../../../../../assets/brand/README.md).
