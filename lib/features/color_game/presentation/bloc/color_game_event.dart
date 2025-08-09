import 'package:equatable/equatable.dart';

/// Base class for all color game events
abstract class ColorGameEvent extends Equatable {
  const ColorGameEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a new game
class StartGameEvent extends ColorGameEvent {
  const StartGameEvent();
}

/// Event to generate next question
class GenerateQuestionEvent extends ColorGameEvent {
  const GenerateQuestionEvent();
}

/// Event when user selects an answer
class AnswerSelectedEvent extends ColorGameEvent {
  final String selectedColor;

  const AnswerSelectedEvent({required this.selectedColor});

  @override
  List<Object?> get props => [selectedColor];
}

/// Event to reset the game
class ResetGameEvent extends ColorGameEvent {
  const ResetGameEvent();
}

/// Event to end the game
class EndGameEvent extends ColorGameEvent {
  const EndGameEvent();
}