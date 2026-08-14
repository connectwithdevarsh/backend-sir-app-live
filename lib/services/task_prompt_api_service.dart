import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/task_prompt_request.dart';
import '../models/task_prompt_result.dart';

/// TaskPromptApiService handles communication with the Python FastAPI backend
/// for Practical 08: Task-Based Prompt Engineering.
class TaskPromptApiService {
  static Future<TaskPromptResult> runTaskPrompt(TaskPromptRequest request) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/practical/8/run');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TaskPromptResult.fromJson(data);
      } else {
        return _generateFallback(request);
      }
    } catch (_) {
      // Offline fallback
    }

    return _generateFallback(request);
  }

  static TaskPromptResult _generateFallback(TaskPromptRequest req) {
    final isOpt = req.promptType == 'optimized';
    String output = '';

    if (req.taskType == 'summarization') {
      if (!isOpt) {
        output =
            "Artificial Intelligence is a computer science field focused on creating intelligent systems. These systems perform human-like tasks such as learning, reasoning, problem solving, language understanding, and visual perception.";
      } else {
        output = """• Field: Computer Science branch developing systems that emulate human cognitive functions.
• Core Capabilities: Machine Learning, Automated Reasoning, Problem Solving, Natural Language Understanding, and Computer Vision.
• Key Objective: Enable computing infrastructure to analyze data, make autonomous decisions, and improve performance iteratively.""";
      }
    } else if (req.taskType == 'blog') {
      if (!isOpt) {
        output =
            "Artificial Intelligence in Education is transforming learning. Students can use AI tools for learning concepts. Teachers can automate administrative tasks. However, balance is necessary between technology and human interaction.";
      } else {
        output = """# Artificial Intelligence in Education: Transforming Learning for Diploma IT Students

## 1. Introduction
Artificial Intelligence (AI) is rapidly revolutionizing the educational landscape. For Diploma Information Technology students, AI tools provide personalized learning pathways and instant code analysis.

## 2. Key Benefits of AI in Academia
- **Adaptive Learning**: Intelligent tutoring systems tailor difficulty based on student performance.
- **Instant Debugging**: AI prompt assistants offer immediate feedback on syntax and algorithm logic.

## 3. Real-World Applications
Tools like ChatGPT and GitHub Copilot are widely adopted in software development labs for rapid prototyping and prompt engineering exercises.

## 4. Challenges & Ethical Considerations
Academic integrity, over-reliance on automated tools, and data privacy remain key challenges.

## 5. Conclusion
Embracing AI as an educational copilot equips IT students with industry-relevant skills while enhancing critical problem-solving abilities.""";
      }
    } else {
      if (!isOpt) {
        output = """def is_prime(n):
    if n < 2: return False
    for i in range(2, n):
        if n % i == 0: return False
    return True

print(is_prime(7))""";
      } else {
        output = """def is_prime(n: int) -> bool:
    \"\"\"
    Checks whether an integer 'n' is a prime number.
    Handles values less than 2 safely and uses O(sqrt(N)) time complexity.
    \"\"\"
    # Edge case validation for numbers less than 2
    if n < 2:
        return False
    
    # 2 is the smallest prime number
    if n == 2:
        return True
        
    # Exclude even numbers greater than 2
    if n % 2 == 0:
        return False
        
    # Check odd divisors up to the square root of n
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
        
    return True

# Sample Execution & Testing
if __name__ == "__main__":
    test_numbers = [-5, 0, 1, 2, 7, 13, 20]
    print("--- Prime Check Execution Test ---")
    for num in test_numbers:
        print(f"is_prime({num}) -> {is_prime(num)}")

'''
Explanation:
1. Input Validation: Instantly returns False for numbers <= 1.
2. Optimization: Checks odd numbers up to sqrt(n) instead of iterating up to n.
3. Output: Returns boolean True for prime integers, False otherwise.
'''""";
      }
    }

    return TaskPromptResult(
      success: false,
      taskType: req.taskType,
      promptType: req.promptType,
      prompt: req.prompt.isNotEmpty ? req.prompt : "Built-in ${req.promptType} prompt",
      output: 'AI service is temporarily unavailable. Please try again.',
      model: 'AI Service (Groq/Gemini)',
      executionTimeMs: 0,
    );
  }
}
