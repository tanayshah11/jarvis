import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:jarvis/core/network/api_client.dart';
import 'package:jarvis/data/database/database.dart';
import 'package:jarvis/data/repositories/memory_repository.dart';
import 'package:jarvis/data/vector/vector_store.dart';
import 'package:jarvis/data/embeddings/local_embedding_service.dart';
import 'package:jarvis/features/network_sync/models/candidate_pair.dart';
import 'package:jarvis/features/network_sync/models/sync_config.dart';
import 'package:jarvis/features/network_sync/models/sync_result.dart';
import 'package:jarvis/features/network_sync/services/sync_anonymizer.dart';
import 'package:jarvis/features/network_sync/services/candidate_scorer.dart';

const String _logName = 'DeepNetworkSync';

/// Main orchestrator for the Deep Network Sync system.
///
/// Discovers new relationships in the memory graph by:
/// 1. Finding semantically similar nodes (vector similarity)
/// 2. Analyzing entity co-occurrences
/// 3. Detecting temporal patterns
/// 4. Using LLM to infer relationships (privacy-preserving with anonymization)
class DeepNetworkSyncService {
  final AppDatabase _database;
  final MemoryRepository _memoryRepo;
  final VectorStore _vectorStore;
  final LocalEmbeddingService _embeddingService;
  final ApiClient _apiClient;
  final CandidateScorer _scorer;

  final Uuid _uuid = const Uuid();

  DeepNetworkSyncService({
    required AppDatabase database,
    required MemoryRepository memoryRepo,
    required VectorStore vectorStore,
    required LocalEmbeddingService embeddingService,
    required ApiClient apiClient,
  })  : _database = database,
        _memoryRepo = memoryRepo,
        _vectorStore = vectorStore,
        _embeddingService = embeddingService,
        _apiClient = apiClient,
        _scorer = CandidateScorer(database);

  /// Run a full sync cycle
  Future<SyncResult> runSync() async {
    final stopwatch = Stopwatch()..start();
    final warnings = <String>[];
    var llmCallsUsed = 0;
    final newEdges = <MemoryEdge>[];

    try {
      developer.log('Starting deep network sync...', name: _logName);

      // 1. Check if we have enough data to sync
      final stats = await _memoryRepo.getStats();
      if (stats.nodeCount < 3) {
        developer.log('Not enough nodes for sync (${stats.nodeCount})', name: _logName);
        return SyncResult.skipped('Insufficient data: only ${stats.nodeCount} nodes');
      }

      // 2. Gather candidates from all discovery sources
      final candidates = <CandidatePair>[];

      // Semantic similarity candidates
      final semanticCandidates = await _findSemanticCandidates();
      candidates.addAll(semanticCandidates);
      developer.log(
        'Found ${semanticCandidates.length} semantic candidates',
        name: _logName,
      );

      // Co-occurrence candidates
      final cooccurrenceCandidates = await _findCooccurrenceCandidates();
      candidates.addAll(cooccurrenceCandidates);
      developer.log(
        'Found ${cooccurrenceCandidates.length} co-occurrence candidates',
        name: _logName,
      );

      // 3. Detect temporal patterns (stored separately)
      final temporalPatterns = await _detectTemporalPatterns();
      developer.log(
        'Detected ${temporalPatterns.length} temporal patterns',
        name: _logName,
      );

      // 4. Deduplicate and merge multi-signal candidates
      final mergedCandidates = _mergeCandidates(candidates);
      developer.log(
        'Merged to ${mergedCandidates.length} unique candidates',
        name: _logName,
      );

      // 5. Score and decide on each candidate
      final scoredCandidates = await _scorer.scoreAndDecide(
        mergedCandidates,
        llmBudget: SyncConfig.maxLLMCallsPerCycle,
      );

      // 6. Process candidates by decision
      final autoConfirmCandidates = <CandidatePair>[];
      final llmInferCandidates = <CandidatePair>[];

      for (final (candidate, _, decision) in scoredCandidates) {
        switch (decision) {
          case CandidateDecision.autoConfirm:
            autoConfirmCandidates.add(candidate);
            break;
          case CandidateDecision.llmInfer:
            llmInferCandidates.add(candidate);
            break;
          case CandidateDecision.skip:
            // Skip this candidate
            break;
        }
      }

      developer.log(
        'Auto-confirm: ${autoConfirmCandidates.length}, LLM infer: ${llmInferCandidates.length}',
        name: _logName,
      );

      // 7. Auto-confirm high-confidence candidates
      for (final candidate in autoConfirmCandidates) {
        final edge = await _createEdgeFromCandidate(
          candidate,
          SyncConfig.autoConfirmEdgeConfidence,
          SyncConfig.autoDiscoveredSource,
        );
        if (edge != null) newEdges.add(edge);
      }

      // 8. Use LLM for medium-confidence candidates
      if (llmInferCandidates.isNotEmpty) {
        final llmResults = await _inferRelationshipsWithLLM(llmInferCandidates);
        llmCallsUsed = 1; // We batch all candidates into one LLM call

        for (final inferredEdge in llmResults) {
          newEdges.add(inferredEdge);
        }
      }

      // 9. Save temporal patterns
      for (final pattern in temporalPatterns) {
        await _saveTemporalPattern(pattern);
      }

      stopwatch.stop();

      final result = SyncResult(
        newEdgesCount: newEdges.length,
        newPatternsCount: temporalPatterns.length,
        candidatesEvaluated: mergedCandidates.length,
        llmCallsUsed: llmCallsUsed,
        duration: stopwatch.elapsed,
        warnings: warnings,
        newEdges: newEdges,
      );

      developer.log('Sync completed: $result', name: _logName);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Sync failed: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return SyncResult.failed(e.toString(), duration: stopwatch.elapsed);
    }
  }

