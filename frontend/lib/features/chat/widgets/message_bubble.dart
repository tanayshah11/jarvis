import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'jarvis_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

import '../../../core/theme/animations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/jarvis_avatar.dart';
import '../chat_controller.dart';
import 'enhanced_typing_indicator.dart';
import 'message_actions.dart';

/// Clean, professional message display - no bubbles
class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isLatest;
  final VoidCallback? onRegenerate;
  final VoidCallback? onFeedbackPositive;
  final VoidCallback? onFeedbackNegative;

  const MessageBubble({
    super.key,
    required this.message,
    this.isLatest = false,
    this.onRegenerate,
    this.onFeedbackPositive,
    this.onFeedbackNegative,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to dismiss overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Actions overlay positioned relative to the message
          Positioned(
            left: offset.dx + 40, // Offset from avatar
            top: offset.dy + size.height - 8, // Below the message
            child: Material(
              color: Colors.transparent,
              child: MessageActionsOverlay(
                messageContent: widget.message.content,
                isAssistant: widget.message.role == 'assistant',
                onRegenerate: widget.onRegenerate,
                onFeedbackPositive: widget.onFeedbackPositive,
                onFeedbackNegative: widget.onFeedbackNegative,
                onDismiss: _removeOverlay,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final isStreaming = widget.message.isStreaming;

    Widget messageWidget = GestureDetector(
      onLongPress: () {
        // Only show actions if message has content
        if (widget.message.content.isNotEmpty && !isStreaming) {
          _showOverlay(context);
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              if (isUser) ...[
                const _UserAvatar(size: 28),
                const SizedBox(width: AppSpacing.md),
              ] else ...[
                JarvisAvatar(size: 28, isThinking: isStreaming),
                const SizedBox(width: AppSpacing.md),
              ],
              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        isUser ? 'You' : 'Jarvis',
                        style: TextStyle(
                          color: isUser ? AppColors.textSecondary : AppColors.primary,
                          fontSize: 13,
                          fontWeight: isUser ? FontWeight.w500 : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Content
                    _buildContent(isUser, isStreaming),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );


    if (widget.isLatest && !isStreaming) {
      return messageWidget
          .animate()
          .fadeIn(duration: AppAnimations.normal)
          .slideY(begin: 0.05, curve: AppAnimations.enter);
    }

    return messageWidget;
  }

  Widget _buildContent(bool isUser, bool isStreaming) {
    if (widget.message.content.isEmpty && isStreaming) {
      // Show simple typing dots when streaming starts (no avatar needed here since row already has it)
      return const TypingDots();
    }

    // User messages - plain white text
    if (isUser) {
      return Text(
        widget.message.content,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
      );
    }

    // AI messages - markdown
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionArea(
          child: JarvisMarkdown(
            widget.message.content,
            baseStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
        if (isStreaming) const _Cursor(),
      ],
    );
  }
}


class _Cursor extends StatelessWidget {
  const _Cursor();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 16,
      margin: const EdgeInsets.only(top: 4),
      color: AppColors.primary,
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 400.ms)
        .then()
        .fadeOut(duration: 400.ms);
  }
}


/// User avatar with ripple Lottie animation
class _UserAvatar extends StatelessWidget {
  final double size;

  const _UserAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: DotLottieLoader.fromAsset(
          'assets/ripple-user.lottie',
          frameBuilder: (BuildContext context, DotLottie? dotLottie) {
            if (dotLottie != null && dotLottie.animations.isNotEmpty) {
              return Lottie.memory(
                dotLottie.animations.values.first,
                width: size,
                height: size,
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              );
            } else {
              // Fallback - simple user icon
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLight,
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: AppColors.textSecondary,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
