# Integrations Hub - Usage Guide

## How to Access

### From Settings
1. Open the Jarvis app
2. Navigate to the Settings tab (bottom navigation)
3. Tap on "Integrations" card
4. You'll see the Integrations Hub screen

### Direct Navigation (for testing)
```dart
context.push('/settings/integrations');
```

## User Interactions

### Connecting an Integration

**OAuth Integration (e.g., Gmail):**
1. Find "Gmail" in the AVAILABLE section
2. Tap the card
3. Permission dialog appears showing:
   - "Access your emails"
   - Capabilities: Search, Read, Send
   - Privacy notice about data sharing
4. Tap "Connect"
5. Card shows "Connecting..." with spinner (2 seconds)
6. Card moves to CONNECTED section
7. Shows "● Connected" with account email

**Local Integration (e.g., Contacts):**
1. Find "Contacts" in the DEVICE section
2. Tap the card
3. Permission dialog appears showing:
   - "Search your contacts"
   - Capabilities: Search, Read
   - "🔒 All data stays on your device"
4. Tap "Enable"
5. Card shows "Connecting..." with spinner (2 seconds)
6. Card moves to CONNECTED section
7. Shows "● Connected" with privacy badge

### Disconnecting an Integration

1. Find the connected integration in CONNECTED section
2. Tap the card
3. Confirmation dialog appears
4. Tap "Disconnect" (red text)
5. Card immediately moves to appropriate section:
   - OAuth → AVAILABLE section
   - Local → DEVICE section
6. Account info is removed
7. Shows "Connect →" status

### Canceling a Connection

1. Tap a disconnected integration
2. Permission dialog appears
3. Tap "Cancel"
4. Dialog dismisses
5. No state change

## Testing Scenarios

### Scenario 1: Fresh Install
**Expected State:**
- AVAILABLE section: 4 OAuth services (Gmail, Google Calendar, Spotify, GitHub, Notion)
- DEVICE section: 2 local services (Contacts, Apple Calendar, Photos)
- CONNECTED section: Not visible (no connections)

**Test:**
1. Navigate to Integrations Hub
2. Verify all services in correct sections
3. Verify all show "Connect →" status
4. Tap each service to verify permission dialog

### Scenario 2: Connect OAuth Service
**Steps:**
1. Tap "Gmail" card
2. Review permission dialog
3. Tap "Connect"

**Expected:**
- Status changes to "Connecting..." with spinner
- After 2 seconds, status becomes "● Connected"
- Account shows "john@gmail.com"
- Card moves to CONNECTED section
- Card has gold border
- CONNECTED section header appears

### Scenario 3: Connect Local Service
**Steps:**
1. Tap "Contacts" card
2. Review permission dialog
3. Verify privacy message shows "Stays on device"
4. Tap "Enable"

**Expected:**
- Status changes to "Connecting..." with spinner
- After 2 seconds, status becomes "● Connected"
- Card moves to CONNECTED section (or stays if already has connected items)
- Privacy badge remains visible
- Card has gold border

### Scenario 4: Disconnect Service
**Steps:**
1. From CONNECTED section, tap "Gmail" card
2. Review disconnect dialog
3. Tap "Disconnect"

**Expected:**
- Card immediately moves to AVAILABLE section
- Status changes to "Connect →"
- Account email is removed
- Border becomes light (no gold)
- If last connected item, CONNECTED section disappears

### Scenario 5: Multiple Connections
**Steps:**
1. Connect Gmail
2. Connect Spotify
3. Connect Contacts
4. Connect Apple Calendar

**Expected:**
- CONNECTED section shows all 4 services
- OAuth services (Gmail, Spotify) show account info
- Local services (Contacts, Calendar) show privacy badge
- All have "● Connected" status
- All have gold borders

### Scenario 6: Navigation Test
**Steps:**
1. Open Settings
2. Tap "Integrations"
3. Tap back button
4. Verify returns to Settings
5. Navigate back to Integrations
6. Verify state is preserved

