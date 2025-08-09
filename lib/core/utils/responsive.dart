import 'package:flutter/material.dart';

/// Responsive utility for adaptive layouts
class Responsive {
  // Enhanced breakpoints for better responsivity
  static const double mobileBreakpoint = 480;
  static const double mobileLargeBreakpoint = 600;
  static const double tabletBreakpoint = 768;
  static const double tabletLargeBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double desktopLargeBreakpoint = 1440;
  static const double ultraWideBreakpoint = 1920;

  // Device type checks
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileLargeBreakpoint;
  }

  static bool isMobileSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileBreakpoint;
  }

  static bool isMobileLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < mobileLargeBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileLargeBreakpoint && width < desktopBreakpoint;
  }

  static bool isTabletSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileLargeBreakpoint && width < tabletLargeBreakpoint;
  }

  static bool isTabletLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletLargeBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint;
  }

  static bool isDesktopLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopLargeBreakpoint;
  }

  static bool isUltraWide(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ultraWideBreakpoint;
  }

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Enhanced value selector with more granular control
  static T valueEnhanced<T>({
    required BuildContext context,
    required T mobileSmall,
    T? mobileLarge,
    T? tabletSmall,
    T? tabletLarge,
    T? desktop,
    T? desktopLarge,
    T? ultraWide,
  }) {
    if (isUltraWide(context)) {
      return ultraWide ?? desktopLarge ?? desktop ?? tabletLarge ?? tabletSmall ?? mobileLarge ?? mobileSmall;
    } else if (isDesktopLarge(context)) {
      return desktopLarge ?? desktop ?? tabletLarge ?? tabletSmall ?? mobileLarge ?? mobileSmall;
    } else if (isDesktop(context)) {
      return desktop ?? tabletLarge ?? tabletSmall ?? mobileLarge ?? mobileSmall;
    } else if (isTabletLarge(context)) {
      return tabletLarge ?? tabletSmall ?? mobileLarge ?? mobileSmall;
    } else if (isTabletSmall(context)) {
      return tabletSmall ?? mobileLarge ?? mobileSmall;
    } else if (isMobileLarge(context)) {
      return mobileLarge ?? mobileSmall;
    } else {
      return mobileSmall;
    }
  }

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double blockSizeHorizontal(BuildContext context) =>
      screenWidth(context) / 100;

  static double blockSizeVertical(BuildContext context) =>
      screenHeight(context) / 100;

  static double fontSize(BuildContext context, double size) {
    return valueEnhanced<double>(
      context: context,
      mobileSmall: size * 0.9,
      mobileLarge: size,
      tabletSmall: size * 1.1,
      tabletLarge: size * 1.2,
      desktop: size * 1.3,
      desktopLarge: size * 1.4,
      ultraWide: size * 1.5,
    );
  }

  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      valueEnhanced<double>(
        context: context,
        mobileSmall: 12,
        mobileLarge: 16,
        tabletSmall: 20,
        tabletLarge: 24,
        desktop: 32,
        desktopLarge: 40,
        ultraWide: 48,
      ),
    );
  }

  static double cardWidth(BuildContext context) {
    return valueEnhanced<double>(
      context: context,
      mobileSmall: screenWidth(context) * 0.95,
      mobileLarge: screenWidth(context) * 0.9,
      tabletSmall: screenWidth(context) * 0.8,
      tabletLarge: screenWidth(context) * 0.7,
      desktop: 600,
      desktopLarge: 700,
      ultraWide: 800,
    );
  }

  /// Calculate the number of columns for grid layouts
  static int getGridColumns(BuildContext context, {double minItemWidth = 150}) {
    final width = screenWidth(context);
    final availableWidth = width - (padding(context).horizontal);
    final columns = (availableWidth / minItemWidth).floor();
    return columns.clamp(1, 6); // Max 6 columns
  }

  /// Get adaptive spacing between elements
  static double getAdaptiveSpacing(BuildContext context) {
    return valueEnhanced<double>(
      context: context,
      mobileSmall: 8,
      mobileLarge: 12,
      tabletSmall: 16,
      tabletLarge: 20,
      desktop: 24,
      desktopLarge: 28,
      ultraWide: 32,
    );
  }

  /// Calculate responsive size with min/max constraints
  static double adaptiveSize(BuildContext context, {
    required double baseSize,
    double minSize = 0,
    double? maxSize,
  }) {
    final width = screenWidth(context);
    final scaleFactor = (width / 390).clamp(0.7, 2.5); // More flexible scaling
    final calculatedSize = baseSize * scaleFactor;
    
    if (maxSize != null) {
      return calculatedSize.clamp(minSize, maxSize);
    }
    return calculatedSize.clamp(minSize, double.infinity);
  }

  /// Get the optimal content width for reading and interaction
  static double getContentWidth(BuildContext context) {
    final screenW = screenWidth(context);
    
    if (isMobile(context)) {
      return screenW * 0.95;
    } else if (isTablet(context)) {
      return (screenW * 0.8).clamp(400, 800);
    } else {
      return (screenW * 0.6).clamp(600, 1200);
    }
  }

  /// Dynamic font size based on screen width percentage
  static double dynamicFontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    final scaleFactor = (width / 390).clamp(0.8, 2.0); // 390 is baseline width
    return baseSize * scaleFactor;
  }

  /// Responsive margin based on screen size
  static EdgeInsets margin(BuildContext context, {double factor = 1.0}) {
    final basePadding = valueEnhanced<double>(
      context: context,
      mobileSmall: 8,
      mobileLarge: 12,
      tabletSmall: 16,
      tabletLarge: 20,
      desktop: 24,
      desktopLarge: 32,
      ultraWide: 40,
    );
    return EdgeInsets.all(basePadding * factor);
  }
}

/// Responsive layout helper for complex adaptive layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;
  final Widget Function(BuildContext, BoxConstraints)? builder;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return LayoutBuilder(builder: builder!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (Responsive.isDesktop(context)) {
          return desktopLayout ?? tabletLayout ?? mobileLayout;
        } else if (Responsive.isTablet(context)) {
          return tabletLayout ?? mobileLayout;
        } else {
          return mobileLayout;
        }
      },
    );
  }
}