"""
Google Gemini AI provider - pure LLM proxy.
Supported Gemini Models and Limits:
Supported Gemini Models and Limits (Text-out):

Model                         | RPM   | TPM        | RPD (requests per day)
------------------------------|-------|------------|------
Gemini 2.5 Pro                | 2     | 125,000    | 50
Gemini 2.5 Flash              | 10    | 250,000    | 250
Gemini 2.5 Flash Preview      | 10    | 250,000    | 250
Gemini 2.5 Flash-Lite         | 15    | 250,000    | 1,000
Gemini 2.5 Flash-Lite Preview | 15    | 250,000    | 1,000
Gemini 2.0 Flash              | 15    | 1,000,000  | 200
Gemini 2.0 Flash-Lite         | 30    | 1,000,000  | 200

RPM: Requests per minute
TPM: Tokens per minute
RPD: Requests per day


"""

import asyncio
from typing import AsyncGenerator

import google.generativeai as genai

from app.ai.base import AIProvider
from app.config import get_settings

settings = get_settings()


class GeminiProvider(AIProvider):
    """Google Gemini AI provider - pure LLM proxy."""

    def __init__(self):
        genai.configure(api_key=settings.gemini_api_key)
        self.model_name = settings.gemini_model

    @property
    def name(self) -> str:
        return "gemini"

    async def chat(
        self,
        messages: list[dict],
        system_prompt: str,
        stream: bool = True,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat response using Gemini."""
        # Set generation config
        generation_config = genai.types.GenerationConfig(
            temperature=temperature,
            max_output_tokens=max_tokens,
        )

        # Build the conversation history for Gemini
        # Gemini uses "model" role instead of "assistant"
        history = []

        # Add system prompt as first user message if there are messages
        if messages:
            # Convert messages to Gemini format
            for msg in messages:
                if msg["role"] == "user":
                    # Prepend system prompt to first user message only
                    if not history:
                        content = f"{system_prompt}\n\n{msg['content']}"
                    else:
                        content = msg["content"]
                    history.append({"role": "user", "parts": [content]})
                elif msg["role"] == "assistant":
                    history.append({"role": "model", "parts": [msg["content"]]})
        else:
            # No messages, just system prompt
            history.append({"role": "user", "parts": [system_prompt]})

        # Create model instance
        model = genai.GenerativeModel(
            model_name=self.model_name,
            generation_config=generation_config,
        )

        if stream:
            # Start chat with history (excluding last message if it's user)
            if history and history[-1]["role"] == "user":
                chat_history = history[:-1]
                last_message = history[-1]["parts"][0]
            else:
                chat_history = []
                last_message = history[0]["parts"][0] if history else system_prompt

            # Start chat session
            chat = model.start_chat(history=chat_history)

            # Wrap synchronous streaming in async
            def _stream_response():
                response = chat.send_message(last_message, stream=True)
                return response

            response = await asyncio.to_thread(_stream_response)

            for chunk in response:
                if chunk.text:
                    yield chunk.text
        else:
            # Non-streaming
            if history and history[-1]["role"] == "user":
                chat_history = history[:-1]
                last_message = history[-1]["parts"][0]
            else:
                chat_history = []
                last_message = history[0]["parts"][0] if history else system_prompt

            chat = model.start_chat(history=chat_history)

            def _get_response():
                return chat.send_message(last_message)

            response = await asyncio.to_thread(_get_response)
            yield response.text

    async def chat_non_streaming(
        self,
        messages: list[dict],
        system_prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 2048,
    ) -> tuple[str, int]:
        """Generate a non-streaming chat response."""
        # Set generation config
        generation_config = genai.types.GenerationConfig(
            temperature=temperature,
            max_output_tokens=max_tokens,
        )

        # Build the conversation history
        history = []

        if messages:
            for msg in messages:
                if msg["role"] == "user":
                    # Prepend system prompt to first user message only
                    if not history:
                        content = f"{system_prompt}\n\n{msg['content']}"
                    else:
                        content = msg["content"]
                    history.append({"role": "user", "parts": [content]})
                elif msg["role"] == "assistant":
                    history.append({"role": "model", "parts": [msg["content"]]})
        else:
            history.append({"role": "user", "parts": [system_prompt]})

        # Create model instance
        model = genai.GenerativeModel(
            model_name=self.model_name,
            generation_config=generation_config,
        )

        # Get last user message
        if history and history[-1]["role"] == "user":
            chat_history = history[:-1]
            last_message = history[-1]["parts"][0]
        else:
            chat_history = []
            last_message = history[0]["parts"][0] if history else system_prompt

        chat = model.start_chat(history=chat_history)

        def _get_response():
            return chat.send_message(last_message)

        response = await asyncio.to_thread(_get_response)

        text = response.text
        # Get token usage from response metadata
        try:
            if hasattr(response, "usage_metadata") and response.usage_metadata:
                tokens = response.usage_metadata.total_token_count
            else:
                tokens = 0
        except Exception:
            tokens = 0

        return text, tokens
