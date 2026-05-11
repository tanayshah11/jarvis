import 'package:jarvis/data/database/database.dart';

/// Source of relationship discovery
enum DiscoverySource {
  /// Found via vector embedding similarity
  semantic,

  /// Found via entity co-occurrence tracking
  cooccurrence,

  /// Found via temporal pattern analysis
  temporal,

  /// Found via multiple discovery methods
  multiSignal,
}

/// A candidate pair of entities that may have an undiscovered relationship
class CandidatePair {
  /// First node in the pair
  final MemoryNode nodeA;

  /// Second node in the pair
  final MemoryNode nodeB;

  /// How this pair was discovered
  final DiscoverySource source;

  /// Semantic similarity score (0.0 - 1.0) if discovered via semantic
  final double? similarity;

  /// Co-occurrence count if discovered via cooccurrence
  final int? cooccurrenceCount;

  /// Pattern confidence if discovered via temporal
  final double? temporalConfidence;

  /// Combined score after all factors considered (0.0 - 1.0)
  double? _finalScore;

  CandidatePair({
    required this.nodeA,
    required this.nodeB,
    required this.source,
    this.similarity,
    this.cooccurrenceCount,
    this.temporalConfidence,
  });

  /// Get or calculate the final score
  double get finalScore {
    if (_finalScore != null) return _finalScore!;

    // Calculate based on source
    switch (source) {
      case DiscoverySource.semantic:
        return similarity ?? 0.0;
      case DiscoverySource.cooccurrence:
        // Normalize co-occurrence count (caps at 10 for max score)
        return ((cooccurrenceCount ?? 0) / 10).clamp(0.0, 0.9);
      case DiscoverySource.temporal:
        return (temporalConfidence ?? 0.0) * 0.85;
      case DiscoverySource.multiSignal:
        // Average available signals with boost
        var total = 0.0;
        var count = 0;
        if (similarity != null) {
          total += similarity!;
          count++;
        }
        if (cooccurrenceCount != null && cooccurrenceCount! > 0) {
          total += ((cooccurrenceCount! / 10).clamp(0.0, 0.9));
          count++;
        }
        if (temporalConfidence != null) {
          total += temporalConfidence! * 0.85;
          count++;
        }
        return count > 0 ? (total / count) + 0.1 : 0.0; // +0.1 multi-signal boost
    }
  }

  /// Set the final score (after external scoring)
  set finalScore(double score) => _finalScore = score;

  /// Unique key for deduplication
  String get key {
    final ids = [nodeA.id, nodeB.id]..sort();
    return '${ids[0]}:${ids[1]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidatePair &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() =>
      'CandidatePair(${nodeA.name} <-> ${nodeB.name}, source: $source, score: ${finalScore.toStringAsFixed(2)})';

  /// Create a copy with additional data merged
  CandidatePair copyWithMergedData({
    double? similarity,
    int? cooccurrenceCount,
    double? temporalConfidence,
  }) {
    return CandidatePair(
      nodeA: nodeA,
      nodeB: nodeB,
      source: DiscoverySource.multiSignal,
      similarity: similarity ?? this.similarity,
      cooccurrenceCount: cooccurrenceCount ?? this.cooccurrenceCount,
      temporalConfidence: temporalConfidence ?? this.temporalConfidence,
    );
  }
}

/// Decision on how to handle a candidate pair
enum CandidateDecision {
  /// High confidence - auto-confirm without LLM
  autoConfirm,

  /// Medium confidence - use LLM to verify
  llmInfer,

  /// Low confidence - skip this cycle
  skip,
}

/// Configuration for candidate scoring
class ScoringConfig {
  /// Threshold for auto-confirmation (no LLM needed)
  final double autoConfirmThreshold;

  /// Threshold for LLM inference (below this, skip)
  final double llmThreshold;

  /// Boost for candidates that bridge disconnected graph components
  final double bridgeBoost;

  /// Boost per additional discovery signal
  final double multiSignalBoost;

  const ScoringConfig({
    this.autoConfirmThreshold = 0.88,
    this.llmThreshold = 0.55,
    this.bridgeBoost = 0.15,
    this.multiSignalBoost = 0.1,
  });

  static const defaults = ScoringConfig();

  /// Decide how to handle a candidate based on score and remaining budget
  CandidateDecision decide(double score, int remainingBudget) {
    // Handle invalid scores (NaN, negative infinity)
    if (score.isNaN || score.isNegative && score.isInfinite) {
      return CandidateDecision.skip;
    }
    if (score >= autoConfirmThreshold) return CandidateDecision.autoConfirm;
    if (score < llmThreshold) return CandidateDecision.skip;
    if (remainingBudget <= 0) return CandidateDecision.skip;
    return CandidateDecision.llmInfer;
  }
}
