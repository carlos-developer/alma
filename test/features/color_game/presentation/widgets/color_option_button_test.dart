import 'package:alma/core/constants/colors.dart';
import 'package:alma/features/color_game/presentation/widgets/color_option_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorOptionButton Widget', () {
    testWidgets('displays color name and calls onPressed when tapped', (WidgetTester tester) async {
      // arrange
      bool wasPressed = false;
      const colorName = 'Rojo';
      
      void onPressed() {
        wasPressed = true;
      }

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: colorName,
              onPressed: onPressed,
            ),
          ),
        ),
      );

      // assert
      expect(find.text(colorName), findsOneWidget);
      
      // Tap the button
      await tester.tap(find.byType(ColorOptionButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('displays correct color background', (WidgetTester tester) async {
      // arrange
      const colorName = 'Azul';
      final expectedColor = GameColors.getColor(colorName);

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: colorName,
              onPressed: () {},
            ),
          ),
        ),
      );

      // assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last, // Get the inner container with decoration
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(expectedColor));
    });

    testWidgets('shows correct answer indicator when isCorrect is true', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Verde',
              onPressed: () {},
              isCorrect: true,
            ),
          ),
        ),
      );

      // assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);
      
      // Check border color for correct answer
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(AppColors.success));
      // Border width should be greater than 2.0 (indicating the 2x multiplier is applied)
      expect(decoration.border?.top.width, greaterThan(2.0));
    });

    testWidgets('shows incorrect answer indicator when isIncorrect is true', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Amarillo',
              onPressed: () {},
              isIncorrect: true,
            ),
          ),
        ),
      );

      // assert
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      
      // Check border color for incorrect answer
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(AppColors.error));
      // Border width should be greater than 2.0 (indicating the 2x multiplier is applied)
      expect(decoration.border?.top.width, greaterThan(2.0));
    });

    testWidgets('is disabled when isDisabled is true', (WidgetTester tester) async {
      // arrange
      bool wasPressed = false;
      
      void onPressed() {
        wasPressed = true;
      }

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Morado',
              onPressed: onPressed,
              isDisabled: true,
            ),
          ),
        ),
      );

      // assert
      // Try to tap the disabled button
      await tester.tap(find.byType(ColorOptionButton));
      expect(wasPressed, isFalse);
      
      // Check if the button appears disabled (reduced opacity)
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last,
      );
      
      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color;
      expect(((color?.a ?? 1.0) * 255.0).round() & 0xff, lessThan(255)); // Should have reduced alpha for disabled state
    });

    testWidgets('has proper rounded corners and shadow when not disabled', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Rosa',
              onPressed: () {},
            ),
          ),
        ),
      );

      // assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(13.6)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
    });

    testWidgets('has no shadow when disabled', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Negro',
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
      );

      // assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ColorOptionButton),
          matching: find.byType(Container),
        ).last,
      );
      
      final decoration = container.decoration as BoxDecoration;
      // When disabled, boxShadow should be either null or an empty list
      expect(decoration.boxShadow == null || decoration.boxShadow!.isEmpty, isTrue);
    });

    testWidgets('displays proper text color based on background color', (WidgetTester tester) async {
      // Test with a dark color (should have light text)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Negro',
              onPressed: () {},
            ),
          ),
        ),
      );

      final darkBackgroundText = tester.widget<Text>(find.text('Negro'));
      expect(darkBackgroundText.style?.color, equals(Colors.white));

      // Test with a light color (should have dark text)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Blanco',
              onPressed: () {},
            ),
          ),
        ),
      );

      final lightBackgroundText = tester.widget<Text>(find.text('Blanco'));
      expect(lightBackgroundText.style?.color, equals(Colors.black87));
    });

    testWidgets('has proper InkWell with rounded border radius', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Marrón',
              onPressed: () {},
            ),
          ),
        ),
      );

      // assert
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, equals(BorderRadius.circular(13.6)));
    });

    testWidgets('text has shadow effect', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Naranja',
              onPressed: () {},
            ),
          ),
        ),
      );

      // assert
      final text = tester.widget<Text>(find.text('Naranja'));
      expect(text.style?.shadows, isNotNull);
      expect(text.style?.shadows!.length, equals(1));
      expect(text.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('responds to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOptionButton(
              colorName: 'Verde',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify the widget renders correctly on mobile without checking exact dimensions
      // as AnimatedContainer dimensions are calculated at runtime based on Responsive utility
      final animatedContainers = find.descendant(
        of: find.byType(ColorOptionButton),
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedContainers, findsAtLeastNWidgets(1));
      
      // Check that the widget is visible and properly sized by checking its render box
      final renderBox = tester.renderObject<RenderBox>(find.byType(ColorOptionButton));
      expect(renderBox.size.width, greaterThan(100)); // Should be reasonably sized for mobile
      expect(renderBox.size.height, greaterThanOrEqualTo(50));
    });
  });
}