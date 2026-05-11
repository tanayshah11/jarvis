/// Represents the type of integration authentication.
enum IntegrationType {
  /// OAuth-based integration (requires user consent and external auth).
  oauth,

  /// Local device integration (contacts, calendar, etc.).
  local,

  /// API key-based integration.
  apiKey,
}

/// Represents the privacy level of an integration.
enum PrivacyLevel {
  /// Data stays on device (local integrations).
  onDevice,

  /// Data shared with consent (OAuth integrations).
  withConsent,

  /// Data shared via API key.
  apiKey,
}

/// Represents the connection status of an integration.
enum IntegrationStatus {
  /// Integration is connected and active.
  connected,

  /// Integration is disconnected.
  disconnected,

  /// Integration is currently connecting.
  connecting,

  /// Integration encountered an error.
  error,
}

/// Model representing an external service integration.
class Integration {
  /// Unique identifier for the integration.
  final String id;

  /// Display name of the integration.
  final String name;

  /// Brief description of what the integration does.
  final String description;

  /// Type of integration authentication.
  final IntegrationType type;

  /// Privacy level of the integration.
  final PrivacyLevel privacy;

  /// List of capabilities this integration provides.
  final List<String> capabilities;

  /// Current connection status.
  final IntegrationStatus status;

  /// Connected account email/username (if connected).
  final String? accountInfo;

  /// Icon identifier (CupertinoIcons name).
  final String? iconName;

  const Integration({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.privacy,
    required this.capabilities,
    required this.status,
    this.accountInfo,
    this.iconName,
  });

  /// Creates a copy of this integration with updated fields.
  Integration copyWith({
    String? id,
    String? name,
    String? description,
    IntegrationType? type,
    PrivacyLevel? privacy,
    List<String>? capabilities,
    IntegrationStatus? status,
    String? accountInfo,
    String? iconName,
  }) {
    return Integration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      capabilities: capabilities ?? this.capabilities,
      status: status ?? this.status,
      accountInfo: accountInfo ?? this.accountInfo,
      iconName: iconName ?? this.iconName,
    );
  }
}
