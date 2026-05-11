import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../chat_controller.dart';
import 'conversation_menu.dart';
import 'user_menu_sheet.dart';

class ChatSidebar extends ConsumerStatefulWidget {
  const ChatSidebar({super.key});

  @override
  ConsumerState<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<ChatSidebar> {
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
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedConversations.clear();
      }
    });
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversations.contains(conversationId)) {
        _selectedConversations.remove(conversationId);
      } else {
        _selectedConversations.add(conversationId);
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedConversations.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Delete Conversations',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedConversations.length} conversation(s)? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      for (final id in _selectedConversations) {
        await ref.read(chatControllerProvider.notifier).deleteConversation(id);
      }
      if (mounted) {
        await ref.read(chatControllerProvider.notifier).loadConversations();
        setState(() {
          _isEditMode = false;
          _selectedConversations.clear();
        });
      }
    }
  }

  Future<void> _bulkArchive(bool archive) async {
    if (_selectedConversations.isEmpty) return;

    for (final id in _selectedConversations) {
      await ref.read(chatControllerProvider.notifier).archiveConversation(id, archive);
    }
    if (mounted) {
      await ref.read(chatControllerProvider.notifier).loadConversations();
      setState(() {
        _isEditMode = false;
        _selectedConversations.clear();
      });
    }
  }

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    // Filter out archived and empty conversations (no title = no messages sent)
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

  void _showConversationMenu(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationContextMenu(
        conversation: conversation,
        onRename: () => _handleRename(context, conversation),
        onArchive: () => _handleArchive(conversation),
        onDelete: () => _handleDelete(context, conversation),
        onDuplicate: () => _handleDuplicate(conversation),
      ),
    );
  }

  Future<void> _handleRename(BuildContext context, Conversation conversation) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => RenameConversationDialog(
        currentTitle: conversation.title ?? 'New chat',
      ),
    );

    if (newTitle != null && newTitle != conversation.title) {
      final success = await ref
          .read(chatControllerProvider.notifier)
          .renameConversation(conversation.id, newTitle);
      if (success && mounted) {
        await ref.read(chatControllerProvider.notifier).loadConversations();
      }
    }
  }

  Future<void> _handleArchive(Conversation conversation) async {
    final success = await ref
        .read(chatControllerProvider.notifier)
        .archiveConversation(conversation.id, !conversation.isArchived);
    if (success && mounted) {
      await ref.read(chatControllerProvider.notifier).loadConversations();
    }
  }

  Future<void> _handleDelete(BuildContext context, Conversation conversation) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Delete Conversation',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await ref
          .read(chatControllerProvider.notifier)
          .deleteConversation(conversation.id);
      if (success && mounted) {
        await ref.read(chatControllerProvider.notifier).loadConversations();
      }
    }
  }

  Future<void> _handleDuplicate(Conversation conversation) async {
    try {
      // Create a new conversation with the same mode and title
      final controller = ref.read(chatControllerProvider.notifier);
      await controller.createConversation();
      
      // Get the newly created conversation and rename it
      final chatState = ref.read(chatControllerProvider);
      final newConversationId = chatState.currentConversationId;
      
      if (newConversationId != null) {
        final newTitle = conversation.title != null
            ? '${conversation.title} (Copy)'
            : 'New chat (Copy)';
        await controller.renameConversation(newConversationId, newTitle);
        
        // Refresh conversations list
        await controller.loadConversations();
        
        if (mounted) {
          Scaffold.of(context).closeDrawer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation duplicated'),
              backgroundColor: AppColors.surfaceLight,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate conversation: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final allConversations = chatState.conversations;
    final conversations = _filterConversations(allConversations);

    // Group conversations by date
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

    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with New Chat button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _NewChatButton(
                isEditMode: _isEditMode,
                onTap: () {
                  if (_isEditMode) {
                    _toggleEditMode();
                  } else {
                    HapticFeedback.lightImpact();
                    ref.read(chatControllerProvider.notifier).startNewChat();
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Conversation list
            Expanded(
              child: conversations.isEmpty
                  ? _EmptyState(
                      isSearching: _searchQuery.isNotEmpty,
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      children: [
                        if (today.isNotEmpty) ...[
                          _SectionHeader(title: 'Today'),
                          ...today.map((conv) => _SwipeableConversationTile(
                                conversation: conv,
                                isSelected:
                                    conv.id == chatState.currentConversationId,
                                isEditMode: _isEditMode,
                                isChecked: _selectedConversations.contains(conv.id),
                                onTap: () {
                                  if (_isEditMode) {
                                    _toggleSelection(conv.id);
                                  } else {
                                    HapticFeedback.selectionClick();
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .loadConversation(conv.id);
                                    Scaffold.of(context).closeDrawer();
                                  }
                                },
                                onLongPress: () {
                                  if (!_isEditMode) {
                                    HapticFeedback.mediumImpact();
                                    _showConversationMenu(context, conv);
                                  }
                                },
                                onArchive: () => _handleArchive(conv),
                                onDelete: () => _handleDelete(context, conv),
                              )),
                        ],
                        if (yesterday.isNotEmpty) ...[
                          _SectionHeader(title: 'Yesterday'),
                          ...yesterday.map((conv) => _SwipeableConversationTile(
                                conversation: conv,
                                isSelected:
                                    conv.id == chatState.currentConversationId,
                                isEditMode: _isEditMode,
                                isChecked: _selectedConversations.contains(conv.id),
                                onTap: () {
                                  if (_isEditMode) {
                                    _toggleSelection(conv.id);
                                  } else {
                                    HapticFeedback.selectionClick();
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .loadConversation(conv.id);
                                    Scaffold.of(context).closeDrawer();
                                  }
                                },
                                onLongPress: () {
                                  if (!_isEditMode) {
                                    HapticFeedback.mediumImpact();
                                    _showConversationMenu(context, conv);
                                  }
                                },
                                onArchive: () => _handleArchive(conv),
                                onDelete: () => _handleDelete(context, conv),
                              )),
                        ],
                        if (lastWeek.isNotEmpty) ...[
                          _SectionHeader(title: 'Previous 7 Days'),
                          ...lastWeek.map((conv) => _SwipeableConversationTile(
                                conversation: conv,
                                isSelected:
                                    conv.id == chatState.currentConversationId,
                                isEditMode: _isEditMode,
                                isChecked: _selectedConversations.contains(conv.id),
                                onTap: () {
                                  if (_isEditMode) {
                                    _toggleSelection(conv.id);
                                  } else {
                                    HapticFeedback.selectionClick();
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .loadConversation(conv.id);
                                    Scaffold.of(context).closeDrawer();
                                  }
                                },
                                onLongPress: () {
                                  if (!_isEditMode) {
                                    HapticFeedback.mediumImpact();
                                    _showConversationMenu(context, conv);
                                  }
                                },
                                onArchive: () => _handleArchive(conv),
                                onDelete: () => _handleDelete(context, conv),
                              )),
                        ],
                        if (older.isNotEmpty) ...[
                          _SectionHeader(title: 'Older'),
                          ...older.map((conv) => _SwipeableConversationTile(
                                conversation: conv,
                                isSelected:
                                    conv.id == chatState.currentConversationId,
                                isEditMode: _isEditMode,
                                isChecked: _selectedConversations.contains(conv.id),
                                onTap: () {
                                  if (_isEditMode) {
                                    _toggleSelection(conv.id);
                                  } else {
                                    HapticFeedback.selectionClick();
                                    ref
                                        .read(chatControllerProvider.notifier)
                                        .loadConversation(conv.id);
                                    Scaffold.of(context).closeDrawer();
                                  }
                                },
                                onLongPress: () {
                                  if (!_isEditMode) {
                                    HapticFeedback.mediumImpact();
                                    _showConversationMenu(context, conv);
                                  }
                                },
                                onArchive: () => _handleArchive(conv),
                                onDelete: () => _handleDelete(context, conv),
                              )),
                        ],
                      ],
                    ),
            ),

            // Edit mode action bar
            if (_isEditMode)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: _selectedConversations.isEmpty
                          ? null
                          : () => _bulkArchive(true),
                      icon: const Icon(
                        Icons.archive_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      label: const Text(
                        'Archive',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _selectedConversations.isEmpty
                          ? null
                          : () => _bulkDelete(),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom user section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: Text(
                        'J',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Jarvis User',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const UserMenuSheet(),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEditMode;

  const _NewChatButton({
    required this.onTap,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'New chat',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                isEditMode ? 'Cancel' : '',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (!isEditMode)
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
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
        left: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SwipeableConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isEditMode;
  final bool isChecked;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _SwipeableConversationTile({
    required this.conversation,
    required this.isSelected,
    this.isEditMode = false,
    this.isChecked = false,
    required this.onTap,
    required this.onLongPress,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _ConversationTile(
        conversation: conversation,
        isSelected: isSelected,
        isEditMode: isEditMode,
        isChecked: isChecked,
        onTap: onTap,
        onLongPress: onLongPress,
      );
    }

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: Icon(
          conversation.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.endToStart) {
          onDelete();
        } else {
          onArchive();
        }
      },
      child: _ConversationTile(
        conversation: conversation,
        isSelected: isSelected,
        isEditMode: isEditMode,
        isChecked: isChecked,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isEditMode;
  final bool isChecked;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    this.isEditMode = false,
    this.isChecked = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.surfaceLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                if (isEditMode)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked
                              ? AppColors.primary
                              : AppColors.textMuted,
                          width: 2,
                        ),
                        color: isChecked
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    conversation.title ?? 'New chat',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearching ? 'No conversations found' : 'No conversations yet',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          if (!isSearching) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a new chat to begin',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
