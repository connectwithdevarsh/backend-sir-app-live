from typing import List, Dict, Any
from services.ai_service import AIService
from services.prompt_builder import PromptBuilder

class ChainService:
    @staticmethod
    def run_prompt_chain(task: str, steps: List[Dict[str, str]]) -> Dict[str, Any]:
        """
        Executes a multi-step prompt chain sequentially.
        The actual output of Step N becomes the {{previous_output}} input for Step N+1.
        Returns detailed actual model outputs, prompts, and measured latency for each step.
        """
        clean_task = task.strip()
        if not clean_task:
            return {
                "success": False,
                "error": "Task description cannot be empty for prompt chaining.",
                "steps": [],
                "totalExecutionTimeMs": 0
            }

        if not steps or len(steps) < 2 or len(steps) > 6:
            return {
                "success": False,
                "error": "Prompt chain must contain between 2 and 6 steps.",
                "steps": [],
                "totalExecutionTimeMs": 0
            }

        executed_steps = []
        previous_output = ""
        total_time_ms = 0
        used_model = "none"

        for idx, step_data in enumerate(steps, start=1):
            step_name = step_data.get("name", f"Step {idx}").strip()
            prompt_template = step_data.get("prompt", "").strip()

            if not prompt_template:
                return {
                    "success": False,
                    "error": f"Step {idx} ('{step_name}') has an empty prompt template.",
                    "steps": executed_steps,
                    "totalExecutionTimeMs": total_time_ms
                }

            # Build interpolated prompt for this step
            actual_prompt = PromptBuilder.build_chain_prompt(
                task=clean_task,
                prompt_template=prompt_template,
                previous_output=previous_output,
                step_number=idx
            )

            # Call real LLM service
            ai_res = AIService.generate_ai_response(actual_prompt)
            
            step_success = ai_res.get("success", False)
            step_output = ai_res.get("output", "") or ai_res.get("response", "")
            step_model = ai_res.get("model", "unknown")
            step_time_ms = ai_res.get("executionTimeMs", 0)

            used_model = step_model
            total_time_ms += step_time_ms

            if not step_success:
                error_msg = ai_res.get("error") or f"LLM execution failed at Step {idx} ('{step_name}')."
                executed_steps.append({
                    "stepNumber": idx,
                    "name": step_name,
                    "prompt": actual_prompt,
                    "output": f"ERROR: {error_msg}",
                    "model": step_model,
                    "executionTimeMs": step_time_ms,
                    "success": False,
                    "error": error_msg
                })
                return {
                    "success": False,
                    "error": f"Chain stopped at Step {idx}: {error_msg}",
                    "steps": executed_steps,
                    "totalExecutionTimeMs": total_time_ms,
                    "model": used_model
                }

            # Store successful step execution
            executed_steps.append({
                "stepNumber": idx,
                "name": step_name,
                "prompt": actual_prompt,
                "output": step_output,
                "model": step_model,
                "executionTimeMs": step_time_ms,
                "success": True,
                "error": None
            })

            # Pass actual output to the next step
            previous_output = step_output

        return {
            "success": True,
            "task": clean_task,
            "steps": executed_steps,
            "totalExecutionTimeMs": total_time_ms,
            "model": used_model,
            "finalOutput": previous_output,
            "error": None
        }
