import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/responsive.dart';

/// Responsive widget to display game score and level
class GameScoreDisplay extends StatelessWidget {
  final int score;
  final int level;
  final int correctAnswers;
  final int totalQuestions;
  final bool isCompact;
  final Axis direction;

  const GameScoreDisplay({
    super.key,
    required this.score,
    required this.level,
    required this.correctAnswers,
    required this.totalQuestions,
    this.isCompact = false,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildAdaptiveScoreDisplay(context, constraints);
      },
    );
  }

  Widget _buildAdaptiveScoreDisplay(BuildContext context, BoxConstraints constraints) {
    final fontSize = Responsive.dynamicFontSize(context, 15);
    final spacing = Responsive.getAdaptiveSpacing(context);
    final padding = Responsive.margin(context, factor: 0.8);
    final borderRadius = Responsive.adaptiveSize(context, baseSize: 20, minSize: 15, maxSize: 25);
    
    // Determine layout based on available space and screen type
    final shouldUseVerticalLayout = _shouldUseVerticalLayout(context, constraints);
    final shouldUseCompactLayout = _shouldUseCompactLayout(context, constraints);
    
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: padding.horizontal / 2,
          vertical: padding.vertical / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: borderRadius * 0.4,
              offset: Offset(0, borderRadius * 0.15),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: shouldUseVerticalLayout
            ? _buildVerticalLayout(fontSize, spacing, shouldUseCompactLayout)
            : _buildHorizontalLayout(fontSize, spacing, shouldUseCompactLayout),
      ),
    );
  }

  bool _shouldUseVerticalLayout(BuildContext context, BoxConstraints constraints) {
    if (direction == Axis.vertical) return true;
    if (Responsive.isMobileSmall(context)) return true;
    if (constraints.maxWidth < 280) return true;
    return false;
  }

  bool _shouldUseCompactLayout(BuildContext context, BoxConstraints constraints) {
    if (isCompact) return true;
    if (Responsive.isMobileSmall(context)) return true;
    if (constraints.maxWidth < 220) return true;
    return false;
  }

  Widget _buildHorizontalLayout(double fontSize, double spacing, bool compact) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: spacing * 0.5,
      children: [
        _buildStatItem(
          icon: Icons.stars,
          label: AppStrings.score,
          value: score.toString(),
          color: Colors.amber,
          fontSize: fontSize,
          isCompact: compact,
        ),
        _buildStatItem(
          icon: Icons.trending_up,
          label: AppStrings.level,
          value: level.toString(),
          color: AppColors.primary,
          fontSize: fontSize,
          isCompact: compact,
        ),
        _buildStatItem(
          icon: Icons.check_circle,
          label: 'Aciertos',
          value: '$correctAnswers/$totalQuestions',
          color: AppColors.success,
          fontSize: fontSize,
          isCompact: compact,
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(double fontSize, double spacing, bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatItem(
          icon: Icons.stars,
          label: AppStrings.score,
          value: score.toString(),
          color: Colors.amber,
          fontSize: fontSize,
          isCompact: compact,
        ),
        SizedBox(height: spacing * 0.8),
        _buildStatItem(
          icon: Icons.trending_up,
          label: AppStrings.level,
          value: level.toString(),
          color: AppColors.primary,
          fontSize: fontSize,
          isCompact: compact,
        ),
        SizedBox(height: spacing * 0.8),
        _buildStatItem(
          icon: Icons.check_circle,
          label: 'Aciertos',
          value: '$correctAnswers/$totalQuestions',
          color: AppColors.success,
          fontSize: fontSize,
          isCompact: compact,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double fontSize,
    bool isCompact = false,
  }) {
    final iconSize = fontSize * (isCompact ? 1.2 : 1.5);
    final labelSize = fontSize * (isCompact ? 0.65 : 0.75);
    final valueSize = fontSize * (isCompact ? 0.85 : 1.0);
    final spacing = isCompact ? 6.0 : 8.0;
    
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: iconSize,
          ),
          SizedBox(width: spacing * 0.5),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        SizedBox(width: spacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}