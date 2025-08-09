import 'package:alma/features/color_game/presentation/widgets/color_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorDisplay Widget', () {
    testWidgets('displays the correct color', (WidgetTester tester) async {
      // arrange
      const testColor = Colors.red;

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorDisplay(color: testColor),
          ),
        ),
      );

      // assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(testColor));
    });

    testWidgets('displays palette icon', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorDisplay(color: Colors.green),
          ),
        ),
      );

      // assert
      expect(find.byIcon(Icons.palette), findsOneWidget);
    });

    testWidgets('has rounded corners and border', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorDisplay(color: Colors.purple),
          ),
        ),
      );

      // assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      expect(decoration.border?.top.width, equals(3));
      expect(decoration.border?.top.color, equals(Colors.white));
    });
  });
}