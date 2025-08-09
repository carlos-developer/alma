import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

/// Adaptive button widget for color options with responsive sizing
class ColorOptionButton extends StatelessWidget {
  final String colorName;
  final VoidCallback onPressed;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isDisabled;
  final double? width;
  final double? height;
  final double? minWidth;
  final double? maxWidth;

  const ColorOptionButton({
    super.key,
    required this.colorName,
    required this.onPressed,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = _calculateAdaptiveDimensions(context, constraints);
        return _buildAdaptiveButton(context, dimensions);
      },
    );
  }

  _ButtonDimensions _calculateAdaptiveDimensions(BuildContext context, BoxConstraints constraints) {
    // Calculate base dimensions using enhanced responsive system
    final baseWidth = width ?? Responsive.valueEnhanced<double>(
      context: context,
      mobileSmall: 130,
      mobileLarge: 150,
      tabletSmall: 170,
      tabletLarge: 190,
      desktop: 200,
      desktopLarge: 220,
      ultraWide: 240,
    );

    final baseHeight = height ?? Responsive.valueEnhanced<double>(
      context: context,
      mobileSmall: 50,
      mobileLarge: 60,
      tabletSmall: 65,
      tabletLarge: 70,
      desktop: 75,
      desktopLarge: 80,
      ultraWide: 85,
    );

    // Adapt to available space
    final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : baseWidth;
    final adaptiveWidth = (availableWidth * 0.9).clamp(
      minWidth ?? 100,
      maxWidth ?? baseWidth * 1.2,
    );

    final finalWidth = [baseWidth, adaptiveWidth].reduce((a, b) => a < b ? a : b).toDouble();
    
    final fontSize = Responsive.dynamicFontSize(context, 16).clamp(12.0, 24.0);
    final borderRadius = finalWidth * 0.08;
    final borderWidth = finalWidth * 0.015;
    final iconSize = finalWidth * 0.12;
    
    return _ButtonDimensions(
      width: finalWidth,
      height: baseHeight,
      fontSize: fontSize,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      iconSize: iconSize,
    );
  }

  Widget _buildAdaptiveButton(BuildContext context, _ButtonDimensions dimensions) {
    final backgroundColor = GameColors.getColor(colorName);
    final borderColor = _getBorderColor();
    final borderWidth = isCorrect || isIncorrect ? dimensions.borderWidth * 2 : dimensions.borderWidth;
    
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: dimensions.width,
        height: dimensions.height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(
                  alpha: isDisabled ? 0.6 : 1.0,
                ),
                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: _buildShadows(backgroundColor, dimensions),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      colorName,
                      style: TextStyle(
                        color: _getTextColor(backgroundColor),
                        fontSize: dimensions.fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1.5,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCorrect)
                    Positioned(
                      top: dimensions.height * 0.1,
                      right: dimensions.width * 0.08,
                      child: AnimatedScale(
                        scale: isCorrect ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: dimensions.iconSize,
                        ),
                      ),
                    ),
                  if (isIncorrect)
                    Positioned(
                      top: dimensions.height * 0.1,
                      right: dimensions.width * 0.08,
                      child: AnimatedScale(
                        scale: isIncorrect ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.cancel,
                          color: AppColors.error,
                          size: dimensions.iconSize,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (isCorrect) return AppColors.success;
    if (isIncorrect) return AppColors.error;
    return Colors.white;
  }

  List<BoxShadow> _buildShadows(Color backgroundColor, _ButtonDimensions dimensions) {
    if (isDisabled) return [];
    
    return [
      BoxShadow(
        color: backgroundColor.withValues(alpha: 0.3),
        blurRadius: dimensions.width * 0.04,
        offset: Offset(0, dimensions.height * 0.06),
      ),
      if (isCorrect)
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.3),
          blurRadius: dimensions.width * 0.06,
          offset: Offset(0, dimensions.height * 0.04),
        ),
      if (isIncorrect)
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.3),
          blurRadius: dimensions.width * 0.06,
          offset: Offset(0, dimensions.height * 0.04),
        ),
    ];
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Helper class to store button dimensions for responsive calculations
class _ButtonDimensions {
  final double width;
  final double height;
  final double fontSize;
  final double borderRadius;
  final double borderWidth;
  final double iconSize;

  const _ButtonDimensions({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.borderRadius,
    required this.borderWidth,
    required this.iconSize,
  });
}