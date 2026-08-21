import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web address outside the app.
///
/// A helper rather than a `launchUrl` at each call site, for the two things
/// that are easy to get wrong once per row: **only the web schemes are
/// opened**, and a refusal is reported instead of swallowed.
///
/// The check is not ceremony. `launchUrl` will happily fire `tel:`, `intent:`,
/// `file:` or a custom scheme, and the addresses this app opens all come from
/// its own constants today — but the About screen's rows are data
/// (`Markets.sources`), and the day one of those URLs comes from the backend
/// instead, this is the line that decides whether a hostile payload can start
/// an arbitrary activity. A host is required for the same reason: `https:` and
/// `https:javascript:alert(1)` both parse with scheme `https` and no host, so
/// checking the scheme alone lets through a string that is not an address.
///
/// **`http` is allowed, and that is a deliberate concession.** Every link this
/// app owns is `https`, so the temptation is to reject anything else — but the
/// API documentation row is composed from `CURRENCY_BACK`, and `Environment`
/// validates that variable as **`http` or `https`**. A developer pointing the
/// app at `http://10.0.2.2:8000`, which is the documented way to reach a local
/// backend from the Android emulator, would find that row permanently dead with
/// no explanation. Two validators disagreeing about what a valid URL is costs
/// more than the downgrade: the real boundary here is "a web address, not an
/// arbitrary intent", and that is what this enforces.
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
  /// Returns `false` rather than throwing on a malformed or non-web URL. The
  /// caller is a row in a list: it has somewhere to show a message and nowhere
  /// to handle an exception.
  ///
  /// `Uri.tryParse` almost never returns `null` — `'not a url at all'` parses
  /// happily, with an empty scheme — so the guard that does the work is the
  /// pair of conditions below, not the parse.
  static Future<bool> open(String url) async {
    final Uri? parsed = Uri.tryParse(url);
    if (parsed == null || !_isWebAddress(parsed)) {
      return false;
    }

    try {
      return await launchUrl(parsed, mode: LaunchMode.externalApplication);
    } on PlatformException {
      // Thrown when no activity can handle the intent. From this screen's
      // point of view that is the same outcome as a `false`, and it must not
      // reach the user as a crash.
      //
      // Deliberately **not** `on Object`: an `ArgumentError` out of `launchUrl`
      // is a programming mistake in this file, and swallowing it would turn a
      // bug into a row that quietly stops working.
      return false;
    }
  }

  /// Whether [uri] is an address a browser can open, rather than a string that
  /// merely parsed.
  ///
  /// `Uri.parse` lowercases the scheme, so `HTTPS://example.com` is accepted —
  /// which is correct, and worth knowing before someone "fixes" the comparison
  /// with a `toLowerCase()`.
  static bool _isWebAddress(Uri uri) =>
      (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}
