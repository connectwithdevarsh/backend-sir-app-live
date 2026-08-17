import os
import sys
import time
import uuid
from datetime import datetime
from typing import List, Dict, Optional

# Ensure backend path is registered for Vercel imports
_backend_dir = os.path.dirname(os.path.abspath(__file__))
if _backend_dir not in sys.path:
    sys.path.insert(0, _backend_dir)

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

from services.ai_service import AIService
from services.nlp_service import NLPService
from services.prompt_builder import PromptBuilder
from services.chain_service import ChainService
from services.task_prompt_builder import TaskPromptBuilder
from services.software_prompt_builder import SoftwarePromptBuilder
from services.document_service import DocumentService
from services.chunking_service import ChunkingService
from services.retrieval_service import RetrievalService
from services.rag_service import RAGService
from services.study_prompt_builder import StudyPromptBuilder
from services.response_parser import ResponseParser
from services.evaluation_service import EvaluationService

load_dotenv()

app = FastAPI(
    title="AIPE LAB Backend Service",
    description="API server for Artificial Intelligence with Prompt Engineering (DI05016011)",
    version="1.0.0"
)

# Enable CORS for Flutter Web, Desktop, and Mobile Apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
@app.get("/api/health")
def health_check():
    return {
        "status": "online",
        "service": "AIPE LAB Backend Service",
        "subject": "Artificial Intelligence with Prompt Engineering (DI05016011)",
        "timestamp": datetime.now().isoformat()
    }

class PracticalRequest(BaseModel):
    prompt: str

class NLPRequest(BaseModel):
    text: str
    task: str = "sentiment"

class PromptExampleItem(BaseModel):
    input: str
    output: str

class Practical3Request(BaseModel):
    task: str
    method: str = "compare"
    examples: Optional[List[PromptExampleItem]] = []

class Practical4Request(BaseModel):
    category: str = "factual"
    query: str
    referenceAnswer: Optional[str] = ""

class Practical6Request(BaseModel):
    task: str
    method: str = "compare"
    examples: Optional[List[PromptExampleItem]] = []
    role: Optional[str] = ""
    audience: Optional[str] = ""
    tone: Optional[str] = ""
    constraints: Optional[str] = ""

class ChainStepItem(BaseModel):
    name: str
    prompt: str

class Practical7Request(BaseModel):
    task: str
    method: str = "compare"
    steps: Optional[List[ChainStepItem]] = []

class Practical8Request(BaseModel):
    taskType: str
    promptType: str
    input: str
    prompt: Optional[str] = ""
    language: Optional[str] = "Python"
    length: Optional[str] = "100 words"
    audience: Optional[str] = "Diploma IT Student"
    summaryFormat: Optional[str] = "Bullet Points"
    focus: Optional[str] = "Main Ideas"
    tone: Optional[str] = "Informative & Friendly"
    keywords: Optional[str] = ""
    includeComments: Optional[bool] = True
    includeValidation: Optional[bool] = True
    useFunction: Optional[bool] = True
    explainCode: Optional[bool] = True
    includeSampleIO: Optional[bool] = True

class Practical9Request(BaseModel):
    taskType: str
    language: Optional[str] = "Python"
    problem: Optional[str] = ""
    requirements: Optional[str] = ""
    code: Optional[str] = ""
    error: Optional[str] = ""
    expectedBehavior: Optional[str] = ""
    level: Optional[str] = "Beginner"
    focus: Optional[List[str]] = []
    prompt: Optional[str] = ""

class ChatMessageItem(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessageItem]

class RAGQueryRequest(BaseModel):
    documentId: str
    question: str

