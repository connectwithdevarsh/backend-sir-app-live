from typing import Optional, List

class SoftwarePromptBuilder:
    @staticmethod
    def build_code_generation_prompt(
        language: str,
        problem: str,
        requirements: Optional[str] = ""
    ) -> str:
        """
        Builds a structured prompt for AI Code Generation.
        """
        clean_lang = language.strip() if language and language.strip() else "Python"
        clean_prob = problem.strip()
        clean_reqs = requirements.strip() if requirements and requirements.strip() else "Write clean, readable code with comments."

        return f"""You are an experienced software developer.

Programming Language:
{clean_lang}

Task / Requirement:
{clean_prob}

Specific Requirements:
{clean_reqs}

Instructions:
1. Generate clean, well-structured, and production-ready {clean_lang} code.
2. Include appropriate inline comments explaining non-trivial logic.
3. Ensure the code handles basic edge cases.
4. Place the code inside a standard markdown code block: ```{clean_lang.lower()} ... ```
5. After the code block, provide a short, step-by-step explanation of how the program works."""

    @staticmethod
    def build_debugging_prompt(
        language: str,
        code: str,
        error: str,
        expected_behavior: Optional[str] = ""
    ) -> str:
        """
        Builds a structured prompt for AI Code Debugging & Repair.
        """
        clean_lang = language.strip() if language and language.strip() else "Python"
        clean_code = code.strip()
        clean_err = error.strip() if error and error.strip() else "Unspecified execution error or unexpected output."
        clean_exp = expected_behavior.strip() if expected_behavior and expected_behavior.strip() else "Expected code to execute without errors and produce correct results."

        return f"""You are an experienced software debugging assistant.

Programming Language:
{clean_lang}

Source Code:
{clean_code}

Error Message / Bug Description:
{clean_err}

Expected Behavior:
{clean_exp}

Analyze the provided code and error to identify the root cause and provide a corrected version.

Please structure your output using these exact headings:

### 1. PROBLEM IDENTIFICATION
[State the exact bug or error]

### 2. CAUSE ANALYSIS
[Explain why this error occurred in the code]

### 3. CORRECTED CODE
```{clean_lang.lower()}
[Insert complete corrected code here]
```

### 4. FIX EXPLANATION
[Explain the specific modifications made to resolve the bug]"""

    @staticmethod
    def build_code_explanation_prompt(
        language: str,
        code: str,
        level: str = "Beginner",
        focus: Optional[List[String]] = None
    ) -> str:
        """
        Builds a structured prompt for AI Code Explanation.
        """
        clean_lang = language.strip() if language and language.strip() else "Python"
        clean_code = code.strip()
        clean_lvl = level.strip() if level and level.strip() else "Beginner"
        
        focus_str = ", ".join(focus) if focus and len(focus) > 0 else "Overall purpose, Control flow, Key logic"

        return f"""You are an experienced programming instructor.

Explain the following {clean_lang} code for a {clean_lvl} learner.

Focus Areas:
{focus_str}

Source Code:
{clean_code}

Instructions:
Provide a clear, student-friendly educational breakdown with the following structured sections:

### 1. OVERALL PURPOSE
[Brief overview of what the program accomplishes]

### 2. IMPORTANT COMPONENTS
[Key functions, variables, and data structures]

### 3. PROGRAM FLOW
[Step-by-step description of how execution progresses]

### 4. KEY LOGIC & EXPLANATION
[Detailed explanation of the critical logic and algorithm]"""
