import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  // Placeholder DSN. In production, this would be replaced with a real Sentry DSN.
  static const String _dsn = '';

  static Future<void> init(VoidCallback appRunner) async {
    if (_dsn.isEmpty) {
      // Sentry DSN is empty; run app normally without Sentry error reporting
      appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.tracesSampleRate = 1.0;
        options.debug = kDebugMode;
      },
      appRunner: appRunner,
    );
  }
}
