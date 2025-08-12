import 'package:get_it/get_it.dart';

import 'core/utils/logger.dart';
import 'features/color_game/data/datasources/color_game_local_data_source.dart';
import 'features/color_game/data/repositories/color_game_repository_impl.dart';
import 'features/color_game/domain/repositories/color_game_repository.dart';
import 'features/color_game/domain/usecases/answer_question.dart';
import 'features/color_game/domain/usecases/generate_color_question.dart';
import 'features/color_game/domain/usecases/start_game_session.dart';
import 'features/color_game/presentation/bloc/color_game_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Flag to prevent multiple initializations
bool _isInitialized = false;

/// Initialize all dependencies (safe for multiple calls)
Future<void> init() async {
  if (_isInitialized) {
    AppLogger.i('Dependency injection container already initialized - skipping');
    return;
  }

  AppLogger.i('Initializing dependency injection container');

  try {
    // Clear existing registrations in case of partial initialization
    if (sl.isRegistered<ColorGameBloc>()) {
      await sl.reset();
    }

    // Features - Color Game
    _initColorGame();

    // Core
    _initCore();

    // External
    _initExternal();

    _isInitialized = true;
    AppLogger.i('Dependency injection container initialized successfully');
  } catch (e) {
    AppLogger.e('Error initializing dependency injection: $e');
    // Reset flag on error so we can try again
    _isInitialized = false;
    rethrow;
  }
}

/// Reset the dependency injection container (for testing)
Future<void> reset() async {
  AppLogger.i('Resetting dependency injection container');
  await sl.reset();
  _isInitialized = false;
  AppLogger.i('Dependency injection container reset completed');
}

void _initColorGame() {
  // Bloc
  sl.registerFactory(
    () => ColorGameBloc(
      startGameSession: sl(),
      generateColorQuestion: sl(),
      answerQuestion: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => StartGameSession(sl()));
  sl.registerLazySingleton(() => GenerateColorQuestion(sl()));
  sl.registerLazySingleton(() => AnswerQuestion(sl()));

  // Repository
  sl.registerLazySingleton<ColorGameRepository>(
    () => ColorGameRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ColorGameLocalDataSource>(
    () => ColorGameLocalDataSourceImpl(),
  );
}

void _initCore() {
  // Add core services here as needed
  // For example: Network info, Permission handler, etc.
}

void _initExternal() {
  // Add external dependencies here
  // For example: SharedPreferences, Dio, etc.
}