import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/answer_card.dart';
import '../../../../core/widgets/progress_widget.dart';
import '../../../../core/widgets/quiz_button.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/question.dart';
import '../cubit/quiz_cubit.dart';
import 'manage_questions_screen.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: BlocConsumer<QuizCubit, QuizState>(
              listener: (context, state) {
                if (state.completed) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 700),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FadeTransition(
                          opacity: animation,
                          child: const ResultScreen(),
                        );
                      },
                    ),
                  );
                }
              },
              builder: (context, state) {
                final question = state.currentQuestion;

                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (question == null) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No questions available yet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        QuizButton(
                          label: 'Manage Questions',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ManageQuestionsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _QuizHeader(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.manage_search),
                              color: Theme.of(context).colorScheme.onBackground,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ManageQuestionsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            const ThemeToggleButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ProgressWidget(
                      current: state.totalQuestions == 0
                          ? 0
                          : state.currentIndex + 1,
                      total: state.totalQuestions,
                      progress: state.progress,
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _QuestionPanel(
                          state: state,
                          question: question,
                          key: ValueKey<int>(state.currentIndex),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: QuizButton(
                            label: 'Previous',
                            enabled:
                                state.currentIndex > 0 &&
                                state.totalQuestions > 0,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF0EA5E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onPressed: () =>
                                context.read<QuizCubit>().previousQuestion(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: QuizButton(
                            label:
                                state.currentIndex == state.totalQuestions - 1
                                ? 'Finish'
                                : AppStrings.nextButton,
                            enabled: state.answered && state.totalQuestions > 0,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onPressed: () =>
                                context.read<QuizCubit>().nextQuestion(),
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
      ),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Image.asset("assets/icons/app1.png", width: 50, height: 50),
              Text(
                AppStrings.appTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 32),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            AppStrings.quizSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  final QuizState state;
  final Question question;

  const _QuestionPanel({
    super.key,
    required this.state,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.category.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            question.text,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 22, height: 1.35),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: question.answers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final selected = state.selectedAnswer == index;
                return AnswerCard(
                  answer: question.answers[index],
                  selected: selected,
                  showResult: false,
                  isCorrect: index == question.correctIndex,
                  onTap: () => context.read<QuizCubit>().selectAnswer(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
