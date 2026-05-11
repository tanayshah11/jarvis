import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/animated_gradient.dart';
import '../../core/widgets/animations/skeleton_loader.dart';
import '../../core/widgets/jarvis_avatar.dart';
import '../../core/widgets/jarvis_sidebar.dart';
import '../../core/widgets/particle_field.dart';
import '../../core/widgets/animated_content.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_model.dart';
import 'chat_controller.dart';
import 'widgets/message_bubble.dart';
import 'widgets/enhanced_typing_indicator.dart';

// =============================================================================
// CHAT SCREEN
// =============================================================================

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openSidebar() {
    HapticFeedback.lightImpact();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final content = text ?? _messageController.text.trim();
    if (content.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(chatControllerProvider.notifier).sendMessage(content);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: const JarvisSidebar(),
        drawerEdgeDragWidth: 60, // Allow edge swipe to open drawer
        body: AnimatedGradient(
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                // Header
                _ChatHeader(
                  onMenuTap: _openSidebar,
                  onSettingsTap: () => _showSettingsSheet(chatState),
                ),

                // Content
                Expanded(
                  child: chatState.isLoading && chatState.messages.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: SkeletonMessageList(messageCount: 4),
                        )
                      : chatState.messages.isEmpty
                          ? AnimatedContent(
                              child: _EmptyState(
                                userName: _getUserName(authState),
                                onSuggestionTap: _sendMessage,
                              ),
                            )
                          : AnimatedContent(
                              child: _MessageList(
                                messages: chatState.messages,
                                scrollController: _scrollController,
                                isLoading: chatState.isLoading,
                              ),
                            ),
                ),

                // Input Area
                _ChatInputArea(
                  controller: _messageController,
                  isLoading: chatState.isLoading,
                  onSend: () => _sendMessage(),
                  onAttachment: () => _showAttachmentSheet(),
                ),

                // Bottom safe area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserName(AuthState authState) {
    return authState.email?.split('@').first ?? 'there';
  }

  void _showSettingsSheet(ChatState chatState) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showProviderPicker(chatState);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.sparkles, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Model: ${chatState.currentProvider.displayName}',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(chatControllerProvider.notifier).startNewChat();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.plus_circle, size: 20),
                SizedBox(width: 8),
                Text('New Chat'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(chatControllerProvider.notifier).clearChat();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.trash, size: 20),
                SizedBox(width: 8),
                Text('Clear Chat'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).logout();
              router.go('/login');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.square_arrow_right, size: 20),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showProviderPicker(ChatState chatState) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select AI Model'),
        message: Text('Currently using ${chatState.currentProvider.displayName}'),
        actions: AiProvider.values.map((provider) {
          final isSelected = chatState.currentProvider == provider;
          return CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(chatControllerProvider.notifier).setProvider(provider);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                Text(
                  '${provider.displayName} (${provider.company})',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAttachmentSheet() {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 20),
                SizedBox(width: 8),
                Text('Photo Library'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, size: 20),
                SizedBox(width: 8),
                Text('Take Photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc, size: 20),
                SizedBox(width: 8),
                Text('Document'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================

class _ChatHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onSettingsTap;

  const _ChatHeader({
    required this.onMenuTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger menu to open sidebar
          _HeaderIconButton(
            onTap: onMenuTap,
            icon: CupertinoIcons.line_horizontal_3,
            semanticsLabel: 'Open menu',
            color: colorScheme.primary,
          ),
          // Title
          Text(
            'Jarvis',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Settings / options
          _HeaderIconButton(
            onTap: onSettingsTap,
            icon: CupertinoIcons.ellipsis,
            semanticsLabel: 'Chat settings',
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String semanticsLabel;
  final Color color;

  const _HeaderIconButton({
    required this.onTap,
    required this.icon,
    required this.semanticsLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final String userName;
  final ValueChanged<String> onSuggestionTap;

  const _EmptyState({
    required this.userName,
    required this.onSuggestionTap,
  });

  String get _greeting {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    // Special greetings
    if (weekday == DateTime.friday && hour >= 16) {
      return 'Happy Friday';
    }
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return 'Enjoying the weekend';
    }
    if (hour < 5) return 'Still up';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  String get _subtitle {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    if (weekday == DateTime.friday && hour >= 16) {
      return 'Ready to wrap up the week?';
    }
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return 'How can I help you relax?';
    }
    if (hour < 5) return 'Working late? I\'m here to help.';
    if (hour < 9) return 'Let\'s start the day right.';
    if (hour < 12) return 'What\'s on your mind?';
    if (hour < 14) return 'Need help with anything?';
    if (hour < 17) return 'How can I assist you?';
    if (hour < 21) return 'Winding down? I\'m here.';
    return 'One last thing before bed?';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxl),

            // Gold orb with particle field
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Particle field orbiting the avatar
                  const ParticleField(
                    size: 120,
                    particleCount: 15,
                  ),
                  // Avatar with glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const JarvisAvatar(size: 120),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),

            const SizedBox(height: AppSpacing.xl),

            // Greeting with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppColors.textPrimary,
                  AppColors.primary,
                ],
              ).createShader(bounds),
              child: Text(
                '$_greeting, $userName',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: AppSpacing.sm),

            // Dynamic subtitle
            Text(
              _subtitle,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

            const SizedBox(height: AppSpacing.xl),

            // Suggestion chips
            _SuggestionChips(onTap: onSuggestionTap)
                .animate()
                .fadeIn(delay: 450.ms)
                .slideY(begin: 0.1),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _SuggestionChips({required this.onTap});

  static const _suggestions = [
    'Summarize my day',
    'Draft an email',
    'Plan my week',
    'Meeting notes',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(_suggestions[index]);
            },
            child: Semantics(
              button: true,
              label: 'Suggestion: ${_suggestions[index]}',
              child: Material(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(_suggestions[index]);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      _suggestions[index],
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// MESSAGE LIST
// =============================================================================

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isLoading;

  const _MessageList({
    required this.messages,
    required this.scrollController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Use the enhanced typing indicator
          return const EnhancedTypingIndicator();
        }
        // Use the proper MessageBubble with markdown support
        // Add subtle entrance animation with stagger delay
        return AnimatedContent(
          delay: Duration(milliseconds: index * 100),
          child: MessageBubble(
            message: messages[index],
            isLatest: index == messages.length - 1,
          ),
        );
      },
    );
  }
}

// =============================================================================
// INPUT AREA (with glassmorphism)
// =============================================================================

class _ChatInputArea extends ConsumerWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  const _ChatInputArea({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onAttachment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode and Model selectors row
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    // Mode selector (Agent / Chat)
                    _ModeSelector(
                      isAgentMode: chatState.isAgentMode,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        ref.read(chatControllerProvider.notifier).setAgentMode(value);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Model selector
                    _ModelSelector(
                      currentProvider: chatState.currentProvider,
                      onChanged: (provider) {
                        HapticFeedback.selectionClick();
                        ref.read(chatControllerProvider.notifier).setProvider(provider);
                      },
                    ),
                    const Spacer(),
                    // Attachment button (moved to right side)
                    Semantics(
                      button: true,
                      label: 'Add attachment',
                      child: Material(
                        color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: isLoading ? null : onAttachment,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              CupertinoIcons.photo,
                              color: isLoading
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Text field row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLines: 5,
                        minLines: 1,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.send,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: chatState.isAgentMode
                              ? 'Ask Jarvis anything...'
                              : 'Chat directly with AI...',
                          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Send button
                  isLoading
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surfaceVariant,
                          ),
                          child: const CupertinoActivityIndicator(),
                        )
                      : ScaleOnPress(
                          onPressed: onSend,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.primary,
                              boxShadow: AppShadows.primaryGlow,
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.black,
                              size: 20,
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
}

// =============================================================================
// MODE SELECTOR (Agent / Chat)
// =============================================================================

class _ModeSelector extends StatelessWidget {
  final bool isAgentMode;
  final ValueChanged<bool> onChanged;

  const _ModeSelector({
    required this.isAgentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showModePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAgentMode ? CupertinoIcons.sparkles : CupertinoIcons.chat_bubble,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              isAgentMode ? 'Agent' : 'Chat',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_down,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showModePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Mode'),
        message: const Text('Agent mode uses memory and context. Chat mode is direct.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              onChanged(true);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAgentMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                Icon(CupertinoIcons.sparkles, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Agent',
                  style: TextStyle(
                    color: isAgentMode ? AppColors.primary : null,
                    fontWeight: isAgentMode ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              onChanged(false);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isAgentMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                const Icon(CupertinoIcons.chat_bubble, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Chat',
                  style: TextStyle(
                    color: !isAgentMode ? AppColors.primary : null,
                    fontWeight: !isAgentMode ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

// =============================================================================
// MODEL SELECTOR
// =============================================================================

class _ModelSelector extends StatelessWidget {
  final AiProvider currentProvider;
  final ValueChanged<AiProvider> onChanged;

  const _ModelSelector({
    required this.currentProvider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showModelPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentProvider.displayName,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_down,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showModelPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select AI Model'),
        actions: AiProvider.values.map((provider) {
          final isSelected = currentProvider == provider;
          return CupertinoActionSheetAction(
            onPressed: () {
              onChanged(provider);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                Text(
                  provider.displayName,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${provider.company})',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
