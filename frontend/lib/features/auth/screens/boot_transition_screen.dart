import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';

/// Cinematic transition screen after Jarvis bootup
class BootTransitionScreen extends StatefulWidget {
  const BootTransitionScreen({super.key});

  @override
  State<BootTransitionScreen> createState() => _BootTransitionScreenState();
}

class _BootTransitionScreenState extends State<BootTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;

  @override
  void initState() {
    super.initState();

    HapticFeedback.heavyImpact();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _mainController.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Expanding rings using flutter_animate
          Center(
            child: _buildRings(size),
          ),

          // Particle burst
          Center(
            child: _buildParticles(),
          ),

          // Center flash
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withAlpha(0),
                  ],
                ),
              ),
            )
                .animate(controller: _mainController)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(4.0, 4.0),
                  duration: 800.ms,
                  curve: Curves.easeOut,
                )
                .fadeOut(delay: 400.ms, duration: 400.ms),
          ),

          // "ONLINE" text
          Center(
            child: Text(
              'ONLINE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 16,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 200.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                  curve: Curves.easeOut,
                )
                .then(delay: 400.ms)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.5, 1.5),
                  duration: 300.ms,
                )
                .fadeOut(duration: 300.ms),
          ),

        ],
      ),
    );
  }

  Widget _buildRings(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(5, (index) {
        final delay = index * 100;
        return Container(
          width: size.longestSide,
          height: size.longestSide,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        )
            .animate(controller: _mainController, delay: Duration(milliseconds: delay))
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1.5, 1.5),
              duration: 1000.ms,
              curve: Curves.easeOut,
            )
            .fadeOut(delay: 500.ms, duration: 500.ms);
      }),
    );
  }

  Widget _buildParticles() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(24, (index) {
        final angle = (index / 24) * math.pi * 2;
        final distance = 300.0;

        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
            .animate(controller: _mainController, delay: 200.ms)
            .move(
              begin: Offset.zero,
              end: Offset(
                math.cos(angle) * distance,
                math.sin(angle) * distance,
              ),
              duration: 600.ms,
              curve: Curves.easeOut,
            )
            .fadeOut(delay: 300.ms, duration: 300.ms)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(0.3, 0.3),
              duration: 600.ms,
            );
      }),
    );
  }
}
