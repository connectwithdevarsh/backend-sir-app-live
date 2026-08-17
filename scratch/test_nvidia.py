import os
import requests
from dotenv import load_dotenv

load_dotenv(r"c:\Users\soham\OneDrive\Desktop\SIR\backend\.env", override=True)
nvidia = os.getenv("NVIDIA_API_KEY", "")

url = "https://integrate.api.nvidia.com/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {nvidia}",
    "Content-Type": "application/json"
}
payload = {
    "model": "meta/llama-3.1-8b-instruct",
    "messages": [
        {"role": "system", "content": "You are a helpful educational AI assistant."},
        {"role": "user", "content": "Explain Artificial Intelligence in 2 sentences."}
    ],
    "temperature": 0.5,
    "max_tokens": 512
}

print("Sending request to NVIDIA NIM API (meta/llama-3.1-8b-instruct)...")
r = requests.post(url, json=payload, headers=headers, timeout=15)
print("Status:", r.status_code)
if r.status_code == 200:
    print("RESPONSE:\n", r.json()['choices'][0]['message']['content'])
else:
    print("ERROR:", r.text)
