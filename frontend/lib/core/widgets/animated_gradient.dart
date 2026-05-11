import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/adaptive_colors.dart';
import '../theme/gradients.dart';

class AnimatedGradient extends StatelessWidget {
  final Widget child;

  const AnimatedGradient({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundAnimated,
          ),
        ),

        // Subtle animated glow at top-left
        Positioned(
          top: -180,
          left: -120,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.1,
                colors: [
                  AdaptiveColors.primary.withValues(alpha: 0.18),
                  AdaptiveColors.primary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(duration: 3.seconds, begin: 0.7, end: 1.0),
        ),

        // Subtle cool glow at bottom-right
        Positioned(
          bottom: -200,
          right: -140,
          child: Container(
            width: 480,
            height: 480,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  AdaptiveColors.primaryLight.withValues(alpha: 0.12),
                  AdaptiveColors.primaryLight.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(duration: 5.seconds, begin: 0.6, end: 0.95),
        ),

        // Content
        child,
      ],
    );
  }
}
