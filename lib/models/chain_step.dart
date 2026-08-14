/// ChainStep models a single step definition in a prompt chain.
class ChainStep {
  String name;
  String prompt;

  ChainStep({
    required this.name,
    required this.prompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'prompt': prompt.trim(),
    };
  }

  factory ChainStep.fromJson(Map<String, dynamic> json) {
    return ChainStep(
      name: json['name'] ?? '',
      prompt: json['prompt'] ?? '',
    );
  }
}

/// ChainStepResultItem models the actual execution output of one step in a prompt chain.
class ChainStepResultItem {
  final int stepNumber;
  final String name;
  final String prompt;
  final String output;
  final String model;
  final int executionTimeMs;
  final bool success;
  final String? error;

  ChainStepResultItem({
    required this.stepNumber,
    required this.name,
    required this.prompt,
    required this.output,
    required this.model,
    required this.executionTimeMs,
    required this.success,
    this.error,
  });

  factory ChainStepResultItem.fromJson(Map<String, dynamic> json) {
    return ChainStepResultItem(
      stepNumber: json['stepNumber'] ?? 1,
      name: json['name'] ?? '',
      prompt: json['prompt'] ?? '',
      output: json['output'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      success: json['success'] ?? true,
      error: json['error'],
    );
  }
}
