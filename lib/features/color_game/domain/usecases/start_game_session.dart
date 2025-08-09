import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/color_game_repository.dart';

/// Use case for starting a new game session
class StartGameSession extends UseCase<GameSession, NoParams> {
  final ColorGameRepository repository;

  StartGameSession(this.repository);

  @override
  Future<Either<Failure, GameSession>> call(NoParams params) async {
    final session = GameSession(
      id: const Uuid().v4(),
      score: 0,
      currentLevel: 1,
      correctAnswers: 0,
      incorrectAnswers: 0,
      startedAt: DateTime.now(),
      answeredQuestions: const [],
    );
    
    final result = await repository.saveSession(session);
    
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(session),
    );
  }
}