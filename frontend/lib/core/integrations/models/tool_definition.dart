import 'integration.dart';

/// Parameter definition for a tool
///
/// Defines the type, constraints, and requirements for a tool parameter.
class ParamDef {
  /// Parameter type (string, number, boolean, array, object)
  final String type;

  /// Human-readable description of the parameter
  final String description;

  /// Whether this parameter is required
  final bool required;

  /// Default value if not provided
  final dynamic defaultValue;

  /// Allowed values for enum-style parameters
  final List<String>? enumValues;

  /// For array types, the type of array items
  final String? itemType;

  /// For object types, the schema of nested properties
  final Map<String, ParamDef>? properties;

  const ParamDef({
    required this.type,
    required this.description,
    this.required = false,
    this.defaultValue,
    this.enumValues,
    this.itemType,
    this.properties,
  });

  /// Create ParamDef from JSON
  factory ParamDef.fromJson(Map<String, dynamic> json) {
    return ParamDef(
      type: json['type'] as String,
      description: json['description'] as String,
      required: json['required'] as bool? ?? false,
      defaultValue: json['default_value'],
      enumValues: (json['enum_values'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      itemType: json['item_type'] as String?,
      properties: (json['properties'] as Map<String, dynamic>?)?.map(
        (key, value) =>
            MapEntry(key, ParamDef.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }

  /// Convert to JSON schema format
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'description': description,
    };

    if (defaultValue != null) {
      json['default'] = defaultValue;
    }

    if (enumValues != null && enumValues!.isNotEmpty) {
      json['enum'] = enumValues;
    }

    if (type == 'array' && itemType != null) {
      json['items'] = {'type': itemType};
    }

    if (type == 'object' && properties != null) {
      json['properties'] =
          properties!.map((key, value) => MapEntry(key, value.toJson()));
    }

    return json;
  }
}

/// Tool definition that AI can call
///
/// Represents a specific action or query that can be executed by the AI.
/// Tools are organized by service and follow the function calling schema
/// used by Claude and OpenAI.
class ToolDefinition {
  /// Unique tool name (e.g., "contacts.search", "gmail.send")
  final String name;

  /// Human-readable description of what the tool does
  final String description;

  /// Service this tool belongs to (e.g., "contacts", "gmail")
  final String service;

  /// Map of parameter names to their definitions
  final Map<String, ParamDef> parameters;

  /// Expected return type description
  final String returnType;

  /// Whether this tool requires authentication
  final bool requiresAuth;

  /// Privacy level for this tool's operation
  final PrivacyLevel privacy;

  /// Examples of tool usage (optional, for AI context)
  final List<String>? examples;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.service,
    required this.parameters,
    required this.returnType,
    this.requiresAuth = true,
    this.privacy = PrivacyLevel.withConsent,
    this.examples,
  });

  /// Create ToolDefinition from JSON
  factory ToolDefinition.fromJson(Map<String, dynamic> json) {
    return ToolDefinition(
      name: json['name'] as String,
      description: json['description'] as String,
      service: json['service'] as String,
      parameters: (json['parameters'] as Map<String, dynamic>? ?? {}).map(
        (key, value) =>
            MapEntry(key, ParamDef.fromJson(value as Map<String, dynamic>)),
      ),
      returnType: json['return_type'] as String,
      requiresAuth: json['requires_auth'] as bool? ?? true,
      privacy: PrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacy'],
        orElse: () => PrivacyLevel.withConsent,
      ),
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'service': service,
      'parameters':
          parameters.map((key, value) => MapEntry(key, value.toJson())),
      'return_type': returnType,
      'requires_auth': requiresAuth,
      'privacy': privacy.name,
      if (examples != null) 'examples': examples,
    };
  }

  /// Convert to Claude/OpenAI function calling schema
  ///
  /// Returns a schema compatible with:
  /// - Anthropic Claude's function calling
  /// - OpenAI's function calling
  Map<String, dynamic> toFunctionSchema() {
    final requiredParams = parameters.entries
        .where((e) => e.value.required)
        .map((e) => e.key)
        .toList();

    return {
      'name': name,
      'description': description,
      'parameters': {
        'type': 'object',
        'properties':
            parameters.map((key, value) => MapEntry(key, value.toJson())),
        if (requiredParams.isNotEmpty) 'required': requiredParams,
      },
    };
  }

  /// Get list of required parameter names
  List<String> get requiredParameters {
    return parameters.entries
        .where((e) => e.value.required)
        .map((e) => e.key)
        .toList();
  }

  /// Get list of optional parameter names
  List<String> get optionalParameters {
    return parameters.entries
        .where((e) => !e.value.required)
        .map((e) => e.key)
        .toList();
  }

  /// Validate parameters against this tool's schema
  bool validateParameters(Map<String, dynamic> params) {
    // Check all required parameters are present
    for (final required in requiredParameters) {
      if (!params.containsKey(required)) {
        return false;
      }
    }

    // Check parameter types (basic validation)
    for (final entry in params.entries) {
      if (!parameters.containsKey(entry.key)) {
        // Unknown parameter
        return false;
      }

      final paramDef = parameters[entry.key]!;
      final value = entry.value;

      // Type checking
      switch (paramDef.type) {
        case 'string':
          if (value is! String) return false;
          break;
        case 'number':
          if (value is! num) return false;
          break;
        case 'boolean':
          if (value is! bool) return false;
          break;
        case 'array':
          if (value is! List) return false;
          break;
        case 'object':
          if (value is! Map) return false;
          break;
      }

      // Enum validation
      if (paramDef.enumValues != null &&
          paramDef.enumValues!.isNotEmpty &&
          value is String) {
        if (!paramDef.enumValues!.contains(value)) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ToolDefinition &&
        other.name == name &&
        other.service == service;
  }

  @override
  int get hashCode => Object.hash(name, service);
}
