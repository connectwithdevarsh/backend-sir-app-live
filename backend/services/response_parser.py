import json
import re
from typing import Dict, Any, List

class ResponseParser:
    @staticmethod
    def extract_json_block(text: str) -> str:
        """
        Extracts raw JSON string from text or markdown code fences.
        """
        if "```json" in text:
            parts = text.split("```json")
            if len(parts) >= 2:
                json_part = parts[1].split("```")[0].strip()
                return json_part
        elif "```" in text:
            parts = text.split("```")
            if len(parts) >= 2:
                json_part = parts[1].strip()
                return json_part
        return text.strip()

    @classmethod
    def parse_quiz_response(cls, raw_output: str) -> Dict[str, Any]:
        json_str = cls.extract_json_block(raw_output)
        try:
            data = json.loads(json_str)
            questions = data.get("questions", [])
            valid_questions = []

            for q in questions:
                if isinstance(q, dict) and "question" in q and "options" in q:
                    opts = q.get("options", [])
                    if isinstance(opts, list) and len(opts) >= 2:
                        valid_questions.append({
                            "question": str(q.get("question", "")),
                            "options": [str(o) for o in opts],
                            "correctAnswer": int(q.get("correctAnswer", 0)),
                            "explanation": str(q.get("explanation", ""))
                        })

            if valid_questions:
                return {"success": True, "questions": valid_questions}
        except Exception:
            pass

        return {
            "success": False,
            "error": "AI returned an invalid quiz format. Could not parse JSON structure."
        }

    @classmethod
    def parse_flashcard_response(cls, raw_output: str) -> Dict[str, Any]:
        json_str = cls.extract_json_block(raw_output)
        try:
            data = json.loads(json_str)
            cards = data.get("flashcards", [])
            valid_cards = []

            for c in cards:
                if isinstance(c, dict) and "front" in c and "back" in c:
                    valid_cards.append({
                        "front": str(c.get("front", "")),
                        "back": str(c.get("back", ""))
                    })

            if valid_cards:
                return {"success": True, "flashcards": valid_cards}
        except Exception:
            pass

        return {
            "success": False,
            "error": "AI returned an invalid flashcard format. Could not parse JSON structure."
        }

    @classmethod
    def parse_study_plan_response(cls, raw_output: str) -> Dict[str, Any]:
        json_str = cls.extract_json_block(raw_output)
        try:
            data = json.loads(json_str)
            plan = data.get("plan", [])
            valid_items = []

            for item in plan:
                if isinstance(item, dict) and "day" in item and "subject" in item:
                    valid_items.append({
                        "day": int(item.get("day", 1)),
                        "subject": str(item.get("subject", "")),
                        "topic": str(item.get("topic", "")),
                        "duration": str(item.get("duration", "1 hour")),
                        "activity": str(item.get("activity", ""))
                    })

            if valid_items:
                return {"success": True, "plan": valid_items}
        except Exception:
            pass

        return {
            "success": False,
            "error": "AI returned an invalid study plan format. Could not parse JSON structure."
        }
