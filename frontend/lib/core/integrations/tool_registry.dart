import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/tool_definition.dart';

/// Handler function type for tool execution
typedef ToolHandler = Future<dynamic> Function(Map<String, dynamic> params);

/// Exception thrown when a tool is not found
class ToolNotFoundException implements Exception {
  final String toolName;
  ToolNotFoundException(this.toolName);

  @override
  String toString() => 'Tool not found: $toolName';
}

/// Exception thrown when tool execution fails
class ToolExecutionException implements Exception {
  final String toolName;
  final String message;
  final dynamic originalError;

  ToolExecutionException(this.toolName, this.message, [this.originalError]);

  @override
  String toString() => 'Tool execution failed [$toolName]: $message';
}

/// Central registry for all available tools
///
/// Manages tool registration, discovery, and execution.
/// Tools are registered by integrations and can be queried by the AI layer.
class ToolRegistry {
  final Map<String, ToolDefinition> _tools = {};
  final Map<String, ToolHandler> _handlers = {};
  final _toolChangesController = StreamController<void>.broadcast();

  /// Stream that emits when tools are added or removed
  Stream<void> get toolChanges => _toolChangesController.stream;

  /// Register a new tool with its handler
  ///
  /// [tool] - The tool definition
  /// [handler] - The function to execute when the tool is called
  ///
  /// Throws [ArgumentError] if a tool with the same name already exists.
  void registerTool(ToolDefinition tool, ToolHandler handler) {
    if (_tools.containsKey(tool.name)) {
      throw ArgumentError('Tool already registered: ${tool.name}');
    }

    _tools[tool.name] = tool;
    _handlers[tool.name] = handler;
    _toolChangesController.add(null);
  }

  /// Register multiple tools at once
  ///
  /// Useful for integrations that provide multiple tools.
  void registerTools(Map<ToolDefinition, ToolHandler> tools) {
    for (final entry in tools.entries) {
      registerTool(entry.key, entry.value);
    }
  }

  /// Unregister a tool by name
  ///
  /// Returns true if the tool was found and removed, false otherwise.
  bool unregisterTool(String name) {
    final removed = _tools.remove(name) != null;
    _handlers.remove(name);

    if (removed) {
      _toolChangesController.add(null);
    }

    return removed;
  }

  /// Unregister all tools for a specific service
  ///
  /// Returns the number of tools that were removed.
  int unregisterServiceTools(String service) {
    final toolsToRemove = _tools.values
        .where((tool) => tool.service == service)
        .map((tool) => tool.name)
        .toList();

    var count = 0;
    for (final name in toolsToRemove) {
      if (unregisterTool(name)) {
        count++;
      }
    }

    return count;
  }

  /// Get a tool definition by name
  ToolDefinition? getTool(String name) {
    return _tools[name];
  }

  /// Get all tools for a specific service
  List<ToolDefinition> getToolsForService(String service) {
    return _tools.values.where((tool) => tool.service == service).toList();
  }

  /// Get all registered tools
  List<ToolDefinition> getAllTools() {
    return _tools.values.toList();
  }

  /// Get only tools that don't require authentication
  List<ToolDefinition> getPublicTools() {
    return _tools.values.where((tool) => !tool.requiresAuth).toList();
  }

  /// Get tools filtered by services that are connected
  ///
  /// [connectedServices] - List of service IDs that are currently connected
  List<ToolDefinition> getAvailableTools(List<String> connectedServices) {
    return _tools.values
        .where((tool) =>
            !tool.requiresAuth || connectedServices.contains(tool.service))
        .toList();
  }

  /// Check if a tool exists
  bool hasTool(String name) {
    return _tools.containsKey(name);
  }

  /// Execute a tool by name with parameters
  ///
  /// [name] - The tool name to execute
  /// [params] - Parameters to pass to the tool
  ///
  /// Throws [ToolNotFoundException] if the tool doesn't exist.
  /// Throws [ToolExecutionException] if execution fails.
  Future<dynamic> executeTool(String name, Map<String, dynamic> params) async {
    final tool = _tools[name];
    if (tool == null) {
      throw ToolNotFoundException(name);
    }

    // Validate parameters
    if (!tool.validateParameters(params)) {
      throw ToolExecutionException(
        name,
        'Invalid parameters provided',
      );
    }

    final handler = _handlers[name];
    if (handler == null) {
      throw ToolExecutionException(
        name,
        'Tool handler not found (inconsistent state)',
      );
    }

    try {
      return await handler(params);
    } catch (e) {
      throw ToolExecutionException(
        name,
        'Execution error: ${e.toString()}',
        e,
      );
    }
  }

  /// Get all tools as function schemas for AI
  ///
  /// Returns a list of function schemas compatible with Claude/OpenAI function calling.
  /// Optionally filter by connected services.
  List<Map<String, dynamic>> toFunctionSchemas({
    List<String>? connectedServices,
  }) {
    final tools = connectedServices != null
        ? getAvailableTools(connectedServices)
        : getAllTools();

    return tools.map((tool) => tool.toFunctionSchema()).toList();
  }

  /// Get statistics about registered tools
  Map<String, dynamic> getStats() {
    final toolsByService = <String, int>{};
    for (final tool in _tools.values) {
      toolsByService[tool.service] = (toolsByService[tool.service] ?? 0) + 1;
    }

    return {
      'total_tools': _tools.length,
      'services': toolsByService.length,
      'tools_by_service': toolsByService,
      'public_tools': getPublicTools().length,
    };
  }

  /// Clear all registered tools
  void clear() {
    _tools.clear();
    _handlers.clear();
    _toolChangesController.add(null);
  }

  /// Dispose of resources
  void dispose() {
    _toolChangesController.close();
    clear();
  }
}

/// Riverpod provider for the tool registry
final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  final registry = ToolRegistry();

  // Dispose when provider is disposed
  ref.onDispose(() {
    registry.dispose();
  });

  return registry;
});

/// Provider for getting all registered tools
final allToolsProvider = StreamProvider<List<ToolDefinition>>((ref) {
  final registry = ref.watch(toolRegistryProvider);

  // Return initial tools and listen for changes
  return Stream.value(registry.getAllTools()).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in registry.toolChanges) {
      yield registry.getAllTools();
    }
  });
});

/// Provider for getting tools for a specific service
final serviceToolsProvider =
    StreamProvider.family<List<ToolDefinition>, String>((ref, service) {
  final registry = ref.watch(toolRegistryProvider);

  return Stream.value(registry.getToolsForService(service))
      .asyncExpand((initial) async* {
    yield initial;
    await for (final _ in registry.toolChanges) {
      yield registry.getToolsForService(service);
    }
  });
});

/// Provider for tool registry statistics
final toolStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final registry = ref.watch(toolRegistryProvider);

  return Stream.value(registry.getStats()).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in registry.toolChanges) {
      yield registry.getStats();
    }
  });
});
