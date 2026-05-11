import '../../services/local/contacts_service.dart';
import '../models/integration.dart';
import '../models/tool_definition.dart';
import '../tool_registry.dart';

/// Register contacts tools with the tool registry
///
/// This function registers all contacts-related tools that can be used
/// by the AI assistant to access device contacts.
///
/// Privacy: All contacts data stays on the device.
void registerContactsTools(ToolRegistry registry, ContactsService contactsService) {
  // Tool: Search contacts by name
  registry.registerTool(
    ToolDefinition(
      name: 'contacts.search',
      description:
          'Search contacts by name on the device. Returns matching contacts with phone numbers and emails. '
          'Use this when the user asks to find a contact, call someone, or get contact information.',
      service: 'contacts',
      parameters: {
        'query': ParamDef(
          type: 'string',
          description: 'Name to search for (case-insensitive, partial matches allowed)',
          required: true,
        ),
      },
      returnType: 'Contact[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final query = params['query'] as String;
      return await contactsService.search(query);
    },
  );

  // Tool: Get all contacts
  registry.registerTool(
    ToolDefinition(
      name: 'contacts.getAll',
      description:
          'Get all contacts from the device with an optional limit. '
          'Use this when the user asks to see their contacts list or wants to browse contacts.',
      service: 'contacts',
      parameters: {
        'limit': ParamDef(
          type: 'integer',
          description: 'Maximum number of contacts to return (default: 100)',
          required: false,
          defaultValue: 100,
        ),
      },
      returnType: 'Contact[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final limit = params['limit'] as int? ?? 100;
      return await contactsService.getAll(limit: limit);
    },
  );

  // Tool: Get contact by ID
  registry.registerTool(
    ToolDefinition(
      name: 'contacts.getById',
      description:
          'Get a specific contact by its unique ID. '
          'Use this when you need to retrieve details for a specific contact.',
      service: 'contacts',
      parameters: {
        'id': ParamDef(
          type: 'string',
          description: 'Unique identifier of the contact',
          required: true,
        ),
      },
      returnType: 'Contact | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      final id = params['id'] as String;
      return await contactsService.getById(id);
    },
  );

  // Tool: Check contacts permission
  registry.registerTool(
    ToolDefinition(
      name: 'contacts.checkPermission',
      description:
          'Check the current permission status for accessing contacts. '
          'Returns one of: notDetermined, authorized, denied, restricted.',
      service: 'contacts',
      parameters: {},
      returnType: 'ContactsPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await contactsService.checkPermission();
    },
  );

  // Tool: Request contacts permission
  registry.registerTool(
    ToolDefinition(
      name: 'contacts.requestPermission',
      description:
          'Request permission to access contacts. Shows system permission dialog if not determined. '
          'Use this before attempting to access contacts if permission is not granted.',
      service: 'contacts',
      parameters: {},
      returnType: 'ContactsPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    (params) async {
      return await contactsService.requestPermission();
    },
  );
}

/// Get contacts tool definitions as a list
///
/// This is useful for systems that need to introspect available tools
/// without registering them.
List<ToolDefinition> getContactsToolDefinitions() {
  return [
    ToolDefinition(
      name: 'contacts.search',
      description:
          'Search contacts by name on the device. Returns matching contacts with phone numbers and emails.',
      service: 'contacts',
      parameters: {
        'query': ParamDef(
          type: 'string',
          description: 'Name to search for',
          required: true,
        ),
      },
      returnType: 'Contact[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'contacts.getAll',
      description: 'Get all contacts from the device with an optional limit.',
      service: 'contacts',
      parameters: {
        'limit': ParamDef(
          type: 'integer',
          description: 'Maximum number of contacts to return',
          required: false,
          defaultValue: 100,
        ),
      },
      returnType: 'Contact[]',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'contacts.getById',
      description: 'Get a specific contact by its unique ID.',
      service: 'contacts',
      parameters: {
        'id': ParamDef(
          type: 'string',
          description: 'Unique identifier of the contact',
          required: true,
        ),
      },
      returnType: 'Contact | null',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'contacts.checkPermission',
      description: 'Check the current permission status for accessing contacts.',
      service: 'contacts',
      parameters: {},
      returnType: 'ContactsPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
    ToolDefinition(
      name: 'contacts.requestPermission',
      description: 'Request permission to access contacts.',
      service: 'contacts',
      parameters: {},
      returnType: 'ContactsPermissionStatus',
      requiresAuth: false,
      privacy: PrivacyLevel.onDevice,
    ),
  ];
}
