import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/responsive.dart';

/// Widget to display game score and level
class GameScoreDisplay extends StatelessWidget {
  final int score;
  final int level;
  final int correctAnswers;
  final int totalQuestions;

  const GameScoreDisplay({
    super.key,
    required this.score,
    required this.level,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.fontSize(context, 16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            icon: Icons.stars,
            label: AppStrings.score,
            value: score.toString(),
            color: Colors.amber,
            fontSize: fontSize,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            icon: Icons.trending_up,
            label: AppStrings.level,
            value: level.toString(),
            color: AppColors.primary,
            fontSize: fontSize,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Aciertos',
            value: '$correctAnswers/$totalQuestions',
            color: AppColors.success,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: fontSize * 1.5,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize * 0.75,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
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