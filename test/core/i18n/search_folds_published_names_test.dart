import 'package:bcv_tracker_app/core/helpers/search_text.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The folding of #41 measured against the copy the app really publishes.
///
/// `search_text_test.dart` proves the function on strings written for the test.
/// That left a gap #104 made visible: until the Spanish map spelled «Dólar»
/// with its accent, **no name the app shipped carried a diacritic at all**, so
/// the folding path was correct, unit-tested and never exercised by real data
/// — and #41's "search ignores accents" could not be verified on screen.
///
/// These tests close that: they read the ten maps `AppTranslations` registers
/// and assert the accents are there, that they are findable without typing
/// them, and that [SearchText]'s table actually covers the copy that exists
/// rather than the copy the table was written for.
final Map<String, Map<String, String>> _languages = AppTranslations().keys;

/// The keys whose values reach a search box.
///
/// These are what `CurrencyHelpers.castCurrencyDisplayName` returns for the
/// rates the currency selector lists, plus the two market names the Home cards
/// title. Anything else in the maps is chrome the filter never reads.
const List<String> _searchableNameKeys = <String>[
  'officialDollar',
  'parallelDollar',
  'eeuuDollar',
  'europeanEuro',
  'turkishLira',
  'chineseYuan',
  'russianRuble',
  'marketAverage',
];

/// Latin letters carrying a diacritic, as a class.
///
/// Covers Latin-1 Supplement and Latin Extended-A, which is where every
/// accented letter of the five Latin-script languages the app ships lives. The
/// Cyrillic and CJK maps fall outside it, so they are not flagged — correctly,
/// since they have nothing to strip.
final RegExp _latinDiacritic = RegExp(r'[À-ɏ]');

void main() {
  group('the Spanish names carry their accent (#104)', () {
    late final Map<String, String> es = _languages['es_ES']!;

    test('the three dollar names are spelled «Dólar»', () {
      expect(es['officialDollar'], 'Dólar Oficial');
      expect(es['parallelDollar'], 'Dólar Paralelo');
      expect(es['eeuuDollar'], 'Dólar Estadounidense');
    });

    test('no Spanish value spells «dolar» without the accent', () {
      // A guard against the regression coming back through a new key rather
      // than through these three.
      final List<String> offenders = <String>[
        for (final MapEntry<String, String> entry in es.entries)
          if (RegExp(r'\bdolar', caseSensitive: false).hasMatch(entry.value))
            '${entry.key} = "${entry.value}"',
      ];

      expect(
        offenders,
        isEmpty,
        reason:
            'In Spanish «dólar» is a llana ending in -r, so it takes the '
            'accent:\n${offenders.join('\n')}',
      );
    });

    test('only Spanish changed — Portuguese still reads as it did', () {
      final Map<String, String> pt = _languages['pt_PT']!;
      expect(pt['officialDollar'], 'Dólar Oficial');
      expect(pt['parallelDollar'], 'Dólar Paralelo');
      expect(pt['eeuuDollar'], 'Dólar Americano');
    });
  });

  group('searching without the accent finds the published name', () {
    test('«dolar» finds the accented Spanish and Portuguese names', () {
      // The criterion #41 could not demonstrate before the accent existed.
      for (final String locale in const <String>['es_ES', 'pt_PT']) {
        final Map<String, String> map = _languages[locale]!;
        for (final String key in const <String>[
          'officialDollar',
          'parallelDollar',
          'eeuuDollar',
        ]) {
          final String name = map[key]!;
          expect(
            name,
            contains('ó'),
            reason:
                '$locale["$key"] should carry the accent to be worth folding',
          );
          expect(
            SearchText.matches('dolar', <String>[name]),
            isTrue,
            reason: 'typing "dolar" must find $locale["$key"] = "$name"',
          );
          expect(
            SearchText.matches('dólar', <String>[name]),
            isTrue,
            reason: 'and typing the accent must keep finding it',
          );
        }
      }
    });

    test('every searchable name is reachable by its accent-free form', () {
      final List<String> problems = <String>[];
      _languages.forEach((String locale, Map<String, String> map) {
        for (final String key in _searchableNameKeys) {
          final String? name = map[key];
          if (name == null) {
            continue; // Parity is another test's job.
          }
          if (!SearchText.matches(SearchText.fold(name), <String>[name])) {
            problems.add('$locale["$key"] = "$name"');
          }
        }
      });

      expect(
        problems,
        isEmpty,
        reason:
            'A published name that its own folded form cannot find is a name '
            'the selector can never surface:\n${problems.join('\n')}',
      );
    });
  });

  test('the fold table covers every diacritic the app actually ships', () {
    // The real risk with a hand-written table: a language gains a letter the
    // table never heard of, and that name silently stops being searchable
    // without the accent. Checked against the copy, not against the table.
    final List<String> uncovered = <String>[];
    _languages.forEach((String locale, Map<String, String> map) {
      for (final String key in _searchableNameKeys) {
        final String? name = map[key];
        if (name == null) {
          continue;
        }
        final String folded = SearchText.fold(name);
        if (_latinDiacritic.hasMatch(folded)) {
          uncovered.add('$locale["$key"] = "$name" folds to "$folded"');
        }
      }
    });

    expect(
      uncovered,
      isEmpty,
      reason:
          'These names keep a Latin diacritic after folding, so searching them '
          'without it fails. Add the letter to SearchText._folded:\n'
          '${uncovered.join('\n')}',
    );
  });
}
