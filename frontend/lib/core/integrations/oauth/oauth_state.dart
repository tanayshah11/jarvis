import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oauth_tokens.dart';
import 'oauth_config.dart';
import 'oauth_service.dart';

/// State of an OAuth authentication flow
///
/// Represents the different stages of the OAuth process:
/// - idle: No authentication in progress
/// - launching: Opening authorization URL
/// - waitingForAuth: User is authenticating with provider
/// - exchangingCode: Got authorization code, exchanging for tokens
/// - success: Authentication completed successfully
/// - error: Authentication failed
/// - cancelled: User cancelled the flow
enum OAuthFlowState {
  /// No authentication flow in progress
  idle,

  /// Opening browser/webview with authorization URL
  launching,

  /// User is authenticating with the OAuth provider
  ///
  /// User is viewing the provider's login/consent screen.
  waitingForAuth,

  /// Exchanging authorization code for access tokens
  ///
  /// Code received, calling token endpoint.
  exchangingCode,

  /// Authentication completed successfully
  success,

  /// Authentication failed with error
  error,

  /// User cancelled the authentication flow
  cancelled,
}

/// Status of an OAuth authentication flow
///
/// Contains the current state, any error message, and resulting tokens.
class OAuthFlowStatus {
  /// Current state of the OAuth flow
  final OAuthFlowState state;

  /// Error message if state is [OAuthFlowState.error]
  final String? errorMessage;

  /// Original error object for debugging
  final dynamic originalError;

  /// Tokens obtained if state is [OAuthFlowState.success]
  final OAuthTokens? tokens;

  /// Provider ID being authenticated
  final String? providerId;

  const OAuthFlowStatus({
    required this.state,
    this.errorMessage,
    this.originalError,
    this.tokens,
    this.providerId,
  });

  /// Create idle status
  factory OAuthFlowStatus.idle() {
    return const OAuthFlowStatus(state: OAuthFlowState.idle);
  }

  /// Create launching status
  factory OAuthFlowStatus.launching(String providerId) {
    return OAuthFlowStatus(
      state: OAuthFlowState.launching,
      providerId: providerId,
    );
  }

  /// Create waiting status
  factory OAuthFlowStatus.waitingForAuth(String providerId) {
    return OAuthFlowStatus(
      state: OAuthFlowState.waitingForAuth,
      providerId: providerId,
    );
  }

  /// Create exchanging status
  factory OAuthFlowStatus.exchangingCode(String providerId) {
    return OAuthFlowStatus(
      state: OAuthFlowState.exchangingCode,
      providerId: providerId,
    );
  }

  /// Create success status
  factory OAuthFlowStatus.success(OAuthTokens tokens) {
    return OAuthFlowStatus(
      state: OAuthFlowState.success,
      tokens: tokens,
      providerId: tokens.service,
    );
  }

  /// Create error status
  factory OAuthFlowStatus.error(
    String providerId,
    String message, [
    dynamic error,
  ]) {
    return OAuthFlowStatus(
      state: OAuthFlowState.error,
      errorMessage: message,
      originalError: error,
      providerId: providerId,
    );
  }

  /// Create cancelled status
  factory OAuthFlowStatus.cancelled(String providerId) {
    return OAuthFlowStatus(
      state: OAuthFlowState.cancelled,
      providerId: providerId,
    );
  }

  /// Whether the flow is in progress
  bool get isInProgress =>
      state == OAuthFlowState.launching ||
      state == OAuthFlowState.waitingForAuth ||
      state == OAuthFlowState.exchangingCode;

  /// Whether the flow completed successfully
  bool get isSuccess => state == OAuthFlowState.success;

  /// Whether the flow has an error
  bool get hasError => state == OAuthFlowState.error;

  /// Whether the flow was cancelled
  bool get wasCancelled => state == OAuthFlowState.cancelled;

  /// Whether the flow is finished (success, error, or cancelled)
  bool get isFinished =>
      state == OAuthFlowState.success ||
      state == OAuthFlowState.error ||
      state == OAuthFlowState.cancelled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OAuthFlowStatus &&
        other.state == state &&
        other.providerId == providerId;
  }

  @override
  int get hashCode => Object.hash(state, providerId);

  @override
  String toString() {
    return 'OAuthFlowStatus(state: $state, providerId: $providerId, '
        'errorMessage: $errorMessage)';
  }
}

/// Notifier for managing OAuth flow state
///
/// Handles the OAuth authentication process and provides real-time
/// state updates for UI. Only one flow can be active at a time.
class OAuthFlowNotifier extends Notifier<OAuthFlowStatus> {
  @override
  OAuthFlowStatus build() {
    return OAuthFlowStatus.idle();
  }

