import 'package:alma/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:alma/main.dart';
import 'package:alma/core/utils/logger.dart';
import 'package:logger/logger.dart';

void main() {
  setUpAll(() async {
    // Initialize test environment
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize logger for tests
    AppLogger.init(level: Level.warning);
    
    // Initialize dependency injection
    await di.init();
  });

  testWidgets('App starts and shows color game', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const AlmaApp());
    await tester.pumpAndSettle();

    // Verify that the app starts with the color game page
    expect(find.text('Identifica el Color'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
    
    // Tap start button
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    
    // Verify game has started
    expect(find.text('¿Cuál es este color?'), findsOneWidget);
  });
}