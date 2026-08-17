import asyncio
import os
import sys

# Ensure backend path is registered
backend_dir = r"c:\Users\soham\OneDrive\Desktop\SIR\backend"
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from services.ai_service import AIService

async def test_all():
    print("=== TESTING PROVIDER HEALTH DIAGNOSTIC ENDPOINT ===")
    health = await AIService.get_provider_health_summary()
    print("Health Summary:", health)

    print("\n=== TESTING PRACTICAL 01 PROMPT GENERATION ===")
    prompt = "Explain the basics of Artificial Intelligence. Include 1. Definition of AI, 2. How AI works at a basic level."
    res = await AIService.generate_ai_response_async(prompt)
    print("Success:", res.get("success"))
    print("Provider:", res.get("provider"))
    print("Model:", res.get("model"))
    print("Execution Time:", res.get("executionTimeMs"), "ms")
    print("Response Output:\n", res.get("output")[:300])

if __name__ == "__main__":
    asyncio.run(test_all())
