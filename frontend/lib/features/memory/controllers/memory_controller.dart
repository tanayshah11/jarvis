import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/memory_node.dart';
import '../services/memory_service.dart';

class MemoryState {
  final List<MemoryNode> nodes;
  final String searchQuery;
  final NodeType selectedNodeType;
  final bool isLoading;
  final String? error;
  final bool isSearching;

  const MemoryState({
    this.nodes = const [],
    this.searchQuery = '',
    this.selectedNodeType = NodeType.all,
    this.isLoading = false,
    this.error,
    this.isSearching = false,
  });

  MemoryState copyWith({
    List<MemoryNode>? nodes,
    String? searchQuery,
    NodeType? selectedNodeType,
    bool? isLoading,
    String? error,
    bool? isSearching,
  }) {
    return MemoryState(
      nodes: nodes ?? this.nodes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedNodeType: selectedNodeType ?? this.selectedNodeType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

final memoryControllerProvider =
    NotifierProvider<MemoryController, MemoryState>(() {
  return MemoryController();
});

class MemoryController extends Notifier<MemoryState> {
  // Use getter to access provider - avoids late initialization issues on rebuild
  MemoryService get memoryService => ref.read(memoryServiceProvider);

  @override
  MemoryState build() {
    // Return initial empty state - fetchNodes() will be called by the UI when ready
    return const MemoryState();
  }

  /// Set the search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set the selected node type filter
  void setNodeTypeFilter(NodeType nodeType) {
    state = state.copyWith(
      selectedNodeType: nodeType,
      searchQuery: '', // Clear search when changing filter
    );
    // Refresh nodes with new filter
    fetchNodes();
  }

  /// Search for memory nodes using semantic search
  Future<void> searchMemories(String query) async {
    if (query.trim().isEmpty) {
      // If query is empty, just fetch all nodes
      await fetchNodes();
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        isSearching: true,
        error: null,
        searchQuery: query,
      );

      final results = await memoryService.searchMemories(query);

      state = state.copyWith(
        nodes: results,
        isLoading: false,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSearching: false,
        error: 'Failed to search memories: $e',
      );
    }
  }

  /// Fetch memory nodes with optional type filter
  Future<void> fetchNodes({int limit = 50}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final nodeType = state.selectedNodeType == NodeType.all
          ? null
          : state.selectedNodeType.value;

      final nodes = await memoryService.fetchNodes(
        nodeType: nodeType,
        limit: limit,
      );

      state = state.copyWith(
        nodes: nodes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch nodes: $e',
      );
    }
  }

  /// Get a single node by ID
  Future<MemoryNode?> getNode(String nodeId) async {
    try {
      final node = await memoryService.getNode(nodeId);
      return node;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get node: $e',
      );
      return null;
    }
  }

  /// Update a memory node
  Future<bool> updateNode(
    String nodeId, {
    String? label,
    Map<String, dynamic>? attributes,
    double? confidence,
  }) async {
    try {
      final updatedNode = await memoryService.updateNode(
        nodeId,
        label: label,
        attributes: attributes,
        confidence: confidence,
      );

      // Update the node in the local state
      final updatedNodes = state.nodes.map((node) {
        if (node.id == nodeId) {
          return updatedNode;
        }
        return node;
      }).toList();

      state = state.copyWith(nodes: updatedNodes);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update node: $e',
      );
      return false;
    }
  }

  /// Delete a memory node
  Future<bool> deleteNode(String nodeId) async {
    try {
      await memoryService.deleteNode(nodeId);

      // Remove the node from the local state
      final updatedNodes = state.nodes.where((node) => node.id != nodeId).toList();

      state = state.copyWith(nodes: updatedNodes);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete node: $e',
      );
      return false;
    }
  }

  /// Refresh the current view (pull-to-refresh)
  Future<void> refresh() async {
    if (state.searchQuery.isNotEmpty) {
      await searchMemories(state.searchQuery);
    } else {
      await fetchNodes();
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}
