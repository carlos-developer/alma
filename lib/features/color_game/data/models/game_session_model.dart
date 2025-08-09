import '../../domain/entities/game_session.dart';

/// Model class for GameSession with serialization support
class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.score,
    required super.currentLevel,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.startedAt,
    super.endedAt,
    required super.answeredQuestions,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      id: json['id'] as String,
      score: json['score'] as int,
      currentLevel: json['currentLevel'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      answeredQuestions: List<String>.from(json['answeredQuestions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'currentLevel': currentLevel,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'answeredQuestions': answeredQuestions,
    };
  }

  factory GameSessionModel.fromEntity(GameSession entity) {
    return GameSessionModel(
      id: entity.id,
      score: entity.score,
      currentLevel: entity.currentLevel,
      correctAnswers: entity.correctAnswers,
      incorrectAnswers: entity.incorrectAnswers,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      answeredQuestions: entity.answeredQuestions,
    );
  }
}