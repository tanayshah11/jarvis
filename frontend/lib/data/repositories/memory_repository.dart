import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../vector/vector_store.dart';
import '../embeddings/local_embedding_service.dart';

const String _logName = 'MemoryRepository';

/// Repository for memory graph operations (nodes and edges)
/// Provides semantic search and graph traversal
class MemoryRepository {
  final AppDatabase _db;
  final VectorStore _vectorStore;
  final LocalEmbeddingService _embeddingService;
  final Uuid _uuid = const Uuid();

  MemoryRepository({
    required AppDatabase db,
    required VectorStore vectorStore,
    required LocalEmbeddingService embeddingService,
  }) : _db = db,
       _vectorStore = vectorStore,
       _embeddingService = embeddingService;

  // ============================================
  // Node Operations
  // ============================================

  /// Get all memory nodes
  Future<List<MemoryNode>> getAllNodes() {
    return _db.getAllMemoryNodes();
  }

  /// Get a specific node by ID
  Future<MemoryNode?> getNode(String id) {
    return _db.getMemoryNode(id);
  }

  /// Search nodes by name or type
  Future<List<MemoryNode>> searchNodes(String query) {
    return _db.searchMemoryNodes(query);
  }

  /// Find node by source and source ID
  Future<MemoryNode?> findBySourceId(String source, String sourceId) {
    return _db.findMemoryNodeBySourceId(source, sourceId);
  }

