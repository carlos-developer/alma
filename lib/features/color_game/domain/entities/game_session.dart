import 'package:equatable/equatable.dart';

/// Entity representing a game session
class GameSession extends Equatable {
  final String id;
  final int score;
  final int currentLevel;
  final int correctAnswers;
  final int incorrectAnswers;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<String> answeredQuestions;

  const GameSession({
    required this.id,
    required this.score,
    required this.currentLevel,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.startedAt,
    this.endedAt,
    required this.answeredQuestions,
  });

  bool get isActive => endedAt == null;
  
  int get totalQuestions => correctAnswers + incorrectAnswers;
  
  double get accuracy => 
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        score,
        currentLevel,
        correctAnswers,
        incorrectAnswers,
        startedAt,
        endedAt,
        answeredQuestions,
      ];

  GameSession copyWith({
    String? id,
    int? score,
    int? currentLevel,
    int? correctAnswers,
    int? incorrectAnswers,
    DateTime? startedAt,
    DateTime? endedAt,
    List<String>? answeredQuestions,
  }) {
    return GameSession(
      id: id ?? this.id,
      score: score ?? this.score,
      currentLevel: currentLevel ?? this.currentLevel,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
    );
  }
}