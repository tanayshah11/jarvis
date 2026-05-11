import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/jarvis_chip.dart';
import '../../../core/widgets/jarvis_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_node.dart';
import '../widgets/memory_node_card.dart';
import 'memory_detail_screen.dart';

class MemorySearchScreen extends ConsumerStatefulWidget {
  const MemorySearchScreen({super.key});

  @override
  ConsumerState<MemorySearchScreen> createState() => _MemorySearchScreenState();
}

class _MemorySearchScreenState extends ConsumerState<MemorySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch nodes after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryControllerProvider.notifier).fetchNodes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryControllerProvider);
    final memoryController = ref.read(memoryControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Memory Search'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: JarvisTextField(
              controller: _searchController,
              hintText: 'Search memories...',
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                memoryController.searchMemories(query);
              },
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        memoryController.setSearchQuery('');
                        memoryController.fetchNodes();
                      },
                    )
                  : null,
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: NodeType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: JarvisChip(
                    label: type.displayName,
                    isSelected: memoryState.selectedNodeType == type,
                    onSelected: () {
                      memoryController.setNodeTypeFilter(type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Memory nodes list
          Expanded(
            child: _buildMemoryList(memoryState, memoryController),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryList(MemoryState state, MemoryController controller) {
    if (state.isLoading && state.nodes.isEmpty) {
      return const LoadingStateWidget(
        message: 'Searching memories...',
      );
    }

    if (state.error != null) {
      return ErrorStateWidget(
        title: 'Failed to load memories',
        message: state.error!,
        onRetry: () {
          controller.clearError();
          controller.refresh();
        },
      );
    }

    if (state.nodes.isEmpty) {
      return EmptyStateWidget(
        title: state.searchQuery.isNotEmpty
            ? 'No memories found'
            : 'No memories yet',
        message: state.searchQuery.isNotEmpty
            ? 'No memories found matching "${state.searchQuery}". Try a different search term.'
            : 'Start chatting with Jarvis to build your memory graph.',
        icon: state.searchQuery.isNotEmpty
            ? Icons.search_off
            : Icons.psychology_outlined,
        iconColor: AppColors.textMuted,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refresh();
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: state.nodes.length,
        itemBuilder: (context, index) {
          final node = state.nodes[index];
          return AnimatedContent(
            delay: Duration(milliseconds: 100 * index),
            child: ScaleOnPress(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemoryDetailScreen(nodeId: node.id),
                  ),
                );
              },
              child: MemoryNodeCard(
                node: node,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MemoryDetailScreen(nodeId: node.id),
                    ),
                  );
                },
                onDelete: () {
                  controller.deleteNode(node.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${node.label}"'),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppColors.primary,
                        onPressed: () {
                          // Could implement undo functionality here
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
