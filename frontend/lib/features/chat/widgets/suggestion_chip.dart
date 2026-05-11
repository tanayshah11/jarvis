import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/adaptive_colors.dart';
import '../../../core/theme/spacing.dart';

/// Suggestion chip for quick message suggestions
/// Displays with dark background and subtle border, tappable to send as message
class SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const SuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  State<SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<SuggestionChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AdaptiveColors.primary.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: AdaptiveColors.primary.withValues(alpha: 0.9),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: AdaptiveColors.primary.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of suggestion chips with common prompts
class SuggestionChipGrid extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SuggestionChipGrid({
    super.key,
    required this.onSuggestionTap,
  });

  static const List<SuggestionItem> _suggestions = [
    SuggestionItem(
      label: 'Summarize my day',
      prompt: 'Summarize my day',
      icon: CupertinoIcons.calendar,
    ),
    SuggestionItem(
      label: 'Draft an email',
      prompt: 'Help me draft an email',
      icon: CupertinoIcons.mail,
    ),
    SuggestionItem(
      label: 'Tell me a joke',
      prompt: 'Tell me a joke',
      icon: CupertinoIcons.smiley,
    ),
    SuggestionItem(
      label: 'Plan a trip',
      prompt: 'Help me plan a trip',
      icon: CupertinoIcons.airplane,
    ),
    SuggestionItem(
      label: 'Explain a concept',
      prompt: 'Explain a complex concept to me',
      icon: CupertinoIcons.lightbulb,
    ),
    SuggestionItem(
      label: 'Write code',
      prompt: 'Help me write some code',
      icon: CupertinoIcons.chevron_left_slash_chevron_right,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: _suggestions.map((suggestion) {
        return SuggestionChip(
          label: suggestion.label,
          icon: suggestion.icon,
          onTap: () => onSuggestionTap(suggestion.prompt),
        );
      }).toList(),
    );
  }
}

class SuggestionItem {
  final String label;
  final String prompt;
  final IconData? icon;

  const SuggestionItem({
    required this.label,
    required this.prompt,
    this.icon,
  });
}
