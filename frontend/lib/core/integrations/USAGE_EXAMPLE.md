# Integration Manager Usage Examples

## Basic Integration Setup

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/integrations/integrations.dart';

// Access the integration manager
final manager = ref.watch(integrationManagerProvider);

// Get all integrations
final integrations = ref.watch(integrationsProvider);

// Connect to an integration
await manager.connect('contacts');

// Disconnect from an integration
await manager.disconnect('contacts');

// Check if connected
final isConnected = manager.isConnected('google');
```

## Working with OAuth Tokens

```dart
// Get tokens (auto-refreshes if needed)
final tokens = await manager.getTokens('google');

// Use tokens in API call
final response = await http.get(
  Uri.parse('https://www.googleapis.com/gmail/v1/users/me/messages'),
  headers: {
    'Authorization': tokens.authorizationHeader,
  },
);

// Store new tokens after OAuth flow
final newTokens = OAuthTokens.fromOAuthResponse(
  oauthResponse,
  'google',
);
await manager.storeTokens('google', newTokens);
```

## Registering Tools

```dart
// Create a tool definition
final contactSearchTool = ToolDefinition(
  name: 'contacts.search',
  description: 'Search contacts by name or email',
  service: 'contacts',
  parameters: {
    'query': ParamDef(
      type: 'string',
      description: 'Search query',
      required: true,
    ),
    'limit': ParamDef(
      type: 'number',
      description: 'Maximum results',
      defaultValue: 10,
    ),
  },
  returnType: 'array',
  privacy: PrivacyLevel.onDevice,
);

// Register the tool with a handler
final registry = ref.watch(toolRegistryProvider);
registry.registerTool(contactSearchTool, (params) async {
  final query = params['query'] as String;
  final limit = params['limit'] as int? ?? 10;

  // Perform contact search
  final results = await searchContacts(query, limit);
  return results;
});
```

## Using Tools with AI

```dart
// Get function schemas for AI
final connectedServices = manager.connectedIntegrations
    .map((i) => i.id)
    .toList();

final schemas = registry.toFunctionSchemas(
  connectedServices: connectedServices,
);

// Send to Claude/OpenAI
final response = await aiClient.chat(
  messages: messages,
  tools: schemas,
);

// Execute tool call
if (response.toolCalls != null) {
  for (final toolCall in response.toolCalls) {
    final result = await registry.executeTool(
      toolCall.name,
      toolCall.parameters,
    );
    // Send result back to AI
  }
}
```

## UI Examples

```dart
// Display all integrations grouped by type
final integrationsByType = ref.watch(integrationsByTypeProvider);

integrationsByType.when(
  data: (grouped) {
    return Column(
      children: [
        for (final type in IntegrationType.values)
          if (grouped[type]?.isNotEmpty ?? false)
            _buildSection(type, grouped[type]!),
      ],
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);

// Watch a specific integration
final contactsIntegration = ref.watch(
  integrationProvider('contacts'),
);

// Connect button
ElevatedButton(
  onPressed: integration.isConnected
      ? null
      : () async {
          await ref.read(integrationManagerProvider).connect('contacts');
        },
  child: Text(
    integration.isConnected ? 'Connected' : 'Connect',
  ),
);
```

## Stream-based Updates

```dart
// Listen to integration status changes
final subscription = manager.statusChanges.listen((integration) {
  print('${integration.name} status: ${integration.status}');

  if (integration.status == IntegrationStatus.error) {
    // Show error notification
    showError(integration.errorMessage);
  }
});

// Don't forget to cancel
subscription.cancel();
```