class StudyAssistantRequest(BaseModel):
    taskType: str  # "explain", "summary", "quiz", "study_plan", "flashcards"
    subject: Optional[str] = "Artificial Intelligence"
    topic: Optional[str] = "Machine Learning"
    content: Optional[str] = ""
    level: Optional[str] = "Beginner"
    style: Optional[str] = "Simple"
    includeExample: Optional[bool] = True
    summaryLength: Optional[str] = "Medium"
    summaryStyle: Optional[str] = "Bullet Points"
    questionCount: Optional[int] = 5
    difficulty: Optional[str] = "Medium"
    questionType: Optional[str] = "MCQ"
    subjects: Optional[List[str]] = ["AIPE", "Python", "JavaScript"]
    days: Optional[int] = 7
    hoursPerDay: Optional[float] = 2.0
    examDate: Optional[str] = ""
    priority: Optional[str] = "Balanced"
    cardCount: Optional[int] = 5
    prompt: Optional[str] = ""

@app.get("/")
def read_root():
    return {
        "status": "online",
        "app": "AIPE LAB Backend API",
        "subject": "Artificial Intelligence with Prompt Engineering",
        "subjectCode": "DI05016011"
    }

# Health Check Endpoints
@app.get("/api/health")
@app.get("/api/rag/health")
def check_health():
    groq_key = os.getenv("GROQ_API_KEY", "").strip()
    gemini_key = os.getenv("GEMINI_API_KEY", "").strip()
    nvidia_key = os.getenv("NVIDIA_API_KEY", "").strip()
    
    active_providers = []
    if groq_key and groq_key != "your_groq_api_key_here":
        active_providers.append("groq")
    if gemini_key and gemini_key != "your_gemini_api_key_here":
        active_providers.append("gemini")
    if nvidia_key and nvidia_key != "your_nvidia_api_key_here":
        active_providers.append("nvidia")

    active_provider = active_providers[0] if active_providers else "none"

    return {
        "status": "ok",
        "provider": active_provider,
        "activeProviders": active_providers,
        "vectorStore": "active",
        "serverTime": datetime.now().isoformat()
    }

# Step 2: Provider Health Diagnostic Endpoint (Never exposes keys)
@app.get("/api/ai/health")
async def check_ai_health():
    health_summary = await AIService.get_provider_health_summary()
    return health_summary

# Practical 1: Direct Generative AI Tool
@app.post("/api/practical/1/run")
async def run_practical_1(request: PracticalRequest):
    prompt_text = request.prompt.strip()
    if not prompt_text:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty.")
    return await AIService.generate_ai_response_async(prompt_text, task_tag="practical_1")

# Practical 2: Real AI-Powered NLP Analysis & Text Classification
@app.post("/api/practical/2/analyze")
async def run_practical_2(request: NLPRequest):
    input_text = request.text.strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Input text cannot be empty.")
    
    task = request.task.lower().strip()
    if task == "sentiment":
        prompt = (
            f"You are an expert NLP Sentiment Analyzer.\n"
            f"Analyze the sentiment of the following text:\n\n"
            f"\"{input_text}\"\n\n"
            f"Provide a structured, clear response in this format:\n"
            f"Sentiment: [POSITIVE / NEGATIVE / NEUTRAL]\n"
            f"Explanation: [Short 1-2 sentence explanation of why this sentiment was assigned]"
        )
        ai_res = await AIService.generate_ai_response_async(prompt, task_tag="practical_2_sentiment")
        output_text = ai_res.get("output", "") or ai_res.get("response", "")
        
        # Parse label
        label = "NEUTRAL"
        upper_out = output_text.upper()
        if "POSITIVE" in upper_out:
            label = "POSITIVE"
        elif "NEGATIVE" in upper_out:
            label = "NEGATIVE"
        elif "NEUTRAL" in upper_out:
            label = "NEUTRAL"
            
        return {
            "success": ai_res.get("success", True),
            "task": "sentiment",
            "label": label,
            "explanation": output_text,
            "output": output_text,
            "model": ai_res.get("model", "Groq/Gemini/NVIDIA"),
            "provider": ai_res.get("provider", "groq"),
            "executionTimeMs": ai_res.get("executionTimeMs", 0),
            "error": ai_res.get("error")
        }
    elif task in ["classification", "classify"]:
        prompt = (
            f"You are an expert NLP Text Classifier.\n"
            f"Classify the following text into one appropriate category (e.g. Technology & AI, Education & Academics, Business & Finance, Healthcare & Medicine, Customer Support, or General Discussion):\n\n"
            f"\"{input_text}\"\n\n"
            f"Provide a structured, clear response in this format:\n"
            f"Category: [Category Name]\n"
            f"Explanation: [Short 1-2 sentence explanation of why this text fits the category]"
        )
        ai_res = await AIService.generate_ai_response_async(prompt, task_tag="practical_2_classification")
        output_text = ai_res.get("output", "") or ai_res.get("response", "")
        
        # Extract Category Name if present
        label = "Text Classification"
        for line in output_text.splitlines():
            if "Category:" in line:
                label = line.replace("Category:", "").strip()
                break
        if label == "Text Classification" and output_text:
            first_line = output_text.splitlines()[0].replace("**", "").replace("##", "").strip()
            if first_line:
                label = first_line

        return {
            "success": ai_res.get("success", True),
            "task": "classification",
            "label": label,
            "explanation": output_text,
            "output": output_text,
            "model": ai_res.get("model", "Groq/Gemini/NVIDIA"),
            "provider": ai_res.get("provider", "groq"),
            "executionTimeMs": ai_res.get("executionTimeMs", 0),
            "error": ai_res.get("error")
        }
    else:
        raise HTTPException(status_code=400, detail=f"Invalid NLP task '{request.task}'.")

