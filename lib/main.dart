import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'core/utils/logger.dart';
import 'features/color_game/presentation/bloc/color_game_bloc.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

void main() async {
  await mainCommon();
}

/// Common main function that can be called from both main() and tests
Future<void> mainCommon({bool isTest = false}) async {
  // Ensure Flutter binding is initialized (but avoid double initialization in tests)
  if (!isTest) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Initialize logger
  AppLogger.init(
    level: kDebugMode ? Level.debug : Level.warning,
  );

  // Log application start
  AppLogger.i('Starting ALMA application');

  // Set preferred orientations only if not in test mode
  // Integration tests have issues with SystemChrome calls
  if (!isTest && !_isRunningInTest()) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      // Silently ignore SystemChrome errors in test environment
      AppLogger.w('SystemChrome.setPreferredOrientations failed: $e');
    }
  }

  // Initialize dependency injection
  await di.init();

  // Configure system UI overlay style only if not in test mode
  if (!isTest && !_isRunningInTest()) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } catch (e) {
      // Silently ignore SystemChrome errors in test environment
      AppLogger.w('SystemChrome.setSystemUIOverlayStyle failed: $e');
    }
  }

  // Run the app with error handling
  runApp(const AlmaApp());
}

/// Checks if the app is running in a test environment
bool _isRunningInTest() {
  // For web, we can't access Platform.environment
  // So we just return false as we're not in a test environment
  if (kIsWeb) {
    return false;
  }
  
  // This will only be executed on non-web platforms
  // We need to do a runtime check to avoid importing dart:io on web
  try {
    // Use a dynamic check to avoid direct Platform reference
    const testEnv = String.fromEnvironment('FLUTTER_TEST', defaultValue: 'false');
    return testEnv == 'true';
  } catch (e) {
    return false;
  }
}

/// Main application widget
class AlmaApp extends StatelessWidget {
  const AlmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ColorGameBloc>(
          create: (context) => sl<ColorGameBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        
        // Localization configuration
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Spanish
          Locale('en', 'US'), // English
        ],
        locale: const Locale('es', 'ES'),
        
        // Router configuration
        routerConfig: AppRouter.router,
        
        // Builder for global configurations
        builder: (context, child) {
          // Add any global wrappers here
          return ResponsiveWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// Responsive wrapper for global responsive adjustments
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Limit text scale factor for better consistency
        textScaler: TextScaler.linear(
          1.0.clamp(0.8, 1.3),
        ),
      ),
      child: child,
    );
  }
}