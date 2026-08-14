/// TaskPromptRequest encapsulates the data payload sent to POST /api/practical/8/run
class TaskPromptRequest {
  final String taskType; // "summarization", "blog", "code"
  final String promptType; // "basic", "optimized"
  final String input;
  final String prompt;
  final String language;
  final String length;
  final String audience;
  final String summaryFormat;
  final String focus;
  final String tone;
  final String keywords;
  final bool includeComments;
  final bool includeValidation;
  final bool useFunction;
  final bool explainCode;
  final bool includeSampleIO;

  TaskPromptRequest({
    required this.taskType,
    required this.promptType,
    required this.input,
    this.prompt = '',
    this.language = 'Python',
    this.length = '100 words',
    this.audience = 'Diploma IT Student',
    this.summaryFormat = 'Bullet Points',
    this.focus = 'Main Ideas',
    this.tone = 'Informative & Friendly',
    this.keywords = '',
    this.includeComments = true,
    this.includeValidation = true,
    this.useFunction = true,
    this.explainCode = true,
    this.includeSampleIO = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskType': taskType.trim(),
      'promptType': promptType.trim(),
      'input': input.trim(),
      'prompt': prompt.trim(),
      'language': language.trim(),
      'length': length.trim(),
      'audience': audience.trim(),
      'summaryFormat': summaryFormat.trim(),
      'focus': focus.trim(),
      'tone': tone.trim(),
      'keywords': keywords.trim(),
      'includeComments': includeComments,
      'includeValidation': includeValidation,
      'useFunction': useFunction,
      'explainCode': explainCode,
      'includeSampleIO': includeSampleIO,
    };
  }
}
