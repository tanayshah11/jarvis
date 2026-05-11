import 'package:objectbox/objectbox.dart';

/// Vector embedding for memory nodes and messages
/// Used for semantic search via HNSW index
@Entity()
class MemoryVector {
  @Id()
  int id = 0;

  /// Reference to the source entity
  /// Format: "node:{node_id}" or "message:{message_id}"
  @Index()
  String entityRef;

  /// Entity type: "node" or "message"
  @Index()
  String entityType;

  /// The text that was embedded
  String sourceText;

  /// 100-dimensional embedding from USE-QA-OnDevice
  /// Note: When changing dimensions, existing vectors must be re-embedded
  @HnswIndex(dimensions: 100)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  /// When the embedding was created
  @Property(type: PropertyType.date)
  DateTime createdAt;

  MemoryVector({
    this.id = 0,
    required this.entityRef,
    required this.entityType,
    required this.sourceText,
    this.embedding,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Conversation context vector for semantic retrieval
@Entity()
class ConversationVector {
  @Id()
  int id = 0;

  /// Conversation ID from Drift
  @Index()
  String conversationId;

  /// Message ID from Drift
  @Index()
  String messageId;

  /// The message content
  String content;

  /// Role: user, assistant, system
  String role;

  /// 100-dimensional embedding from USE-QA-OnDevice
  @HnswIndex(dimensions: 100)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  /// Message timestamp
  @Property(type: PropertyType.date)
  DateTime timestamp;

  ConversationVector({
    this.id = 0,
    required this.conversationId,
    required this.messageId,
    required this.content,
    required this.role,
    this.embedding,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