  /// Start an OAuth authentication flow
  ///
  /// Opens the provider's authorization page, handles the callback,
  /// and exchanges the code for tokens.
  ///
  /// [config] - OAuth provider configuration
  ///
  /// Returns true if authentication was successful, false otherwise.
  Future<bool> startFlow(OAuthConfig config) async {
    // Don't start new flow if one is already in progress
    if (state.isInProgress) {
      return false;
    }

    try {
      final oauthService = ref.read(oauthServiceProvider);

      // Update state: launching
      state = OAuthFlowStatus.launching(config.providerId);

      // Small delay to show launching state in UI
      await Future.delayed(const Duration(milliseconds: 200));

      // Update state: waiting for auth
      state = OAuthFlowStatus.waitingForAuth(config.providerId);

      // Perform OAuth flow
      final tokens = await oauthService.authenticate(config);

      if (tokens == null) {
        // User cancelled
        state = OAuthFlowStatus.cancelled(config.providerId);
        return false;
      }

      // Update state: success
      state = OAuthFlowStatus.success(tokens);
      return true;
    } on OAuthAuthenticationException catch (e) {
      state = OAuthFlowStatus.error(
        config.providerId,
        e.message,
        e.originalError,
      );
      return false;
    } catch (e) {
      state = OAuthFlowStatus.error(
        config.providerId,
        'Unexpected error during authentication',
        e,
      );
      return false;
    }
  }

  /// Refresh tokens for a provider
  ///
  /// Attempts to refresh expired tokens. Updates state on success or failure.
  ///
  /// [config] - OAuth provider configuration
  /// [refreshToken] - The refresh token to use
  Future<bool> refresh(OAuthConfig config, String refreshToken) async {
    try {
      final oauthService = ref.read(oauthServiceProvider);

      state = OAuthFlowStatus.exchangingCode(config.providerId);

      final tokens = await oauthService.refreshToken(config, refreshToken);

      if (tokens == null) {
        state = OAuthFlowStatus.error(
          config.providerId,
          'Token refresh returned null',
        );
        return false;
      }

      state = OAuthFlowStatus.success(tokens);
      return true;
    } on OAuthTokenRefreshException catch (e) {
      state = OAuthFlowStatus.error(
        config.providerId,
        e.message,
        e.originalError,
      );
      return false;
    } catch (e) {
      state = OAuthFlowStatus.error(
        config.providerId,
        'Unexpected error during token refresh',
        e,
      );
      return false;
    }
  }

  /// Logout from a provider
  ///
  /// Revokes tokens and clears local storage.
  ///
  /// [providerId] - Provider to logout from
  /// [config] - Optional config for token revocation
  Future<void> logout(String providerId, {OAuthConfig? config}) async {
    final oauthService = ref.read(oauthServiceProvider);
    await oauthService.logout(providerId, config: config);
    reset();
  }

  /// Reset flow state to idle
  ///
  /// Call this after handling success/error/cancelled states.
  void reset() {
    state = OAuthFlowStatus.idle();
  }

  /// Clear error state and return to idle
  void clearError() {
    if (state.hasError) {
      reset();
    }
  }
}

/// Provider for OAuth flow notifier
///
/// Use this to manage OAuth authentication flows in your UI.
///
/// Example:
/// ```dart
/// final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
/// final flowStatus = ref.watch(oauthFlowNotifierProvider);
///
/// // Start authentication
/// final success = await flowNotifier.startFlow(config);
/// ```
final oauthFlowNotifierProvider =
    NotifierProvider<OAuthFlowNotifier, OAuthFlowStatus>(
  OAuthFlowNotifier.new,
);

/// Provider for checking authentication status of a specific provider
///
/// Returns true if the user is authenticated (has valid tokens).
///
/// Example:
/// ```dart
/// final isSpotifyAuth = await ref.watch(
///   isAuthenticatedProvider((providerId: 'spotify', config: spotifyConfig)),
/// );
/// ```
final isAuthenticatedProvider = FutureProvider.family<bool, ({String providerId, OAuthConfig? config})>(
  (ref, params) async {
    final oauthService = ref.watch(oauthServiceProvider);
    return await oauthService.isAuthenticated(
      params.providerId,
      config: params.config,
    );
  },
);

/// Provider for getting tokens of a specific provider
///
/// Returns tokens if authenticated, null otherwise.
/// Automatically refreshes expired tokens if config is provided.
///
/// Example:
/// ```dart
/// final tokens = await ref.watch(
///   tokensProvider((providerId: 'spotify', config: spotifyConfig)),
/// );
/// ```
final tokensProvider = FutureProvider.family<OAuthTokens?, ({String providerId, OAuthConfig? config})>(
  (ref, params) async {
    final oauthService = ref.watch(oauthServiceProvider);
    return await oauthService.getTokens(
      params.providerId,
      config: params.config,
    );
  },
);

/// Provider for getting all authenticated provider IDs
///
/// Returns list of provider IDs that have stored tokens.
///
/// Example:
/// ```dart
/// final providers = await ref.watch(authenticatedProvidersProvider.future);
/// ```
final authenticatedProvidersProvider = FutureProvider<List<String>>((ref) async {
  final oauthService = ref.watch(oauthServiceProvider);
  return await oauthService.getAuthenticatedProviders();
});
