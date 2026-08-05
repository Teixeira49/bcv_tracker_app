import 'dart:io';

import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ten language maps, keyed by locale, exactly as `AppTranslations`
/// registers them for GetX. Using the registration itself means this test also
/// fails if a language map stops being wired in.
final Map<String, Map<String, String>> _languages = AppTranslations().keys;

/// The keys `AppMessages` actually asks GetX to translate.
///
/// Dart has no runtime reflection here, so the keys are read from the source:
/// every `'<key>'.tr` in `app_messages.dart`. `flutter test` runs with the
/// package root as the working directory, so the relative path resolves.
Set<String> _appMessagesKeys() {
  final content = File('lib/core/i18n/app_messages.dart').readAsStringSync();
  return RegExp(
    r"'([A-Za-z0-9_]+)'\.tr",
  ).allMatches(content).map((m) => m.group(1)!).toSet();
}

void main() {
  group('i18n key parity', () {
    test('the ten expected languages are registered', () {
      expect(
        _languages.keys.toSet(),
        {
          'en_US',
          'es_ES',
          'pt_PT',
          'zh_CN',
          'fr_FR',
          'de_DE',
          'it_IT',
          'ja_JP',
          'ko_KR',
          'ru_RU',
        },
        reason: 'AppTranslations must register exactly these ten locales.',
      );
    });

    test('every language has the same set of keys', () {
      // The union is the reference: a key present in one language but absent in
      // another shows up as the others "missing" it. That catches divergence in
      // either direction and names the language and the exact keys — not a bare
      // `expected true`, which is the whole point of #36.
      final Set<String> union = {
        for (final map in _languages.values) ...map.keys,
      };

      final problems = <String>[];
      _languages.forEach((locale, map) {
        final missing = union.difference(map.keys.toSet());
        if (missing.isNotEmpty) {
          final sorted = missing.toList()..sort();
          problems.add('$locale is missing ${sorted.length} key(s): $sorted');
        }
      });

      expect(
        problems,
        isEmpty,
        reason:
            'The ten languages must share one key set. A key added to only some '
            'renders as the raw key on screen for the rest:\n${problems.join('\n')}',
      );
    });

    test('every key AppMessages exposes exists in all ten languages', () {
      final keys = _appMessagesKeys();
      expect(
        keys,
        isNotEmpty,
        reason: 'No `.tr` keys found in app_messages.dart — regex or path off?',
      );

      final problems = <String>[];
      for (final key in keys) {
        final absentIn = _languages.entries
            .where((e) => !e.value.containsKey(key))
            .map((e) => e.key)
            .toList();
        if (absentIn.isNotEmpty) {
          problems.add(
            '"$key" is used by AppMessages but missing in: $absentIn',
          );
        }
      }

      expect(
        problems,
        isEmpty,
        reason:
            'Every AppMessages getter must resolve in all ten languages:\n'
            '${problems.join('\n')}',
      );
    });

    test('no translation value is empty or equal to its key', () {
      final problems = <String>[];
      _languages.forEach((locale, map) {
        map.forEach((key, value) {
          if (value.trim().isEmpty) {
            problems.add('$locale["$key"] is empty');
          } else if (value == key) {
            problems.add('$locale["$key"] equals its key (left untranslated)');
          }
        });
      });

      expect(
        problems,
        isEmpty,
        reason:
            'A value equal to its key or empty renders as the raw key or blank:\n'
            '${problems.join('\n')}',
      );
    });
  });
}
