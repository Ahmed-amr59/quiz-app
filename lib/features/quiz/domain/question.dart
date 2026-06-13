class Question {
  final int id;
  final String category;
  final String text;
  final List<String> answers;
  final int correctIndex;

  const Question({
    required this.id,
    required this.category,
    required this.text,
    required this.answers,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'text': text,
      'answers': answers.join('|'),
      'correctIndex': correctIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      category: map['category'] as String,
      text: map['text'] as String,
      answers: (map['answers'] as String).split('|'),
      correctIndex: map['correctIndex'] as int,
    );
  }
}
