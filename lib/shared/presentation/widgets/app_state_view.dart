import 'package:flutter/material.dart';

import '../../../config/theme/colors/colors_values.dart';
import '../../../core/constants/constants.dart';
import '../../../core/i18n/app_messages.dart';

/// Which exceptional state a view represents. Kept apart from the message so
/// "no data" reads visually different from "something failed", even when the
/// text is short (a criterion of #11).
///
/// [noResults] is not the same as [empty], and the difference is worth a case:
/// empty means the app has nothing to show, while no-results means it has data
/// and the user's own filter excluded all of it. Showing "no rates yet, pull to
/// refresh" to someone who just mistyped a search would be a lie.
enum AppStateKind { error, empty, noResults }

/// A shared, branded state view for the exceptional screens — error and empty —
/// used by both Home and Converter.
///
/// It replaces the minimal advisor cards that used to live inside
/// `home_widgets.dart`: a flat line of text with no illustration and no clear
/// recovery. This one is centred, uses the project palette (and, for the empty
/// state, the app logo), works in light and dark, and — for errors — offers a
/// retry that re-requests the data.
///
/// What the states **say** (which message for which failure) is #18's job; this
/// is how they **look**. So the caller passes the already-resolved [message];
/// the error state shows the `loadingError` headline above it.
class AppStateView extends StatelessWidget {
  const AppStateView.error({
    super.key,
    required String message,
    this.onRetry,
    this.isBusy = false,
  }) : kind = AppStateKind.error,
       _message = message;

  const AppStateView.empty({super.key, String? message, this.onRetry})
    : kind = AppStateKind.empty,
      _message = message,
      isBusy = false;

  /// Nothing matched what the user is filtering by (#41).
  ///
  /// No retry: the data is fine and re-requesting it would change nothing. The
  /// way out is to change the filter, and that control belongs to whoever owns
  /// it — the search field's own clear button, in the currency selector.
  const AppStateView.noResults({super.key, String? message})
    : kind = AppStateKind.noResults,
      _message = message,
      onRetry = null,
      isBusy = false;

  final AppStateKind kind;
  final String? _message;

  /// Re-requests the data. When null, no retry button is shown.
  final VoidCallback? onRetry;

  /// While a retry is in flight the button is disabled, so a double tap does not
  /// fire two refreshes.
  final bool isBusy;

  bool get _isError => kind == AppStateKind.error;

  @override
  Widget build(BuildContext context) {
    final accent = _isError
        ? ColorValues.textErrorPrimary(context)
        : ColorValues.textQuaternary(context);

    final title = switch (kind) {
      AppStateKind.error => AppMessages.loadingError,
      AppStateKind.empty => AppMessages.emptyStateTitle,
      AppStateKind.noResults => AppMessages.noSearchResultsTitle,
    };
    final message =
        _message ??
        switch (kind) {
          AppStateKind.error => '',
          AppStateKind.empty => AppMessages.emptyStateMessage,
          AppStateKind.noResults => '',
        };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _illustration(context, accent),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isError ? accent : ColorValues.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorValues.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isBusy ? null : onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppMessages.retryAction),
            ),
          ],
        ],
      ),
    );
  }

  /// Error → an error icon in a tinted circle (the error palette). No results →
  /// a struck-through magnifier, so it reads as "your filter found nothing"
  /// rather than "the app is empty". Empty → the app logo, faded. The three
  /// never look alike, which is the point of #11.
  Widget _illustration(BuildContext context, Color accent) {
    if (_isError || kind == AppStateKind.noResults) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.12),
        ),
        child: Icon(
          _isError ? Icons.cloud_off_rounded : Icons.search_off_rounded,
          color: accent,
          size: 40,
        ),
      );
    }
    return Opacity(
      opacity: 0.55,
      child: Image.asset(
        Constants.appLogoAsset,
        width: 72,
        height: 72,
        // The empty state must not itself fail if the asset is missing.
        errorBuilder: (_, _, _) =>
            Icon(Icons.inbox_rounded, color: accent, size: 48),
      ),
    );
  }
}
