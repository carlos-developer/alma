import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/error/exceptions.dart';
import '../models/color_question_model.dart';
import '../models/game_session_model.dart';

/// Local data source for color game
abstract class ColorGameLocalDataSource {
  /// Generates a new color question based on level
  Future<ColorQuestionModel> generateQuestion(int level);
  
  /// Saves the current game session
  Future<void> saveSession(GameSessionModel session);
  
  /// Gets the current game session
  Future<GameSessionModel?> getCurrentSession();
  
  /// Caches game statistics
  Future<void> cacheStatistics(Map<String, dynamic> statistics);
  
  /// Gets cached statistics
  Future<Map<String, dynamic>?> getCachedStatistics();
}

class ColorGameLocalDataSourceImpl implements ColorGameLocalDataSource {
  static const String _sessionKey = 'current_session';
  static const String _statisticsKey = 'game_statistics';
  
  // In-memory storage for MVP (can be replaced with SharedPreferences later)
  final Map<String, dynamic> _storage = {};
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  @override
  Future<ColorQuestionModel> generateQuestion(int level) async {
    try {
      // Get available colors
      final allColors = GameColors.colorNames;
      
      // Determine number of options based on level
      int numberOfOptions = _calculateNumberOfOptions(level);
      numberOfOptions = numberOfOptions.clamp(2, allColors.length);
      
      // Select correct answer
      final correctColorName = allColors[_random.nextInt(allColors.length)];
      final correctColor = GameColors.getColor(correctColorName);
      
      // Generate options (including correct answer)
      final options = _generateOptions(
        correctColorName,
        allColors,
        numberOfOptions,
      );
      
      // Shuffle options
      options.shuffle(_random);
      
      return ColorQuestionModel(
        id: _uuid.v4(),
        correctColorName: correctColorName,
        correctColor: correctColor,
        options: options,
        level: level,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw GameException(
        message: 'Failed to generate question',
        originalError: e,
      );
    }
  }

  @override
  Future<void> saveSession(GameSessionModel session) async {
    try {
      _storage[_sessionKey] = jsonEncode(session.toJson());
    } catch (e) {
      throw CacheException(
        message: 'Failed to save session',
        originalError: e,
      );
    }
  }

  @override
  Future<GameSessionModel?> getCurrentSession() async {
    try {
      final jsonString = _storage[_sessionKey] as String?;
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameSessionModel.fromJson(json);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get current session',
        originalError: e,
      );
    }
  }

  @override
  Future<void> cacheStatistics(Map<String, dynamic> statistics) async {
    try {
      _storage[_statisticsKey] = jsonEncode(statistics);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache statistics',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedStatistics() async {
    try {
      final jsonString = _storage[_statisticsKey] as String?;
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached statistics',
        originalError: e,
      );
    }
  }

  /// Calculates number of options based on level
  int _calculateNumberOfOptions(int level) {
    // Start with 2 options, add one more every 3 levels
    return 2 + (level ~/ 3);
  }

  /// Generates options for the question
  List<String> _generateOptions(
    String correctAnswer,
    List<String> allColors,
    int numberOfOptions,
  ) {
    final options = <String>[correctAnswer];
    final availableColors = List<String>.from(allColors)..remove(correctAnswer);
    
    // Add random incorrect options
    while (options.length < numberOfOptions && availableColors.isNotEmpty) {
      final randomIndex = _random.nextInt(availableColors.length);
      options.add(availableColors[randomIndex]);
      availableColors.removeAt(randomIndex);
    }
    
    return options;
  }
}