import '../../services/local/calendar_service.dart';
import '../models/integration.dart';
import '../models/tool_definition.dart';
import '../tool_registry.dart';

/// Register calendar tools with the tool registry
///
/// This function registers all calendar-related tools that can be used
/// by the AI assistant to access device calendar.
///
/// Privacy: All calendar data stays on the device.
void registerCalendarTools(ToolRegistry registry, CalendarService calendarService) {
  // Tool: Get calendar events within a date range
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.getEvents',
      description:
          'Get calendar events within a date range from the device calendar. '
          'Returns all events that fall between the start and end dates. '
          'Use this when the user asks about their schedule or upcoming events.',
      service: 'calendar',
      parameters: {
        'start': ParamDef(
          type: 'string',
          description: 'Start date in ISO 8601 format (e.g., "2024-01-01T00:00:00Z")',
          required: true,
        ),
        'end': ParamDef(
          type: 'string',
          description: 'End date in ISO 8601 format (e.g., "2024-01-31T23:59:59Z")',
          required: true,
        ),
        'calendarIds': ParamDef(
          type: 'string[]',
          description: 'Optional list of calendar IDs to filter events',
          required: false,
        ),
      },
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final start = DateTime.parse(params['start'] as String);
      final end = DateTime.parse(params['end'] as String);
      final calendarIds = params['calendarIds'] as List<String>?;

      return await calendarService.getEvents(
        start: start,
        end: end,
        calendarIds: calendarIds,
      );
    },
  );

  // Tool: Get today's events
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.today',
      description:
          'Get all calendar events happening today. '
          'Convenience method that returns events from midnight today to midnight tomorrow. '
          'Use this when the user asks "What\'s on my calendar today?" or similar queries.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.getTodayEvents();
    },
  );

  // Tool: Get this week's events
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.thisWeek',
      description:
          'Get all calendar events happening this week (next 7 days). '
          'Use this when the user asks about their schedule for the week.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.getThisWeekEvents();
    },
  );

  // Tool: Get this month's events
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.thisMonth',
      description:
          'Get all calendar events happening this month. '
          'Use this when the user asks about their schedule for the month.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.getThisMonthEvents();
    },
  );

  // Tool: Create a new event
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.create',
      description:
          'Create a new calendar event. '
          'Use this when the user asks to add, create, or schedule an event. '
          'Returns the created event or null if creation failed.',
      service: 'calendar',
      parameters: {
        'title': ParamDef(
          type: 'string',
          description: 'Title of the event',
          required: true,
        ),
        'startDate': ParamDef(
          type: 'string',
          description: 'Start date/time in ISO 8601 format',
          required: true,
        ),
        'endDate': ParamDef(
          type: 'string',
          description: 'End date/time in ISO 8601 format',
          required: true,
        ),
        'isAllDay': ParamDef(
          type: 'boolean',
          description: 'Whether this is an all-day event',
          required: false,
          defaultValue: false,
        ),
        'location': ParamDef(
          type: 'string',
          description: 'Location of the event',
          required: false,
        ),
        'notes': ParamDef(
          type: 'string',
          description: 'Notes or description for the event',
          required: false,
        ),
        'calendarId': ParamDef(
          type: 'string',
          description: 'ID of the calendar to add the event to (defaults to default calendar)',
          required: false,
        ),
      },
      returnType: 'CalendarEvent | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final title = params['title'] as String;
      final startDate = DateTime.parse(params['startDate'] as String);
      final endDate = DateTime.parse(params['endDate'] as String);
      final isAllDay = params['isAllDay'] as bool? ?? false;
      final location = params['location'] as String?;
      final notes = params['notes'] as String?;
      final calendarId = params['calendarId'] as String?;

      return await calendarService.createEvent(
        title: title,
        startDate: startDate,
        endDate: endDate,
        isAllDay: isAllDay,
        location: location,
        notes: notes,
        calendarId: calendarId,
      );
    },
  );

  // Tool: Update an existing event
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.update',
      description:
          'Update an existing calendar event. '
          'Use this when the user asks to modify, change, or update an event. '
          'Only provided fields will be updated.',
      service: 'calendar',
      parameters: {
        'eventId': ParamDef(
          type: 'string',
          description: 'Unique identifier of the event to update',
          required: true,
        ),
        'title': ParamDef(
          type: 'string',
          description: 'New title for the event',
          required: false,
        ),
        'startDate': ParamDef(
          type: 'string',
          description: 'New start date/time in ISO 8601 format',
          required: false,
        ),
        'endDate': ParamDef(
          type: 'string',
          description: 'New end date/time in ISO 8601 format',
          required: false,
        ),
        'isAllDay': ParamDef(
          type: 'boolean',
          description: 'Whether this should be an all-day event',
          required: false,
        ),
        'location': ParamDef(
          type: 'string',
          description: 'New location for the event',
          required: false,
        ),
        'notes': ParamDef(
          type: 'string',
          description: 'New notes or description for the event',
          required: false,
        ),
      },
      returnType: 'CalendarEvent | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final eventId = params['eventId'] as String;
      final title = params['title'] as String?;
      final startDate = params['startDate'] != null ? DateTime.parse(params['startDate'] as String) : null;
      final endDate = params['endDate'] != null ? DateTime.parse(params['endDate'] as String) : null;
      final isAllDay = params['isAllDay'] as bool?;
      final location = params['location'] as String?;
      final notes = params['notes'] as String?;

      return await calendarService.updateEvent(
        eventId: eventId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        isAllDay: isAllDay,
        location: location,
        notes: notes,
      );
    },
  );

  // Tool: Delete an event
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.delete',
      description:
          'Delete a calendar event by its ID. '
          'Use this when the user asks to remove, cancel, or delete an event. '
          'Returns true if deletion was successful.',
      service: 'calendar',
      parameters: {
        'eventId': ParamDef(
          type: 'string',
          description: 'Unique identifier of the event to delete',
          required: true,
        ),
      },
      returnType: 'boolean',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final eventId = params['eventId'] as String;
      return await calendarService.deleteEvent(eventId);
    },
  );

  // Tool: Get available calendars
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.getCalendars',
      description:
          'Get all available calendars on the device. '
          'Use this when the user wants to see which calendars are available or select a calendar.',
      service: 'calendar',
      parameters: {},
      returnType: 'DeviceCalendar[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.getCalendars();
    },
  );

  // Tool: Check calendar permission
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.checkPermission',
      description:
          'Check the current permission status for accessing calendar. '
          'Returns one of: notDetermined, authorized, denied, restricted.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.checkPermission();
    },
  );

  // Tool: Request calendar permission
  registry.registerTool(
    ToolDefinition(
      name: 'calendar.requestPermission',
      description:
          'Request permission to access calendar. Shows system permission dialog if not determined. '
          'Use this before attempting to access calendar if permission is not granted.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await calendarService.requestPermission();
    },
  );
}

