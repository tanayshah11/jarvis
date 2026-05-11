import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/memory_repository.dart';
import '../data_service.dart';
import 'memory_seed_data.dart';

/// Provider for the memory seeder
final memorySeedProvider = Provider<MemorySeeder>((ref) {
  final memoryRepository = ref.watch(memoryRepositoryProvider);
  return MemorySeeder(memoryRepository: memoryRepository);
});

/// Seeds the memory database with synthetic test data
class MemorySeeder {
  final MemoryRepository memoryRepository;

  MemorySeeder({required this.memoryRepository});

  /// Seed all memory data
  /// Returns a summary of what was seeded
  Future<SeedResult> seedAll() async {
    final result = SeedResult();
    final nodeIdMap = <String, String>{}; // name -> id mapping for edges

    final allNodes = MemorySeedData.getAllNodes();
    debugPrint('MemorySeeder: Found ${allNodes.length} nodes to seed');

    // Seed all node types (upsert to handle existing data)
    for (final nodeData in allNodes) {
      try {
        final id = await memoryRepository.upsertNode(
          nodeType: nodeData['nodeType'] as String,
          name: nodeData['name'] as String,
          source: 'seed_data',
          sourceId: '${nodeData['nodeType']}_${nodeData['name']}'
              .replaceAll(' ', '_')
              .toLowerCase(),
          attributes: nodeData['attributes'] as Map<String, dynamic>?,
          confidence: 0.95, // High confidence for seed data
        );
        nodeIdMap[nodeData['name'] as String] = id;
        result.nodesCreated++;
      } catch (e) {
        debugPrint('MemorySeeder: Failed to create node ${nodeData['name']}: $e');
        result.errors.add('Failed to create node ${nodeData['name']}: $e');
      }
    }

    // Create the "user" node (the person whose memory this is)
    try {
      final userId = await memoryRepository.upsertNode(
        nodeType: 'self',
        name: 'Me',
        source: 'seed_data',
        sourceId: 'user_self',
        attributes: {'name': 'User', 'role': 'The person whose memory this is'},
        confidence: 1.0,
      );
      nodeIdMap['Me'] = userId;
      result.nodesCreated++;

      // Create edges from user to key entities
      await _createUserEdges(userId, nodeIdMap, result);
    } catch (e) {
      result.errors.add('Failed to create user node: $e');
    }

    // Seed relationships (upsert to handle existing)
    for (final rel in MemorySeedData.relationships) {
      try {
        final fromId = nodeIdMap[rel['from'] as String];
        final toId = nodeIdMap[rel['to'] as String];

        if (fromId != null && toId != null) {
          await memoryRepository.upsertEdge(
            fromNodeId: fromId,
            toNodeId: toId,
            relationshipType: rel['type'] as String,
            confidence: 0.9,
          );
          result.edgesCreated++;
        } else {
          result.errors.add(
            'Could not find nodes for edge: ${rel['from']} -> ${rel['to']}',
          );
        }
      } catch (e) {
        result.errors.add('Failed to create edge: $e');
      }
    }

    return result;
  }

  /// Create edges from the user node to various entities
  Future<void> _createUserEdges(
    String userId,
    Map<String, String> nodeIdMap,
    SeedResult result,
  ) async {
    // User knows all people
    for (final person in MemorySeedData.people) {
      final personId = nodeIdMap[person['name'] as String];
      if (personId != null) {
        final attrs = person['attributes'] as Map<String, dynamic>?;
        final relationship = attrs?['relationship'] as String? ?? 'knows';

        String edgeType;
        if (relationship.contains('friend') || relationship == 'best friend') {
          edgeType = 'friend_of';
        } else if (relationship.contains('family') ||
            relationship == 'mother' ||
            relationship == 'father' ||
            relationship.contains('sibling')) {
          edgeType = 'family_of';
        } else if (relationship.contains('colleague') ||
            relationship == 'manager') {
          edgeType = 'works_with';
        } else {
          edgeType = 'knows';
        }

        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: personId,
          relationshipType: edgeType,
          attributes: {'since': attrs?['how_met'] ?? 'unknown'},
          confidence: 0.95,
        );
        result.edgesCreated++;
      }
    }

