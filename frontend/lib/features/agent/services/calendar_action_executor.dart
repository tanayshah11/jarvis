/// Calendar Action Executor - Executes calendar intents using native calendar
///
/// Parses natural language dates and creates real calendar events.
library;

import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local/calendar_service.dart';

const String _logName = 'CalendarActionExecutor';

/// Result of executing a calendar action
class CalendarActionResult {
  final bool success;
  final CalendarEvent? event;
  final String message;
  final String? error;

  const CalendarActionResult({
    required this.success,
    this.event,
    required this.message,
    this.error,
  });

  factory CalendarActionResult.success(CalendarEvent event, String message) =>
      CalendarActionResult(success: true, event: event, message: message);

  factory CalendarActionResult.failure(String error) =>
      CalendarActionResult(success: false, message: error, error: error);
}

/// Calendar action executor provider
final calendarActionExecutorProvider = Provider<CalendarActionExecutor>((ref) {
  return CalendarActionExecutor(ref.watch(calendarServiceProvider));
});

/// Executes calendar-related actions
class CalendarActionExecutor {
  final CalendarService _calendarService;

  CalendarActionExecutor(this._calendarService);

  /// Execute a createEvent action from NLU intent
  ///
  /// Takes the action payload with attendees, date, time, location
  /// and creates an actual calendar event.
  Future<CalendarActionResult> executeCreateEvent({
    required List<String> attendees,
    String? dateString,
    String? timeString,
    String? location,
    String? title,
    String? notes,
  }) async {
    try {
      // Check permission first
      final permission = await _calendarService.checkPermission();
      if (permission != CalendarPermissionStatus.authorized) {
        final requested = await _calendarService.requestPermission();
        if (requested != CalendarPermissionStatus.authorized) {
          return CalendarActionResult.failure(
            'Calendar permission denied. Please enable calendar access in Settings.',
          );
        }
      }

      // Parse date and time
      final (startDate, endDate) = _parseDateAndTime(dateString, timeString);

      if (startDate == null) {
        return CalendarActionResult.failure(
          'Could not determine when to schedule the event. Please specify a date and time.',
        );
      }

      // Build event title
      final eventTitle = title ??
          (attendees.isNotEmpty
              ? 'Meeting with ${attendees.join(", ")}'
              : 'New Event');

      // Build notes with attendees
      final eventNotes = StringBuffer();
      if (attendees.isNotEmpty) {
        eventNotes.writeln('Attendees: ${attendees.join(", ")}');
      }
      if (notes != null && notes.isNotEmpty) {
        eventNotes.writeln(notes);
      }

      developer.log(
        'Creating event: "$eventTitle" at $startDate',
        name: _logName,
      );

      // Create the event
      final event = await _calendarService.createEvent(
        title: eventTitle,
        startDate: startDate,
        endDate: endDate ?? startDate.add(const Duration(hours: 1)),
        location: location,
        notes: eventNotes.isNotEmpty ? eventNotes.toString() : null,
      );

      if (event == null) {
        return CalendarActionResult.failure(
          'Failed to create calendar event. Please try again.',
        );
      }

      developer.log(
        'Event created successfully: ${event.id}',
        name: _logName,
      );

      // Build confirmation message
      final formattedDate = _formatDateTime(startDate);
      final confirmMessage = attendees.isNotEmpty
          ? "I've added a meeting with ${attendees.join(" and ")} to your calendar for $formattedDate."
          : "I've added \"$eventTitle\" to your calendar for $formattedDate.";

      return CalendarActionResult.success(event, confirmMessage);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create event: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return CalendarActionResult.failure('Error creating event: $e');
    }
  }

  /// Execute an updateEvent action
  Future<CalendarActionResult> executeUpdateEvent({
    required String eventId,
    String? title,
    String? dateString,
    String? timeString,
    String? location,
    String? notes,
  }) async {
    try {
      DateTime? startDate;
      DateTime? endDate;

      if (dateString != null || timeString != null) {
        final parsed = _parseDateAndTime(dateString, timeString);
        startDate = parsed.$1;
        endDate = parsed.$2;
      }

      final event = await _calendarService.updateEvent(
        eventId: eventId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        location: location,
        notes: notes,
      );

      if (event == null) {
        return CalendarActionResult.failure('Failed to update event.');
      }

      return CalendarActionResult.success(
        event,
        "I've updated the event on your calendar.",
      );
    } catch (e) {
      return CalendarActionResult.failure('Error updating event: $e');
    }
  }

  /// Execute a deleteEvent action
  Future<CalendarActionResult> executeDeleteEvent(String eventId) async {
    try {
      final success = await _calendarService.deleteEvent(eventId);
      if (!success) {
        return CalendarActionResult.failure('Failed to delete event.');
      }
      return CalendarActionResult(
        success: true,
        message: "I've removed the event from your calendar.",
      );
    } catch (e) {
      return CalendarActionResult.failure('Error deleting event: $e');
    }
  }

