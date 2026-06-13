import '../domain/question.dart';
import 'question_model.dart';
import 'database_helper.dart';
import 'quiz_data.dart';

class QuestionRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<QuestionModel>> getQuestions() async {
    final rows = await _dbHelper.queryAll(DatabaseHelper.tableQuestions);
    return rows
        .map((row) => QuestionModel.fromMap(row))
        .toList(growable: false);
  }

  Future<void> seedDefaultQuestions() async {
    for (final question in QuizData.questions) {
      await _dbHelper.insert(DatabaseHelper.tableQuestions, question.toMap());
    }
  }

  Future<void> createQuestion(Question question) async {
    await _dbHelper.insert(DatabaseHelper.tableQuestions, question.toMap());
  }

  Future<int> updateQuestion(Question question) async {
    return await _dbHelper.update(
      DatabaseHelper.tableQuestions,
      question.toMap(),
      'id = ?',
      [question.id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    return await _dbHelper.delete(DatabaseHelper.tableQuestions, 'id = ?', [
      id,
    ]);
  }
}
