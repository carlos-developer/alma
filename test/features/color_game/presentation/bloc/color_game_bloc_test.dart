import 'package:alma/core/error/failures.dart';
import 'package:alma/core/usecases/usecase.dart';
import 'package:alma/core/utils/logger.dart';
import 'package:alma/features/color_game/domain/entities/color_question.dart';
import 'package:alma/features/color_game/domain/entities/game_session.dart';
import 'package:alma/features/color_game/domain/repositories/color_game_repository.dart';
import 'package:alma/features/color_game/domain/usecases/answer_question.dart';
import 'package:alma/features/color_game/domain/usecases/generate_color_question.dart';
import 'package:alma/features/color_game/domain/usecases/start_game_session.dart';
import 'package:alma/features/color_game/presentation/bloc/color_game_bloc.dart';
import 'package:alma/features/color_game/presentation/bloc/color_game_event.dart';
import 'package:alma/features/color_game/presentation/bloc/color_game_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockStartGameSession extends Mock implements StartGameSession {}
class MockGenerateColorQuestion extends Mock implements GenerateColorQuestion {}
class MockAnswerQuestion extends Mock implements AnswerQuestion {}
class MockColorGameRepository extends Mock implements ColorGameRepository {}

void main() {
  late ColorGameBloc bloc;
  late MockStartGameSession mockStartGameSession;
  late MockGenerateColorQuestion mockGenerateColorQuestion;
  late MockAnswerQuestion mockAnswerQuestion;
  late MockColorGameRepository mockRepository;

  setUpAll(() {
    // Initialize AppLogger for tests
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLogger.init(level: Level.off); // Disable logging in tests
    
    // Register fallback values for mocktail
    registerFallbackValue(NoParams());
    registerFallbackValue(GenerateColorQuestionParams(level: 1));
    registerFallbackValue(AnswerQuestionParams(
      session: GameSession(
        id: 'test',
        score: 0,
        currentLevel: 1,
        correctAnswers: 0,
        incorrectAnswers: 0,
        startedAt: DateTime.now(),
        answeredQuestions: const [],
      ),
      questionId: 'test',
      isCorrect: true,
    ));
  });

  setUp(() {
    mockStartGameSession = MockStartGameSession();
    mockGenerateColorQuestion = MockGenerateColorQuestion();
    mockAnswerQuestion = MockAnswerQuestion();
    mockRepository = MockColorGameRepository();
    
    bloc = ColorGameBloc(
      startGameSession: mockStartGameSession,
      generateColorQuestion: mockGenerateColorQuestion,
      answerQuestion: mockAnswerQuestion,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tSession = GameSession(
    id: const Uuid().v4(),
    score: 0,
    currentLevel: 1,
    correctAnswers: 0,
    incorrectAnswers: 0,
    startedAt: DateTime.now(),
    answeredQuestions: const [],
  );

  final tQuestion = ColorQuestion(
    id: const Uuid().v4(),
    correctColorName: 'Rojo',
    correctColor: Colors.red,
    options: const ['Rojo', 'Azul'],
    level: 1,
    createdAt: DateTime.now(),
  );

  group('StartGameEvent', () {
    blocTest<ColorGameBloc, ColorGameState>(
      'emits [ColorGameLoading, ColorGameReady] when game starts successfully',
      build: () {
        when(() => mockStartGameSession(any()))
            .thenAnswer((_) async => Right(tSession));
        when(() => mockGenerateColorQuestion(any()))
            .thenAnswer((_) async => Right(tQuestion));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartGameEvent()),
      expect: () => [
        const ColorGameLoading(),
        ColorGameReady(session: tSession, currentQuestion: tQuestion),
      ],
      verify: (_) {
        verify(() => mockStartGameSession(any())).called(1);
        verify(() => mockGenerateColorQuestion(any())).called(1);
      },
    );

    blocTest<ColorGameBloc, ColorGameState>(
      'emits [ColorGameLoading, ColorGameError] when starting game fails',
      build: () {
        when(() => mockStartGameSession(any()))
            .thenAnswer((_) async => const Left(GeneralFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartGameEvent()),
      expect: () => [
        const ColorGameLoading(),
        const ColorGameError(message: 'Error'),
      ],
    );
  });

  group('AnswerSelectedEvent', () {
    blocTest<ColorGameBloc, ColorGameState>(
      'emits [ColorGameCorrectAnswer, ColorGameTransitioning, ColorGameReady] when answer is correct',
      build: () {
        when(() => mockAnswerQuestion(any()))
            .thenAnswer((_) async => Right(tSession.copyWith(
                  score: 10,
                  correctAnswers: 1,
                )));
        // Mock the generateColorQuestion call that happens after correct answer
        when(() => mockGenerateColorQuestion(any()))
            .thenAnswer((_) async => Right(tQuestion));
        return bloc;
      },
      seed: () => ColorGameReady(session: tSession, currentQuestion: tQuestion),
      act: (bloc) => bloc.add(const AnswerSelectedEvent(selectedColor: 'Rojo')),
      expect: () => [
        ColorGameCorrectAnswer(
          session: tSession.copyWith(score: 10, correctAnswers: 1),
          currentQuestion: tQuestion,
        ),
        ColorGameTransitioning(
          session: tSession.copyWith(score: 10, correctAnswers: 1),
        ),
        ColorGameReady(
          session: tSession.copyWith(score: 10, correctAnswers: 1),
          currentQuestion: tQuestion,
        ),
      ],
      wait: const Duration(milliseconds: 3000), // Increased wait time to be safe
    );

    blocTest<ColorGameBloc, ColorGameState>(
      'emits [ColorGameIncorrectAnswer, ColorGameReady] when answer is incorrect',
      build: () {
        when(() => mockAnswerQuestion(any()))
            .thenAnswer((_) async => Right(tSession.copyWith(
                  incorrectAnswers: 1,
                )));
        return bloc;
      },
      seed: () => ColorGameReady(session: tSession, currentQuestion: tQuestion),
      act: (bloc) => bloc.add(const AnswerSelectedEvent(selectedColor: 'Azul')),
      expect: () => [
        ColorGameIncorrectAnswer(
          session: tSession.copyWith(incorrectAnswers: 1),
          currentQuestion: tQuestion,
          selectedAnswer: 'Azul',
        ),
        ColorGameReady(
          session: tSession.copyWith(incorrectAnswers: 1),
          currentQuestion: tQuestion,
        ),
      ],
      wait: const Duration(milliseconds: 3000), // Increased wait time to be safe
    );
  });

  group('ResetGameEvent', () {
    blocTest<ColorGameBloc, ColorGameState>(
      'emits [ColorGameInitial] and triggers StartGameEvent',
      build: () {
        when(() => mockStartGameSession(any()))
            .thenAnswer((_) async => Right(tSession));
        when(() => mockGenerateColorQuestion(any()))
            .thenAnswer((_) async => Right(tQuestion));
        return bloc;
      },
      seed: () => ColorGameEnded(session: tSession, statistics: const {}),
      act: (bloc) => bloc.add(const ResetGameEvent()),
      expect: () => [
        const ColorGameInitial(),
        const ColorGameLoading(),
        ColorGameReady(session: tSession, currentQuestion: tQuestion),
      ],
    );
  });
}