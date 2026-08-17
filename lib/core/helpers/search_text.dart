/// Text folding for in-app search.
///
/// Introduced for the currency selector's search box (#41), which has to find
/// "Dólar" when the user types "dolar" — on a phone keyboard the accent is
/// extra work, and nobody types it to search.
///
/// **Why a table and not Unicode normalisation.** Dart's core libraries do not
/// expose NFD decomposition, so stripping diacritics properly means a package.
/// The strings actually searched here are currency names from `AppMessages` and
/// market names from the backend, and between the ten languages the app ships
/// they use a closed set of Latin marks — the table below covers it. Adding a
/// dependency for that is a worse trade than twenty lines that can be read and
/// tested.
///
/// Languages written outside the Latin alphabet — Russian, Japanese, Korean,
/// Chinese — are unaffected by folding and rely on the lower-casing, which
/// `String.toLowerCase` already does for Cyrillic and is a no-op for the CJK
/// scripts. That is correct, not a gap: those scripts have no diacritics to
/// strip here.
class SearchText {
  const SearchText._();

  /// Latin letters with a diacritic, mapped to the bare letter.
  ///
  /// Covers Spanish, Portuguese, French, German and Italian — the accented
  /// languages among the ten. `ß` maps to `ss`, which is how German itself
  /// expands it, so "Strasse" finds "Straße".
  static const Map<String, String> _folded = <String, String>{
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
    'ý': 'y',
    'ÿ': 'y',
    'ß': 'ss',
  };

  /// Lower-cased and stripped of diacritics, ready to compare.
  ///
  /// Both sides of a search go through this, so the comparison is symmetric:
  /// typing an accent finds the unaccented text just as the other way round.
  static String fold(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final String char in value.toLowerCase().split('')) {
      buffer.write(_folded[char] ?? char);
    }
    return buffer.toString();
  }

  /// Whether [query] appears in any of [fields], ignoring case and accents.
  ///
  /// An empty or blank query matches everything — the caller does not have to
  /// special-case "nothing typed yet", which is the state the field spends most
  /// of its life in.
  static bool matches(String query, Iterable<String> fields) {
    final String needle = fold(query.trim());
    if (needle.isEmpty) {
      return true;
    }
    return fields.any((String field) => fold(field).contains(needle));
  }
}
