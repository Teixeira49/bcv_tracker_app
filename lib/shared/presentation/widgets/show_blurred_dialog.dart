import 'dart:ui'; // Necesario para ImageFilter
import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:flutter/material.dart';

/// Muestra [builder] como un diálogo centrado sobre un fondo difuminado.
///
/// El único punto de entrada de `BaseModal`: el desenfoque es cómo esta app
/// eleva un diálogo (ver `DESIGN.md` → Elevation & Depth), no una sombra dura,
/// y hacerlo aquí evita que cada llamada repita el `BackdropFilter`.
///
/// **Sin llamadas hoy**, por la misma razón que `BaseModal`: los ajustes eran
/// su único uso hasta [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37).
/// Se conserva con él — un diálogo suelto abierto con `Get.dialog` es
/// exactamente lo que esta función existe para impedir.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    // Duración de la animación de entrada y salida
    transitionDuration: const Duration(milliseconds: 200),
    // Define cómo se construye la animación de transición
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Usa un FadeTransition para que el diálogo aparezca y desaparezca suavemente
      return FadeTransition(opacity: animation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        // El sigmaX y sigmaY controlan la intensidad del difuminado
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: builder(context), // Aquí se construye tu AlertDialog
      );
    },
    // Es importante hacer el fondo transparente para que se vea el contenido detrás del BackdropFilter
    barrierColor: ColorValues.textBlack(context).withAlpha(51),
    barrierDismissible: true,
    barrierLabel: '', // Requerido por la API
  );
}
