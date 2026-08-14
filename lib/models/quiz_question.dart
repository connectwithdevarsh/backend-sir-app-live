/// QuizQuestion encapsulates a single AI-generated quiz question with 4 options, correct answer index, and explanation.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var rawOpts = json['options'] as List? ?? [];
    List<String> optList = rawOpts.map((e) => e.toString()).toList();

    return QuizQuestion(
      question: json['question'] ?? '',
      options: optList,
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
      };
}
