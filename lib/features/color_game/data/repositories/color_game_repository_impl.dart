import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/color_question.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/color_game_repository.dart';
import '../datasources/color_game_local_data_source.dart';
import '../models/game_session_model.dart';

/// Implementation of ColorGameRepository
class ColorGameRepositoryImpl implements ColorGameRepository {
  final ColorGameLocalDataSource localDataSource;

  ColorGameRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ColorQuestion>> generateQuestion(int level) async {
    try {
      final question = await localDataSource.generateQuestion(level);
      return Right(question);
    } on GameException catch (e) {
      return Left(GameFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession(GameSession session) async {
    try {
      final sessionModel = GameSessionModel.fromEntity(session);
      await localDataSource.saveSession(sessionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, GameSession?>> getCurrentSession() async {
    try {
      final session = await localDataSource.getCurrentSession();
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, GameSession>> updateSessionWithAnswer({
    required GameSession session,
    required String questionId,
    required bool isCorrect,
  }) async {
    try {
      // Update session with new answer
      final updatedSession = session.copyWith(
        score: isCorrect ? session.score + 10 : session.score,
        correctAnswers: isCorrect 
            ? session.correctAnswers + 1 
            : session.correctAnswers,
        incorrectAnswers: !isCorrect 
            ? session.incorrectAnswers + 1 
            : session.incorrectAnswers,
        currentLevel: _calculateLevel(
          session.correctAnswers + (isCorrect ? 1 : 0),
        ),
        answeredQuestions: [...session.answeredQuestions, questionId],
      );
      
      // Save updated session
      final sessionModel = GameSessionModel.fromEntity(updatedSession);
      await localDataSource.saveSession(sessionModel);
      
      return Right(updatedSession);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endSession(String sessionId) async {
    try {
      final sessionResult = await getCurrentSession();
      
      return sessionResult.fold(
        (failure) => Left(failure),
        (session) async {
          if (session == null) {
            return const Left(
              GameFailure(message: 'No active session found'),
            );
          }
          
          final endedSession = session.copyWith(
            endedAt: DateTime.now(),
          );
          
          final sessionModel = GameSessionModel.fromEntity(endedSession);
          await localDataSource.saveSession(sessionModel);
          
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    try {
      // Try to get cached statistics first
      final cached = await localDataSource.getCachedStatistics();
      if (cached != null) {
        return Right(cached);
      }
      
      // Calculate new statistics from current session
      final sessionResult = await getCurrentSession();
      
      return sessionResult.fold(
        (failure) => Left(failure),
        (session) {
          final stats = {
            'totalQuestions': session?.totalQuestions ?? 0,
            'correctAnswers': session?.correctAnswers ?? 0,
            'incorrectAnswers': session?.incorrectAnswers ?? 0,
            'accuracy': session?.accuracy ?? 0.0,
            'currentLevel': session?.currentLevel ?? 1,
            'score': session?.score ?? 0,
          };
          
          // Cache the statistics
          localDataSource.cacheStatistics(stats);
          
          return Right(stats);
        },
      );
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  /// Calculates level based on correct answers
  int _calculateLevel(int correctAnswers) {
    // Level up every 5 correct answers
    return 1 + (correctAnswers ~/ 5);
  }
}