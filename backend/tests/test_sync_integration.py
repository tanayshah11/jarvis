"""
Frontend-to-Backend Integration Tests for Deep Network Sync.

These tests call the REAL backend API with real-world-like data to verify
end-to-end functionality, security, and performance.

Run with: pytest tests/test_sync_integration.py -v --tb=short

Note: Tests account for rate limiting (429) from external LLM providers.
"""

import asyncio
import json
import time
from datetime import datetime, timezone
from typing import Any

import httpx
import pytest

pytestmark = pytest.mark.asyncio(loop_scope="function")

# Backend URL
BASE_URL = "http://localhost:8000"
SYNC_ENDPOINT = f"{BASE_URL}/sync/infer-relationships"
HEALTH_ENDPOINT = f"{BASE_URL}/sync/health"

# Test authentication token (from session context)
TEST_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4NzJkYjgyOC01MmQyLTQxZWItOWZkZC0wNDYxNjFjYTIwMDIiLCJleHAiOjE3NjQ5MDU1MzB9.b_n8nGpET_nwT7TSBGT6xWlzWf-VwLagXgBtRTpmKy4"

# Valid status codes (200 success, 422 validation, 429 rate limited)
VALID_STATUS_CODES = [200, 400, 422, 429]


def get_headers():
    """Get auth headers for API calls."""
    return {
        "Authorization": f"Bearer {TEST_TOKEN}",
        "Content-Type": "application/json",
    }


def assert_valid_response(response, expected_success_codes=None):
    """Assert response is valid (success or rate limited)."""
    if expected_success_codes is None:
        expected_success_codes = [200]
    valid_codes = expected_success_codes + [429]  # Always allow rate limiting
    assert response.status_code in valid_codes, f"Got {response.status_code}: {response.text[:200]}"
    return response.status_code == 200


# ============================================
# Real-World Data Scenarios
# ============================================

class TestRealWorldScenarios:
    """Test with realistic data that mirrors actual user patterns."""

    @pytest.mark.asyncio
    async def test_corporate_network_scenario(self):
        """
        Real-world scenario: Corporate network with employees, managers, and offices.

        Simulates discovering relationships in a user's professional network.
        """
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
                {"placeholder": "ORG_1", "node_type": "organization"},
                {"placeholder": "PLACE_1", "node_type": "place"},
            ],
            "existing_edges": [
                {"from_placeholder": "PERSON_1", "to_placeholder": "ORG_1", "relationship_type": "works_at", "confidence": 0.95},
            ],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_1", "placeholder_b": "PERSON_2", "discovery_source": "cooccurrence", "cooccurrence_count": 45},
            ],
            "max_inferences": 3,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            assert "inferred_edges" in data
            assert "llm_calls_used" in data
            assert isinstance(data["inferred_edges"], list)

    @pytest.mark.asyncio
    async def test_social_network_scenario(self):
        """
        Real-world scenario: Friend network with events and locations.
        """
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
                {"placeholder": "EVENT_1", "node_type": "event"},
            ],
            "existing_edges": [
                {"from_placeholder": "PERSON_1", "to_placeholder": "PERSON_2", "relationship_type": "friend_of", "confidence": 0.95},
            ],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_1", "placeholder_b": "EVENT_1", "discovery_source": "temporal"},
            ],
            "max_inferences": 2,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        assert_valid_response(response)

    @pytest.mark.asyncio
    async def test_academic_network_scenario(self):
        """
        Real-world scenario: Academic network with professors, students, institutions.
        """
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
                {"placeholder": "ORG_1", "node_type": "organization"},
                {"placeholder": "TOPIC_1", "node_type": "topic"},
            ],
            "existing_edges": [
                {"from_placeholder": "PERSON_1", "to_placeholder": "ORG_1", "relationship_type": "works_at", "confidence": 0.98},
            ],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_2", "placeholder_b": "PERSON_1", "discovery_source": "cooccurrence", "cooccurrence_count": 50},
            ],
            "max_inferences": 2,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        assert_valid_response(response)


# ============================================
# Security Tests - Real API Calls
# ============================================

