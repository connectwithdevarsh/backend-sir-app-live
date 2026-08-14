from typing import List, Dict, Optional

class PromptBuilder:
    @staticmethod
    def build_zero_shot_prompt(task: str) -> str:
        """
        Builds a clean Zero-Shot prompt.
        """
        clean_task = task.strip()
        return (
            f"You are an AI assistant performing a direct Zero-Shot task.\n\n"
            f"Task:\n{clean_task}\n\n"
            f"Instruction:\nPerform the requested task directly and provide a concise, accurate response without introductory fluff."
        )

    @staticmethod
    def build_few_shot_prompt(task: str, examples: List[Dict[str, str]]) -> str:
        """
        Builds a structured Few-Shot prompt providing explicit input/output demonstration pairs.
        """
        clean_task = task.strip()
        
        prompt_lines = [
            "You are an AI assistant performing a Few-Shot task based on the provided demonstration examples.\n",
            f"Task Description:\n{clean_task}\n",
            "Demonstration Examples:"
        ]

        if not examples:
            return PromptBuilder.build_zero_shot_prompt(task)

        for i, eg in enumerate(examples, start=1):
            eg_in = eg.get("input", "").strip()
            eg_out = eg.get("output", "").strip()
            prompt_lines.append(f"Example {i}:")
            prompt_lines.append(f"Input: {eg_in}")
            prompt_lines.append(f"Output: {eg_out}\n")

        prompt_lines.append("Now, based on the pattern established in the examples above, solve the target task:")
        prompt_lines.append(f"Target Input:\n{clean_task}")
        prompt_lines.append("Output:")

        return "\n".join(prompt_lines)

    @staticmethod
    def build_role_based_prompt(
        task: str,
        role: str,
        audience: str = "",
        tone: str = "",
        constraints: str = ""
    ) -> str:
        """
        Builds a structured Role-Based prompt.
        """
        clean_task = task.strip()
        clean_role = role.strip() if role.strip() else "You are an expert educational instructor."
        
        prompt_lines = [
            f"Role Persona:\n{clean_role}\n",
            f"Task to Perform:\n{clean_task}\n"
        ]
        
        spec_lines = []
        if audience and audience.strip():
            spec_lines.append(f"• Target Audience: {audience.strip()}")
        if tone and tone.strip():
            spec_lines.append(f"• Tone & Style: {tone.strip()}")
        if constraints and constraints.strip():
            spec_lines.append(f"• Constraints: {constraints.strip()}")
            
        if spec_lines:
            prompt_lines.append("Guidelines & Constraints:")
            prompt_lines.extend(spec_lines)
            prompt_lines.append("")
            
        prompt_lines.append("Instructions:\nAdopt the specified persona fully and respond with domain depth, alignment, and clarity suitable for the target audience.")
        
        return "\n".join(prompt_lines)

    @staticmethod
    def build_structured_reasoning_prompt(task: str) -> str:
        """
        Builds a Chain-of-Thought style Structured Reasoning prompt for multi-step tasks.
        Instructs the model to provide numbered task steps and a clear final answer.
        """
        clean_task = task.strip()
        return f"""You are an advanced AI problem solver.

Solve the following multi-step problem using clear, numbered, structured reasoning steps.

Problem:
{clean_task}

Instructions:
1. Break down the solution into explicit numbered steps (Step 1, Step 2, etc.).
2. State the operation or analysis being performed in each step.
3. Show the clear intermediate result for each step.
4. Avoid unnecessary internal developer chatter.
5. Provide a clear, distinct final section starting with:

FINAL ANSWER:
[Concise final result/solution]
"""

    @staticmethod
    def build_chain_prompt(
        task: str,
        prompt_template: str,
        previous_output: str = "",
        step_number: int = 1
    ) -> str:
        """
        Builds a prompt for a single step in a Prompt Chain.
        Replaces variables {{original_task}}, {{previous_output}}, and {{step_number}}.
        """
        clean_task = task.strip()
        clean_prev = previous_output.strip() if previous_output.strip() else "None (Initial Step)"
        template = prompt_template.strip()

        # Replace variables
        built = template.replace("{{original_task}}", clean_task)
        built = built.replace("{{previous_output}}", clean_prev)
        built = built.replace("{{step_number}}", str(step_number))

        # If template doesn't contain variables explicitly, append context headers
        if "{{original_task}}" not in prompt_template and "{{previous_output}}" not in prompt_template:
            context_header = f"Original Problem: {clean_task}\n"
            if clean_prev != "None (Initial Step)":
                context_header += f"Previous Step Output:\n{clean_prev}\n\n"
            return f"{context_header}Step Task:\n{built}"

        return built
