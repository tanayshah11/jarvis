import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database.dart';

/// Repository for OAuth connection operations
/// Uses flutter_secure_storage for encrypted token storage
class ConnectionRepository {
  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;

  ConnectionRepository({
    required AppDatabase db,
    FlutterSecureStorage? secureStorage,
  })  : _db = db,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Key prefixes for secure storage
  static const _accessTokenPrefix = 'access_token_';
  static const _refreshTokenPrefix = 'refresh_token_';

  // ============================================
  // Connection Operations
  // ============================================

  /// Get all connected providers
  Future<List<Connection>> getAllConnections() {
    return _db.getAllConnections();
  }

  /// Get connection for a specific provider
  Future<Connection?> getConnection(String provider) {
    return _db.getConnection(provider);
  }

  /// Check if a provider is connected
  Future<bool> isConnected(String provider) async {
    final connection = await _db.getConnection(provider);
    return connection != null;
  }

  /// Store OAuth tokens after successful authentication
  Future<void> storeConnection({
    required String provider,
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();

    // Store tokens in secure storage
    await _secureStorage.write(
      key: '$_accessTokenPrefix$provider',
      value: accessToken,
    );

    if (refreshToken != null) {
      await _secureStorage.write(
        key: '$_refreshTokenPrefix$provider',
        value: refreshToken,
      );
    }

    // Store connection metadata in database (no sensitive data)
    await _db.insertConnection(ConnectionsCompanion.insert(
      provider: provider,
      encryptedAccessToken: '[SECURE_STORAGE]', // Placeholder - actual token in secure storage
      encryptedRefreshToken: Value(refreshToken != null ? '[SECURE_STORAGE]' : null),
      expiresAt: Value(expiresAt),
      metadata: Value(metadata != null ? jsonEncode(metadata) : null),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// Update tokens (e.g., after refresh)
  Future<void> updateTokens({
    required String provider,
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    final existing = await _db.getConnection(provider);
    if (existing == null) return;

    // Update tokens in secure storage
    await _secureStorage.write(
      key: '$_accessTokenPrefix$provider',
      value: accessToken,
    );

    if (refreshToken != null) {
      await _secureStorage.write(
        key: '$_refreshTokenPrefix$provider',
        value: refreshToken,
      );
    }

    // Update connection metadata
    final now = DateTime.now();
    await _db.updateConnection(existing.copyWith(
      expiresAt: expiresAt != null ? Value(expiresAt) : Value(existing.expiresAt),
      updatedAt: now,
    ));
  }

  /// Get decrypted access token
  Future<String?> getAccessToken(String provider) {
    return _secureStorage.read(key: '$_accessTokenPrefix$provider');
  }

  /// Get decrypted refresh token
  Future<String?> getRefreshToken(String provider) {
    return _secureStorage.read(key: '$_refreshTokenPrefix$provider');
  }

  /// Check if access token is expired
  Future<bool> isTokenExpired(String provider) async {
    final connection = await _db.getConnection(provider);
    if (connection == null) return true;
    if (connection.expiresAt == null) return false;

    // Consider expired if within 5 minutes of expiry
    return connection.expiresAt!
        .subtract(const Duration(minutes: 5))
        .isBefore(DateTime.now());
  }

  /// Update sync status
  Future<void> updateSyncStatus({
    required String provider,
    int? entitiesSynced,
    int? relationshipsSynced,
  }) async {
    final existing = await _db.getConnection(provider);
    if (existing == null) return;

    final now = DateTime.now();
    await _db.updateConnection(existing.copyWith(
      lastSyncedAt: Value(now),
      lastSyncEntities: entitiesSynced != null ? Value(entitiesSynced) : Value(existing.lastSyncEntities),
      lastSyncRelationships: relationshipsSynced != null
          ? Value(relationshipsSynced)
          : Value(existing.lastSyncRelationships),
      updatedAt: now,
    ));
  }

  /// Disconnect a provider
  Future<void> disconnect(String provider) async {
    // Remove tokens from secure storage
    await _secureStorage.delete(key: '$_accessTokenPrefix$provider');
    await _secureStorage.delete(key: '$_refreshTokenPrefix$provider');

    // Remove from database
    await _db.deleteConnection(provider);
  }

  /// Disconnect all providers
  Future<void> disconnectAll() async {
    final connections = await getAllConnections();
    for (final conn in connections) {
      await disconnect(conn.provider);
    }
  }

  // ============================================
  // Connection Status
  // ============================================

  /// Get detailed status for all providers
  Future<List<ConnectionStatus>> getConnectionStatuses() async {
    final connections = await getAllConnections();
    final statuses = <ConnectionStatus>[];

    for (final conn in connections) {
      final isExpired = conn.expiresAt != null &&
          conn.expiresAt!.isBefore(DateTime.now());

      final hasRefreshToken = await _secureStorage.read(
        key: '$_refreshTokenPrefix${conn.provider}',
      ) != null;

      statuses.add(ConnectionStatus(
        provider: conn.provider,
        isConnected: true,
        isTokenExpired: isExpired,
        hasRefreshToken: hasRefreshToken,
        connectedAt: conn.createdAt,
        lastSyncedAt: conn.lastSyncedAt,
        lastSyncEntities: conn.lastSyncEntities,
        lastSyncRelationships: conn.lastSyncRelationships,
      ));
    }

    return statuses;
  }
}

/// Connection status information
class ConnectionStatus {
  final String provider;
  final bool isConnected;
  final bool isTokenExpired;
  final bool hasRefreshToken;
  final DateTime connectedAt;
  final DateTime? lastSyncedAt;
  final int? lastSyncEntities;
  final int? lastSyncRelationships;

  ConnectionStatus({
    required this.provider,
    required this.isConnected,
    required this.isTokenExpired,
    required this.hasRefreshToken,
    required this.connectedAt,
    this.lastSyncedAt,
    this.lastSyncEntities,
    this.lastSyncRelationships,
  });

  bool get needsRefresh => isTokenExpired && hasRefreshToken;
  bool get needsReauth => isTokenExpired && !hasRefreshToken;
}
