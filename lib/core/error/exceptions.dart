/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Exception thrown when game logic fails
class GameException extends AppException {
  const GameException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}