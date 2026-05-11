import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/haptics.dart';
import '../theme/animations.dart';
import '../theme/colors.dart';
import '../theme/gradients.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';

/// Premium card component with glassmorphism, animations, and haptic feedback
class JarvisCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final bool glass;
  final bool elevated;
  final bool glowOnPress;
  final bool enableHaptics;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final Gradient? gradient;
  final bool showGradientBorder;

  const JarvisCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.glass = false,
    this.elevated = false,
    this.glowOnPress = false,
    this.enableHaptics = true,
    this.isLoading = false,
    this.borderRadius,
    this.customShadow,
    this.gradient,
    this.showGradientBorder = false,
  });

  @override
  State<JarvisCard> createState() => _JarvisCardState();
}

class _JarvisCardState extends State<JarvisCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(JarvisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.isLoading && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      AppHaptics.lightTap();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.enableHaptics) {
      AppHaptics.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppRadius.lg);
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    // Determine shadow based on state and elevation
    List<BoxShadow> shadow;
    if (widget.customShadow != null) {
      shadow = widget.customShadow!;
    } else if (_isPressed && widget.glowOnPress) {
      shadow = AppShadows.primaryGlow;
    } else if (widget.elevated) {
      shadow = AppShadows.elevated;
    } else {
      shadow = AppShadows.subtle;
    }

    Widget cardContent;

    if (widget.glass) {
      // Glassmorphism card
      cardContent = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppGradients.glass,
              borderRadius: borderRadius,
              border: widget.showGradientBorder
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
            ),
            child: widget.child,
          ),
        ),
      );
    } else {
      // Standard card with premium styling
      cardContent = Container(
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.surfaceLight,
          gradient: widget.gradient,
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: shadow,
        ),
        child: widget.child,
      );
    }

    // Wrap with gradient border if needed
    if (widget.showGradientBorder) {
      cardContent = Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.surfaceLight,
            borderRadius:
                BorderRadius.circular(borderRadius.topLeft.x - 1.5),
          ),
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: widget.child,
        ),
      );
    }

    // Add shimmer loading effect
    if (widget.isLoading) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: _ShimmerAnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x1AFFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: [
                          _shimmerController.value - 0.3,
                          _shimmerController.value,
                          _shimmerController.value + 0.3,
                        ].map((s) => s.clamp(0.0, 1.0)).toList(),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    // Wrap with margin
    cardContent = Container(
      margin: widget.margin,
      child: cardContent,
    );

    // Add press animation and interactivity
    if (isInteractive) {
      cardContent = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _isPressed ? AppAnimations.pressedScale : 1.0,
            duration: AppAnimations.instant,
            curve: AppAnimations.defaultCurve,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}

/// Animated builder helper for shimmer effect
class _ShimmerAnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const _ShimmerAnimatedBuilder({
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
