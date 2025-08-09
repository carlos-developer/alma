import 'package:alma/core/error/failures.dart';
import 'package:alma/features/color_game/domain/entities/color_question.dart';
import 'package:alma/features/color_game/domain/repositories/color_game_repository.dart';
import 'package:alma/features/color_game/domain/usecases/generate_color_question.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockColorGameRepository extends Mock implements ColorGameRepository {}

void main() {
  late GenerateColorQuestion usecase;
  late MockColorGameRepository mockRepository;

  setUp(() {
    mockRepository = MockColorGameRepository();
    usecase = GenerateColorQuestion(mockRepository);
  });

  final tLevel = 1;
  final tColorQuestion = ColorQuestion(
    id: const Uuid().v4(),
    correctColorName: 'Rojo',
    correctColor: Colors.red,
    options: ['Rojo', 'Azul'],
    level: tLevel,
    createdAt: DateTime.now(),
  );

  test(
    'should get color question from repository',
    () async {
      // arrange
      when(() => mockRepository.generateQuestion(any()))
          .thenAnswer((_) async => Right(tColorQuestion));

      // act
      final result = await usecase(GenerateColorQuestionParams(level: tLevel));

      // assert
      expect(result, Right(tColorQuestion));
      verify(() => mockRepository.generateQuestion(tLevel));
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return failure when repository fails',
    () async {
      // arrange
      const tFailure = GameFailure(message: 'Failed to generate question');
      when(() => mockRepository.generateQuestion(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(GenerateColorQuestionParams(level: tLevel));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.generateQuestion(tLevel));
      verifyNoMoreInteractions(mockRepository);
    },
  );
}