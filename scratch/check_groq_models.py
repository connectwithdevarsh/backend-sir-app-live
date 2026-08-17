import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)
groq = os.getenv("GROQ_API_KEY", "")

try:
    r = requests.get(
        "https://api.groq.com/openai/v1/models",
        headers={"Authorization": f"Bearer {groq}"},
        timeout=10
    )
    print("Groq Models Status:", r.status_code)
    if r.status_code == 200:
        models = [m['id'] for m in r.json().get('data', [])]
        print("Active Groq Models:", models)
    else:
        print("Error:", r.text)
except Exception as e:
    print("Exception:", e)
