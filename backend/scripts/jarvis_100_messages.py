#!/usr/bin/env python3
"""
100-Message Jarvis Conversation

A comprehensive test of Jarvis capabilities over 100 messages,
simulating a full day of real user interactions.
"""

import asyncio
import httpx
from datetime import datetime


API_BASE = "http://localhost:8000"

# Colors
USER = "\033[92m"
JARVIS = "\033[93m"
SYSTEM = "\033[90m"
TOOL = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"


# 50 user messages (each gets a response = 100 total messages)
USER_MESSAGES = [
    # Morning (1-10)
    "Good morning Jarvis!",
    "What day is it today?",
    "Schedule a team meeting for tomorrow at 10am",
    "Add Sarah to that meeting",
    "What's the weather like?",
    "Remind me to call Mom later",
    "Set an alarm for 8am tomorrow",
    "What meetings do I have this week?",
    "Cancel my 3pm meeting",
    "Send an email to Jake about the project update",

    # Work tasks (11-20)
    "Remember that the project deadline is January 15th",
    "Who is our main client contact?",
    "Save that Mike from Acme Corp is our client contact",
    "What's Mike's phone number?",
    "Save Mike's number as 555-234-5678",
    "Draft a message to the team about the deadline",
    "Schedule a client call with Mike next Tuesday",
    "What do I know about Acme Corp?",
    "Remember that Acme Corp is based in New York",
    "Add a note that Mike prefers morning meetings",

    # Personal (21-30)
    "When is Sarah's birthday?",
    "Remember Sarah's birthday is March 15th",
    "Set a reminder for March 14th to buy a gift",
    "What gift ideas do you have for Sarah?",
    "She likes photography and hiking",
    "Remember that Sarah likes photography and hiking",
    "Find a nice restaurant for date night",
    "Book a table at Bella Italia for Friday 7pm",
    "What's our anniversary date?",
    "Remember our anniversary is June 20th",

    # Afternoon tasks (31-40)
    "Text Sarah that I'll be home late",
    "What's on my todo list?",
    "Add 'finish quarterly report' to my tasks",
    "What's the status of the quarterly report?",
    "Mark the quarterly report as in progress",
    "Schedule a dentist appointment next week",
    "Who is my dentist?",
    "Remember Dr. Chen is my dentist",
    "What's Dr. Chen's office address?",
    "Save Dr. Chen's address as 123 Medical Plaza",

    # Evening (41-50)
    "What should I make for dinner?",
    "Remember that Emma is allergic to peanuts",
    "Find a recipe without peanuts",
    "Set a timer for 30 minutes",
    "Remind me to take out the trash",
    "What time does Emma's school start?",
    "Remember Emma's school starts at 8:30am",
    "Set a recurring alarm for 7am on weekdays",
    "What's the traffic like to work?",
    "Thanks Jarvis, you've been super helpful today!",
]

MEMORY_CONTEXT = """
Sarah is the user's wife. Works as a designer.
Emma is the user's daughter, age 7.
Mom is the user's mother, named Linda.
Dad is the user's father, named Robert.
Jake is a colleague and friend.
The user works at TechNova as a software engineer.
Max is the family dog.
Home address is 742 Maple Street.
"""


