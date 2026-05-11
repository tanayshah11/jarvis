import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_gradient.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/state_widgets.dart';
import '../chat_controller.dart';

/// Premium dark conversation history screen with glassmorphism styling.
class ConversationHistoryScreen extends ConsumerStatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  ConsumerState<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState
    extends ConsumerState<ConversationHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isEditMode = false;
  final Set<String> _selectedConversations = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedConversations.clear();
      }
    });
  }

  void _toggleSelection(String conversationId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedConversations.contains(conversationId)) {
        _selectedConversations.remove(conversationId);
      } else {
        _selectedConversations.add(conversationId);
      }
    });
  }

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    if (_searchQuery.isEmpty) {
      return conversations
          .where((c) => !c.isArchived && c.title != null && c.title!.isNotEmpty)
          .toList();
    }
    final query = _searchQuery.toLowerCase();
    return conversations
        .where((c) =>
            !c.isArchived &&
            c.title != null &&
            c.title!.isNotEmpty &&
            c.title!.toLowerCase().contains(query))
        .toList();
  }

  Map<String, List<Conversation>> _groupConversations(
      List<Conversation> conversations) {
    final today = <Conversation>[];
    final yesterday = <Conversation>[];
    final lastWeek = <Conversation>[];
    final older = <Conversation>[];

    final now = DateTime.now();
    for (final conv in conversations) {
      final diff = now.difference(conv.createdAt).inDays;
      if (diff == 0) {
        today.add(conv);
      } else if (diff == 1) {
        yesterday.add(conv);
      } else if (diff < 7) {
        lastWeek.add(conv);
      } else {
        older.add(conv);
      }
    }

    return {
      if (today.isNotEmpty) 'Today': today,
      if (yesterday.isNotEmpty) 'Yesterday': yesterday,
      if (lastWeek.isNotEmpty) 'Previous 7 Days': lastWeek,
      if (older.isNotEmpty) 'Older': older,
    };
  }

  Future<void> _handleNewChat() async {
    HapticFeedback.mediumImpact();
    ref.read(chatControllerProvider.notifier).startNewChat();
    context.go('/chat');
  }

  Future<void> _handleSelectConversation(Conversation conv) async {
    if (_isEditMode) {
      _toggleSelection(conv.id);
    } else {
      HapticFeedback.selectionClick();
      ref.read(chatControllerProvider.notifier).loadConversation(conv.id);
      context.go('/chat');
    }
  }

  Future<void> _handleDeleteConversation(Conversation conv) async {
    HapticFeedback.mediumImpact();
    await ref.read(chatControllerProvider.notifier).deleteConversation(conv.id);
    await ref.read(chatControllerProvider.notifier).loadConversations();
  }

  Future<void> _handleArchiveConversation(Conversation conv) async {
    HapticFeedback.mediumImpact();
    await ref
        .read(chatControllerProvider.notifier)
        .archiveConversation(conv.id, !conv.isArchived);
    await ref.read(chatControllerProvider.notifier).loadConversations();
  }

  Future<void> _bulkDelete() async {
    if (_selectedConversations.isEmpty) return;

    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Conversations'),
        content: Text(
          'Are you sure you want to delete ${_selectedConversations.length} conversation(s)? This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      HapticFeedback.heavyImpact();
      for (final id in _selectedConversations) {
        await ref.read(chatControllerProvider.notifier).deleteConversation(id);
      }
      await ref.read(chatControllerProvider.notifier).loadConversations();
      setState(() {
        _isEditMode = false;
        _selectedConversations.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final allConversations = chatState.conversations;
    final conversations = _filterConversations(allConversations);
    final grouped = _groupConversations(conversations);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              // Empty state or conversation list
              if (conversations.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    for (final entry in grouped.entries) ...[
                      AnimatedContent(
                        delay: Duration(milliseconds: grouped.keys.toList().indexOf(entry.key) * 100),
                        child: _SectionHeader(title: entry.key),
                      ),
                      for (int i = 0; i < entry.value.length; i++)
                        AnimatedContent(
                          delay: Duration(milliseconds: (grouped.keys.toList().indexOf(entry.key) * 100) + ((i + 1) * 50)),
                          child: _ConversationCard(
                            conversation: entry.value[i],
                            isSelected:
                                entry.value[i].id == chatState.currentConversationId,
                            isEditMode: _isEditMode,
                            isChecked: _selectedConversations.contains(entry.value[i].id),
                            onTap: () => _handleSelectConversation(entry.value[i]),
                            onDelete: () => _handleDeleteConversation(entry.value[i]),
                            onArchive: () => _handleArchiveConversation(entry.value[i]),
                          ),
                        ),
                    ],
                    SizedBox(height: 100 + bottomPadding),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - back button or cancel in edit mode
              if (_isEditMode)
                GestureDetector(
                  onTap: _toggleEditMode,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                ScaleOnPress(
                  onPressed: () {
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

              // Title
              Text(
                'History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              // Right side actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditMode && _selectedConversations.isNotEmpty)
                    GestureDetector(
                      onTap: _bulkDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          CupertinoIcons.trash,
                          color: AppColors.error,
                          size: 22,
                        ),
                      ),
                    )
                  else if (!_isEditMode)
                    ScaleOnPress(
                      onPressed: _handleNewChat,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.plus,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Text(
                      _isEditMode ? 'Done' : 'Edit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search conversations',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: AppColors.textMuted,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: _searchQuery.isNotEmpty
          ? 'No conversations found'
          : 'No conversations yet',
      message: _searchQuery.isNotEmpty
          ? 'Try a different search term'
          : 'Start a new chat to begin',
      icon: _searchQuery.isNotEmpty
          ? CupertinoIcons.search
          : CupertinoIcons.chat_bubble_2,
      iconColor: AppColors.primary.withValues(alpha: 0.6),
      onAction: _searchQuery.isEmpty ? _handleNewChat : null,
      actionText: _searchQuery.isEmpty ? 'New Chat' : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Row(
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
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isEditMode;
  final bool isChecked;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const _ConversationCard({
    required this.conversation,
    required this.isSelected,
    required this.isEditMode,
    required this.isChecked,
    required this.onTap,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.1),
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Left icon or checkbox
                  if (isEditMode)
                    _SelectionCircle(isChecked: isChecked)
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.chat_bubble,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: 14),

                  // Title and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.title ?? 'New chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(conversation.createdAt),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  if (!isEditMode)
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isEditMode) {
      return card;
    }

    // Swipe actions for non-edit mode
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          final shouldDelete = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Delete Conversation'),
              content: const Text(
                'Are you sure you want to delete this conversation?',
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (shouldDelete == true) {
            onDelete();
          }
          return false;
        } else {
          // Archive
          onArchive();
          return false;
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        child: const Icon(
          CupertinoIcons.archivebox,
          color: Colors.black,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        child: const Icon(
          CupertinoIcons.trash,
          color: Colors.white,
        ),
      ),
      child: card,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _SelectionCircle extends StatelessWidget {
  final bool isChecked;

  const _SelectionCircle({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? AppColors.primary : AppColors.textMuted,
          width: 2,
        ),
        color: isChecked ? AppColors.primary : Colors.transparent,
        boxShadow: isChecked
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: isChecked
          ? const Icon(
              CupertinoIcons.checkmark,
              size: 14,
              color: Colors.black,
            )
          : null,
    );
  }
}
