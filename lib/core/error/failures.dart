import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// General failures
class GeneralFailure extends Failure {
  const GeneralFailure({
    required super.message,
    super.code,
  });
}

/// Game related failures
class GameFailure extends Failure {
  const GameFailure({
    required super.message,
    super.code,
  });
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}