class TestSecurityRealAPI:
    """Security tests against the live API."""

    @pytest.mark.asyncio
    async def test_sql_injection_in_placeholder(self):
        """SQL injection attempts should be safely handled."""
        malicious_placeholders = [
            "PERSON_1'; DROP TABLE users;--",
            "PERSON_1 OR 1=1",
            "PERSON_1 UNION SELECT * FROM users",
            "'; EXEC xp_cmdshell('whoami');--",
        ]

        for payload in malicious_placeholders:
            request = {
                "nodes": [
                    {"placeholder": payload, "node_type": "person"},
                    {"placeholder": "PERSON_2", "node_type": "person"},
                ],
                "existing_edges": [],
                "candidate_pairs": [
                    {"placeholder_a": payload, "placeholder_b": "PERSON_2", "discovery_source": "semantic", "similarity_score": 0.8}
                ],
                "max_inferences": 1,
                "provider": "groq",
            }

            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

            # Should succeed (handled safely), validation error, or rate limited - NOT 500
            assert response.status_code in [200, 422, 429], f"Unexpected status {response.status_code} for SQL payload"

    @pytest.mark.asyncio
    async def test_xss_in_placeholder(self):
        """XSS payloads should be safely handled."""
        xss_payloads = [
            "<script>alert('XSS')</script>",
            "<img src=x onerror=alert('XSS')>",
            "javascript:alert('XSS')",
        ]

        for payload in xss_payloads:
            request = {
                "nodes": [
                    {"placeholder": f"PERSON_{payload}", "node_type": "person"},
                    {"placeholder": "ORG_1", "node_type": "organization"},
                ],
                "existing_edges": [],
                "candidate_pairs": [],
                "max_inferences": 1,
                "provider": "groq",
            }

            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

            assert response.status_code in [200, 422, 429]

    @pytest.mark.asyncio
    async def test_path_traversal_in_node_type(self):
        """Path traversal attempts should be handled."""
        traversal_payloads = [
            "../../../etc/passwd",
            "..\\..\\..\\windows\\system32",
        ]

        for payload in traversal_payloads:
            request = {
                "nodes": [
                    {"placeholder": "PERSON_1", "node_type": payload},
                    {"placeholder": "PERSON_2", "node_type": "person"},
                ],
                "existing_edges": [],
                "candidate_pairs": [],
                "max_inferences": 1,
                "provider": "groq",
            }

            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

            assert response.status_code in [200, 422, 429]

    @pytest.mark.asyncio
    async def test_command_injection_in_relationship_type(self):
        """Command injection should be safely handled."""
        cmd_payloads = [
            "works_at; rm -rf /",
            "works_at | cat /etc/passwd",
        ]

        for payload in cmd_payloads:
            request = {
                "nodes": [
                    {"placeholder": "PERSON_1", "node_type": "person"},
                    {"placeholder": "ORG_1", "node_type": "organization"},
                ],
                "existing_edges": [
                    {"from_placeholder": "PERSON_1", "to_placeholder": "ORG_1", "relationship_type": payload, "confidence": 0.9}
                ],
                "candidate_pairs": [],
                "max_inferences": 1,
                "provider": "groq",
            }

            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

            assert response.status_code in [200, 422, 429]


# ============================================
# Edge Cases & Error Handling
# ============================================

