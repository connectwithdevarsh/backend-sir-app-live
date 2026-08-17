import os
import time
import json
import random
import asyncio
import hashlib
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv
import httpx

load_dotenv()

# ============================================================================
# PRODUCTION CONCURRENCY, QUEUE & CACHE CONFIGURATION
# ============================================================================
def _get_env_int(key: str, default: int) -> int:
    try:
        val = os.getenv(key, "").strip()
        return int(val) if val else default
    except Exception:
        return default

MAX_AI_CONCURRENCY = _get_env_int("MAX_AI_CONCURRENCY", 5)
AI_QUEUE_TIMEOUT = _get_env_int("AI_QUEUE_TIMEOUT", 90)
CACHE_TTL_SECONDS = _get_env_int("CACHE_TTL_SECONDS", 300)

# Global Semaphore for controlling concurrency across burst requests (30-40 students)
_concurrency_semaphore: Optional[asyncio.Semaphore] = None

def _get_semaphore() -> asyncio.Semaphore:
    global _concurrency_semaphore
    if _concurrency_semaphore is None:
        _concurrency_semaphore = asyncio.Semaphore(MAX_AI_CONCURRENCY)
    return _concurrency_semaphore

# Global Shared Async HTTP Client for Connection Pooling
_async_http_client: Optional[httpx.AsyncClient] = None

def _get_http_client() -> httpx.AsyncClient:
    global _async_http_client
    if _async_http_client is None or _async_http_client.is_closed:
        limits = httpx.Limits(max_keepalive_connections=20, max_connections=50)
        _async_http_client = httpx.AsyncClient(limits=limits, timeout=12.0)
    return _async_http_client

# Short-Lived TTL Response Cache: { cache_key: (response_dict, expire_timestamp) }
_response_cache: Dict[str, tuple[dict, float]] = {}

# In-flight Request Coalescing: { cache_key: asyncio.Future }
_in_flight_futures: Dict[str, asyncio.Future] = {}

# ============================================================================
# PROVIDER CIRCUIT BREAKER & HEALTH TRACKING
# ============================================================================
class ProviderCircuitBreaker:
    def __init__(self, name: str, cooldown_seconds: float = 60.0):
        self.name = name
        self.state = "HEALTHY"  # "HEALTHY", "DEGRADED", "OPEN"
        self.consecutive_failures = 0
        self.cooldown_until = 0.0
        self.cooldown_seconds = cooldown_seconds

    def is_available(self) -> bool:
        now = time.time()
        if self.state == "OPEN":
            if now >= self.cooldown_until:
                self.state = "DEGRADED"
                return True
            return False
        return True

    def record_success(self):
        self.consecutive_failures = 0
        self.state = "HEALTHY"

    def record_failure(self, is_rate_limit: bool = False):
        self.consecutive_failures += 1
        if is_rate_limit or self.consecutive_failures >= 3:
            self.state = "OPEN"
            self.cooldown_until = time.time() + self.cooldown_seconds

_circuit_breakers = {
    "groq": ProviderCircuitBreaker("groq"),
    "gemini": ProviderCircuitBreaker("gemini"),
    "nvidia": ProviderCircuitBreaker("nvidia"),
}

