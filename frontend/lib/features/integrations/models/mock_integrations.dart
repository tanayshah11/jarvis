import 'integration.dart';

/// Mock integrations data for development.
final List<Integration> mockIntegrations = [
  // Connected integrations
  Integration(
    id: 'gmail',
    name: 'Gmail',
    description: 'Access your emails',
    type: IntegrationType.oauth,
    privacy: PrivacyLevel.withConsent,
    capabilities: ['search', 'read', 'send'],
    status: IntegrationStatus.connected,
    accountInfo: 'john@gmail.com',
    iconName: 'mail',
  ),
  Integration(
    id: 'contacts',
    name: 'Contacts',
    description: 'Search your contacts',
    type: IntegrationType.local,
    privacy: PrivacyLevel.onDevice,
    capabilities: ['search', 'read'],
    status: IntegrationStatus.connected,
    iconName: 'person',
  ),

  // Available integrations
  Integration(
    id: 'google_calendar',
    name: 'Google Calendar',
    description: 'Manage your schedule',
    type: IntegrationType.oauth,
    privacy: PrivacyLevel.withConsent,
    capabilities: ['search', 'read', 'create', 'update'],
    status: IntegrationStatus.disconnected,
    iconName: 'calendar',
  ),
  Integration(
    id: 'spotify',
    name: 'Spotify',
    description: 'Control music playback',
    type: IntegrationType.oauth,
    privacy: PrivacyLevel.withConsent,
    capabilities: ['search', 'play', 'pause', 'next'],
    status: IntegrationStatus.disconnected,
    iconName: 'music_note',
  ),
  Integration(
    id: 'github',
    name: 'GitHub',
    description: 'Access your repositories',
    type: IntegrationType.oauth,
    privacy: PrivacyLevel.withConsent,
    capabilities: ['search', 'read', 'create'],
    status: IntegrationStatus.disconnected,
    iconName: 'square_stack_3d_up',
  ),
  Integration(
    id: 'notion',
    name: 'Notion',
    description: 'Access your notes and databases',
    type: IntegrationType.oauth,
    privacy: PrivacyLevel.withConsent,
    capabilities: ['search', 'read', 'create', 'update'],
    status: IntegrationStatus.disconnected,
    iconName: 'doc_text',
  ),

  // Local device integrations
  Integration(
    id: 'apple_calendar',
    name: 'Apple Calendar',
    description: 'Access your local calendar',
    type: IntegrationType.local,
    privacy: PrivacyLevel.onDevice,
    capabilities: ['search', 'read', 'create'],
    status: IntegrationStatus.disconnected,
    iconName: 'calendar_today',
  ),
  Integration(
    id: 'photos',
    name: 'Photos',
    description: 'Access your photo library',
    type: IntegrationType.local,
    privacy: PrivacyLevel.onDevice,
    capabilities: ['search', 'read'],
    status: IntegrationStatus.disconnected,
    iconName: 'photo',
  ),
];
