import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/secure_storage.dart';
import '../models/oauth_tokens.dart';
import 'oauth_config.dart';

/// Exception thrown when OAuth authentication fails
class OAuthAuthenticationException implements Exception {
  final String providerId;
  final String message;
  final dynamic originalError;

  OAuthAuthenticationException(
    this.providerId,
    this.message, [
    this.originalError,
  ]);

  @override
  String toString() =>
      'OAuth authentication failed [$providerId]: $message';
}

/// Exception thrown when token refresh fails
class OAuthTokenRefreshException implements Exception {
  final String providerId;
  final String message;
  final dynamic originalError;

  OAuthTokenRefreshException(
    this.providerId,
    this.message, [
    this.originalError,
  ]);

  @override
  String toString() => 'Token refresh failed [$providerId]: $message';
}

/// Service for handling OAuth 2.0 authentication flows
///
/// Manages the complete OAuth lifecycle including:
/// - Initial authentication with PKCE support
/// - Token storage and retrieval
/// - Automatic token refresh
/// - Token revocation and logout
///
/// Uses flutter_appauth for secure OAuth flows with native browser/webview.
class OAuthService {
  final SecureStorage _secureStorage;
  final FlutterAppAuth _appAuth;
  final Dio _dio;

  static const String _tokensPrefix = 'oauth_tokens_';

  OAuthService({
    required SecureStorage secureStorage,
    FlutterAppAuth? appAuth,
    Dio? dio,
  })  : _secureStorage = secureStorage,
        _appAuth = appAuth ?? const FlutterAppAuth(),
        _dio = dio ?? Dio();

