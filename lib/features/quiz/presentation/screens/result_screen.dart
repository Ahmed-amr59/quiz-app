import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/quiz_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../cubit/quiz_cubit.dart';
import '../screens/review_screen.dart';
import '../widgets/result_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  String _resultMessage(int percentage) {
    if (percentage >= 90)
      return 'Excellent work! Your knowledge is impressive.';
    if (percentage >= 70) return 'Great job! You are on the right track.';
    if (percentage >= 50) return 'Good try! Keep polishing your trivia skills.';
    return 'Keep learning and come back stronger next time.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final percent = state.totalQuestions == 0
            ? 0
            : ((state.score / state.totalQuestions) * 100).round();
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          context.read<QuizCubit>().restartQuiz();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: ResultCard(
                        key: ValueKey<int>(percent),
                        score: state.score,
                        total: state.totalQuestions,
                        message: _resultMessage(percent),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percent / 100),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 16,
                                    color: Color(0xff4caf50),
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$percent%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                      
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Quiz Complete',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    QuizButton(
                      label: 'Review Answers',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReviewScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    QuizButton(
                      label: 'Restart Quiz',
                      onPressed: () {
                        context.read<QuizCubit>().restartQuiz();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
