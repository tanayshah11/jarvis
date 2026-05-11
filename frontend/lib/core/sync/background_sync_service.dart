import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:jarvis/core/network/api_client.dart';
import 'package:jarvis/core/storage/secure_storage.dart';
import 'package:jarvis/data/database/database.dart';
import 'package:jarvis/data/embeddings/local_embedding_service.dart';
import 'package:jarvis/data/repositories/memory_repository.dart';
import 'package:jarvis/data/vector/vector_store.dart';
import 'package:jarvis/features/network_sync/models/sync_config.dart';
import 'package:jarvis/features/network_sync/services/deep_network_sync_service.dart';

const String _logName = 'BackgroundSync';

/// Background sync service provider
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  return BackgroundSyncService();
});

/// Service for managing background sync tasks using WorkManager
class BackgroundSyncService {
  bool _isInitialized = false;

  /// Initialize WorkManager and register periodic sync task
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );

    _isInitialized = true;
    developer.log('WorkManager initialized', name: _logName);
  }

  /// Register the periodic deep network sync task
  Future<void> registerPeriodicSync() async {
    if (!_isInitialized) await initialize();

    await Workmanager().registerPeriodicTask(
      SyncConfig.backgroundTaskName,
      SyncConfig.backgroundTaskTag,
      frequency: SyncConfig.syncInterval,
      constraints: Constraints(
        networkType: SyncConfig.requiresNetwork
            ? NetworkType.connected
            : NetworkType.not_required,
        requiresBatteryNotLow: SyncConfig.requiresBatteryNotLow,
        requiresDeviceIdle: SyncConfig.requiresDeviceIdle,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      initialDelay: const Duration(minutes: 5), // Give app time to settle
    );

    developer.log(
      'Registered periodic sync: every ${SyncConfig.syncInterval.inMinutes} minutes',
      name: _logName,
    );
  }

  /// Run a one-time sync immediately
  Future<void> runImmediateSync() async {
    if (!_isInitialized) await initialize();

    await Workmanager().registerOneOffTask(
      '${SyncConfig.backgroundTaskName}-immediate',
      SyncConfig.backgroundTaskTag,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    developer.log('Registered immediate sync task', name: _logName);
  }

  /// Cancel all sync tasks
  Future<void> cancelAllSyncs() async {
    await Workmanager().cancelAll();
    developer.log('Cancelled all sync tasks', name: _logName);
  }

  /// Cancel the periodic sync task only
  Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName(SyncConfig.backgroundTaskName);
    developer.log('Cancelled periodic sync task', name: _logName);
  }

  /// Check when the last sync was performed
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('last_deep_sync');
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }
}

/// WorkManager callback dispatcher - runs in an isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    developer.log('Background task started: $task', name: _logName);

    try {
      if (task == SyncConfig.backgroundTaskTag ||
          task == 'deepNetworkSync' ||
          task == SyncConfig.backgroundTaskName) {
        // Execute the deep network sync
        final result = await _executeDeepSync();

        // Save last sync time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_deep_sync', DateTime.now().toIso8601String());

        developer.log(
          'Background sync completed: ${result ? 'success' : 'failed'}',
          name: _logName,
        );
        return result;
      }

      developer.log('Unknown task: $task', name: _logName);
      return false;
    } catch (e, stackTrace) {
      developer.log(
        'Background sync error: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  });
}

/// Execute the deep network sync in background isolate
Future<bool> _executeDeepSync() async {
  try {
    // Initialize required services
    // Note: In background isolate, we need to reinitialize everything
    final database = AppDatabase();
    final vectorStore = VectorStore();
    await vectorStore.initialize();

    final embeddingService = LocalEmbeddingService();
    await embeddingService.initialize();

    final secureStorage = SecureStorage();
    final apiClient = ApiClient(secureStorage: secureStorage);

    final memoryRepo = MemoryRepository(
      db: database,
      vectorStore: vectorStore,
      embeddingService: embeddingService,
    );

    final syncService = DeepNetworkSyncService(
      database: database,
      memoryRepo: memoryRepo,
      vectorStore: vectorStore,
      embeddingService: embeddingService,
      apiClient: apiClient,
    );

    // Run sync
    final result = await syncService.runSync();

    // Cleanup
    vectorStore.close();

    developer.log('Deep sync result: $result', name: _logName);
    return result.success;
  } catch (e) {
    developer.log('Deep sync execution failed: $e', name: _logName);
    return false;
  }
}

/// Extension for easy access from WidgetRef
extension BackgroundSyncX on WidgetRef {
  BackgroundSyncService get backgroundSync =>
      read(backgroundSyncServiceProvider);
}
