#!/usr/bin/env python3
"""
Real-World User & Jarvis Conversation

Simulates a realistic day-in-the-life conversation between a user and Jarvis,
demonstrating tool calling, memory extraction, and context-aware responses.

Usage:
    python scripts/user_jarvis_chat.py
"""

import asyncio
import httpx
from datetime import datetime
from typing import Any


# Configuration
API_BASE = "http://localhost:8000"

# Colors for terminal output
USER_COLOR = "\033[92m"      # Green
JARVIS_COLOR = "\033[93m"    # Yellow
TOOL_COLOR = "\033[96m"      # Cyan
MEMORY_COLOR = "\033[95m"    # Magenta
SYSTEM_COLOR = "\033[90m"    # Gray
RESET = "\033[0m"
BOLD = "\033[1m"


class JarvisChat:
    """Simulates a realistic Jarvis conversation with tool calling."""

    def __init__(self):
        self.token: str | None = None
        self.conversation_history: list[dict] = []
        self.memory_context: str = ""
        self.extracted_memories: list[dict] = []

    async def setup(self):
        """Initialize auth and set up user preferences."""
        async with httpx.AsyncClient() as client:
            # Try login first
            resp = await client.post(
                f"{API_BASE}/auth/login",
                json={"email": "demo_user@jarvis.ai", "password": "demo1234"}
            )

            if resp.status_code != 200:
                # Register new user
                await client.post(
                    f"{API_BASE}/auth/register",
                    json={
                        "email": "demo_user@jarvis.ai",
                        "password": "demo1234",
                        "name": "Alex"
                    }
                )
                resp = await client.post(
                    f"{API_BASE}/auth/login",
                    json={"email": "demo_user@jarvis.ai", "password": "demo1234"}
                )

            self.token = resp.json()["access_token"]

            # Enable privacy features for demo
            await client.put(
                f"{API_BASE}/preferences/privacy",
                headers={"Authorization": f"Bearer {self.token}"},
                json={"enable_memory_extraction": True, "enable_anonymization": True}
            )

        # Set up initial memory context (simulating existing knowledge)
        self.memory_context = """
Sarah is Alex's wife. She works as a product designer at Figma.
Mom is Alex's mother. Her name is Linda. Phone: 555-867-5309.
Dad is Alex's father. His name is Robert.
Dr. Chen is Alex's dentist at Smile Dental Clinic.
Jake is Alex's best friend from college. Works at Google.
Emma is Alex's daughter, age 7. Goes to Sunshine Elementary.
Max is the family dog, a golden retriever.
The family lives at 742 Maple Street, San Francisco.
Alex works as a software engineer at a startup called TechNova.
Weekly team standup is every Monday at 10am.
Date night with Sarah is usually Friday evenings.
"""

    def print_header(self):
        """Print conversation header."""
        print("\n" + "=" * 70)
        print(f"{BOLD}     A Day with Jarvis - Real World Conversation Demo{RESET}")
        print("=" * 70)
        now = datetime.now()
        print(f"{SYSTEM_COLOR}Date: {now.strftime('%A, %B %d, %Y')}")
        print(f"Time: {now.strftime('%I:%M %p')}{RESET}")
        print("-" * 70 + "\n")

    def print_user(self, message: str):
        """Print user message."""
        print(f"{USER_COLOR}{BOLD}Alex:{RESET} {message}\n")

    def print_jarvis(self, response: dict):
        """Print Jarvis response with tool call details."""
        # Show the response
        print(f"{JARVIS_COLOR}{BOLD}Jarvis:{RESET} {response.get('response', '')}\n")

        # Show intent detection
        intent = response.get("intent_type", "general")
        if intent != "general":
            print(f"{SYSTEM_COLOR}  [Intent: {intent}]{RESET}")

        # Show tool calls if any
        tool_calls = response.get("tool_calls")
        if tool_calls:
            for tool in tool_calls:
                print(f"{TOOL_COLOR}  [Tool: {tool['name']}]")
                params = tool.get("parameters", {})
                for k, v in params.items():
                    if v is not None:
                        print(f"    • {k}: {v}")
                print(RESET)

        # Show extracted fields (what LLM saw - anonymized)
        extracted = response.get("extracted_fields", {})
        if extracted and any(v for v in extracted.values() if v):
            # Check if any fields contain anonymized tokens
            has_anonymized = any(
                "[P" in str(v) or "[PHONE" in str(v) or "[EMAIL" in str(v)
                for v in extracted.values() if v
            )
            if has_anonymized:
                print(f"{SYSTEM_COLOR}  [Privacy: PII anonymized before LLM]{RESET}")

        print()

    def print_memory_extraction(self, extraction: dict):
        """Print memory extraction results."""
        entities = extraction.get("entities", [])
        relationships = extraction.get("relationships", [])

        if extraction.get("skipped"):
            return

        if entities or relationships:
            print(f"{MEMORY_COLOR}  [Memory Extracted]{RESET}")
            for entity in entities[:3]:  # Limit display
                attrs = entity.get("attributes", {})
                attr_str = ", ".join(f"{k}={v}" for k, v in attrs.items()) if attrs else ""
                print(f"{MEMORY_COLOR}    • {entity.get('type')}: {entity.get('label')}")
                if attr_str:
                    print(f"      ({attr_str})")
                print(RESET)
            print()

    async def send_message(self, message: str) -> dict:
        """Send a message to Jarvis agent."""
        self.conversation_history.append({"role": "user", "content": message})

        async with httpx.AsyncClient(timeout=30.0) as client:
            # Call agent endpoint
            resp = await client.post(
                f"{API_BASE}/agent/chat",
                headers={"Authorization": f"Bearer {self.token}"},
                json={
                    "messages": self.conversation_history,
                    "memory_context": self.memory_context
                }
            )

            if resp.status_code != 200:
                return {"response": f"[Error: {resp.status_code}]", "intent_type": "error"}

            result = resp.json()

            # Add assistant response to history
            self.conversation_history.append({
                "role": "assistant",
                "content": result.get("response", "")
            })

            return result

    async def extract_memories(self, message: str) -> dict:
        """Extract memories from conversation."""
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{API_BASE}/llm/extract",
                headers={"Authorization": f"Bearer {self.token}"},
                json={
                    "conversation": [{"role": "user", "content": message}]
                }
            )

            if resp.status_code == 200:
                return resp.json()
            return {}

    async def simulate_conversation(self):
        """Run a realistic day-in-the-life conversation."""

        # Morning routine
        conversations = [
            # --- MORNING ---
            {
                "time": "7:30 AM",
                "section": "Morning Routine",
                "messages": [
                    ("Good morning Jarvis! What's on my schedule today?",
                     "Let me check... You have your weekly team standup at 10am, and I see it's Thursday - don't forget Emma has soccer practice at 4pm."),

                    ("Oh right, can you remind Sarah about picking up Emma? I have a late meeting.",
                     None),  # Will use real API

                    ("Also schedule a dentist appointment with Dr. Chen for next week",
                     None),
                ]
            },

            # --- WORK ---
            {
                "time": "10:30 AM",
                "section": "Work Tasks",
                "messages": [
                    ("Remember that the new project deadline is December 15th and Jake from Google is our external consultant",
                     None),

                    ("Send Jake an email about the API integration meeting tomorrow",
                     None),
                ]
            },

            # --- AFTERNOON ---
            {
                "time": "2:00 PM",
                "section": "Afternoon",
                "messages": [
                    ("What do you know about Jake?",
                     None),

                    ("Mom called earlier - save her new number: 555-123-4567",
                     None),
                ]
            },

            # --- EVENING ---
            {
                "time": "6:30 PM",
                "section": "Evening Planning",
                "messages": [
                    ("It's almost date night! Any restaurant suggestions for me and Sarah?",
                     None),

                    ("Book a dinner reservation for two tomorrow at 7pm at Bella Italia",
                     None),

                    ("Thanks Jarvis! You're the best assistant.",
                     None),
                ]
            },
        ]

        for section in conversations:
            # Print section header
            print(f"\n{SYSTEM_COLOR}{'─' * 70}")
            print(f"  {section['time']} - {section['section']}")
            print(f"{'─' * 70}{RESET}\n")

            for user_msg, mock_response in section["messages"]:
                self.print_user(user_msg)

                # Get real response from API
                response = await self.send_message(user_msg)
                self.print_jarvis(response)

                # Try memory extraction for informational messages
                if "remember" in user_msg.lower() or "save" in user_msg.lower():
                    extraction = await self.extract_memories(user_msg)
                    self.print_memory_extraction(extraction)

                await asyncio.sleep(1)  # Pacing

    async def run(self):
        """Run the full demo."""
        await self.setup()
        self.print_header()

        print(f"{SYSTEM_COLOR}Memory Context Loaded:")
        print("  • Family: Sarah (wife), Emma (daughter), Mom (Linda), Dad (Robert)")
        print("  • Friends: Jake (Google)")
        print("  • Services: Dr. Chen (dentist)")
        print("  • Work: TechNova startup, Monday standups")
        print(f"  • Privacy: Anonymization ON{RESET}\n")

        await self.simulate_conversation()

        # Summary
        print("\n" + "=" * 70)
        print(f"{BOLD}     Conversation Summary{RESET}")
        print("=" * 70)
        print(f"\nTotal messages exchanged: {len(self.conversation_history)}")

        # Count intents
        print("\nCapabilities demonstrated:")
        print("  • Calendar events (create_event)")
        print("  • Messaging (send_message)")
        print("  • Memory storage (save_memory)")
        print("  • Memory recall (query_memory)")
        print("  • PII anonymization (names, phones)")
        print("  • Context-aware responses")
        print("\n" + "=" * 70 + "\n")


async def main():
    chat = JarvisChat()
    await chat.run()


if __name__ == "__main__":
    asyncio.run(main())
