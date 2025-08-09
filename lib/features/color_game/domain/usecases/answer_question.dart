import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/color_game_repository.dart';

/// Use case for answering a color question
class AnswerQuestion extends UseCase<GameSession, AnswerQuestionParams> {
  final ColorGameRepository repository;

  AnswerQuestion(this.repository);

  @override
  Future<Either<Failure, GameSession>> call(AnswerQuestionParams params) async {
    return await repository.updateSessionWithAnswer(
      session: params.session,
      questionId: params.questionId,
      isCorrect: params.isCorrect,
    );
  }
}

class AnswerQuestionParams extends Equatable {
  final GameSession session;
  final String questionId;
  final bool isCorrect;

  const AnswerQuestionParams({
    required this.session,
    required this.questionId,
    required this.isCorrect,
  });

  @override
  List<Object> get props => [session, questionId, isCorrect];
}