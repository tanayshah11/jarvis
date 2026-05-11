# Tool Definitions for Local Services

This directory contains tool definitions for Contacts and Calendar services that integrate with the Jarvis AI tool registry.

## Overview

The tool definitions allow the AI assistant to:
- Search and access device contacts
- Read, create, update, and delete calendar events
- Manage permissions for both services

All operations are **privacy-first** and run **on-device only** - no data is sent to external servers.

## Available Tool Files

### 1. contacts_tools.dart

Provides 5 contact-related tools:

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| `contacts.search` | Search contacts by name | `query: string` |
| `contacts.getAll` | Get all contacts with limit | `limit?: number` (default: 100) |
| `contacts.getById` | Get specific contact by ID | `id: string` |
| `contacts.checkPermission` | Check permission status | none |
| `contacts.requestPermission` | Request permission | none |

**Example AI Usage:**
```
User: "Call John Smith"
AI: [uses contacts.search with query "John Smith"]
AI: "I found John Smith with phone number +1 (555) 123-4567. Would you like me to initiate the call?"
```

### 2. calendar_tools.dart

Provides 10 calendar-related tools:

| Tool Name | Description | Parameters |
|-----------|-------------|------------|
| `calendar.getEvents` | Get events in date range | `start: string`, `end: string`, `calendarIds?: string[]` |
| `calendar.today` | Get today's events | none |
| `calendar.thisWeek` | Get this week's events | none |
| `calendar.thisMonth` | Get this month's events | none |
| `calendar.create` | Create new event | `title`, `startDate`, `endDate`, `isAllDay?`, `location?`, `notes?`, `calendarId?` |
| `calendar.update` | Update existing event | `eventId`, plus any fields to update |
| `calendar.delete` | Delete an event | `eventId: string` |
| `calendar.getCalendars` | Get available calendars | none |
| `calendar.checkPermission` | Check permission status | none |
| `calendar.requestPermission` | Request permission | none |

**Example AI Usage:**
```
User: "What's on my schedule today?"
AI: [uses calendar.today]
AI: "You have 3 events today:
     1. Team Meeting at 9:00 AM - 10:00 AM
     2. Lunch with Sarah at 12:30 PM - 1:30 PM
     3. Project Review at 3:00 PM - 4:00 PM"

User: "Add a meeting with Bob tomorrow at 2pm for 1 hour"
AI: [uses calendar.create with appropriate parameters]
AI: "I've added 'Meeting with Bob' to your calendar for tomorrow at 2:00 PM - 3:00 PM."
```

## Integration with Tool Registry

To register these tools with the Jarvis tool registry:

### Step 1: Import Dependencies

```dart
import 'package:jarvis/core/integrations/tool_registry.dart';
import 'package:jarvis/core/integrations/tools/contacts_tools.dart';
import 'package:jarvis/core/integrations/tools/calendar_tools.dart';
import 'package:jarvis/core/services/local/local_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### Step 2: Register Tools

```dart
// In your app initialization or integration manager
void registerLocalTools(WidgetRef ref) {
  final registry = ref.read(toolRegistryProvider);
  final contactsService = ref.read(contactsServiceProvider);
  final calendarService = ref.read(calendarServiceProvider);

  // Register all contact tools
  registerContactsTools(registry, contactsService);

  // Register all calendar tools
  registerCalendarTools(registry, calendarService);

  print('Registered ${registry.getAllTools().length} tools');
}
```

### Step 3: Use in AI Context

```dart
// Get function schemas for AI
final registry = ref.read(toolRegistryProvider);
final schemas = registry.toFunctionSchemas();

// Send to Claude API
final response = await anthropic.messages.create(
  model: 'claude-sonnet-4-5-20250929',
  messages: messages,
  tools: schemas, // AI can now use these tools
);

// Execute tool if requested
if (response.stopReason == 'tool_use') {
  for (final content in response.content) {
    if (content is ToolUse) {
      final result = await registry.executeTool(
        content.name,
        content.input as Map<String, dynamic>,
      );
      // Send result back to AI...
    }
  }
}
```

## Privacy & Permissions

All tools respect iOS permission system:

1. **First Access**: Tools will throw `PERMISSION_DENIED` error if permission not granted
2. **Permission Flow**: Use `checkPermission` and `requestPermission` tools
3. **User Control**: Users can revoke permissions anytime in iOS Settings
4. **Privacy Level**: All tools marked as `PrivacyLevel.onDevice`

### Permission Handling Example

```dart
// AI should check permission before accessing data
try {
  final contacts = await registry.executeTool('contacts.search', {'query': 'John'});
} catch (e) {
  if (e.toString().contains('PERMISSION_DENIED')) {
    // Ask user to grant permission
    await registry.executeTool('contacts.requestPermission', {});
    // Retry...
  }
}
```

## Tool Registry Statistics

Check registered tools at runtime:

```dart
final stats = registry.getStats();
print('Total tools: ${stats['total_tools']}');
print('Services: ${stats['services']}');
print('Tools by service: ${stats['tools_by_service']}');