/// Get calendar tool definitions as a list
///
/// This is useful for systems that need to introspect available tools
/// without registering them.
List<ToolDefinition> getCalendarToolDefinitions() {
  return [
    ToolDefinition(
      name: 'calendar.getEvents',
      description: 'Get calendar events within a date range from the device calendar.',
      service: 'calendar',
      parameters: {
        'start': ParamDef(
          type: 'string',
          description: 'Start date (ISO 8601)',
          required: true,
        ),
        'end': ParamDef(
          type: 'string',
          description: 'End date (ISO 8601)',
          required: true,
        ),
        'calendarIds': ParamDef(
          type: 'string[]',
          description: 'Optional calendar IDs to filter',
          required: false,
        ),
      },
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.today',
      description: 'Get all calendar events happening today.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.thisWeek',
      description: 'Get all calendar events happening this week.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.thisMonth',
      description: 'Get all calendar events happening this month.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarEvent[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.create',
      description: 'Create a new calendar event.',
      service: 'calendar',
      parameters: {
        'title': ParamDef(type: 'string', description: 'Title of the event', required: true),
        'startDate': ParamDef(type: 'string', description: 'Start date (ISO 8601)', required: true),
        'endDate': ParamDef(type: 'string', description: 'End date (ISO 8601)', required: true),
        'isAllDay': ParamDef(type: 'boolean', description: 'All-day event', required: false, defaultValue: false),
        'location': ParamDef(type: 'string', description: 'Event location', required: false),
        'notes': ParamDef(type: 'string', description: 'Event notes', required: false),
        'calendarId': ParamDef(type: 'string', description: 'Calendar ID', required: false),
      },
      returnType: 'CalendarEvent | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.update',
      description: 'Update an existing calendar event.',
      service: 'calendar',
      parameters: {
        'eventId': ParamDef(type: 'string', description: 'Event ID', required: true),
        'title': ParamDef(type: 'string', description: 'New title', required: false),
        'startDate': ParamDef(type: 'string', description: 'New start date (ISO 8601)', required: false),
        'endDate': ParamDef(type: 'string', description: 'New end date (ISO 8601)', required: false),
        'isAllDay': ParamDef(type: 'boolean', description: 'All-day event', required: false),
        'location': ParamDef(type: 'string', description: 'New location', required: false),
        'notes': ParamDef(type: 'string', description: 'New notes', required: false),
      },
      returnType: 'CalendarEvent | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.delete',
      description: 'Delete a calendar event.',
      service: 'calendar',
      parameters: {
        'eventId': ParamDef(type: 'string', description: 'Event ID to delete', required: true),
      },
      returnType: 'boolean',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.getCalendars',
      description: 'Get all available calendars.',
      service: 'calendar',
      parameters: {},
      returnType: 'DeviceCalendar[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.checkPermission',
      description: 'Check calendar permission status.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'calendar.requestPermission',
      description: 'Request calendar permission.',
      service: 'calendar',
      parameters: {},
      returnType: 'CalendarPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
  ];
}
