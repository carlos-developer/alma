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
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.init(
    level: kDebugMode ? Level.debug : Level.warning,
  );

  // Log application start
  AppLogger.i('Starting ALMA application');

  // Set preferred orientations (optional - for better mobile experience)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize dependency injection
  await di.init();

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Run the app with error handling
  runApp(const AlmaApp());
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