import 'package:url_launcher/url_launcher.dart';

/// Opens a web address outside the app.
///
/// A helper rather than a `launchUrl` at each call site, for the two things
/// that are easy to get wrong once per row: **only `https` is opened**, and a
/// refusal is reported instead of swallowed.
///
/// The scheme check is not ceremony. `launchUrl` will happily fire `tel:`,
/// `intent:` or a custom scheme, and the addresses this app opens all come from
/// its own constants today — but the About screen's rows are data
/// (`Markets.sources`), and the day one of those URLs comes from the backend
/// instead, this is the line that decides whether a hostile payload can start
/// an arbitrary activity.
///
/// **Android needs the manifest to agree.** From API 30 an app only sees the
/// intents it declares, so `AndroidManifest.xml` carries a `<queries>` entry for
/// `VIEW` + `https`; without it every call here returns `false` on a device that
/// has a browser installed.
class ExternalLink {
  const ExternalLink._();

  /// Opens [url] in the browser. Returns whether the platform accepted it.
  ///
  /// `externalApplication` and not the in-app web view: these links leave the
  /// app on purpose — the user is going to check a source or read a repository,
  /// and doing that inside a frame with no address bar hides the very thing
  /// they went to verify.
  ///
  /// Returns `false` rather than throwing on a malformed or non-`https` URL. The
  /// caller is a row in a list: it has somewhere to show a message and nowhere
  /// to handle an exception.
  static Future<bool> open(String url) async {
    final Uri? parsed = Uri.tryParse(url);
    if (parsed == null || parsed.scheme != 'https') {
      return false;
    }

    try {
      return await launchUrl(parsed, mode: LaunchMode.externalApplication);
    } on Object {
      // `launchUrl` throws a `PlatformException` when no activity can handle
      // the intent. From this screen's point of view that is the same outcome
      // as a `false`, and it must not reach the user as a crash.
      return false;
    }
  }
}
