/// Integration type defines how the service connects
enum IntegrationType {
  /// Local device integration (e.g., Contacts, Calendar)
  local,

  /// OAuth-based integration (e.g., Google, Spotify, GitHub)
  oauth,

  /// API key-based integration
  apiKey,
}

/// Status of an integration connection
enum IntegrationStatus {
  /// Service is disconnected
  disconnected,

  /// Currently connecting to service
  connecting,

  /// Successfully connected and ready
  connected,

  /// Connection or authentication error
  error,
}

/// Privacy level for data handling
enum PrivacyLevel {
  /// All data stays on device
  onDevice,

  /// Data shared only with explicit user consent
  withConsent,

  /// Low-risk data (e.g., public information)
  lowRisk,
}

/// Base model for all service integrations
///
/// Represents a service that can be connected to Jarvis for enhanced capabilities.
/// Each integration provides tools that the AI can use to perform actions.
class Integration {
  /// Unique identifier (e.g., "contacts", "gmail", "spotify")
  final String id;

  /// Display name (e.g., "Contacts", "Gmail", "Spotify")
  final String name;

  /// User-friendly description of the integration
  final String description;

  /// Asset path or icon name for UI display
  final String iconPath;

  /// Type of integration (local, oauth, apiKey)
  final IntegrationType type;

  /// Privacy level for this integration
  final PrivacyLevel privacy;

  /// List of capabilities this integration provides
  /// Examples: ["search", "read", "write", "send"]
  final List<String> capabilities;

  /// Current connection status
  final IntegrationStatus status;

  /// Account information (e.g., "john@gmail.com", "Premium User")
  final String? accountInfo;

  /// When the integration was first connected
  final DateTime? connectedAt;

  /// Error message if status is error
  final String? errorMessage;

  const Integration({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.privacy,
    required this.capabilities,
    this.status = IntegrationStatus.disconnected,
    this.accountInfo,
    this.connectedAt,
    this.errorMessage,
  });

  /// Create Integration from JSON
  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['icon_path'] as String,
      type: IntegrationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntegrationType.local,
      ),
      privacy: PrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacy'],
        orElse: () => PrivacyLevel.withConsent,
      ),
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: IntegrationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IntegrationStatus.disconnected,
      ),
      accountInfo: json['account_info'] as String?,
      connectedAt: json['connected_at'] != null
          ? DateTime.parse(json['connected_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Convert Integration to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_path': iconPath,
      'type': type.name,
      'privacy': privacy.name,
      'capabilities': capabilities,
      'status': status.name,
      if (accountInfo != null) 'account_info': accountInfo,
      if (connectedAt != null) 'connected_at': connectedAt!.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  /// Create a copy with updated fields
  Integration copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    IntegrationType? type,
    PrivacyLevel? privacy,
    List<String>? capabilities,
    IntegrationStatus? status,
    String? accountInfo,
    DateTime? connectedAt,
    String? errorMessage,
  }) {
    return Integration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      capabilities: capabilities ?? this.capabilities,
      status: status ?? this.status,
      accountInfo: accountInfo ?? this.accountInfo,
      connectedAt: connectedAt ?? this.connectedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Whether this integration is currently connected
  bool get isConnected => status == IntegrationStatus.connected;

  /// Whether this integration requires OAuth
  bool get requiresOAuth => type == IntegrationType.oauth;

  /// Whether this integration uses device-only data
  bool get isDeviceOnly => privacy == PrivacyLevel.onDevice;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Integration &&
        other.id == id &&
        other.name == name &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, name, status);
}
