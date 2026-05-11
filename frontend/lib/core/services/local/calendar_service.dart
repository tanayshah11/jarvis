import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calendar model representing a device calendar
class DeviceCalendar {
  /// Unique identifier for the calendar
  final String id;

  /// Display title of the calendar
  final String title;

  /// Hex color code for the calendar (e.g., "#FF5733")
  final String? color;

  /// Whether this is the default calendar
  final bool isDefault;

  const DeviceCalendar({
    required this.id,
    required this.title,
    this.color,
    this.isDefault = false,
  });

  /// Create a DeviceCalendar from a map (from native platform)
  factory DeviceCalendar.fromMap(Map<String, dynamic> map) {
    return DeviceCalendar(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      color: map['color'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  /// Convert DeviceCalendar to a map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() {
    return 'DeviceCalendar(id: $id, title: $title, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceCalendar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Calendar event model representing a calendar event
class CalendarEvent {
  /// Unique identifier for the event
  final String id;

  /// Title of the event
  final String title;

  /// Start date and time of the event
  final DateTime startDate;

  /// End date and time of the event
  final DateTime endDate;

  /// Whether this is an all-day event
  final bool isAllDay;

  /// Location of the event
  final String? location;

  /// Notes or description of the event
  final String? notes;

  /// ID of the calendar this event belongs to
  final String calendarId;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.isAllDay = false,
    this.location,
    this.notes,
    required this.calendarId,
  });

  /// Create a CalendarEvent from a map (from native platform)
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      startDate: DateTime.parse(map['startDate'] as String).toLocal(),
      endDate: DateTime.parse(map['endDate'] as String).toLocal(),
      isAllDay: map['isAllDay'] as bool? ?? false,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      calendarId: map['calendarId'] as String? ?? '',
    );
  }

  /// Convert CalendarEvent to a map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isAllDay': isAllDay,
      'location': location,
      'notes': notes,
      'calendarId': calendarId,
    };
  }

  /// Duration of the event
  Duration get duration => endDate.difference(startDate);

  /// Check if event is happening now
  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if event is in the past
  bool get isPast {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  /// Check if event is in the future
  bool get isFuture {
    final now = DateTime.now();
    return startDate.isAfter(now);
  }

  /// Check if event is happening today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return startDate.isBefore(tomorrow) && endDate.isAfter(today);
  }

  /// Get formatted duration string (e.g., "2h 30m")
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, start: $startDate, end: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Permission status for calendar access
enum CalendarPermissionStatus {
  /// Permission has not been requested yet
  notDetermined,

  /// Permission has been granted
  authorized,

  /// Permission has been denied by user
  denied,

  /// Permission is restricted (e.g., by parental controls)
  restricted
}

/// Service for accessing device calendar via iOS native bridge
///
/// This service communicates with the iOS native CalendarManager
/// through the method channel 'com.jarvis/calendar'.
class CalendarService {
  static const _channel = MethodChannel('com.jarvis/calendar');

