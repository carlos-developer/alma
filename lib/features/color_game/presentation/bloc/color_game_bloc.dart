import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/usecases/answer_question.dart';
import '../../domain/usecases/generate_color_question.dart';
import '../../domain/usecases/start_game_session.dart';
import '../../domain/repositories/color_game_repository.dart';
import 'color_game_event.dart';
import 'color_game_state.dart';

/// BLoC for managing color game state
class ColorGameBloc extends Bloc<ColorGameEvent, ColorGameState> {
  final StartGameSession startGameSession;
  final GenerateColorQuestion generateColorQuestion;
  final AnswerQuestion answerQuestion;
  final ColorGameRepository repository;

  ColorGameBloc({
    required this.startGameSession,
    required this.generateColorQuestion,
    required this.answerQuestion,
    required this.repository,
  }) : super(const ColorGameInitial()) {
    on<StartGameEvent>(_onStartGame);
    on<GenerateQuestionEvent>(_onGenerateQuestion);
    on<AnswerSelectedEvent>(_onAnswerSelected);
    on<ResetGameEvent>(_onResetGame);
    on<EndGameEvent>(_onEndGame);
  }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    try {
      emit(const ColorGameLoading());
      
      // Start new game session
      final sessionResult = await startGameSession(NoParams());
      
      await sessionResult.fold(
        (failure) async {
          AppLogger.e('Failed to start game session', failure);
          emit(ColorGameError(message: failure.message));
        },
        (session) async {
          // Generate first question
          final questionResult = await generateColorQuestion(
            GenerateColorQuestionParams(level: session.currentLevel),
          );
          
          questionResult.fold(
            (failure) {
              AppLogger.e('Failed to generate question', failure);
              emit(ColorGameError(message: failure.message));
            },
            (question) {
              AppLogger.i('Game started with session: ${session.id}');
              emit(ColorGameReady(
                session: session,
                currentQuestion: question,
              ));
            },
          );
        },
      );
    } catch (e, stack) {
      AppLogger.e('Unexpected error starting game', e, stack);
      emit(ColorGameError(message: e.toString()));
    }
  }

  Future<void> _onGenerateQuestion(
    GenerateQuestionEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    try {
      if (state is ColorGameTransitioning) {
        final transitionState = state as ColorGameTransitioning;
        
        final questionResult = await generateColorQuestion(
          GenerateColorQuestionParams(
            level: transitionState.session.currentLevel,
          ),
        );
        
        questionResult.fold(
          (failure) {
            AppLogger.e('Failed to generate question', failure);
            emit(ColorGameError(message: failure.message));
          },
          (question) {
            AppLogger.d('New question generated: ${question.id}');
            emit(ColorGameReady(
              session: transitionState.session,
              currentQuestion: question,
            ));
          },
        );
      }
    } catch (e, stack) {
      AppLogger.e('Unexpected error generating question', e, stack);
      emit(ColorGameError(message: e.toString()));
    }
  }

  Future<void> _onAnswerSelected(
    AnswerSelectedEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    try {
      if (state is ColorGameReady) {
        final currentState = state as ColorGameReady;
        final isCorrect = event.selectedColor == 
            currentState.currentQuestion.correctColorName;
        
        // Update session with answer
        final updateResult = await answerQuestion(
          AnswerQuestionParams(
            session: currentState.session,
            questionId: currentState.currentQuestion.id,
            isCorrect: isCorrect,
          ),
        );
        
        await updateResult.fold(
          (failure) async {
            AppLogger.e('Failed to update session', failure);
            emit(ColorGameError(message: failure.message));
          },
          (updatedSession) async {
            AppLogger.d('Answer processed: $isCorrect');
            
            if (isCorrect) {
              // Show correct answer feedback
              emit(ColorGameCorrectAnswer(
                session: updatedSession,
                currentQuestion: currentState.currentQuestion,
              ));
              
              // Transition to next question after delay
              await Future.delayed(const Duration(milliseconds: 1500));
              emit(ColorGameTransitioning(session: updatedSession));
              
              // Automatically generate next question
              add(const GenerateQuestionEvent());
            } else {
              // Show incorrect answer feedback
              emit(ColorGameIncorrectAnswer(
                session: updatedSession,
                currentQuestion: currentState.currentQuestion,
                selectedAnswer: event.selectedColor,
              ));
              
              // Allow retry after delay
              await Future.delayed(const Duration(milliseconds: 2000));
              emit(ColorGameReady(
                session: updatedSession,
                currentQuestion: currentState.currentQuestion,
              ));
            }
          },
        );
      }
    } catch (e, stack) {
      AppLogger.e('Unexpected error processing answer', e, stack);
      emit(ColorGameError(message: e.toString()));
    }
  }

  Future<void> _onResetGame(
    ResetGameEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    try {
      AppLogger.i('Resetting game');
      emit(const ColorGameInitial());
      // Start new game
      add(const StartGameEvent());
    } catch (e, stack) {
      AppLogger.e('Unexpected error resetting game', e, stack);
      emit(ColorGameError(message: e.toString()));
    }
  }

  Future<void> _onEndGame(
    EndGameEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    try {
      if (state is ColorGameReady || 
          state is ColorGameCorrectAnswer || 
          state is ColorGameIncorrectAnswer) {
        
        // Get current session from state
        late final GameSession session;
        if (state is ColorGameReady) {
          session = (state as ColorGameReady).session;
        } else if (state is ColorGameCorrectAnswer) {
          session = (state as ColorGameCorrectAnswer).session;
        } else {
          session = (state as ColorGameIncorrectAnswer).session;
        }
        
        // End session
        await repository.endSession(session.id);
        
        // Get statistics
        final statsResult = await repository.getStatistics();
        
        statsResult.fold(
          (failure) {
            AppLogger.e('Failed to get statistics', failure);
            emit(ColorGameError(message: failure.message));
          },
          (statistics) {
            AppLogger.i('Game ended. Score: ${session.score}');
            emit(ColorGameEnded(
              session: session,
              statistics: statistics,
            ));
          },
        );
      }
    } catch (e, stack) {
      AppLogger.e('Unexpected error ending game', e, stack);
      emit(ColorGameError(message: e.toString()));
    }
  }
}