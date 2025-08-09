import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

/// Button widget for color options
class ColorOptionButton extends StatelessWidget {
  final String colorName;
  final VoidCallback onPressed;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isDisabled;

  const ColorOptionButton({
    super.key,
    required this.colorName,
    required this.onPressed,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = Responsive.value<double>(
      context: context,
      mobile: 140,
      tablet: 180,
      desktop: 200,
    );

    final buttonHeight = Responsive.value<double>(
      context: context,
      mobile: 60,
      tablet: 70,
      desktop: 80,
    );

    final fontSize = Responsive.fontSize(context, 18);

    Color backgroundColor = GameColors.getColor(colorName);
    Color borderColor = Colors.white;
    double borderWidth = 2;

    if (isCorrect) {
      borderColor = AppColors.success;
      borderWidth = 4;
    } else if (isIncorrect) {
      borderColor = AppColors.error;
      borderWidth = 4;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: isDisabled ? 0.5 : 1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: [
                if (!isDisabled)
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    colorName,
                    style: TextStyle(
                      color: _getTextColor(backgroundColor),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isCorrect)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                if (isIncorrect)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}