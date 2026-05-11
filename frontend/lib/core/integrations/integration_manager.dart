import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import 'models/integration.dart';
import 'models/oauth_tokens.dart';
import 'tool_registry.dart';

/// Exception thrown when integration connection fails
class IntegrationConnectionException implements Exception {
  final String integrationId;
  final String message;
  final dynamic originalError;

  IntegrationConnectionException(
    this.integrationId,
    this.message, [
    this.originalError,
  ]);

  @override
  String toString() => 'Integration connection failed [$integrationId]: $message';
}

/// Exception thrown when token refresh fails
class TokenRefreshException implements Exception {
  final String service;
  final String message;

  TokenRefreshException(this.service, this.message);

  @override
  String toString() => 'Token refresh failed [$service]: $message';
}

/// Central manager for all integrations
///
/// Manages integration lifecycle, OAuth tokens, and service connections.
/// Integrations can be local (device permissions) or OAuth-based (external services).
class IntegrationManager {
  final SecureStorage _secureStorage;
  final ToolRegistry _toolRegistry;

  final Map<String, Integration> _integrations = {};
  final _statusChangesController = StreamController<Integration>.broadcast();

  static const String _integrationsKey = 'integrations';
  static const String _tokensPrefix = 'oauth_tokens_';

  IntegrationManager({
    required SecureStorage secureStorage,
    required ToolRegistry toolRegistry,
  })  : _secureStorage = secureStorage,
        _toolRegistry = toolRegistry;

  /// Stream of integration status changes
  Stream<Integration> get statusChanges => _statusChangesController.stream;

  /// Initialize with all available integrations
  ///
  /// Loads saved integration states and registers default integrations.
  Future<void> initialize() async {
    // Load saved integrations from storage
    await _loadIntegrations();

    // Register default integrations if none exist
    if (_integrations.isEmpty) {
      _registerDefaultIntegrations();
      await _saveIntegrations();
    }

    // Restore connection status for OAuth integrations
    await _restoreOAuthConnections();
  }

  /// Register default available integrations
  void _registerDefaultIntegrations() {
    // Local integrations (iOS/Android permissions)
    _integrations['contacts'] = const Integration(
      id: 'contacts',
      name: 'Contacts',
      description: 'Access your device contacts for searching and reading',
      iconPath: 'assets/icons/contacts.png',
      type: IntegrationType.local,
      privacy: PrivacyLevel.onDevice,
      capabilities: ['search', 'read'],
    );

    _integrations['calendar'] = const Integration(
      id: 'calendar',
      name: 'Calendar',
      description: 'Read and create calendar events',
      iconPath: 'assets/icons/calendar.png',
      type: IntegrationType.local,
      privacy: PrivacyLevel.onDevice,
      capabilities: ['read', 'write', 'search'],
    );

    // OAuth integrations
    _integrations['google'] = const Integration(
      id: 'google',
      name: 'Google',
      description: 'Access Gmail, Calendar, Drive, and other Google services',
      iconPath: 'assets/icons/google.png',
      type: IntegrationType.oauth,
      privacy: PrivacyLevel.withConsent,
      capabilities: ['email', 'calendar', 'drive', 'search'],
    );

    _integrations['spotify'] = const Integration(
      id: 'spotify',
      name: 'Spotify',
      description: 'Control playback and access your music library',
      iconPath: 'assets/icons/spotify.png',
      type: IntegrationType.oauth,
      privacy: PrivacyLevel.lowRisk,
      capabilities: ['playback', 'search', 'playlists'],
    );

    _integrations['github'] = const Integration(
      id: 'github',
      name: 'GitHub',
      description: 'Access repositories, issues, and pull requests',
      iconPath: 'assets/icons/github.png',
      type: IntegrationType.oauth,
      privacy: PrivacyLevel.withConsent,
      capabilities: ['read', 'write', 'search'],
    );
  }

  /// Get all integrations grouped by type
  Map<IntegrationType, List<Integration>> get integrationsByType {
    final grouped = <IntegrationType, List<Integration>>{};

    for (final type in IntegrationType.values) {
      grouped[type] = _integrations.values
          .where((integration) => integration.type == type)
          .toList();
    }

    return grouped;
  }