  /// Start OAuth authentication flow for a provider
  ///
  /// Opens the provider's authorization page in a browser/webview,
  /// handles the callback, and exchanges the authorization code for tokens.
  ///
  /// Uses PKCE (Proof Key for Code Exchange) when [config.usePKCE] is true
  /// for enhanced security on mobile devices.
  ///
  /// [config] - OAuth provider configuration
  ///
  /// Returns [OAuthTokens] on success, null if user cancels.
  /// Throws [OAuthAuthenticationException] on failure.
  Future<OAuthTokens?> authenticate(OAuthConfig config) async {
    try {
      // Prepare authorization request
      final request = AuthorizationTokenRequest(
        config.clientId,
        config.redirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: config.authorizationUrl,
          tokenEndpoint: config.tokenUrl,
          endSessionEndpoint: config.revocationUrl,
        ),
        scopes: config.scopes,
        clientSecret: config.clientSecret,
        // Additional parameters (e.g., access_type=offline for Google)
        additionalParameters: config.additionalParameters,
        // Use PKCE if specified
        promptValues: config.prompt != null ? [config.prompt!] : null,
      );

      // Perform authorization and token exchange
      final result = await _appAuth.authorizeAndExchangeCode(request);

      // Convert response to OAuthTokens
      final tokens = OAuthTokens.fromOAuthResponse(
        {
          'access_token': result.accessToken!,
          if (result.refreshToken != null)
            'refresh_token': result.refreshToken,
          'expires_in': result.accessTokenExpirationDateTime != null
              ? result.accessTokenExpirationDateTime!
                  .difference(DateTime.now())
                  .inSeconds
              : 3600,
          if (result.tokenType != null) 'token_type': result.tokenType,
          if (result.idToken != null) 'id_token': result.idToken,
          'scope': result.scopes?.join(' ') ?? config.scopes.join(' '),
        },
        config.providerId,
      );

      // Store tokens securely
      await _storeTokens(config.providerId, tokens);

      return tokens;
    } on PlatformException catch (e) {
      // User cancelled or platform error
      if (e.code == 'CANCELED' || e.code == 'USER_CANCELLED_LOGIN') {
        return null;
      }

      throw OAuthAuthenticationException(
        config.providerId,
        e.message ?? 'Platform error during authentication',
        e,
      );
    } catch (e) {
      throw OAuthAuthenticationException(
        config.providerId,
        'Failed to complete OAuth flow',
        e,
      );
    }
  }

  /// Refresh an expired access token
  ///
  /// Uses the refresh token to obtain a new access token from the provider.
  /// The new tokens are automatically stored.
  ///
  /// [config] - OAuth provider configuration
  /// [refreshToken] - The refresh token to use
  ///
  /// Returns new [OAuthTokens] on success.
  /// Throws [OAuthTokenRefreshException] on failure.
  Future<OAuthTokens?> refreshToken(
    OAuthConfig config,
    String refreshToken,
  ) async {
    try {
      // Use flutter_appauth for standard providers
      if (config.usePKCE) {
        final response = await _appAuth.token(
          TokenRequest(
            config.clientId,
            config.redirectUri,
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: config.authorizationUrl,
              tokenEndpoint: config.tokenUrl,
              endSessionEndpoint: config.revocationUrl,
            ),
            refreshToken: refreshToken,
            clientSecret: config.clientSecret,
          ),
        );

        final tokens = OAuthTokens.fromOAuthResponse(
          {
            'access_token': response.accessToken!,
            if (response.refreshToken != null)
              'refresh_token': response.refreshToken,
            'expires_in': response.accessTokenExpirationDateTime != null
                ? response.accessTokenExpirationDateTime!
                    .difference(DateTime.now())
                    .inSeconds
                : 3600,
            if (response.tokenType != null) 'token_type': response.tokenType,
            if (response.idToken != null) 'id_token': response.idToken,
            'scope': response.scopes?.join(' ') ?? config.scopes.join(' '),
          },
          config.providerId,
        );

        await _storeTokens(config.providerId, tokens);
        return tokens;
      } else {
        // Manual token refresh for providers that don't support PKCE (like GitHub)
        return await _manualTokenRefresh(config, refreshToken);
      }
    } on PlatformException catch (e) {
      throw OAuthTokenRefreshException(
        config.providerId,
        e.message ?? 'Platform error during token refresh',
        e,
      );
    } catch (e) {
      throw OAuthTokenRefreshException(
        config.providerId,
        'Failed to refresh token',
        e,
      );
    }
  }

  /// Manually refresh token using HTTP request
  ///
  /// Used for providers that don't support PKCE or have custom refresh flows.
  Future<OAuthTokens?> _manualTokenRefresh(
    OAuthConfig config,
    String refreshToken,
  ) async {
    try {
      final response = await _dio.post(
        config.tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': config.clientId,
          if (config.clientSecret != null) 'client_secret': config.clientSecret,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final tokens = OAuthTokens.fromOAuthResponse(
        response.data as Map<String, dynamic>,
        config.providerId,
      );

      await _storeTokens(config.providerId, tokens);
      return tokens;
    } on DioException catch (e) {
      throw OAuthTokenRefreshException(
        config.providerId,
        'HTTP error during token refresh: ${e.response?.statusCode}',
        e,
      );
    }
  }

  /// Get stored tokens for a provider (auto-refresh if needed)
  ///
  /// Retrieves tokens from secure storage and automatically refreshes
  /// them if they are expired or about to expire.
  ///
  /// [providerId] - The provider identifier (e.g., "spotify", "github")
  /// [config] - Optional config for auto-refresh. Required if auto-refresh is needed.
  ///
  /// Returns [OAuthTokens] if valid tokens exist, null otherwise.
  Future<OAuthTokens?> getTokens(
    String providerId, {
    OAuthConfig? config,
  }) async {
    final key = '$_tokensPrefix$providerId';
    final tokensJson = await _secureStorage.read(key);

    if (tokensJson == null) return null;

    try {
      final tokens = OAuthTokens.fromJson(
        jsonDecode(tokensJson) as Map<String, dynamic>,
      );

      // Check if tokens need refresh
      if (tokens.needsRefresh && tokens.canRefresh) {
        if (config == null) {
          // Can't refresh without config, return expired tokens
          return tokens;
        }

        // Auto-refresh tokens
        try {
          return await refreshToken(config, tokens.refreshToken!);
        } catch (e) {
          // Refresh failed, return expired tokens
          // Caller should handle re-authentication
          return tokens;
        }
      }

      return tokens;
    } catch (e) {
      // Invalid token format, delete and return null
      await _secureStorage.delete(key);
      return null;
    }
  }

  /// Revoke tokens and clear storage
  ///
  /// Calls the provider's revocation endpoint (if available) to invalidate
  /// the tokens, then removes them from local storage.
  ///
  /// [providerId] - The provider identifier
  /// [config] - Optional config with revocation endpoint
  Future<void> logout(String providerId, {OAuthConfig? config}) async {
    // Get current tokens
    final tokens = await getTokens(providerId);

    // Attempt to revoke token at provider if endpoint is available
    if (tokens != null && config?.revocationUrl != null) {
      try {
        await _revokeToken(
          config!.revocationUrl!,
          tokens.accessToken,
          config.clientId,
          config.clientSecret,
        );
      } catch (e) {
        // Log error but continue with local cleanup
        // Revocation failure shouldn't prevent local logout
      }
    }

    // Clear from secure storage
    final key = '$_tokensPrefix$providerId';
    await _secureStorage.delete(key);
  }

  /// Revoke a token at the provider's revocation endpoint
  Future<void> _revokeToken(
    String revocationUrl,
    String token,
    String clientId,
    String? clientSecret,
  ) async {
    try {
      await _dio.post(
        revocationUrl,
        data: {
          'token': token,
          'client_id': clientId,
          if (clientSecret != null) 'client_secret': clientSecret,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
    } on DioException catch (e) {
      // Some providers return 200 OK even if token is already invalid
      if (e.response?.statusCode != 200) {
        rethrow;
      }
    }
  }

  /// Check if user is authenticated with a provider
  ///
  /// Returns true if valid (non-expired) tokens exist for the provider.
  ///
  /// [providerId] - The provider identifier
  /// [config] - Optional config for auto-refresh check
  Future<bool> isAuthenticated(
    String providerId, {
    OAuthConfig? config,
  }) async {
    final tokens = await getTokens(providerId, config: config);
    return tokens != null && !tokens.isExpired;
  }

  /// Store tokens securely
  Future<void> _storeTokens(String providerId, OAuthTokens tokens) async {
    final key = '$_tokensPrefix$providerId';
    final tokensJson = jsonEncode(tokens.toJson());
    await _secureStorage.write(key, tokensJson);
  }

  /// Clear all OAuth tokens from storage
  ///
  /// Useful for complete app logout or data reset.
  Future<void> clearAllTokens() async {
    final allData = await _secureStorage.readAll();
    for (final key in allData.keys) {
      if (key.startsWith(_tokensPrefix)) {
        await _secureStorage.delete(key);
      }
    }
  }

  /// Get all provider IDs that have stored tokens
  Future<List<String>> getAuthenticatedProviders() async {
    final allData = await _secureStorage.readAll();
    return allData.keys
        .where((key) => key.startsWith(_tokensPrefix))
        .map((key) => key.substring(_tokensPrefix.length))
        .toList();
  }
}

/// Riverpod provider for OAuthService
final oauthServiceProvider = Provider<OAuthService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return OAuthService(secureStorage: secureStorage);
});
