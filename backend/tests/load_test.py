import asyncio
import time
import statistics
import sys
import os
from typing import List, Dict, Any

try:
    import httpx
except ImportError:
    print("Please install httpx to run load test: pip install httpx")
    sys.exit(1)

TARGET_URL = os.getenv("TARGET_URL", "https://backend-sir-app-live.onrender.com")

SAMPLE_REQUESTS = [
    {
        "endpoint": "/api/practical/1/run",
        "payload": {"prompt": "Explain the core concepts of Artificial Intelligence and Machine Learning in 2 sentences."}
    },
    {
        "endpoint": "/api/practical/2/analyze",
        "payload": {"text": "I really enjoyed this college AI practical lab session. The instructions were crystal clear and helpful.", "task": "sentiment"}
    },
    {
        "endpoint": "/api/practical/2/analyze",
        "payload": {"text": "TensorFlow and PyTorch GPU installation and neural network architecture training overview.", "task": "classification"}
    },
    {
        "endpoint": "/api/practical/3/run",
        "payload": {"task": "Translate the following English sentence to Hindi: 'Artificial Intelligence will transform education.'", "method": "zero_shot"}
    },
    {
        "endpoint": "/api/practical/5/run",
        "payload": {"prompt": "Write a 3-line Python function to compute the factorial of a number."}
    }
]

async def send_single_request(client: httpx.AsyncClient, user_id: int, request_info: dict) -> dict:
    url = f"{TARGET_URL.rstrip('/')}{request_info['endpoint']}"
    start_time = time.time()
    result = {
        "user_id": user_id,
        "endpoint": request_info['endpoint'],
        "status_code": 0,
        "success": False,
        "latency_ms": 0.0,
        "provider": "unknown",
        "error_code": None,
        "error_msg": None
    }
    
    try:
        resp = await client.post(url, json=request_info['payload'], timeout=95.0)
        elapsed_ms = (time.time() - start_time) * 1000.0
        result["latency_ms"] = elapsed_ms
        result["status_code"] = resp.status_code
        
        if resp.status_code == 200:
            data = resp.json()
            result["success"] = data.get("success", True)
            result["provider"] = data.get("provider", "unknown")
            if not result["success"]:
                err = data.get("error") or {}
                if isinstance(err, dict):
                    result["error_code"] = err.get("code")
                    result["error_msg"] = err.get("message")
        else:
            result["success"] = False
            result["error_msg"] = f"HTTP {resp.status_code}: {resp.text[:100]}"
            if resp.status_code == 429:
                result["error_code"] = "RATE_LIMIT_429"
            elif resp.status_code >= 500:
                result["error_code"] = f"SERVER_ERROR_{resp.status_code}"
                
    except httpx.TimeoutException:
        result["latency_ms"] = (time.time() - start_time) * 1000.0
        result["error_code"] = "TIMEOUT"
        result["error_msg"] = "Request timed out after 95s"
    except Exception as e:
        result["latency_ms"] = (time.time() - start_time) * 1000.0
        result["error_code"] = "CONNECTION_ERROR"
        result["error_msg"] = str(e)

    return result

async def run_burst_test(num_users: int) -> Dict[str, Any]:
    print(f"\n========================================================")
    print(f"  RUNNING BURST LOAD TEST: {num_users} SIMULTANEOUS USERS")
    print(f"  Target Server: {TARGET_URL}")
    print(f"========================================================")
    
    limits = httpx.Limits(max_keepalive_connections=50, max_connections=100)
    async with httpx.AsyncClient(limits=limits, timeout=95.0) as client:
        tasks = []
        for i in range(num_users):
            req_info = SAMPLE_REQUESTS[i % len(SAMPLE_REQUESTS)]
            tasks.append(send_single_request(client, i + 1, req_info))
            
        start_burst = time.time()
        results = await asyncio.gather(*tasks)
        total_burst_time = time.time() - start_burst

    # Calculate metrics
    latencies = [r["latency_ms"] for r in results]
    successes = [r for r in results if r["success"]]
    rate_limits = [r for r in results if r["error_code"] == "RATE_LIMIT_429"]
    server_errors = [r for r in results if r["status_code"] >= 500 or (r["error_code"] and "SERVER_ERROR" in str(r["error_code"]))]
    timeouts = [r for r in results if r["error_code"] == "TIMEOUT"]
    capacity_errors = [r for r in results if r["error_code"] == "AI_CAPACITY_TEMPORARY"]
    
    providers_count = {}
    for r in results:
        p = r["provider"]
        providers_count[p] = providers_count.get(p, 0) + 1
        
    latencies_sorted = sorted(latencies)
    avg_latency = statistics.mean(latencies) if latencies else 0.0
    p95_latency = latencies_sorted[int(len(latencies_sorted) * 0.95)] if latencies_sorted else 0.0
    p99_latency = latencies_sorted[int(len(latencies_sorted) * 0.99)] if latencies_sorted else 0.0

    print(f"\n--- BURST RESULTS FOR {num_users} CONCURRENT USERS ---")
    print(f"Total Burst Wall Duration : {total_burst_time:.2f} s")
    print(f"Successful Responses     : {len(successes)} / {num_users} ({len(successes)/num_users*100:.1f}%)")
    print(f"Average Latency          : {avg_latency:.1f} ms ({avg_latency/1000:.2f} s)")
    print(f"P95 Latency              : {p95_latency:.1f} ms ({p95_latency/1000:.2f} s)")
    print(f"P99 Latency              : {p99_latency:.1f} ms ({p99_latency/1000:.2f} s)")
    print(f"429 Rate Limit Errors    : {len(rate_limits)}")
    print(f"5xx Server Errors        : {len(server_errors)}")
    print(f"Timeout Errors (>95s)    : {len(timeouts)}")
    print(f"AI Capacity Busy Errors  : {len(capacity_errors)}")
    print(f"Provider Breakdown       : {providers_count}")
    print(f"--------------------------------------------------------\n")

    return {
        "num_users": num_users,
        "success_rate": len(successes) / num_users,
        "avg_latency_ms": avg_latency,
        "p95_latency_ms": p95_latency,
        "p99_latency_ms": p99_latency,
        "rate_limits": len(rate_limits),
        "server_errors": len(server_errors),
        "timeouts": len(timeouts),
        "providers": providers_count
    }

async def main():
    concurrency_levels = [10, 20, 30, 40]
    print(f"Starting AIPE LAB Backend High-Concurrency Load Simulation against {TARGET_URL}...\n")
    for level in concurrency_levels:
        await run_burst_test(level)
        await asyncio.sleep(2)  # Cooldown between test runs

if __name__ == "__main__":
    asyncio.run(main())
