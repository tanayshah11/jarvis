import 'package:jarvis/features/network_sync/models/sync_config.dart';

/// Anonymizer for deep network sync operations.
///
/// Replaces real entity IDs and names with anonymous placeholders
/// before sending to the backend for LLM inference.
class SyncAnonymizer {
  /// Maps node IDs to their placeholder tokens
  final Map<String, String> _nodeToPlaceholder = {};

  /// Maps placeholder tokens back to node IDs
  final Map<String, String> _placeholderToNode = {};

  /// Counters for each entity type
  final Map<String, int> _counters = {
    'person': 0,
    'place': 0,
    'location': 0,
    'organization': 0,
    'event': 0,
    'topic': 0,
    'default': 0,
  };

  /// Create anonymous placeholder for a node
  String anonymize(String nodeId, String nodeType) {
    // Return existing placeholder if already anonymized
    if (_nodeToPlaceholder.containsKey(nodeId)) {
      return _nodeToPlaceholder[nodeId]!;
    }

    // Get the prefix for this node type
    final normalizedType = nodeType.toLowerCase();
    final prefix = SyncConfig.placeholderPrefixes[normalizedType] ??
        SyncConfig.placeholderPrefixes['default']!;

    // Get the counter key (use 'default' for unknown types)
    final counterKey = _counters.containsKey(normalizedType) ? normalizedType : 'default';

    // Increment counter and create placeholder
    _counters[counterKey] = (_counters[counterKey] ?? 0) + 1;
    final counter = _counters[counterKey]!;
    final placeholder = '$prefix$counter';

    // Store bidirectional mapping
    _nodeToPlaceholder[nodeId] = placeholder;
    _placeholderToNode[placeholder] = nodeId;

    return placeholder;
  }

  /// De-anonymize a placeholder back to the original node ID
  String? deanonymize(String placeholder) {
    return _placeholderToNode[placeholder];
  }

  /// Check if a node has been anonymized
  bool hasPlaceholder(String nodeId) {
    return _nodeToPlaceholder.containsKey(nodeId);
  }

  /// Get the placeholder for a node (without creating new one)
  String? getPlaceholder(String nodeId) {
    return _nodeToPlaceholder[nodeId];
  }

  /// Get all node IDs that have been anonymized
  Set<String> get anonymizedNodeIds => _nodeToPlaceholder.keys.toSet();

  /// Get all placeholders
  Set<String> get placeholders => _placeholderToNode.keys.toSet();

  /// Get the full mapping (for debugging)
  Map<String, String> get mapping => Map.unmodifiable(_nodeToPlaceholder);

  /// Clear all mappings (for reuse)
  void reset() {
    _nodeToPlaceholder.clear();
    _placeholderToNode.clear();
    for (final key in _counters.keys) {
      _counters[key] = 0;
    }
  }

  /// Get current counter values
  Map<String, int> get counters => Map.unmodifiable(_counters);
}