# Practical 3: Zero-Shot & Few-Shot Prompting Engine
@app.post("/api/practical/3/run")
def run_practical_3(request: Practical3Request):
    task_text = request.task.strip()
    if not task_text:
        raise HTTPException(status_code=400, detail="Task cannot be empty.")
    
    method = request.method.lower()
    examples_dict = [{"input": eg.input, "output": eg.output} for eg in (request.examples or [])]

    if method == "zero_shot":
        prompt = PromptBuilder.build_zero_shot_prompt(task_text)
        res = AIService.generate_ai_response(prompt)
        return {
            "success": res.get("success", False),
            "method": "zero_shot",
            "prompt": prompt,
            "output": res.get("output", ""),
            "model": res.get("model", ""),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }
    elif method == "few_shot":
        prompt = PromptBuilder.build_few_shot_prompt(task_text, examples_dict)
        res = AIService.generate_ai_response(prompt)
        return {
            "success": res.get("success", False),
            "method": "few_shot",
            "prompt": prompt,
            "output": res.get("output", ""),
            "model": res.get("model", ""),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }
    else:
        prompt_zero = PromptBuilder.build_zero_shot_prompt(task_text)
        res_zero = AIService.generate_ai_response(prompt_zero)

        prompt_few = PromptBuilder.build_few_shot_prompt(task_text, examples_dict)
        res_few = AIService.generate_ai_response(prompt_few)

        return {
            "success": res_zero.get("success", False) or res_few.get("success", False),
            "method": "compare",
            "results": [
                {
                    "method": "zero_shot",
                    "prompt": prompt_zero,
                    "output": res_zero.get("output", ""),
                    "model": res_zero.get("model", ""),
                    "executionTimeMs": res_zero.get("executionTimeMs", 0),
                    "success": res_zero.get("success", False),
                    "error": res_zero.get("error")
                },
                {
                    "method": "few_shot",
                    "prompt": prompt_few,
                    "output": res_few.get("output", ""),
                    "model": res_few.get("model", ""),
                    "executionTimeMs": res_few.get("executionTimeMs", 0),
                    "success": res_few.get("success", False),
                    "error": res_few.get("error")
                }
            ]
        }

# Practical 4: LLM Capability & Hallucination Evaluation
@app.post("/api/practical/4/evaluate")
def evaluate_practical_4(request: Practical4Request):
    query_text = request.query.strip()
    if not query_text:
        raise HTTPException(status_code=400, detail="Query cannot be empty.")

    ai_result = AIService.generate_ai_response(query_text)
    assisted_eval = EvaluationService.compare_reference(
        model_response=ai_result.get("response", ""),
        reference_answer=request.referenceAnswer,
        category=request.category
    )

    return {
        "success": True,
        "category": request.category,
        "query": query_text,
        "response": ai_result.get("response", ""),
        "model": ai_result.get("model", "unknown"),
        "executionTimeMs": ai_result.get("executionTimeMs", 0),
        "referenceAnswer": request.referenceAnswer or "",
        "assistedEvaluation": assisted_eval
    }

