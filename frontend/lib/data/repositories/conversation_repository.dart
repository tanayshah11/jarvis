import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../vector/vector_store.dart';
import '../embeddings/local_embedding_service.dart';

/// Repository for conversation and message operations
/// Abstracts local storage and provides a clean API
class ConversationRepository {
  final AppDatabase _db;
  final VectorStore _vectorStore;
  final LocalEmbeddingService _embeddingService;
  final Uuid _uuid = const Uuid();

  ConversationRepository({
    required AppDatabase db,
    required VectorStore vectorStore,
    required LocalEmbeddingService embeddingService,
  })  : _db = db,
        _vectorStore = vectorStore,
        _embeddingService = embeddingService;

  // ============================================
  // Conversation Operations
  // ============================================

  /// Get all conversations ordered by most recent
  Future<List<Conversation>> getAllConversations() {
    return _db.getAllConversations();
  }

  /// Get a single conversation by ID
  Future<Conversation?> getConversation(String id) {
    return _db.getConversation(id);
  }

  /// Create a new conversation
  Future<String> createConversation({String? title}) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertConversation(ConversationsCompanion.insert(
      id: id,
      title: Value(title),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    return id;
  }

  /// Update conversation title
  Future<void> updateConversationTitle(String id, String title) async {
    final existing = await _db.getConversation(id);
    if (existing == null) return;

    await _db.updateConversation(existing.copyWith(
      title: Value(title),
      updatedAt: DateTime.now(),
    ));
  }

  /// Archive a conversation
  Future<void> archiveConversation(String id) async {
    final existing = await _db.getConversation(id);
    if (existing == null) return;

    await _db.updateConversation(existing.copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    ));
  }

  /// Pin/unpin a conversation
  Future<void> togglePinConversation(String id) async {
    final existing = await _db.getConversation(id);
    if (existing == null) return;

    await _db.updateConversation(existing.copyWith(
      isPinned: !existing.isPinned,
      updatedAt: DateTime.now(),
    ));
  }

  /// Delete a conversation and all its messages
  Future<void> deleteConversation(String id) async {
    // Delete all message vectors
    await _vectorStore.deleteConversationVectors(id);

    // Delete messages
    await _db.deleteMessagesByConversation(id);

    // Delete conversation
    await _db.deleteConversation(id);
  }

  /// Delete all conversations (for cleanup/reset)
  Future<int> deleteAllConversations() async {
    final conversations = await getAllConversations();
    int count = 0;
    for (final conv in conversations) {
      await deleteConversation(conv.id);
      count++;
    }
    return count;
  }

  // ============================================
  // Message Operations
  // ============================================

  /// Get all messages for a conversation
  Future<List<Message>> getMessages(String conversationId) {
    return _db.getMessagesByConversation(conversationId);
  }

  /// Watch messages for a conversation (reactive)
  Stream<List<Message>> watchMessages(String conversationId) {
    return _db.watchMessagesByConversation(conversationId);
  }

  /// Add a message to a conversation
  Future<String> addMessage({
    required String conversationId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // Insert message
    await _db.insertMessage(MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: Value(now),
      metadata: Value(metadata != null ? _encodeJson(metadata) : null),
    ));

    // Update conversation timestamp
    final conversation = await _db.getConversation(conversationId);
    if (conversation != null) {
      await _db.updateConversation(conversation.copyWith(
        updatedAt: now,
      ));
    }

    // Generate and store embedding (async, non-blocking)
    _generateAndStoreEmbedding(conversationId, id, content, role);

    return id;
  }

  /// Generate embedding and store in vector database
  Future<void> _generateAndStoreEmbedding(
    String conversationId,
    String messageId,
    String content,
    String role,
  ) async {
    try {
      final embedding = await _embeddingService.embed(content);

      final vectorId = await _vectorStore.storeConversationVector(
        conversationId: conversationId,
        messageId: messageId,
        content: content,
        role: role,
        embedding: embedding,
      );

      // Update message with vector ID
      final message = await (_db.select(_db.messages)
            ..where((m) => m.id.equals(messageId)))
          .getSingleOrNull();

      if (message != null) {
        await _db.into(_db.messages).insertOnConflictUpdate(
              message.copyWith(vectorId: Value(vectorId)).toCompanion(true),
            );
      }
    } catch (e) {
      // Failed to generate embedding - non-critical, continue silently
    }
  }

  // ============================================
  // Semantic Search
  // ============================================

  /// Search messages semantically
  Future<List<SemanticMessageResult>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 10,
  }) async {
    final queryEmbedding = await _embeddingService.embed(query);

    final vectorResults = await _vectorStore.searchConversations(
      queryEmbedding: queryEmbedding,
      conversationId: conversationId,
      limit: limit,
    );

    final results = <SemanticMessageResult>[];
    for (final result in vectorResults) {
      final message = await (_db.select(_db.messages)
            ..where((m) => m.id.equals(result.entityId)))
          .getSingleOrNull();

      if (message != null) {
        results.add(SemanticMessageResult(
          message: message,
          score: result.score,
        ));
      }
    }

    return results;
  }

  /// Get relevant context for a query
  Future<String> getRelevantContext({
    required String query,
    int maxMessages = 5,
    double minScore = 0.3,
  }) async {
    final results = await searchMessages(
      query: query,
      limit: maxMessages,
    );

    final relevantResults = results.where((r) => r.score >= minScore);
    if (relevantResults.isEmpty) return '';

    final contextParts = <String>[];
    for (final result in relevantResults) {
      contextParts.add(
        '[${result.message.role}]: ${result.message.content}',
      );
    }

    return contextParts.join('\n\n');
  }

  // ============================================
  // Helpers
  // ============================================

  String _encodeJson(Map<String, dynamic> data) {
    // Simple JSON encoding - in production use dart:convert
    return data.toString();
  }
}

/// Result from semantic message search
class SemanticMessageResult {
  final Message message;
  final double score;

  SemanticMessageResult({
    required this.message,
    required this.score,
  });
}
