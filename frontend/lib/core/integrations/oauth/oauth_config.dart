/// OAuth 2.0 provider configuration
///
/// Contains all necessary information to perform OAuth authentication
/// with a specific provider. Supports both standard OAuth flows and
/// PKCE (Proof Key for Code Exchange) for enhanced mobile security.
class OAuthConfig {
  /// Unique provider identifier (e.g., "spotify", "github", "google")
  final String providerId;

  /// OAuth authorization endpoint URL
  ///
  /// User is redirected here to grant permissions.
  final String authorizationUrl;

  /// OAuth token endpoint URL
  ///
  /// Used to exchange authorization code for access tokens.
  final String tokenUrl;

  /// OAuth token revocation endpoint URL (optional)
  ///
  /// Used to revoke access tokens during logout.
  final String? revocationUrl;

  /// Client ID issued by the OAuth provider
  final String clientId;

  /// Client secret (optional)
  ///
  /// Not required for PKCE flows. Some providers (like Spotify)
  /// don't require client secrets for mobile apps.
  final String? clientSecret;

  /// Redirect URI for OAuth callback
  ///
  /// Must match the URI registered with the OAuth provider.
  /// Typically uses custom URL schemes like "com.jarvis://oauth".
  final String redirectUri;

  /// List of OAuth scopes to request
  ///
  /// Defines the permissions being requested from the user.
  final List<String> scopes;

  /// Whether to use PKCE (Proof Key for Code Exchange)
  ///
  /// Recommended for mobile applications. Adds an extra layer of security
  /// by generating a code verifier and challenge.
  final bool usePKCE;

  /// Additional parameters to include in authorization request
  ///
  /// Some providers require extra parameters (e.g., "access_type=offline").
  final Map<String, String>? additionalParameters;

  /// Prompt parameter for authorization request
  ///
  /// Controls whether the user is re-prompted for consent.
  /// Common values: "consent", "select_account", "none".
  final String? prompt;

  const OAuthConfig({
    required this.providerId,
    required this.authorizationUrl,
    required this.tokenUrl,
    this.revocationUrl,
    required this.clientId,
    this.clientSecret,
    required this.redirectUri,
    required this.scopes,
    this.usePKCE = true,
    this.additionalParameters,
    this.prompt,
  });

  /// Create configuration for Spotify OAuth
  ///
  /// Spotify supports PKCE and doesn't require a client secret for mobile apps.
  ///
  /// Common scopes:
  /// - user-read-playback-state: Read current playback state
  /// - user-modify-playback-state: Control playback
  /// - playlist-read-private: Access private playlists
  /// - playlist-modify-public: Modify public playlists
  /// - playlist-modify-private: Modify private playlists
  /// - user-library-read: Access saved tracks
  /// - user-library-modify: Modify saved tracks
  /// - user-top-read: Access top artists and tracks
  /// - user-read-recently-played: Access listening history
  ///
  /// [clientId] - Spotify application client ID
  /// [scopes] - List of permission scopes to request
  /// [redirectUri] - Custom redirect URI (defaults to "com.jarvis://oauth")
  factory OAuthConfig.spotify({
    required String clientId,
    required List<String> scopes,
    String redirectUri = 'com.jarvis://oauth',
  }) {
    return OAuthConfig(
      providerId: 'spotify',
      authorizationUrl: 'https://accounts.spotify.com/authorize',
      tokenUrl: 'https://accounts.spotify.com/api/token',
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: scopes,
      usePKCE: true,
      // Spotify doesn't need client secret for PKCE flow
      clientSecret: null,
    );
  }

  /// Create configuration for GitHub OAuth
  ///
  /// GitHub uses traditional OAuth 2.0 (requires client secret).
  /// Does not support PKCE for public clients.
  ///
  /// Common scopes:
  /// - repo: Full control of private repositories
  /// - repo:status: Access commit status
  /// - repo_deployment: Access deployment status
  /// - public_repo: Access public repositories
  /// - repo:invite: Access repository invitations
  /// - user: Access user profile data
  /// - user:email: Access user email addresses
  /// - user:follow: Follow and unfollow users
  /// - gist: Create and manage gists
  /// - notifications: Access notifications
  /// - read:org: Read org and team membership
  ///
  /// [clientId] - GitHub application client ID
  /// [clientSecret] - GitHub application client secret
  /// [scopes] - List of permission scopes to request
  /// [redirectUri] - Custom redirect URI (defaults to "com.jarvis://oauth")
  factory OAuthConfig.github({
    required String clientId,
    required String clientSecret,
    required List<String> scopes,
    String redirectUri = 'com.jarvis://oauth',
  }) {
    return OAuthConfig(
      providerId: 'github',
      authorizationUrl: 'https://github.com/login/oauth/authorize',
      tokenUrl: 'https://github.com/login/oauth/access_token',
      revocationUrl:
          'https://api.github.com/applications/$clientId/token',
      clientId: clientId,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
      scopes: scopes,
      // GitHub doesn't support PKCE for public clients
      usePKCE: false,
    );
  }

