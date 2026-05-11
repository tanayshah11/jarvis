"""
Base class for AI providers.

Privacy-First Architecture:
- These providers are pure LLM proxies
- No memory extraction (handled on-device)
- No embeddings (handled on-device with ObjectBox + MiniLM)
"""

from abc import ABC, abstractmethod
from typing import AsyncGenerator


class AIProvider(ABC):
    """Abstract base class for AI providers - pure LLM proxy."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Return the provider name."""
        pass

    @abstractmethod
    async def chat(
        self,
        messages: list[dict],
        system_prompt: str,
        stream: bool = True,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> AsyncGenerator[str, None]:
        """
        Generate a streaming chat response.

        Args:
            messages: List of message dicts with 'role' and 'content'
            system_prompt: System prompt (includes memory context from device)
            stream: Whether to stream the response
            temperature: Temperature for generation (0.0-1.0)
            max_tokens: Maximum tokens to generate

        Yields:
            Chunks of the response text
        """
        pass

    @abstractmethod
    async def chat_non_streaming(
        self,
        messages: list[dict],
        system_prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> tuple[str, int]:
        """
        Generate a non-streaming chat response.

        Args:
            messages: List of message dicts with 'role' and 'content'
            system_prompt: System prompt (includes memory context from device)
            temperature: Temperature for generation (0.0-1.0)
            max_tokens: Maximum tokens to generate

        Returns:
            Tuple of (response_text, tokens_used)
        """
        pass
