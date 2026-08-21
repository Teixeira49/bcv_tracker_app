/// Where the project lives on the web, for the About screen to point at.
///
/// Apart from [Constants] because these are **outward** addresses — things the
/// user can open in a browser and check — rather than values the app computes
/// with. Centralised for the usual reason: a repository that moves breaks in one
/// file instead of in six rows of a screen.
///
/// The API documentation is **not** here, and cannot be: it hangs off the
/// backend base URL, which is a per-environment value read from `.env` (see
/// `.agents/rules/environment-variables.md`). `SettingsAboutPage` composes it
/// from `Environment.currency` at build time.
class AppLinks {
  const AppLinks._();

  /// Source of the app itself.
  static const String repository =
      'https://github.com/Teixeira49/bcv_tracker_app';

  /// Source of the backend it consumes. Named in the About screen because the
  /// rates the user is reading are assembled there, not here.
  static const String backendRepository =
      'https://github.com/Teixeira49/bcv_tracker_backend';

  /// Straight to the issue form, not to the issue list: someone tapping
  /// "report a problem" wants to write one, not to read forty.
  static const String reportIssue = '$repository/issues/new';

  /// Who maintains it.
  static const String author = 'https://github.com/Teixeira49';

  /// Shown verbatim next to the licence row. Matches the `LICENSE` at the root
  /// of the repository — if one changes, both change.
  static const String licenseName = 'Apache 2.0';

  static const String licenseUrl =
      'https://www.apache.org/licenses/LICENSE-2.0';

  /// Path appended to the backend base URL for its interactive documentation.
  ///
  /// The backend also serves `/redoc` — the same OpenAPI schema in a different
  /// renderer. Only this one is offered: two rows pointing at the same content
  /// is a choice the user has no basis to make.
  static const String apiDocsPath = '/docs';
}
