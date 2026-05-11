# Local Device Services

This directory contains Flutter services that communicate with iOS native bridges to access device-local data.

## Privacy First

All services in this directory are designed with privacy in mind:
- **Data stays on device** - No data is sent to external servers
- **User permission required** - All services respect iOS permission system
- **Transparent access** - Users can see and control what data is accessed

## Available Services

### 1. Contacts Service

Access device contacts through the iOS native ContactsManager bridge.

**Usage:**

```dart
import 'package:jarvis/core/services/local/contacts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsService = ref.watch(contactsServiceProvider);
    final permissionStatus = ref.watch(contactsPermissionProvider);

    return permissionStatus.when(
      data: (status) {
        if (status == ContactsPermissionStatus.authorized) {
          return ContactsList(service: contactsService);
        }
        return PermissionRequest(service: contactsService);
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

// Search contacts
final contacts = await contactsService.search('John');

// Get all contacts
final allContacts = await contactsService.getAll(limit: 50);

// Get by ID
final contact = await contactsService.getById('contact-id-123');
```

**Models:**

- `Contact` - Represents a device contact with name, phones, emails, organization
- `ContactsPermissionStatus` - Enum for permission states (notDetermined, authorized, denied, restricted)

**Providers:**

- `contactsServiceProvider` - Access the ContactsService instance
- `contactsPermissionProvider` - Watch current permission status

### 2. Calendar Service

Access device calendar events through the iOS native CalendarManager bridge.

**Usage:**

```dart
import 'package:jarvis/core/services/local/calendar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEvents = ref.watch(todayEventsProvider);

    return todayEvents.when(
      data: (events) => EventsList(events: events),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

final calendarService = ref.watch(calendarServiceProvider);

// Get today's events
final events = await calendarService.getTodayEvents();

// Get events for a date range
final rangeEvents = await calendarService.getEvents(
  start: DateTime(2024, 1, 1),
  end: DateTime(2024, 1, 31),
);

// Create an event
final newEvent = await calendarService.createEvent(
  title: 'Team Meeting',
  startDate: DateTime(2024, 1, 15, 14, 0),
  endDate: DateTime(2024, 1, 15, 15, 0),
  location: 'Conference Room A',
  notes: 'Quarterly planning discussion',
);

// Update an event
await calendarService.updateEvent(
  eventId: event.id,
  title: 'Updated Meeting Title',
  location: 'Conference Room B',
);

// Delete an event
await calendarService.deleteEvent(eventId);
```

**Models:**

- `DeviceCalendar` - Represents a calendar with id, title, color, isDefault
- `CalendarEvent` - Represents an event with title, dates, location, notes
- `CalendarPermissionStatus` - Enum for permission states

**Providers:**

- `calendarServiceProvider` - Access the CalendarService instance
- `calendarPermissionProvider` - Watch current permission status
- `calendarsProvider` - Watch available calendars
- `todayEventsProvider` - Watch today's events
- `thisWeekEventsProvider` - Watch this week's events

**CalendarEvent Helpers:**

```dart
final event = CalendarEvent(...);

event.duration;           // Duration object
event.isNow;             // Is event happening now?
event.isPast;            // Is event in the past?
event.isFuture;          // Is event in the future?
event.isToday;           // Is event happening today?
event.formattedDuration; // "2h 30m"
```

## Tool Definitions

Both services have corresponding tool definitions for AI integration:

### Contacts Tools

Located in `lib/core/integrations/tools/contacts_tools.dart`

Available tools:
- `contacts.search` - Search contacts by name
- `contacts.getAll` - Get all contacts with limit
- `contacts.getById` - Get specific contact
- `contacts.checkPermission` - Check permission status
- `contacts.requestPermission` - Request permission

### Calendar Tools

Located in `lib/core/integrations/tools/calendar_tools.dart`

Available tools:
- `calendar.getEvents` - Get events in date range
- `calendar.today` - Get today's events
- `calendar.thisWeek` - Get this week's events
- `calendar.thisMonth` - Get this month's events
- `calendar.create` - Create new event
- `calendar.update` - Update existing event
- `calendar.delete` - Delete event
- `calendar.getCalendars` - Get available calendars
- `calendar.checkPermission` - Check permission status
- `calendar.requestPermission` - Request permission

## Architecture

```
Flutter (Dart)
    ↓ MethodChannel
iOS Native Bridge (Swift)
    ↓ Native iOS APIs
Device Data (Contacts/Calendar)
```

### Method Channels

- **Contacts**: `com.jarvis/contacts`
- **Calendar**: `com.jarvis/calendar`

### iOS Native Bridges

The iOS native code is expected to implement these method channels in Swift:

**ContactsManager.swift** should handle:
- `requestPermission()` → String (status)
- `checkPermission()` → String (status)
- `search(query: String)` → List<Map>
- `getAll(limit: Int)` → List<Map>
- `getById(id: String)` → Map?

**CalendarManager.swift** should handle:
- `requestPermission()` → String (status)
- `checkPermission()` → String (status)
- `getCalendars()` → List<Map>
- `getEvents(start: String, end: String, calendarIds: [String]?)` → List<Map>
- `createEvent(...)` → Map?
- `updateEvent(...)` → Map?
- `deleteEvent(eventId: String)` → Bool

## Error Handling

All services throw exceptions on errors:

```dart
try {
  final contacts = await contactsService.search('John');
} on PlatformException catch (e) {
  // Handle platform-specific errors
  if (e.code == 'PERMISSION_DENIED') {
    // Show permission dialog
  }
} catch (e) {
  // Handle general errors
  print('Error: $e');
}
```

## Permission Flow

1. Check permission status: `checkPermission()`
2. If not determined, request: `requestPermission()`
3. If denied, direct user to Settings
4. If authorized, access data

## Testing

Since these services require iOS native bridges, they cannot be fully tested without:
1. Running on a real iOS device or simulator
2. Implementing the native Swift bridges
3. Having test data in Contacts/Calendar apps

For testing in development, consider:
- Mock implementations for the services
- Test the data models and serialization
- Integration tests on real devices

## Next Steps

To use these services:

1. Implement iOS native bridges in Swift
2. Register method channels in AppDelegate
3. Request necessary permissions in Info.plist
4. Integrate with AI tool registry when ready
5. Build UI components that use these services

## Dependencies

- `flutter/services.dart` - For MethodChannel communication
- `flutter_riverpod` - For state management and providers
