// Calendar Integration Test - Creates real calendar events
//
// Run with: flutter test integration_test/calendar_integration_test.dart -d <device_id>

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarvis/core/services/local/calendar_service.dart';
import 'package:jarvis/features/agent/services/calendar_action_executor.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late CalendarService calendarService;
  late CalendarActionExecutor calendarExecutor;

  setUpAll(() {
    calendarService = CalendarService();
    calendarExecutor = CalendarActionExecutor(calendarService);
  });

  // No tearDownAll - events will persist in the calendar!

  testWidgets('Create calendar events', (tester) async {
    // Request permission
    final permission = await calendarService.requestPermission();
    print('Permission status: $permission');

    // Create: Lunch with Sarah tomorrow at noon
    final lunch = await calendarExecutor.executeCreateEvent(
      attendees: ['Sarah'],
      dateString: 'tomorrow',
      timeString: '12pm',
      title: 'Lunch with Sarah',
      location: 'Kokkari Estiatorio',
    );
    print('Created: ${lunch.message}');

    // Create: Meeting with David on Tuesday at 2pm
    final meeting = await calendarExecutor.executeCreateEvent(
      attendees: ['David Thompson'],
      dateString: 'tuesday',
      timeString: '2pm',
      title: 'Meeting with David',
    );
    print('Created: ${meeting.message}');

    // Create: Dinner on Friday at 7pm
    final dinner = await calendarExecutor.executeCreateEvent(
      attendees: ['Alex'],
      dateString: 'friday',
      timeString: '7pm',
      title: 'Dinner with Alex',
      location: 'Lazy Bear Restaurant',
    );
    print('Created: ${dinner.message}');

    // Create: Team sync next Monday at 10am
    final sync = await calendarExecutor.executeCreateEvent(
      attendees: ['Team'],
      dateString: 'next monday',
      timeString: '10am',
      title: 'Team Sync',
      location: 'Conference Room A',
    );
    print('Created: ${sync.message}');

    print('\n✅ All events created! Check your calendar app.');
  });
}
