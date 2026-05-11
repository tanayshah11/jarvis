import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/glass_container.dart';
import '../chat_controller.dart';

class ConversationContextMenu extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onRename;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const ConversationContextMenu({
    super.key,
    required this.conversation,
    required this.onRename,
    required this.onArchive,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      color: AppColors.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _MenuOption(
              icon: Icons.edit_outlined,
              label: 'Rename',
              onTap: () {
                Navigator.pop(context);
                onRename();
              },
            ),
            _MenuOption(
              icon: Icons.content_copy_outlined,
              label: 'Duplicate',
              onTap: () {
                Navigator.pop(context);
                onDuplicate();
              },
            ),
            _MenuOption(
              icon: conversation.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
              label: conversation.isArchived ? 'Unarchive' : 'Archive',
              onTap: () {
                Navigator.pop(context);
                onArchive();
              },
            ),
            Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: AppSpacing.lg,
            ),
            _MenuOption(
              icon: Icons.delete_outline,
              label: 'Delete',
              labelColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

