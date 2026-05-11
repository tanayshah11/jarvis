# Integrations Hub Feature

This feature provides a complete UI for managing external service integrations in the Jarvis Flutter app. It follows the app's black and gold design system with glassmorphism effects.

## Overview

The Integrations Hub allows users to:
- View all available integrations
- Connect/disconnect services
- See connected account information
- Understand privacy implications before connecting
- Manage OAuth, local, and API key-based integrations

## File Structure

```
lib/features/integrations/
├── models/
│   ├── integration.dart          # Integration model and enums
│   └── mock_integrations.dart    # Mock data for development
├── providers/
│   └── integrations_provider.dart # Riverpod state management
├── screens/
│   └── integrations_hub_screen.dart # Main integrations screen
└── widgets/
    ├── connection_status.dart     # Status indicator widget
    ├── integration_card.dart      # Glassmorphism integration card
    └── permission_dialog.dart     # Permission consent dialog
```

## Architecture

### Models

**Integration** - Core model representing a service integration
- `IntegrationType`: oauth, local, apiKey
- `PrivacyLevel`: onDevice, withConsent, apiKey
- `IntegrationStatus`: connected, disconnected, connecting, error

**Mock Data** - 8 sample integrations:
- Connected: Gmail, Contacts
- Available: Google Calendar, Spotify, GitHub, Notion
- Device: Apple Calendar, Photos

### State Management

Uses **Riverpod** with the Notifier pattern:
- `IntegrationsNotifier` - Manages integration state
- `integrationsControllerProvider` - Provider for the notifier
- `IntegrationsState` - State class with computed properties

Key computed properties:
- `connectedIntegrations` - OAuth integrations that are connected
- `availableIntegrations` - OAuth integrations ready to connect
- `deviceIntegrations` - Local integrations (disconnected)
- `connectedDeviceIntegrations` - Local integrations (connected)

### Screens

**IntegrationsHubScreen** - Main screen with three sections:
1. **CONNECTED** - Shows connected integrations with account info
2. **AVAILABLE** - OAuth services ready to connect
3. **DEVICE** - Local device integrations with privacy badge

Features:
- Animated gradient background
- Custom header with back button
- Scrollable list of integrations
- Tap to connect/disconnect
- Permission dialogs before connecting

### Widgets

**IntegrationCard** - Reusable glassmorphism card
- Icon with colored background
- Service name and status
- Account email (if connected)
- Privacy badge for local services
- Gold accent border when connected

**ConnectionStatus** - Animated status indicator
- Green dot + "Connected" for connected state
- Gold "Connect →" for available state
- Spinner for connecting state
- Red error icon for error state

**PermissionDialog** - Pre-connection consent dialog
- Lists integration capabilities
- Shows privacy implications
- Different messaging for local vs OAuth
- Connect/Cancel actions

## Design System

### Colors (from AppColors)
- Background: `#000000` (pure black)
- Surface: `#0A0A0A` (near black)
- Gold/Primary: `#D4AF37`
- Text Primary: `#FFFFFF`
- Text Secondary: `#888888`

### Glassmorphism Effect
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      // ...
    ),
  ),
)
```

### Spacing (from AppSpacing)
- xs: 4px, sm: 8px, md: 12px, lg: 16px, xl: 24px

## Navigation

The Integrations Hub is accessible from Settings:

```
Settings → Integrations
Path: /settings/integrations
```

Route definition in `router.dart`:
```dart
GoRoute(
  path: 'integrations',
  pageBuilder: (context, state) => _buildCupertinoPage(
    child: const IntegrationsHubScreen(),
    state: state,
  ),
),
```

## User Flow

### Connecting an Integration

1. User taps on disconnected integration card
2. Permission dialog appears showing:
   - Service description
   - Required capabilities
   - Privacy information
3. User confirms or cancels
4. If confirmed:
   - Status changes to "Connecting..." with spinner
   - 2-second simulated delay
   - Status changes to "Connected" with green dot
   - Account info appears (mock data)

### Disconnecting an Integration

1. User taps on connected integration card
2. Confirmation dialog appears
3. User confirms disconnection
4. Status changes to disconnected
5. Account info is removed

## Mock Data Implementation

Currently uses static mock data. Key methods:

```dart
Future<void> connectIntegration(String integrationId)
Future<void> disconnectIntegration(String integrationId)
```

When the real Integration Manager is implemented, replace:
- `mockIntegrations` with actual API calls
- Mock delays with real OAuth flows
- Mock account info with real user data

## Haptic Feedback

The UI includes haptic feedback for better UX:
- `HapticFeedback.selectionClick()` - Card taps
- `HapticFeedback.mediumImpact()` - Dialogs
- `HapticFeedback.lightImpact()` - Back button

## Testing

To test the feature:

1. Navigate to Settings
2. Tap "Integrations"
3. Try connecting/disconnecting services
4. Verify:
   - Sections show correct integrations
   - Permission dialogs display properly
   - Status animations work
   - Local services show privacy badge
   - Account info appears when connected

## Future Enhancements

- [ ] Real OAuth implementation
- [ ] API key configuration UI
- [ ] Integration settings per service
- [ ] Connection error handling
- [ ] Retry mechanisms
- [ ] Integration usage statistics
- [ ] Search/filter integrations
- [ ] Integration categories

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `cupertino_icons` - Icons

## Design Patterns

- **Riverpod Notifier**: State management
- **Provider Pattern**: Dependency injection
- **Composition**: Reusable widgets
- **Separation of Concerns**: Models, views, controllers

## Notes

- All integrations are currently mock data
- OAuth flows are simulated with delays
- No actual API calls are made
- Privacy levels are for UI demonstration only
- Ready to integrate with real Integration Manager when available