**Expected:**
- Navigation works smoothly
- State persists (Riverpod keeps state)
- No flickering or loading

### Scenario 7: Dialog Interactions
**Test all dialogs:**
- Permission dialog (OAuth)
- Permission dialog (Local)
- Disconnect dialog

**Expected:**
- All dialogs blur background
- Tapping outside dismisses (iOS behavior)
- Cancel buttons work
- Action buttons have correct colors (gold for connect, red for disconnect)
- Haptic feedback on dialog open

## Provider Usage

### Reading State
```dart
// In a widget
final integrationsState = ref.watch(integrationsControllerProvider);

// Access computed properties
final connected = integrationsState.connectedIntegrations;
final available = integrationsState.availableIntegrations;
```

### Connecting Integration
```dart
await ref
    .read(integrationsControllerProvider.notifier)
    .connectIntegration('gmail');
```

### Disconnecting Integration
```dart
await ref
    .read(integrationsControllerProvider.notifier)
    .disconnectIntegration('gmail');
```

## Mock Data Reference

### Currently Available Integrations

**OAuth Services:**
- **Gmail** - mail icon
- **Google Calendar** - calendar icon
- **Spotify** - music_note icon
- **GitHub** - square_stack_3d_up icon
- **Notion** - doc_text icon

**Local Services:**
- **Contacts** - person_2 icon
- **Apple Calendar** - calendar_today icon
- **Photos** - photo icon

### Mock Account Info (after connecting)

| Service | Account Info |
|---------|-------------|
| Gmail | john@gmail.com |
| Google Calendar | john@gmail.com |
| Spotify | john_music |
| GitHub | johndev |
| Notion | john@notion.so |
| Contacts | (none - privacy badge instead) |
| Apple Calendar | (none - privacy badge instead) |
| Photos | (none - privacy badge instead) |

## Customization

### Adding New Integration

1. Add to `mock_integrations.dart`:
```dart
Integration(
  id: 'slack',
  name: 'Slack',
  description: 'Send and receive messages',
  type: IntegrationType.oauth,
  privacy: PrivacyLevel.withConsent,
  capabilities: ['search', 'read', 'send'],
  status: IntegrationStatus.disconnected,
  iconName: 'chat_bubble',
),
```

2. Add icon mapping in `integration_card.dart`:
```dart
case 'chat_bubble':
  return CupertinoIcons.chat_bubble;
```

3. Add account info in `integrations_provider.dart`:
```dart
case 'slack':
  return 'john@workspace.slack.com';
```

### Modifying UI

**Card Style:**
- Edit `integration_card.dart`
- Adjust padding, border radius, colors
- Change icon size or background

**Section Headers:**
- Edit `integrations_hub_screen.dart`
- Modify `_buildSection` method
- Adjust title styling, spacing

**Dialogs:**
- Edit `permission_dialog.dart`
- Customize content, actions
- Add/remove information

## Troubleshooting

### State not updating
- Check Riverpod provider is properly read/watched
- Verify notifier methods are being called
- Use Flutter DevTools to inspect state

### Cards not appearing
- Verify integration status matches section filter
- Check `IntegrationsState` computed properties
- Ensure mock data is properly imported

### Navigation issues
- Verify route is added to `router.dart`
- Check context is mounted before navigation
- Ensure Settings screen has correct path

### Icons not showing
- Verify icon name matches CupertinoIcons
- Check icon mapping in `_getIcon()` method
- Add new icon cases as needed

## Performance Notes

- State updates are O(n) where n = number of integrations
- Mock delay is 2 seconds (configurable)
- List rebuilds are efficient (const constructors)
- No unnecessary re-renders (Riverpod optimization)

## Future Integration Points

When connecting to real Integration Manager:

1. Replace `connectIntegration()` with OAuth flow
2. Replace `disconnectIntegration()` with revoke call
3. Replace mock data with API calls
4. Add error handling for network failures
5. Add retry logic for failed connections
6. Store connection state persistently
7. Add token refresh logic
8. Implement actual capability checks