  /// Request permission to access calendar
  ///
  /// This will show the system permission dialog if permission
  /// has not been determined yet.
  ///
  /// Returns the current permission status after the request.
  Future<CalendarPermissionStatus> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<String>('requestPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to request calendar permission: ${e.message}');
    }
  }

  /// Check current permission status without requesting
  ///
  /// Returns the current permission status without showing
  /// any system dialogs.
  Future<CalendarPermissionStatus> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<String>('checkPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to check calendar permission: ${e.message}');
    }
  }

  /// Get all calendars from the device
  ///
  /// Returns a list of all available calendars.
  ///
  /// Throws an exception if permission is not granted.
  Future<List<DeviceCalendar>> getCalendars() async {
    try {
      final result = await _channel.invokeMethod<List>('getCalendars');
      if (result == null) return [];

      return result
          .map((c) => DeviceCalendar.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Calendar permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to get calendars: ${e.message}');
    }
  }

  /// Get events within a date range
  ///
  /// Retrieves events between [start] and [end] dates.
  /// Optionally filter by specific [calendarIds].
  ///
  /// Returns a list of events, or an empty list if no events found.
  ///
  /// Throws an exception if permission is not granted.
  Future<List<CalendarEvent>> getEvents({
    required DateTime start,
    required DateTime end,
    List<String>? calendarIds,
  }) async {
    try {
      final params = {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        if (calendarIds != null) 'calendarIds': calendarIds,
      };

      final result = await _channel.invokeMethod<List>('getEvents', params);
      if (result == null) return [];

      return result
          .map((e) => CalendarEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Calendar permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to get events: ${e.message}');
    }
  }

  /// Get events for today
  ///
  /// Convenience method to retrieve all events happening today.
  Future<List<CalendarEvent>> getTodayEvents() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getEvents(start: start, end: end);
  }

  /// Get events for this week
  ///
  /// Convenience method to retrieve all events happening this week.
  Future<List<CalendarEvent>> getThisWeekEvents() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    return getEvents(start: start, end: end);
  }

  /// Get events for this month
  ///
  /// Convenience method to retrieve all events happening this month.
  Future<List<CalendarEvent>> getThisMonthEvents() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return getEvents(start: start, end: end);
  }

  /// Create a new event
  ///
  /// Creates a new calendar event with the specified details.
  /// If [calendarId] is not provided, the default calendar will be used.
  ///
  /// Returns the created event if successful, null otherwise.
  ///
  /// Throws an exception if permission is not granted.
  Future<CalendarEvent?> createEvent({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    bool isAllDay = false,
    String? location,
    String? notes,
    String? calendarId,
  }) async {
    try {
      final params = {
        'title': title,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        'isAllDay': isAllDay,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        if (calendarId != null) 'calendarId': calendarId,
      };

      final result = await _channel.invokeMethod<Map>('createEvent', params);
      if (result == null) return null;

      return CalendarEvent.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Calendar permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to create event: ${e.message}');
    }
  }

  /// Update an existing event
  ///
  /// Updates an existing calendar event with the specified details.
  /// Only provided fields will be updated.
  ///
  /// Returns the updated event if successful, null otherwise.
  ///
  /// Throws an exception if permission is not granted.
  Future<CalendarEvent?> updateEvent({
    required String eventId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    String? location,
    String? notes,
  }) async {
    try {
      final params = {
        'eventId': eventId,
        if (title != null) 'title': title,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if (isAllDay != null) 'isAllDay': isAllDay,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

      final result = await _channel.invokeMethod<Map>('updateEvent', params);
      if (result == null) return null;

      return CalendarEvent.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Calendar permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to update event: ${e.message}');
    }
  }

  /// Delete an event
  ///
  /// Deletes a calendar event by its [eventId].
  ///
  /// Returns true if deletion was successful, false otherwise.
  ///
  /// Throws an exception if permission is not granted.
  Future<bool> deleteEvent(String eventId) async {
    try {
      final result = await _channel.invokeMethod<Map>('deleteEvent', {'eventId': eventId});
      if (result == null) return false;
      return result['success'] as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Calendar permission denied. Please grant access in Settings.');
      }
      if (e.code == 'EVENT_NOT_FOUND') {
        return false; // Event already deleted or doesn't exist
      }
      throw Exception('Failed to delete event: ${e.message}');
    }
  }

  /// Parse permission status string from native platform
  CalendarPermissionStatus _parsePermissionStatus(String? status) {
    if (status == null) return CalendarPermissionStatus.notDetermined;

    switch (status.toLowerCase()) {
      case 'authorized':
        return CalendarPermissionStatus.authorized;
      case 'denied':
        return CalendarPermissionStatus.denied;
      case 'restricted':
        return CalendarPermissionStatus.restricted;
      case 'notdetermined':
      default:
        return CalendarPermissionStatus.notDetermined;
    }
  }
}

/// Riverpod provider for CalendarService
///
/// Use this provider to access the calendar service throughout the app.
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

/// Riverpod provider for calendar permission status
///
/// This provider watches the current permission status.
/// Refresh to re-check permissions.
final calendarPermissionProvider = FutureProvider<CalendarPermissionStatus>((ref) {
  return ref.watch(calendarServiceProvider).checkPermission();
});

/// Riverpod provider for available calendars
///
/// This provider fetches all available calendars from the device.
final calendarsProvider = FutureProvider<List<DeviceCalendar>>((ref) {
  return ref.watch(calendarServiceProvider).getCalendars();
});

/// Riverpod provider for today's events
///
/// This provider fetches all events happening today.
final todayEventsProvider = FutureProvider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarServiceProvider).getTodayEvents();
});

/// Riverpod provider for this week's events
///
/// This provider fetches all events happening this week.
final thisWeekEventsProvider = FutureProvider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarServiceProvider).getThisWeekEvents();
});