  /// Create a new memory node
  Future<String> createNode({
    required String nodeType,
    required String name,
    String? source,
    String? sourceId,
    Map<String, dynamic>? attributes,
    double confidence = 0.8,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertMemoryNode(
      MemoryNodesCompanion.insert(
        id: id,
        nodeType: nodeType,
        name: name,
        source: Value(source),
        sourceId: Value(sourceId),
        attributes: Value(attributes != null ? jsonEncode(attributes) : null),
        confidence: Value(confidence),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // Generate and store embedding
    await _generateAndStoreNodeEmbedding(id, name, nodeType, attributes);

    return id;
  }

  /// Update an existing node
  Future<void> updateNode(
    String id, {
    String? name,
    Map<String, dynamic>? attributes,
    double? confidence,
  }) async {
    final existing = await _db.getMemoryNode(id);
    if (existing == null) return;

    final now = DateTime.now();
    var updated = existing.copyWith(updatedAt: now, lastReferenced: Value(now));

    if (name != null) {
      updated = updated.copyWith(name: name);
    }
    if (attributes != null) {
      updated = updated.copyWith(attributes: Value(jsonEncode(attributes)));
    }
    if (confidence != null) {
      updated = updated.copyWith(confidence: confidence);
    }

    await _db.updateMemoryNode(updated);

    // Update embedding if name changed
    if (name != null) {
      await _generateAndStoreNodeEmbedding(
        id,
        name,
        existing.nodeType,
        attributes,
      );
    }
  }

  /// Upsert a node (create or update)
  ///
  /// Resolution strategy:
  /// 1. First check by source+sourceId (exact match)
  /// 2. Then check by name+type (semantic match)
  /// 3. If found, update only if new confidence >= existing confidence
  /// 4. Merge attributes, with higher confidence values winning
  Future<String> upsertNode({
    required String nodeType,
    required String name,
    String? source,
    String? sourceId,
    Map<String, dynamic>? attributes,
    double confidence = 0.8,
  }) async {
    MemoryNode? existing;

    // 1. Check if node exists by source+sourceId (exact match)
    if (source != null && sourceId != null) {
      existing = await findBySourceId(source, sourceId);
    }

    // 2. If not found, check by name+type (semantic match)
    existing ??= await _findByNameAndType(name, nodeType);

    // 3. If found, handle update with confidence-based resolution
    if (existing != null) {
      final existingConfidence = existing.confidence;

      // Only update if new confidence is >= existing
      // This means explicit user statements (0.95) override seed data (0.7)
      if (confidence >= existingConfidence) {
        // Merge attributes - new values override old ones
        Map<String, dynamic>? mergedAttributes;
        if (attributes != null || existing.attributes != null) {
          mergedAttributes = <String, dynamic>{};

          // Start with existing attributes
          if (existing.attributes != null) {
            try {
              final existingAttrs = jsonDecode(existing.attributes!) as Map<String, dynamic>;
              mergedAttributes.addAll(existingAttrs);
            } catch (_) {}
          }

          // Override with new attributes (higher confidence wins)
          if (attributes != null) {
            mergedAttributes.addAll(attributes);
          }
        }

        developer.log(
          'Updating existing node "$name" (${existing.id}): '
          'confidence $existingConfidence -> $confidence',
          name: _logName,
        );

        await updateNode(
          existing.id,
          name: name,
          attributes: mergedAttributes,
          confidence: confidence,
        );
        return existing.id;
      } else {
        // New data has lower confidence - just mark as referenced
        developer.log(
          'Keeping existing node "$name" (confidence $existingConfidence > $confidence)',
          name: _logName,
        );
        await markNodeReferenced(existing.id);
        return existing.id;
      }
    }

    // 4. Create new node
    return createNode(
      nodeType: nodeType,
      name: name,
      source: source,
      sourceId: sourceId,
      attributes: attributes,
      confidence: confidence,
    );
  }

  /// Find a node by name and type (fuzzy matching)
  /// Matches: exact, first name, or contains
  Future<MemoryNode?> _findByNameAndType(String name, String nodeType) async {
    final allNodes = await _db.getAllMemoryNodes();
    final nameLower = name.toLowerCase().trim();
    final nameFirst = nameLower.split(' ').first; // First name for fuzzy match

    MemoryNode? exactMatch;
    MemoryNode? firstNameMatch;
    MemoryNode? containsMatch;

    for (final node in allNodes) {
      if (node.nodeType != nodeType) continue;

      final nodeNameLower = node.name.toLowerCase();
      final nodeNameFirst = nodeNameLower.split(' ').first;

      // Exact match (highest priority)
      if (nodeNameLower == nameLower) {
        exactMatch = node;
        break;
      }

      // First name match (e.g., "Alex" matches "Alex Kim")
      if (firstNameMatch == null) {
        if (nodeNameFirst == nameLower || nameFirst == nodeNameLower || nodeNameFirst == nameFirst) {
          firstNameMatch = node;
        }
      }

      // Contains match (lowest priority)
      if (containsMatch == null) {
        if (nodeNameLower.contains(nameLower) || nameLower.contains(nodeNameLower)) {
          containsMatch = node;
        }
      }
    }

    final match = exactMatch ?? firstNameMatch ?? containsMatch;
    if (match != null) {
      developer.log(
        'Fuzzy match: "$name" -> "${match.name}" (${match.nodeType})',
        name: _logName,
      );
    }
    return match;
  }

  /// Mark node as referenced (updates lastReferenced timestamp)
  Future<void> markNodeReferenced(String id) async {
    final existing = await _db.getMemoryNode(id);
    if (existing == null) return;

    await _db.updateMemoryNode(
      existing.copyWith(lastReferenced: Value(DateTime.now())),
    );
  }

  /// Delete a memory node and its associated data
  /// This will:
  /// 1. Delete the vector embedding
  /// 2. Delete all connected edges (both incoming and outgoing)
  /// 3. Delete the node itself
  Future<bool> deleteNode(String id) async {
    try {
      final existing = await _db.getMemoryNode(id);
      if (existing == null) {
        developer.log(
          'Attempted to delete non-existent node: $id',
          name: _logName,
          level: 800, // Info level
        );
        return false;
      }

      // 1. Delete vector embedding
      await _vectorStore.deleteMemoryVector(id);

      // 2. Delete all connected edges
      final deletedEdges = await _db.deleteEdgesForNode(id);
      developer.log(
        'Deleted $deletedEdges edges for node $id',
        name: _logName,
        level: 800,
      );

      // 3. Delete the node
      await _db.deleteMemoryNode(id);

      developer.log(
        'Successfully deleted node: $id (${existing.name})',
        name: _logName,
        level: 800,
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete node $id: $e',
        name: _logName,
        level: 1000, // Error level
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Generate embedding for a node
  Future<void> _generateAndStoreNodeEmbedding(
    String nodeId,
    String name,
    String nodeType,
    Map<String, dynamic>? attributes,
  ) async {
    try {
      // Build text for embedding
      final textParts = <String>[name, nodeType];
      if (attributes != null) {
        attributes.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            textParts.add('$key: $value');
          }
        });
      }
      final text = textParts.join(' ');

      final embedding = await _embeddingService.embed(text);

      final vectorId = await _vectorStore.storeMemoryVector(
        nodeId: nodeId,
        sourceText: text,
        embedding: embedding,
      );

      // Update node with vector ID
      final node = await _db.getMemoryNode(nodeId);
      if (node != null) {
        await _db.updateMemoryNode(node.copyWith(vectorId: Value(vectorId)));
      }
    } catch (e, stackTrace) {
      // Embedding generation is optional - log warning but don't fail
      developer.log(
        'Failed to generate embedding for node $nodeId: $e',
        name: _logName,
        level: 900, // Warning level
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================
  // Edge Operations
  // ============================================

  /// Get all edges
  Future<List<MemoryEdge>> getAllEdges() {
    return _db.getAllMemoryEdges();
  }

  /// Get edges from a node
  Future<List<MemoryEdge>> getEdgesFromNode(String nodeId) {
    return _db.getEdgesFromNode(nodeId);
  }

  /// Get edges to a node
  Future<List<MemoryEdge>> getEdgesToNode(String nodeId) {
    return _db.getEdgesToNode(nodeId);
  }

  /// Create a new edge (relationship)
  Future<String> createEdge({
    required String fromNodeId,
    required String toNodeId,
    required String relationshipType,
    Map<String, dynamic>? attributes,
    double confidence = 0.7,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertMemoryEdge(
      MemoryEdgesCompanion.insert(
        id: id,
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
        relationshipType: relationshipType,
        attributes: Value(attributes != null ? jsonEncode(attributes) : null),
        confidence: Value(confidence),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    return id;
  }

  /// Upsert an edge (create or update)
  Future<String> upsertEdge({
    required String fromNodeId,
    required String toNodeId,
    required String relationshipType,
    Map<String, dynamic>? attributes,
    double confidence = 0.7,
  }) async {
    final existing = await _db.findEdge(fromNodeId, toNodeId, relationshipType);

    if (existing != null) {
      // Update existing edge
      final now = DateTime.now();
      await _db.updateMemoryEdge(
        existing.copyWith(
          referenceCount: existing.referenceCount + 1,
          confidence: (existing.confidence + confidence) / 2,
          updatedAt: now,
          lastReferenced: Value(now),
          attributes: attributes != null
              ? Value(jsonEncode(attributes))
              : Value(existing.attributes),
        ),
      );
      return existing.id;
    }

    // Create new edge
    return createEdge(
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      relationshipType: relationshipType,
      attributes: attributes,
      confidence: confidence,
    );
  }

  // ============================================
  // Graph Traversal
  // ============================================

  /// Find all nodes connected to a given node within N hops
  Future<List<MemoryNode>> findConnectedNodes(
    String nodeId, {
    int maxDepth = 2,
  }) {
    return _db.findConnectedNodes(nodeId, maxDepth);
  }

  /// Find path between two nodes
  Future<List<String>> findPath(
    String fromNodeId,
    String toNodeId, {
    int maxDepth = 5,
  }) {
    return _db.findPath(fromNodeId, toNodeId, maxDepth);
  }

  /// Get a node with all its relationships
  Future<NodeWithRelationships?> getNodeWithRelationships(String nodeId) async {
    final node = await _db.getMemoryNode(nodeId);
    if (node == null) return null;

    final outgoingEdges = await _db.getEdgesFromNode(nodeId);
    final incomingEdges = await _db.getEdgesToNode(nodeId);

    // Get connected nodes
    final connectedNodeIds = <String>{};
    for (final edge in outgoingEdges) {
      connectedNodeIds.add(edge.toNodeId);
    }
    for (final edge in incomingEdges) {
      connectedNodeIds.add(edge.fromNodeId);
    }

    final connectedNodes = <MemoryNode>[];
    for (final id in connectedNodeIds) {
      final n = await _db.getMemoryNode(id);
      if (n != null) connectedNodes.add(n);
    }

    return NodeWithRelationships(
      node: node,
      outgoingEdges: outgoingEdges,
      incomingEdges: incomingEdges,
      connectedNodes: connectedNodes,
    );
  }

  // ============================================
  // Semantic Search
  // ============================================

  /// Search nodes semantically with keyword fallback
  /// Uses hybrid approach: vector search + keyword matching
  Future<List<SemanticNodeResult>> searchNodesSemantically({
    required String query,
    int limit = 10,
    double minScore = 0.3,
  }) async {
    final results = <SemanticNodeResult>[];
    final seenIds = <String>{};

    // First, try keyword-based search (works reliably without ML model)
    final keywordResults = await _keywordSearch(query, limit);
    for (final result in keywordResults) {
      if (!seenIds.contains(result.node.id)) {
        results.add(result);
        seenIds.add(result.node.id);
      }
    }

    // Only use vector search when TFLite model is loaded (not hash-based fallback)
    // Hash-based fallback produces meaningless similarity scores
    if (_embeddingService.isModelLoaded) {
      try {
        final queryEmbedding = await _embeddingService.embed(query);
        final vectorResults = await _vectorStore.searchMemoryNodes(
          queryEmbedding: queryEmbedding,
          limit: limit,
          minScore: minScore,
        );

        for (final result in vectorResults) {
          if (!seenIds.contains(result.entityId)) {
            final node = await _db.getMemoryNode(result.entityId);
            if (node != null) {
              results.add(SemanticNodeResult(node: node, score: result.score));
              seenIds.add(result.entityId);
            }
          }
        }
      } catch (e) {
        developer.log(
          'Vector search failed, using keyword results only: $e',
          name: _logName,
          level: 800,
        );
      }
    }
    // When TFLite model is not loaded, keyword search results are used exclusively

    // Sort by score descending and limit results
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  /// Keyword-based search for nodes
  /// Searches in name and attributes for query terms
  Future<List<SemanticNodeResult>> _keywordSearch(String query, int limit) async {
    final queryLower = query.toLowerCase();
    // Also clean punctuation from query terms
    final queryTerms = queryLower
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'[^\w]'), ''))  // Remove punctuation
        .where((t) => t.length > 2)
        .toList();

    if (queryTerms.isEmpty) return [];

    // Detect if query is about plans/events/meetings
    final eventKeywords = ['plan', 'plans', 'meeting', 'appointment', 'schedule', 'doing', 'event'];
    final isEventQuery = queryTerms.any((t) => eventKeywords.contains(t));

    final allNodes = await _db.getAllMemoryNodes();
    final scoredNodes = <SemanticNodeResult>[];

    for (final node in allNodes) {
      double score = 0;

      // Check name
      final nameLower = node.name.toLowerCase();
      for (final term in queryTerms) {
        if (nameLower.contains(term)) {
          score += 0.5;
          if (nameLower == term) score += 0.3; // Exact match bonus
        }
      }

      // Check node type
      if (node.nodeType.toLowerCase().contains(queryLower)) {
        score += 0.3;
      }

      // Boost events when query is about plans
      if (isEventQuery && node.nodeType == 'event') {
        score += 0.6;
      }

      // Check attributes
      if (node.attributes != null) {
        final attrsLower = node.attributes!.toLowerCase();
        for (final term in queryTerms) {
          if (attrsLower.contains(term)) {
            score += 0.4;
            // Extra boost if person name found in event attendees
            if (node.nodeType == 'event' && attrsLower.contains('attendees')) {
              score += 0.5;
            }
          }
        }
        // Special check for exact phrase in attributes
        if (attrsLower.contains(queryLower)) {
          score += 0.5;
        }
      }

      if (score > 0) {
        // Normalize score to 0-1 range (max possible ~3.5)
        final normalizedScore = (score / 3.5).clamp(0.0, 1.0);
        scoredNodes.add(SemanticNodeResult(node: node, score: normalizedScore));
      }
    }

    // Sort by score and return top results
    scoredNodes.sort((a, b) => b.score.compareTo(a.score));
    return scoredNodes.take(limit).toList();
  }

  /// Build context from relevant memories for LLM
  Future<String> buildMemoryContext({
    required String query,
    int maxNodes = 5,
    double minScore = 0.3,
  }) async {
    // Debug: Check total nodes in database
    final allNodes = await _db.getAllMemoryNodes();
    developer.log(
      'buildMemoryContext: Total nodes in DB: ${allNodes.length}, query: "$query"',
      name: _logName,
    );

    final results = await searchNodesSemantically(
      query: query,
      limit: maxNodes,
      minScore: minScore,
    );

    developer.log(
      'buildMemoryContext: Found ${results.length} results for query "$query"',
      name: _logName,
    );

    if (results.isEmpty) return '';

    final contextParts = <String>[];
    for (final result in results) {
      final nodeInfo = <String>[];
      nodeInfo.add('${result.node.nodeType}: ${result.node.name}');

      // Parse attributes
      if (result.node.attributes != null) {
        try {
          final attrs =
              jsonDecode(result.node.attributes!) as Map<String, dynamic>;
          attrs.forEach((key, value) {
            if (value != null && value.toString().isNotEmpty) {
              nodeInfo.add('  - $key: $value');
            }
          });
        } catch (_) {}
      }

      // Get relationships
      final edges = await _db.getEdgesFromNode(result.node.id);
      for (final edge in edges.take(3)) {
        final targetNode = await _db.getMemoryNode(edge.toNodeId);
        if (targetNode != null) {
          nodeInfo.add('  - ${edge.relationshipType} → ${targetNode.name}');
        }
      }

      contextParts.add(nodeInfo.join('\n'));
    }

    return contextParts.join('\n\n');
  }

  // ============================================
  // Stats
  // ============================================

  /// Get memory statistics
  Future<MemoryStats> getStats() async {
    final dbStats = await _db.getMemoryStats();
    return MemoryStats(
      nodeCount: dbStats['nodes'] ?? 0,
      edgeCount: dbStats['edges'] ?? 0,
      vectorCount: _vectorStore.memoryVectorCount,
    );
  }

  // ============================================
  // Export (for nightly sync)
  // ============================================

  /// Export all memory data as JSON for nightly sync
  Future<Map<String, dynamic>> exportForSync() async {
    final nodes = await getAllNodes();
    final edges = await getAllEdges();

    return {
      'nodes': nodes
          .map(
            (n) => {
              'id': n.id,
              'node_type': n.nodeType,
              'name': n.name,
              'source': n.source,
              'source_id': n.sourceId,
              'attributes': n.attributes,
              'confidence': n.confidence,
              'created_at': n.createdAt.toIso8601String(),
              'updated_at': n.updatedAt.toIso8601String(),
              'last_referenced': n.lastReferenced?.toIso8601String(),
            },
          )
          .toList(),
      'edges': edges
          .map(
            (e) => {
              'id': e.id,
              'from_node_id': e.fromNodeId,
              'to_node_id': e.toNodeId,
              'relationship_type': e.relationshipType,
              'attributes': e.attributes,
              'confidence': e.confidence,
              'reference_count': e.referenceCount,
              'created_at': e.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Node with all its relationships
class NodeWithRelationships {
  final MemoryNode node;
  final List<MemoryEdge> outgoingEdges;
  final List<MemoryEdge> incomingEdges;
  final List<MemoryNode> connectedNodes;

  NodeWithRelationships({
    required this.node,
    required this.outgoingEdges,
    required this.incomingEdges,
    required this.connectedNodes,
  });
}

/// Result from semantic node search
class SemanticNodeResult {
  final MemoryNode node;
  final double score;

  SemanticNodeResult({required this.node, required this.score});
}

/// Memory statistics
class MemoryStats {
  final int nodeCount;
  final int edgeCount;
  final int vectorCount;

  MemoryStats({
    required this.nodeCount,
    required this.edgeCount,
    required this.vectorCount,
  });
}
