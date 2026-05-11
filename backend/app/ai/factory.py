"""
AI Provider Factory - pure LLM proxy providers.

Privacy-First Architecture:
- No embeddings (handled on-device with ObjectBox + MiniLM)
- No memory extraction (handled on-device)
- Just LLM chat for inference
"""

from app.ai.base import AIProvider
from app.ai.providers.anthropic_provider import AnthropicProvider
from app.ai.providers.openai_provider import OpenAIProvider
from app.ai.providers.groq_provider import GroqProvider
from app.ai.providers.gemini_provider import GeminiProvider

_providers: dict[str, type[AIProvider]] = {
    "anthropic": AnthropicProvider,
    "openai": OpenAIProvider,
    "groq": GroqProvider,
    "gemini": GeminiProvider,
}

_instances: dict[str, AIProvider] = {}


def get_ai_provider(provider_name: str) -> AIProvider:
    """
    Get an AI provider instance by name.

    Available providers:
    - "groq" - Fast, free-tier Llama inference (default)
    - "anthropic" - Claude Haiku
    - "openai" - GPT-4o
    - "gemini" - Google Gemini

    Args:
        provider_name: Provider identifier

    Returns:
        AIProvider instance

    Raises:
        ValueError: If provider_name is not recognized
    """
    # Normalize provider name
    provider_name = provider_name.lower()

    if provider_name not in _providers:
        raise ValueError(
            f"Unknown AI provider: {provider_name}. "
            f"Available providers: {list(_providers.keys())}"
        )

    # Cache provider instances for reuse
    if provider_name not in _instances:
        _instances[provider_name] = _providers[provider_name]()

    return _instances[provider_name]
