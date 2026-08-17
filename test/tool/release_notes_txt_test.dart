import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/release_notes_txt.dart';

/// The derivation that turns `release_notes.json` into the plain text Firebase
/// App Distribution shows a tester (#93).
///
/// Worth testing even though it is a build script: it produces **the only text
/// the tester reads**, it runs on a machine nobody is watching, and its failure
/// mode is silent — notes that are empty, in the wrong language, or the wrong
/// version's. The real file at the repository root is exercised too, so the
/// suite fails if a release ever leaves it malformed.
void main() {
  String notes(List<Map<String, String>> entries) =>
      renderReleaseNotes(jsonEncode(entries));

  group('picking the language', () {
    test('Spanish wins, because that is who tests this app', () {
      expect(
        notes(<Map<String, String>>[
          <String, String>{'language': 'en-US', 'text': 'English notes'},
          <String, String>{'language': 'es-ES', 'text': 'Notas en español'},
        ]),
        'Notas en español\n',
      );
    });

    test('order in the file does not decide it — the preference does', () {
      expect(
        notes(<Map<String, String>>[
          <String, String>{'language': 'es-ES', 'text': 'Notas en español'},
          <String, String>{'language': 'en-US', 'text': 'English notes'},
        ]),
        'Notas en español\n',
      );
    });

    test('English serves when Spanish is not written', () {
      expect(
        notes(<Map<String, String>>[
          <String, String>{'language': 'en-US', 'text': 'English notes'},
        ]),
        'English notes\n',
      );
    });

    test('an explicit language overrides the preference', () {
      expect(
        renderReleaseNotes(
          jsonEncode(<Map<String, String>>[
            <String, String>{'language': 'en-US', 'text': 'English notes'},
            <String, String>{'language': 'es-ES', 'text': 'Notas en español'},
          ]),
          preferredLanguages: const <String>['en-US'],
        ),
        'English notes\n',
      );
    });

    test('an unknown preference falls back to the first entry in the file', () {
      // The same rule Codemagic applies, so a later migration to its own
      // publishing block cannot quietly change what gets published.
      expect(
        renderReleaseNotes(
          jsonEncode(<Map<String, String>>[
            <String, String>{'language': 'pt-PT', 'text': 'Notas em português'},
            <String, String>{'language': 'en-US', 'text': 'English notes'},
          ]),
          preferredLanguages: const <String>['ja-JP'],
        ),
        'Notas em português\n',
      );
    });
  });

  group('what the tester actually sees', () {
    test('bullets and blank lines survive verbatim', () {
      // Firebase renders the text as-is. Reflowing it would break the shape the
      // notes were written in.
      const String text = 'Line one.\n\n• First bullet\n• Second bullet';
      expect(
        notes(<Map<String, String>>[
          <String, String>{'language': 'en-US', 'text': text},
        ]),
        '$text\n',
      );
    });

    test(
      'surrounding blank space is trimmed and one newline is guaranteed',
      () {
        expect(
          notes(<Map<String, String>>[
            <String, String>{'language': 'en-US', 'text': '\n\n  Notes  \n\n'},
          ]),
          'Notes\n',
        );
      },
    );
  });

  group('it refuses to distribute empty notes', () {
    // Every one of these used to end as "Build #N – rama master" reaching the
    // tester. Failing loudly is the point: a silent fallback is how the notes
    // stopped arriving in the first place.
    test('invalid JSON', () {
      expect(
        () => renderReleaseNotes('{not json'),
        throwsA(isA<ReleaseNotesException>()),
      );
    });

    test('a JSON object instead of an array', () {
      expect(
        () => renderReleaseNotes('{"language": "en-US", "text": "x"}'),
        throwsA(isA<ReleaseNotesException>()),
      );
    });

    test('an empty array', () {
      expect(
        () => renderReleaseNotes('[]'),
        throwsA(isA<ReleaseNotesException>()),
      );
    });

    test('an entry whose text is blank', () {
      expect(
        () => notes(<Map<String, String>>[
          <String, String>{'language': 'en-US', 'text': '   '},
        ]),
        throwsA(isA<ReleaseNotesException>()),
      );
    });

    test('an entry with no language code', () {
      expect(
        () => renderReleaseNotes('[{"text": "orphan"}]'),
        throwsA(isA<ReleaseNotesException>()),
      );
    });

    test('no en-US entry, even when another language would have served', () {
      // en-US is what Codemagic publishes to email and Slack, so its absence is
      // worth stopping for even though this script would have used es-ES.
      expect(
        () => notes(<Map<String, String>>[
          <String, String>{'language': 'es-ES', 'text': 'Notas en español'},
        ]),
        throwsA(
          isA<ReleaseNotesException>().having(
            (ReleaseNotesException e) => e.message,
            'message',
            contains('en-US'),
          ),
        ),
      );
    });
  });

  group('the real release_notes.json at the repository root', () {
    // `flutter test` runs with the package root as the working directory, the
    // same assumption `translation_parity_test.dart` already makes.
    late final String source = File('release_notes.json').readAsStringSync();

    test('exists and derives without throwing', () {
      expect(File('release_notes.json').existsSync(), isTrue);
      expect(renderReleaseNotes(source).trim(), isNotEmpty);
    });

    test('the tester gets Spanish', () {
      expect(renderReleaseNotes(source), contains('tasas'));
    });

    test('every language fits the 500 characters Google Play allows', () {
      // The tightest limit of the four channels the same file feeds, and the
      // one the rule says to write for first.
      final List<dynamic> entries = jsonDecode(source) as List<dynamic>;
      for (final dynamic entry in entries) {
        final Map<String, dynamic> map = entry as Map<String, dynamic>;
        expect(
          (map['text'] as String).length,
          lessThanOrEqualTo(500),
          reason: '${map['language']} exceeds the Google Play limit',
        );
      }
    });

    test('no angle bracket, which App Store review rejects', () {
      expect(source, isNot(contains('<')));
      expect(renderReleaseNotes(source), isNot(contains('>')));
    });
  });
}
