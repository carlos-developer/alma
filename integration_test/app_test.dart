import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:alma/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App should start without errors', (WidgetTester tester) async {
    // Start the app
    app.main();
    
    // Wait for app to settle
    await tester.pumpAndSettle();
    
    // Verify the app started successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}