import 'package:drift/drift.dart';

/// Tracks co-occurrence of entities within messages/sessions
/// Used for discovering implicit relationships between entities
class EntityCooccurrences extends Table {
  /// First entity ID (sorted alphabetically to ensure consistent pairs)
  TextColumn get entityA => text()();

  /// Second entity ID (sorted alphabetically to ensure consistent pairs)
  TextColumn get entityB => text()();

  /// Number of times these entities co-occurred in the same message
  IntColumn get cooccurrenceCount => integer().withDefault(const Constant(0))();

  /// Number of distinct messages where they co-occurred
  IntColumn get messageCount => integer().withDefault(const Constant(0))();

  /// Number of distinct sessions/conversations where they co-occurred
  IntColumn get sessionCount => integer().withDefault(const Constant(0))();

  /// Average temporal proximity (seconds between mentions in same session)
  /// Lower values indicate closer temporal relationship
  RealColumn get temporalProximity => real().withDefault(const Constant(0.0))();

  /// When this pair was first observed together
  DateTimeColumn get firstSeen => dateTime().withDefault(currentDateAndTime)();

  /// When this pair was last observed together
  DateTimeColumn get lastSeen => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {entityA, entityB};
}
