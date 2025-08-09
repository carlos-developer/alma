import 'package:flutter/material.dart';

import '../../domain/entities/color_question.dart';

/// Model class for ColorQuestion with serialization support
class ColorQuestionModel extends ColorQuestion {
  const ColorQuestionModel({
    required super.id,
    required super.correctColorName,
    required super.correctColor,
    required super.options,
    required super.level,
    required super.createdAt,
  });

  factory ColorQuestionModel.fromJson(Map<String, dynamic> json) {
    return ColorQuestionModel(
      id: json['id'] as String,
      correctColorName: json['correctColorName'] as String,
      correctColor: Color(json['correctColor'] as int),
      options: List<String>.from(json['options'] as List),
      level: json['level'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correctColorName': correctColorName,
      'correctColor': correctColor.toARGB32(),
      'options': options,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ColorQuestionModel.fromEntity(ColorQuestion entity) {
    return ColorQuestionModel(
      id: entity.id,
      correctColorName: entity.correctColorName,
      correctColor: entity.correctColor,
      options: entity.options,
      level: entity.level,
      createdAt: entity.createdAt,
    );
  }
}