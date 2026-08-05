import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../config/enviroment/enviroment.dart';
import '../../../../core/i18n/app_messages.dart';

/// Shown instead of the app when the build has no usable configuration.
///
/// It replaces what used to happen: the app started, asked for the rates
/// against a relative URL and surfaced a generic network error that never
/// mentioned a missing variable. The two audiences need different things, so
/// the page serves them differently — the developer gets the diagnostic, the
/// user gets a plain statement. Neither ever sees the configured URL.
class ConfigurationErrorPage extends StatelessWidget {
  const ConfigurationErrorPage({required this.error, super.key});

  final EnvironmentError error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.settings_ethernet, size: 56),
                const SizedBox(height: 24),
                Text(
                  AppMessages.configErrorTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppMessages.configErrorBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                // The diagnostic names the project's own files and is written
                // for whoever builds the app, so it is compiled out of release
                // by `kDebugMode` — a user cannot act on it, and it would only
                // expose how the app is wired.
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      error.developerMessage,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