# Practical 5: Prompt Design & Refinement
@app.post("/api/practical/5/run")
def run_practical_5(request: PracticalRequest):
    prompt_text = request.prompt.strip()
    if not prompt_text:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty.")

    ai_result = AIService.generate_ai_response(prompt_text)
    return {
        "success": ai_result.get("success", True),
        "prompt": prompt_text,
        "output": ai_result.get("output", "") or ai_result.get("response", ""),
        "model": ai_result.get("model", "unknown"),
        "executionTimeMs": ai_result.get("executionTimeMs", 0),
        "error": ai_result.get("error")
    }

# Practical 6: Zero-Shot, Few-Shot & Role-Based Prompting
@app.post("/api/practical/6/run")
def run_practical_6(request: Practical6Request):
    task_text = request.task.strip()
    if not task_text:
        raise HTTPException(status_code=400, detail="Task cannot be empty.")

    method = request.method.lower().strip()

    if method == "zero_shot":
        built_prompt = PromptBuilder.build_zero_shot_prompt(task_text)
        res = AIService.generate_ai_response(built_prompt)
        return {
            "success": res.get("success", True),
            "method": "zero_shot",
            "prompt": built_prompt,
            "output": res.get("output", "") or res.get("response", ""),
            "model": res.get("model", "unknown"),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }

    elif method == "few_shot":
        ex_list = [{"input": e.input, "output": e.output} for e in (request.examples or [])]
        built_prompt = PromptBuilder.build_few_shot_prompt(task_text, ex_list)
        res = AIService.generate_ai_response(built_prompt)
        return {
            "success": res.get("success", True),
            "method": "few_shot",
            "prompt": built_prompt,
            "output": res.get("output", "") or res.get("response", ""),
            "model": res.get("model", "unknown"),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }

    elif method == "role_based":
        built_prompt = PromptBuilder.build_role_based_prompt(
            task=task_text,
            role=request.role or "",
            audience=request.audience or "",
            tone=request.tone or "",
            constraints=request.constraints or ""
        )
        res = AIService.generate_ai_response(built_prompt)
        return {
            "success": res.get("success", True),
            "method": "role_based",
            "prompt": built_prompt,
            "output": res.get("output", "") or res.get("response", ""),
            "model": res.get("model", "unknown"),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }

    elif method == "compare":
        prompt_zero = PromptBuilder.build_zero_shot_prompt(task_text)
        res_zero = AIService.generate_ai_response(prompt_zero)

        ex_list = [{"input": e.input, "output": e.output} for e in (request.examples or [])]
        prompt_few = PromptBuilder.build_few_shot_prompt(task_text, ex_list)
        res_few = AIService.generate_ai_response(prompt_few)

        prompt_role = PromptBuilder.build_role_based_prompt(
            task=task_text,
            role=request.role or "You are an experienced AI teacher explaining concepts to Diploma IT students.",
            audience=request.audience or "Diploma IT students",
            tone=request.tone or "Educational and clear",
            constraints=request.constraints or "Keep it structured"
        )
        res_role = AIService.generate_ai_response(prompt_role)

        return {
            "success": True,
            "method": "compare",
            "task": task_text,
            "results": [
                {
                    "method": "zero_shot",
                    "prompt": prompt_zero,
                    "output": res_zero.get("output", "") or res_zero.get("response", ""),
                    "model": res_zero.get("model", "unknown"),
                    "executionTimeMs": res_zero.get("executionTimeMs", 0),
                    "success": res_zero.get("success", False),
                    "error": res_zero.get("error")
                },
                {
                    "method": "few_shot",
                    "prompt": prompt_few,
                    "output": res_few.get("output", "") or res_few.get("response", ""),
                    "model": res_few.get("model", "unknown"),
                    "executionTimeMs": res_few.get("executionTimeMs", 0),
                    "success": res_few.get("success", False),
                    "error": res_few.get("error")
                },
                {
                    "method": "role_based",
                    "prompt": prompt_role,
                    "output": res_role.get("output", "") or res_role.get("response", ""),
                    "model": res_role.get("model", "unknown"),
                    "executionTimeMs": res_role.get("executionTimeMs", 0),
                    "success": res_role.get("success", False),
                    "error": res_role.get("error")
                }
            ]
        }
    else:
        raise HTTPException(status_code=400, detail=f"Invalid method '{request.method}'.")

