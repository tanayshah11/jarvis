import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../chat/chat_controller.dart';
import '../providers/history_provider.dart';
import '../widgets/conversation_card.dart';
import '../widgets/date_header.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/sort_options_sheet.dart';
import '../widgets/bulk_action_bar.dart';

/// History screen showing all past conversations.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Filter and sort state
  Set<HistoryFilter> _selectedFilters = {};
  SortOption _currentSortOption = SortOption.recent;

  // Bulk select state
  bool _isBulkSelectMode = false;
  Set<String> _selectedConversationIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(historyControllerProvider.notifier).setSearchQuery(
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onConversationTap(String conversationId) {
    HapticFeedback.selectionClick();

    if (_isBulkSelectMode) {
      // In bulk select mode, toggle selection
      setState(() {
        if (_selectedConversationIds.contains(conversationId)) {
          _selectedConversationIds.remove(conversationId);
        } else {
          _selectedConversationIds.add(conversationId);
        }
      });
    } else {
      // Normal mode, navigate to conversation
      ref.read(chatControllerProvider.notifier).loadConversation(conversationId);
      context.go('/chat');
    }
  }

  void _onDeleteConversation(String conversationId) {
    ref.read(historyControllerProvider.notifier).deleteConversation(conversationId);
  }

  void _onNewConversation() {
    HapticFeedback.lightImpact();
    ref.read(chatControllerProvider.notifier).startNewChat();
    context.go('/chat');
  }

  void _onFilterChanged(Set<HistoryFilter> filters) {
    setState(() {
      _selectedFilters = filters;
    });
  }

  void _onSortChanged(SortOption sortOption) {
    setState(() {
      _currentSortOption = sortOption;
    });
    // TODO: Apply sorting to conversation list
  }

  void _toggleBulkSelectMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBulkSelectMode = !_isBulkSelectMode;
      if (!_isBulkSelectMode) {
        _selectedConversationIds.clear();
      }
    });
  }

  void _showSortOptions() {
    HapticFeedback.selectionClick();
    SortOptionsSheet.show(
      context,
      currentSort: _currentSortOption,
      onSortChanged: _onSortChanged,
    );
  }

  void _onSelectAll() {
    final historyState = ref.read(historyControllerProvider);
    setState(() {
      if (_selectedConversationIds.length == _getTotalConversationCount(historyState)) {
        // Deselect all
        _selectedConversationIds.clear();
      } else {
        // Select all
        _selectedConversationIds = _getAllConversationIds(historyState);
      }
    });
  }

  void _onBulkDelete() {
    if (_selectedConversationIds.isEmpty) return;

    // TODO: Show confirmation dialog
    for (final id in _selectedConversationIds) {
      ref.read(historyControllerProvider.notifier).deleteConversation(id);
    }
    setState(() {
      _selectedConversationIds.clear();
      _isBulkSelectMode = false;
    });
  }

  void _onBulkArchive() {
    if (_selectedConversationIds.isEmpty) return;

    // TODO: Implement archive functionality
    setState(() {
      _selectedConversationIds.clear();
      _isBulkSelectMode = false;
    });
  }

  void _onBulkExport() {
    if (_selectedConversationIds.isEmpty) return;

    // TODO: Implement export functionality
    setState(() {
      _selectedConversationIds.clear();
      _isBulkSelectMode = false;
    });
  }

  int _getTotalConversationCount(HistoryState state) {
    return state.todayConversations.length +
        state.yesterdayConversations.length +
        state.previous7DaysConversations.length +
        state.olderConversations.length;
  }

  Set<String> _getAllConversationIds(HistoryState state) {
    final ids = <String>{};
    ids.addAll(state.todayConversations.map((c) => c.id));
    ids.addAll(state.yesterdayConversations.map((c) => c.id));
    ids.addAll(state.previous7DaysConversations.map((c) => c.id));
    ids.addAll(state.olderConversations.map((c) => c.id));
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header with actions
              SliverScreenHeader(
                title: 'History',
                subtitle: 'View your past conversations',
                showBackButton: false,
                actions: [
                  // Sort button
                  CupertinoButton(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onPressed: _showSortOptions,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.sort_down,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  // Bulk select toggle button
                  CupertinoButton(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onPressed: _toggleBulkSelectMode,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _isBulkSelectMode
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: _isBulkSelectMode
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_square,
                        color: _isBulkSelectMode
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  // Add button
                  CupertinoButton(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onPressed: _onNewConversation,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // Search bar
              SliverToBoxAdapter(
                child: AnimatedContent(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search conversations',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          suffixIcon: historyState.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.clear,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchFocusNode.unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: FilterChipBar(
                  onFilterChanged: _onFilterChanged,
                  initialFilters: _selectedFilters,
                ),
              ),

              // Loading state
              if (historyState.isLoading)
                const SliverFillRemaining(
                  child: LoadingStateWidget(
                    message: 'Loading conversations...',
                  ),
                ),

              // Conversation list
              if (!historyState.isLoading)
                SliverToBoxAdapter(
                  child: _buildConversationList(historyState),
                ),
            ],
          ),
          // Bulk action bar (overlay at bottom)
          BulkActionBar(
            isVisible: _isBulkSelectMode,
            selectedCount: _selectedConversationIds.length,
            totalCount: _getTotalConversationCount(historyState),
            onSelectAll: _onSelectAll,
            onDelete: _onBulkDelete,
            onArchive: _onBulkArchive,
            onExport: _onBulkExport,
            onCancel: _toggleBulkSelectMode,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(HistoryState state) {
    final todayConversations = state.todayConversations;
    final yesterdayConversations = state.yesterdayConversations;
    final previous7DaysConversations = state.previous7DaysConversations;
    final olderConversations = state.olderConversations;

    // Check if there are any conversations
    final hasConversations = todayConversations.isNotEmpty ||
        yesterdayConversations.isNotEmpty ||
        previous7DaysConversations.isNotEmpty ||
        olderConversations.isNotEmpty;

    if (!hasConversations) {
      return EmptyStateWidget(
        title: state.searchQuery.isNotEmpty
            ? 'No conversations found'
            : 'No conversations yet',
        message: state.searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Start a new conversation to get started',
        icon: CupertinoIcons.chat_bubble_2,
        onAction: state.searchQuery.isEmpty ? _onNewConversation : null,
        actionText: state.searchQuery.isEmpty ? 'Start Conversation' : null,
      );
    }

    return AnimatedContent(
      delay: const Duration(milliseconds: 200),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // TODAY
          if (todayConversations.isNotEmpty) ...[
            const DateHeader(label: 'Today'),
            ...todayConversations.asMap().entries.map((entry) {
              return ConversationCard(
                conversation: entry.value,
                onTap: () => _onConversationTap(entry.value.id),
                onDelete: () => _onDeleteConversation(entry.value.id),
                index: entry.key,
                isOngoing: entry.key == 0, // First today is ongoing
              )
                  .animate(delay: Duration(milliseconds: 100 * entry.key))
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideX(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ],

          // YESTERDAY
          if (yesterdayConversations.isNotEmpty) ...[
            const DateHeader(label: 'Yesterday'),
            ...yesterdayConversations.asMap().entries.map((entry) {
              final delay = todayConversations.length + entry.key;
              return ConversationCard(
                conversation: entry.value,
                onTap: () => _onConversationTap(entry.value.id),
                onDelete: () => _onDeleteConversation(entry.value.id),
                index: entry.key + todayConversations.length,
              )
                  .animate(delay: Duration(milliseconds: 100 * delay))
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideX(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ],

          // PREVIOUS 7 DAYS
          if (previous7DaysConversations.isNotEmpty) ...[
            const DateHeader(label: 'Previous 7 Days'),
            ...previous7DaysConversations.asMap().entries.map((entry) {
              final delay = todayConversations.length +
                  yesterdayConversations.length +
                  entry.key;
              return ConversationCard(
                conversation: entry.value,
                onTap: () => _onConversationTap(entry.value.id),
                onDelete: () => _onDeleteConversation(entry.value.id),
                index: entry.key +
                    todayConversations.length +
                    yesterdayConversations.length,
              )
                  .animate(delay: Duration(milliseconds: 100 * delay))
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideX(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ],

          // OLDER
          if (olderConversations.isNotEmpty) ...[
            const DateHeader(label: 'Older'),
            ...olderConversations.asMap().entries.map((entry) {
              final delay = todayConversations.length +
                  yesterdayConversations.length +
                  previous7DaysConversations.length +
                  entry.key;
              return ConversationCard(
                conversation: entry.value,
                onTap: () => _onConversationTap(entry.value.id),
                onDelete: () => _onDeleteConversation(entry.value.id),
                index: entry.key +
                    todayConversations.length +
                    yesterdayConversations.length +
                    previous7DaysConversations.length,
              )
                  .animate(delay: Duration(milliseconds: 100 * delay))
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideX(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ],

          // Bottom padding
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

}
