from typing import Optional, List, Dict, Any

class TaskPromptBuilder:
    @staticmethod
    def build_summarization_prompt(
        source_text: str,
        prompt_type: str = "basic",
        length: str = "100 words",
        audience: str = "Diploma IT Student",
        summary_format: str = "Bullet Points",
        focus: str = "Main Ideas",
        custom_prompt: Optional[str] = None
    ) -> str:
        """
        Builds basic or optimized summarization prompts.
        """
        clean_text = source_text.strip()
        
        if custom_prompt and custom_prompt.strip():
            # If student modified the prompt in the UI editor, append source text if needed
            cp = custom_prompt.strip()
            if clean_text and clean_text not in cp:
                return f"{cp}\n\nSource Text:\n{clean_text}"
            return cp

        if prompt_type.lower() == "basic":
            return f"Summarize the following text:\n\n{clean_text}"
        
        # Optimized Summarization Prompt Construction
        return f"""Summarize the following text for a {audience} in approximately {length}.

Focus: {focus}.
Output Format: {summary_format}.

Instructions:
1. Extract key concepts clearly.
2. Keep the language accessible for the target audience.
3. Adhere strictly to the requested {summary_format} structure.
4. Avoid adding information not present in the source text.

Source Text:
{clean_text}"""

    @staticmethod
    def build_blog_prompt(
        topic: str,
        prompt_type: str = "basic",
        audience: str = "Students",
        tone: str = "Informative & Friendly",
        length: str = "Medium (~600 words)",
        keywords: str = "",
        custom_prompt: Optional[str] = None
    ) -> str:
        """
        Builds basic or optimized blog generation prompts.
        """
        clean_topic = topic.strip()
        
        if custom_prompt and custom_prompt.strip():
            return custom_prompt.strip()

        if prompt_type.lower() == "basic":
            return f"Write a blog about {clean_topic}."

        kw_section = f"\nKey Keywords to Include: {keywords.strip()}" if keywords and keywords.strip() else ""

        return f"""Write an engaging and educational blog post on the topic: "{clean_topic}".

Target Audience: {audience}
Tone & Style: {tone}
Target Length: {length}{kw_section}

Blog Structure Requirements:
1. Catchy Title
2. Introduction with an engaging hook
3. Key Benefits & Concepts
4. Real-world Practical Applications
5. Challenges or Future Outlook
6. Concise Conclusion

Guidelines:
- Use clear markdown headings (##, ###) and short paragraphs.
- Keep the explanation student-friendly and well-structured.
- Ensure all technical terms are explained clearly."""

    @staticmethod
    def build_code_prompt(
        problem_statement: str,
        language: str = "Python",
        prompt_type: str = "basic",
        include_comments: bool = True,
        include_validation: bool = True,
        use_function: bool = True,
        explain_code: bool = True,
        include_sample_io: bool = True,
        custom_prompt: Optional[str] = None
    ) -> str:
        """
        Builds basic or optimized code generation prompts.
        """
        clean_problem = problem_statement.strip()
        clean_lang = language.strip() if language.strip() else "Python"

        if custom_prompt and custom_prompt.strip():
            return custom_prompt.strip()

        if prompt_type.lower() == "basic":
            return f"Write {clean_lang} code to: {clean_problem}"

        req_list = []
        if use_function:
            req_list.append("• Modularize the logic inside clean, reusable functions.")
        if include_validation:
            req_list.append("• Include input validation and edge-case handling (e.g., negative/zero values).")
        if include_comments:
            req_list.append("• Include concise inline code comments explaining non-trivial logic.")
        if include_sample_io:
            req_list.append("• Provide example input and expected output execution demonstrations.")
        if explain_code:
            req_list.append("• Include a brief, structured code explanation after the program.")

        reqs_formatted = "\n".join(req_list) if req_list else "• Write clean, production-ready code."

        return f"""Write a complete, high-quality {clean_lang} program for the following problem statement:

Problem Statement:
{clean_problem}

Technical & Quality Requirements:
{reqs_formatted}

Format Guidelines:
- Place all executable code inside a clean ```{clean_lang.lower()} code block.
- Follow standard PEP8 / language style guidelines.
- Provide a clear explanation section after the code block."""