# Practical 7: Advanced Prompting Techniques
@app.post("/api/practical/7/run")
def run_practical_7(request: Practical7Request):
    task_text = request.task.strip()
    if not task_text:
        raise HTTPException(
            status_code=400,
            detail="Task cannot be empty. Please enter a valid multi-step problem."
        )

    method = request.method.lower().strip()
    steps_list = [{"name": s.name, "prompt": s.prompt} for s in (request.steps or [])]

    if method == "structured_reasoning":
        built_prompt = PromptBuilder.build_structured_reasoning_prompt(task_text)
        res = AIService.generate_ai_response(built_prompt)
        return {
            "success": res.get("success", True),
            "method": "structured_reasoning",
            "prompt": built_prompt,
            "output": res.get("output", "") or res.get("response", ""),
            "model": res.get("model", "unknown"),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }

    elif method == "prompt_chaining":
        return ChainService.run_prompt_chain(task_text, steps_list)

    elif method in ["compare", "compare_both"]:
        built_prompt = PromptBuilder.build_structured_reasoning_prompt(task_text)
        res_struct = AIService.generate_ai_response(built_prompt)
        struct_data = {
            "success": res_struct.get("success", True),
            "method": "structured_reasoning",
            "prompt": built_prompt,
            "output": res_struct.get("output", "") or res_struct.get("response", ""),
            "model": res_struct.get("model", "unknown"),
            "executionTimeMs": res_struct.get("executionTimeMs", 0),
            "error": res_struct.get("error")
        }

        chain_data = ChainService.run_prompt_chain(task_text, steps_list)

        return {
            "success": struct_data.get("success", False) or chain_data.get("success", False),
            "method": "compare",
            "task": task_text,
            "structuredResult": struct_data,
            "chainResult": chain_data
        }

    else:
        raise HTTPException(status_code=400, detail=f"Invalid method '{request.method}'.")

