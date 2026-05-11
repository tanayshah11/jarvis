import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/adaptive_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/jarvis_avatar.dart';

/// Enhanced typing indicator showing Jarvis is composing a response
/// Features small gold orb with animated dots
class EnhancedTypingIndicator extends StatelessWidget {
  const EnhancedTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small Jarvis avatar
          const JarvisAvatar(size: 28, isThinking: true),
          const SizedBox(width: AppSpacing.md),
          // Typing bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Jarvis',
                    style: TextStyle(
                      color: AdaptiveColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Animated dots
                const TypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple typing dots animation showing "Thinking..." with animated dots
class TypingDots extends StatelessWidget {
  const TypingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Thinking',
          style: TextStyle(
            color: AdaptiveColors.textSecondary(context),
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AdaptiveColors.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(),
                  delay: Duration(milliseconds: i * 150),
                )
                .fadeIn(duration: 300.ms)
                .then()
                .fadeOut(duration: 300.ms);
          }),
        ),
      ],
    );
  }
}

/// Simple compact typing indicator (just dots, no avatar)
class CompactTypingIndicator extends StatelessWidget {
  const CompactTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return _buildDot(i * 200);
        }),
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AdaptiveColors.primary,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          begin: const Offset(1, 1),
          end: const Offset(1.5, 1.5),
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          duration: 600.ms,
          begin: const Offset(1.5, 1.5),
          end: const Offset(1, 1),
          curve: Curves.easeInOut,
        );
  }
}