  /// Get all integrations
  List<Integration> get allIntegrations => _integrations.values.toList();

  /// Get connected integrations
  List<Integration> get connectedIntegrations =>
      _integrations.values.where((i) => i.isConnected).toList();

  /// Get integration by ID
  Integration? getIntegration(String id) {
    return _integrations[id];
  }

  /// Connect an integration
  ///
  /// For local integrations: requests device permissions
  /// For OAuth integrations: initiates OAuth flow
  ///
  /// Returns true if connection was successful.
  Future<bool> connect(String integrationId) async {
    final integration = _integrations[integrationId];
    if (integration == null) {
      throw IntegrationConnectionException(
        integrationId,
        'Integration not found',
      );
    }

    // Update status to connecting
    _updateIntegration(
      integrationId,
      integration.copyWith(status: IntegrationStatus.connecting),
    );

    try {
      switch (integration.type) {
        case IntegrationType.local:
          return await _connectLocal(integrationId);

        case IntegrationType.oauth:
          return await _connectOAuth(integrationId);

        case IntegrationType.apiKey:
          return await _connectApiKey(integrationId);
      }
    } catch (e) {
      _updateIntegration(
        integrationId,
        integration.copyWith(
          status: IntegrationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Disconnect an integration
  Future<void> disconnect(String integrationId) async {
    final integration = _integrations[integrationId];
    if (integration == null) return;

    // Remove OAuth tokens if applicable
    if (integration.type == IntegrationType.oauth) {
      await _removeTokens(integrationId);
    }

    // Unregister tools for this service
    _toolRegistry.unregisterServiceTools(integrationId);

    // Update status
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.disconnected,
        accountInfo: null,
        connectedAt: null,
        errorMessage: null,
      ),
    );

    await _saveIntegrations();
  }

  /// Check if a service is connected
  bool isConnected(String integrationId) {
    final integration = _integrations[integrationId];
    return integration?.isConnected ?? false;
  }

  /// Get OAuth tokens for a service (auto-refreshes if needed)
  Future<OAuthTokens?> getTokens(String service) async {
    final key = '$_tokensPrefix$service';
    final tokensJson = await _secureStorage.read(key);

    if (tokensJson == null) return null;

    final tokens = OAuthTokens.fromJson(
      jsonDecode(tokensJson) as Map<String, dynamic>,
    );

    // Auto-refresh if needed
    if (tokens.needsRefresh && tokens.canRefresh) {
      return await _refreshTokens(tokens);
    }

    return tokens;
  }

  /// Store OAuth tokens
  Future<void> storeTokens(String service, OAuthTokens tokens) async {
    final key = '$_tokensPrefix$service';
    final tokensJson = jsonEncode(tokens.toJson());
    await _secureStorage.write(key, tokensJson);
  }

  /// Remove OAuth tokens
  Future<void> _removeTokens(String service) async {
    final key = '$_tokensPrefix$service';
    await _secureStorage.delete(key);
  }

  /// Refresh OAuth tokens
  Future<OAuthTokens> _refreshTokens(OAuthTokens tokens) async {
    // This is a placeholder - actual implementation would call the OAuth provider
    // For now, throw an exception to be implemented by service-specific handlers
    throw TokenRefreshException(
      tokens.service,
      'Token refresh not implemented for ${tokens.service}',
    );
  }

  /// Connect a local integration (request device permissions)
  Future<bool> _connectLocal(String integrationId) async {
    // This is a placeholder - actual implementation would request permissions
    // using platform-specific APIs (e.g., contacts_service, permission_handler)

    final integration = _integrations[integrationId]!;

    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, automatically grant (would check actual permissions in real app)
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.connected,
        connectedAt: DateTime.now(),
        accountInfo: 'Device',
      ),
    );

    await _saveIntegrations();
    return true;
  }

