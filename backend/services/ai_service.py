import os
import time
import requests
from typing import List, Dict, Any
from dotenv import load_dotenv

load_dotenv()

class AIService:
    @staticmethod
    def generate_ai_response(prompt: str) -> dict:
        load_dotenv(override=True)
        groq_api_key = os.getenv("GROQ_API_KEY", "").strip()
        gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        nvidia_api_key = os.getenv("NVIDIA_API_KEY", "").strip()
        
        start_time = time.time()
        
        # 1. Try Groq AI (Ultra-fast LPU inference: ~400ms - 800ms)
        if groq_api_key and groq_api_key != "your_groq_api_key_here":
            groq_models = [
                "llama-3.3-70b-versatile",
                "llama-3.1-8b-instant",
                "mixtral-8x7b-32768",
                "gemma2-9b-it"
            ]
            for model_name in groq_models:
                try:
                    url = "https://api.groq.com/openai/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {groq_api_key}",
                        "Content-Type": "application/json"
                    }
                    payload = {
                        "model": model_name,
                        "messages": [
                            {"role": "system", "content": "You are a helpful educational AI assistant for an Artificial Intelligence laboratory subject."},
                            {"role": "user", "content": prompt}
                        ],
                        "temperature": 0.7,
                        "max_tokens": 1024
                    }
                    
                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    
                    if resp.status_code == 200:
                        data = resp.json()
                        choices = data.get("choices", [])
                        if choices and "message" in choices[0]:
                            text = choices[0]["message"].get("content", "")
                            return {
                                "success": True,
                                "output": text,
                                "response": text,
                                "provider": "groq",
                                "model": f"groq/{model_name}",
                                "executionTimeMs": elapsed_ms,
                                "error": None
                            }
                except Exception:
                    continue

        # 2. Try Google Gemini API (Fast fallback with strict timeout)
        if gemini_api_key and gemini_api_key != "your_gemini_api_key_here":
            gemini_models = ["gemini-flash-latest", "gemini-2.5-flash-lite"]
            for model_name in gemini_models:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_api_key}"
                    headers = {"Content-Type": "application/json"}
                    payload = {
                        "contents": [
                            {
                                "parts": [
                                    {"text": prompt}
                                ]
                            }
                        ]
                    }
                    
                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    
                    if resp.status_code == 200:
                        data = resp.json()
                        candidates = data.get("candidates", [])
                        if candidates and "content" in candidates[0]:
                            parts = candidates[0]["content"].get("parts", [])
                            if parts and "text" in parts[0]:
                                text = parts[0]["text"]
                                return {
                                    "success": True,
                                    "output": text,
                                    "response": text,
                                    "provider": "gemini",
                                    "model": f"google/{model_name}",
                                    "executionTimeMs": elapsed_ms,
                                    "error": None
                                }
                except Exception:
                    continue

        # 3. Try NVIDIA Nemotron OpenAI-compatible API (Reliable NIM fallback)
        if nvidia_api_key and nvidia_api_key != "your_nvidia_api_key_here":
            nvidia_models = [
                "nvidia/llama-3.1-nemotron-70b-instruct",
                "meta/llama-3.1-70b-instruct",
                "nvidia/nemotron-4-340b-instruct"
            ]
            for model_name in nvidia_models:
                try:
                    url = "https://integrate.api.nvidia.com/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {nvidia_api_key}",
                        "Content-Type": "application/json"
                    }
                    payload = {
                        "model": model_name,
                        "messages": [
                            {"role": "system", "content": "You are a helpful educational AI assistant for an Artificial Intelligence laboratory subject."},
                            {"role": "user", "content": prompt}
                        ],
                        "temperature": 0.5,
                        "max_tokens": 1024
                    }
                    
                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    
                    if resp.status_code == 200:
                        data = resp.json()
                        choices = data.get("choices", [])
                        if choices and "message" in choices[0]:
                            text = choices[0]["message"].get("content", "")
                            return {
                                "success": True,
                                "output": text,
                                "response": text,
                                "provider": "nvidia",
                                "model": f"nvidia/{model_name}",
                                "executionTimeMs": elapsed_ms,
                                "error": None
                            }
                except Exception:
                    continue

        elapsed_ms = int((time.time() - start_time) * 1000)
        
        if not groq_api_key and not gemini_api_key and not nvidia_api_key:
            return {
                "success": False,
                "output": "API Key Missing: Please configure GROQ_API_KEY, GEMINI_API_KEY, or NVIDIA_API_KEY on the backend.",
                "response": "API Key Missing: Please configure GROQ_API_KEY, GEMINI_API_KEY, or NVIDIA_API_KEY on the backend.",
                "provider": "none",
                "model": "none",
                "executionTimeMs": elapsed_ms,
                "error": {
                    "code": "API_KEY_MISSING",
                    "message": "No API keys configured"
                }
            }
        
        return {
            "success": False,
            "output": "All configured AI providers (Groq, Gemini, NVIDIA Nemotron) are temporarily unavailable.",
            "response": "All configured AI providers (Groq, Gemini, NVIDIA Nemotron) are temporarily unavailable.",
            "provider": "failed",
            "model": "multi-provider",
            "executionTimeMs": elapsed_ms,
            "error": {
                "code": "AI_PROVIDER_UNAVAILABLE",
                "message": "All configured AI providers are temporarily unavailable."
            }
        }

    @staticmethod
    def generate_chat_response(messages: List[Dict[str, str]]) -> dict:
        """
        Executes multi-turn AI chatbot conversations maintaining context history across Groq, Gemini, and NVIDIA.
        """
        load_dotenv(override=True)
        groq_api_key = os.getenv("GROQ_API_KEY", "").strip()
        gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        nvidia_api_key = os.getenv("NVIDIA_API_KEY", "").strip()
        
        start_time = time.time()
        system_instruction = (
            "You are an AI assistant for students. "
            "Provide clear, accurate and concise educational answers. "
            "If you are uncertain, say so instead of inventing facts. "
            "Explain technical concepts in a student-friendly way."
        )

        recent_messages = messages[-20:] if len(messages) > 20 else messages

        # 1. Try Groq AI Chat API
        if groq_api_key and groq_api_key != "your_groq_api_key_here":
            groq_models = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant"]
            for model_name in groq_models:
                try:
                    url = "https://api.groq.com/openai/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {groq_api_key}",
                        "Content-Type": "application/json"
                    }
                    
                    formatted_msgs = [{"role": "system", "content": system_instruction}]
                    for msg in recent_messages:
                        role = "assistant" if msg.get("role") in ["assistant", "ai", "model"] else "user"
                        formatted_msgs.append({
                            "role": role,
                            "content": msg.get("content", "").strip()
                        })

                    payload = {
                        "model": model_name,
                        "messages": formatted_msgs,
                        "temperature": 0.7,
                        "max_tokens": 1024
                    }

                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)

                    if resp.status_code == 200:
                        data = resp.json()
                        choices = data.get("choices", [])
                        if choices and "message" in choices[0]:
                            content = choices[0]["message"].get("content", "")
                            return {
                                "success": True,
                                "message": {
                                    "role": "assistant",
                                    "content": content
                                },
                                "model": f"groq/{model_name}",
                                "provider": "groq",
                                "executionTimeMs": elapsed_ms,
                                "error": None
                            }
                except Exception:
                    continue

        # 2. Try Google Gemini Chat API
        if gemini_api_key and gemini_api_key != "your_gemini_api_key_here":
            gemini_models = ["gemini-flash-latest", "gemini-2.5-flash-lite"]
            for model_name in gemini_models:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_api_key}"
                    headers = {"Content-Type": "application/json"}
                    
                    gemini_contents = []
                    for msg in recent_messages:
                        role = "model" if msg.get("role") in ["assistant", "ai", "model"] else "user"
                        gemini_contents.append({
                            "role": role,
                            "parts": [{"text": msg.get("content", "").strip()}]
                        })

                    payload = {
                        "contents": gemini_contents,
                        "systemInstruction": {
                            "parts": [{"text": system_instruction}]
                        }
                    }

                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)

                    if resp.status_code == 200:
                        data = resp.json()
                        candidates = data.get("candidates", [])
                        if candidates and "content" in candidates[0]:
                            parts = candidates[0]["content"].get("parts", [])
                            if parts and "text" in parts[0]:
                                content = parts[0]["text"]
                                return {
                                    "success": True,
                                    "message": {
                                        "role": "assistant",
                                        "content": content
                                    },
                                    "model": f"google/{model_name}",
                                    "provider": "gemini",
                                    "executionTimeMs": elapsed_ms,
                                    "error": None
                                }
                except Exception:
                    continue

        # 3. Try NVIDIA Nemotron OpenAI-compatible Chat API
        if nvidia_api_key and nvidia_api_key != "your_nvidia_api_key_here":
            nvidia_models = ["nvidia/llama-3.1-nemotron-70b-instruct", "meta/llama-3.1-70b-instruct"]
            for model_name in nvidia_models:
                try:
                    url = "https://integrate.api.nvidia.com/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {nvidia_api_key}",
                        "Content-Type": "application/json"
                    }
                    
                    formatted_msgs = [{"role": "system", "content": system_instruction}]
                    for msg in recent_messages:
                        role = "assistant" if msg.get("role") in ["assistant", "ai", "model"] else "user"
                        formatted_msgs.append({
                            "role": role,
                            "content": msg.get("content", "").strip()
                        })

                    payload = {
                        "model": model_name,
                        "messages": formatted_msgs,
                        "temperature": 0.5,
                        "max_tokens": 1024
                    }

                    resp = requests.post(url, json=payload, headers=headers, timeout=10)
                    elapsed_ms = int((time.time() - start_time) * 1000)

                    if resp.status_code == 200:
                        data = resp.json()
                        choices = data.get("choices", [])
                        if choices and "message" in choices[0]:
                            content = choices[0]["message"].get("content", "")
                            return {
                                "success": True,
                                "message": {
                                    "role": "assistant",
                                    "content": content
                                },
                                "model": f"nvidia/{model_name}",
                                "provider": "nvidia",
                                "executionTimeMs": elapsed_ms,
                                "error": None
                            }
                except Exception:
                    continue

        elapsed_ms = int((time.time() - start_time) * 1000)

        if not groq_api_key and not gemini_api_key and not nvidia_api_key:
            return {
                "success": False,
                "message": {
                    "role": "assistant",
                    "content": "API Key Missing: Please configure GROQ_API_KEY, GEMINI_API_KEY, or NVIDIA_API_KEY on backend."
                },
                "model": "none",
                "provider": "none",
                "executionTimeMs": elapsed_ms,
                "error": {
                    "code": "API_KEY_MISSING",
                    "message": "No API keys configured"
                }
            }

        return {
            "success": False,
            "message": {
                "role": "assistant",
                "content": "All configured AI providers (Groq, Gemini, NVIDIA Nemotron) are temporarily unavailable."
            },
            "model": "multi-provider",
            "provider": "failed",
            "executionTimeMs": elapsed_ms,
            "error": {
                "code": "AI_PROVIDER_UNAVAILABLE",
                "message": "All configured AI providers are temporarily unavailable."
            }
        }
