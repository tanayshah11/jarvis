"""
Groq Provider - Fast, free-tier LLM inference.

Uses Groq's ultra-fast inference for Llama models.
Free tier: 6,000 requests/day, 6,000 tokens/minute.

Privacy-First: Pure LLM proxy, no data storage.
"""

from typing import AsyncGenerator

from groq import AsyncGroq

from app.ai.base import AIProvider
from app.config import get_settings

settings = get_settings()


class GroqProvider(AIProvider):
    """Groq provider for ultra-fast Llama inference - pure LLM proxy."""

    def __init__(self):
        self.client = AsyncGroq(api_key=settings.groq_api_key)
        self.model = settings.groq_model

    @property
    def name(self) -> str:
        return "groq"

    async def chat(
        self,
        messages: list[dict],
        system_prompt: str,
        stream: bool = True,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat response using Groq."""
        groq_messages = [{"role": "system", "content": system_prompt}]
        groq_messages.extend(
            [
                {"role": msg["role"], "content": msg["content"]}
                for msg in messages
                if msg["role"] in ("user", "assistant")
            ]
        )

        if stream:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=groq_messages,
                max_tokens=max_tokens,
                temperature=temperature,
                stream=True,
            )

            async for chunk in response:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
        else:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=groq_messages,
                max_tokens=max_tokens,
                temperature=temperature,
            )
            yield response.choices[0].message.content

    async def chat_non_streaming(
        self,
        messages: list[dict],
        system_prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> tuple[str, int]:
        """Generate a non-streaming chat response."""
        groq_messages = [{"role": "system", "content": system_prompt}]
        groq_messages.extend(
            [
                {"role": msg["role"], "content": msg["content"]}
                for msg in messages
                if msg["role"] in ("user", "assistant")
            ]
        )

        response = await self.client.chat.completions.create(
            model=self.model,
            messages=groq_messages,
            max_tokens=max_tokens,
            temperature=temperature,
        )

        text = response.choices[0].message.content
        tokens = response.usage.total_tokens if response.usage else 0

        return text, tokens
