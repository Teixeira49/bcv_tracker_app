import 'dart:async';

import 'package:bcv_tracker_app/config/routes/pages.dart';
import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/app_info_service.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/app_info_fake.dart';

/// La versión de la app en los ajustes (#43).
///
/// Lo que hay que proteger no es que se pinte un texto: es que **sea la del
/// paquete instalado**, que **el menú y «Acerca de» digan lo mismo**, y que un
/// paquete que no contesta **no se lleve nada por delante**. Una versión
/// inventada por la pantalla es peor que ninguna — un tester reporta un fallo
/// contra una build que nunca existió.
PackageInfo _info(String version, String build) => PackageInfo(
  appName: 'BCV Tracker',
  packageName: 'com.example.bcv_tracker_app',
  version: version,
  buildNumber: build,
);

Future<void> _pumpDegraded(WidgetTester tester) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);
  // Registrado sin llamar a `load`: el estado degradado.
  Get.put<AppInfoService>(AppInfoService(), permanent: true);

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(500, 2400);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      initialRoute: AppRoutes.settings,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, String route) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);
  await putFakeAppInfo();

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(500, 2400);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      initialRoute: route,
    ),
  );
  await tester.pumpAndSettle();
}

/// Intercepta el portapapeles y devuelve lo que se copió.
List<String> _captureClipboard(WidgetTester tester) {
  final List<String> copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map<Object?, Object?>)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

void main() {
  tearDown(Get.reset);

  group('el servicio', () {
    test('compone versión y build, que es lo que pide un reporte', () async {
      final AppInfoService info = AppInfoService();
      await info.load(read: () async => _info('1.2.3', '77'));

      expect(info.version.value, '1.2.3');
      expect(info.buildNumber.value, '77');
      expect(info.versionLabel, '1.2.3 (77)');
      expect(info.isKnown, isTrue);
    });

    test('arranca en el marcador, antes de que el paquete conteste', () {
      // Lo que ve la pantalla entre el registro y la respuesta del canal. Es la
      // razón por la que los valores son observables y no `late final`.
      final AppInfoService info = AppInfoService();
      expect(info.versionLabel, '-- (--)');
      expect(info.isKnown, isFalse);
    });

    test('un lector que falla deja el marcador, sin lanzar', () async {
      // La rama que la primera versión de este archivo decía cubrir con
      // `expect(AppInfoService.unknown, '--')` — es decir, con nada: `'--'`
      // comparado consigo mismo. Se prueba inyectando el **lector**, no el
      // resultado, que es el cambio que la revisión de #121 pidió.
      final AppInfoService info = AppInfoService();
      await info.load(
        read: () => Future<PackageInfo>.error(
          MissingPluginException('sin implementación'),
        ),
      );

      expect(info.isKnown, isFalse);
      expect(info.versionLabel, '-- (--)');
    });

    test('un lector que nunca contesta no bloquea a nadie', () async {
      // Ya no hace falta `timeout`: nada espera a `load`, así que un canal
      // colgado deja el marcador y la app sigue. Es lo que en la primera
      // versión —registrada con `await` en `initServices()`— colgó la suite
      // entera durante minutos.
      final AppInfoService info = AppInfoService();
      final Completer<PackageInfo> never = Completer<PackageInfo>();
      unawaited(info.load(read: () => never.future));

      await Future<void>.delayed(Duration.zero);
      expect(info.isKnown, isFalse);
      expect(info.versionLabel, '-- (--)');
    });

    test('una respuesta tardía todavía llega', () async {
      // El otro lado de lo mismo: al ser observables, contestar tarde no se
      // pierde. Con el `late final` de la primera versión el marcador se
      // congelaba para todo el proceso, aunque el dato llegara un instante
      // después.
      final AppInfoService info = AppInfoService();
      final Completer<PackageInfo> pending = Completer<PackageInfo>();
      unawaited(info.load(read: () => pending.future));

      expect(info.isKnown, isFalse);
      pending.complete(_info('2.0.0', '9'));
      await Future<void>.delayed(Duration.zero);

      expect(info.versionLabel, '2.0.0 (9)');
    });
  });

  group('en pantalla', () {
    testWidgets('el menú muestra la versión del paquete instalado', (
      WidgetTester tester,
    ) async {
      await _pump(tester, AppRoutes.settings);

      expect(find.text(AppMessages.appVersion), findsOneWidget);
      // Del paquete, no de una constante: el doble dice 9.9.9 y el `pubspec`
      // del repo dice otra cosa, así que una pantalla que leyera el `pubspec`
      // haría fallar esto — que es justo lo que debe hacer.
      expect(find.text(kFakeVersionLabel), findsOneWidget);
    });

    testWidgets('la fila copia y no navega, y su icono lo dice', (
      WidgetTester tester,
    ) async {
      await _pump(tester, AppRoutes.settings);

      final SettingsMenuTile tile = tester.widget<SettingsMenuTile>(
        find.ancestor(
          of: find.text(AppMessages.appVersion),
          matching: find.byType(SettingsMenuTile),
        ),
      );
      expect(tile.trailingIcon, Icons.copy_rounded);
    });

    testWidgets('tocarla copia al portapapeles y lo confirma', (
      WidgetTester tester,
    ) async {
      final List<String> copied = _captureClipboard(tester);

      await _pump(tester, AppRoutes.settings);
      await tester.tap(find.text(AppMessages.appVersion));
      await tester.pump();
      await tester.pump();

      // Leer la versión de la pantalla para reescribirla es donde se pierde el
      // dígito, así que lo copiado tiene que ser exactamente lo mostrado.
      expect(copied, <String>[kFakeVersionLabel]);
      expect(find.textContaining(AppMessages.versionCopied), findsOneWidget);
    });

    testWidgets('sin versión no copia nada ni finge que copió', (
      WidgetTester tester,
    ) async {
      final List<String> copied = _captureClipboard(tester);
      await _pumpDegraded(tester);

      // La fila se ve, con el marcador: que no se sepa la versión es
      // información. Lo que no se hace es copiar `-- (--)` y anunciar éxito.
      expect(find.text('-- (--)'), findsOneWidget);

      await tester.tap(find.text(AppMessages.appVersion));
      await tester.pump();
      await tester.pump();

      expect(copied, isEmpty);
      expect(find.textContaining(AppMessages.versionCopied), findsNothing);
    });

    testWidgets('«Acerca de» muestra exactamente el mismo dato', (
      WidgetTester tester,
    ) async {
      await _pump(tester, AppRoutes.settingsAbout);

      // El criterio duro de #43. Ambas pantallas leen el mismo `AppInfoService`,
      // así que no pueden citar builds distintas; esto falla el día que alguien
      // formatee la versión por su cuenta en una de las dos.
      expect(find.text(AppMessages.appVersion), findsOneWidget);
      expect(find.text(kFakeVersionLabel), findsOneWidget);
    });
  });
}
