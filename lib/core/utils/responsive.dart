import 'package:flutter/material.dart';

/// Responsive utility for adaptive layouts
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

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

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double blockSizeHorizontal(BuildContext context) =>
      screenWidth(context) / 100;

  static double blockSizeVertical(BuildContext context) =>
      screenHeight(context) / 100;

  static double fontSize(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 600) {
      return size;
    } else if (width < 1200) {
      return size * 1.2;
    } else {
      return size * 1.4;
    }
  }

  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value<double>(
        context: context,
        mobile: 16,
        tablet: 24,
        desktop: 32,
      ),
    );
  }

  static double cardWidth(BuildContext context) {
    return value<double>(
      context: context,
      mobile: screenWidth(context) * 0.9,
      tablet: screenWidth(context) * 0.7,
      desktop: 600,
    );
  }
}