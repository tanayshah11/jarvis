import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Message actions overlay - appears on long press
/// Shows Copy, Regenerate, and feedback buttons
class MessageActionsOverlay extends StatelessWidget {
  final String messageContent;
  final bool isAssistant;
  final VoidCallback? onRegenerate;
  final VoidCallback? onFeedbackPositive;
  final VoidCallback? onFeedbackNegative;
  final VoidCallback onDismiss;

  const MessageActionsOverlay({
    super.key,
    required this.messageContent,
    required this.isAssistant,
    this.onRegenerate,
    this.onFeedbackPositive,
    this.onFeedbackNegative,
    required this.onDismiss,
  });

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: messageContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Copy
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () => _copyMessage(context),
                  ),
                  if (isAssistant) ...[
                    _Divider(),
                    // Regenerate
                    _ActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'Retry',
                      onTap: () {
                        onRegenerate?.call();
                        onDismiss();
                      },
                    ),
                    _Divider(),
                    // Feedback
                    _ActionButton(
                      icon: Icons.thumb_up_outlined,
                      onTap: () {
                        onFeedbackPositive?.call();
                        onDismiss();
                      },
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.thumb_down_outlined,
                      onTap: () {
                        onFeedbackNegative?.call();
                        onDismiss();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 150.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 150.ms);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: AppColors.primary.withValues(alpha: 0.2),
    );
  }
}

/// Quick action chips that appear after certain message types
class QuickActionChips extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionChips({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return _QuickActionChip(
            label: action.label,
            icon: action.icon,
            onTap: action.onTap,
          )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 200.ms)
              .slideX(begin: 0.1, duration: 200.ms);
        }).toList(),
      ),
    );
  }
}

class QuickAction {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const QuickAction({
    required this.label,
    this.icon,
    required this.onTap,
  });
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
