from typing import List, Optional

class StudyPromptBuilder:
    @staticmethod
    def build_explain_prompt(
        subject: str,
        topic: str,
        level: str = "Beginner",
        style: str = "Simple",
        include_example: bool = True
    ) -> str:
        clean_sub = subject.strip() if subject and subject.strip() else "Artificial Intelligence"
        clean_top = topic.strip() if topic and topic.strip() else "Machine Learning"
        ex_str = "Yes, include a simple relatable real-world example." if include_example else "No explicit example needed."

        return f"""You are an experienced academic teacher.

Subject:
{clean_sub}

Topic:
{clean_top}

Task:
Explain this topic for a {level} student.

Explanation Style:
{style}

Include Example:
{ex_str}

Instructions:
1. Provide a clear, educational, and well-structured explanation.
2. Highlight key terms and core principles.
3. Keep the tone encouraging and academic.
4. Do not invent unsupported facts."""

    @staticmethod
    def build_summary_prompt(
        content: str,
        length: str = "Medium",
        style: str = "Bullet Points"
    ) -> str:
        clean_content = content.strip()

        return f"""You are an academic summarization assistant.

Summarize the following study material.

Study Material:
{clean_content}

Target Length:
{length}

Summary Format/Style:
{style}

Instructions:
1. Preserve all key facts, definitions, and core concepts.
2. Do not introduce external information not present in the material.
3. Structure the summary logically for exam revision."""

    @staticmethod
    def build_quiz_prompt(
        subject: str,
        topic: str,
        question_count: int = 5,
        difficulty: str = "Medium",
        question_type: str = "MCQ"
    ) -> str:
        clean_sub = subject.strip() if subject and subject.strip() else "Artificial Intelligence"
        clean_top = topic.strip() if topic and topic.strip() else "Prompt Engineering"

        return f"""You are an educational quiz generator.

Subject:
{clean_sub}

Topic:
{clean_top}

Number of Questions:
{question_count}

Difficulty Level:
{difficulty}

Question Type:
{question_type}

Instructions:
Generate exactly {question_count} questions based strictly on the topic "{clean_top}".

CRITICAL OUTPUT FORMAT:
You MUST return ONLY a valid JSON object matching this exact schema:
```json
{{
  "questions": [
    {{
      "question": "What is ...?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": 0,
      "explanation": "Short explanation why Option A is correct."
    }}
  ]
}}
```
Note: "correctAnswer" must be an integer index from 0 to 3 corresponding to the correct option in the options array. Return ONLY raw JSON."""

    @staticmethod
    def build_study_plan_prompt(
        subjects: List[str],
        days: int = 7,
        hours_per_day: float = 2.0,
        exam_date: Optional[str] = "",
        priority: str = "Balanced"
    ) -> str:
        sub_list = ", ".join(subjects) if subjects else "AIPE, Python, JavaScript"
        date_str = f"Exam Date: {exam_date}" if exam_date else "No fixed exam date."

        return f"""You are an academic study planning assistant.

Create a realistic day-by-day study plan.

Subjects to Cover:
{sub_list}

Available Days:
{days} Days

Study Hours Per Day:
{hours_per_day} Hours

{date_str}

Study Priority Focus:
{priority}

CRITICAL OUTPUT FORMAT:
Return ONLY a valid JSON object matching this exact schema:
```json
{{
  "plan": [
    {{
      "day": 1,
      "subject": "AIPE",
      "topic": "Prompt Engineering Basics",
      "duration": "{hours_per_day} hours",
      "activity": "Read notes and practice zero-shot prompts"
    }}
  ]
}}
```
Provide an entry for each of the {days} days."""

    @staticmethod
    def build_flashcard_prompt(
        subject: str,
        topic: str,
        card_count: int = 5
    ) -> str:
        clean_sub = subject.strip() if subject and subject.strip() else "Artificial Intelligence"
        clean_top = topic.strip() if topic and topic.strip() else "Key Concepts"

        return f"""You are an educational flashcard generator.

Subject:
{clean_sub}

Topic:
{clean_top}

Number of Flashcards:
{card_count}

CRITICAL OUTPUT FORMAT:
Return ONLY a valid JSON object matching this exact schema:
```json
{{
  "flashcards": [
    {{
      "front": "What is ...?",
      "back": "Clear concise explanation or answer."
    }}
  ]
}}
```
Generate exactly {card_count} flashcards."""
