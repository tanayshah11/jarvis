import 'dart:math';

import 'package:jarvis/data/database/database.dart';
import 'package:jarvis/features/network_sync/models/candidate_pair.dart';
import 'package:jarvis/features/network_sync/models/sync_config.dart';

/// Scores candidate pairs to determine LLM usage priority.
///
/// Factors considered:
/// - Discovery source signal strength
/// - Graph connectivity (bridges disconnected components)
/// - Multi-signal confirmation
class CandidateScorer {
  final AppDatabase _database;

  CandidateScorer(this._database);

  /// Score a candidate pair
  Future<double> score(CandidatePair candidate) async {
    double score = 0.0;

    // 1. Base score from discovery source
    switch (candidate.source) {
      case DiscoverySource.semantic:
        score = candidate.similarity ?? 0.0;
        break;
      case DiscoverySource.cooccurrence:
        // Normalize: 3 co-occurrences = 0.3, 10+ = 0.9
        final count = candidate.cooccurrenceCount ?? 0;
        score = min(count / 10, 0.9);
        break;
      case DiscoverySource.temporal:
        score = (candidate.temporalConfidence ?? 0.0) * 0.85;
        break;
      case DiscoverySource.multiSignal:
        // Average available signals
        var total = 0.0;
        var signalCount = 0;
        if (candidate.similarity != null && candidate.similarity! > 0) {
          total += candidate.similarity!;
          signalCount++;
        }
        if (candidate.cooccurrenceCount != null && candidate.cooccurrenceCount! > 0) {
          total += min(candidate.cooccurrenceCount! / 10, 0.9);
          signalCount++;
        }
        if (candidate.temporalConfidence != null && candidate.temporalConfidence! > 0) {
          total += candidate.temporalConfidence! * 0.85;
          signalCount++;
        }
        score = signalCount > 0 ? total / signalCount : 0.0;
        break;
    }

    // 2. Bridge boost (connects disconnected components)
    final pathLength = await _findShortestPath(
      candidate.nodeA.id,
      candidate.nodeB.id,
    );
    if (pathLength == null) {
      // No existing path - this is a bridge candidate
      score += SyncConfig.bridgeCandidateBoost;
    } else if (pathLength > SyncConfig.maxPathLengthForConnection) {
      // Very distant nodes - partial bridge boost
      score += SyncConfig.bridgeCandidateBoost * 0.5;
    }

    // 3. Multi-signal boost
    final signalCount = _countSignals(candidate);
    if (signalCount > 1) {
      score += SyncConfig.multiSignalBoost * (signalCount - 1);
    }

    // Clamp to valid range
    return min(score, 1.0);
  }

  /// Find shortest path between two nodes (null if no path)
  Future<int?> _findShortestPath(String fromId, String toId) async {
    final path = await _database.findPath(
      fromId,
      toId,
      SyncConfig.maxPathLengthForConnection + 1,
    );
    if (path.isEmpty) return null;
    return path.length - 1; // Path length is number of edges
  }

  /// Count how many discovery signals a candidate has
  int _countSignals(CandidatePair candidate) {
    var count = 0;
    if (candidate.similarity != null && candidate.similarity! > 0.5) count++;
    if (candidate.cooccurrenceCount != null && candidate.cooccurrenceCount! > 0) count++;
    if (candidate.temporalConfidence != null && candidate.temporalConfidence! > 0) count++;
    return count;
  }

  /// Decide how to handle a candidate based on score and budget
  CandidateDecision decide(double score, int remainingBudget) {
    if (score >= SyncConfig.autoConfirmThreshold) {
      return CandidateDecision.autoConfirm;
    }
    if (score < SyncConfig.llmInferenceThreshold) {
      return CandidateDecision.skip;
    }
    if (remainingBudget <= 0) {
      return CandidateDecision.skip;
    }
    return CandidateDecision.llmInfer;
  }

  /// Score and sort candidates, returning decision for each
  Future<List<(CandidatePair, double, CandidateDecision)>> scoreAndDecide(
    List<CandidatePair> candidates, {
    int llmBudget = SyncConfig.maxLLMCallsPerCycle,
  }) async {
    final results = <(CandidatePair, double, CandidateDecision)>[];
    var remainingBudget = llmBudget;

    // Score all candidates
    final scored = <(CandidatePair, double)>[];
    for (final candidate in candidates) {
      final s = await score(candidate);
      candidate.finalScore = s;
      scored.add((candidate, s));
    }

    // Sort by score descending
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    // Decide for each
    for (final (candidate, s) in scored) {
      final decision = decide(s, remainingBudget);
      if (decision == CandidateDecision.llmInfer) {
        remainingBudget--;
      }
      results.add((candidate, s, decision));
    }

    return results;
  }
}
