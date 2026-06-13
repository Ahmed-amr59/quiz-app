import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/question.dart';
import '../../data/question_repository.dart';

class QuizState {
  static const _undefined = Object();

  final List<Question> questionPool;
  final List<Question> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final int score;
  final bool completed;
  final bool answered;
  final Map<int, int> userAnswers;
  final bool loading;

  const QuizState({
    required this.questionPool,
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswer,
    required this.score,
    required this.completed,
    required this.answered,
    required this.userAnswers,
    required this.loading,
  });

  int get totalQuestions => questions.length;

  double get progress =>
      totalQuestions == 0 ? 0 : (currentIndex + 1) / totalQuestions;

  Question? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  QuizState copyWith({
    List<Question>? questionPool,
    List<Question>? questions,
    int? currentIndex,
    Object? selectedAnswer = _undefined,
    int? score,
    bool? completed,
    bool? answered,
    Map<int, int>? userAnswers,
    bool? loading,
  }) {
    return QuizState(
      questionPool: questionPool ?? this.questionPool,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer == _undefined
          ? this.selectedAnswer
          : selectedAnswer as int?,
      score: score ?? this.score,
      completed: completed ?? this.completed,
      answered: answered ?? this.answered,
      userAnswers: userAnswers ?? this.userAnswers,
      loading: loading ?? this.loading,
    );
  }
}

class QuizCubit extends Cubit<QuizState> {
  final QuestionRepository repository;
  final Random _random = Random();

  QuizCubit({required this.repository})
    : super(
        QuizState(
          questionPool: const [],
          questions: const [],
          currentIndex: 0,
          selectedAnswer: null,
          score: 0,
          completed: false,
          answered: false,
          userAnswers: const {},
          loading: true,
        ),
      ) {
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    emit(state.copyWith(loading: true));
    try {
      var pool = await repository.getQuestions();
      if (pool.isEmpty) {
        await repository.seedDefaultQuestions();
        pool = await repository.getQuestions();
      }
      emit(
        state.copyWith(
          questionPool: pool,
          questions: _sampleQuestions(pool),
          currentIndex: 0,
          selectedAnswer: null,
          answered: false,
          userAnswers: {},
          score: 0,
          completed: false,
          loading: false,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('QuizCubit failed to load questions: $error');
      debugPrint(stackTrace.toString());
      emit(
        state.copyWith(
          questionPool: const [],
          questions: const [],
          currentIndex: 0,
          selectedAnswer: null,
          answered: false,
          userAnswers: const {},
          score: 0,
          completed: false,
          loading: false,
        ),
      );
    }
  }

  List<Question> _sampleQuestions(List<Question> pool) {
    if (pool.length <= 10) return List<Question>.from(pool);
    final shuffled = List<Question>.from(pool);
    shuffled.shuffle(_random);
    return shuffled.take(10).toList(growable: false);
  }

  Future<void> refreshQuestions() async {
    await _refreshQuestions();
  }

  void selectAnswer(int index) {
    final question = state.currentQuestion;
    if (question == null || state.completed) return;

    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[question.id] = index;

    emit(
      state.copyWith(
        selectedAnswer: index,
        userAnswers: updatedAnswers,
        answered: true,
      ),
    );
  }

  int calculateFinalScore() {
    return state.questions.fold(0, (score, question) {
      final selected = state.userAnswers[question.id];
      if (selected == null) return score;
      return score + (selected == question.correctIndex ? 1 : 0);
    });
  }

  void nextQuestion() {
    if (!state.answered) return;

    final isLast = state.currentIndex == state.totalQuestions - 1;
    if (isLast) {
      finishQuiz();
      return;
    }

    final nextIndex = state.currentIndex + 1;
    final nextQuestion = state.questions[nextIndex];
    final nextSelected = state.userAnswers[nextQuestion.id];

    emit(
      state.copyWith(
        currentIndex: nextIndex,
        selectedAnswer: nextSelected,
        answered: nextSelected != null,
      ),
    );
  }

  void previousQuestion() {
    if (state.currentIndex == 0) return;
    final previousIndex = state.currentIndex - 1;
    final previousQuestion = state.questions[previousIndex];
    final previousSelected = state.userAnswers[previousQuestion.id];

    emit(
      state.copyWith(
        currentIndex: previousIndex,
        selectedAnswer: previousSelected,
        answered: previousSelected != null,
      ),
    );
  }

  void finishQuiz() {
    if (!state.answered) return;
    emit(state.copyWith(score: calculateFinalScore(), completed: true));
  }

  Future<void> addQuestion(Question question) async {
    await repository.createQuestion(question);
    await _refreshQuestions();
  }

  Future<void> updateQuestion(Question question) async {
    await repository.updateQuestion(question);
    await _refreshQuestions();
  }

  Future<void> deleteQuestion(int questionId) async {
    await repository.deleteQuestion(questionId);
    await _refreshQuestions();
  }

  Future<void> _refreshQuestions() async {
    emit(state.copyWith(loading: true));
    try {
      final fullPool = await repository.getQuestions();
      final sampledQuestions = _sampleQuestions(fullPool);
      final existingAnswers = Map<int, int>.fromEntries(
        state.userAnswers.entries.where(
          (entry) => fullPool.any((question) => question.id == entry.key),
        ),
      );
      final nextIndex = sampledQuestions.isEmpty
          ? 0
          : state.currentIndex.clamp(0, sampledQuestions.length - 1);
      final nextQuestion = sampledQuestions.isEmpty
          ? null
          : sampledQuestions[nextIndex];
      final selectedAnswer = nextQuestion == null
          ? null
          : existingAnswers[nextQuestion.id];

      emit(
        state.copyWith(
          questionPool: fullPool,
          questions: sampledQuestions,
          currentIndex: nextIndex,
          selectedAnswer: selectedAnswer,
          answered: selectedAnswer != null,
          userAnswers: existingAnswers,
          loading: false,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('QuizCubit failed to refresh questions: $error');
      debugPrint(stackTrace.toString());
      emit(
        state.copyWith(
          questionPool: const [],
          questions: const [],
          currentIndex: 0,
          selectedAnswer: null,
          answered: false,
          userAnswers: const {},
          score: 0,
          completed: false,
          loading: false,
        ),
      );
    }
  }

  void restartQuiz() {
    emit(
      state.copyWith(
        currentIndex: 0,
        selectedAnswer: null,
        score: 0,
        completed: false,
        answered: false,
        userAnswers: {},
      ),
    );
  }
}
