/// Represents a conversation in the history.
class Conversation {
  /// Unique identifier for the conversation.
  final String id;

  /// Title/summary of the conversation.
  final String title;

  /// Timestamp when the conversation was created.
  final DateTime timestamp;

  /// Last message preview (optional).
  final String? lastMessage;

  /// Number of messages in the conversation.
  final int messageCount;

  /// Model used in this conversation.
  final String? modelId;

  const Conversation({
    required this.id,
    required this.title,
    required this.timestamp,
    this.lastMessage,
    this.messageCount = 0,
    this.modelId,
  });

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    String? lastMessage,
    int? messageCount,
    String? modelId,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      lastMessage: lastMessage ?? this.lastMessage,
      messageCount: messageCount ?? this.messageCount,
      modelId: modelId ?? this.modelId,
    );
  }
}
