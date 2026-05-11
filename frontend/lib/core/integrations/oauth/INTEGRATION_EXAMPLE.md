# Integrating OAuth Service with IntegrationManager

This guide shows how to use the OAuth service with the existing IntegrationManager to handle OAuth-based integrations.

## Overview

The OAuth service is designed to work seamlessly with IntegrationManager. The IntegrationManager already has placeholders for OAuth flows - we'll replace those with the real OAuth implementation.

## Step 1: Update IntegrationManager

Replace the placeholder `_connectOAuth` method in `integration_manager.dart`:

```dart
/// Connect an OAuth integration
Future<bool> _connectOAuth(String integrationId) async {
  final integration = _integrations[integrationId]!;

  // Get OAuth configuration for this provider
  final config = _getOAuthConfig(integrationId);
  if (config == null) {
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.error,
        errorMessage: 'OAuth configuration not found',
      ),
    );
    return false;
  }

  try {
    // Use OAuthService to authenticate
    final oauthService = OAuthService(secureStorage: _secureStorage);
    final tokens = await oauthService.authenticate(config);

    if (tokens == null) {
      // User cancelled
      _updateIntegration(
        integrationId,
        integration.copyWith(
          status: IntegrationStatus.disconnected,
        ),
      );
      return false;
    }

    // Get account info from tokens if available
    final accountInfo = await _getAccountInfo(integrationId, tokens);

    // Update integration status
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.connected,
        connectedAt: DateTime.now(),
        accountInfo: accountInfo,
      ),
    );

    // Register tools for this service
    await _registerServiceTools(integrationId);

    await _saveIntegrations();
    return true;
  } on OAuthAuthenticationException catch (e) {
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.error,
        errorMessage: e.message,
      ),
    );
    return false;
  } catch (e) {
    _updateIntegration(
      integrationId,
      integration.copyWith(
        status: IntegrationStatus.error,
        errorMessage: 'Failed to authenticate: $e',
      ),
    );
    return false;
  }
}

/// Get OAuth configuration for a provider
OAuthConfig? _getOAuthConfig(String integrationId) {
  // Load client IDs from environment or config
  // In production, these should come from secure config/environment variables
  switch (integrationId) {
    case 'spotify':
      return OAuthConfig.spotify(
        clientId: const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
        scopes: [
          'user-read-playback-state',
          'user-modify-playback-state',
          'playlist-read-private',
          'playlist-modify-public',
          'user-library-read',
        ],
      );

    case 'github':
      return OAuthConfig.github(
        clientId: const String.fromEnvironment('GITHUB_CLIENT_ID'),
        clientSecret: const String.fromEnvironment('GITHUB_CLIENT_SECRET'),
        scopes: ['repo', 'user', 'gist'],
      );

    case 'google':
      return OAuthConfig.google(
        clientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
        scopes: [
          'https://www.googleapis.com/auth/gmail.readonly',
          'https://www.googleapis.com/auth/calendar.events',
          'https://www.googleapis.com/auth/userinfo.email',
        ],
      );

    default:
      return null;
  }
}

/// Get account information from tokens (optional)
Future<String?> _getAccountInfo(String integrationId, OAuthTokens tokens) async {
  // This could make an API call to get user info
  // For now, just return the service name
  return integrationId;
}

/// Register tools for this service
Future<void> _registerServiceTools(String integrationId) async {
  // This would register service-specific tools with the ToolRegistry
  // Implementation depends on your tool registry design
}
```

## Step 2: Update Token Refresh

Replace the `_refreshTokens` method:

```dart
/// Refresh OAuth tokens
@override
Future<OAuthTokens> _refreshTokens(OAuthTokens tokens) async {
  final config = _getOAuthConfig(tokens.service);
  if (config == null) {
    throw TokenRefreshException(
      tokens.service,
      'OAuth configuration not found',
    );
  }

  if (!tokens.canRefresh) {
    throw TokenRefreshException(
      tokens.service,
      'No refresh token available',
    );
  }

  try {
    final oauthService = OAuthService(secureStorage: _secureStorage);
    final refreshedTokens = await oauthService.refreshToken(
      config,
      tokens.refreshToken!,
    );

    if (refreshedTokens == null) {
      throw TokenRefreshException(
        tokens.service,
        'Token refresh returned null',
      );
    }

    return refreshedTokens;
  } on OAuthTokenRefreshException catch (e) {
    throw TokenRefreshException(tokens.service, e.message);
  }
}
```

## Step 3: Add OAuth Import

At the top of `integration_manager.dart`:

```dart
import 'oauth/oauth.dart';
```

## Step 4: Environment Configuration

Create a `.env` file (or use build-time configuration):

```env
# Spotify
SPOTIFY_CLIENT_ID=your_spotify_client_id

# GitHub
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Google
GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
```

## Step 5: Using in UI

Now you can use IntegrationManager as before, and OAuth will work automatically:

```dart
class IntegrationConnectionButton extends ConsumerWidget {
  final String integrationId;

  const IntegrationConnectionButton({required this.integrationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(integrationManagerProvider);
    final integration = manager.getIntegration(integrationId);

    if (integration == null) return SizedBox.shrink();

    return ElevatedButton(
      onPressed: integration.isConnected
        ? () => manager.disconnect(integrationId)
        : () => manager.connect(integrationId),
      child: Text(
        integration.isConnected ? 'Disconnect' : 'Connect',
      ),
    );
  }
}
```

## Alternative: Using OAuth Directly in UI

For more control over the OAuth flow UI, you can use OAuthFlowNotifier directly:

```dart
class SpotifyConnectPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
    final flowStatus = ref.watch(oauthFlowNotifierProvider);
    final integrationManager = ref.watch(integrationManagerProvider);

    // Listen to flow completion
    ref.listen(oauthFlowNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        // Update IntegrationManager
        _updateIntegrationStatus(
          integrationManager,
          'spotify',
          next.tokens!,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to Spotify!')),
        );

        flowNotifier.reset();
      } else if (next.hasError) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}')),
        );

        flowNotifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Connect Spotify')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (flowStatus.isInProgress)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  final config = OAuthConfig.spotify(
                    clientId: 'your-client-id',
                    scopes: ['user-read-playback-state'],
                  );

                  flowNotifier.startFlow(config);
                },
                child: Text('Connect Spotify'),
              ),

            if (flowStatus.state == OAuthFlowState.waitingForAuth)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Please complete authentication in browser'),
              ),
          ],
        ),
      ),
    );
  }

  void _updateIntegrationStatus(
    IntegrationManager manager,
    String integrationId,
    OAuthTokens tokens,
  ) {
    // This would call a method in IntegrationManager to update status
    // You might need to add a public method for this
  }
}
```

## Benefits of This Approach

1. **Separation of Concerns**: OAuth logic is separate from integration management
2. **Reusability**: OAuth service can be used independently
3. **Testability**: Easy to mock OAuthService in tests
4. **Flexibility**: Can use OAuth directly in UI when needed
5. **Security**: Tokens are handled securely throughout

## Next Steps

1. Add OAuth client IDs to your build configuration
2. Configure platform URL schemes (iOS/Android)
3. Test OAuth flow with each provider
4. Add error recovery UI
5. Implement token refresh monitoring
6. Add analytics/logging for OAuth events
