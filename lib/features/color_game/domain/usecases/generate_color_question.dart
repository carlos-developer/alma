import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/color_question.dart';
import '../repositories/color_game_repository.dart';

/// Use case for generating a new color question
class GenerateColorQuestion extends UseCase<ColorQuestion, GenerateColorQuestionParams> {
  final ColorGameRepository repository;

  GenerateColorQuestion(this.repository);

  @override
  Future<Either<Failure, ColorQuestion>> call(GenerateColorQuestionParams params) async {
    return await repository.generateQuestion(params.level);
  }
}

class GenerateColorQuestionParams extends Equatable {
  final int level;

  const GenerateColorQuestionParams({required this.level});

  @override
  List<Object> get props => [level];
}