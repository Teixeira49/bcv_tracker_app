import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:bcv_tracker_app/shared/domain/conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Los números siguen al idioma que el usuario eligió (#63).
///
/// El defecto que arregla: `toStringAsFixed` escribe **siempre** un punto, y
/// seis de los diez idiomas que la app publica usan coma. Una tasa mal puntuada
/// no es un desliz de estilo en una app financiera — es una cifra que hay que
/// releer para estar seguro.
///
/// El locale sale de **`Get.locale`**, no del sistema: el usuario puede haber
/// puesto la app en un idioma distinto al del teléfono, y el separador tiene
/// que seguir a lo que está leyendo.
void main() {
  tearDown(Get.reset);

  /// Deja `Get.locale` puesto sin montar una app entera.
  void useLocale(String language, String country) {
    Get.locale = Locale(language, country);
  }

  group('el separador decimal sigue al idioma', () {
    // Seis de los diez usan coma; el inglés es el que conserva el punto.
    const Map<String, (String, String)> comma = <String, (String, String)>{
      'español': ('es', 'ES'),
      'alemán': ('de', 'DE'),
      'italiano': ('it', 'IT'),
      'francés': ('fr', 'FR'),
      'portugués': ('pt', 'PT'),
      'ruso': ('ru', 'RU'),
    };

    comma.forEach((String name, (String, String) locale) {
      test('$name escribe coma', () {
        useLocale(locale.$1, locale.$2);
        expect(
          CurrencyHelpers.castAmount(value: 1234.5),
          contains(','),
          reason: '$name debería usar coma decimal.',
        );
        expect(CurrencyHelpers.castAmount(value: 1234.5), isNot(contains('.')));
      });
    });

    test('inglés escribe punto', () {
      useLocale('en', 'US');
      expect(CurrencyHelpers.castAmount(value: 1234.5), '1234.50');
    });

    test('japonés y coreano también son punto, y se comprueban', () {
      // El issue pide probarlos explícitamente: sus códigos eran inválidos
      // (`ja_JA`) hasta #98, y `NumberFormat` con un locale que no conoce cae
      // al de por defecto **en silencio**.
      useLocale('ja', 'JP');
      expect(CurrencyHelpers.castAmount(value: 1234.5), '1234.50');
      useLocale('ko', 'KR');
      expect(CurrencyHelpers.castAmount(value: 1234.5), '1234.50');
    });
  });

  group('el separador de miles', () {
    test('agrupa donde la cifra solo se lee', () {
      useLocale('de', 'DE');
      // Alemán: punto para los miles y coma para los decimales — el caso que
      // más se parece a un error si se escribe con las reglas del inglés.
      expect(CurrencyHelpers.castCurrency(value: 1234.5), 'Bs.S 1.234,50');

      useLocale('en', 'US');
      expect(CurrencyHelpers.castCurrency(value: 1234.5), 'Bs.S 1,234.50');
    });

    test('NO agrupa la cifra que vuelve al campo de texto', () {
      useLocale('de', 'DE');
      // `castAmount` alimenta el conversor, y su resultado se rescribe en el
      // campo al invertir el sentido. Con separador de miles, `1.234,50`
      // llegaría a `parseAmount` como `1.234.50` y se convertiría en 0,0.
      expect(CurrencyHelpers.castAmount(value: 1234.5), '1234,50');
    });
  });

  group('el ciclo escribir → convertir → mostrar → reparsear', () {
    test('cierra en un locale con coma decimal', () {
      useLocale('es', 'ES');

      // 1. El usuario escribe con coma, que es lo que su teclado ofrece.
      const String typed = '1234,5';
      final double parsed = CurrencyConversion.parseAmount(typed);
      expect(parsed, 1234.5);

      // 2. Se convierte con la tasa y se muestra.
      final double converted = CurrencyConversion.convert(
        amount: parsed,
        fromRate: 1,
        toRate: 2,
      );
      final String shown = CurrencyHelpers.castAmount(value: converted);
      expect(shown, '617,25');

      // 3. La hoja de detalle rescribe **lo mostrado** en el campo al invertir
      //    el sentido, así que tiene que volver a parsearse al mismo número.
      expect(CurrencyConversion.parseAmount(shown), converted);
    });

    test('y también con un techo de decimales alto', () {
      useLocale('es', 'ES');

      final String shown = CurrencyHelpers.castAmount(
        value: 1234.56789,
        maxDecimals: 6,
      );
      expect(shown, '1234,56789');
      expect(CurrencyConversion.parseAmount(shown), 1234.56789);
    });
  });

  test('cambiar de idioma cambia el formato de la siguiente lectura', () {
    // El criterio «cambiar el idioma en ajustes actualiza el formato de los
    // números ya visibles»: el formateador lee `Get.locale` en cada llamada, y
    // `Get.updateLocale` reconstruye la app, así que la siguiente pintada ya
    // sale con el separador nuevo.
    useLocale('en', 'US');
    expect(CurrencyHelpers.castAmount(value: 1.5), '1.50');

    useLocale('es', 'ES');
    expect(CurrencyHelpers.castAmount(value: 1.5), '1,50');
  });

  test('sin locale asignado no revienta', () {
    // Antes de que `GetMaterialApp` asigne uno — en la práctica, tests.
    Get.locale = null;
    expect(CurrencyHelpers.castAmount(value: 1.5), isNotEmpty);
    expect(CurrencyHelpers.displayLocale, isNotEmpty);
  });
}
