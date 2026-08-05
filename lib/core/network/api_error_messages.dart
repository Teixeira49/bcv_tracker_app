import '../i18n/app_messages.dart';
import 'api_exception.dart';

/// Translates an [ApiException] into the message the **user** should read.
///
/// The backend's own `message` is written for developers (and goes to the log,
/// #19); the user needs to know whether the problem is theirs (no connection)
/// or the service's, and what to do about it. The mapping is by [kind] first —
/// so "no connection" is never confused with "the server failed" — and then by
/// the HTTP code the backend assigns meaning to (408 slow source, 502 source
/// down, 422 mode not allowed, 500 internal). Anything else falls to a
/// controlled generic message rather than leaking a raw status.
String apiErrorMessage(ApiException e) {
  switch (e.kind) {
    case ApiExceptionKind.network:
      return AppMessages.errorNoConnection;
    case ApiExceptionKind.malformed:
      return AppMessages.errorUnexpectedResponse;
    case ApiExceptionKind.response:
      return switch (e.statusCode) {
        408 => AppMessages.errorTimeout,
        422 => AppMessages.errorInvalidRequest,
        502 => AppMessages.errorServiceUnavailable,
        500 => AppMessages.errorServerInternal,
        _ => AppMessages.errorGeneric,
      };
  }
}
