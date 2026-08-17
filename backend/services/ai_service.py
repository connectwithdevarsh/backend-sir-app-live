import os
import time
import json
import random
import asyncio
import hashlib
import logging
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv
import httpx

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AIPE_AI_SERVICE")

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

_concurrency_semaphore: Optional[asyncio.Semaphore] = None

def _get_semaphore() -> asyncio.Semaphore:
    global _concurrency_semaphore
    if _concurrency_semaphore is None:
        _concurrency_semaphore = asyncio.Semaphore(MAX_AI_CONCURRENCY)
    return _concurrency_semaphore

_async_http_client: Optional[httpx.AsyncClient] = None

def _get_http_client() -> httpx.AsyncClient:
    global _async_http_client
    if _async_http_client is None or _async_http_client.is_closed:
        limits = httpx.Limits(max_keepalive_connections=20, max_connections=50)
        _async_http_client = httpx.AsyncClient(limits=limits, timeout=15.0)
    return _async_http_client

_response_cache: Dict[str, tuple[dict, float]] = {}
_in_flight_futures: Dict[str, asyncio.Future] = {}

# ============================================================================
# PROVIDER CIRCUIT BREAKER & HEALTH TRACKING
# ============================================================================
class ProviderCircuitBreaker:
    def __init__(self, name: str, cooldown_seconds: float = 30.0):
        self.name = name
        self.state = "HEALTHY"
        self.consecutive_failures = 0
        self.cooldown_until = 0.0
        self.cooldown_seconds = cooldown_seconds
        self.last_error_reason = "none"

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
        self.last_error_reason = "healthy"

    def record_failure(self, reason: str, is_rate_limit: bool = False):
        self.last_error_reason = reason
        # Only trip circuit breaker on persistent rate limits or 5+ network failures
        if is_rate_limit:
            self.consecutive_failures += 1
            if self.consecutive_failures >= 3:
                self.state = "OPEN"
                self.cooldown_until = time.time() + self.cooldown_seconds
                logger.warning(f"[{self.name.upper()}] Circuit breaker TRIPPED to OPEN for {self.cooldown_seconds}s due to: {reason}")
        else:
            self.consecutive_failures += 1
            if self.consecutive_failures >= 5:
                self.state = "OPEN"
                self.cooldown_until = time.time() + self.cooldown_seconds
                logger.warning(f"[{self.name.upper()}] Circuit breaker TRIPPED to OPEN for {self.cooldown_seconds}s due to: {reason}")

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
    async def get_provider_health_summary(cls) -> dict:
        """
        Diagnostic helper for GET /api/ai/health endpoint.
        Safely tests each provider with a micro-prompt without exposing keys.
        """
        load_dotenv(override=True)
        groq_api_key = os.getenv("GROQ_API_KEY", "").strip()
        gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        nvidia_api_key = os.getenv("NVIDIA_API_KEY", "").strip()
        client = _get_http_client()

        summary = {}

        # 1. Test Groq
        if not groq_api_key or groq_api_key == "your_groq_api_key_here":
            summary["groq"] = {"configured": False, "status": "not_configured"}
        else:
            ok, msg, _, _ = await cls._try_groq_request(client, groq_api_key, "llama-3.3-70b-versatile", "Hi")
            if not ok:
                ok, msg, _, _ = await cls._try_groq_request(client, groq_api_key, "llama-3.1-8b-instant", "Hi")
            summary["groq"] = {"configured": True, "status": "healthy" if ok else msg}

        # 2. Test Gemini
        if not gemini_api_key or gemini_api_key == "your_gemini_api_key_here":
            summary["gemini"] = {"configured": False, "status": "not_configured"}
        else:
            ok, msg, _, _ = await cls._try_gemini_request(client, gemini_api_key, "gemini-1.5-flash", "Hi")
            summary["gemini"] = {"configured": True, "status": "healthy" if ok else msg}

        # 3. Test NVIDIA
        if not nvidia_api_key or nvidia_api_key == "your_nvidia_api_key_here":
            summary["nvidia"] = {"configured": False, "status": "not_configured"}
        else:
            ok, msg, _, _ = await cls._try_nvidia_request(client, nvidia_api_key, "meta/llama-3.1-8b-instruct", "Hi")
            summary["nvidia"] = {"configured": True, "status": "healthy" if ok else msg}

        return summary

    @classmethod
    async def generate_ai_response_async(cls, prompt: str, task_tag: str = "general") -> dict:
        """
        Production-grade async AI generator.
        Order: Groq -> Gemini -> NVIDIA (meta/llama-3.1-8b-instruct / meta/llama-3.1-70b-instruct).
        """
        load_dotenv(override=True)
        start_time = time.time()
        cache_key = cls._compute_cache_key(task_tag, prompt)

        # 1. Check TTL Cache
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

        # 2. Request Coalescing
        if cache_key in _in_flight_futures:
            try:
                shared_result = await asyncio.shield(_in_flight_futures[cache_key])
                result = dict(shared_result)
                result["executionTimeMs"] = int((time.time() - start_time) * 1000)
                result["coalesced"] = True
                return result
            except Exception:
                pass

        loop = asyncio.get_running_loop()
        future = loop.create_future()
        _in_flight_futures[cache_key] = future

        try:
            # 3. Semaphore Queue Control
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
                # 4. Execute Multi-Provider Router
                res = await cls._execute_provider_router(prompt, start_time)

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
        failure_log = []

        # --------------------------------------------------------------------
        # PROVIDER 1: Groq AI
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
                    logger.info(f"[GROQ SUCCESS] Model: groq/{model_name} in {elapsed_ms}ms")
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
                    failure_log.append(f"Groq ({model_name}): {data}")
                    cb_groq.record_failure(data, is_rate_limit=is_rate_limit)

        # --------------------------------------------------------------------
        # PROVIDER 2: Google Gemini API
        # --------------------------------------------------------------------
        cb_gemini = _circuit_breakers["gemini"]
        if gemini_api_key and gemini_api_key != "your_gemini_api_key_here" and cb_gemini.is_available():
            gemini_models = ["gemini-1.5-flash", "gemini-flash-latest"]
            for model_name in gemini_models:
                success, data, is_rate_limit, is_permanent = await cls._try_gemini_request(
                    client, gemini_api_key, model_name, prompt
                )
                if success:
                    cb_gemini.record_success()
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    logger.info(f"[GEMINI SUCCESS] Model: google/{model_name} in {elapsed_ms}ms")
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
                    failure_log.append(f"Gemini ({model_name}): {data}")
                    cb_gemini.record_failure(data, is_rate_limit=is_rate_limit)

        # --------------------------------------------------------------------
        # PROVIDER 3: NVIDIA NIM API (Active models: meta/llama-3.1-8b-instruct, meta/llama-3.1-70b-instruct)
        # --------------------------------------------------------------------
        cb_nvidia = _circuit_breakers["nvidia"]
        if nvidia_api_key and nvidia_api_key != "your_nvidia_api_key_here" and cb_nvidia.is_available():
            nvidia_models = [
                "meta/llama-3.1-8b-instruct",
                "meta/llama-3.1-70b-instruct"
            ]
            for model_name in nvidia_models:
                success, data, is_rate_limit, is_permanent = await cls._try_nvidia_request(
                    client, nvidia_api_key, model_name, prompt
                )
                if success:
                    cb_nvidia.record_success()
                    elapsed_ms = int((time.time() - start_time) * 1000)
                    logger.info(f"[NVIDIA SUCCESS] Model: nvidia/{model_name} in {elapsed_ms}ms")
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
                    failure_log.append(f"NVIDIA ({model_name}): {data}")
                    cb_nvidia.record_failure(data, is_rate_limit=is_rate_limit)

        # --------------------------------------------------------------------
        # ALL PROVIDERS FAILED OR UNCONFIGURED
        # --------------------------------------------------------------------
        elapsed_ms = int((time.time() - start_time) * 1000)
        logger.error(f"[ALL PROVIDERS FAILED] Summary: { ' | '.join(failure_log) }")

        return {
            "success": False,
            "output": "All configured AI providers are temporarily unavailable. Please try again shortly.",
            "response": "All configured AI providers are temporarily unavailable. Please try again shortly.",
            "provider": "failed",
            "model": "multi-provider",
            "executionTimeMs": elapsed_ms,
            "error": {
                "code": "AI_PROVIDER_UNAVAILABLE",
                "message": f"All configured AI providers (Groq, Gemini, NVIDIA) failed. Details: {'; '.join(failure_log)}"
            }
        }

    # ========================================================================
    # PROVIDER HTTP REQUEST HELPERS
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
                resp = await client.post(url, json=payload, headers=headers, timeout=12.0)
                if resp.status_code == 200:
                    data = resp.json()
                    choices = data.get("choices", [])
                    if choices and "message" in choices[0]:
                        return True, choices[0]["message"].get("content", ""), False, False
                elif resp.status_code in [401, 403, 404, 422]:
                    return False, f"invalid_model/auth_failed (HTTP {resp.status_code})", False, True
                elif resp.status_code == 429:
                    if attempt < max_attempts - 1:
                        await asyncio.sleep(1.0 + random.uniform(0.1, 0.4))
                        continue
                    return False, "rate_limited (HTTP 429)", True, False
                else:
                    return False, f"provider_error (HTTP {resp.status_code})", False, False
            except Exception as e:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
                return False, f"timeout/connection_error ({e})", False, False
        return False, "failed", False, False

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
                resp = await client.post(url, json=payload, headers=headers, timeout=12.0)
                if resp.status_code == 200:
                    data = resp.json()
                    candidates = data.get("candidates", [])
                    if candidates and "content" in candidates[0]:
                        parts = candidates[0]["content"].get("parts", [])
                        if parts and "text" in parts[0]:
                            return True, parts[0]["text"], False, False
                elif resp.status_code in [400, 401, 403, 404]:
                    return False, f"invalid_model/auth_failed (HTTP {resp.status_code})", False, True
                elif resp.status_code in [429, 503]:
                    if attempt < max_attempts - 1:
                        await asyncio.sleep(1.0 + random.uniform(0.1, 0.4))
                        continue
                    return False, f"rate_limited/high_demand (HTTP {resp.status_code})", True, False
                else:
                    return False, f"provider_error (HTTP {resp.status_code})", False, False
            except Exception as e:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
                return False, f"timeout/connection_error ({e})", False, False
        return False, "failed", False, False

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
                resp = await client.post(url, json=payload, headers=headers, timeout=12.0)
                if resp.status_code == 200:
                    data = resp.json()
                    choices = data.get("choices", [])
                    if choices and "message" in choices[0]:
                        return True, choices[0]["message"].get("content", ""), False, False
                elif resp.status_code in [401, 403, 404, 422]:
                    return False, f"invalid_model/auth_failed (HTTP {resp.status_code})", False, True
                elif resp.status_code == 429:
                    if attempt < max_attempts - 1:
                        await asyncio.sleep(1.0 + random.uniform(0.1, 0.4))
                        continue
                    return False, "rate_limited (HTTP 429)", True, False
                else:
                    return False, f"provider_error (HTTP {resp.status_code})", False, False
            except Exception as e:
                if attempt < max_attempts - 1:
                    await asyncio.sleep(1.0 + random.uniform(0.1, 0.3))
                    continue
                return False, f"timeout/connection_error ({e})", False, False
        return False, "failed", False, False

    # ========================================================================
    # SYNCHRONOUS WRAPPERS FOR COMPATIBILITY
    # ========================================================================
    @classmethod
    def generate_ai_response(cls, prompt: str, task_tag: str = "general") -> dict:
        try:
            try:
                loop = asyncio.get_running_loop()
            except RuntimeError:
                loop = None

            if loop is not None and loop.is_running():
                import concurrent.futures
                with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
                    future = executor.submit(lambda: asyncio.run(cls.generate_ai_response_async(prompt, task_tag=task_tag)))
                    return future.result()
            else:
                return asyncio.run(cls.generate_ai_response_async(prompt, task_tag=task_tag))
        except Exception as e:
            return {
                "success": False,
                "output": f"Execution error: {e}",
                "response": f"Execution error: {e}",
                "provider": "error",
                "model": "none",
                "executionTimeMs": 0,
                "error": str(e)
            }

    @classmethod
    async def generate_chat_response_async(cls, messages: List[Dict[str, str]]) -> dict:
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
            try:
                loop = asyncio.get_running_loop()
            except RuntimeError:
                loop = None

            if loop is not None and loop.is_running():
                import concurrent.futures
                with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
                    future = executor.submit(lambda: asyncio.run(cls.generate_chat_response_async(messages)))
                    return future.result()
            else:
                return asyncio.run(cls.generate_chat_response_async(messages))
        except Exception as e:
            return {
                "success": False,
                "message": {
                    "role": "assistant",
                    "content": f"Chat execution error: {e}"
                },
                "model": "none",
                "provider": "error",
                "executionTimeMs": 0,
                "error": str(e)
            }
