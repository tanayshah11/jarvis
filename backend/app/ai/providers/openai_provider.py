"""
OpenAI GPT AI provider - pure LLM proxy.
"""

from typing import AsyncGenerator

import openai

from app.ai.base import AIProvider
from app.config import get_settings

settings = get_settings()


class OpenAIProvider(AIProvider):
    """OpenAI GPT AI provider - pure LLM proxy."""

    def __init__(self):
        self.client = openai.AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model

    @property
    def name(self) -> str:
        return "openai"

    async def chat(
        self,
        messages: list[dict],
        system_prompt: str,
        stream: bool = True,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat response using GPT."""
        # Convert messages to OpenAI format
        openai_messages = [{"role": "system", "content": system_prompt}]
        openai_messages.extend([
            {"role": msg["role"], "content": msg["content"]}
            for msg in messages
            if msg["role"] in ("user", "assistant")
        ])

        if stream:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=openai_messages,
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
                messages=openai_messages,
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
        openai_messages = [{"role": "system", "content": system_prompt}]
        openai_messages.extend([
            {"role": msg["role"], "content": msg["content"]}
            for msg in messages
            if msg["role"] in ("user", "assistant")
        ])

        response = await self.client.chat.completions.create(
            model=self.model,
            messages=openai_messages,
            max_tokens=max_tokens,
            temperature=temperature,
        )

        text = response.choices[0].message.content
        tokens = response.usage.total_tokens

        return text, tokens
