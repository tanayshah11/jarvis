import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/animated_gradient.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../data/data_service.dart';
import '../../../data/seed/memory_seeder.dart';
import '../services/memory_service.dart';
import '../widgets/memory_action_tile.dart';
import '../widgets/stats_card.dart';

class MemoryHubScreen extends ConsumerStatefulWidget {
  const MemoryHubScreen({super.key});

  @override
  ConsumerState<MemoryHubScreen> createState() => _MemoryHubScreenState();
}

class _MemoryHubScreenState extends ConsumerState<MemoryHubScreen> {
  bool _isSeeding = false;

  Future<void> _clearAllChats() async {
    HapticFeedback.mediumImpact();
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear All Chats'),
        content: const Text(
          'This will permanently delete all conversation history. Are you sure?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final dataService = ref.read(dataServiceProvider);
        final count = await dataService.conversationRepository
            .deleteAllConversations();

        if (mounted) {
          _showToast('Deleted $count conversations', isError: false);
        }
      } catch (e) {
        if (mounted) {
          _showToast('Error: $e', isError: true);
        }
      }
    }
  }

  void _showToast(String message, {required bool isError}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedToast(
        message: message,
        isError: isError,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  Future<void> _testMemorySearch() async {
    HapticFeedback.mediumImpact();
    try {
      final memoryService = ref.read(memoryServiceProvider);
      final dataService = ref.read(dataServiceProvider);

      final isModelLoaded = dataService.embeddingService.isModelLoaded;
      final vectorCount = dataService.vectorStore.memoryVectorCount;
      final allNodes = await memoryService.fetchNodes(limit: 100);
      final searchResults = await memoryService.searchMemories('best friend');
      final memoryContext = await dataService.memoryRepository
          .buildMemoryContext(query: 'best friend', maxNodes: 5, minScore: 0.0);

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Memory Debug Results'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'TFLite Model: ${isModelLoaded ? "Loaded" : "Not Loaded"}',
                    style: TextStyle(
                      color: isModelLoaded
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemOrange,
                    ),
                  ),
                  Text('Vector Count: $vectorCount'),
                  Text('Total nodes: ${allNodes.length}'),
                  Text('Search results: ${searchResults.length}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Top Results:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...searchResults
                      .take(3)
                      .map(
                        (node) => Text(
                          '${node.type}: ${node.label}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      memoryContext.isEmpty
                          ? '(empty context)'
                          : (memoryContext.length > 200
                                ? '${memoryContext.substring(0, 200)}...'
                                : memoryContext),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e, stack) {
      if (mounted) {
        _showToast('Error: $e', isError: true);
      }
      debugPrint('Memory search error: $e\n$stack');
    }
  }

  Future<void> _seedTestData() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSeeding = true);

    try {
      final seeder = ref.read(memorySeedProvider);
      final result = await seeder.seedAll();

      if (mounted) {
        ref.invalidate(memoryStatsProvider);

        if (result.errors.isNotEmpty) {
          // Show first error if there are any
          debugPrint('Seed errors: ${result.errors}');
          _showToast(
            'Seeded ${result.nodesCreated} nodes, ${result.edgesCreated} edges. ${result.errors.length} errors.',
            isError: result.nodesCreated == 0,
          );
        } else {
          _showToast(
            'Seeded ${result.nodesCreated} nodes and ${result.edgesCreated} edges!',
            isError: false,
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Seed exception: $e\n$stackTrace');
      if (mounted) {
        _showToast('Error seeding data: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(memoryStatsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          const Positioned.fill(
            child: AnimatedGradient(child: SizedBox.expand()),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // Custom header
              SliverToBoxAdapter(child: _buildHeader(topPadding)),

              // Subtitle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    'Your personal knowledge graph',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Statistics Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: statsAsync.when(
                    data: (stats) => AnimatedContent(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              label: 'Nodes',
                              value: stats.totalNodes.toString(),
                              icon: CupertinoIcons.square_grid_3x2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StatsCard(
                              label: 'Connections',
                              value: stats.totalEdges.toString(),
                              icon: CupertinoIcons.arrow_right_arrow_left,
                              color: AppColors.accentLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const LoadingStateWidget(
                      message: 'Loading statistics...',
                    ),
                    error: (error, _) => ErrorStateWidget(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(memoryStatsProvider),
                    ),
                  ),
                ),
              ),

              // Actions Section
              SliverToBoxAdapter(
                child: AnimatedContent(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSection(
                    title: 'ACTIONS',
                    children: [
                      ScaleOnPress(
                        onPressed: () => context.push('/memory/search'),
                        child: MemoryActionTile(
                          title: 'Search Memories',
                          subtitle: 'Browse your knowledge graph',
                          icon: CupertinoIcons.search,
                          iconColor: AppColors.primary,
                          onTap: () => context.push('/memory/search'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Developer Tools Section
              SliverToBoxAdapter(
                child: AnimatedContent(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSection(
                    title: 'DEVELOPER TOOLS',
                    children: [
                      ScaleOnPress(
                        onPressed: _isSeeding ? () {} : _seedTestData,
                        child: MemoryActionTile(
                          title: 'Seed Test Data',
                          subtitle: _isSeeding
                              ? 'Seeding...'
                              : 'Populate with synthetic memories',
                          icon: _isSeeding
                              ? CupertinoIcons.hourglass
                              : CupertinoIcons.sparkles,
                          iconColor: AppColors.warning,
                          showSpinner: _isSeeding,
                          onTap: _isSeeding ? null : _seedTestData,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScaleOnPress(
                        onPressed: _testMemorySearch,
                        child: MemoryActionTile(
                          title: 'Test Memory Search',
                          subtitle: 'Debug query: "best friend"',
                          icon: CupertinoIcons.ant,
                          iconColor: AppColors.accentLight,
                          onTap: _testMemorySearch,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScaleOnPress(
                        onPressed: _clearAllChats,
                        child: MemoryActionTile(
                          title: 'Clear All Chats',
                          subtitle: 'Delete conversation history',
                          icon: CupertinoIcons.trash,
                          iconColor: AppColors.error,
                          onTap: _clearAllChats,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding for tab bar
              SliverToBoxAdapter(child: SizedBox(height: 100 + bottomPadding)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/chat');
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              // Title centered
              Expanded(
                child: Text(
                  'Memory',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Spacer for symmetry
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

/// Animated toast notification - slides up from bottom and fades out
class _AnimatedToast extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 24,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isError
                    ? AppColors.error.withValues(alpha: 0.95)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isError
                      ? AppColors.error
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isError ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError
                        ? CupertinoIcons.xmark_circle_fill
                        : CupertinoIcons.checkmark_circle_fill,
                    color: widget.isError ? Colors.white : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.isError
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