async def run_conversation():
    """Run 100-message conversation with Jarvis."""

    print("\n" + "=" * 70)
    print(f"{BOLD}     100-Message Jarvis Conversation Test{RESET}")
    print("=" * 70)
    print(f"{SYSTEM}Starting at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{RESET}")
    print("-" * 70 + "\n")

    # Setup auth
    async with httpx.AsyncClient(timeout=30.0) as client:
        # Login or register
        resp = await client.post(
            f"{API_BASE}/auth/login",
            json={"email": "test100@jarvis.ai", "password": "test1234"}
        )
        if resp.status_code != 200:
            await client.post(
                f"{API_BASE}/auth/register",
                json={"email": "test100@jarvis.ai", "password": "test1234", "name": "Test User"}
            )
            resp = await client.post(
                f"{API_BASE}/auth/login",
                json={"email": "test100@jarvis.ai", "password": "test1234"}
            )
        token = resp.json()["access_token"]

        # Enable anonymization
        await client.put(
            f"{API_BASE}/preferences/privacy",
            headers={"Authorization": f"Bearer {token}"},
            json={"enable_anonymization": True, "enable_memory_extraction": True}
        )

    # Track stats
    stats = {
        "total_messages": 0,
        "intents": {},
        "tool_calls": 0,
        "errors": 0,
        "anonymized": 0,
    }

    conversation_history = []

    async with httpx.AsyncClient(timeout=30.0) as client:
        for i, user_msg in enumerate(USER_MESSAGES, 1):
            msg_num = i * 2 - 1  # Odd numbers for user

            # Print user message
            print(f"{SYSTEM}[{msg_num}/100]{RESET} {USER}{BOLD}User:{RESET} {user_msg}")

            conversation_history.append({"role": "user", "content": user_msg})

            # Call Jarvis
            try:
                resp = await client.post(
                    f"{API_BASE}/agent/chat",
                    headers={"Authorization": f"Bearer {token}"},
                    json={
                        "messages": conversation_history[-10:],  # Keep last 10 for context
                        "memory_context": MEMORY_CONTEXT
                    }
                )

                if resp.status_code == 200:
                    result = resp.json()
                    jarvis_response = result.get("response", "...")
                    intent = result.get("intent_type", "general")
                    tool_calls = result.get("tool_calls")
                    extracted = result.get("extracted_fields", {})

                    # Update stats
                    stats["total_messages"] += 2
                    stats["intents"][intent] = stats["intents"].get(intent, 0) + 1
                    if tool_calls:
                        stats["tool_calls"] += len(tool_calls)

                    # Check for anonymization
                    if any("[P" in str(v) or "[PHONE" in str(v) for v in extracted.values() if v):
                        stats["anonymized"] += 1

                    # Print Jarvis response
                    msg_num = i * 2  # Even numbers for Jarvis
                    print(f"{SYSTEM}[{msg_num}/100]{RESET} {JARVIS}{BOLD}Jarvis:{RESET} {jarvis_response}")

                    # Show intent and tool
                    extras = []
                    if intent != "general":
                        extras.append(f"intent={intent}")
                    if tool_calls:
                        tools = [t["name"] for t in tool_calls]
                        extras.append(f"tools={tools}")
                    if extras:
                        print(f"        {TOOL}[{', '.join(extras)}]{RESET}")

                    conversation_history.append({"role": "assistant", "content": jarvis_response})

                else:
                    stats["errors"] += 1
                    print(f"        {SYSTEM}[Error: {resp.status_code}]{RESET}")

            except Exception as e:
                stats["errors"] += 1
                print(f"        {SYSTEM}[Exception: {e}]{RESET}")

            print()  # Blank line between exchanges

            # Small delay to avoid rate limiting
            await asyncio.sleep(0.3)

    # Print summary
    print("\n" + "=" * 70)
    print(f"{BOLD}     Conversation Summary{RESET}")
    print("=" * 70)
    print(f"\n{BOLD}Messages:{RESET} {stats['total_messages']}")
    print(f"{BOLD}Tool Calls:{RESET} {stats['tool_calls']}")
    print(f"{BOLD}Anonymized Requests:{RESET} {stats['anonymized']}")
    print(f"{BOLD}Errors:{RESET} {stats['errors']}")

    print(f"\n{BOLD}Intent Distribution:{RESET}")
    for intent, count in sorted(stats["intents"].items(), key=lambda x: -x[1]):
        bar = "█" * count
        print(f"  {intent:20} {bar} ({count})")

    print(f"\n{SYSTEM}Finished at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{RESET}")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    asyncio.run(run_conversation())