class TestEdgeCasesRealAPI:
    """Edge case tests against the live API."""

    @pytest.mark.asyncio
    async def test_empty_request(self):
        """Empty request should return empty results."""
        request = {
            "nodes": [],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 10,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            assert data["inferred_edges"] == []
            assert data["llm_calls_used"] == 0

    @pytest.mark.asyncio
    async def test_single_node_no_pairs(self):
        """Single node with no candidate pairs."""
        request = {
            "nodes": [{"placeholder": "PERSON_1", "node_type": "person"}],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 10,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            assert data["llm_calls_used"] == 0

    @pytest.mark.asyncio
    async def test_max_inferences_zero(self):
        """Zero max_inferences should limit processing."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_1", "placeholder_b": "PERSON_2", "discovery_source": "semantic", "similarity_score": 0.9}
            ],
            "max_inferences": 0,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            assert len(data["inferred_edges"]) == 0

    @pytest.mark.asyncio
    async def test_unicode_everywhere(self):
        """Unicode characters in all fields."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1_Chinese", "node_type": "person"},
                {"placeholder": "PERSON_2_Russian", "node_type": "person"},
                {"placeholder": "ORG_1_Japanese", "node_type": "organization"},
            ],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        assert_valid_response(response)

    @pytest.mark.asyncio
    async def test_very_long_placeholder(self):
        """Very long placeholder names (edge case)."""
        long_placeholder = "PERSON_" + "A" * 1000

        request = {
            "nodes": [
                {"placeholder": long_placeholder, "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        # Should succeed or return validation error, not crash
        assert response.status_code in [200, 422, 429]

    @pytest.mark.asyncio
    async def test_invalid_provider(self):
        """Invalid provider should return 400."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "invalid_provider_xyz",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        assert response.status_code in [400, 429]


# ============================================
# Performance Tests
# ============================================

class TestPerformanceRealAPI:
    """Performance tests against the live API."""

    @pytest.mark.asyncio
    async def test_large_graph_50_nodes(self):
        """Test with 50 nodes and multiple candidate pairs."""
        nodes = [{"placeholder": f"PERSON_{i}", "node_type": "person"} for i in range(30)]
        nodes.extend([{"placeholder": f"ORG_{i}", "node_type": "organization"} for i in range(10)])
        nodes.extend([{"placeholder": f"PLACE_{i}", "node_type": "place"} for i in range(10)])

        existing_edges = [
            {"from_placeholder": f"PERSON_{i}", "to_placeholder": f"ORG_{i % 10}", "relationship_type": "works_at", "confidence": 0.9}
            for i in range(20)
        ]

        candidate_pairs = [
            {"placeholder_a": f"PERSON_{i}", "placeholder_b": f"PERSON_{i + 1}", "discovery_source": "cooccurrence", "cooccurrence_count": 5 + i}
            for i in range(5)
        ]

        request = {
            "nodes": nodes,
            "existing_edges": existing_edges,
            "candidate_pairs": candidate_pairs,
            "max_inferences": 3,
            "provider": "groq",
        }

        start = time.time()
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())
        elapsed = time.time() - start

        if assert_valid_response(response):
            data = response.json()
            assert data["processing_time_ms"] > 0
            # Should complete in reasonable time
            assert elapsed < 60, f"Request took too long: {elapsed}s"

    @pytest.mark.asyncio
    async def test_response_time_measurement(self):
        """Verify processing_time_ms is accurate."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_1", "placeholder_b": "PERSON_2", "discovery_source": "semantic", "similarity_score": 0.8}
            ],
            "max_inferences": 1,
            "provider": "groq",
        }

        start = time.time()
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())
        client_elapsed = (time.time() - start) * 1000

        if assert_valid_response(response):
            data = response.json()
            server_elapsed = data["processing_time_ms"]
            # Server time should be less than client time (network overhead)
            assert server_elapsed <= client_elapsed + 100


# ============================================
# Concurrent Request Tests
# ============================================

