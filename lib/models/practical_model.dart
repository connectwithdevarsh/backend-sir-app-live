/// PracticalModel defines the structure for an AIPE practical experiment.
class PracticalModel {
  final int id;
  final String number; // e.g. "01"
  final String displayTitle; // e.g. "01 — Generative AI Tools"
  final String officialOutcome; // Official GTU syllabus outcome statement
  final String aim; // Clear educational objective
  final String category; // Filter category: AI Tools, NLP, LLM, Prompt Engineering, AI Applications
  final String taskDescription; // Explanation of what the student experiments with
  final String demoPromptOrCode; // Monospace prompt or Python demonstration code
  final String demoOutput; // Predefined execution output for local demonstration
  final bool isPythonCode; // True if content is Python code, false if prompt text
  final bool requiresApi; // True for Practicals 10, 11, 12 requiring API notice
  final String? apiNotice; // Professional status message for API integration
  bool isCompleted; // Local state indicating if student completed the practical

  PracticalModel({
    required this.id,
    required this.number,
    required this.displayTitle,
    required this.officialOutcome,
    required this.aim,
    required this.category,
    required this.taskDescription,
    required this.demoPromptOrCode,
    required this.demoOutput,
    this.isPythonCode = false,
    this.requiresApi = false,
    this.apiNotice,
    this.isCompleted = false,
  });

  /// Copy with updated completion status
  PracticalModel copyWith({bool? isCompleted}) {
    return PracticalModel(
      id: id,
      number: number,
      displayTitle: displayTitle,
      officialOutcome: officialOutcome,
      aim: aim,
      category: category,
      taskDescription: taskDescription,
      demoPromptOrCode: demoPromptOrCode,
      demoOutput: demoOutput,
      isPythonCode: isPythonCode,
      requiresApi: requiresApi,
      apiNotice: apiNotice,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
