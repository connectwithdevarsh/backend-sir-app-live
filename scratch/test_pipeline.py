import asyncio
import os
import sys

# Ensure backend path is registered for imports
backend_dir = r"c:\Users\soham\OneDrive\Desktop\SIR\backend"
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from services.ai_service import AIService

async def test_all():
    print("\n========================================================")
    print("  AIPE LAB BACKEND LIVE DIAGNOSTIC & GENERATION TEST")
    print("========================================================\n")

    # 1. Test Provider Health
    print("[STEP 1] Testing /api/ai/health provider status...")
    health = await AIService.get_provider_health_summary()
    print("Provider Health Summary:")
    for provider, details in health.items():
        status_str = details.get("status", "")
        status_icon = "[OK] HEALTHY" if status_str == "healthy" else f"[FAIL] {status_str}"
        print(f"  - {provider.upper()}: Configured={details.get('configured')}, Status={status_icon}")

    # 2. Test Real Prompt Execution (Practical 01)
    print("\n[STEP 2] Executing Practical 01 AI Prompt Generation...")
    prompt = "Explain the basics of Artificial Intelligence. Include 1. Definition of AI, 2. How AI works at a basic level."
    res = await AIService.generate_ai_response_async(prompt)

    print("\n------------------- EXECUTION RESULT -------------------")
    print("Success         :", res.get("success"))
    print("Provider Used   :", res.get("provider"))
    print("Model ID        :", res.get("model"))
    print("Execution Time  :", res.get("executionTimeMs"), "ms")
    print("\n--- AI RESPONSE OUTPUT ---")
    output_text = res.get("output", "")
    print(output_text[:500] + ("..." if len(output_text) > 500 else ""))
    print("--------------------------------------------------------\n")

if __name__ == "__main__":
    asyncio.run(test_all())
