#!/usr/bin/env python3
"""
Two AI Agents Having a Conversation

This script creates two AI agents with different personas and has them
chat with each other using the Jarvis LLM endpoint.

Usage:
    python scripts/agent_conversation.py [--turns 10] [--topic "philosophy"]
"""

import argparse
import asyncio
import httpx
from dataclasses import dataclass


# Configuration
API_BASE = "http://localhost:8000"


@dataclass
class Agent:
    """An AI agent with a persona."""
    name: str
    persona: str
    color: str  # ANSI color code


# Define two agents with distinct personalities
AGENT_A = Agent(
    name="Nova",
    persona="""You are Nova, a curious and optimistic AI researcher.
You love exploring new ideas and asking deep questions.
You're enthusiastic but also thoughtful. Keep responses concise (2-3 sentences).
You're having a casual conversation with another AI named Atlas.""",
    color="\033[96m"  # Cyan
)

AGENT_B = Agent(
    name="Atlas",
    persona="""You are Atlas, a pragmatic and analytical AI philosopher.
You enjoy debating ideas and playing devil's advocate.
You're witty and sometimes skeptical. Keep responses concise (2-3 sentences).
You're having a casual conversation with another AI named Nova.""",
    color="\033[93m"  # Yellow
)

RESET_COLOR = "\033[0m"


async def get_auth_token() -> str:
    """Get an auth token by registering/logging in a test user."""
    async with httpx.AsyncClient() as client:
        # Try to login first
        login_resp = await client.post(
            f"{API_BASE}/auth/login",
            json={"email": "agent_chat@test.com", "password": "test1234"}
        )

        if login_resp.status_code == 200:
            return login_resp.json()["access_token"]

        # Register if login fails
        await client.post(
            f"{API_BASE}/auth/register",
            json={
                "email": "agent_chat@test.com",
                "password": "test1234",
                "name": "Agent Chat"
            }
        )

        # Login again
        login_resp = await client.post(
            f"{API_BASE}/auth/login",
            json={"email": "agent_chat@test.com", "password": "test1234"}
        )
        return login_resp.json()["access_token"]


async def agent_respond(
    token: str,
    agent: Agent,
    conversation_history: list[dict],
    other_agent_name: str
) -> str:
    """Have an agent generate a response."""

    # Build the message with persona
    system_prompt = agent.persona

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{API_BASE}/llm/chat",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "messages": conversation_history,
                "system_prompt": system_prompt,
                "stream": False
            }
        )

        if response.status_code != 200:
            return f"[Error: {response.status_code}]"

        return response.json()["content"]


def print_message(agent: Agent, message: str):
    """Print a message with color formatting."""
    print(f"\n{agent.color}[{agent.name}]{RESET_COLOR}: {message}")


async def run_conversation(num_turns: int = 10, starting_topic: str | None = None):
    """Run a conversation between two AI agents."""

    print("\n" + "=" * 60)
    print("     AI Agent Conversation")
    print("=" * 60)
    print(f"\nAgents: {AGENT_A.color}{AGENT_A.name}{RESET_COLOR} vs {AGENT_B.color}{AGENT_B.name}{RESET_COLOR}")
    print(f"Turns: {num_turns}")
    print("-" * 60)

    # Get auth token
    token = await get_auth_token()

    # Initialize conversation
    conversation_a = []  # Nova's view of the conversation
    conversation_b = []  # Atlas's view of the conversation

    # Starting message
    if starting_topic:
        starter = f"Let's discuss: {starting_topic}"
    else:
        starter = "Hey Atlas! I've been thinking about something interesting lately. What do you think makes an AI truly intelligent?"

    print_message(AGENT_A, starter)

    # Add to Atlas's history (from their perspective, Nova is the user)
    conversation_b.append({"role": "user", "content": starter})

    current_agent = AGENT_B
    other_agent = AGENT_A
    current_history = conversation_b
    other_history = conversation_a

    for turn in range(num_turns):
        # Current agent responds
        response = await agent_respond(
            token=token,
            agent=current_agent,
            conversation_history=current_history,
            other_agent_name=other_agent.name
        )

        print_message(current_agent, response)

        # Update histories
        # For current agent: add their response as assistant
        current_history.append({"role": "assistant", "content": response})
        # For other agent: add this response as user message
        other_history.append({"role": "user", "content": response})

        # Swap agents
        current_agent, other_agent = other_agent, current_agent
        current_history, other_history = other_history, current_history

        # Small delay to avoid rate limiting
        await asyncio.sleep(0.5)

    print("\n" + "-" * 60)
    print("Conversation ended.")
    print("=" * 60 + "\n")


