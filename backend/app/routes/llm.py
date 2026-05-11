"""
LLM Proxy - Thin, stateless proxy for AI inference.

Privacy-First Architecture:
- ALL user data stays on-device
- This is a pure proxy - no data storage, no preferences, no state
- Anonymization happens on-device BEFORE data reaches this endpoint
- Memory extraction happens on-device AFTER receiving response

Supported providers:
- Groq (free tier, default) - llama-3.3-70b-versatile
- Anthropic Claude (premium) - claude-haiku-4-5-20251001
- Google Gemini (premium) - gemini-2.0-flash
- OpenAI (premium) - gpt-4o

Quota enforcement via subscription tier.
"""

import logging
from typing import Optional
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.factory import get_ai_provider
from app.database import get_db
from app.models import User
from app.dependencies.quota import check_quota, increment_token_usage

# Configure logging with colors
logger = logging.getLogger("llm_proxy")
logger.setLevel(logging.DEBUG)

# Create console handler with formatting
if not logger.handlers:
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        '\033[36m[LLM]\033[0m %(message)s'
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)

router = APIRouter(prefix="/llm", tags=["llm"])


class ChatMessage(BaseModel):
    """Single chat message."""
    role: str  # user, assistant, system
    content: str


class ChatRequest(BaseModel):
    """
    Request for LLM chat completion.

    Note: All data sent here should already be anonymized by the device.
    The system_prompt should contain memory context built on-device.
    """
    messages: list[ChatMessage]
    system_prompt: Optional[str] = None
    provider: str = "groq"  # groq, anthropic, gemini, openai
    stream: bool = True

    # AI settings (sent from device)
    temperature: float = 0.7  # 0.0-1.0, maps to creativity setting
    max_tokens: int = 2048  # Maps to response_length: short=512, medium=2048, long=4096


class ChatResponse(BaseModel):
    """Non-streaming chat response."""
    content: str
    model: str
    usage: Optional[dict] = None
    timestamp: str


@router.post("/chat")
async def chat(
    request: ChatRequest,
    current_user: User = Depends(check_quota),
    db: AsyncSession = Depends(get_db),
):
    """
    Pure LLM proxy - forward chat request to provider.

    Privacy guarantees:
    - Backend has NO access to user data
    - All content should be pre-anonymized by device (PERSON_1, PLACE_1, etc.)
    - No state is stored - pure forwarding
    - Response should be de-anonymized by device after receiving

    Requires authentication and checks quota before processing.
    """
    # === DEBUG: Log incoming request ===
    logger.info("=" * 60)
    logger.info("\033[33m📥 INCOMING REQUEST\033[0m")
    logger.info(f"   Provider: \033[32m{request.provider}\033[0m")
    logger.info(f"   Stream: {request.stream}")
    logger.info(f"   Temperature: {request.temperature}")
    logger.info(f"   Max Tokens: {request.max_tokens}")
    logger.info(f"   User ID: {current_user.id}")
    logger.info("-" * 60)

    # Log messages
    logger.info("\033[33m💬 MESSAGES RECEIVED:\033[0m")
    for i, msg in enumerate(request.messages):
        content_preview = msg.content[:200] + "..." if len(msg.content) > 200 else msg.content
        logger.info(f"   [{i}] \033[35m{msg.role}\033[0m: {content_preview}")

    # Log system prompt
    if request.system_prompt:
        prompt_preview = request.system_prompt[:300] + "..." if len(request.system_prompt) > 300 else request.system_prompt
        logger.info("-" * 60)
        logger.info("\033[33m📋 SYSTEM PROMPT:\033[0m")
        logger.info(f"   {prompt_preview}")
    logger.info("=" * 60)

    try:
        provider = get_ai_provider(request.provider)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid provider: {request.provider}. Available: groq, anthropic, gemini, openai",
        )

    # Build messages list (already anonymized by device)
    messages = [{"role": m.role, "content": m.content} for m in request.messages]

    # Use provided system prompt (with on-device memory context already embedded)
    system_prompt = request.system_prompt or _default_system_prompt()

    if request.stream:
        # Streaming response
        estimated_tokens = sum(len(m.content.split()) * 1.3 for m in request.messages)
        logger.info("\033[33m📤 STREAMING RESPONSE...\033[0m")

        async def generate():
            total_tokens = int(estimated_tokens)
            response_buffer = []
            async for chunk in provider.chat(
                messages=messages,
                system_prompt=system_prompt,
                stream=True,
                temperature=request.temperature,
                max_tokens=request.max_tokens,
            ):
                total_tokens += len(chunk.split())
                response_buffer.append(chunk)
                yield f"data: {chunk}\n\n"
            yield "data: [DONE]\n\n"

            # Log complete response
            full_response = "".join(response_buffer)
            response_preview = full_response[:500] + "..." if len(full_response) > 500 else full_response
            logger.info("=" * 60)
            logger.info("\033[32m✅ RESPONSE SENT:\033[0m")
            logger.info(f"   {response_preview}")
            logger.info(f"   \033[36mTokens used: ~{total_tokens}\033[0m")
            logger.info("=" * 60)

            # Increment usage after streaming completes
            await increment_token_usage(current_user.id, total_tokens, db)

        return StreamingResponse(
            generate(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Accel-Buffering": "no",
            },
        )
    else:
        # Non-streaming response
        content, total_tokens = await provider.chat_non_streaming(
            messages=messages,
            system_prompt=system_prompt,
            temperature=request.temperature,
            max_tokens=request.max_tokens,
        )

        if not total_tokens:
            total_tokens = int(len(content.split()) * 1.3)
        await increment_token_usage(current_user.id, int(total_tokens), db)

        # Log response
        response_preview = content[:500] + "..." if len(content) > 500 else content
        logger.info("=" * 60)
        logger.info("\033[32m✅ RESPONSE SENT:\033[0m")
        logger.info(f"   {response_preview}")
        logger.info(f"   \033[36mTokens used: {total_tokens}\033[0m")
        logger.info("=" * 60)

        return ChatResponse(
            content=content,
            model=request.provider,
            usage={"total_tokens": total_tokens},
            timestamp=datetime.now(timezone.utc).isoformat(),
        )


@router.get("/providers")
async def list_providers() -> dict:
    """
    List available LLM providers.
    """
    return {
        "providers": [
            {
                "id": "groq",
                "name": "Groq",
                "tier": "free",
                "description": "Ultra-fast Llama inference (free tier)",
                "model": "llama-3.3-70b-versatile",
            },
            {
                "id": "anthropic",
                "name": "Anthropic Claude",
                "tier": "premium",
                "description": "Claude Haiku - fast and capable",
                "model": "claude-haiku-4-5-20251001",
            },
            {
                "id": "gemini",
                "name": "Google Gemini",
                "tier": "premium",
                "description": "Gemini 2.0 Flash - multimodal",
                "model": "gemini-2.0-flash",
            },
            {
                "id": "openai",
                "name": "OpenAI",
                "tier": "premium",
                "description": "GPT-4o",
                "model": "gpt-4o",
            },
        ],
        "default": "groq",
    }


@router.get("/health")
async def health_check() -> dict:
    """
    Check LLM gateway health.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def _default_system_prompt() -> str:
    """Default system prompt for Jarvis (minimal - device provides full context)."""
    return """You are Jarvis, a personal AI assistant.

Be helpful, concise, and personable. The user's context and memories
are provided in the system prompt when available."""
