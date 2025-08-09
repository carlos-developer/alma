import 'package:equatable/equatable.dart';

import '../../domain/entities/color_question.dart';
import '../../domain/entities/game_session.dart';

/// Base class for all color game states
abstract class ColorGameState extends Equatable {
  const ColorGameState();

  @override
  List<Object?> get props => [];
}

/// Initial state before game starts
class ColorGameInitial extends ColorGameState {
  const ColorGameInitial();
}

/// Loading state
class ColorGameLoading extends ColorGameState {
  const ColorGameLoading();
}

/// State when game is ready with a question
class ColorGameReady extends ColorGameState {
  final GameSession session;
  final ColorQuestion currentQuestion;

  const ColorGameReady({
    required this.session,
    required this.currentQuestion,
  });

  @override
  List<Object?> get props => [session, currentQuestion];
}

/// State when user answers correctly
class ColorGameCorrectAnswer extends ColorGameState {
  final GameSession session;
  final ColorQuestion currentQuestion;
  
  const ColorGameCorrectAnswer({
    required this.session,
    required this.currentQuestion,
  });

  @override
  List<Object?> get props => [session, currentQuestion];
}

/// State when user answers incorrectly
class ColorGameIncorrectAnswer extends ColorGameState {
  final GameSession session;
  final ColorQuestion currentQuestion;
  final String selectedAnswer;
  
  const ColorGameIncorrectAnswer({
    required this.session,
    required this.currentQuestion,
    required this.selectedAnswer,
  });

  @override
  List<Object?> get props => [session, currentQuestion, selectedAnswer];
}

/// State when transitioning to next question
class ColorGameTransitioning extends ColorGameState {
  final GameSession session;
  
  const ColorGameTransitioning({required this.session});

  @override
  List<Object?> get props => [session];
}

/// Error state
class ColorGameError extends ColorGameState {
  final String message;

  const ColorGameError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Game ended state
class ColorGameEnded extends ColorGameState {
  final GameSession session;
  final Map<String, dynamic> statistics;

  const ColorGameEnded({
    required this.session,
    required this.statistics,
  });

  @override
  List<Object?> get props => [session, statistics];
}