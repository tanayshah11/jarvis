/// Configuration for the deep network sync system
class SyncConfig {
  // ============================================
  // Timing Configuration
  // ============================================

  /// How often to run background sync
  static const syncInterval = Duration(minutes: 30);

  /// Maximum time allowed for a single sync cycle
  static const maxSyncDuration = Duration(minutes: 5);

  /// Minimum time between syncs (prevents rapid consecutive syncs)
  static const minSyncGap = Duration(minutes: 15);

  // ============================================
  // Semantic Discovery Configuration
  // ============================================

  /// Minimum cosine similarity for semantic candidates
  static const double semanticSimilarityThreshold = 0.72;

  /// Maximum semantic candidates to consider per node
  static const int maxSemanticCandidatesPerNode = 5;

  /// Maximum total semantic candidates per sync
  static const int maxSemanticCandidatesTotal = 50;

  // ============================================
  // Co-occurrence Configuration
  // ============================================

  /// Minimum co-occurrence count to consider a pair
  static const int minCooccurrenceCount = 3;

  /// Weight for co-occurrence in combined scoring
  static const double cooccurrenceConfidenceWeight = 0.7;

  /// Maximum co-occurrence candidates per sync
  static const int maxCooccurrenceCandidates = 30;

  // ============================================
  // Temporal Pattern Configuration
  // ============================================

  /// Number of weeks to analyze for patterns
  static const int patternWindowWeeks = 8;

  /// Minimum occurrences to consider a pattern valid
  static const int minPatternOccurrences = 3;

  /// Chi-squared threshold for statistical significance (p < 0.05, df=6)
  static const double chiSquaredThreshold = 12.59;

  // ============================================
  // LLM Budget Configuration
  // ============================================

  /// Maximum LLM calls per sync cycle
  static const int maxLLMCallsPerCycle = 10;

  /// Score threshold for auto-confirmation (no LLM needed)
  static const double autoConfirmThreshold = 0.88;

  /// Score threshold for LLM inference (below this, skip)
  static const double llmInferenceThreshold = 0.55;

  // ============================================
  // Edge Creation Configuration
  // ============================================

  /// Minimum confidence for creating an edge from LLM inference
  static const double minLLMEdgeConfidence = 0.6;

  /// Default confidence for auto-confirmed edges
  static const double autoConfirmEdgeConfidence = 0.85;

  /// Evidence source label for auto-discovered edges
  static const String autoDiscoveredSource = 'auto_discovered';

  /// Evidence source label for LLM-discovered edges
  static const String llmDiscoveredSource = 'llm_discovered';

  // ============================================
  // Background Task Configuration (WorkManager)
  // ============================================

  /// Unique task name for WorkManager
  static const String backgroundTaskName = 'deep-network-sync';

  /// Task tag for WorkManager
  static const String backgroundTaskTag = 'jarvis_sync';

  /// Require network connection for sync
  static const bool requiresNetwork = true;

  /// Only sync when battery is not low
  static const bool requiresBatteryNotLow = true;

  /// Require device to be idle (optional, for less intrusive sync)
  static const bool requiresDeviceIdle = false;

  // ============================================
  // Graph Analysis Configuration
  // ============================================

  /// Boost score for candidates that bridge disconnected components
  static const double bridgeCandidateBoost = 0.15;

  /// Boost score for candidates found by multiple discovery methods
  static const double multiSignalBoost = 0.1;

  /// Maximum path length to consider nodes "connected" (for bridge detection)
  static const int maxPathLengthForConnection = 3;

  // ============================================
  // Cleanup Configuration
  // ============================================

  /// Maximum age for low-confidence patterns before cleanup
  static const Duration maxPatternAge = Duration(days: 90);

  /// Minimum confidence for patterns to survive cleanup
  static const double minPatternConfidenceForRetention = 0.3;

  // ============================================
  // Anonymization Placeholders
  // ============================================

  /// Placeholder prefixes for anonymization
  static const Map<String, String> placeholderPrefixes = {
    'person': 'PERSON_',
    'place': 'PLACE_',
    'location': 'LOCATION_',
    'organization': 'ORG_',
    'event': 'EVENT_',
    'topic': 'TOPIC_',
    'default': 'ENTITY_',
  };
}
