"""
Evaluation Service for Practical 04: LLM Capability & Hallucination Evaluation
Provides assisted reference comparison with clear educational disclaimers.
"""

import re
from typing import Dict, Any, Optional


class EvaluationService:
    @staticmethod
    def compare_reference(
        model_response: str,
        reference_answer: Optional[str],
        category: str = "factual"
    ) -> Dict[str, Any]:
        """
        Performs assisted comparison between the model response and reference answer.
        Does NOT claim absolute hallucination or correctness detection.
        """
        if not reference_answer or not reference_answer.strip():
            return {
                "hasReference": False,
                "status": "No reference provided",
                "detail": "No reference information was supplied for automated comparison.",
                "disclaimer": "Student evaluation and analytical review recommended."
            }

        ref_clean = reference_answer.strip().lower()
        resp_clean = model_response.strip().lower()

        # Remove punctuation for basic comparison
        ref_tokens = set(re.findall(r'\b\w+\b', ref_clean))
        resp_tokens = set(re.findall(r'\b\w+\b', resp_clean))

        # Check exact or strong containment
        if ref_clean == resp_clean:
            status = "Exact match with supplied reference"
            detail = "The model output exactly matches the provided reference information."
        elif ref_clean in resp_clean:
            status = "Matches supplied reference"
            detail = "The reference key phrases or answer were found within the model response."
        elif ref_tokens and ref_tokens.issubset(resp_tokens):
            status = "High reference term overlap"
            detail = "All key words from the reference answer appear in the model response."
        elif ref_tokens and len(ref_tokens.intersection(resp_tokens)) > 0:
            overlap_pct = int((len(ref_tokens.intersection(resp_tokens)) / len(ref_tokens)) * 100)
            status = f"Partial overlap (~{overlap_pct}%)"
            detail = "Some reference terms were found. Detailed manual verification is recommended."
        else:
            status = "Does not match supplied reference"
            detail = "The reference answer was not clearly reflected in the model output. Check for factual discrepancy or reasoning difference."

        return {
            "hasReference": True,
            "status": status,
            "detail": detail,
            "disclaimer": "Assisted evaluation only. Hallucination identification and final accuracy assessment must be performed by the student."
        }
