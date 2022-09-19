import 'package:sentry/sentry.dart';

Future<void> reportError(dynamic exception, dynamic stackTrace) async {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
  );
}