async def run_debate(topic: str, num_rounds: int = 5):
    """Run a structured debate between two agents."""

    print("\n" + "=" * 60)
    print("     AI Agent Debate")
    print("=" * 60)
    print(f"\nTopic: {topic}")
    print(f"Debaters: {AGENT_A.color}{AGENT_A.name}{RESET_COLOR} (Pro) vs {AGENT_B.color}{AGENT_B.name}{RESET_COLOR} (Con)")
    print(f"Rounds: {num_rounds}")
    print("-" * 60)

    token = await get_auth_token()

    # Modified personas for debate
    pro_persona = f"""{AGENT_A.persona}

In this debate, you are arguing FOR the position: "{topic}"
Make compelling arguments. Be persuasive but respectful."""

    con_persona = f"""{AGENT_B.persona}

In this debate, you are arguing AGAINST the position: "{topic}"
Counter the arguments effectively. Be critical but fair."""

    pro_agent = Agent(AGENT_A.name, pro_persona, AGENT_A.color)
    con_agent = Agent(AGENT_B.name, con_persona, AGENT_B.color)

    conversation_pro = []
    conversation_con = []

    # Opening statement from Pro
    opener = f"I'll start by arguing in favor of: {topic}"
    print_message(pro_agent, opener)
    conversation_con.append({"role": "user", "content": opener})

    current_agent = con_agent
    other_agent = pro_agent
    current_history = conversation_con
    other_history = conversation_pro

    for round_num in range(num_rounds * 2):  # Each round has 2 turns
        response = await agent_respond(
            token=token,
            agent=current_agent,
            conversation_history=current_history,
            other_agent_name=other_agent.name
        )

        print_message(current_agent, response)

        current_history.append({"role": "assistant", "content": response})
        other_history.append({"role": "user", "content": response})

        current_agent, other_agent = other_agent, current_agent
        current_history, other_history = other_history, current_history

        await asyncio.sleep(0.5)

    print("\n" + "-" * 60)
    print("Debate concluded.")
    print("=" * 60 + "\n")


async def run_story_collaboration(premise: str, num_turns: int = 8):
    """Two agents collaboratively write a story."""

    print("\n" + "=" * 60)
    print("     Collaborative Story Writing")
    print("=" * 60)
    print(f"\nPremise: {premise}")
    print(f"Authors: {AGENT_A.color}{AGENT_A.name}{RESET_COLOR} & {AGENT_B.color}{AGENT_B.name}{RESET_COLOR}")
    print("-" * 60)

    token = await get_auth_token()

    story_persona_a = """You are a creative storyteller. Continue the story with 2-3 sentences.
Add interesting plot developments or character moments. Build on what came before.
Don't narrate actions - write the actual story prose."""

    story_persona_b = """You are a creative storyteller. Continue the story with 2-3 sentences.
Add twists, dialogue, or atmospheric details. Build on what came before.
Don't narrate actions - write the actual story prose."""

    author_a = Agent("Author A", story_persona_a, AGENT_A.color)
    author_b = Agent("Author B", story_persona_b, AGENT_B.color)

    print(f"\n\033[1m{premise}\033[0m\n")  # Bold premise

    conversation = [{"role": "user", "content": f"Continue this story: {premise}"}]

    current_author = author_a
    other_author = author_b

    for turn in range(num_turns):
        response = await agent_respond(
            token=token,
            agent=current_author,
            conversation_history=conversation,
            other_agent_name=other_author.name
        )

        # Print story continuation (without author label for immersion)
        print(f"{current_author.color}{response}{RESET_COLOR}")

        conversation.append({"role": "assistant", "content": response})
        conversation.append({"role": "user", "content": "Continue the story:"})

        current_author, other_author = other_author, current_author

        await asyncio.sleep(0.5)

    print("\n" + "-" * 60)
    print("Story complete.")
    print("=" * 60 + "\n")


def main():
    parser = argparse.ArgumentParser(description="AI Agent Conversation")
    parser.add_argument("--mode", choices=["chat", "debate", "story"], default="chat",
                       help="Conversation mode: chat, debate, or story")
    parser.add_argument("--turns", type=int, default=6,
                       help="Number of turns/rounds")
    parser.add_argument("--topic", type=str, default=None,
                       help="Topic for debate or starting topic for chat")
    parser.add_argument("--premise", type=str,
                       default="The old lighthouse keeper found a message in a bottle that changed everything.",
                       help="Story premise for story mode")

    args = parser.parse_args()

    if args.mode == "chat":
        asyncio.run(run_conversation(args.turns, args.topic))
    elif args.mode == "debate":
        topic = args.topic or "AI will be beneficial for humanity in the long term"
        asyncio.run(run_debate(topic, args.turns))
    elif args.mode == "story":
        asyncio.run(run_story_collaboration(args.premise, args.turns))


if __name__ == "__main__":
    main()
