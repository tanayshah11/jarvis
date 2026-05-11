import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarvis/core/network/api_client.dart';
import 'package:jarvis/data/database/database.dart';
import 'package:jarvis/data/embeddings/local_embedding_service.dart';
import 'package:jarvis/data/repositories/memory_repository.dart';
import 'package:jarvis/data/vector/vector_store.dart';
import 'package:jarvis/features/network_sync/models/sync_result.dart';
import 'package:jarvis/features/network_sync/services/deep_network_sync_service.dart';

/// Provider for the DeepNetworkSyncService
final deepNetworkSyncServiceProvider =
    Provider<DeepNetworkSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final vectorStore = ref.watch(vectorStoreProvider);
  final embeddingService = ref.watch(embeddingServiceProvider);
  final apiClient = ref.watch(apiClientProvider);

  return DeepNetworkSyncService(
    database: database,
    memoryRepo: memoryRepo,
    vectorStore: vectorStore,
    embeddingService: embeddingService,
    apiClient: apiClient,
  );
});

/// Notifier for sync status using Riverpod's Notifier
class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    return const SyncState.idle();
  }

  /// Run a sync operation
  Future<SyncResult> runSync() async {
    final syncService = ref.read(deepNetworkSyncServiceProvider);
    state = const SyncState.syncing();

    try {
      final result = await syncService.runSync();

      if (result.success) {
        state = SyncState.completed(result);
      } else {
        state = SyncState.error(result.errorMessage ?? 'Unknown error');
      }

      return result;
    } catch (e) {
      state = SyncState.error(e.toString());
      return SyncResult.failed(e.toString());
    }
  }

  /// Reset to idle state
  void reset() {
    state = const SyncState.idle();
  }
}

/// Provider for sync notifier
final syncNotifierProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);

/// Sync state enum wrapper
sealed class SyncState {
  const SyncState();

  const factory SyncState.idle() = SyncStateIdle;
  const factory SyncState.syncing() = SyncStateSyncing;
  const factory SyncState.completed(SyncResult result) = SyncStateCompleted;
  const factory SyncState.error(String message) = SyncStateError;

  bool get isIdle => this is SyncStateIdle;
  bool get isSyncing => this is SyncStateSyncing;
  bool get isCompleted => this is SyncStateCompleted;
  bool get isError => this is SyncStateError;
}

class SyncStateIdle extends SyncState {
  const SyncStateIdle();
}

class SyncStateSyncing extends SyncState {
  const SyncStateSyncing();
}

class SyncStateCompleted extends SyncState {
  final SyncResult result;
  const SyncStateCompleted(this.result);
}

class SyncStateError extends SyncState {
  final String message;
  const SyncStateError(this.message);
}

// ============================================
// Re-export common providers from other files
// These would typically already exist in your codebase
// ============================================

/// Database provider (should already exist in your app)
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Vector store provider (should already exist in your app)
final vectorStoreProvider = Provider<VectorStore>((ref) {
  final store = VectorStore();
  // Note: initialize() should be called at app startup
  return store;
});

/// Embedding service provider (should already exist in your app)
final embeddingServiceProvider = Provider<LocalEmbeddingService>((ref) {
  final service = LocalEmbeddingService();
  // Note: initialize() should be called at app startup
  return service;
});

/// Memory repository provider (should already exist in your app)
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final vectorStore = ref.watch(vectorStoreProvider);
  final embeddingService = ref.watch(embeddingServiceProvider);

  return MemoryRepository(
    db: db,
    vectorStore: vectorStore,
    embeddingService: embeddingService,
  );
});
