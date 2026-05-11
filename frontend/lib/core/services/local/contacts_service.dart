import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contact model representing a device contact
class Contact {
  /// Unique identifier for the contact
  final String id;

  /// Given name (first name)
  final String givenName;

  /// Family name (last name)
  final String familyName;

  /// Full name (combination of given and family name)
  final String fullName;

  /// List of phone numbers associated with the contact
  final List<String> phones;

  /// List of email addresses associated with the contact
  final List<String> emails;

  /// Organization or company name
  final String? organization;

  const Contact({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.fullName,
    required this.phones,
    required this.emails,
    this.organization,
  });

  /// Create a Contact from a map (from native platform)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String? ?? '',
      givenName: map['givenName'] as String? ?? '',
      familyName: map['familyName'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phones: (map['phones'] as List<dynamic>?)?.cast<String>() ?? [],
      emails: (map['emails'] as List<dynamic>?)?.cast<String>() ?? [],
      organization: map['organization'] as String?,
    );
  }

  /// Convert Contact to a map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'fullName': fullName,
      'phones': phones,
      'emails': emails,
      'organization': organization,
    };
  }

  /// Get primary phone number (first in list)
  String? get primaryPhone => phones.isNotEmpty ? phones.first : null;

  /// Get primary email (first in list)
  String? get primaryEmail => emails.isNotEmpty ? emails.first : null;

  /// Check if contact has any phone numbers
  bool get hasPhones => phones.isNotEmpty;

  /// Check if contact has any emails
  bool get hasEmails => emails.isNotEmpty;

  @override
  String toString() {
    return 'Contact(id: $id, fullName: $fullName, phones: $phones, emails: $emails)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Permission status for contacts access
enum ContactsPermissionStatus {
  /// Permission has not been requested yet
  notDetermined,

  /// Permission has been granted
  authorized,

  /// Permission has been denied by user
  denied,

  /// Permission is restricted (e.g., by parental controls)
  restricted
}

/// Service for accessing device contacts via iOS native bridge
///
/// This service communicates with the iOS native ContactsManager
/// through the method channel 'com.jarvis/contacts'.
class ContactsService {
  static const _channel = MethodChannel('com.jarvis/contacts');

  /// Request permission to access contacts
  ///
  /// This will show the system permission dialog if permission
  /// has not been determined yet.
  ///
  /// Returns the current permission status after the request.
  Future<ContactsPermissionStatus> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<String>('requestPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to request contacts permission: ${e.message}');
    }
  }

  /// Check current permission status without requesting
  ///
  /// Returns the current permission status without showing
  /// any system dialogs.
  Future<ContactsPermissionStatus> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<String>('checkPermission');
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to check contacts permission: ${e.message}');
    }
  }

  /// Search contacts by name
  ///
  /// Searches for contacts matching the given [query] string.
  /// The search is case-insensitive and matches against full name,
  /// given name, and family name.
  ///
  /// Returns a list of matching contacts, or an empty list if no matches found.
  ///
  /// Throws an exception if permission is not granted.
  Future<List<Contact>> search(String query) async {
    try {
      final result = await _channel.invokeMethod<List>('search', {'query': query});
      if (result == null) return [];

      return result
          .map((c) => Contact.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Contacts permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to search contacts: ${e.message}');
    }
  }

  /// Get all contacts with optional limit
  ///
  /// Retrieves contacts from the device, up to the specified [limit].
  /// Default limit is 100 contacts. Set to a higher value if needed.
  ///
  /// Returns a list of contacts, or an empty list if no contacts found.
  ///
  /// Throws an exception if permission is not granted.
  Future<List<Contact>> getAll({int limit = 100}) async {
    try {
      final result = await _channel.invokeMethod<List>('getAll', {'limit': limit});
      if (result == null) return [];

      return result
          .map((c) => Contact.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Contacts permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to get contacts: ${e.message}');
    }
  }

  /// Get contact by ID
  ///
  /// Retrieves a single contact by its unique [id].
  ///
  /// Returns the contact if found, null otherwise.
  ///
  /// Throws an exception if permission is not granted.
  Future<Contact?> getById(String id) async {
    try {
      final result = await _channel.invokeMethod<Map>('getById', {'id': id});
      if (result == null) return null;

      return Contact.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception('Contacts permission denied. Please grant access in Settings.');
      }
      throw Exception('Failed to get contact: ${e.message}');
    }
  }

  /// Parse permission status string from native platform
  ContactsPermissionStatus _parsePermissionStatus(String? status) {
    if (status == null) return ContactsPermissionStatus.notDetermined;

    switch (status.toLowerCase()) {
      case 'authorized':
        return ContactsPermissionStatus.authorized;
      case 'denied':
        return ContactsPermissionStatus.denied;
      case 'restricted':
        return ContactsPermissionStatus.restricted;
      case 'notdetermined':
      default:
        return ContactsPermissionStatus.notDetermined;
    }
  }
}

/// Riverpod provider for ContactsService
///
/// Use this provider to access the contacts service throughout the app.
final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService();
});

/// Riverpod provider for contacts permission status
///
/// This provider watches the current permission status.
/// Refresh to re-check permissions.
final contactsPermissionProvider = FutureProvider<ContactsPermissionStatus>((ref) {
  return ref.watch(contactsServiceProvider).checkPermission();
});
