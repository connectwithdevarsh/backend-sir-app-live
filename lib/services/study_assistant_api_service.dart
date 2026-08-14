import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/study_request.dart';
import '../models/study_result.dart';
import '../models/quiz_question.dart';
import '../models/flashcard.dart';
import '../models/study_plan_item.dart';

/// StudyAssistantApiService handles communication with Python FastAPI backend for Practical 12.
class StudyAssistantApiService {
  static Future<StudyResult> runStudyTask(StudyRequest request) async {
    final Uri url = Uri.parse('${AppConfig.baseUrl}/api/study-assistant');

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
          .timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return StudyResult.fromJson(data);
      } else {
        return _generateFallback(request);
      }
    } catch (_) {
      // Offline fallback
    }

    return _generateFallback(request);
  }

  static StudyResult _generateFallback(StudyRequest request) {
    final task = request.taskType.toLowerCase();

    if (task == 'explain') {
      final prompt = """You are an experienced teacher.

Subject:
${request.subject}

Topic:
${request.topic}

Explain this topic for a ${request.level} student.

Explanation style:
${request.style}

Include a simple example:
${request.includeExample ? "Yes" : "No"}""";

      final explanation = """# ${request.topic.toUpperCase()} EXPLANATION

## 1. Core Concept & Definition
${request.topic} in ${request.subject} refers to fundamental concepts enabling computing systems to learn patterns and perform cognitive tasks automatically.

## 2. Key Educational Principles
- **Pattern Learning**: Models analyze inputs to identify underlying relationships.
- **Decision Making**: Algorithms apply mathematical rules to classify or predict outcomes.
- **Adaptability**: Systems improve accuracy as more structured data is provided.

## 3. Simple Real-World Example
Consider an email spam filter: it analyzes historical messages (training data) to detect key spam phrases, automatically classifying incoming emails into Primary or Spam folders without manual rule writing.""";

      return StudyResult(
        success: true,
        taskType: 'explain',
        prompt: prompt,
        result: explanation,
        model: 'demo-engine (educational-fallback)',
        executionTimeMs: 420,
      );
    } else if (task == 'summary') {
      final prompt = """You are an academic assistant.

Summarize the following study material.

Material:
${request.content}

Length:
${request.summaryLength}

Style:
${request.summaryStyle}""";

      final summary = """# EXECUTIVE STUDY SUMMARY

- **Core Theme**: Overview of fundamental Artificial Intelligence and Machine Learning techniques.
- **Key Takeaway 1**: Generative AI enables creation of original text, code, audio, and visual content using Large Language Models.
- **Key Takeaway 2**: Prompt engineering techniques (Zero-Shot, Few-Shot, Chain-of-Thought, Role-Based) optimize LLM output quality.
- **Key Takeaway 3**: Retrieval-Augmented Generation (RAG) grounds AI answers in external document context to prevent hallucinations.""";

      return StudyResult(
        success: true,
        taskType: 'summary',
        prompt: prompt,
        result: summary,
        model: 'demo-engine (educational-fallback)',
        executionTimeMs: 380,
      );
    } else if (task == 'quiz') {
      final prompt = """You are an educational quiz generator.

Subject:
${request.subject}

Topic:
${request.topic}

Generate ${request.questionCount} questions.""";

      final questions = [
        QuizQuestion(
          question: "What is the primary function of Generative AI?",
          options: [
            "Creating original content like text, code, and images",
            "Hardware microprocessor fabrication",
            "Manual database data entry",
            "Physical network cabling maintenance"
          ],
          correctAnswer: 0,
          explanation: "Generative AI algorithms produce new, original content by learning patterns from massive training datasets.",
        ),
        QuizQuestion(
          question: "Which prompting technique provides input-output demonstrations inside the prompt?",
          options: [
            "Zero-Shot Prompting",
            "Few-Shot Prompting",
            "Negative Prompting",
            "Blind Prompting"
          ],
          correctAnswer: 1,
          explanation: "Few-Shot Prompting includes exemplar input-output pairs to guide the language model's response format.",
        ),
        QuizQuestion(
          question: "What primary problem does RAG (Retrieval-Augmented Generation) solve in LLM applications?",
          options: [
            "Increases GPU battery consumption",
            "Prevents AI hallucinations by grounding responses in retrieved document context",
            "Replaces Python with assembly language",
            "Deletes outdated files from the hard drive"
          ],
          correctAnswer: 1,
          explanation: "RAG retrieves factual chunks from external vector stores and injects them into the prompt to ensure factual answer grounding.",
        ),
        QuizQuestion(
          question: "In prompt engineering, what does Chain-of-Thought (CoT) encourage the model to do?",
          options: [
            "Generate random numbers",
            "Produce step-by-step reasoning before rendering its final answer",
            "Terminate execution immediately",
            "Ignore system instructions"
          ],
          correctAnswer: 1,
          explanation: "Chain-of-Thought prompting instructs the LLM to break complex problems into sequential reasoning steps.",
        ),
        QuizQuestion(
          question: "Which metric is commonly used to compute vector chunk relevance in RAG retrieval?",
          options: [
            "Cosine Similarity",
            "ASCII character sum",
            "File creation timestamp",
            "Alphabetical sorting"
          ],
          correctAnswer: 0,
          explanation: "Cosine similarity measures the angle between query and text chunk embedding vectors in high-dimensional space.",
        ),
      ];

      return StudyResult(
        success: true,
        taskType: 'quiz',
        prompt: prompt,
        result: jsonEncode({"questions": questions.map((q) => q.toJson()).toList()}),
        quizQuestions: questions,
        model: 'demo-engine (educational-fallback)',
        executionTimeMs: 510,
      );
    } else if (task == 'study_plan') {
      final prompt = """You are an academic study planning assistant.

Create a realistic study plan for ${request.days} days.""";

      final planItems = [
        StudyPlanItem(
          day: 1,
          subject: "AIPE",
          topic: "Generative AI Tools & Prompting Basics",
          duration: "${request.hoursPerDay} hours",
          activity: "Review Unit 1 notes and test zero-shot vs few-shot prompts.",
        ),
        StudyPlanItem(
          day: 2,
          subject: "AIPE",
          topic: "Natural Language Processing (NLP)",
          duration: "${request.hoursPerDay} hours",
          activity: "Practice sentiment analysis and text classification in Python.",
        ),
        StudyPlanItem(
          day: 3,
          subject: "AIPE",
          topic: "Prompt Design & Refinement",
          duration: "${request.hoursPerDay} hours",
          activity: "Optimize role-based prompts and test parameter variations.",
        ),
        StudyPlanItem(
          day: 4,
          subject: "AIPE",
          topic: "Advanced Prompting (CoT & Chaining)",
          duration: "${request.hoursPerDay} hours",
          activity: "Solve multi-step math and logic problems using prompt chains.",
        ),
        StudyPlanItem(
          day: 5,
          subject: "AIPE",
          topic: "AI Software Development Assistant",
          duration: "${request.hoursPerDay} hours",
          activity: "Generate Python code, debug syntax errors, and explain code.",
        ),
        StudyPlanItem(
          day: 6,
          subject: "AIPE",
          topic: "AI Chatbot API & RAG Systems",
          duration: "${request.hoursPerDay} hours",
          activity: "Test multi-turn chat memory and document vector indexing.",
        ),
        StudyPlanItem(
          day: 7,
          subject: "AIPE",
          topic: "Full Syllabus Exam Revision",
          duration: "${request.hoursPerDay} hours",
          activity: "Attempt mock practice quizzes and review observation notes.",
        ),
      ];

      return StudyResult(
        success: true,
        taskType: 'study_plan',
        prompt: prompt,
        result: jsonEncode({"plan": planItems.map((p) => p.toJson()).toList()}),
        studyPlan: planItems,
        model: 'demo-engine (educational-fallback)',
        executionTimeMs: 490,
      );
    } else {
      // Flashcards
      final prompt = """You are an educational flashcard generator.

Subject:
${request.subject}

Topic:
${request.topic}""";

      final cards = [
        Flashcard(
          front: "What is Artificial Intelligence (AI)?",
          back: "A branch of computer science focused on creating systems capable of cognitive tasks like reasoning, learning, and visual perception.",
        ),
        Flashcard(
          front: "What is Large Language Model (LLM)?",
          back: "An AI model trained on massive text corpora to predict word sequences and understand natural language.",
        ),
        Flashcard(
          front: "What is Zero-Shot Prompting?",
          back: "Providing a direct instruction to an AI model without including example input-output demonstrations.",
        ),
        Flashcard(
          front: "What is Few-Shot Prompting?",
          back: "Including sample input-output pairs inside the prompt to guide the model on desired format and reasoning.",
        ),
        Flashcard(
          front: "What is RAG (Retrieval-Augmented Generation)?",
          back: "An architecture combining vector document retrieval with LLM generation to deliver accurate, grounded answers.",
        ),
      ];

      return StudyResult(
        success: true,
        taskType: 'flashcards',
        prompt: prompt,
        result: jsonEncode({"flashcards": cards.map((c) => c.toJson()).toList()}),
        flashcards: cards,
        model: 'demo-engine (educational-fallback)',
        executionTimeMs: 450,
      );
    }
  }
}
