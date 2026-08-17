import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)
gemini = os.getenv("GEMINI_API_KEY", "")

test_urls = [
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent",
    "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent",
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent",
]

for url in test_urls:
    print(f"\nTesting URL: {url}")
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": gemini
    }
    payload = {
        "contents": [{"parts": [{"text": "Reply with exactly: GEMINI_OK"}]}]
    }
    try:
        r = requests.post(url, json=payload, headers=headers, timeout=10)
        print("Status Code:", r.status_code)
        if r.status_code == 200:
            print("SUCCESS! Output:\n", r.json()['candidates'][0]['content']['parts'][0]['text'])
        else:
            print("RESPONSE:", r.text[:200])
    except Exception as e:
        print("ERROR:", e)
