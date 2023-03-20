// AuthException
// Authentication exception information

class AuthException implements Exception {
  static const String errorCodeMissingVerification = 'missingVerificationId';
  static const String errorCodeRetrievalTimeout = 'codeAutoRetrievalTimeout';
  static const String errorCodeUnauthorized = 'unauthorized';

  AuthException({
    this.message,
    required this.code,
    this.context,
  });

  final String? message;
  final String code;
  final String? context;
}
