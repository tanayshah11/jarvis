import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/jarvis_avatar.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarSize = screenHeight < 700 ? 120.0 : 140.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Large gold orb with pulsing animation
          JarvisAvatar(
            size: avatarSize,
            isThinking: true,
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .scale(
                duration: 2000.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 2000.ms,
                begin: const Offset(1.08, 1.08),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: AppSpacing.xl),

          // "Meet Jarvis" title
          Text(
            'Meet Jarvis',
            style: AppTypography.textTheme.displayLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.md),

          // "Your Personal AI Assistant" subtitle
          Text(
            'Your Personal AI Assistant',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.xl),

          // Description
          Text(
            'Powered by the world\'s most advanced AI models. Ask anything, anytime.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
