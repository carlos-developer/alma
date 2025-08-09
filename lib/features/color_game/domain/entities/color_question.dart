import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity representing a color identification question
class ColorQuestion extends Equatable {
  final String id;
  final String correctColorName;
  final Color correctColor;
  final List<String> options;
  final int level;
  final DateTime createdAt;

  const ColorQuestion({
    required this.id,
    required this.correctColorName,
    required this.correctColor,
    required this.options,
    required this.level,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        correctColorName,
        correctColor,
        options,
        level,
        createdAt,
      ];

  ColorQuestion copyWith({
    String? id,
    String? correctColorName,
    Color? correctColor,
    List<String>? options,
    int? level,
    DateTime? createdAt,
  }) {
    return ColorQuestion(
      id: id ?? this.id,
      correctColorName: correctColorName ?? this.correctColorName,
      correctColor: correctColor ?? this.correctColor,
      options: options ?? this.options,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}