import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the installed package. Injectable so a test can supply one — or fail.
typedef PackageReader = Future<PackageInfo> Function();

/// What version of the app is actually installed.
///
/// **Read from the package at runtime, never from a constant.** `pubspec.yaml`
/// is not readable at runtime, and a constant written by hand desynchronises on
/// the first release someone forgets to bump — which is precisely the failure
/// [#43](https://github.com/Teixeira49/bcv_tracker_app/issues/43) exists to
/// prevent. A version label that lies is worse than none: a tester reports a
/// bug against a build that never shipped.
///
/// **One service, so the menu and «Acerca de» cannot disagree.** #43 asks for
/// the figure in two places and requires them to be the same figure. Two
/// independent `PackageInfo.fromPlatform()` calls would satisfy that today and
/// stop satisfying it the day one of them gains a format.
///
/// ### Why it is registered in `dependencies()` and not `initServices()`
///
/// The first draft awaited it before `runApp`, with a two-second timeout, and
/// the review of #121 was right to push back: `dependency-injection.md` states
/// one criterion — *if the first frame reads it, `initServices()`; if not,
/// `dependencies()`* — and the first frame does not read this. The rule was
/// being cited to justify the opposite of what it says.
///
/// The reason the first draft reached for `initServices()` was real: a
/// `putAsync` in `dependencies()` is **not awaited**, so a `Get.find` arriving
/// first throws. What that argument missed is a third option — register a
/// **synchronous instance** and let it fill itself in:
///
/// ```dart
/// Get.put<AppInfoService>(AppInfoService()..load(), permanent: true);
/// ```
///
/// The instance exists from the moment it is registered, so `Get.find` cannot
/// throw; startup pays nothing; the timeout stops being necessary because
/// nothing is waiting; and the observables mean a late answer still reaches the
/// screen. The price is a theoretical frame showing `--` on a screen the user
/// takes seconds to reach.
///
/// The bill for the first draft was visible in its own diff: six test files had
/// to learn about `package_info_plus`, two of which have nothing to do with the
/// version and only suffered it because it hung off `initServices()`.
class AppInfoService extends GetxService {
  /// What is shown while the package has not answered, or when it will not.
  ///
  /// The same placeholder `CurrencyHelpers` uses for a missing figure, so an
  /// unknown version reads like every other absent value in the app.
  static const String unknown = '--';

  /// Semantic version of the installed package — `1.1.0`.
  ///
  /// Matches the part of `pubspec.yaml`'s `version:` before the `+`, which is
  /// what Codemagic passes as `--build-name`. Observable because [load] fills
  /// it in after the first frame; a plain field would freeze at `--`.
  final RxString version = unknown.obs;

  /// Build number of the installed package — `3`.
  ///
  /// **Leído pero no mostrado**, por decisión del propietario: la etiqueta de
  /// la pantalla es `MAJOR.MINOR.PATCH` a secas. Se sigue leyendo porque #43 lo
  /// pide en tiempo de ejecución y porque es el dato que distingue dos
  /// artefactos de la misma versión — el día que un flujo de reporte lo
  /// necesite, está aquí y no hay que volver a montar nada.
  ///
  /// **No coincidirá con el `+N` del `pubspec.yaml` en una build de release**, y
  /// eso es correcto, no un defecto: `codemagic.yaml` pasa
  /// `--build-number ${CM_BUILD_NUMBER}`, así que el número del repositorio es
  /// solo lo que estamparía un `flutter build` local.
  final RxString buildNumber = unknown.obs;

  /// La versión como se muestra: `1.1.0`, sin el número de build.
  ///
  /// Fue `1.1.0 (3)` hasta que el propietario lo probó en dispositivo. El
  /// paréntesis dice algo verdadero —qué artefacto de esa versión— pero se lo
  /// dice a alguien que no lo va a usar: quien lee esta fila quiere saber qué
  /// versión tiene, no cuál de sus compilaciones. [buildNumber] sigue leído y
  /// disponible para cuando haga falta.
  ///
  /// Compuesto aquí y no en cada pantalla, que es lo que hace imposible que el
  /// menú, «Acerca de» y el portapapeles digan cosas distintas.
  String get versionLabel => version.value;

  /// Whether the package answered. `false` means [versionLabel] is placeholders.
  bool get isKnown => version.value != unknown;

  /// Fills the observables in, in the background.
  ///
  /// Returns a `Future` so a test can await it, but **nothing in the app does**:
  /// it is started with `..load()` at registration and the screens read the
  /// observables. That is what removes the timeout the first draft needed —
  /// a call nobody waits for cannot hold up a launch.
  ///
  /// Never throws. A version label is the least important thing on any screen
  /// it appears on; failing to read it leaves `--`, which is information, and
  /// **retryable** — unlike the `late final` of the first draft, which froze
  /// the placeholder in for the life of the process.
  ///
  /// [read] is the seam the review of #121 asked for. Injecting the *result*
  /// (a `PackageInfo`) made the failure paths untestable: the only test of them
  /// was `expect(unknown, '--')`, which is `'--' == '--'`. Injecting the
  /// *reader* lets a test fail, hang or answer.
  Future<void> load({PackageReader? read}) async {
    try {
      final PackageInfo info = await (read ?? PackageInfo.fromPlatform)();
      version.value = info.version;
      buildNumber.value = info.buildNumber;
    } on Object {
      // Left at `unknown`. Deliberately swallowed: there is no caller to
      // report to — nothing awaits this — and a plugin that cannot answer is
      // not a reason to take a screen down.
    }
  }
}
