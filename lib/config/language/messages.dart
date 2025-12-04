
import 'package:get/get.dart';

class AppMessages {

  static final String dollar = 'dollar'.tr;

  static final String todayTax = 'today_tax'.tr;

  static final String dateTax = 'date_tax'.tr;
}

/* Uso

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Necesario para .tr

class MyTranslatedPage extends StatelessWidget {
  const MyTranslatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = "Usuario GetX";
    int itemCount = 5;

    return Scaffold(
      appBar: AppBar(
        // Para traducir el título del AppBar si es dinámico:
        title: Text('app_title'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('hello'.tr, style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('welcome_message'.tr, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            // Traducción con parámetros
            Text(
              'greeting'.trParams({'name': userName}),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Traducción con pluralización
            // '.trPluralParams' es más explícito para plurales si tienes problemas con .trParams
            Text(
              'items_available'.trPluralParams(
                // O usa directamente .trParams si tu clave está bien configurada para plurales
                // 'items_available'.trParams({
                'count': itemCount.toString(),
              ),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Lógica para mostrar un diálogo de cambio de idioma
                _showLanguageDialog(context);
              },
              child: Text('change_language'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'change_language'.tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('english'.tr),
            onTap: () {
              Get.updateLocale(const Locale('en', 'US'));
              Get.back(); // Cierra el diálogo
            },
          ),
          ListTile(
            title: Text('spanish'.tr),
            onTap: () {
              Get.updateLocale(const Locale('es', 'ES'));
              Get.back();
            },
          ),
          ListTile(
            title: Text('french'.tr),
            onTap: () {
              Get.updateLocale(const Locale('fr', 'FR'));
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

 */

// Para actualizar idioma:
/*
// Cambiar a Español
Get.updateLocale(const Locale('es', 'ES'));

// Cambiar a Inglés
Get.updateLocale(const Locale('en', 'US'));*/