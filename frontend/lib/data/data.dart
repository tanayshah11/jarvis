/// Local-first data layer for Jarvis
///
/// This module provides:
/// - Drift (SQLite) for relational data
/// - ObjectBox for vector search
/// - TensorFlow Lite for on-device embeddings
/// - Repository pattern for clean API
library;

// Core service
export 'data_service.dart';

// Database
export 'database/database.dart';

// Vector store
export 'vector/vector_store.dart';
export 'vector/models/memory_vector.dart';

// Embeddings
export 'embeddings/local_embedding_service.dart';

// Repositories
export 'repositories/conversation_repository.dart';
export 'repositories/memory_repository.dart';
export 'repositories/connection_repository.dart';