// Expected output:
// Total tools: 15
// Services: 2
// Tools by service: {contacts: 5, calendar: 10}
```

## Architecture Flow

```
┌─────────────────────────────────────────────────────┐
│                  AI Assistant                        │
│  "What's on my schedule today?"                     │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│              Tool Registry                           │
│  - Validates tool request                           │
│  - Routes to correct handler                        │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│          calendar.today handler                      │
│  - Calls CalendarService.getTodayEvents()          │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│           CalendarService                            │
│  - Communicates via MethodChannel                   │
│  - Channel: com.jarvis/calendar                     │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│         iOS Native Bridge (Swift)                    │
│  - CalendarManager                                   │
│  - Uses EventKit.framework                          │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│            Device Calendar                           │
│  - Returns events for today                         │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
       Results flow back up through layers
       and are returned to the AI
```

## Testing

### Unit Test Example

```dart
void main() {
  test('contacts.search tool definition', () {
    final tools = getContactsToolDefinitions();
    final searchTool = tools.firstWhere((t) => t.name == 'contacts.search');

    expect(searchTool.service, 'contacts');
    expect(searchTool.requiresAuth, false);
    expect(searchTool.privacy, PrivacyLevel.onDevice);
    expect(searchTool.parameters['query']?.required, true);
  });

  test('tool validation', () {
    final tools = getCalendarToolDefinitions();
    final createTool = tools.firstWhere((t) => t.name == 'calendar.create');

    // Valid parameters
    expect(createTool.validateParameters({
      'title': 'Meeting',
      'startDate': '2024-01-15T14:00:00Z',
      'endDate': '2024-01-15T15:00:00Z',
    }), true);

    // Missing required parameter
    expect(createTool.validateParameters({
      'title': 'Meeting',
    }), false);
  });
}
```

### Integration Test Example

```dart
void main() {
  testWidgets('Tool registry integration', (tester) async {
    final container = ProviderContainer();
    final registry = container.read(toolRegistryProvider);

    // Register mock services
    final mockContactsService = MockContactsService();
    registerContactsTools(registry, mockContactsService);

    expect(registry.hasTool('contacts.search'), true);
    expect(registry.getToolsForService('contacts').length, 5);
  });
}
```

## Error Handling

Tools throw specific exceptions that should be handled:

```dart
try {
  final result = await registry.executeTool(toolName, params);
} on ToolNotFoundException catch (e) {
  // Tool doesn't exist
  print('Tool not found: ${e.toolName}');
} on ToolExecutionException catch (e) {
  // Execution failed
  print('Execution failed: ${e.message}');
  if (e.originalError != null) {
    print('Original error: ${e.originalError}');
  }
} catch (e) {
  // Generic error
  print('Unexpected error: $e');
}
```

## Best Practices

1. **Check Permissions First**: Always check permission status before accessing sensitive data
2. **Handle Errors Gracefully**: Provide user-friendly messages for permission denials
3. **Validate Parameters**: Tool registry automatically validates parameters
4. **Use Convenience Methods**: Prefer `calendar.today` over `calendar.getEvents` with manual date ranges
5. **Respect Privacy**: All tools are marked as `onDevice` - ensure data stays local

## Future Enhancements

Potential additions to these tools:

- `contacts.searchByPhone` - Search by phone number
- `contacts.searchByEmail` - Search by email
- `calendar.conflictCheck` - Check for scheduling conflicts
- `calendar.freeSlots` - Find free time slots
- `calendar.recurring` - Create recurring events
- `calendar.reminders` - Manage event reminders

## Related Files

- Service implementations: `lib/core/services/local/`
- Integration models: `lib/core/integrations/models/`
- Tool registry: `lib/core/integrations/tool_registry.dart`
- Usage examples: `lib/core/services/local/EXAMPLE_USAGE.dart`

## Support

For questions or issues with tool integration:
1. Check service implementation in `lib/core/services/local/README.md`
2. Review tool registry documentation
3. See example usage in `EXAMPLE_USAGE.dart`
