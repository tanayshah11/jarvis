import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/data_service.dart';
import '../../../data/repositories/memory_repository.dart';
import '../models/memory_node.dart';
import '../../../data/database/database.dart' as db;

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final memoryRepository = ref.watch(memoryRepositoryProvider);
  return MemoryService(memoryRepository: memoryRepository);
});

class MemoryService {
  final MemoryRepository memoryRepository;

  MemoryService({required this.memoryRepository});

  /// Search for memory nodes using semantic search
  Future<List<MemoryNode>> searchMemories(String query) async {
    try {
      final results = await memoryRepository.searchNodesSemantically(
        query: query,
        limit: 50,
        minScore: 0.3,
      );

      return results.map((result) => _convertDbNodeToApiNode(result.node, result.score)).toList();
    } catch (e) {
      throw Exception('Failed to search memories: $e');
    }
  }

  /// Fetch memory nodes with optional filters
  Future<List<MemoryNode>> fetchNodes({
    String? nodeType,
    int limit = 50,
  }) async {
    try {
      List<db.MemoryNode> dbNodes = await memoryRepository.getAllNodes();

      // Filter by node type if specified
      if (nodeType != null && nodeType.isNotEmpty) {
        dbNodes = dbNodes.where((node) => node.nodeType == nodeType).toList();
      }

      // Apply limit
      if (dbNodes.length > limit) {
        dbNodes = dbNodes.take(limit).toList();
      }

      return dbNodes.map((node) => _convertDbNodeToApiNode(node, null)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nodes: $e');
    }
  }

  /// Get a single memory node by ID
  Future<MemoryNode> getNode(String nodeId) async {
    try {
      final dbNode = await memoryRepository.getNode(nodeId);

      if (dbNode != null) {
        return _convertDbNodeToApiNode(dbNode, null);
      }
      throw Exception('Node not found');
    } catch (e) {
      throw Exception('Failed to get node: $e');
    }
  }

  /// Update a memory node
  Future<MemoryNode> updateNode(
    String nodeId, {
    String? label,
    Map<String, dynamic>? attributes,
    double? confidence,
  }) async {
    try {
      await memoryRepository.updateNode(
        nodeId,
        name: label,
        attributes: attributes,
        confidence: confidence,
      );

      final updatedNode = await memoryRepository.getNode(nodeId);
      if (updatedNode != null) {
        return _convertDbNodeToApiNode(updatedNode, null);
      }
      throw Exception('Failed to update node');
    } catch (e) {
      throw Exception('Failed to update node: $e');
    }
  }

  /// Delete a memory node and all its associated data
  Future<void> deleteNode(String nodeId) async {
    try {
      final success = await memoryRepository.deleteNode(nodeId);
      if (!success) {
        throw Exception('Node not found or could not be deleted');
      }
    } catch (e) {
      throw Exception('Failed to delete node: $e');
    }
  }

  /// Get memory stats
  Future<MemoryStats> getStats() async {
    try {
      final dbStats = await memoryRepository.getStats();

      // Convert repository stats to API stats format
      // Note: nodesByType is not tracked in the repository, so we'll calculate it
      final nodes = await memoryRepository.getAllNodes();
      final nodesByType = <String, int>{};
      for (final node in nodes) {
        nodesByType[node.nodeType] = (nodesByType[node.nodeType] ?? 0) + 1;
      }

      return MemoryStats(
        totalNodes: dbStats.nodeCount,
        totalEdges: dbStats.edgeCount,
        nodesByType: nodesByType,
      );
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// Convert database MemoryNode to API MemoryNode model
  MemoryNode _convertDbNodeToApiNode(db.MemoryNode dbNode, double? similarity) {
    // Parse attributes from JSON string
    Map<String, dynamic> attributes = {};
    if (dbNode.attributes != null && dbNode.attributes!.isNotEmpty) {
      try {
        attributes = jsonDecode(dbNode.attributes!) as Map<String, dynamic>;
      } catch (e) {
        // If parsing fails, keep empty map
        attributes = {};
      }
    }

    // Calculate reference count based on lastReferenced
    // For now, use a simple heuristic: 1 if referenced, 0 if not
    int referenceCount = dbNode.lastReferenced != null ? 1 : 0;

    return MemoryNode(
      id: dbNode.id,
      type: dbNode.nodeType,
      label: dbNode.name,
      attributes: attributes,
      confidence: dbNode.confidence,
      referenceCount: referenceCount,
      similarity: similarity,
    );
  }
}

/// Memory statistics model
class MemoryStats {
  final int totalNodes;
  final int totalEdges;
  final Map<String, int> nodesByType;

  const MemoryStats({
    this.totalNodes = 0,
    this.totalEdges = 0,
    this.nodesByType = const {},
  });

  factory MemoryStats.fromJson(Map<String, dynamic> json) {
    return MemoryStats(
      totalNodes: json['total_nodes'] ?? 0,
      totalEdges: json['total_edges'] ?? 0,
      nodesByType: Map<String, int>.from(json['nodes_by_type'] ?? {}),
    );
  }
}

/// Stats provider
final memoryStatsProvider = FutureProvider<MemoryStats>((ref) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getStats();
});