  /// Find semantically similar node pairs using vector search
  Future<List<CandidatePair>> _findSemanticCandidates() async {
    final candidates = <CandidatePair>[];
    final seenPairs = <String>{};

    // Only use semantic search if embedding model is loaded
    if (!_embeddingService.isModelLoaded) {
      developer.log(
        'Skipping semantic discovery: embedding model not loaded',
        name: _logName,
      );
      return candidates;
    }

    final allNodes = await _memoryRepo.getAllNodes();

    for (final node in allNodes) {
      if (node.vectorId == null) continue;

      try {
        // Build embedding for this node's text
        final searchText = '${node.name} ${node.nodeType}';
        final queryEmbedding = await _embeddingService.embed(searchText);

        // Search for similar nodes
        final results = await _vectorStore.searchMemoryNodes(
          queryEmbedding: queryEmbedding,
          limit: SyncConfig.maxSemanticCandidatesPerNode + 1, // +1 to skip self
          minScore: SyncConfig.semanticSimilarityThreshold,
        );

        for (final result in results) {
          // Skip self
          if (result.entityId == node.id) continue;

          // Check if edge already exists
          final existingEdges = await _database.getEdgesFromNode(node.id);
          final edgeExists = existingEdges.any(
            (e) => e.toNodeId == result.entityId,
          );
          if (edgeExists) continue;

          // Check reverse edge
          final reverseEdges = await _database.getEdgesToNode(node.id);
          final reverseExists = reverseEdges.any(
            (e) => e.fromNodeId == result.entityId,
          );
          if (reverseExists) continue;

          // Avoid duplicate pairs
          final pairKey = _makePairKey(node.id, result.entityId);
          if (seenPairs.contains(pairKey)) continue;
          seenPairs.add(pairKey);

          // Get the other node
          final otherNode = await _memoryRepo.getNode(result.entityId);
          if (otherNode == null) continue;

          candidates.add(CandidatePair(
            nodeA: node,
            nodeB: otherNode,
            source: DiscoverySource.semantic,
            similarity: result.score,
          ));
        }
      } catch (e) {
        // Log and continue with other nodes
        developer.log(
          'Error processing node ${node.id}: $e',
          name: _logName,
          level: 800,
        );
      }

      // Limit total candidates
      if (candidates.length >= SyncConfig.maxSemanticCandidatesTotal) break;
    }

    return candidates;
  }