  /// Connect an OAuth integration
  Future<bool> _connectOAuth(String integrationId) async {
    // This is a placeholder - actual implementation would:
    // 1. Open OAuth URL in browser/webview
    // 2. Handle redirect callback
    // 3. Exchange code for tokens
    // 4. Store tokens

    final integration = _integrations[integrationId]!;

    // For now, simulate OAuth flow
    await Future.delayed(const Duration(seconds: 1));

    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.error,
        errorMessage: 'OAuth flow not yet implemented',
      ),
    );

    await _saveIntegrations();
    return false;
  }

  /// Connect an API key integration
  Future<bool> _connectApiKey(String integrationId) async {
    // This is a placeholder - would prompt user for API key
    final integration = _integrations[integrationId]!;

    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.error,
        errorMessage: 'API key flow not yet implemented',
      ),
    );

    await _saveIntegrations();
    return false;
  }

  /// Update an integration and notify listeners
  void _updateIntegration(String id, Integration integration) {
    _integrations[id] = integration;
    _statusChangesController.add(integration);
  }

  /// Load integrations from storage
  Future<void> _loadIntegrations() async {
    final integrationsJson = await _secureStorage.read(_integrationsKey);

    if (integrationsJson == null) return;

    final List<dynamic> integrationsList = jsonDecode(integrationsJson);
    for (final json in integrationsList) {
      final integration = Integration.fromJson(json as Map<String, dynamic>);
      _integrations[integration.id] = integration;
    }
  }

  /// Save integrations to storage
  Future<void> _saveIntegrations() async {
    final integrationsList =
        _integrations.values.map((i) => i.toJson()).toList();
    final integrationsJson = jsonEncode(integrationsList);
    await _secureStorage.write(_integrationsKey, integrationsJson);
  }

  /// Restore OAuth connection states on app start
  Future<void> _restoreOAuthConnections() async {
    for (final integration in _integrations.values) {
      if (integration.type == IntegrationType.oauth &&
          integration.isConnected) {
        // Check if tokens still exist and are valid
        final tokens = await getTokens(integration.id);

        if (tokens == null || (tokens.isExpired && !tokens.canRefresh)) {
          // Tokens are invalid, mark as disconnected
          _updateIntegration(
            integration.id,
            integration.copyWith(
              status: IntegrationStatus.disconnected,
              accountInfo: null,
              errorMessage: 'Session expired',
            ),
          );
        }
      }
    }

    await _saveIntegrations();
  }

  /// Dispose of resources
  void dispose() {
    _statusChangesController.close();
  }
}

/// Riverpod provider for integration manager
final integrationManagerProvider = Provider<IntegrationManager>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final toolRegistry = ref.watch(toolRegistryProvider);

  final manager = IntegrationManager(
    secureStorage: secureStorage,
    toolRegistry: toolRegistry,
  );

  // Initialize on first access
  manager.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});

/// Provider for all integrations
final integrationsProvider = StreamProvider<List<Integration>>((ref) {
  final manager = ref.watch(integrationManagerProvider);

  return Stream.value(manager.allIntegrations).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in manager.statusChanges) {
      yield manager.allIntegrations;
    }
  });
});

/// Provider for connected integrations
final connectedIntegrationsProvider = StreamProvider<List<Integration>>((ref) {
  final manager = ref.watch(integrationManagerProvider);

  return Stream.value(manager.connectedIntegrations)
      .asyncExpand((initial) async* {
    yield initial;
    await for (final _ in manager.statusChanges) {
      yield manager.connectedIntegrations;
    }
  });
});

/// Provider for integrations grouped by type
final integrationsByTypeProvider =
    StreamProvider<Map<IntegrationType, List<Integration>>>((ref) {
  final manager = ref.watch(integrationManagerProvider);

  return Stream.value(manager.integrationsByType).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in manager.statusChanges) {
      yield manager.integrationsByType;
    }
  });
});

/// Provider for a specific integration
final integrationProvider =
    StreamProvider.family<Integration?, String>((ref, id) {
  final manager = ref.watch(integrationManagerProvider);

  return Stream.value(manager.getIntegration(id)).asyncExpand((initial) async* {
    yield initial;
    await for (final update in manager.statusChanges) {
      if (update.id == id) {
        yield update;
      }
    }
  });
});