  /// Create configuration for Google OAuth
  ///
  /// Google supports PKCE and requires "access_type=offline" for refresh tokens.
  ///
  /// Common scopes:
  /// - https://www.googleapis.com/auth/gmail.readonly: Read Gmail
  /// - https://www.googleapis.com/auth/gmail.send: Send email
  /// - https://www.googleapis.com/auth/gmail.modify: Modify Gmail
  /// - https://www.googleapis.com/auth/calendar: Full calendar access
  /// - https://www.googleapis.com/auth/calendar.events: Calendar events
  /// - https://www.googleapis.com/auth/calendar.readonly: Read calendar
  /// - https://www.googleapis.com/auth/drive: Full Drive access
  /// - https://www.googleapis.com/auth/drive.readonly: Read Drive
  /// - https://www.googleapis.com/auth/drive.file: Per-file Drive access
  /// - https://www.googleapis.com/auth/userinfo.email: User email
  /// - https://www.googleapis.com/auth/userinfo.profile: User profile
  ///
  /// [clientId] - Google application client ID
  /// [scopes] - List of permission scopes to request
  /// [redirectUri] - Custom redirect URI (defaults to "com.jarvis://oauth")
  /// [forceConsent] - Force user to grant consent even if previously granted
  factory OAuthConfig.google({
    required String clientId,
    required List<String> scopes,
    String redirectUri = 'com.jarvis://oauth',
    bool forceConsent = false,
  }) {
    return OAuthConfig(
      providerId: 'google',
      authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
      tokenUrl: 'https://oauth2.googleapis.com/token',
      revocationUrl: 'https://oauth2.googleapis.com/revoke',
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: scopes,
      usePKCE: true,
      // Request offline access to get refresh token
      additionalParameters: {
        'access_type': 'offline',
        // Prompt for consent on first auth
        'prompt': forceConsent ? 'consent' : 'select_account',
      },
      prompt: forceConsent ? 'consent' : 'select_account',
    );
  }

  /// Create configuration for Microsoft OAuth
  ///
  /// Microsoft supports PKCE and uses common OAuth 2.0 endpoints.
  ///
  /// Common scopes:
  /// - User.Read: Read user profile
  /// - Mail.Read: Read user mail
  /// - Mail.Send: Send mail
  /// - Calendars.Read: Read calendars
  /// - Calendars.ReadWrite: Read and write calendars
  /// - Files.Read: Read files
  /// - Files.ReadWrite: Read and write files
  /// - offline_access: Get refresh token
  ///
  /// [clientId] - Microsoft application client ID
  /// [scopes] - List of permission scopes to request
  /// [redirectUri] - Custom redirect URI (defaults to "com.jarvis://oauth")
  /// [tenant] - Azure AD tenant (defaults to "common")
  factory OAuthConfig.microsoft({
    required String clientId,
    required List<String> scopes,
    String redirectUri = 'com.jarvis://oauth',
    String tenant = 'common',
  }) {
    return OAuthConfig(
      providerId: 'microsoft',
      authorizationUrl:
          'https://login.microsoftonline.com/$tenant/oauth2/v2.0/authorize',
      tokenUrl:
          'https://login.microsoftonline.com/$tenant/oauth2/v2.0/token',
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: scopes,
      usePKCE: true,
    );
  }

  /// Create a copy with updated fields
  OAuthConfig copyWith({
    String? providerId,
    String? authorizationUrl,
    String? tokenUrl,
    String? revocationUrl,
    String? clientId,
    String? clientSecret,
    String? redirectUri,
    List<String>? scopes,
    bool? usePKCE,
    Map<String, String>? additionalParameters,
    String? prompt,
  }) {
    return OAuthConfig(
      providerId: providerId ?? this.providerId,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      tokenUrl: tokenUrl ?? this.tokenUrl,
      revocationUrl: revocationUrl ?? this.revocationUrl,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      redirectUri: redirectUri ?? this.redirectUri,
      scopes: scopes ?? this.scopes,
      usePKCE: usePKCE ?? this.usePKCE,
      additionalParameters: additionalParameters ?? this.additionalParameters,
      prompt: prompt ?? this.prompt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OAuthConfig &&
        other.providerId == providerId &&
        other.clientId == clientId;
  }

  @override
  int get hashCode => Object.hash(providerId, clientId);

  @override
  String toString() {
    return 'OAuthConfig(providerId: $providerId, scopes: $scopes, usePKCE: $usePKCE)';
  }
}
