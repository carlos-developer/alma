import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

/// Widget that displays the color to be identified
class ColorDisplay extends StatelessWidget {
  final Color color;
  final double? size;

  const ColorDisplay({
    super.key,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final displaySize = size ?? Responsive.value<double>(
      context: context,
      mobile: 200,
      tablet: 250,
      desktop: 300,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: displaySize,
      height: displaySize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.palette,
          size: displaySize * 0.3,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}