  /// Parse natural language date and time strings into DateTime
  ///
  /// Supports:
  /// - "today", "tomorrow", "next Monday", etc.
  /// - "2pm", "14:00", "2:30 PM", etc.
  /// - Combined: "tomorrow at 2pm"
  (DateTime?, DateTime?) _parseDateAndTime(String? dateString, String? timeString) {
    DateTime baseDate = DateTime.now();

    // Parse date
    if (dateString != null) {
      final dateLower = dateString.toLowerCase().trim();

      if (dateLower == 'today') {
        baseDate = DateTime.now();
      } else if (dateLower == 'tomorrow') {
        baseDate = DateTime.now().add(const Duration(days: 1));
      } else if (dateLower == 'yesterday') {
        baseDate = DateTime.now().subtract(const Duration(days: 1));
      } else if (dateLower.startsWith('next ')) {
        final dayName = dateLower.substring(5);
        baseDate = _getNextDayOfWeek(dayName);
      } else {
        // Try to match day names
        final dayMatch = _parseDayOfWeek(dateLower);
        if (dayMatch != null) {
          baseDate = dayMatch;
        }
      }
    }

    // Parse time
    int hour = 9; // Default to 9 AM
    int minute = 0;
    bool timeSpecified = false;

    if (timeString != null) {
      final timeLower = timeString.toLowerCase().trim();

      // Try various time formats
      final timePatterns = [
        // "2pm", "2 pm", "2PM"
        RegExp(r'^(\d{1,2})\s*(am|pm)$', caseSensitive: false),
        // "2:30pm", "2:30 pm"
        RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)?$', caseSensitive: false),
        // "14:00", "14:30"
        RegExp(r'^(\d{1,2}):(\d{2})$'),
      ];

      for (final pattern in timePatterns) {
        final match = pattern.firstMatch(timeLower);
        if (match != null) {
          hour = int.parse(match.group(1)!);
          minute = match.groupCount >= 2 && match.group(2) != null
              ? int.tryParse(match.group(2)!) ?? 0
              : 0;

          // Handle AM/PM
          final amPm = match.groupCount >= 3 ? match.group(3) : null;
          if (amPm != null) {
            if (amPm.toLowerCase() == 'pm' && hour < 12) {
              hour += 12;
            } else if (amPm.toLowerCase() == 'am' && hour == 12) {
              hour = 0;
            }
          }

          timeSpecified = true;
          break;
        }
      }
    }

    if (!timeSpecified && dateString == null) {
      // No date or time specified
      return (null, null);
    }

    // Combine date and time
    final startDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );

    // Default to 1 hour duration
    final endDate = startDate.add(const Duration(hours: 1));

    return (startDate, endDate);
  }

  /// Get the next occurrence of a day of the week
  DateTime _getNextDayOfWeek(String dayName) {
    final targetDay = _dayNameToWeekday(dayName);
    if (targetDay == null) return DateTime.now();

    final now = DateTime.now();
    var daysUntil = targetDay - now.weekday;
    if (daysUntil <= 0) daysUntil += 7;

    return now.add(Duration(days: daysUntil));
  }

  /// Parse a day name that might be this week or next
  DateTime? _parseDayOfWeek(String dayName) {
    final targetDay = _dayNameToWeekday(dayName);
    if (targetDay == null) return null;

    final now = DateTime.now();
    var daysUntil = targetDay - now.weekday;
    if (daysUntil < 0) daysUntil += 7;
    if (daysUntil == 0) daysUntil = 7; // If same day, assume next week

    return now.add(Duration(days: daysUntil));
  }

  /// Convert day name to weekday number (Monday = 1, Sunday = 7)
  int? _dayNameToWeekday(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
      case 'mon':
        return DateTime.monday;
      case 'tuesday':
      case 'tue':
        return DateTime.tuesday;
      case 'wednesday':
      case 'wed':
        return DateTime.wednesday;
      case 'thursday':
      case 'thu':
        return DateTime.thursday;
      case 'friday':
      case 'fri':
        return DateTime.friday;
      case 'saturday':
      case 'sat':
        return DateTime.saturday;
      case 'sunday':
      case 'sun':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  /// Format DateTime for user-friendly display
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(date.year, date.month, date.day);

    String dayPart;
    if (eventDay == today) {
      dayPart = 'today';
    } else if (eventDay == tomorrow) {
      dayPart = 'tomorrow';
    } else {
      final weekdays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      dayPart = weekdays[date.weekday - 1];
    }

    // Format time
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final timePart = date.minute == 0 ? '$hour $amPm' : '$hour:$minute $amPm';

    return '$dayPart at $timePart';
  }
}
