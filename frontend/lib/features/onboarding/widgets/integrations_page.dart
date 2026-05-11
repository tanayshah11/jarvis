import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import 'integrations_visual.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final visualSize = screenHeight < 700 ? 200.0 : 240.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Integrations visualization with orbital animation
          IntegrationsVisual(size: visualSize)
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),

          const SizedBox(height: AppSpacing.xl),

          // "Connect Your World" title
          Text(
            'Connect Your World',
            style: AppTypography.textTheme.displayLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.md),

          // "Seamless Integrations" subtitle
          Text(
            'Seamless Integrations',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.xl),

          // Description
          Text(
            'Link your favorite apps and services. Jarvis uses this context to give you smarter, more personalized assistance.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.lg),

          // Service badges
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apps,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Gmail, Calendar, Spotify & more',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
