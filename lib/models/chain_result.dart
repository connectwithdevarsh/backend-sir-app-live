import 'chain_step.dart';
import 'reasoning_result.dart';

/// ChainResult models the sequential execution output of a multi-step prompt chain.
class ChainResult {
  final bool success;
  final String task;
  final List<ChainStepResultItem> steps;
  final int totalExecutionTimeMs;
  final String model;
  final String finalOutput;
  final String? error;

  ChainResult({
    required this.success,
    required this.task,
    required this.steps,
    required this.totalExecutionTimeMs,
    required this.model,
    required this.finalOutput,
    this.error,
  });

  factory ChainResult.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List? ?? [];
    final stepsList = rawSteps
        .map((s) => ChainStepResultItem.fromJson(s as Map<String, dynamic>))
        .toList();

    String lastOutput = json['finalOutput'] ?? '';
    if (lastOutput.isEmpty && stepsList.isNotEmpty) {
      lastOutput = stepsList.last.output;
    }

    return ChainResult(
      success: json['success'] ?? false,
      task: json['task'] ?? '',
      steps: stepsList,
      totalExecutionTimeMs: json['totalExecutionTimeMs'] ?? 0,
      model: json['model'] ?? (stepsList.isNotEmpty ? stepsList.last.model : 'unknown'),
      finalOutput: lastOutput,
      error: json['error'],
    );
  }

  factory ChainResult.failure(String errorMessage, {String task = ''}) {
    return ChainResult(
      success: false,
      task: task,
      steps: [],
      totalExecutionTimeMs: 0,
      model: 'none',
      finalOutput: '',
      error: errorMessage,
    );
  }
}

/// AdvancedPromptCompareResult models the combined output of Compare Both mode.
class AdvancedPromptCompareResult {
  final bool success;
  final String task;
  final ReasoningResult structuredResult;
  final ChainResult chainResult;
  final String? error;

  AdvancedPromptCompareResult({
    required this.success,
    required this.task,
    required this.structuredResult,
    required this.chainResult,
    this.error,
  });

  factory AdvancedPromptCompareResult.fromJson(Map<String, dynamic> json) {
    final structJson = json['structuredResult'] as Map<String, dynamic>? ?? {};
    final chainJson = json['chainResult'] as Map<String, dynamic>? ?? {};

    return AdvancedPromptCompareResult(
      success: json['success'] ?? false,
      task: json['task'] ?? '',
      structuredResult: ReasoningResult.fromJson(structJson),
      chainResult: ChainResult.fromJson(chainJson),
      error: json['error'],
    );
  }
}
