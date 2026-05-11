import 'package:drift/drift.dart';

/// Stores discovered temporal patterns for entities
/// Examples: "User mentions 'gym' mostly on Mondays", "Sarah is often mentioned in evenings"
class TemporalPatterns extends Table {
  /// Unique pattern ID (UUID)
  TextColumn get id => text()();

  /// The entity this pattern is about
  TextColumn get entityId => text()();

  /// Type of pattern: 'weekly', 'daily', 'monthly', 'sequence'
  /// - weekly: entity mentioned on specific day(s) of week
  /// - daily: entity mentioned at specific time(s) of day
  /// - monthly: entity mentioned on specific day(s) of month
  /// - sequence: entity often follows/precedes another entity
  TextColumn get patternType => text()();

  /// JSON-encoded pattern data
  /// For weekly: {"dayOfWeek": 0, "dayName": "Monday", "avgTime": "18:30"}
  /// For daily: {"hourOfDay": 18, "timeRange": "evening"}
  /// For sequence: {"followsEntity": "uuid", "precedesEntity": "uuid"}
  TextColumn get patternData => text()();

  /// Statistical confidence in the pattern (0.0 - 1.0)
  /// Based on chi-squared test or other statistical measure
  RealColumn get confidence => real().withDefault(const Constant(0.5))();

  /// Number of times this pattern was observed
  IntColumn get occurrenceCount => integer().withDefault(const Constant(0))();

  /// When the pattern was first discovered
  DateTimeColumn get discoveredAt => dateTime().withDefault(currentDateAndTime)();

  /// When the pattern was last observed
  DateTimeColumn get lastObserved => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
