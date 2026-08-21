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

/// La versión de la app en los ajustes (#43).
///
/// Lo que hay que proteger no es que se pinte un texto: es que **sea la del
/// paquete instalado** y que **el menú y «Acerca de» digan lo mismo**. Una
/// versión inventada por la pantalla es peor que ninguna — un tester reporta un
/// fallo contra una build que nunca existió.
const String _version = '9.9.9';
const String _build = '42';
const String _label = '$_version ($_build)';

Future<void> _pump(WidgetTester tester, String route) async {
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  Get.put(SettingsController(), permanent: true);
  await Get.putAsync<AppInfoService>(
    () => AppInfoService().init(
      info: PackageInfo(
        appName: 'BCV Tracker',
        packageName: 'com.example.bcv_tracker_app',
        version: _version,
        buildNumber: _build,
      ),
    ),
    permanent: true,
  );

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

void main() {
  tearDown(Get.reset);

  test(
    'la etiqueta compone versión y build, que es lo que pide un reporte',
    () async {
      final AppInfoService info = await AppInfoService().init(
        info: PackageInfo(
          appName: 'x',
          packageName: 'y',
          version: '1.2.3',
          buildNumber: '77',
        ),
      );

      // La versión semántica dice qué código es; el build, cuál de sus
      // artefactos. Un reporte necesita ambos.
      expect(info.version, '1.2.3');
      expect(info.buildNumber, '77');
      expect(info.versionLabel, '1.2.3 (77)');
    },
  );

  test('una plataforma que no contesta degrada, no cuelga el arranque', () async {
    // Este caso lo encontró la suite antes de que existiera el test: sin doble
    // del canal, `initServices()` —que `main` espera **antes** de `runApp`— se
    // quedaba esperando y arrastraba todo. Una etiqueta de versión es lo menos
    // importante de la pantalla y estaba delante del primer fotograma.
    PackageInfo.setMockInitialValues(
      appName: 'x',
      packageName: 'y',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final AppInfoService ok = await AppInfoService().init();
    expect(ok.version, '1.0.0');

    // Y si no hay nada que leer, se degrada al mismo marcador que el resto de
    // los valores ausentes de la app en vez de reventar.
    expect(AppInfoService.unknown, '--');
  });

  testWidgets('el menú muestra la versión del paquete instalado', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AppRoutes.settings);

    expect(find.text(AppMessages.appVersion), findsOneWidget);
    // Del paquete, no de una constante: el fake dice 9.9.9 y el `pubspec` del
    // repo dice otra cosa, así que si la pantalla leyera el `pubspec` este
    // test fallaría — que es justo lo que debe hacer.
    expect(find.text(_label), findsOneWidget);
  });

  testWidgets('la fila copia y no navega, y su icono lo dice', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AppRoutes.settings);

    // Un chevron prometería una pantalla que no existe.
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
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
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

    await _pump(tester, AppRoutes.settings);
    await tester.tap(find.text(AppMessages.appVersion));
    await tester.pump();
    await tester.pump();

    // El detalle que la vuelve útil: leer la versión de la pantalla para
    // reescribirla es donde se pierde el dígito.
    expect(copied, _label);
    // Y la confirmación, porque un toque silencioso se repite.
    expect(find.textContaining(AppMessages.versionCopied), findsOneWidget);
  });

  testWidgets('«Acerca de» muestra exactamente el mismo dato', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AppRoutes.settingsAbout);

    // El criterio duro de #43. Ambas pantallas leen `AppInfoService`, así que
    // no pueden citar builds distintas; este test falla el día que alguien
    // formatee la versión por su cuenta en una de las dos.
    expect(find.text(AppMessages.appVersion), findsOneWidget);
    expect(find.text(_label), findsOneWidget);
  });
}
