import 'package:drift/drift.dart';

/// Conversation threads
class Conversations extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Conversation title (auto-generated or user-set)
  TextColumn get title => text().nullable()();

  /// Summary of the conversation
  TextColumn get summary => text().nullable()();

  /// When the conversation was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the conversation was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Metadata as JSON (e.g., tags, context)
  TextColumn get metadata => text().nullable()();

  /// Whether the conversation is archived
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Whether the conversation is pinned
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
