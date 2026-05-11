import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/jarvis_card.dart';
import '../models/memory_node.dart';

class MemoryNodeCard extends StatelessWidget {
  final MemoryNode node;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MemoryNodeCard({
    super.key,
    required this.node,
    this.onTap,
    this.onDelete,
  });

  IconData _getNodeTypeIcon() {
    switch (node.type.toLowerCase()) {
      case 'person':
        return Icons.person;
      case 'place':
        return Icons.place;
      case 'preference':
        return Icons.favorite;
      case 'organization':
        return Icons.business;
      case 'event':
        return Icons.event;
      case 'concept':
        return Icons.lightbulb;
      default:
        return Icons.circle;
    }
  }

  Color _getNodeTypeColor() {
    switch (node.type.toLowerCase()) {
      case 'person':
        return const Color(0xFF00D9FF);
      case 'place':
        return const Color(0xFF00C48C);
      case 'preference':
        return const Color(0xFFFF4757);
      case 'organization':
        return const Color(0xFFFFB800);
      case 'event':
        return const Color(0xFF6C5CE7);
      case 'concept':
        return const Color(0xFF8B7CFF);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(node.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Delete Memory',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to delete "${node.label}"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 24,
        ),
      ),
      child: JarvisCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Node type icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _getNodeTypeColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getNodeTypeIcon(),
                    size: 20,
                    color: _getNodeTypeColor(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Label and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        node.type.toUpperCase(),
                        style: TextStyle(
                          color: _getNodeTypeColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Confidence indicator
                _buildConfidenceIndicator(),
              ],
            ),

            // Attributes preview
            if (node.attributes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _buildAttributeChips(),
              ),
            ],

            // Similarity score (if available)
            if (node.similarity != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.compare_arrows,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Similarity: ${(node.similarity! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final color = node.confidence >= 0.7
        ? AppColors.success
        : node.confidence >= 0.4
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${(node.confidence * 100).toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAttributeChips() {
    final attributes = node.attributes.entries.take(3).toList();
    return attributes.map((entry) {
      final value = entry.value.toString();
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          '${entry.key}: ${value.length > 20 ? '${value.substring(0, 20)}...' : value}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      );
    }).toList();
  }
}
