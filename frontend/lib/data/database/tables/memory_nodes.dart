import 'package:drift/drift.dart';

/// Memory graph nodes (entities like people, events, organizations)
class MemoryNodes extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Node type: person, event, organization, location, topic, etc.
  TextColumn get nodeType => text()();

  /// Display name
  TextColumn get name => text()();

  /// Source of this node: google_calendar, gmail, contacts, conversation
  TextColumn get source => text().nullable()();

  /// ID from the source system
  TextColumn get sourceId => text().nullable()();

  /// Additional attributes as JSON
  /// e.g., {"email": "...", "birthday": "...", "job_title": "..."}
  TextColumn get attributes => text().nullable()();

  /// Confidence score (0.0 - 1.0)
  /// 0.9 = explicitly mentioned, 0.7 = implied, 0.5 = inferred
  RealColumn get confidence => real().withDefault(const Constant(0.8))();

  /// When the node was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the node was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// When the node was last referenced in conversation
  DateTimeColumn get lastReferenced => dateTime().nullable()();

  /// Vector embedding ID (reference to ObjectBox)
  IntColumn get vectorId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {source, sourceId}, // Unique constraint on source + sourceId
      ];
}