    // User has visited places
    for (final place in MemorySeedData.places) {
      final placeId = nodeIdMap[place['name'] as String];
      if (placeId != null) {
        final attrs = place['attributes'] as Map<String, dynamic>?;
        final rating = attrs?['rating'];

        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: placeId,
          relationshipType: rating != null && rating >= 4 ? 'loves' : 'visited',
          confidence: 0.9,
        );
        result.edgesCreated++;
      }
    }

    // User attended events
    for (final event in MemorySeedData.events) {
      final eventId = nodeIdMap[event['name'] as String];
      if (eventId != null) {
        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: eventId,
          relationshipType: 'attended',
          confidence: 0.95,
        );
        result.edgesCreated++;
      }
    }

    // User likes music
    for (final music in MemorySeedData.music) {
      final musicId = nodeIdMap[music['name'] as String];
      if (musicId != null) {
        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: musicId,
          relationshipType: 'likes',
          confidence: 0.9,
        );
        result.edgesCreated++;
      }
    }

    // User has preferences
    for (final pref in MemorySeedData.preferences) {
      final prefId = nodeIdMap[pref['name'] as String];
      if (prefId != null) {
        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: prefId,
          relationshipType: 'has_preference',
          confidence: 0.95,
        );
        result.edgesCreated++;
      }
    }

    // User has hobbies
    for (final hobby in MemorySeedData.hobbies) {
      final hobbyId = nodeIdMap[hobby['name'] as String];
      if (hobbyId != null) {
        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: hobbyId,
          relationshipType: 'practices',
          confidence: 0.9,
        );
        result.edgesCreated++;
      }
    }

    // User works at companies
    for (final work in MemorySeedData.work) {
      final workId = nodeIdMap[work['name'] as String];
      if (workId != null) {
        final nodeType = work['nodeType'] as String;
        if (nodeType == 'company') {
          final attrs = work['attributes'] as Map<String, dynamic>?;
          final endDate = attrs?['end_date'];
          await memoryRepository.upsertEdge(
            fromNodeId: userId,
            toNodeId: workId,
            relationshipType: endDate != null ? 'worked_at' : 'works_at',
            confidence: 0.95,
          );
          result.edgesCreated++;
        } else if (nodeType == 'skill') {
          await memoryRepository.upsertEdge(
            fromNodeId: userId,
            toNodeId: workId,
            relationshipType: 'skilled_at',
            confidence: 0.9,
          );
          result.edgesCreated++;
        }
      }
    }

    // User interested in topics
    for (final topic in MemorySeedData.topics) {
      final topicId = nodeIdMap[topic['name'] as String];
      if (topicId != null) {
        await memoryRepository.upsertEdge(
          fromNodeId: userId,
          toNodeId: topicId,
          relationshipType: 'interested_in',
          confidence: 0.85,
        );
        result.edgesCreated++;
      }
    }
  }

  /// Clear all memory data (for testing)
  Future<void> clearAll() async {
    try {
      final nodes = await memoryRepository.getAllNodes();
      debugPrint('MemorySeeder: Clearing ${nodes.length} nodes');

      int deletedCount = 0;
      for (final node in nodes) {
        final success = await memoryRepository.deleteNode(node.id);
        if (success) {
          deletedCount++;
        }
      }

      debugPrint('MemorySeeder: Successfully deleted $deletedCount nodes');
    } catch (e) {
      debugPrint('MemorySeeder: Failed to clear all nodes: $e');
      rethrow;
    }
  }
}

/// Result of seeding operation
class SeedResult {
  int nodesCreated = 0;
  int edgesCreated = 0;
  List<String> errors = [];

  @override
  String toString() {
    return 'SeedResult: $nodesCreated nodes, $edgesCreated edges, ${errors.length} errors';
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes_created': nodesCreated,
      'edges_created': edgesCreated,
      'errors': errors,
    };
  }
}
