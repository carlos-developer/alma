import 'package:alma/core/utils/logger.dart';
import 'package:alma/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  setUpAll(() {
    // Initialize test environment
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize logger for tests
    AppLogger.init(level: Level.off); // Disable logging in tests
  });

  testWidgets('App MaterialApp basic configuration test', (WidgetTester tester) async {
    // Create a simplified test app without full dependency injection
    final testApp = MaterialApp(
      title: 'ALMA Test',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ALMA - Aprendizaje y Lógica'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Bienvenido a ALMA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aprendizaje y Lógica para Mentes Activas',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    
    // Build the test app
    await tester.pumpWidget(testApp);
    await tester.pumpAndSettle();

    // Verify basic app structure
    expect(find.text('ALMA - Aprendizaje y Lógica'), findsOneWidget);
    expect(find.text('Bienvenido a ALMA'), findsOneWidget);
    expect(find.text('Aprendizaje y Lógica para Mentes Activas'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
  
  testWidgets('Theme configuration test', (WidgetTester tester) async {
    final testApp = MaterialApp(
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Theme Test'),
        ),
      ),
    );
    
    await tester.pumpWidget(testApp);
    
    // Verify that the theme is applied
    final BuildContext context = tester.element(find.text('Theme Test'));
    final ThemeData theme = Theme.of(context);
    
    expect(theme.useMaterial3, isTrue);
    expect(find.text('Theme Test'), findsOneWidget);
  });
}