# ============================================================================
# MAIN AI SERVICE CLASS
# ============================================================================
class AIService:
    @staticmethod
    def _compute_cache_key(task: str, prompt: str) -> str:
        raw = f"{task.strip().lower()}:{prompt.strip()}"
        return hashlib.sha256(raw.encode('utf-8')).hexdigest()

    @classmethod
    async def generate_ai_response_async(cls, prompt: str, task_tag: str = "general") -> dict:
        """
        Production-grade async AI generator designed for 30-40 student burst loads.
        Includes: Response Cache -> Request Coalescing -> Concurrency Semaphore -> Circuit Breaker -> Provider Router.
        """
        load_dotenv(override=True)
        start_time = time.time()
        cache_key = cls._compute_cache_key(task_tag, prompt)

        # 1. Check TTL Response Cache (5-Minute TTL)
        now = time.time()
        if cache_key in _response_cache:
            cached_resp, expire_time = _response_cache[cache_key]
            if now < expire_time:
                result = dict(cached_resp)
                result["executionTimeMs"] = int((now - start_time) * 1000)
                result["cached"] = True
                return result
            else:
                del _response_cache[cache_key]

        # 2. Request Coalescing (In-flight deduplication for identical simultaneous student requests)
        if cache_key in _in_flight_futures:
            try:
                shared_result = await asyncio.shield(_in_flight_futures[cache_key])
                result = dict(shared_result)
                result["executionTimeMs"] = int((time.time() - start_time) * 1000)
                result["coalesced"] = True
                return result
            except Exception:
                pass

        # Register in-flight future for request deduplication
        loop = asyncio.get_running_loop()
        future = loop.create_future()
        _in_flight_futures[cache_key] = future

        try:
            # 3. Server-side Concurrency Semaphore & Queue Control
            semaphore = _get_semaphore()
            try:
                await asyncio.wait_for(semaphore.acquire(), timeout=float(AI_QUEUE_TIMEOUT))
            except asyncio.TimeoutError:
                err_resp = {
                    "success": False,
                    "output": "AI service is currently busy processing student lab requests. Please try again shortly.",
                    "response": "AI service is currently busy processing student lab requests. Please try again shortly.",
                    "provider": "queue_timeout",
                    "model": "none",
                    "executionTimeMs": int((time.time() - start_time) * 1000),
                    "error": {
                        "code": "AI_CAPACITY_TEMPORARY",
                        "message": "AI service is currently busy processing student lab requests. Please try again shortly."
                    }
                }
                if not future.done():
                    future.set_result(err_resp)
                return err_resp

            try:
                # 4. Execute Multi-Provider Fallback Router (Groq -> Gemini -> NVIDIA Nemotron)
                res = await cls._execute_provider_router(prompt, start_time)

                # Store in Cache if successful
                if res.get("success"):
                    _response_cache[cache_key] = (res, time.time() + CACHE_TTL_SECONDS)

                if not future.done():
                    future.set_result(res)
                return res

            finally:
                semaphore.release()

        finally:
            _in_flight_futures.pop(cache_key, None)

    @classmethod
    async def _execute_provider_router(cls, prompt: str, start_time: float) -> dict:
        groq_api_key = os.getenv("GROQ_API_KEY", "").strip()
        gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        nvidia_api_key = os.getenv("NVIDIA_API_KEY", "").strip()

        client = _get_http_client()

        # --------------------------------------------------------------------
        # PROVIDER 1: Groq AI (Ultra-fast LPU inference: ~400ms - 800ms)
        # --------------------------------------------------------------------
        cb_groq = _circuit_breakers["groq"]
        if groq_api_key and groq_api_key != "your_groq_api_key_here" and cb_groq.is_available():
            groq_models = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant"]
            for model_name in groq_models:
                success, data, is_rate_limit, is_permanent = await cls._try_groq_request(
                    client, groq_api_key, model_name, prompt
                )
                if success:
                    cb_groq.record_success()
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    return {
                        "success": True,
                        "output": data,
                        "response": data,
                        "provider": "groq",
                        "model": f"groq/{model_name}",
                        "executionTimeMs": elapsed_ms,
                        "error": None
                    }
                else:
                    cb_groq.record_failure(is_rate_limit=is_rate_limit)
                    if is_permanent:
                        break

        # --------------------------------------------------------------------
        # PROVIDER 2: Google Gemini API (Fast secondary fallback)
        # --------------------------------------------------------------------
        cb_gemini = _circuit_breakers["gemini"]
        if gemini_api_key and gemini_api_key != "your_gemini_api_key_here" and cb_gemini.is_available():
            gemini_models = ["gemini-flash-latest", "gemini-2.5-flash-lite"]
            for model_name in gemini_models:
                success, data, is_rate_limit, is_permanent = await cls._try_gemini_request(
                    client, gemini_api_key, model_name, prompt
                )
                if success:
                    cb_gemini.record_success()
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    return {
                        "success": True,
                        "output": data,
                        "response": data,
                        "provider": "gemini",
                        "model": f"google/{model_name}",
                        "executionTimeMs": elapsed_ms,
                        "error": None
                    }
                else:
                    cb_gemini.record_failure(is_rate_limit=is_rate_limit)
                    if is_permanent:
                        break

        # --------------------------------------------------------------------
        # PROVIDER 3: NVIDIA Nemotron OpenAI-compatible API (Reliable NIM tertiary fallback)
        # --------------------------------------------------------------------
        cb_nvidia = _circuit_breakers["nvidia"]
        if nvidia_api_key and nvidia_api_key != "your_nvidia_api_key_here" and cb_nvidia.is_available():
            nvidia_models = ["nvidia/llama-3.1-nemotron-70b-instruct", "meta/llama-3.1-70b-instruct"]
            for model_name in nvidia_models:
                success, data, is_rate_limit, is_permanent = await cls._try_nvidia_request(
                    client, nvidia_api_key, model_name, prompt
                )
                if success:
                    cb_nvidia.record_success()
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    return {
                        "success": True,
                        "output": data,
                        "response": data,
                        "provider": "nvidia",
                        "model": f"nvidia/{model_name}",
                        "executionTimeMs": elapsed_ms,
                        "error": None
                    }
                else:
                    cb_nvidia.record_failure(is_rate_limit=is_rate_limit)
                    if is_permanent:
                        break

        # --------------------------------------------------------------------
        # ALL PROVIDERS FAILED OR UNCONFIGURED
        # --------------------------------------------------------------------
        elapsed_ms = int((time.time() - start_time) * 1000)
        if not groq_api_key and not gemini_api_key and not nvidia_api_key:
            return {
                "success": False,
                "output": "API Key Missing: Please configure GROQ_API_KEY, GEMINI_API_KEY, or NVIDIA_API_KEY on the backend environment variables.",
                "response": "API Key Missing: Please configure GROQ_API_KEY, GEMINI_API_KEY, or NVIDIA_API_KEY on the backend environment variables.",
                "provider": "none",
                "model": "none",
                "executionTimeMs": elapsed_ms,
                "error": {
                    "code": "API_KEY_MISSING",
                    "message": "No API keys configured on backend server."
                }
            }

        return {
            "success": False,
            "output": "All configured AI providers (Groq, Gemini, NVIDIA Nemotron) are temporarily unavailable. Please try again in a few seconds.",
            "response": "All configured AI providers (Groq, Gemini, NVIDIA Nemotron) are temporarily unavailable. Please try again in a few seconds.",
            "provider": "failed",
            "model": "multi-provider",
            "executionTimeMs": elapsed_ms,
            "error": {
                "code": "AI_PROVIDER_UNAVAILABLE",
                "message": "All configured AI providers are temporarily unavailable."
            }
        }

    # ========================================================================
    # PROVIDER HTTP REQUEST HELPERS WITH BACKOFF & JITTER
    # ========================================================================
    @staticmethod
    async def _try_groq_request(client: httpx.AsyncClient, api_key: str, model_name: str, prompt: str) -> tuple[bool, str, bool, bool]:
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": model_name,
            "messages": [
                {"role": "system", "content": "You are an expert educational AI assistant for an Artificial Intelligence laboratory subject. Provide concise, clear answers."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.6,
            "max_tokens": 1024
        }

        max_attempts = 2
        for attempt in range(max_attempts):
            try:
                resp = await client.post(url, json=payload, headers=headers, timeout=10.0)
                if resp.status_code == 200:
                    data = resp.json()
                    choices = data.get("choices", [])
                    if choices and "message" in choices[0]:
                        return True, choices[0]["message"].get("content", ""), False, False
                elif resp.status_code in [401, 403, 404, 422]:
                    return False, f"HTTP {resp.status_code}", False, True
                elif resp.status_code == 429:
                    if attempt < max_attempts - 1:
                        backoff = (2 ** attempt) + random.uniform(0.1, 0.5)
                        await asyncio.sleep(backoff)
                        continue
                    return False, "Rate Limited", True, False
            except Exception:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
        return False, "Failed", False, False

    @staticmethod
    async def _try_gemini_request(client: httpx.AsyncClient, api_key: str, model_name: str, prompt: str) -> tuple[bool, str, bool, bool]:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
        headers = {"Content-Type": "application/json"}
        payload = {
            "contents": [
                {
                    "parts": [{"text": prompt}]
                }
            ]
        }

        max_attempts = 2
        for attempt in range(max_attempts):
            try:
                resp = await client.post(url, json=payload, headers=headers, timeout=10.0)
                if resp.status_code == 200:
                    data = resp.json()
                    candidates = data.get("candidates", [])
                    if candidates and "content" in candidates[0]:
                        parts = candidates[0]["content"].get("parts", [])
                        if parts and "text" in parts[0]:
                            return True, parts[0]["text"], False, False
                elif resp.status_code in [400, 401, 403, 404]:
                    return False, f"HTTP {resp.status_code}", False, True
                elif resp.status_code == 429:
                    if attempt < max_attempts - 1:
                        backoff = (2 ** attempt) + random.uniform(0.1, 0.5)
                        await asyncio.sleep(backoff)
                        continue
                    return False, "Rate Limited", True, False
            except Exception:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
        return False, "Failed", False, False

    @staticmethod
    async def _try_nvidia_request(client: httpx.AsyncClient, api_key: str, model_name: str, prompt: str) -> tuple[bool, str, bool, bool]:
        url = "https://integrate.api.nvidia.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": model_name,
            "messages": [
                {"role": "system", "content": "You are an expert educational AI assistant for an Artificial Intelligence laboratory subject. Provide concise, clear answers."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.5,
            "max_tokens": 1024
        }

        max_attempts = 2
        for attempt in range(max_attempts):
            try:
                resp = await client.post(url, json=payload, headers=headers, timeout=10.0)
                if resp.status_code == 200:
                    data = resp.json()
                    choices = data.get("choices", [])
                    if choices and "message" in choices[0]:
                        return True, choices[0]["message"].get("content", ""), False, False
                elif resp.status_code in [401, 403, 404, 422]:
                    return False, f"HTTP {resp.status_code}", False, True
                elif resp.status_code == 429:
                    if attempt < max_attempts - 1:
                        backoff = (2 ** attempt) + random.uniform(0.1, 0.5)
                        await asyncio.sleep(backoff)
                        continue
                    return False, "Rate Limited", True, False
            except Exception:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
        return False, "Failed", False, False

    # ========================================================================
    # SYNCHRONOUS WRAPPERS FOR COMPATIBILITY
    # ========================================================================
    @classmethod
    def generate_ai_response(cls, prompt: str, task_tag: str = "general") -> dict:
        """Synchronous wrapper for legacy callers."""
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                # In running loop thread, use asyncio.run_coroutine_threadsafe or nest_asyncio logic
                import nest_asyncio
                nest_asyncio.apply()
                return loop.run_until_complete(cls.generate_ai_response_async(prompt, task_tag=task_tag))
            else:
                return loop.run_until_complete(cls.generate_ai_response_async(prompt, task_tag=task_tag))
        except Exception:
            return asyncio.run(cls.generate_ai_response_async(prompt, task_tag=task_tag))

    @classmethod
    async def generate_chat_response_async(cls, messages: List[Dict[str, str]]) -> dict:
        """Multi-turn chat completion with full concurrency control and provider router."""
        prompt_summary = "\n".join([f"{m.get('role')}: {m.get('content')}" for m in messages[-4:]])
        res = await cls.generate_ai_response_async(prompt_summary, task_tag="chat")
        if res.get("success"):
            return {
                "success": True,
                "message": {
                    "role": "assistant",
                    "content": res.get("output", "")
                },
                "model": res.get("model", "unknown"),
                "provider": res.get("provider", "unknown"),
                "executionTimeMs": res.get("executionTimeMs", 0),
                "error": None
            }
        return {
            "success": False,
            "message": {
                "role": "assistant",
                "content": res.get("output", "Unable to process chat request.")
            },
            "model": res.get("model", "none"),
            "provider": res.get("provider", "failed"),
            "executionTimeMs": res.get("executionTimeMs", 0),
            "error": res.get("error")
        }

    @classmethod
    def generate_chat_response(cls, messages: List[Dict[str, str]]) -> dict:
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                import nest_asyncio
                nest_asyncio.apply()
                return loop.run_until_complete(cls.generate_chat_response_async(messages))
            else:
                return loop.run_until_complete(cls.generate_chat_response_async(messages))
        except Exception:
            return asyncio.run(cls.generate_chat_response_async(messages))
