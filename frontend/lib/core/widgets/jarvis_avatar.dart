import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../theme/colors.dart';

class JarvisAvatar extends StatefulWidget {
  final double size;
  final bool isThinking;

  const JarvisAvatar({super.key, this.size = 40, this.isThinking = false});

  @override
  State<JarvisAvatar> createState() => _JarvisAvatarState();
}

class _JarvisAvatarState extends State<JarvisAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = widget.size < 50;

    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer breathing glow (skip for small sizes)
              if (!isSmall)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.4),
                          blurRadius: widget.size * 0.4,
                          spreadRadius: widget.size * 0.05,
                        ),
                      ],
                    ),
                  ),
                ),
              // Inner pulse ring
              Container(
                width: widget.size * (isSmall ? 1.0 : _breatheAnimation.value),
                height: widget.size * (isSmall ? 1.0 : _breatheAnimation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: isSmall ? 0.6 : _glowAnimation.value * 0.5),
                    width: isSmall ? 1.0 : 1.5,
                  ),
                ),
              ),
              // The orb itself
              SizedBox(
                width: widget.size * 0.85,
                height: widget.size * 0.85,
                child: ClipOval(
                  child: DotLottieLoader.fromAsset(
                    'assets/loading-orb.lottie',
                    frameBuilder: (BuildContext context, DotLottie? dotLottie) {
                      if (dotLottie != null && dotLottie.animations.isNotEmpty) {
                        return Lottie.memory(
                          dotLottie.animations.values.first,
                          width: widget.size * 0.85,
                          height: widget.size * 0.85,
                          fit: BoxFit.cover,
                          repeat: true,
                          animate: true,
                        );
                      } else {
                        // Fallback - gold filled circle
                        return Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
