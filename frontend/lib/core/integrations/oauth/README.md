# OAuth 2.0 Service for Jarvis

A complete, reusable OAuth 2.0 implementation for Flutter mobile apps with PKCE support, automatic token refresh, and secure storage.

## Features

- **PKCE Support**: Enhanced security for mobile OAuth flows
- **Automatic Token Refresh**: Tokens are refreshed automatically before expiration
- **Secure Storage**: Tokens stored in platform-specific secure storage (Keychain/Keystore)
- **Pre-configured Providers**: Spotify, GitHub, Google, Microsoft ready to use
- **State Management**: Riverpod-based state management for flow tracking
- **Error Handling**: Comprehensive error handling with custom exceptions

## Quick Start

### 1. Platform Configuration

#### iOS (Info.plist)

Add URL scheme for OAuth callbacks:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.jarvis</string>
    </array>
  </dict>
</array>
```

#### Android (AndroidManifest.xml)

Add intent filter for OAuth callbacks:

```xml
<activity android:name="com.linusu.flutter_web_auth_2.CallbackActivity">
  <intent-filter android:label="flutter_web_auth">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.jarvis" />
  </intent-filter>
</activity>
```

### 2. Basic Usage

```dart
import 'package:jarvis/core/integrations/oauth/oauth.dart';

// Configure provider
final spotifyConfig = OAuthConfig.spotify(
  clientId: 'your-spotify-client-id',
  scopes: [
    'user-read-playback-state',
    'user-modify-playback-state',
    'playlist-read-private',
  ],
);

// In your widget
class SpotifyAuthButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
    final flowStatus = ref.watch(oauthFlowNotifierProvider);

    return ElevatedButton(
      onPressed: flowStatus.isInProgress ? null : () async {
        final success = await flowNotifier.startFlow(spotifyConfig);

        if (success) {
          // Authentication successful!
          final tokens = flowStatus.tokens;
          print('Access token: ${tokens?.accessToken}');
        } else if (flowStatus.wasCancelled) {
          // User cancelled
          print('User cancelled authentication');
        } else if (flowStatus.hasError) {
          // Error occurred
          print('Error: ${flowStatus.errorMessage}');
        }

        // Reset state after handling
        flowNotifier.reset();
      },
      child: flowStatus.isInProgress
        ? CircularProgressIndicator()
        : Text('Connect Spotify'),
    );
  }
}
```

### 3. Check Authentication Status

```dart
final isAuthenticated = await ref.watch(
  isAuthenticatedProvider((
    providerId: 'spotify',
    config: spotifyConfig,
  )),
);

if (isAuthenticated) {
  // User is authenticated
}
```

### 4. Get Tokens (Auto-refresh)

```dart
final tokens = await ref.watch(
  tokensProvider((
    providerId: 'spotify',
    config: spotifyConfig,
  )),
);

if (tokens != null) {
  // Use tokens for API calls
  final authHeader = tokens.authorizationHeader; // "Bearer <token>"
}
```

### 5. Logout

```dart
final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
await flowNotifier.logout('spotify', config: spotifyConfig);
```

## Provider Configurations

### Spotify

```dart
final config = OAuthConfig.spotify(
  clientId: 'your-client-id',
  scopes: [
    'user-read-playback-state',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    'user-library-read',
    'user-library-modify',
  ],
);
```

**Setup**: Create app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
- Add `com.jarvis://oauth` as redirect URI

### GitHub

```dart
final config = OAuthConfig.github(
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret',
  scopes: [
    'repo',
    'user',
    'gist',
    'notifications',
  ],
);
```

