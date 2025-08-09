import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/color_question.dart';
import '../entities/game_session.dart';

/// Repository interface for color game
abstract class ColorGameRepository {
  /// Generates a new color question
  Future<Either<Failure, ColorQuestion>> generateQuestion(int level);
  
  /// Saves the current game session
  Future<Either<Failure, void>> saveSession(GameSession session);
  
  /// Gets the current game session
  Future<Either<Failure, GameSession?>> getCurrentSession();
  
  /// Updates the game session with a new answer
  Future<Either<Failure, GameSession>> updateSessionWithAnswer({
    required GameSession session,
    required String questionId,
    required bool isCorrect,
  });
  
  /// Ends the current game session
  Future<Either<Failure, void>> endSession(String sessionId);
  
  /// Gets game statistics
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();
}