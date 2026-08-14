import '../models/practical_model.dart';

/// PracticalData provides the authoritative list of 12 AIPE practical experiments
/// based on the GTU Information Technology 5th Semester syllabus.
class PracticalData {
  static List<PracticalModel> getPracticals() {
    return [
      // Practical 01
      PracticalModel(
        id: 1,
        number: '01',
        displayTitle: '01 — Generative AI Tools',
        officialOutcome:
            'Use Generative AI tools to perform different types of tasks and document their applications in various domains.',
        aim: 'Explore and compare Generative AI capabilities for text, image, and code generation across education and industry domains.',
        category: 'AI Tools',
        taskDescription:
            'Demonstration experiment evaluating multi-modal AI output generation for academic research, creative writing, and documentation.',
        demoPromptOrCode: '''
[DEMO PROMPT]
Act as an Educational Researcher. List 3 key applications of Generative AI tools in Diploma Engineering education:
1. Automated Code Explanation
2. Personalized Quiz Generation
3. Interactive Concept Visualization
Provide a 1-sentence summary for each.
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
1. Automated Code Explanation: Instantly breaks down complex C++/Python syntax into student-friendly steps.
2. Personalized Quiz Generation: Creates adaptive practice questions tailored to 5th-sem GTU topics.
3. Interactive Concept Visualization: Generates diagrams & pseudo-code for Data Structures & AI algorithms.
--------------------------------------------------
Status: Demo evaluation complete. Domain applications documented.
''',
        isPythonCode: false,
      ),

      // Practical 02
      PracticalModel(
        id: 2,
        number: '02',
        displayTitle: '02 — NLP Tasks',
        officialOutcome:
            'Perform basic NLP-based tasks such as sentiment analysis and text classification using AI tools or Python libraries.',
        aim: 'Analyze text sentiment (Positive, Negative, Neutral) and classify technical feedback using Python NLTK / VADER.',
        category: 'NLP',
        taskDescription:
            'Demonstration experiment executing sentiment classification on student feedback regarding AI Prompt Engineering lectures.',
        demoPromptOrCode: '''
# DEMO PYTHON CODE (NLP Sentiment Analysis)
from nltk.sentiment import SentimentIntensityAnalyzer

feedback_text = "The AIPE prompt engineering lab was extremely engaging and clear!"

analyzer = SentimentIntensityAnalyzer()
scores = analyzer.polarity_scores(feedback_text)

print(f"Text: {feedback_text}")
print(f"Sentiment Scores: {scores}")
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Input: "The AIPE prompt engineering lab was extremely engaging and clear!"
Analysis:
 - Positive Score: 0.82
 - Neutral Score:  0.18
 - Negative Score: 0.00
 - Compound:       +0.762 (Highly Positive)
Classification: POSITIVE FEEDBACK
--------------------------------------------------
Status: NLP Text Classification completed.
''',
        isPythonCode: true,
      ),

      // Practical 03
      PracticalModel(
        id: 3,
        number: '03',
        displayTitle: '03 — LLM Behaviour',
        officialOutcome:
            'Perform experiments to analyze the behavior of LLM by testing prompt variations, context understanding and response consistency.',
        aim: 'Test response consistency, temperature variations, and context adherence under different prompt structures.',
        category: 'LLM',
        taskDescription:
            'Demonstration experiment comparing LLM outputs when given identical queries under strict vs open context instructions.',
        demoPromptOrCode: '''
[DEMO PROMPT VARIATION TEST]
Prompt A (Unstructured): "Explain neural networks."
Prompt B (Structured Context):
"Context: You are a Diploma IT Professor explaining to 5th-semester students.
Task: Explain Neural Networks in exactly 3 bullet points using an analogy of human brain neurons."
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Prompt A Output: Broad 400-word general technical breakdown.
Prompt B Output:
 • Input Layer: Acts like sensory receptors gathering input data.
 • Hidden Layers: Processes inputs through weighted mathematical nodes (synapses).
 • Output Layer: Produces the final prediction/decision.
Analysis: Structured context increased response precision and constraint adherence by 95%.
--------------------------------------------------
Status: LLM Behavior & Consistency evaluation completed.
''',
        isPythonCode: false,
      ),

      // Practical 04
      PracticalModel(
        id: 4,
        number: '04',
        displayTitle: '04 — LLM Capabilities & Limitations',
        officialOutcome:
            'Evaluate the capabilities and limitations of LLMs by testing factual, logical, and ambiguous queries and identifying hallucinations.',
        aim: 'Identify LLM hallucinations, logical reasoning boundaries, and factual accuracy limits.',
        category: 'LLM',
        taskDescription:
            'Demonstration experiment submitting trick queries (e.g. non-existent GTU syllabus codes) to test hallucination detection.',
        demoPromptOrCode: '''
[DEMO HALLUCINATION TEST QUERY]
Query: "Who was the GTU syllabus coordinator for AIPE in the year 1850?"

Analysis Criteria:
- Factual Check: GTU & AIPE did not exist in 1850.
- Expected Safe Behavior: Refusal / Temporal error identification.
- Hallucination Risk: Generating a fake historical figure name.
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Tested Query: "Who was the GTU syllabus coordinator for AIPE in 1850?"
LLM Response Evaluation:
 [✓] Correctly Detected Anachronism: Noted GTU was established in 2007.
 [✓] Avoided Hallucination: Refused to fabricate a 19th-century coordinator.
Limitation Identified: LLMs require grounding data to avoid confident false facts.
--------------------------------------------------
Status: Hallucination & capability evaluation completed.
''',
        isPythonCode: false,
      ),

      // Practical 05
      PracticalModel(
        id: 5,
        number: '05',
        displayTitle: '05 — Prompt Refinement',
        officialOutcome:
            'Design and refine prompts for tasks such as email writing and concept explanation. Compare outputs before and after prompt refinement.',
        aim: 'Refine raw prompts into structured, formatted prompts and evaluate output quality improvements.',
        category: 'Prompt Engineering',
        taskDescription:
            'Demonstration experiment comparing a raw email request against a refined, role-specified prompt.',
        demoPromptOrCode: '''
[BEFORE REFINEMENT - RAW PROMPT]
"Write an email to sir asking for lab extension."

[AFTER REFINEMENT - REFINED PROMPT]
"Role: Diploma IT Student
Recipient: AIPE Subject Coordinator
Subject: Request for 2-day Extension on AIPE Practical 5 Submission
Tone: Respectful, Academic
Details to Include: Subject Code DI05016011, specific reason (server setup delay), proposed submission date."
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Before Output: Generic 2-line casual request lacking subject code and context.
After Output:
 Subject: Request for Extension - AIPE Lab Practical 5 (DI05016011)
 Dear Professor,
 I am writing to request a brief 2-day extension for Practical 05 due to environment configuration delays...
Comparison: Refined prompt yielded a professional, complete academic email.
--------------------------------------------------
Status: Prompt refinement comparison complete.
''',
        isPythonCode: false,
      ),

      // Practical 06
      PracticalModel(
        id: 6,
        number: '06',
        displayTitle: '06 — Prompting Techniques',
        officialOutcome:
            'Apply prompting techniques such as zero-shot, few-shot, and role-based prompting.',
        aim: 'Implement Zero-Shot, Few-Shot, and Role-Based prompting patterns to solve technical tasks.',
        category: 'Prompt Engineering',
        taskDescription:
            'Demonstration experiment executing a Few-Shot Prompt for converting English descriptions into SQL queries.',
        demoPromptOrCode: '''
[DEMO FEW-SHOT PROMPT]
Task: Convert plain text into SQL queries.

Example 1:
Input: "Find all students in IT branch."
Output: SELECT * FROM students WHERE branch = 'IT';

Example 2:
Input: "Get total count of 5th semester students."
Output: SELECT COUNT(*) FROM students WHERE semester = 5;

Test Input:
Input: "Find all students enrolled in subject code DI05016011."
Output:
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Technique Applied: Few-Shot Prompting (2 Exemplars)
Generated Output:
 SELECT * FROM students WHERE subject_code = 'DI05016011';

Evaluation: Exact pattern matching achieved on first attempt without system fine-tuning.
--------------------------------------------------
Status: Prompting techniques (Few-Shot) validated.
''',
        isPythonCode: false,
      ),

      // Practical 07
      PracticalModel(
        id: 7,
        number: '07',
        displayTitle: '07 — Advanced Prompting',
        officialOutcome:
            'Apply advanced prompting techniques such as chain-of-thought and prompt chaining to solve multi-step problems.',
        aim: 'Utilize Chain-of-Thought (CoT) prompting to break down complex algorithmic problems into explicit reasoning steps.',
        category: 'Prompt Engineering',
        taskDescription:
            'Demonstration experiment solving a multi-step logical calculation using step-by-step reasoning triggers.',
        demoPromptOrCode: '''
[DEMO CHAIN-OF-THOUGHT (CoT) PROMPT]
Problem: "A lab has 30 computers. 20% are offline. Half of the online computers are running Linux, and the rest Windows. How many computers are running Windows?"

Instruction: Think step-by-step before providing the final answer.
Step 1: Calculate total offline computers.
Step 2: Calculate remaining online computers.
Step 3: Divide online computers between Linux and Windows.
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Reasoning Trace:
 • Step 1: 20% of 30 = 6 computers offline.
 • Step 2: 30 - 6 = 24 computers online.
 • Step 3: Half of 24 = 12 computers running Linux, 12 running Windows.
Final Answer: 12 computers are running Windows.
--------------------------------------------------
Status: Chain-of-Thought reasoning verified.
''',
        isPythonCode: false,
      ),

      // Practical 08
      PracticalModel(
        id: 8,
        number: '08',
        displayTitle: '08 — Task-Based Prompt Engineering',
        officialOutcome:
            'Perform task-based prompt engineering for summarization, blog generation, and code generation. Optimize prompts for better output.',
        aim: 'Optimize task-specific prompts for technical text summarization, blog drafting, and Python code generation.',
        category: 'Prompt Engineering',
        taskDescription:
            'Demonstration experiment optimizing a summarization prompt with explicit constraints (bullet count, length, key terms).',
        demoPromptOrCode: '''
[DEMO TASK OPTIMIZED PROMPT - SUMMARIZATION]
Text: "Prompt engineering is the practice of structuring text that can be interpreted and understood by a generative AI model. It requires understanding model capabilities, context windows, and instruction formatting..."

Optimization Constraints:
- Length: Max 30 words
- Format: 2 Bullet Points
- Highlight: "Context" and "Formatting"
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
Optimized Summary Output:
 • Prompt engineering structures text inputs to guide generative AI model outputs effectively.
 • Key components include understanding model context constraints and precise instruction formatting.
--------------------------------------------------
Status: Task-based prompt optimization verified.
''',
        isPythonCode: false,
      ),

      // Practical 09
      PracticalModel(
        id: 9,
        number: '09',
        displayTitle: '09 — AI for Software Development',
        officialOutcome:
            'Use AI tools for software development tasks such as code generation, debugging, and code explanation.',
        aim: 'Utilize AI assistants to debug syntax/logic errors and generate unit tests for Dart/Python code.',
        category: 'AI Tools',
        taskDescription:
            'Demonstration experiment using AI debugging prompt to fix a faulty Python loop and explain the bug.',
        demoPromptOrCode: '''
[DEMO AI DEBUGGING PROMPT]
Buggy Code:
def calculate_average(scores):
    total = 0
    for i in range(len(scores)):
        total += scores[i]
    return total / len(scores)  # Fails if scores list is empty!

Task: Identify the edge-case bug, explain why it occurs, and provide the fixed code.
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
AI Diagnosis:
 Bug: ZeroDivisionError occurs when `scores` is an empty list `[]`.
 Fixed Code:
 def calculate_average(scores):
     if not scores:
         return 0.0
     return sum(scores) / len(scores)
--------------------------------------------------
Status: AI Software Development & Debugging demonstration complete.
''',
        isPythonCode: true,
      ),

      // Practical 10
      PracticalModel(
        id: 10,
        number: '10',
        displayTitle: '10 — AI Chatbot',
        officialOutcome:
            'Develop a simple AI chatbot using API integration (OpenAI/Gemini) with Python.',
        aim: 'Build a Python chatbot interface connecting to LLM APIs with conversation history management.',
        category: 'AI Applications',
        taskDescription:
            'Demonstration code structure for an API-driven Python chatbot using the Google Gemini / OpenAI Python SDK.',
        demoPromptOrCode: '''
# DEMO PYTHON CODE (AI Chatbot API Concept)
import google.generativeai as genai

# API key will be loaded securely from environment in Phase 3
genai.configure(api_key="YOUR_GEMINI_API_KEY")

model = genai.GenerativeModel("gemini-1.5-flash")
chat = model.start_chat(history=[])

response = chat.send_message("Hello! I am an AIPE IT student.")
print(response.text)
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
[STATUS] API integration (OpenAI/Gemini) will be connected in a later phase.

Demonstration Chat Response:
"Hello! Welcome to AIPE Lab. How can I assist you with your 5th-semester Prompt Engineering studies today?"
--------------------------------------------------
''',
        isPythonCode: true,
        requiresApi: true,
        apiNotice:
            'API integration (OpenAI/Gemini) will be implemented in a later phase.',
      ),

      // Practical 11
      PracticalModel(
        id: 11,
        number: '11',
        displayTitle: '11 — Document Q&A / Basic RAG',
        officialOutcome:
            'Build a document-based question-answering system using AI APIs. (Basic RAG concept)',
        aim: 'Implement Retrieval-Augmented Generation (RAG) by embedding GTU syllabus PDFs and querying context.',
        category: 'AI Applications',
        taskDescription:
            'Demonstration concept illustrating vector embeddings, similarity search, and context injection into LLM prompts.',
        demoPromptOrCode: '''
# DEMO RAG PIPELINE ARCHITECTURE (Python / LangChain)
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS

# 1. Load AIPE Syllabus PDF
loader = PyPDFLoader("AIPE_Syllabus_DI05016011.pdf")
docs = loader.load_and_split()

# 2. Query Vector Store
# query = "What is the subject code for AIPE?"
# retrieved_chunks = vectorstore.similarity_search(query)
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
[STATUS] Document-based RAG pipeline and vector search will be implemented in a later phase.

Demonstration RAG Answer:
Retrieved Context: "Subject Code: DI05016011 | Subject: Artificial Intelligence with Prompt Engineering"
System Answer: The official GTU subject code for AIPE is DI05016011.
--------------------------------------------------
''',
        isPythonCode: true,
        requiresApi: true,
        apiNotice:
            'Document-based RAG pipeline and vector search will be implemented in a later phase.',
      ),

      // Practical 12
      PracticalModel(
        id: 12,
        number: '12',
        displayTitle: '12 — AI-Based Application',
        officialOutcome:
            'Develop an AI-based application such as a Study Assistant, Resume Generator, Blog writer, or Coding assistant.',
        aim: 'Design and deploy a full-featured AI Study Assistant application for Diploma Engineering students.',
        category: 'AI Applications',
        taskDescription:
            'Demonstration architecture for an AI Study Assistant combining prompt templates, user input, and output formatting.',
        demoPromptOrCode: '''
# DEMO APP ARCHITECTURE (AI Study Assistant Module)
class AipeStudyAssistant:
    def generate_study_plan(self, topic, days_left):
        prompt = f"""
        Role: AI Study Assistant
        Topic: {topic} (Subject Code: DI05016011)
        Timeframe: {days_left} Days
        Generate a day-by-day revision schedule with practice prompts.
        """
        return prompt
''',
        demoOutput: '''
DEMO EXECUTION RESULT:
--------------------------------------------------
[STATUS] Full AI Application suite backend will be integrated in a later phase.

Demonstration Study Assistant Output:
Day 1: Generative AI Tools & NLP Fundamentals
Day 2: Zero-Shot, Few-Shot & Chain-of-Thought Prompt Engineering
Day 3: Practical 1-12 Revision & Lab Demonstration
--------------------------------------------------
''',
        isPythonCode: true,
        requiresApi: true,
        apiNotice:
            'Full AI Application suite backend will be integrated in a later phase.',
      ),
    ];
  }
}
