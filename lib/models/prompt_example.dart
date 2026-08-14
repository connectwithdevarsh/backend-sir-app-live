/// PromptExample represents a single input-output demonstration pair for Few-Shot prompting.
class PromptExample {
  String input;
  String output;

  PromptExample({
    required this.input,
    required this.output,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'output': output,
    };
  }

  factory PromptExample.fromJson(Map<String, dynamic> json) {
    return PromptExample(
      input: json['input'] as String? ?? '',
      output: json['output'] as String? ?? '',
    );
  }
}