# Practical 8: Task-Based Prompt Engineering
@app.post("/api/practical/8/run")
def run_practical_8(request: Practical8Request):
    input_text = request.input.strip()
    if not input_text:
        raise HTTPException(
            status_code=400,
            detail="Input content/topic/problem cannot be empty for task-based prompting."
        )

    task_type = request.taskType.lower().strip()
    prompt_type = request.promptType.lower().strip()

    actual_prompt = request.prompt.strip() if request.prompt and request.prompt.strip() else ""

    if not actual_prompt:
        if task_type == "summarization":
            actual_prompt = TaskPromptBuilder.build_summarization_prompt(
                source_text=input_text,
                prompt_type=prompt_type,
                length=request.length or "100 words",
                audience=request.audience or "Diploma IT Student",
                summary_format=request.summaryFormat or "Bullet Points",
                focus=request.focus or "Main Ideas"
            )
        elif task_type == "blog":
            actual_prompt = TaskPromptBuilder.build_blog_prompt(
                topic=input_text,
                prompt_type=prompt_type,
                audience=request.audience or "Students",
                tone=request.tone or "Informative & Friendly",
                length=request.length or "Medium (~600 words)",
                keywords=request.keywords or ""
            )
        elif task_type == "code":
            actual_prompt = TaskPromptBuilder.build_code_prompt(
                problem_statement=input_text,
                language=request.language or "Python",
                prompt_type=prompt_type,
                include_comments=request.includeComments if request.includeComments is not None else True,
                include_validation=request.includeValidation if request.includeValidation is not None else True,
                use_function=request.useFunction if request.useFunction is not None else True,
                explain_code=request.explainCode if request.explainCode is not None else True,
                include_sample_io=request.includeSampleIO if request.includeSampleIO is not None else True
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unsupported taskType '{request.taskType}'.")

    res = AIService.generate_ai_response(actual_prompt)

    return {
        "success": res.get("success", True),
        "taskType": task_type,
        "promptType": prompt_type,
        "prompt": actual_prompt,
        "output": res.get("output", "") or res.get("response", ""),
        "model": res.get("model", "unknown"),
        "executionTimeMs": res.get("executionTimeMs", 0),
        "error": res.get("error")
    }

# Practical 9: AI Software Development Assistant
@app.post("/api/practical/9/run")
def run_practical_9(request: Practical9Request):
    task_type = request.taskType.lower().strip()
    language = request.language or "Python"

    actual_prompt = request.prompt.strip() if request.prompt and request.prompt.strip() else ""

    if not actual_prompt:
        if task_type in ["code_generation", "generation"]:
            prob = request.problem or ""
            if not prob.strip():
                raise HTTPException(status_code=400, detail="Problem statement cannot be empty for Code Generation.")
            actual_prompt = SoftwarePromptBuilder.build_code_generation_prompt(
                language=language,
                problem=prob,
                requirements=request.requirements or ""
            )
        elif task_type in ["debugging", "debug"]:
            code_text = request.code or ""
            if not code_text.strip():
                raise HTTPException(status_code=400, detail="Source code cannot be empty for Debugging.")
            actual_prompt = SoftwarePromptBuilder.build_debugging_prompt(
                language=language,
                code=code_text,
                error=request.error or "Error analysis",
                expected_behavior=request.expectedBehavior or ""
            )
        elif task_type in ["code_explanation", "explanation"]:
            code_text = request.code or ""
            if not code_text.strip():
                raise HTTPException(status_code=400, detail="Source code cannot be empty for Code Explanation.")
            actual_prompt = SoftwarePromptBuilder.build_code_explanation_prompt(
                language=language,
                code=code_text,
                level=request.level or "Beginner",
                focus=request.focus or ["purpose", "flow", "logic"]
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unsupported taskType '{request.taskType}'.")

    res = AIService.generate_ai_response(actual_prompt)

    return {
        "success": res.get("success", True),
        "taskType": task_type,
        "prompt": actual_prompt,
        "output": res.get("output", "") or res.get("response", ""),
        "model": res.get("model", "unknown"),
        "executionTimeMs": res.get("executionTimeMs", 0),
        "error": res.get("error")
    }

# Practical 10: AI Chatbot via API Integration
@app.post("/api/chat")
@app.post("/api/practical/10/chat")
def run_chat_practical_10(request: ChatRequest):
    if not request.messages or len(request.messages) == 0:
        raise HTTPException(status_code=400, detail="Messages array cannot be empty.")

    raw_msgs = [{"role": msg.role, "content": msg.content} for msg in request.messages]
    res = AIService.generate_chat_response(raw_msgs)
    
    return {
        "success": res.get("success", True),
        "message": res.get("message", {"role": "assistant", "content": "No response."}),
        "model": res.get("model", "unknown"),
        "provider": res.get("provider", "unknown"),
        "executionTimeMs": res.get("executionTimeMs", 0),
        "error": res.get("error")
    }

# Practical 11: RAG Document Question Answering Endpoints
@app.post("/api/rag/upload")
@app.post("/api/practical/11/upload")
async def upload_rag_document(file: UploadFile = File(...)):
    filename = file.filename or "uploaded_document.txt"
    ext = filename.split(".")[-1].lower()

    if ext not in ["pdf", "txt"]:
        raise HTTPException(
            status_code=400,
            detail="Unsupported document format. Only .pdf and .txt files are supported."
        )

    file_bytes = await file.read()
    file_size = len(file_bytes)

    if file_size > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File is too large. Maximum size is 10 MB.")

    if ext == "pdf":
        pages = DocumentService.extract_pdf_text(file_bytes)
    else:
        pages = DocumentService.extract_txt_text(file_bytes)

    if not pages or not any(p.get("text", "").strip() for p in pages):
        raise HTTPException(
            status_code=400,
            detail="This document does not contain extractable text."
        )

    chunks = ChunkingService.create_chunks(pages, chunk_size=800, chunk_overlap=100)
    doc_id = f"doc_{uuid.uuid4().hex[:8]}"
    RetrievalService.index_document(doc_id, filename, chunks)

    return {
        "success": True,
        "documentId": doc_id,
        "filename": filename,
        "fileType": ext,
        "fileSize": file_size,
        "chunkCount": len(chunks),
        "status": "ready"
    }

@app.post("/api/rag/query")
@app.post("/api/practical/11/query")
def query_rag_document(request: RAGQueryRequest):
    doc_id = request.documentId.strip()
    question = request.question.strip()

    if not doc_id:
        raise HTTPException(status_code=400, detail="Document ID is required. Please upload a document first.")
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty.")

    return RAGService.answer_question(doc_id, question, top_k=4)

# Practical 12: AI Study Assistant Endpoints
@app.post("/api/study-assistant")
@app.post("/api/practical/12/run")
def run_study_assistant(request: StudyAssistantRequest):
    task_type = request.taskType.lower().strip()
    actual_prompt = request.prompt.strip() if request.prompt and request.prompt.strip() else ""

    if not actual_prompt:
        if task_type == "explain":
            actual_prompt = StudyPromptBuilder.build_explain_prompt(
                subject=request.subject or "Artificial Intelligence",
                topic=request.topic or "Machine Learning",
                level=request.level or "Beginner",
                style=request.style or "Simple",
                include_example=request.includeExample if request.includeExample is not None else True
            )
        elif task_type == "summary":
            mat = request.content or ""
            if not mat.strip():
                raise HTTPException(status_code=400, detail="Study material content cannot be empty for Summarize feature.")
            actual_prompt = StudyPromptBuilder.build_summary_prompt(
                content=mat,
                length=request.summaryLength or "Medium",
                style=request.summaryStyle or "Bullet Points"
            )
        elif task_type == "quiz":
            actual_prompt = StudyPromptBuilder.build_quiz_prompt(
                subject=request.subject or "Artificial Intelligence",
                topic=request.topic or "Prompt Engineering",
                question_count=request.questionCount or 5,
                difficulty=request.difficulty or "Medium",
                question_type=request.questionType or "MCQ"
            )
        elif task_type == "study_plan":
            actual_prompt = StudyPromptBuilder.build_study_plan_prompt(
                subjects=request.subjects or ["AIPE", "Python", "JavaScript"],
                days=request.days or 7,
                hours_per_day=request.hoursPerDay or 2.0,
                exam_date=request.examDate or "",
                priority=request.priority or "Balanced"
            )
        elif task_type == "flashcards":
            actual_prompt = StudyPromptBuilder.build_flashcard_prompt(
                subject=request.subject or "Artificial Intelligence",
                topic=request.topic or "Key Concepts",
                card_count=request.cardCount or 5
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unsupported taskType '{request.taskType}'.")

    # Call real LLM service
    res = AIService.generate_ai_response(actual_prompt)
    raw_output = res.get("output", "") or res.get("response", "")

    # Parse structured JSON for Quiz, Flashcards, or Study Plan
    parsed_data = {}
    if task_type == "quiz":
        parsed_data = ResponseParser.parse_quiz_response(raw_output)
    elif task_type == "flashcards":
        parsed_data = ResponseParser.parse_flashcard_response(raw_output)
    elif task_type == "study_plan":
        parsed_data = ResponseParser.parse_study_plan_response(raw_output)

    return {
        "success": res.get("success", True),
        "taskType": task_type,
        "prompt": actual_prompt,
        "result": raw_output,
        "parsedData": parsed_data,
        "model": res.get("model", "unknown"),
        "executionTimeMs": res.get("executionTimeMs", 0),
        "error": res.get("error")
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
