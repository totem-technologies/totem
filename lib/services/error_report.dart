import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> reportError(dynamic exception, dynamic stackTrace) async {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
  );
}
