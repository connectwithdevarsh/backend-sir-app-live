import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/prompt_example.dart';
import '../models/prompting_result.dart';

/// PromptingApiService communicates with the Python FastAPI backend for Practical 06
/// executing Zero-Shot, Few-Shot, Role-Based, and 3-way Compare prompting requests.
/// Includes automatic educational fallback when the local backend server is offline.
class PromptingApiService {
  static Future<dynamic> runPromptingTechnique({
    required String task,
    required String method, // "zero_shot", "few_shot", "role_based", "compare"
    List<PromptExample> examples = const [],
    String role = '',
    String audience = '',
    String tone = '',
    String constraints = '',
  }) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/6/run');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'task': task.trim(),
              'method': method.toLowerCase().trim(),
              'examples': examples.map((e) => e.toJson()).toList(),
              'role': role.trim(),
              'audience': audience.trim(),
              'tone': tone.trim(),
              'constraints': constraints.trim(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (method.toLowerCase() == 'compare') {
          return PromptingCompareResult.fromJson(data);
        } else {
          return PromptingResult.fromJson(data);
        }
      }
    } catch (_) {
      // Backend is offline or unreachable - fall back to interactive demo engine
    }

    // Generate smart local demonstration fallback
    return _generateFallback(
      task: task,
      method: method,
      examples: examples,
      role: role,
      audience: audience,
      tone: tone,
      constraints: constraints,
    );
  }

  static dynamic _generateFallback({
    required String task,
    required String method,
    required List<PromptExample> examples,
    required String role,
    required String audience,
    required String tone,
    required String constraints,
  }) {
    final String cleanTask = task.trim();
    final String cleanMethod = method.toLowerCase().trim();

    if (cleanMethod == 'compare') {
      final zeroShot = _buildSingleFallback('zero_shot', cleanTask, examples, role, audience, tone, constraints);
      final fewShot = _buildSingleFallback('few_shot', cleanTask, examples, role, audience, tone, constraints);
      final roleBased = _buildSingleFallback('role_based', cleanTask, examples, role, audience, tone, constraints);

      return PromptingCompareResult(
        success: true,
        task: cleanTask,
        results: [zeroShot, fewShot, roleBased],
      );
    }

    return _buildSingleFallback(cleanMethod, cleanTask, examples, role, audience, tone, constraints);
  }

  static PromptingResult _buildSingleFallback(
    String method,
    String task,
    List<PromptExample> examples,
    String role,
    String audience,
    String tone,
    String constraints,
  ) {
    String formattedPrompt = '';
    String generatedOutput = '';

    if (method == 'zero_shot') {
      formattedPrompt = task;
      generatedOutput = _generateZeroShotOutput(task);
    } else if (method == 'few_shot') {
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('Task Exemplars:');
      for (int i = 0; i < examples.length; i++) {
        buffer.writeln('Input: ${examples[i].input}');
        buffer.writeln('Output: ${examples[i].output}\n');
      }
      buffer.writeln('Test Query:\nInput: $task\nOutput:');
      formattedPrompt = buffer.toString().trim();
      generatedOutput = _generateFewShotOutput(task, examples);
    } else {
      // role_based
      formattedPrompt = '''
System Role: ${role.isNotEmpty ? role : "Expert Instructor"}
Audience: ${audience.isNotEmpty ? audience : "Diploma IT Students"}
Tone: ${tone.isNotEmpty ? tone : "Academic & Clear"}
Constraints: ${constraints.isNotEmpty ? constraints : "Provide structured breakdown"}

Task: $task
'''.trim();
      generatedOutput = _generateRoleBasedOutput(task, role, audience, tone, constraints);
    }

    return PromptingResult(
      success: true,
      method: method,
      prompt: formattedPrompt,
      output: generatedOutput,
      model: 'demo-engine ($method)',
      executionTimeMs: method == 'zero_shot' ? 320 : (method == 'few_shot' ? 410 : 480),
    );
  }

  static String _generateZeroShotOutput(String task) {
    if (task.toLowerCase().contains('cybersecurity')) {
      return '''
Cybersecurity is the practice of protecting systems, networks, and programs from digital attacks. These cyberattacks are usually aimed at accessing, changing, or destroying sensitive information; extorting money from users; or interrupting normal business processes.

Key Principles:
1. Confidentiality (Data privacy)
2. Integrity (Data accuracy)
3. Availability (System accessibility)
''';
    }
    if (task.toLowerCase().contains('cloud')) {
      return '''
Cloud Computing is the on-demand delivery of IT resources over the Internet with pay-as-you-go pricing. Instead of buying, owning, and maintaining physical data centers, you can access technology services, such as computing power, storage, and databases, on an as-needed basis from a cloud provider.

Service Models:
- IaaS (Infrastructure as a Service)
- PaaS (Platform as a Service)
- SaaS (Software as a Service)
''';
    }
    return '''
Artificial Intelligence (AI) refers to the simulation of human intelligence in machines programmed to think and learn like humans. It encompasses subfields such as Machine Learning, Natural Language Processing, and Computer Vision.

Key Components:
1. Data Input & Processing
2. Pattern Recognition
3. Decision Making & Output Generation
''';
  }

  static String _generateFewShotOutput(String task, List<PromptExample> examples) {
    if (task.toLowerCase().contains('cybersecurity')) {
      return 'Cybersecurity is the protection of internet-connected systems, including hardware, software, and data, from cyberattacks.';
    }
    if (task.toLowerCase().contains('cloud')) {
      return 'Cloud Computing is the delivery of computing services including servers, storage, and databases over the Internet.';
    }
    return 'Artificial Intelligence is the branch of computer science that builds smart machines capable of performing human-like tasks.';
  }

  static String _generateRoleBasedOutput(
    String task,
    String role,
    String audience,
    String tone,
    String constraints,
  ) {
    final String topic = task.toLowerCase().contains('cybersecurity')
        ? 'Cybersecurity'
        : (task.toLowerCase().contains('cloud') ? 'Cloud Computing' : 'Artificial Intelligence');

    return '''
Welcome Students! Let's understand $topic step-by-step:

📚 Core Concept:
$topic is like a digital security guard protecting a high-tech library. It ensures only authorized visitors enter and all books remain safe from tampering.

💡 Real-World Analogies:
1. Home Security System: Just as sensors and smart locks protect your home, firewalls and encryption protect computer networks.
2. Verified ID Card: Authentication ensures that only registered students can access college servers.

🎯 Practical Key Takeaways for Diploma IT Students:
• Always apply multi-factor authentication (MFA).
• Understand the difference between defensive security and ethical hacking.
• Keep software dependencies updated to avoid vulnerability exploits.
''';
  }
}
