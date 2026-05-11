import 'package:drift/drift.dart';

/// OAuth connections to external services (Google, Amazon, Spotify, etc.)
class Connections extends Table {
  /// Provider name: google, amazon, spotify
  TextColumn get provider => text()();

  /// Encrypted access token
  TextColumn get encryptedAccessToken => text()();

  /// Encrypted refresh token
  TextColumn get encryptedRefreshToken => text().nullable()();

  /// When the access token expires
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// Connection metadata as JSON
  /// e.g., {"scopes": [...], "email": "..."}
  TextColumn get metadata => text().nullable()();

  /// When the connection was established
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the connection was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// When data was last synced from this provider
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Number of entities synced in last sync
  IntColumn get lastSyncEntities => integer().nullable()();

  /// Number of relationships synced in last sync
  IntColumn get lastSyncRelationships => integer().nullable()();

  @override
  Set<Column> get primaryKey => {provider};
}
