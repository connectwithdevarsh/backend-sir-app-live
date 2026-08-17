import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)

groq = os.getenv("GROQ_API_KEY", "")
gemini = os.getenv("GEMINI_API_KEY", "")
nvidia = os.getenv("NVIDIA_API_KEY", "")

# 1. Test Groq active models
print("=== TESTING GROQ ACTIVE MODELS ===")
groq_models = [
    "llama-3.3-70b-versatile",
    "llama-3.1-8b-instant",
    "llama-3.2-3b-preview",
    "llama-3.2-1b-preview",
    "llama-3.2-11b-vision-preview",
    "llama3-70b-8192",
    "qwen-2.5-32b",
    "deepseek-r1-distill-llama-70b"
]

for m in groq_models:
    try:
        r = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {groq}", "Content-Type": "application/json"},
            json={"model": m, "messages": [{"role": "user", "content": "Reply with exactly: GROQ_OK"}]},
            timeout=8
        )
        if r.status_code == 200:
            content = r.json()['choices'][0]['message']['content']
            print(f"[GROQ SUCCESS] Model '{m}': {content.strip()}")
        else:
            print(f"[GROQ FAIL] Model '{m}': HTTP {r.status_code} - {r.text[:100]}")
    except Exception as e:
        print(f"[GROQ ERR] Model '{m}': {e}")

# 2. Test Gemini active models
print("\n=== TESTING GEMINI ACTIVE MODELS ===")
gemini_models = [
    "gemini-1.5-flash-latest",
    "gemini-1.5-pro-latest",
    "gemini-2.0-flash-exp",
    "gemini-2.0-flash",
    "gemini-flash-latest"
]

for m in gemini_models:
    try:
        r = requests.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent?key={gemini}",
            headers={"Content-Type": "application/json"},
            json={"contents": [{"parts": [{"text": "Reply with exactly: GEMINI_OK"}]}]},
            timeout=8
        )
        if r.status_code == 200:
            content = r.json()['candidates'][0]['content']['parts'][0]['text']
            print(f"[GEMINI SUCCESS] Model '{m}': {content.strip()}")
        else:
            print(f"[GEMINI FAIL] Model '{m}': HTTP {r.status_code} - {r.text[:100]}")
    except Exception as e:
        print(f"[GEMINI ERR] Model '{m}': {e}")

# 3. Test NVIDIA active models
print("\n=== TESTING NVIDIA ACTIVE MODELS ===")
nvidia_models = [
    "meta/llama-3.1-70b-instruct",
    "meta/llama-3.1-8b-instruct",
    "meta/llama3-70b-instruct",
    "nvidia/llama-3.1-nemotron-70b-instruct"
]

for m in nvidia_models:
    try:
        r = requests.post(
            "https://integrate.api.nvidia.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {nvidia}", "Content-Type": "application/json"},
            json={"model": m, "messages": [{"role": "user", "content": "Reply with exactly: NVIDIA_OK"}]},
            timeout=8
        )
        if r.status_code == 200:
            content = r.json()['choices'][0]['message']['content']
            print(f"[NVIDIA SUCCESS] Model '{m}': {content.strip()}")
        else:
            print(f"[NVIDIA FAIL] Model '{m}': HTTP {r.status_code} - {r.text[:100]}")
    except Exception as e:
        print(f"[NVIDIA ERR] Model '{m}': {e}")
