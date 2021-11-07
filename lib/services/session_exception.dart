class SessionException implements Exception {
  static const String errorCodeUnauthorized = 'unauthorized';
  static const String errorCodeInvalidSession = 'invalid session';

  SessionException({
    this.message,
    required this.code,
    required this.reference,
  });

  final String? message;
  final String code;
  final String reference;
}
