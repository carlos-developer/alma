import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base class for all use cases in the application
/// Following Clean Architecture principles
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when the use case doesn't require parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}