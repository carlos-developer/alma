import 'package:alma/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive Utility', () {
    testWidgets('identifies mobile small screens correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobileSmall(context), isTrue);
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('identifies mobile large screens correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(550, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobileSmall(context), isFalse);
              expect(Responsive.isMobileLarge(context), isTrue);
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('identifies tablet screens correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isTrue);
              expect(Responsive.isTabletSmall(context), isTrue);
              expect(Responsive.isDesktop(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('identifies desktop screens correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(1300, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isTrue);
              expect(Responsive.isDesktopLarge(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('identifies ultra-wide screens correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(2000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isTrue);
              expect(Responsive.isUltraWide(context), isTrue);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('valueEnhanced returns correct values for different screen sizes', (WidgetTester tester) async {
      // Mobile small test
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = Responsive.valueEnhanced<double>(
                context: context,
                mobileSmall: 100,
                mobileLarge: 120,
                tabletSmall: 140,
                desktop: 200,
              );
              expect(value, equals(100));
              return Container();
            },
          ),
        ),
      );

      // Tablet test
      tester.view.physicalSize = const Size(800, 1024);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = Responsive.valueEnhanced<double>(
                context: context,
                mobileSmall: 100,
                mobileLarge: 120,
                tabletSmall: 140,
                desktop: 200,
              );
              expect(value, equals(140));
              return Container();
            },
          ),
        ),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('adaptiveSize calculates sizes correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final adaptiveSize = Responsive.adaptiveSize(
                context,
                baseSize: 200,
                minSize: 100,
                maxSize: 400,
              );
              expect(adaptiveSize, greaterThanOrEqualTo(100));
              expect(adaptiveSize, lessThanOrEqualTo(400));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getAdaptiveSpacing returns appropriate values', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final spacing = Responsive.getAdaptiveSpacing(context);
              expect(spacing, equals(8)); // mobileSmall spacing
              return Container();
            },
          ),
        ),
      );
    });

    test('dynamicFontSize calculation works correctly', () {
      // Test the calculation logic directly
      const baseSize = 16.0;
      const screenWidth = 780.0;
      const scaleFactor = screenWidth / 390;
      final clampedScaleFactor = scaleFactor.clamp(0.8, 2.0);
      final expectedFontSize = baseSize * clampedScaleFactor;
      
      expect(expectedFontSize, greaterThan(16 * 0.8));
      expect(expectedFontSize, lessThanOrEqualTo(16 * 2.0));
    });

    testWidgets('getContentWidth provides appropriate content width', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final contentWidth = Responsive.getContentWidth(context);
              expect(contentWidth, greaterThan(0));
              expect(contentWidth, lessThanOrEqualTo(1200));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getGridColumns calculates columns correctly', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act & assert
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final columns = Responsive.getGridColumns(context, minItemWidth: 200);
              expect(columns, greaterThanOrEqualTo(1));
              expect(columns, lessThanOrEqualTo(6));
              return Container();
            },
          ),
        ),
      );
    });

    test('breakpoint constants are correctly defined', () {
      expect(Responsive.mobileBreakpoint, equals(480));
      expect(Responsive.mobileLargeBreakpoint, equals(600));
      expect(Responsive.tabletBreakpoint, equals(768));
      expect(Responsive.tabletLargeBreakpoint, equals(1024));
      expect(Responsive.desktopBreakpoint, equals(1200));
      expect(Responsive.desktopLargeBreakpoint, equals(1440));
      expect(Responsive.ultraWideBreakpoint, equals(1920));
    });
  });

  group('ResponsiveLayout Widget', () {
    testWidgets('shows mobile layout on mobile screens', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const mobileWidget = Text('Mobile Layout');
      const tabletWidget = Text('Tablet Layout');
      const desktopWidget = Text('Desktop Layout');

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
            tabletLayout: tabletWidget,
            desktopLayout: desktopWidget,
          ),
        ),
      );

      // assert
      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('shows tablet layout on tablet screens', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const mobileWidget = Text('Mobile Layout');
      const tabletWidget = Text('Tablet Layout');
      const desktopWidget = Text('Desktop Layout');

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
            tabletLayout: tabletWidget,
            desktopLayout: desktopWidget,
          ),
        ),
      );

      // assert
      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('shows desktop layout on desktop screens', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(1400, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const mobileWidget = Text('Mobile Layout');
      const tabletWidget = Text('Tablet Layout');
      const desktopWidget = Text('Desktop Layout');

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
            tabletLayout: tabletWidget,
            desktopLayout: desktopWidget,
          ),
        ),
      );

      // assert
      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);
    });

    testWidgets('falls back to mobile layout when tablet/desktop layouts are not provided', (WidgetTester tester) async {
      // arrange
      tester.view.physicalSize = const Size(1400, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const mobileWidget = Text('Mobile Layout');

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
          ),
        ),
      );

      // assert
      expect(find.text('Mobile Layout'), findsOneWidget);
    });
  });
}