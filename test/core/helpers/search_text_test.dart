import 'package:bcv_tracker_app/core/helpers/search_text.dart';
import 'package:flutter_test/flutter_test.dart';

/// The folding behind the currency selector's search (#41). A pure function, so
/// the cases that matter are the scripts the app's ten languages actually use.
void main() {
  group('fold', () {
    test('lower-cases', () {
      expect(SearchText.fold('BINANCE'), 'binance');
    });

    test('strips the Latin diacritics of the languages the app ships', () {
      expect(SearchText.fold('Dólar'), 'dolar');
      expect(SearchText.fold('Français'), 'francais');
      expect(SearchText.fold('Türkische'), 'turkische');
      expect(
        SearchText.fold('Banco Central de Venezuela'),
        matches('^[a-z ]+\$'),
      );
    });

    test('expands the German sharp s the way German does', () {
      expect(SearchText.fold('Straße'), 'strasse');
    });

    test('leaves non-Latin scripts alone, which is correct', () {
      // Cyrillic lower-cases; the CJK scripts have no case and no diacritics to
      // strip. Folding must not mangle them.
      expect(SearchText.fold('Рубль'), 'рубль');
      expect(SearchText.fold('通貨'), '通貨');
      expect(SearchText.fold('통화'), '통화');
    });

    test('is idempotent, so folding a folded string is safe', () {
      const String name = 'Dólar Estadounidense';
      expect(SearchText.fold(SearchText.fold(name)), SearchText.fold(name));
    });
  });

  group('matches', () {
    const List<String> fields = <String>[
      'USD',
      'Dólar estadounidense',
      'Banco Central de Venezuela',
    ];

    test('an unaccented query finds the accented text', () {
      // The whole point: nobody types the accent to search.
      expect(SearchText.matches('dolar', fields), isTrue);
    });

    test('and an accented query finds it too — the fold is symmetric', () {
      expect(SearchText.matches('DÓLAR', fields), isTrue);
    });

    test('matches the market, not just the currency', () {
      expect(SearchText.matches('venezuela', fields), isTrue);
    });

    test('matches a fragment from the middle of a word', () {
      expect(SearchText.matches('estadou', fields), isTrue);
    });

    test('a query that is nowhere does not match', () {
      expect(SearchText.matches('zzzz', fields), isFalse);
    });

    test('nothing typed matches everything, so the caller need not branch', () {
      expect(SearchText.matches('', fields), isTrue);
      expect(SearchText.matches('   ', fields), isTrue);
    });

    test('surrounding spaces are ignored', () {
      expect(SearchText.matches('  dolar  ', fields), isTrue);
    });

    test('no field at all cannot match a real query', () {
      expect(SearchText.matches('usd', const <String>[]), isFalse);
    });
  });
}