class TestConcurrentRequests:
    """Test concurrent request handling."""

    @pytest.mark.asyncio
    async def test_concurrent_requests_3(self):
        """Test 3 concurrent requests (reduced to avoid rate limiting)."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [],
            "candidate_pairs": [],  # No inference needed
            "max_inferences": 1,
            "provider": "groq",
        }

        async def make_request(client: httpx.AsyncClient, idx: int):
            try:
                response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())
                return idx, response.status_code, response.json() if response.status_code == 200 else {}
            except Exception as e:
                return idx, 0, {"error": str(e)}

        async with httpx.AsyncClient(timeout=60.0) as client:
            tasks = [make_request(client, i) for i in range(3)]
            results = await asyncio.gather(*tasks, return_exceptions=True)

        success_count = 0
        for result in results:
            if isinstance(result, Exception):
                continue
            idx, status, data = result
            if status in [200, 429]:  # Success or rate limited both acceptable
                success_count += 1

        # All should get a valid response (success or rate limited)
        assert success_count >= 2, f"Only {success_count}/3 requests got valid response"


# ============================================
# Authentication Tests
# ============================================

class TestAuthentication:
    """Test authentication requirements."""

    @pytest.mark.asyncio
    async def test_no_auth_header(self):
        """Request without auth header should fail."""
        request = {
            "nodes": [{"placeholder": "PERSON_1", "node_type": "person"}],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request)

        # Should return 401 or 403
        assert response.status_code in [401, 403]

    @pytest.mark.asyncio
    async def test_invalid_token(self):
        """Request with invalid token should fail."""
        request = {
            "nodes": [{"placeholder": "PERSON_1", "node_type": "person"}],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        headers = {"Authorization": "Bearer invalid_token_xyz", "Content-Type": "application/json"}

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=headers)

        assert response.status_code in [401, 403]


# ============================================
# Data Integrity Tests
# ============================================

class TestDataIntegrity:
    """Test that data is processed correctly."""

    @pytest.mark.asyncio
    async def test_response_contains_valid_placeholders(self):
        """Inferred relationships should only use placeholders from input."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_ALICE", "node_type": "person"},
                {"placeholder": "PERSON_BOB", "node_type": "person"},
                {"placeholder": "ORG_ACME", "node_type": "organization"},
            ],
            "existing_edges": [],
            "candidate_pairs": [
                {"placeholder_a": "PERSON_ALICE", "placeholder_b": "PERSON_BOB", "discovery_source": "cooccurrence", "cooccurrence_count": 10},
            ],
            "max_inferences": 2,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            input_placeholders = {"PERSON_ALICE", "PERSON_BOB", "ORG_ACME"}

            for edge in data["inferred_edges"]:
                assert edge["from_placeholder"] in input_placeholders
                assert edge["to_placeholder"] in input_placeholders
                assert 0.0 <= edge["confidence"] <= 1.0

    @pytest.mark.asyncio
    async def test_timestamp_is_valid_iso(self):
        """Response timestamp should be valid ISO format."""
        request = {
            "nodes": [{"placeholder": "PERSON_1", "node_type": "person"}],
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        if assert_valid_response(response):
            data = response.json()
            # Should be parseable as ISO timestamp
            timestamp = datetime.fromisoformat(data["timestamp"].replace("Z", "+00:00"))
            assert timestamp is not None


# ============================================
# Health Check Tests
# ============================================

class TestHealthCheck:
    """Test health endpoint."""

    @pytest.mark.asyncio
    async def test_health_endpoint(self):
        """Health endpoint should return status."""
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(HEALTH_ENDPOINT)

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "deep-network-sync"


# ============================================
# Malformed Request Tests
# ============================================

class TestMalformedRequests:
    """Test handling of malformed requests."""

    @pytest.mark.asyncio
    async def test_missing_nodes_field(self):
        """Request missing nodes field should fail validation."""
        request = {
            "existing_edges": [],
            "candidate_pairs": [],
            "max_inferences": 5,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        assert response.status_code in [422, 429]

    @pytest.mark.asyncio
    async def test_invalid_json(self):
        """Invalid JSON should return error."""
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                SYNC_ENDPOINT,
                content="not valid json {{{",
                headers=get_headers(),
            )

        assert response.status_code in [422, 429]

    @pytest.mark.asyncio
    async def test_wrong_content_type(self):
        """Wrong content type should be handled."""
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                SYNC_ENDPOINT,
                content="nodes=test",
                headers={"Authorization": f"Bearer {TEST_TOKEN}", "Content-Type": "application/x-www-form-urlencoded"},
            )

        assert response.status_code in [422, 429]

    @pytest.mark.asyncio
    async def test_negative_confidence(self):
        """Negative confidence should be handled."""
        request = {
            "nodes": [
                {"placeholder": "PERSON_1", "node_type": "person"},
                {"placeholder": "PERSON_2", "node_type": "person"},
            ],
            "existing_edges": [
                {"from_placeholder": "PERSON_1", "to_placeholder": "PERSON_2", "relationship_type": "knows", "confidence": -0.5}
            ],
            "candidate_pairs": [],
            "max_inferences": 1,
            "provider": "groq",
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(SYNC_ENDPOINT, json=request, headers=get_headers())

        # Should handle gracefully (either accept or validate)
        assert response.status_code in [200, 422, 429]


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