  /// Find candidate pairs based on entity co-occurrence
  Future<List<CandidatePair>> _findCooccurrenceCandidates() async {
    final candidates = <CandidatePair>[];

    // Get high co-occurrence pairs
    final cooccurrences = await _database.getHighCooccurrences(
      minCount: SyncConfig.minCooccurrenceCount,
      limit: SyncConfig.maxCooccurrenceCandidates,
    );

    for (final cooc in cooccurrences) {
      // Check if edge already exists
      final existingEdges = await _database.getEdgesFromNode(cooc.entityA);
      final edgeExists = existingEdges.any((e) => e.toNodeId == cooc.entityB);
      if (edgeExists) continue;

      // Check reverse edge
      final reverseEdges = await _database.getEdgesToNode(cooc.entityA);
      final reverseExists = reverseEdges.any((e) => e.fromNodeId == cooc.entityB);
      if (reverseExists) continue;

      // Get the nodes
      final nodeA = await _memoryRepo.getNode(cooc.entityA);
      final nodeB = await _memoryRepo.getNode(cooc.entityB);
      if (nodeA == null || nodeB == null) continue;

      candidates.add(CandidatePair(
        nodeA: nodeA,
        nodeB: nodeB,
        source: DiscoverySource.cooccurrence,
        cooccurrenceCount: cooc.cooccurrenceCount,
      ));
    }

    return candidates;
  }

  /// Detect weekly temporal patterns
  Future<List<_DetectedPattern>> _detectTemporalPatterns() async {
    final patterns = <_DetectedPattern>[];

    // Group node references by day of week
    final allNodes = await _memoryRepo.getAllNodes();
    final nodesByWeekday = <String, List<int>>{}; // nodeId -> list of weekdays

    for (final node in allNodes) {
      if (node.lastReferenced != null) {
        final weekday = node.lastReferenced!.weekday;
        nodesByWeekday.putIfAbsent(node.id, () => []).add(weekday);
      }
      // Also check createdAt
      final createWeekday = node.createdAt.weekday;
      nodesByWeekday.putIfAbsent(node.id, () => []).add(createWeekday);
    }

    // Analyze each node for patterns
    for (final entry in nodesByWeekday.entries) {
      final nodeId = entry.key;
      final weekdays = entry.value;

      if (weekdays.length < SyncConfig.minPatternOccurrences) continue;

      // Count occurrences by day
      final dayCounts = List.filled(7, 0);
      for (final day in weekdays) {
        dayCounts[day - 1]++; // weekday is 1-7, convert to 0-6
      }

      // Chi-squared test for non-uniform distribution
      final expected = weekdays.length / 7;
      var chiSquared = 0.0;
      for (final count in dayCounts) {
        chiSquared += pow(count - expected, 2) / expected;
      }

      if (chiSquared > SyncConfig.chiSquaredThreshold) {
        // Find peak day
        final peakDay = dayCounts.indexOf(dayCounts.reduce(max));
        final confidence = 1 - _chiSquaredPValue(chiSquared, 6);

        patterns.add(_DetectedPattern(
          entityId: nodeId,
          patternType: 'weekly',
          patternData: {
            'dayOfWeek': peakDay,
            'dayName': _dayNames[peakDay],
            'chiSquared': chiSquared,
          },
          confidence: confidence,
          occurrenceCount: weekdays.length,
        ));
      }
    }

    return patterns;
  }

