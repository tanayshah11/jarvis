"""
Deep Network Sync - LLM-powered relationship inference.

Privacy-First Architecture:
- Device sends ONLY anonymized data (PERSON_1, ORG_1, etc.)
- Backend infers relationships between placeholders
- Device de-anonymizes results locally
- NO real user data ever reaches the server

This endpoint supports the 30-minute background sync that discovers
new connections in the user's memory graph.
"""

import json
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.factory import get_ai_provider
from app.database import get_db
from app.models import User
from app.dependencies.quota import check_quota, increment_token_usage


router = APIRouter(prefix="/sync", tags=["sync"])


# ============================================
# Request/Response Models
# ============================================


class AnonymizedNode(BaseModel):
    """A node with anonymized placeholder ID."""
    placeholder: str  # e.g., "PERSON_1", "ORG_2"
    node_type: str    # e.g., "person", "organization", "place"
    attributes: Optional[dict] = None  # Non-identifying attributes if needed


class AnonymizedEdge(BaseModel):
    """An existing edge between anonymized nodes."""
    from_placeholder: str
    to_placeholder: str
    relationship_type: str
    confidence: float


class CandidatePair(BaseModel):
    """A candidate pair for relationship inference."""
    placeholder_a: str
    placeholder_b: str
    discovery_source: str  # "semantic", "cooccurrence", "temporal"
    similarity_score: Optional[float] = None
    cooccurrence_count: Optional[int] = None


class RelationshipInferenceRequest(BaseModel):
    """
    Request to infer relationships between anonymized entities.

    All data is pre-anonymized by the device before reaching here.
    We never see real names, only placeholders like PERSON_1.
    """
    nodes: list[AnonymizedNode]
    existing_edges: list[AnonymizedEdge]
    candidate_pairs: list[CandidatePair]
    max_inferences: int = 10
    provider: str = "groq"


class InferredRelationship(BaseModel):
    """A relationship inferred by the LLM."""
    from_placeholder: str
    to_placeholder: str
    relationship_type: str
    confidence: float
    reasoning: str


class RelationshipInferenceResponse(BaseModel):
    """Response with inferred relationships."""
    inferred_edges: list[InferredRelationship]
    llm_calls_used: int
    processing_time_ms: int
    timestamp: str


# ============================================
# Endpoints
# ============================================


@router.post("/infer-relationships", response_model=RelationshipInferenceResponse)
async def infer_relationships(
    request: RelationshipInferenceRequest,
    current_user: User = Depends(check_quota),
    db: AsyncSession = Depends(get_db),
):
    """
    Infer relationships between anonymized entities using LLM.

    Privacy guarantees:
    - Only anonymized placeholders are processed (PERSON_1, ORG_2, etc.)
    - NO real user data ever reaches this endpoint
    - Device handles all anonymization/de-anonymization

    The LLM analyzes the graph structure and candidate pairs to infer
    meaningful relationships that don't already exist.
    """
    start_time = datetime.now(timezone.utc)

    if not request.candidate_pairs:
        return RelationshipInferenceResponse(
            inferred_edges=[],
            llm_calls_used=0,
            processing_time_ms=0,
            timestamp=start_time.isoformat(),
        )

    # Limit candidates to max_inferences
    candidates = request.candidate_pairs[:request.max_inferences]

    try:
        provider = get_ai_provider(request.provider)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid provider: {request.provider}",
        )

    # Build the inference prompt
    prompt = _build_inference_prompt(
        nodes=request.nodes,
        existing_edges=request.existing_edges,
        candidates=candidates,
    )

    # Call LLM for inference
    response_content, tokens_used = await provider.chat_non_streaming(
        messages=[{"role": "user", "content": prompt}],
        system_prompt=_inference_system_prompt(),
        temperature=0.3,  # Lower temperature for more consistent structured output
        max_tokens=2048,
    )

    # Parse LLM response
    inferred = _parse_inference_response(response_content)

    # Track token usage
    if tokens_used:
        await increment_token_usage(current_user.id, int(tokens_used), db)

    end_time = datetime.now(timezone.utc)
    processing_ms = int((end_time - start_time).total_seconds() * 1000)

    return RelationshipInferenceResponse(
        inferred_edges=inferred,
        llm_calls_used=1,
        processing_time_ms=processing_ms,
        timestamp=end_time.isoformat(),
    )


