import 'package:drift/drift.dart';
import 'users.dart';

/// User profile with preferences
class Profiles extends Table {
  /// UUID
  TextColumn get id => text()();

  /// Foreign key to users table
  TextColumn get userId => text().references(Users, #id)();

  /// User's display name
  TextColumn get displayName => text().nullable()();

  /// AI provider preference (groq, anthropic, openai)
  TextColumn get preferredAiProvider => text().withDefault(const Constant('groq'))();

  /// AI model preference
  TextColumn get preferredModel => text().nullable()();

  /// User's timezone
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();

  /// Personality traits as JSON
  TextColumn get personalityTraits => text().nullable()();

  /// User preferences as JSON
  TextColumn get preferences => text().nullable()();

  /// When the profile was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the profile was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