  /// Merge candidates from different sources, combining signals
  List<CandidatePair> _mergeCandidates(List<CandidatePair> candidates) {
    final merged = <String, CandidatePair>{};

    for (final candidate in candidates) {
      final key = candidate.key;

      if (merged.containsKey(key)) {
        // Merge with existing
        final existing = merged[key]!;
        merged[key] = existing.copyWithMergedData(
          similarity: candidate.similarity ?? existing.similarity,
          cooccurrenceCount:
              candidate.cooccurrenceCount ?? existing.cooccurrenceCount,
          temporalConfidence:
              candidate.temporalConfidence ?? existing.temporalConfidence,
        );
      } else {
        merged[key] = candidate;
      }
    }

    return merged.values.toList();
  }

  /// Create an edge from a candidate pair
  Future<MemoryEdge?> _createEdgeFromCandidate(
    CandidatePair candidate,
    double confidence,
    String evidenceSource,
  ) async {
    try {
      // Infer relationship type from node types
      final relType = _inferRelationshipType(
        candidate.nodeA.nodeType,
        candidate.nodeB.nodeType,
      );

      final edgeId = await _memoryRepo.createEdge(
        fromNodeId: candidate.nodeA.id,
        toNodeId: candidate.nodeB.id,
        relationshipType: relType,
        confidence: confidence,
        attributes: {
          'evidence_source': evidenceSource,
          'discovery_source': candidate.source.name,
          if (candidate.similarity != null) 'similarity': candidate.similarity,
          if (candidate.cooccurrenceCount != null)
            'cooccurrence_count': candidate.cooccurrenceCount,
        },
      );

      developer.log(
        'Created edge: ${candidate.nodeA.name} -[$relType]-> ${candidate.nodeB.name}',
        name: _logName,
      );

      // Return the edge data
      final allEdges = await _database.getAllMemoryEdges();
      return allEdges.firstWhere((e) => e.id == edgeId);
    } catch (e) {
      developer.log('Failed to create edge: $e', name: _logName, level: 800);
      return null;
    }
  }

