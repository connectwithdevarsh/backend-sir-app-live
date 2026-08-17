import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)

groq = os.getenv("GROQ_API_KEY", "")
gemini = os.getenv("GEMINI_API_KEY", "")
nvidia = os.getenv("NVIDIA_API_KEY", "")

print("GROQ KEY:", groq[:12] if groq else "EMPTY")
print("GEMINI KEY:", gemini[:12] if gemini else "EMPTY")
print("NVIDIA KEY:", nvidia[:12] if nvidia else "EMPTY")
print("=" * 60)

# 1. Test Groq
print("\n[1] Testing Groq...")
try:
    r1 = requests.post(
        "https://api.groq.com/openai/v1/chat/completions",
        headers={"Authorization": f"Bearer {groq}", "Content-Type": "application/json"},
        json={"model": "llama-3.3-70b-versatile", "messages": [{"role": "user", "content": "Hi"}]},
        timeout=10
    )
    print("Groq Status:", r1.status_code)
    print("Groq Response:", r1.text[:300])
except Exception as e:
    print("Groq Exception:", e)

# 2. Test Gemini
print("\n[2] Testing Gemini...")
try:
    r2 = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={gemini}",
        headers={"Content-Type": "application/json"},
        json={"contents": [{"parts": [{"text": "Hi"}]}]},
        timeout=10
    )
    print("Gemini Status:", r2.status_code)
    print("Gemini Response:", r2.text[:300])
except Exception as e:
    print("Gemini Exception:", e)

# 3. Test NVIDIA
print("\n[3] Testing NVIDIA...")
try:
    r3 = requests.post(
        "https://integrate.api.nvidia.com/v1/chat/completions",
        headers={"Authorization": f"Bearer {nvidia}", "Content-Type": "application/json"},
        json={"model": "nvidia/llama-3.1-nemotron-70b-instruct", "messages": [{"role": "user", "content": "Hi"}]},
        timeout=10
    )
    print("NVIDIA Status:", r3.status_code)
    print("NVIDIA Response:", r3.text[:300])
except Exception as e:
    print("NVIDIA Exception:", e)
