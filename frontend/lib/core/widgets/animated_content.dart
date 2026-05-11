import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Helper widget for consistent content entrance animations
class AnimatedContent extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool slideUp;

  const AnimatedContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.slideUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: slideUp ? 0.1 : -0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }
}

/// Helper for staggered list animations
class StaggeredAnimatedContent extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration itemDelay;
  final Duration startDelay;
  final Curve curve;
  final bool slideUp;
  final Axis direction;

  const StaggeredAnimatedContent({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 400),
    this.itemDelay = const Duration(milliseconds: 100),
    this.startDelay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.slideUp = true,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        children.length,
        (index) {
          final delay = startDelay + (itemDelay * index);
          return children[index]
              .animate(delay: delay)
              .fadeIn(duration: itemDuration, curve: curve)
              .slideY(
                begin: slideUp ? 0.1 : -0.1,
                end: 0,
                duration: itemDuration,
                curve: curve,
              );
        },
      ),
    );
  }
}

/// Scale animation wrapper for button feedback
class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleFactor;
  final Duration duration;

  const ScaleOnPress({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _handlePress(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
