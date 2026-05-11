import 'package:jarvis/data/database/database.dart';

/// Result of a deep network sync operation
class SyncResult {
  /// Number of new edges created
  final int newEdgesCount;

  /// Number of temporal patterns discovered
  final int newPatternsCount;

  /// Number of candidates evaluated
  final int candidatesEvaluated;

  /// Number of LLM calls made
  final int llmCallsUsed;

  /// Time taken for the sync
  final Duration duration;

  /// Any errors that occurred (non-fatal)
  final List<String> warnings;

  /// The newly created edges
  final List<MemoryEdge> newEdges;

  /// Whether the sync completed successfully
  final bool success;

  /// Error message if sync failed
  final String? errorMessage;

  const SyncResult({
    required this.newEdgesCount,
    required this.newPatternsCount,
    required this.candidatesEvaluated,
    required this.llmCallsUsed,
    required this.duration,
    this.warnings = const [],
    this.newEdges = const [],
    this.success = true,
    this.errorMessage,
  });

  /// Create a failed result
  factory SyncResult.failed(String error, {Duration? duration}) {
    return SyncResult(
      newEdgesCount: 0,
      newPatternsCount: 0,
      candidatesEvaluated: 0,
      llmCallsUsed: 0,
      duration: duration ?? Duration.zero,
      success: false,
      errorMessage: error,
    );
  }

  /// Create a skipped result (e.g., not enough data)
  factory SyncResult.skipped(String reason) {
    return SyncResult(
      newEdgesCount: 0,
      newPatternsCount: 0,
      candidatesEvaluated: 0,
      llmCallsUsed: 0,
      duration: Duration.zero,
      warnings: [reason],
    );
  }

  @override
  String toString() {
    if (!success) return 'SyncResult(failed: $errorMessage)';
    return 'SyncResult(edges: $newEdgesCount, patterns: $newPatternsCount, '
        'candidates: $candidatesEvaluated, llmCalls: $llmCallsUsed, '
        'duration: ${duration.inSeconds}s)';
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'newEdgesCount': newEdgesCount,
        'newPatternsCount': newPatternsCount,
        'candidatesEvaluated': candidatesEvaluated,
        'llmCallsUsed': llmCallsUsed,
        'durationMs': duration.inMilliseconds,
        'warnings': warnings,
        if (errorMessage != null) 'error': errorMessage,
      };
}

/// Statistics about the sync system
class SyncStats {
  /// Total syncs completed
  final int totalSyncs;

  /// Total edges created across all syncs
  final int totalEdgesCreated;

  /// Total patterns discovered
  final int totalPatternsDiscovered;

  /// Total LLM calls used
  final int totalLlmCalls;

  /// Last sync time
  final DateTime? lastSyncTime;

  /// Average sync duration
  final Duration avgDuration;

  const SyncStats({
    required this.totalSyncs,
    required this.totalEdgesCreated,
    required this.totalPatternsDiscovered,
    required this.totalLlmCalls,
    this.lastSyncTime,
    this.avgDuration = Duration.zero,
  });

  factory SyncStats.empty() => const SyncStats(
        totalSyncs: 0,
        totalEdgesCreated: 0,
        totalPatternsDiscovered: 0,
        totalLlmCalls: 0,
      );
}
