import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animations/jarvis_spinner.dart';

/// Tool access visualization card
/// Shows when Jarvis is accessing a tool (calendar, contacts, etc.)
class ToolAccessCard extends StatelessWidget {
  final String toolName;
  final String? description;
  final ToolAccessState state;
  final List<String>? results;
  final IconData? icon;

  const ToolAccessCard({
    super.key,
    required this.toolName,
    this.description,
    required this.state,
    this.results,
    this.icon,
  });

  IconData get _icon => icon ?? _defaultIcon;

  IconData get _defaultIcon {
    switch (toolName.toLowerCase()) {
      case 'calendar':
      case 'schedule':
        return Icons.calendar_today_rounded;
      case 'contacts':
      case 'contact':
        return Icons.contacts_rounded;
      case 'email':
      case 'mail':
        return Icons.email_rounded;
      case 'reminder':
      case 'reminders':
        return Icons.alarm_rounded;
      case 'notes':
      case 'note':
        return Icons.note_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'weather':
        return Icons.cloud_rounded;
      case 'memory':
        return Icons.psychology_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: state == ToolAccessState.success
              ? AppColors.success.withValues(alpha: 0.3)
              : state == ToolAccessState.error
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _ToolHeader(
            icon: _icon,
            toolName: toolName,
            description: description,
            state: state,
          ),
          // Results (if any and completed)
          if (state == ToolAccessState.success && results != null && results!.isNotEmpty)
            _ResultsList(results: results!),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, duration: 200.ms);
  }
}

enum ToolAccessState {
  loading,
  success,
  error,
}

class _ToolHeader extends StatelessWidget {
  final IconData icon;
  final String toolName;
  final String? description;
  final ToolAccessState state;

  const _ToolHeader({
    required this.icon,
    required this.toolName,
    this.description,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description ?? _getDefaultDescription(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (state == ToolAccessState.success && description == null)
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Status indicator
          _StatusIndicator(state: state),
        ],
      ),
    );
  }

  String _getDefaultDescription() {
    switch (state) {
      case ToolAccessState.loading:
        return 'Accessing $toolName...';
      case ToolAccessState.success:
        return 'Accessed $toolName';
      case ToolAccessState.error:
        return 'Failed to access $toolName';
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final ToolAccessState state;

  const _StatusIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ToolAccessState.loading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: JarvisSpinner(
            size: 20,
            strokeWidth: 1.5,
          ),
        );
      case ToolAccessState.success:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 16,
            color: AppColors.success,
          ),
        )
            .animate()
            .scale(begin: const Offset(0, 0), duration: 200.ms, curve: Curves.elasticOut);
      case ToolAccessState.error:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: AppColors.error,
          ),
        );
    }
  }
}

class _ResultsList extends StatelessWidget {
  final List<String> results;

  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                top: index > 0 ? 4 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '›',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: index * 50))
                .fadeIn(duration: 150.ms)
                .slideX(begin: 0.05, duration: 150.ms);
          }).toList(),
        ),
      ),
    );
  }
}

/// Compact tool indicator for inline display
class ToolIndicatorChip extends StatelessWidget {
  final String toolName;
  final ToolAccessState state;

  const ToolIndicatorChip({
    super.key,
    required this.toolName,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state == ToolAccessState.success
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state == ToolAccessState.loading)
            const SizedBox(
              width: 12,
              height: 12,
              child: JarvisSpinner(
                size: 12,
                strokeWidth: 1.0,
              ),
            )
          else
            Icon(
              state == ToolAccessState.success
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 14,
              color: state == ToolAccessState.success
                  ? AppColors.success
                  : AppColors.error,
            ),
          const SizedBox(width: 6),
          Text(
            toolName,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
