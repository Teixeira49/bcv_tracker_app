/// Derives the plain-text release notes Firebase App Distribution shows to a
/// tester, from the multi-language `release_notes.json` at the repository root.
///
/// **Why this script exists.** Codemagic reads `release_notes.json` on its own
/// only when distribution goes through its `publishing:` block. The three
/// workflows call the Firebase CLI by hand, and the CLI's `--release-notes-file`
/// takes **plain text**, not the multi-language JSON — so without a step in the
/// middle the file is simply ignored, which is what #93 is about. The notes used
/// to be `Build #12 – rama master`, a line that repeats what the Firebase
/// console already shows above it and tells the tester nothing about what to
/// try.
///
/// **Why derive instead of committing a `.txt`.** Two files with the same prose
/// drift, and the one nobody reads drifts first. `release_notes.json` stays the
/// single source `.agents/rules/release-notes.md` describes; the `.txt` is a
/// build artifact and is gitignored.
///
/// **Why it runs early in the workflow.** A malformed or missing notes file
/// fails the build in seconds instead of after a fifteen-minute compile, and
/// there is no silent fallback to a generic string on purpose: falling back is
/// how the notes would quietly stop arriving again with nobody noticing.
///
/// ```bash
/// dart run tool/release_notes_txt.dart              # → release_notes.txt
/// dart run tool/release_notes_txt.dart --language en-US
/// dart run tool/release_notes_txt.dart --output /tmp/notes.txt
/// ```
library;

import 'dart:convert';
import 'dart:io';

/// Where the notes are read from, relative to the working directory.
const String kDefaultInput = 'release_notes.json';

/// Where the derived plain text is written. The name is the one Codemagic
/// itself looks for, so the build email picks the notes up too.
const String kDefaultOutput = 'release_notes.txt';

/// Store locale codes tried in order, first match wins.
///
/// **Spanish before English, deliberately.** `.agents/rules/release-notes.md`
/// makes `en-US` mandatory because that is the entry Codemagic's own
/// integration publishes, and that constraint still holds — the entry has to
/// exist. But this script picks the language, and the tester group for this app
/// reads Spanish. English stays as the fallback the rule guarantees is there.
const List<String> kPreferredLanguages = <String>['es-ES', 'en-US'];

/// Raised when the notes cannot be derived. The message is what the build log
/// shows, so it says what to fix rather than what went wrong internally.
class ReleaseNotesException implements Exception {
  ReleaseNotesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The text a tester will read, picked out of [jsonText].
///
/// Walks [preferredLanguages] in order and falls back to the **first entry in
/// the file** when none of them is present — the same rule Codemagic applies,
/// so switching to its `publishing:` block later cannot change what gets
/// published without anyone noticing.
///
/// Throws a [ReleaseNotesException] when the file is not the shape the rule
/// documents: a JSON array of objects with `language` and `text`. Distributing
/// with empty notes is the failure this whole change exists to remove, so it is
/// never the outcome.
String renderReleaseNotes(
  String jsonText, {
  List<String> preferredLanguages = kPreferredLanguages,
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonText);
  } on FormatException catch (error) {
    throw ReleaseNotesException(
      'release_notes.json is not valid JSON: ${error.message}',
    );
  }

  if (decoded is! List) {
    throw ReleaseNotesException(
      'release_notes.json must be a JSON array of '
      '{"language": ..., "text": ...} objects.',
    );
  }
  if (decoded.isEmpty) {
    throw ReleaseNotesException('release_notes.json has no entries.');
  }

  // Keyed by language so the preference walk is a lookup, but the original
  // order is kept separately: the fallback is positional, not alphabetical.
  final Map<String, String> byLanguage = <String, String>{};
  final List<String> inFileOrder = <String>[];

  for (final Object? entry in decoded) {
    if (entry is! Map) {
      throw ReleaseNotesException(
        'Every entry of release_notes.json must be an object; found '
        '${entry.runtimeType}.',
      );
    }
    final Object? language = entry['language'];
    final Object? text = entry['text'];
    if (language is! String || language.trim().isEmpty) {
      throw ReleaseNotesException(
        'An entry of release_notes.json has no "language" code.',
      );
    }
    if (text is! String || text.trim().isEmpty) {
      throw ReleaseNotesException(
        'The "$language" entry of release_notes.json has no "text".',
      );
    }
    byLanguage[language] = text;
    inFileOrder.add(language);
  }

  // `en-US` is mandatory per the rule, and its absence is worth stopping for
  // even when another language would have served here: the build email, Slack
  // and any future migration to Codemagic's own block all read that entry.
  if (!byLanguage.containsKey('en-US')) {
    throw ReleaseNotesException(
      'release_notes.json must carry an "en-US" entry — it is the one '
      'Codemagic publishes to email, Slack and Firebase. Found: '
      '${inFileOrder.join(', ')}.',
    );
  }

  for (final String language in preferredLanguages) {
    final String? text = byLanguage[language];
    if (text != null) {
      return _normalise(text);
    }
  }
  return _normalise(byLanguage[inFileOrder.first]!);
}

/// Trims the surrounding blank space and guarantees a trailing newline.
///
/// The Firebase console renders the notes verbatim, so a stray leading blank
/// line shows up as one.
String _normalise(String text) => '${text.trim()}\n';

void main(List<String> args) {
  String input = kDefaultInput;
  String output = kDefaultOutput;
  List<String> languages = kPreferredLanguages;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--input':
        input = args[++i];
      case '--output':
        output = args[++i];
      case '--language':
        // An explicit choice wins outright; the file's own order still backs it
        // up if that language is missing.
        languages = <String>[args[++i]];
      default:
        stderr.writeln('Unknown argument: ${args[i]}');
        exit(64); // EX_USAGE
    }
  }

  final File source = File(input);
  if (!source.existsSync()) {
    stderr.writeln(
      'release notes: $input not found. It lives at the repository root and '
      'is required to distribute — see .agents/rules/release-notes.md.',
    );
    exit(66); // EX_NOINPUT
  }

  final String notes;
  try {
    notes = renderReleaseNotes(
      source.readAsStringSync(),
      preferredLanguages: languages,
    );
  } on ReleaseNotesException catch (error) {
    stderr.writeln('release notes: $error');
    exit(65); // EX_DATAERR
  }

  File(output).writeAsStringSync(notes);
  stdout.writeln(
    'release notes: wrote $output (${notes.trim().length} chars) '
    'from $input',
  );
}
