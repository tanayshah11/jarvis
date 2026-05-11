import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/database.dart';
import 'vector/vector_store.dart';
import 'embeddings/local_embedding_service.dart';
import 'repositories/conversation_repository.dart';
import 'repositories/memory_repository.dart';
import 'repositories/connection_repository.dart';

/// Main data service that manages all local storage
/// Initializes database, vector store, and embedding service
class DataService {
  late final AppDatabase _database;
  late final VectorStore _vectorStore;
  late final LocalEmbeddingService _embeddingService;

  late final ConversationRepository conversationRepository;
  late final MemoryRepository memoryRepository;
  late final ConnectionRepository connectionRepository;

  bool _isInitialized = false;

  /// Initialize all data services
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize database
    _database = AppDatabase();

    // Initialize vector store
    _vectorStore = VectorStore();
    await _vectorStore.initialize();

    // Initialize embedding service
    _embeddingService = LocalEmbeddingService();
    await _embeddingService.initialize();

    // Create repositories
    conversationRepository = ConversationRepository(
      db: _database,
      vectorStore: _vectorStore,
      embeddingService: _embeddingService,
    );

    memoryRepository = MemoryRepository(
      db: _database,
      vectorStore: _vectorStore,
      embeddingService: _embeddingService,
    );

    connectionRepository = ConnectionRepository(
      db: _database,
      // Uses flutter_secure_storage internally for token encryption
    );

    _isInitialized = true;
  }

  /// Close all services
  Future<void> close() async {
    if (!_isInitialized) return;

    _embeddingService.dispose();
    _vectorStore.close();
    await _database.close();

    _isInitialized = false;
  }

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Get raw database access (use sparingly)
  AppDatabase get database => _database;

  /// Get raw vector store access (use sparingly)
  VectorStore get vectorStore => _vectorStore;

  /// Get embedding service
  LocalEmbeddingService get embeddingService => _embeddingService;

  /// Get memory stats across all stores
  Future<DataStats> getStats() async {
    final memoryStats = await memoryRepository.getStats();
    final dbStats = await _database.getMemoryStats();

    return DataStats(
      nodeCount: memoryStats.nodeCount,
      edgeCount: memoryStats.edgeCount,
      conversationCount: dbStats['conversations'] ?? 0,
      messageCount: dbStats['messages'] ?? 0,
      memoryVectorCount: memoryStats.vectorCount,
      conversationVectorCount: _vectorStore.conversationVectorCount,
      isModelLoaded: _embeddingService.isModelLoaded,
    );
  }

  /// Clear all local data (for logout or reset)
  Future<void> clearAllData() async {
    // Clear vectors
    await _vectorStore.clearAll();

    // Note: For full database clear, we'd need to add
    // deleteAll methods to each table
  }

  /// Export all data for nightly sync
  Future<Map<String, dynamic>> exportForSync() async {
    final memoryData = await memoryRepository.exportForSync();
    final connections = await connectionRepository.getAllConnections();

    return {
      'memory': memoryData,
      'connections': connections.map((c) => {
        'provider': c.provider,
        'connected_at': c.createdAt.toIso8601String(),
        'last_synced': c.lastSyncedAt?.toIso8601String(),
      }).toList(),
      'stats': {
        'node_count': memoryData['nodes']?.length ?? 0,
        'edge_count': memoryData['edges']?.length ?? 0,
      },
      'device_info': {
        'exported_at': DateTime.now().toIso8601String(),
      },
    };
  }
}

/// Combined data statistics
class DataStats {
  final int nodeCount;
  final int edgeCount;
  final int conversationCount;
  final int messageCount;
  final int memoryVectorCount;
  final int conversationVectorCount;
  final bool isModelLoaded;

  DataStats({
    required this.nodeCount,
    required this.edgeCount,
    required this.conversationCount,
    required this.messageCount,
    required this.memoryVectorCount,
    required this.conversationVectorCount,
    required this.isModelLoaded,
  });

  int get totalVectors => memoryVectorCount + conversationVectorCount;

  @override
  String toString() {
    return '''DataStats:
  Nodes: $nodeCount
  Edges: $edgeCount
  Conversations: $conversationCount
  Messages: $messageCount
  Memory Vectors: $memoryVectorCount
  Conversation Vectors: $conversationVectorCount
  Model Loaded: $isModelLoaded''';
  }
}

// ============================================
// Riverpod Providers
// ============================================

/// Provider for the DataService singleton
final dataServiceProvider = Provider<DataService>((ref) {
  final service = DataService();
  ref.onDispose(() => service.close());
  return service;
});

/// Provider for DataService initialization status
final dataServiceInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(dataServiceProvider);
  await service.initialize();
  return true;
});

/// Provider for ConversationRepository
/// Depends on dataServiceInitializedProvider to ensure initialization is complete
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  // Ensure initialization has completed before accessing repositories
  final initialized = ref.watch(dataServiceInitializedProvider);
  if (!initialized.hasValue || initialized.value != true) {
    throw StateError('DataService not yet initialized. Ensure dataServiceInitializedProvider is awaited before accessing repositories.');
  }
  final service = ref.watch(dataServiceProvider);
  return service.conversationRepository;
});

/// Provider for MemoryRepository
/// Depends on dataServiceInitializedProvider to ensure initialization is complete
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  // Ensure initialization has completed before accessing repositories
  final initialized = ref.watch(dataServiceInitializedProvider);
  if (!initialized.hasValue || initialized.value != true) {
    throw StateError('DataService not yet initialized. Ensure dataServiceInitializedProvider is awaited before accessing repositories.');
  }
  final service = ref.watch(dataServiceProvider);
  return service.memoryRepository;
});

/// Provider for ConnectionRepository
/// Depends on dataServiceInitializedProvider to ensure initialization is complete
final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  // Ensure initialization has completed before accessing repositories
  final initialized = ref.watch(dataServiceInitializedProvider);
  if (!initialized.hasValue || initialized.value != true) {
    throw StateError('DataService not yet initialized. Ensure dataServiceInitializedProvider is awaited before accessing repositories.');
  }
  final service = ref.watch(dataServiceProvider);
  return service.connectionRepository;
});

/// Provider for DataStats
final dataStatsProvider = FutureProvider<DataStats>((ref) async {
  final service = ref.watch(dataServiceProvider);
  return service.getStats();
});
