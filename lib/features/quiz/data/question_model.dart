import '../domain/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.category,
    required super.text,
    required super.answers,
    required super.correctIndex,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      category: map['category'] as String,
      text: map['text'] as String,
      answers: (map['answers'] as String).split('|'),
      correctIndex: map['correctIndex'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'text': text,
      'answers': answers.join('|'),
      'correctIndex': correctIndex,
    };
  }
}