@router.get("/health")
async def sync_health() -> dict:
    """Check sync service health."""
    return {
        "status": "healthy",
        "service": "deep-network-sync",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# ============================================
# Internal Functions
# ============================================


def _inference_system_prompt() -> str:
    """System prompt for relationship inference."""
    return """You are a knowledge graph analyst. Your task is to infer meaningful
relationships between entities based on graph structure and co-occurrence patterns.

IMPORTANT: You are analyzing ANONYMIZED data. Entity names like PERSON_1, ORG_2,
PLACE_3 are placeholders. Focus on the structural relationships, not the identities.

Output ONLY valid JSON array. No explanation text outside the JSON."""


def _build_inference_prompt(
    nodes: list[AnonymizedNode],
    existing_edges: list[AnonymizedEdge],
    candidates: list[CandidatePair],
) -> str:
    """Build the prompt for relationship inference."""
    nodes_json = json.dumps(
        [{"placeholder": n.placeholder, "type": n.node_type} for n in nodes],
        indent=2,
    )

    edges_json = json.dumps(
        [
            {
                "from": e.from_placeholder,
                "to": e.to_placeholder,
                "type": e.relationship_type,
            }
            for e in existing_edges
        ],
        indent=2,
    )

    candidates_json = json.dumps(
        [
            {
                "a": c.placeholder_a,
                "b": c.placeholder_b,
                "source": c.discovery_source,
                "similarity": c.similarity_score,
                "cooccurrence": c.cooccurrence_count,
            }
            for c in candidates
        ],
        indent=2,
    )

    return f"""Analyze this anonymized knowledge graph and infer relationships for the candidate pairs.

## Nodes (Entities)
{nodes_json}

## Existing Edges (Known Relationships)
{edges_json}

## Candidate Pairs (Potential New Relationships)
{candidates_json}

## Task
For each candidate pair, determine if a meaningful relationship likely exists based on:
1. Graph structure (shared connections, path patterns)
2. Entity types (person-org suggests works_at, person-person suggests knows, etc.)
3. Discovery signals (high semantic similarity or co-occurrence count)

## Valid Relationship Types
- knows: Two people who know each other
- works_with: Colleagues or collaborators
- friend_of: Friends
- family_of: Family members
- frequents: Person regularly visits a place
- lives_in: Person lives at a location
- works_at: Person works at an organization
- attended: Person attended an event
- interested_in: Person has interest in a topic
- expert_in: Person is expert in a topic
- near: Two locations that are geographically close
- similar_to: Two entities that are similar in nature

## Output Format
Return a JSON array of inferred relationships. For each valid inference, include:
- from: source placeholder
- to: target placeholder
- type: relationship type from the valid types above
- confidence: 0.0-1.0 based on evidence strength
- reasoning: brief explanation (1 sentence)

Only include relationships with confidence >= 0.6. Skip pairs where no relationship is evident.

Return ONLY the JSON array, no other text:
[{{"from": "PERSON_1", "to": "ORG_1", "type": "works_at", "confidence": 0.85, "reasoning": "High co-occurrence and person-org type pattern"}}]"""


def _parse_inference_response(response: str) -> list[InferredRelationship]:
    """Parse LLM response into InferredRelationship objects."""
    try:
        # Clean up response - extract JSON array
        response = response.strip()

        # Handle markdown code blocks
        if "```json" in response:
            response = response.split("```json")[1].split("```")[0].strip()
        elif "```" in response:
            response = response.split("```")[1].split("```")[0].strip()

        # Find the JSON array
        start_idx = response.find("[")
        end_idx = response.rfind("]") + 1

        if start_idx == -1 or end_idx == 0:
            return []

        json_str = response[start_idx:end_idx]
        parsed = json.loads(json_str)

        relationships = []
        for item in parsed:
            if isinstance(item, dict):
                # Validate required fields
                if all(k in item for k in ["from", "to", "type", "confidence"]):
                    # Safely parse confidence value
                    try:
                        confidence_val = float(item.get("confidence", 0.6))
                        # Clamp to valid range and handle NaN/Inf
                        if not (0.0 <= confidence_val <= 1.0) or confidence_val != confidence_val:
                            confidence_val = 0.6  # Default for invalid values
                    except (ValueError, TypeError):
                        confidence_val = 0.6  # Default for non-numeric values

                    relationships.append(InferredRelationship(
                        from_placeholder=str(item["from"]),
                        to_placeholder=str(item["to"]),
                        relationship_type=str(item["type"]),
                        confidence=confidence_val,
                        reasoning=str(item.get("reasoning", "Inferred from graph structure")),
                    ))

        return relationships

    except (json.JSONDecodeError, KeyError, TypeError):
        # If parsing fails, return empty list
        return []
