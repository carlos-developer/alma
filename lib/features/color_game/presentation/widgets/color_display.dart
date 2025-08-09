import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

/// Widget that displays the color to be identified with adaptive sizing
class ColorDisplay extends StatelessWidget {
  final Color color;
  final double? size;
  final double? maxSize;
  final double? minSize;

  const ColorDisplay({
    super.key,
    required this.color,
    this.size,
    this.maxSize,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displaySize = _calculateAdaptiveSize(context, constraints);
        final borderRadius = displaySize * 0.08; // Proportional border radius
        final shadowBlur = displaySize * 0.05; // Proportional shadow
        final borderWidth = displaySize * 0.015; // Proportional border
        final iconSize = displaySize * 0.28; // Proportional icon

        return RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: displaySize,
            height: displaySize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowBlur * 0.4),
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: shadowBlur * 0.8,
                  offset: Offset(0, shadowBlur * 0.2),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: borderWidth,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.palette,
                size: iconSize,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateAdaptiveSize(BuildContext context, BoxConstraints constraints) {
    // If size is explicitly provided, use it with constraints
    if (size != null) {
      final constrainedSize = size!.clamp(
        minSize ?? 100,
        maxSize ?? double.infinity,
      );
      return constrainedSize.clamp(100.0, _getMaxAvailableSize(constraints)).toDouble();
    }

    // Calculate base size using enhanced responsive system - TRIPLED SIZES
    final baseSize = Responsive.valueEnhanced<double>(
      context: context,
      mobileSmall: 540,    // 180 * 3
      mobileLarge: 660,    // 220 * 3
      tabletSmall: 840,    // 280 * 3
      tabletLarge: 960,    // 320 * 3
      desktop: 1080,       // 360 * 3
      desktopLarge: 1200,  // 400 * 3
      ultraWide: 1350,     // 450 * 3
    );

    // Adaptive sizing based on available space
    final availableSize = _getMaxAvailableSize(constraints);
    final adaptiveSize = (availableSize * 0.85).clamp(  // Increased from 0.7 to 0.85 for larger display
      minSize ?? 450,  // Tripled from 150
      maxSize ?? baseSize * 1.2,
    );

    // Use the smaller of base size or adaptive size
    final finalSize = [baseSize, adaptiveSize].reduce((a, b) => a < b ? a : b);

    return finalSize.clamp(
      minSize ?? 360.0,   // Tripled from 120
      maxSize ?? 1500.0,  // Tripled from 500
    ).toDouble();
  }

  double _getMaxAvailableSize(BoxConstraints constraints) {
    // Calculate maximum size based on available space
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;
    
    // Use 85% of the smaller dimension to ensure the circle fits well (increased for larger display)
    final maxDimension = [availableWidth, availableHeight]
        .where((d) => d.isFinite)
        .fold(1200.0, (prev, curr) => prev < curr ? prev : curr);  // Tripled from 400
    
    return (maxDimension * 0.85).toDouble();  // Increased from 0.7 to 0.85
  }
}

/// Enhanced ColorDisplay with additional customization options
class EnhancedColorDisplay extends StatelessWidget {
  final Color color;
  final double? size;
  final String? label;
  final bool showBorder;
  final bool showShadow;
  final VoidCallback? onTap;
  final double aspectRatio;

  const EnhancedColorDisplay({
    super.key,
    required this.color,
    this.size,
    this.label,
    this.showBorder = true,
    this.showShadow = true,
    this.onTap,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayWidth = size ?? 
          Responsive.adaptiveSize(
            context,
            baseSize: 750,   // Tripled from 250
            minSize: 450,    // Tripled from 150
            maxSize: 1200,   // Tripled from 400
          );
        final displayHeight = displayWidth / aspectRatio;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(displayWidth * 0.08),
            child: Container(
              width: displayWidth,
              height: displayHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(displayWidth * 0.08),
                boxShadow: showShadow ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: displayWidth * 0.04,
                    offset: Offset(0, displayWidth * 0.02),
                  ),
                ] : null,
                border: showBorder ? Border.all(
                  color: Colors.white,
                  width: displayWidth * 0.012,
                ) : null,
              ),
              child: label != null
                ? Center(
                    child: Text(
                      label!,
                      style: TextStyle(
                        color: _getContrastColor(color),
                        fontSize: displayWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            ),
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}