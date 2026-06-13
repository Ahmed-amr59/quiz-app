import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/question.dart';
import '../cubit/quiz_cubit.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final _categoryController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerControllers = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  int? _editingQuestionId;

  @override
  void dispose() {
    _categoryController.dispose();
    _questionController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitQuestion(QuizCubit cubit) {
    final category = _categoryController.text.trim();
    final questionText = _questionController.text.trim();
    final answers = _answerControllers.map((c) => c.text.trim()).toList();

    if (category.isEmpty ||
        questionText.isEmpty ||
        answers.any((text) => text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete every field.')),
      );
      return;
    }

    final question = Question(
      id: _editingQuestionId ?? DateTime.now().millisecondsSinceEpoch,
      category: category,
      text: questionText,
      answers: answers,
      correctIndex: _correctIndex,
    );

    if (_editingQuestionId != null) {
      cubit.updateQuestion(question);
    } else {
      cubit.addQuestion(question);
    }

    _clearForm();
  }

  void _clearForm() {
    _categoryController.clear();
    _questionController.clear();
    for (final controller in _answerControllers) {
      controller.clear();
    }
    setState(() {
      _correctIndex = 0;
      _editingQuestionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              color: Theme.of(context).colorScheme.onBackground,
                              onPressed: Navigator.of(context).pop,
                            ),
                            Text(
                              'Manage Questions',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 26),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Builder(
                          builder: (context) {
                            final questionGroups = <String, List<Question>>{};
                            for (final question in state.questionPool) {
                              final category = question.category.trim().isEmpty
                                  ? 'Uncategorized'
                                  : question.category.trim();
                              questionGroups
                                  .putIfAbsent(category, () => [])
                                  .add(question);
                            }
                            final categoryNames = questionGroups.keys.toList()
                              ..sort();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (categoryNames.isNotEmpty) ...[
                                  Text(
                                    'Categories',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: categoryNames.map((category) {
                                      return ActionChip(
                                        label: Text(category),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.14),
                                        labelStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        onPressed: () {
                                          setState(() {
                                            _categoryController.text = category;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                SizedBox(
                                  height: 300,
                                  child: categoryNames.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No questions available yet.',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: categoryNames.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 16),
                                          itemBuilder: (context, index) {
                                            final category =
                                                categoryNames[index];
                                            final questions =
                                                questionGroups[category]!;
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor.withOpacity(0.95),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .shadowColor
                                                        .withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ExpansionTile(
                                                key: ValueKey(category),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                tilePadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                childrenPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                collapsedBackgroundColor:
                                                    Theme.of(context).cardColor
                                                        .withOpacity(0.85),
                                                title: Text(
                                                  '$category (${questions.length})',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleSmall,
                                                ),
                                                children: questions.map((
                                                  question,
                                                ) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .cardColor
                                                          .withOpacity(0.95),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                question.text,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                'Answers: ${question.answers.length}',
                                                                style: Theme.of(
                                                                  context,
                                                                ).textTheme.bodySmall,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                              ),
                                                              color: Colors
                                                                  .blueAccent,
                                                              onPressed: () {
                                                                setState(() {
                                                                  _editingQuestionId =
                                                                      question
                                                                          .id;
                                                                  _categoryController
                                                                          .text =
                                                                      question
                                                                          .category;
                                                                  _questionController
                                                                          .text =
                                                                      question
                                                                          .text;
                                                                  for (
                                                                    var i = 0;
                                                                    i < 4;
                                                                    i++
                                                                  ) {
                                                                    _answerControllers[i]
                                                                            .text =
                                                                        question
                                                                            .answers[i];
                                                                  }
                                                                  _correctIndex =
                                                                      question
                                                                          .correctIndex;
                                                                });
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_forever,
                                                              ),
                                                              color: Colors
                                                                  .redAccent,
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                      QuizCubit
                                                                    >()
                                                                    .deleteQuestion(
                                                                      question
                                                                          .id,
                                                                    );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Add New Question',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            hintText: 'e.g. Science or العلوم',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _questionController,
                          decoration: const InputDecoration(
                            labelText: 'Question',
                            hintText: 'اكتب السؤال بالعربية أو بالإنجليزية',
                          ),
                          minLines: 2,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: _answerControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Answer ${index + 1}',
                                hintText: 'Answer بالعربية أو English',
                                suffixIcon: Radio<int>(
                                  value: index,
                                  groupValue: _correctIndex,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _correctIndex = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Text(
                          'Select the correct answer using the radio button.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _submitQuestion(context.read<QuizCubit>()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add Question',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
