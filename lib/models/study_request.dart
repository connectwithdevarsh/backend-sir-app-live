/// StudyRequest encapsulates payload parameters for Practical 12 AI Study Assistant tasks.
class StudyRequest {
  final String taskType; // "explain", "summary", "quiz", "study_plan", "flashcards"
  final String subject;
  final String topic;
  final String content;
  final String level;
  final String style;
  final bool includeExample;
  final String summaryLength;
  final String summaryStyle;
  final int questionCount;
  final String difficulty;
  final String questionType;
  final List<String> subjects;
  final int days;
  final double hoursPerDay;
  final String examDate;
  final String priority;
  final int cardCount;
  final String prompt;

  StudyRequest({
    required this.taskType,
    this.subject = 'Artificial Intelligence',
    this.topic = 'Machine Learning',
    this.content = '',
    this.level = 'Beginner',
    this.style = 'Simple',
    this.includeExample = true,
    this.summaryLength = 'Medium',
    this.summaryStyle = 'Bullet Points',
    this.questionCount = 5,
    this.difficulty = 'Medium',
    this.questionType = 'MCQ',
    this.subjects = const ['AIPE', 'Python', 'JavaScript'],
    this.days = 7,
    this.hoursPerDay = 2.0,
    this.examDate = '',
    this.priority = 'Balanced',
    this.cardCount = 5,
    this.prompt = '',
  });

  Map<String, dynamic> toJson() => {
        'taskType': taskType,
        'subject': subject,
        'topic': topic,
        'content': content,
        'level': level,
        'style': style,
        'includeExample': includeExample,
        'summaryLength': summaryLength,
        'summaryStyle': summaryStyle,
        'questionCount': questionCount,
        'difficulty': difficulty,
        'questionType': questionType,
        'subjects': subjects,
        'days': days,
        'hoursPerDay': hoursPerDay,
        'examDate': examDate,
        'priority': priority,
        'cardCount': cardCount,
        'prompt': prompt,
      };
}