  /// Use LLM to infer relationships for medium-confidence candidates
  Future<List<MemoryEdge>> _inferRelationshipsWithLLM(
    List<CandidatePair> candidates,
  ) async {
    final results = <MemoryEdge>[];
    final anonymizer = SyncAnonymizer();

    try {
      // Build anonymized request
      final allNodes = <MemoryNode>{};
      for (final c in candidates) {
        allNodes.add(c.nodeA);
        allNodes.add(c.nodeB);
      }

      final anonymizedNodes = allNodes.map((n) {
        final placeholder = anonymizer.anonymize(n.id, n.nodeType);
        return {
          'placeholder': placeholder,
          'node_type': n.nodeType,
        };
      }).toList();

      // Get existing edges between involved nodes
      final existingEdges = <Map<String, dynamic>>[];
      for (final node in allNodes) {
        final edges = await _database.getEdgesFromNode(node.id);
        for (final edge in edges) {
          if (allNodes.any((n) => n.id == edge.toNodeId)) {
            existingEdges.add({
              'from_placeholder': anonymizer.anonymize(edge.fromNodeId, 'default'),
              'to_placeholder': anonymizer.anonymize(edge.toNodeId, 'default'),
              'relationship_type': edge.relationshipType,
              'confidence': edge.confidence,
            });
          }
        }
      }

      final candidatePairs = candidates.map((c) {
        return {
          'placeholder_a': anonymizer.anonymize(c.nodeA.id, c.nodeA.nodeType),
          'placeholder_b': anonymizer.anonymize(c.nodeB.id, c.nodeB.nodeType),
          'discovery_source': c.source.name,
          'similarity_score': c.similarity,
          'cooccurrence_count': c.cooccurrenceCount,
        };
      }).toList();

      // Call backend API
      final response = await _apiClient.post(
        '/sync/infer-relationships',
        data: {
          'nodes': anonymizedNodes,
          'existing_edges': existingEdges,
          'candidate_pairs': candidatePairs,
          'max_inferences': SyncConfig.maxLLMCallsPerCycle,
          'provider': 'groq',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final inferredEdges = data['inferred_edges'] as List<dynamic>;

        for (final inferred in inferredEdges) {
          final confidence = (inferred['confidence'] as num).toDouble();
          if (confidence < SyncConfig.minLLMEdgeConfidence) continue;

          final fromId = anonymizer.deanonymize(inferred['from_placeholder']);
          final toId = anonymizer.deanonymize(inferred['to_placeholder']);

          if (fromId == null || toId == null) continue;

          // Create the edge
          final edgeId = await _memoryRepo.createEdge(
            fromNodeId: fromId,
            toNodeId: toId,
            relationshipType: inferred['relationship_type'] as String,
            confidence: confidence,
            attributes: {
              'evidence_source': SyncConfig.llmDiscoveredSource,
              'llm_reasoning': inferred['reasoning'],
            },
          );

          final allEdges = await _database.getAllMemoryEdges();
          final edge = allEdges.firstWhere((e) => e.id == edgeId);
          results.add(edge);

          developer.log(
            'LLM inferred: ${inferred['from_placeholder']} -[${inferred['relationship_type']}]-> ${inferred['to_placeholder']}',
            name: _logName,
          );
        }
      }
    } catch (e) {
      developer.log('LLM inference failed: $e', name: _logName, level: 900);
    }

    return results;
  }

  /// Save a detected temporal pattern
  Future<void> _saveTemporalPattern(_DetectedPattern pattern) async {
    final now = DateTime.now();
    final patternId = _uuid.v4();

    await _database.upsertTemporalPattern(TemporalPatternsCompanion(
      id: Value(patternId),
      entityId: Value(pattern.entityId),
      patternType: Value(pattern.patternType),
      patternData: Value(jsonEncode(pattern.patternData)),
      confidence: Value(pattern.confidence),
      occurrenceCount: Value(pattern.occurrenceCount),
      discoveredAt: Value(now),
      lastObserved: Value(now),
    ));
  }

  /// Infer relationship type from node types
  String _inferRelationshipType(String typeA, String typeB) {
    final types = {typeA.toLowerCase(), typeB.toLowerCase()};

    if (types.contains('person') && types.contains('organization')) {
      return 'works_at';
    }
    if (types.contains('person') && types.contains('place')) {
      return 'frequents';
    }
    if (types.contains('person') && types.contains('location')) {
      return 'lives_in';
    }
    if (types.contains('person') && types.contains('event')) {
      return 'attended';
    }
    if (types.contains('person') && types.contains('topic')) {
      return 'interested_in';
    }
    if (types.containsAll({'person'})) {
      return 'knows';
    }
    if (types.containsAll({'place'}) || types.containsAll({'location'})) {
      return 'near';
    }

    return 'related_to';
  }

  /// Create a consistent pair key for deduplication
  String _makePairKey(String idA, String idB) {
    final ids = [idA, idB]..sort();
    return '${ids[0]}:${ids[1]}';
  }

  /// Approximate chi-squared p-value (simplified)
  double _chiSquaredPValue(double chiSquared, int degreesOfFreedom) {
    // Simplified approximation - for more accuracy use a statistics library
    // This is a rough estimate for p < 0.05 detection
    if (degreesOfFreedom == 6) {
      if (chiSquared > 22.46) return 0.001;
      if (chiSquared > 16.81) return 0.01;
      if (chiSquared > 12.59) return 0.05;
      if (chiSquared > 10.64) return 0.10;
    }
    return 0.5; // No significant pattern
  }

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}

/// Internal class for detected temporal patterns
class _DetectedPattern {
  final String entityId;
  final String patternType;
  final Map<String, dynamic> patternData;
  final double confidence;
  final int occurrenceCount;

  _DetectedPattern({
    required this.entityId,
    required this.patternType,
    required this.patternData,
    required this.confidence,
    required this.occurrenceCount,
  });
}
