import 'package:drift/drift.dart';

/// Local user table - stores authenticated user info
class Users extends Table {
  /// UUID from server
  TextColumn get id => text()();

  /// User's email address
  TextColumn get email => text()();

  /// Display name
  TextColumn get name => text().nullable()();

  /// When the user was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the user was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
