import 'package:drift/drift.dart';
import 'conversations.dart';

/// Individual messages within conversations
class Messages extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Foreign key to conversations table
  TextColumn get conversationId => text().references(Conversations, #id)();

  /// Role: 'user', 'assistant', or 'system'
  TextColumn get role => text()();

  /// Message content
  TextColumn get content => text()();

  /// When the message was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Message metadata as JSON (tokens used, model, etc.)
  TextColumn get metadata => text().nullable()();

  /// Whether memories were extracted from this message
  BoolColumn get memoriesExtracted => boolean().withDefault(const Constant(false))();

  /// Vector embedding ID (reference to ObjectBox)
  IntColumn get vectorId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
