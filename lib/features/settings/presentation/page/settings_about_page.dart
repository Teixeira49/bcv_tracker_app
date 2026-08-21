import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/constants/app_links.dart';
import '../../../../core/constants/market_constants.dart';
import '../../../../core/helpers/external_link.dart';
import '../../../../core/i18n/app_messages.dart';
import '../../../../shared/presentation/controller/app_info_service.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../widgets/about_widgets.dart';
import '../widgets/settings_section.dart';

/// Who made this app, where its numbers come from, and under what licence.
///
/// [#42](https://github.com/Teixeira49/bcv_tracker_app/issues/42), and the
/// block that justifies the screen is the middle one. The Home lists nine
/// market names as bare labels; a user deciding what to charge is reading a
/// number without being told whether an institution *set* it, whether it
/// emerged from people trading, or whether somebody else averaged it first.
/// **Attribution is not decoration in an app whose product is a rate.**
///
/// **Tres bloques, no los cuatro del issue.** El de «Proyecto» —licencia, ambos
/// repositorios y la documentación de la API— se retiró tras la prueba en
/// dispositivo: el propietario no quiere exponer el estado del proyecto en una
/// versión pública, y la de la API además revelaba la URL del backend
/// configurado. Vuelve detrás de un interruptor por dispositivo, que es un
/// feature aparte; la copy y las constantes se conservan intactas para
/// entonces.
///
/// Lo que queda es lo que el usuario final necesita: qué es la app y **de dónde
/// sale cada tasa**, el bloque que justifica la pantalla. La versión llega en
/// [#43](https://github.com/Teixeira49/bcv_tracker_app/issues/43).
///
/// Everything that leaves the app goes through [ExternalLink], which only opens
/// `https` and reports a refusal. A tap that does nothing is indistinguishable
/// from a broken screen, so the failure has a message.
class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorValues.bgPrimary(context),
    body: BaseLayout(
      title: AppMessages.aboutView,
      showBackButton: true,
      showSettingsAction: false,
      margins: EdgeInsets.fromLTRB(
        WidthValues.spacingMd,
        WidthValues.spacingLg,
        WidthValues.spacingMd,
        WidthValues.spacingNone,
      ),
      child: ListView(
        padding: EdgeInsets.only(bottom: WidthValues.spacing4xl),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: WidthValues.spacingXs,
              right: WidthValues.spacingXs,
              bottom: WidthValues.spacingMd,
            ),
            child: Text(
              AppMessages.aboutIntro,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: ColorValues.textTertiary(context),
              ),
            ),
          ),
          const AboutHeader(),
          _DataSourcesSection(),
          _CreditsSection(),
        ],
      ),
    ),
  );
}

/// Opens [url], and says so when it cannot.
///
/// Shared by every row of the screen so the failure message is written once.
/// A message is the only feedback available: the platform gives no callback for
/// "the browser opened", so success is simply the app going to the background.
///
/// **`ScaffoldMessenger`, not `Get.snackbar`**, though the rest of the app
/// reaches for GetX first. `Get.snackbar` resolves its own overlay, and from
/// this screen it throws `No Overlay widget found` — reproduced in
/// `settings_about_page_test.dart` before this was changed. Flutter's own
/// messenger needs nothing but the `Scaffold` this page already has, so the
/// error path cannot fail more loudly than the error it is reporting.
Future<void> _open(BuildContext context, String url) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final bool opened = await ExternalLink.open(url);
  if (opened) return;

  // The await crossed a frame boundary, so the element may be gone — the user
  // can tap a link and leave before the platform answers.
  if (!context.mounted) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(AppMessages.openLinkError),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// The nine markets, each with what kind of reference it is and a way to check
/// it.
///
/// Reads `Markets.sources`, the catalogue in `core/constants/`, rather than a
/// list written here. That is what makes this screen and
/// [#12](https://github.com/Teixeira49/bcv_tracker_app/issues/12) — which wants
/// the same classification on the rate cards — one decision instead of two.
class _DataSourcesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SettingsSection(
    title: AppMessages.dataSourcesSection,
    note: AppMessages.dataSourcesNote,
    children: <Widget>[
      for (final MarketSource source in Markets.sources)
        AboutLinkTile(
          // The market's own name, untranslated: these are institutions and
          // brands (`i18n-convention.md`, rule 9).
          title: source.name,
          isBrandName: true,
          trailing: marketKindLabel(source.kind),
          onTap: () => _open(context, source.url),
        ),
    ],
  );
}

/// Who maintains it, and which build the user is looking at.
///
/// **Sin enlaces.** El autor era un enlace a su perfil y había una fila de
/// «reportar un problema»; las dos salieron a petición del propietario tras
/// probarlo en dispositivo. La segunda vuelve como sección propia en un feature
/// futuro; la primera apuntaba al repositorio, que es justo lo que el bloque
/// «Proyecto» dejó de revelar.
class _CreditsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SettingsSection(
    title: AppMessages.creditsSection,
    children: <Widget>[
      AboutFactRow(
        label: AppMessages.developedByLabel,
        value: AppLinks.authorName,
      ),
      // El mismo `AppInfoService` que lee el menú (#43): un solo servicio, así
      // que las dos pantallas no pueden citar builds distintas.
      //
      // `Obx`, a diferencia de la fila de arriba: la versión llega después del
      // primer build ahora que nada la espera antes de `runApp`.
      Obx(
        () => AboutFactRow(
          label: AppMessages.appVersion,
          value: Get.find<AppInfoService>().versionLabel,
        ),
      ),
    ],
  );
}
