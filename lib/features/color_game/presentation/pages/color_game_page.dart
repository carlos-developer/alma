import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/color_game_bloc.dart';
import '../bloc/color_game_event.dart';
import '../bloc/color_game_state.dart';
import '../widgets/color_display.dart';
import '../widgets/color_option_button.dart';
import '../widgets/game_score_display.dart';

/// Main page for the color identification game
class ColorGamePage extends StatelessWidget {
  const ColorGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ColorGameBloc, ColorGameState>(
          listener: (context, state) {
            // Handle error states with snackbar
            if (state is ColorGameError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorGameState state) {
    if (state is ColorGameInitial) {
      return _buildStartScreen(context);
    } else if (state is ColorGameLoading) {
      return _buildLoadingScreen(context);
    } else if (state is ColorGameReady ||
        state is ColorGameCorrectAnswer ||
        state is ColorGameIncorrectAnswer) {
      return _buildGameScreen(context, state);
    } else if (state is ColorGameTransitioning) {
      return _buildTransitionScreen(context, state);
    } else if (state is ColorGameEnded) {
      return _buildEndScreen(context, state);
    } else if (state is ColorGameError) {
      return _buildErrorScreen(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildStartScreen(BuildContext context) {
    final fontSize = Responsive.fontSize(context, 20);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette,
            size: Responsive.value<double>(
              context: context,
              mobile: 100,
              tablet: 120,
              desktop: 150,
            ),
            color: AppColors.primary,
          ),
          const SizedBox(height: 30),
          Text(
            AppStrings.colorGameTitle,
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aprende a identificar los colores',
            style: TextStyle(
              fontSize: fontSize * 0.9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ColorGameBloc>().add(const StartGameEvent());
            },
            icon: const Icon(Icons.play_arrow, size: 28),
            label: Text(
              AppStrings.start,
              style: TextStyle(fontSize: fontSize),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 20),
          Text(
            AppStrings.loading,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, ColorGameState state) {
    final session = state is ColorGameReady
        ? state.session
        : state is ColorGameCorrectAnswer
            ? state.session
            : (state as ColorGameIncorrectAnswer).session;

    final question = state is ColorGameReady
        ? state.currentQuestion
        : state is ColorGameCorrectAnswer
            ? state.currentQuestion
            : (state as ColorGameIncorrectAnswer).currentQuestion;

    final isCorrectState = state is ColorGameCorrectAnswer;
    final isIncorrectState = state is ColorGameIncorrectAnswer;
    final selectedAnswer =
        isIncorrectState ? state.selectedAnswer : '';

    final fontSize = Responsive.fontSize(context, 18);

    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        children: [
          // Score display
          GameScoreDisplay(
            score: session.score,
            level: session.currentLevel,
            correctAnswers: session.correctAnswers,
            totalQuestions: session.totalQuestions,
          ),
          const Spacer(),
          // Question text
          Text(
            AppStrings.colorGameInstruction,
            style: TextStyle(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 30),
          // Color display
          ColorDisplay(color: question.correctColor),
          const SizedBox(height: 40),
          // Feedback message
          if (isCorrectState)
            _buildFeedbackMessage(
              AppStrings.correctAnswer,
              AppColors.success,
              Icons.check_circle,
              fontSize,
            ),
          if (isIncorrectState)
            _buildFeedbackMessage(
              AppStrings.incorrectAnswer,
              AppColors.error,
              Icons.cancel,
              fontSize,
            ),
          const SizedBox(height: 20),
          // Option buttons
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: question.options.map((colorName) {
              final isCorrect = isCorrectState && 
                  colorName == question.correctColorName;
              final isIncorrect = isIncorrectState && 
                  colorName == selectedAnswer;
              
              return ColorOptionButton(
                colorName: colorName,
                isCorrect: isCorrect,
                isIncorrect: isIncorrect,
                isDisabled: isCorrectState || isIncorrectState,
                onPressed: () {
                  if (!isCorrectState && !isIncorrectState) {
                    context.read<ColorGameBloc>().add(
                          AnswerSelectedEvent(selectedColor: colorName),
                        );
                  }
                },
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage(
    String message,
    Color color,
    IconData icon,
    double fontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionScreen(BuildContext context, ColorGameTransitioning state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.nextColor,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen(BuildContext context, ColorGameEnded state) {
    final fontSize = Responsive.fontSize(context, 20);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.cardWidth(context),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.amber[700],
            ),
            const SizedBox(height: 20),
            Text(
              '¡Juego Terminado!',
              style: TextStyle(
                fontSize: fontSize * 1.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30),
            _buildStatCard('Puntaje Final', state.session.score.toString(), fontSize),
            const SizedBox(height: 15),
            _buildStatCard('Nivel Alcanzado', state.session.currentLevel.toString(), fontSize),
            const SizedBox(height: 15),
            _buildStatCard(
              'Precisión',
              '${state.session.accuracy.toStringAsFixed(1)}%',
              fontSize,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              'Respuestas Correctas',
              '${state.session.correctAnswers}/${state.session.totalQuestions}',
              fontSize,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ColorGameBloc>().add(const ResetGameEvent());
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Jugar de Nuevo',
                style: TextStyle(fontSize: fontSize * 0.9),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, double fontSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize * 0.8,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, ColorGameError state) {
    final fontSize = Responsive.fontSize(context, 18);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.generalError,
              style: TextStyle(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.message,
              style: TextStyle(
                fontSize: fontSize * 0.9,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ColorGameBloc>().add(const ResetGameEvent());
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                AppStrings.tryAgain,
                style: TextStyle(fontSize: fontSize),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}