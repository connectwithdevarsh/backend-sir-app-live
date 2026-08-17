import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)

groq = os.getenv("GROQ_API_KEY", "")
gemini = os.getenv("GEMINI_API_KEY", "")
nvidia = os.getenv("NVIDIA_API_KEY", "")

# 1. Test Groq Models
print("=== TESTING GROQ MODELS ===")
groq_test_models = [
    "llama-3.3-70b-versatile",
    "llama3-70b-8192",
    "llama3-8b-8192",
    "llama-3.1-8b-instant",
    "mixtral-8x7b-32768",
    "gemma2-9b-it"
]
for m in groq_test_models:
    try:
        r = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {groq}", "Content-Type": "application/json"},
            json={"model": m, "messages": [{"role": "user", "content": "Hello"}]},
            timeout=8
        )
        print(f"Groq [{m}]: status={r.status_code}")
        if r.status_code == 200:
            print(f"  -> SUCCESS! Output: {r.json()['choices'][0]['message']['content'][:60]}")
        else:
            print(f"  -> FAIL: {r.text[:120]}")
    except Exception as e:
        print(f"Groq [{m}]: Exception={e}")

# 2. Test Gemini Models
print("\n=== TESTING GEMINI MODELS ===")
gemini_test_models = [
    "gemini-1.5-flash",
    "gemini-1.5-pro",
    "gemini-flash-latest"
]
for m in gemini_test_models:
    try:
        r = requests.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent?key={gemini}",
            headers={"Content-Type": "application/json"},
            json={"contents": [{"parts": [{"text": "Hello"}]}]},
            timeout=8
        )
        print(f"Gemini [{m}]: status={r.status_code}")
        if r.status_code == 200:
            print(f"  -> SUCCESS! Output: {r.json()['candidates'][0]['content']['parts'][0]['text'][:60]}")
        else:
            print(f"  -> FAIL: {r.text[:120]}")
    except Exception as e:
        print(f"Gemini [{m}]: Exception={e}")

# 3. Test NVIDIA Models
print("\n=== TESTING NVIDIA MODELS ===")
nvidia_test_models = [
    "nvidia/llama-3.1-nemotron-70b-instruct",
    "meta/llama-3.1-8b-instruct",
    "meta/llama-3.1-70b-instruct",
    "meta/llama3-70b-instruct",
    "nvidia/nemotron-4-340b-instruct"
]
for m in nvidia_test_models:
    try:
        r = requests.post(
            "https://integrate.api.nvidia.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {nvidia}", "Content-Type": "application/json"},
            json={"model": m, "messages": [{"role": "user", "content": "Hello"}]},
            timeout=8
        )
        print(f"NVIDIA [{m}]: status={r.status_code}")
        if r.status_code == 200:
            print(f"  -> SUCCESS! Output: {r.json()['choices'][0]['message']['content'][:60]}")
        else:
            print(f"  -> FAIL: {r.text[:120]}")
    except Exception as e:
        print(f"NVIDIA [{m}]: Exception={e}")
