/// OAuth tokens with refresh capability
///
/// Stores access and refresh tokens for OAuth-based integrations.
/// Handles token expiration checking and provides serialization for secure storage.
class OAuthTokens {
  /// Access token for API requests
  final String accessToken;

  /// Refresh token for obtaining new access tokens
  final String? refreshToken;

  /// When the access token expires
  final DateTime expiresAt;

  /// Service identifier (e.g., "google", "spotify", "github")
  final String service;

  /// OAuth scopes granted to this token
  final List<String> scopes;

  /// Additional token metadata (e.g., token_type, id_token)
  final Map<String, dynamic>? metadata;

  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.service,
    required this.scopes,
    this.metadata,
  });

  /// Whether the access token has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the token should be refreshed soon (5 minutes before expiration)
  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

  /// Whether a refresh token is available
  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  /// Time until token expires
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  /// Create OAuthTokens from JSON
  factory OAuthTokens.fromJson(Map<String, dynamic> json) {
    return OAuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      service: json['service'] as String,
      scopes: (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert OAuthTokens to JSON for secure storage
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'service': service,
      'scopes': scopes,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create tokens from OAuth response
  ///
  /// Handles common OAuth response formats from various providers.
  /// [response] - The OAuth token response
  /// [service] - The service identifier
  /// [expiresIn] - Optional override for expires_in seconds
  factory OAuthTokens.fromOAuthResponse(
    Map<String, dynamic> response,
    String service, {
    int? expiresIn,
  }) {
    final expiresInSeconds = expiresIn ??
        (response['expires_in'] as int?) ??
        3600; // Default 1 hour

    return OAuthTokens(
      accessToken: response['access_token'] as String,
      refreshToken: response['refresh_token'] as String?,
      expiresAt: DateTime.now().add(Duration(seconds: expiresInSeconds)),
      service: service,
      scopes: _parseScopes(response['scope']),
      metadata: {
        if (response['token_type'] != null)
          'token_type': response['token_type'],
        if (response['id_token'] != null) 'id_token': response['id_token'],
        if (response.containsKey('refresh_token_expires_in'))
          'refresh_token_expires_in': response['refresh_token_expires_in'],
      },
    );
  }

  /// Parse scopes from various formats
  static List<String> _parseScopes(dynamic scope) {
    if (scope == null) return [];
    if (scope is String) {
      // Space-separated or comma-separated
      if (scope.contains(',')) {
        return scope.split(',').map((s) => s.trim()).toList();
      }
      return scope.split(' ').where((s) => s.isNotEmpty).toList();
    }
    if (scope is List) {
      return scope.map((s) => s.toString()).toList();
    }
    return [];
  }

  /// Create a copy with updated fields
  OAuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? service,
    List<String>? scopes,
    Map<String, dynamic>? metadata,
  }) {
    return OAuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      service: service ?? this.service,
      scopes: scopes ?? this.scopes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get authorization header value
  String get authorizationHeader {
    final tokenType = metadata?['token_type'] as String? ?? 'Bearer';
    return '$tokenType $accessToken';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OAuthTokens &&
        other.accessToken == accessToken &&
        other.service == service;
  }

  @override
  int get hashCode => Object.hash(accessToken, service);

  @override
  String toString() {
    return 'OAuthTokens(service: $service, scopes: $scopes, '
        'expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}
