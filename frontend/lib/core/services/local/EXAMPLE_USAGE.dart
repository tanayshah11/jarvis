// ignore_for_file: unused_element, unused_local_variable, file_names, prefer_final_fields, dangling_library_doc_comments

/// Example usage of local device services (Contacts and Calendar).
///
/// This file demonstrates how to use the services in a real Flutter app.
/// It is not meant to be included in the build - it's for reference only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_services.dart';

// ============================================================================
// CONTACTS EXAMPLE
// ============================================================================

/// Example widget showing contacts search
class ContactsSearchExample extends ConsumerStatefulWidget {
  const ContactsSearchExample({super.key});

  @override
  ConsumerState<ContactsSearchExample> createState() => _ContactsSearchExampleState();
}

class _ContactsSearchExampleState extends ConsumerState<ContactsSearchExample> {
  final _searchController = TextEditingController();
  List<Contact> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final contactsService = ref.read(contactsServiceProvider);
      final results = await contactsService.search(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching contacts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = ref.watch(contactsPermissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Search')),
      body: permissionStatus.when(
        data: (status) {
          if (status != ContactsPermissionStatus.authorized) {
            return _buildPermissionRequest();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search contacts',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchContacts,
                ),
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final contact = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(contact.givenName.isNotEmpty
                            ? contact.givenName[0]
                            : '?'),
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(
                        contact.primaryPhone ?? contact.primaryEmail ?? '',
                      ),
                      trailing: contact.hasPhones
                          ? IconButton(
                              icon: const Icon(Icons.phone),
                              onPressed: () {
                                // Handle call action
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contacts, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Contacts Access Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please grant access to your contacts to use this feature',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final contactsService = ref.read(contactsServiceProvider);
              await contactsService.requestPermission();
              ref.invalidate(contactsPermissionProvider);
            },
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CALENDAR EXAMPLE
// ============================================================================

/// Example widget showing today's calendar events
class TodayEventsExample extends ConsumerWidget {
  const TodayEventsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(calendarPermissionProvider);
    final todayEvents = ref.watch(todayEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Schedule')),
      body: permissionStatus.when(
        data: (status) {
          if (status != CalendarPermissionStatus.authorized) {
            return _buildPermissionRequest(ref);
          }

          return todayEvents.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No events today'),
                    ],
                  ),
                );
              }

              // Sort events by start time
              final sortedEvents = List<CalendarEvent>.from(events)
                ..sort((a, b) => a.startDate.compareTo(b.startDate));

              return ListView.builder(
                itemCount: sortedEvents.length,
                itemBuilder: (context, index) {
                  final event = sortedEvents[index];
                  return _buildEventCard(event);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final isNow = event.isNow;
    final isPast = event.isPast;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isNow ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNow
              ? Colors.blue
              : isPast
                  ? Colors.grey
                  : Colors.green,
          child: Icon(
            event.isAllDay ? Icons.calendar_today : Icons.access_time,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
            decoration: isPast ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatEventTime(event)),
            if (event.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14),
                  const SizedBox(width: 4),
                  Expanded(child: Text(event.location!)),
                ],
              ),
            ],
          ],
        ),
        trailing: isNow
            ? Chip(
                label: const Text('Now', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue,
                labelStyle: const TextStyle(color: Colors.white),
              )
            : Text(event.formattedDuration),
      ),
    );
  }

  String _formatEventTime(CalendarEvent event) {
    if (event.isAllDay) {
      return 'All day';
    }

    final startTime = TimeOfDay.fromDateTime(event.startDate);
    final endTime = TimeOfDay.fromDateTime(event.endDate);

    return '${startTime.format} - ${endTime.format}';
  }

  Widget _buildPermissionRequest(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Calendar Access Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please grant access to your calendar to use this feature',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final calendarService = ref.read(calendarServiceProvider);
              await calendarService.requestPermission();
              ref.invalidate(calendarPermissionProvider);
            },
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CREATE EVENT EXAMPLE
// ============================================================================

/// Example widget for creating a new calendar event
class CreateEventExample extends ConsumerStatefulWidget {
  const CreateEventExample({super.key});

  @override
  ConsumerState<CreateEventExample> createState() => _CreateEventExampleState();
}

class _CreateEventExampleState extends ConsumerState<CreateEventExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final calendarService = ref.read(calendarServiceProvider);
      final event = await calendarService.createEvent(
        title: _titleController.text,
        startDate: _startDate,
        endDate: _endDate,
        isAllDay: _isAllDay,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (event != null && mounted) {
        // Refresh the events list
        ref.invalidate(todayEventsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('All-day event'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start'),
              subtitle: Text(_isAllDay
                  ? _formatDate(_startDate)
                  : _formatDateTime(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // Show date/time picker
              },
            ),
            ListTile(
              title: const Text('End'),
              subtitle: Text(_isAllDay
                  ? _formatDate(_endDate)
                  : _formatDateTime(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // Show date/time picker
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _createEvent,
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Extension for TimeOfDay formatting
extension on TimeOfDay {
  String get format {
    final hour = this.hour > 12 ? this.hour - 12 : this.hour;
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
