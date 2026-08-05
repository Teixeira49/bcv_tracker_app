import 'dart:ui'; // Necesario para ImageFilter
import 'package:bcv_tracker_app/config/theme/colors/colors_values.dart';
import 'package:flutter/material.dart';

// Función reutilizable para mostrar cualquier widget como un diálogo con fondo difuminado
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
