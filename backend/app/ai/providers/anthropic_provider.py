"""
Anthropic Claude AI provider - pure LLM proxy.
"""

from typing import AsyncGenerator

import anthropic

from app.ai.base import AIProvider
from app.config import get_settings

settings = get_settings()


class AnthropicProvider(AIProvider):
    """Anthropic Claude AI provider - pure LLM proxy."""

    def __init__(self):
        self.client = anthropic.AsyncAnthropic(api_key=settings.anthropic_api_key)
        self.model = settings.anthropic_model

    @property
    def name(self) -> str:
        return "anthropic"

    async def chat(
        self,
        messages: list[dict],
        system_prompt: str,
        stream: bool = True,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat response using Claude."""
        # Convert messages to Anthropic format
        anthropic_messages = [
            {"role": msg["role"], "content": msg["content"]}
            for msg in messages
            if msg["role"] in ("user", "assistant")
        ]

        if stream:
            async with self.client.messages.stream(
                model=self.model,
                max_tokens=max_tokens,
                temperature=temperature,
                system=system_prompt,
                messages=anthropic_messages,
            ) as response:
                async for text in response.text_stream:
                    yield text
        else:
            response = await self.client.messages.create(
                model=self.model,
                max_tokens=max_tokens,
                temperature=temperature,
                system=system_prompt,
                messages=anthropic_messages,
            )
            yield response.content[0].text

    async def chat_non_streaming(
        self,
        messages: list[dict],
        system_prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> tuple[str, int]:
        """Generate a non-streaming chat response."""
        anthropic_messages = [
            {"role": msg["role"], "content": msg["content"]}
            for msg in messages
            if msg["role"] in ("user", "assistant")
        ]

        response = await self.client.messages.create(
            model=self.model,
            max_tokens=max_tokens,
            temperature=temperature,
            system=system_prompt,
            messages=anthropic_messages,
        )

        text = response.content[0].text
        tokens = response.usage.input_tokens + response.usage.output_tokens

        return text, tokens
