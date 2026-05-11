import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Callback signature for bulk action bar actions.
typedef BulkActionCallback = void Function();

/// A glassmorphic action bar that appears at the bottom when bulk select mode is active.
///
/// Features:
/// - Glassmorphism effect with backdrop blur
/// - Gold accent color for buttons
/// - Shows count of selected items
/// - Actions: Select All, Delete, Archive, Export
/// - Animates in/out with slide from bottom
/// - Haptic feedback on interactions
class BulkActionBar extends StatelessWidget {
  /// Whether the bulk action bar should be visible.
  final bool isVisible;

  /// Number of items currently selected.
  final int selectedCount;

  /// Total number of items available for selection.
  final int totalCount;

  /// Callback when "Select All" is tapped.
  final BulkActionCallback? onSelectAll;

  /// Callback when "Delete" is tapped.
  final BulkActionCallback? onDelete;

  /// Callback when "Archive" is tapped.
  final BulkActionCallback? onArchive;

  /// Callback when "Export" is tapped.
  final BulkActionCallback? onExport;

  /// Callback when "Cancel" (close) is tapped.
  final BulkActionCallback? onCancel;

  const BulkActionBar({
    super.key,
    required this.isVisible,
    required this.selectedCount,
    required this.totalCount,
    this.onSelectAll,
    this.onDelete,
    this.onArchive,
    this.onExport,
    this.onCancel,
  });

  /// Whether all items are currently selected.
  bool get _isAllSelected => selectedCount == totalCount && totalCount > 0;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 0 : -120,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected count indicator
                _buildSelectedCount(),
                const SizedBox(height: AppSpacing.md),
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: 1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 250.ms);
  }

  /// Builds the selected count indicator with cancel button.
  Widget _buildSelectedCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Count text
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$selectedCount',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              selectedCount == 1 ? 'item selected' : 'items selected',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        // Cancel button
        _BulkActionButton(
          icon: CupertinoIcons.xmark,
          label: 'Cancel',
          onTap: () {
            HapticFeedback.lightImpact();
            onCancel?.call();
          },
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  /// Builds the row of action buttons.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Select All / Deselect All
        Expanded(
          child: _BulkActionButton(
            icon: _isAllSelected
                ? CupertinoIcons.checkmark_circle
                : CupertinoIcons.checkmark_circle_fill,
            label: _isAllSelected ? 'Deselect' : 'Select All',
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectAll?.call();
            },
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Delete
        Expanded(
          child: _BulkActionButton(
            icon: CupertinoIcons.trash,
            label: 'Delete',
            onTap: selectedCount > 0
                ? () {
                    HapticFeedback.mediumImpact();
                    onDelete?.call();
                  }
                : null,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Archive
        Expanded(
          child: _BulkActionButton(
            icon: CupertinoIcons.archivebox,
            label: 'Archive',
            onTap: selectedCount > 0
                ? () {
                    HapticFeedback.lightImpact();
                    onArchive?.call();
                  }
                : null,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Export
        Expanded(
          child: _BulkActionButton(
            icon: CupertinoIcons.square_arrow_up,
            label: 'Export',
            onTap: selectedCount > 0
                ? () {
                    HapticFeedback.lightImpact();
                    onExport?.call();
                  }
                : null,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// A single action button within the bulk action bar.
class _BulkActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _BulkActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final effectiveColor = isEnabled ? color : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? effectiveColor.withValues(alpha: 0.15)
              : AppColors.surfaceLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? effectiveColor.withValues(alpha: 0.3)
                : AppColors.textMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: effectiveColor,
              size: 20,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
