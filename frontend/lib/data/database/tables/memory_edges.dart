import 'package:drift/drift.dart';
import 'memory_nodes.dart';

/// Memory graph edges (relationships between nodes)
class MemoryEdges extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Source node ID
  @ReferenceName('outgoingEdges')
  TextColumn get fromNodeId => text().references(MemoryNodes, #id)();

  /// Target node ID
  @ReferenceName('incomingEdges')
  TextColumn get toNodeId => text().references(MemoryNodes, #id)();

  /// Relationship type: knows, works_at, attended, lives_in, etc.
  TextColumn get relationshipType => text()();

  /// Additional attributes as JSON
  /// e.g., {"since": "2020", "role": "colleague"}
  TextColumn get attributes => text().nullable()();

  /// Confidence score (0.0 - 1.0)
  RealColumn get confidence => real().withDefault(const Constant(0.7))();

  /// How many times this relationship has been referenced
  IntColumn get referenceCount => integer().withDefault(const Constant(1))();

  /// When the edge was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the edge was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// When the edge was last referenced in conversation
  DateTimeColumn get lastReferenced => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {fromNodeId, toNodeId, relationshipType}, // Unique constraint
      ];
}
