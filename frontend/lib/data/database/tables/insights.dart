import 'package:drift/drift.dart';

/// Computed insights from nightly sync (personality, reconnection suggestions, etc.)
class Insights extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Type of insight: personality, reconnection, pattern, community
  TextColumn get insightType => text()();

  /// Human-readable title
  TextColumn get title => text()();

  /// Insight data as JSON (structure varies by type)
  TextColumn get data => text()();

  /// When the insight was generated
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();

  /// When the insight expires (should be regenerated)
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// Whether the insight has been viewed by the user
  BoolColumn get isViewed => boolean().withDefault(const Constant(false))();

  /// Whether the user dismissed this insight
  BoolColumn get isDismissed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
