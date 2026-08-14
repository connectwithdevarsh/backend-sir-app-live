import '../models/faculty_model.dart';

/// FacultyData provides centralized profile information for Dr. Dippal P. Israni.
class FacultyData {
  static FacultyModel getFaculty() {
    return FacultyModel.currentFaculty;
  }

  static List<String> getLearningFocus() {
    return const [
      'Machine Learning',
      'Computer Vision',
      'Deep Learning',
    ];
  }

  static List<Map<String, String>> getCourseUnits() {
    return const [
      {
        'number': '01',
        'title': 'Foundations of Artificial Intelligence and Generative AI',
      },
      {
        'number': '02',
        'title': 'Basics of Large Language Models (LLMs)',
      },
      {
        'number': '03',
        'title': 'Prompt Engineering Fundamentals',
      },
      {
        'number': '04',
        'title': 'Advanced Prompting Techniques',
      },
      {
        'number': '05',
        'title': 'AI Tools for Software Development',
      },
    ];
  }
}