**Setup**: Create app at [GitHub Developer Settings](https://github.com/settings/developers)
- Add `com.jarvis://oauth` as Authorization callback URL
- GitHub requires client secret (no PKCE)

### Google

```dart
final config = OAuthConfig.google(
  clientId: 'your-client-id.apps.googleusercontent.com',
  scopes: [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
  forceConsent: true, // Force user to grant consent
);
```

**Setup**: Create OAuth 2.0 Client at [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
- Application type: iOS or Android
- Add bundle ID (iOS) or package name (Android)
- Add `com.jarvis://oauth` as redirect URI for development

### Microsoft

```dart
final config = OAuthConfig.microsoft(
  clientId: 'your-client-id',
  scopes: [
    'User.Read',
    'Mail.Read',
    'Mail.Send',
    'Calendars.ReadWrite',
    'offline_access', // Required for refresh token
  ],
  tenant: 'common', // or your organization tenant ID
);
```

**Setup**: Register app at [Azure Portal](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps)
- Add mobile/desktop redirect URI: `com.jarvis://oauth`

## Custom Provider

```dart
final customConfig = OAuthConfig(
  providerId: 'custom',
  authorizationUrl: 'https://provider.com/oauth/authorize',
  tokenUrl: 'https://provider.com/oauth/token',
  revocationUrl: 'https://provider.com/oauth/revoke',
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret', // Optional for PKCE
  redirectUri: 'com.jarvis://oauth',
  scopes: ['read', 'write'],
  usePKCE: true,
  additionalParameters: {
    'custom_param': 'value',
  },
);
```

## Advanced Usage

### Using OAuthService Directly

```dart
final oauthService = ref.watch(oauthServiceProvider);

// Authenticate
final tokens = await oauthService.authenticate(config);

// Refresh tokens
final refreshedTokens = await oauthService.refreshToken(
  config,
  oldTokens.refreshToken!,
);

// Check authentication
final isAuth = await oauthService.isAuthenticated('spotify');

// Get tokens without auto-refresh
final tokens = await oauthService.getTokens('spotify');

// Logout
await oauthService.logout('spotify', config: config);

// Clear all tokens
await oauthService.clearAllTokens();

// Get all authenticated providers
final providers = await oauthService.getAuthenticatedProviders();
```

### Monitoring Flow State

```dart
class OAuthFlowMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowStatus = ref.watch(oauthFlowNotifierProvider);

    return switch (flowStatus.state) {
      OAuthFlowState.idle => Text('Ready to authenticate'),
      OAuthFlowState.launching => Text('Opening browser...'),
      OAuthFlowState.waitingForAuth => Text('Waiting for authentication...'),
      OAuthFlowState.exchangingCode => Text('Exchanging code for tokens...'),
      OAuthFlowState.success => Text('Success! ${flowStatus.tokens?.service}'),
      OAuthFlowState.error => Text('Error: ${flowStatus.errorMessage}'),
      OAuthFlowState.cancelled => Text('Authentication cancelled'),
    };
  }
}
```

### Manual Token Refresh

```dart
final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);

final tokens = await ref.watch(
  tokensProvider((providerId: 'spotify', config: null)),
);

if (tokens?.needsRefresh ?? false) {
  final success = await flowNotifier.refresh(
    spotifyConfig,
    tokens!.refreshToken!,
  );

  if (success) {
    final newTokens = flowNotifier.state.tokens;
  }
}
```

## Error Handling

```dart
try {
  final success = await flowNotifier.startFlow(config);

  if (!success) {
    if (flowStatus.hasError) {
      // Handle specific errors
      if (flowStatus.originalError is OAuthAuthenticationException) {
        final error = flowStatus.originalError as OAuthAuthenticationException;
        print('OAuth error: ${error.message}');
      }
    }
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

## Token Expiration

Tokens are automatically refreshed when:
- Calling `getTokens()` with a config parameter
- Using the `tokensProvider` with a config parameter
- Token is within 5 minutes of expiration

Manual refresh is needed only for custom flows.

## Security Best Practices

1. **Use PKCE**: Always use PKCE for mobile apps (`usePKCE: true`)
2. **Secure Storage**: Tokens are automatically stored in platform keychain/keystore
3. **HTTPS Only**: All OAuth endpoints must use HTTPS
4. **Client Secrets**: Don't hardcode client secrets - use build-time environment variables
5. **Scope Minimization**: Request only the scopes you need
6. **Token Revocation**: Always revoke tokens on logout

## Testing

For testing, you can mock the OAuthService:

```dart
class MockOAuthService extends OAuthService {
  @override
  Future<OAuthTokens?> authenticate(OAuthConfig config) async {
    return OAuthTokens(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresAt: DateTime.now().add(Duration(hours: 1)),
      service: config.providerId,
      scopes: config.scopes,
    );
  }
}

// In tests
final container = ProviderContainer(
  overrides: [
    oauthServiceProvider.overrideWithValue(MockOAuthService()),
  ],
);
```

## Troubleshooting

### "Invalid redirect URI"
- Ensure URL scheme is registered in platform manifests
- Verify redirect URI matches exactly in OAuth app settings
- Check for typos (e.g., `com.jarvis` vs `jarvis.com`)

### "User cancelled authentication" always shown
- Check if browser/webview is opening correctly
- Verify app can handle custom URL schemes
- Test with a simple HTTP redirect first

### Tokens not persisting
- Check SecureStorage permissions
- Verify device supports secure storage
- Check for storage quota limits

### Auto-refresh not working
- Ensure config is passed to `getTokens()` or `tokensProvider`
- Verify refresh token exists (`tokens.canRefresh`)
- Check provider supports refresh tokens

## Architecture

```
oauth/
├── oauth_config.dart     # Provider configurations
├── oauth_service.dart    # Core OAuth logic
├── oauth_state.dart      # State management
└── oauth.dart            # Barrel file + docs
```

## Dependencies

- `flutter_appauth`: Native OAuth with PKCE
- `flutter_secure_storage`: Secure token storage
- `dio`: HTTP client for token refresh
- `flutter_riverpod`: State management

## License

Part of the Jarvis project.
