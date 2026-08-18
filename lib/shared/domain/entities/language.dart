/// One entry of the language selector in Settings.
///
/// A presentation-shaped entity: the app ships ten translations and this is how
/// each is offered. Deliberately **not** derived from `AppTranslations.keys` —
/// [name] and [flag] are copy for the user, and a locale code cannot produce
/// either. `SettingsController.languageOptions` holds the list.
class LanguageOption {
  /// Store-shaped locale code, `xx_YY`, matching a key `AppTranslations`
  /// registers **exactly**.
  ///
  /// Exactness matters: it is what lets
  /// `SettingsController.resolveDeviceLanguage` answer "does the device's locale
  /// match a language we publish?" by comparison. Two of these used to be
  /// invalid (`en_EN`, `ja_JA`) and only worked because GetX falls back on the
  /// language code alone — corrected in
  /// [#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98), which also
  /// added the migration for installs that had stored the old ones.
  final String code;

  /// The language's name **in that language** ("Español", "日本語").
  ///
  /// Never translated: someone looking for their own language scans for the word
  /// they know, not for its name in a language they cannot read.
  final String name;

  /// Flag emoji shown beside [name].
  ///
  /// An emoji rather than an asset, so it needs no file per language and picks up
  /// the platform's own rendering. Typed as `String` for that reason.
  final String flag;

  /// Creates an option. `const` so `SettingsController.defaultLanguage` can be a
  /// compile-time constant and therefore identical by reference — which
  /// `DropdownButtonFormField` relies on, since this class does not override
  /// `==`.
  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}
