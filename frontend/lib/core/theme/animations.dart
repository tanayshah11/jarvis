import 'package:flutter/material.dart';

/// Animation constants for consistent motion design
class AppAnimations {
  const AppAnimations._();

  // ============================================
  // DURATIONS
  // ============================================

  /// Instant feedback (button press, toggle)
  static const Duration instant = Duration(milliseconds: 100);

  /// Quick transitions (hover states, small UI changes)
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard animations (most UI transitions)
  static const Duration normal = Duration(milliseconds: 250);

  /// Medium animations (page transitions, modals)
  static const Duration medium = Duration(milliseconds: 350);

  /// Slow animations (complex transitions, onboarding)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow (dramatic reveals, hero animations)
  static const Duration extraSlow = Duration(milliseconds: 700);

  /// Stagger delay between items in lists
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // ============================================
  // CURVES
  // ============================================

  /// Default curve - smooth deceleration
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// For elements entering the screen
  static const Curve enter = Curves.easeOutCubic;

  /// For elements exiting the screen
  static const Curve exit = Curves.easeInCubic;

  /// For bounce effects (buttons, badges)
  static const Curve bounce = Curves.elasticOut;

  /// Subtle bounce (less dramatic)
  static const Curve subtleBounce = Curves.easeOutBack;

  /// Spring-like motion
  static const Curve spring = Curves.easeOutExpo;

  /// Linear (progress indicators, loading)
  static const Curve linear = Curves.linear;

  /// Emphasized curve for attention-grabbing animations
  static const Curve emphasized = Curves.easeInOutCubic;

  // ============================================
  // TRANSFORM VALUES
  // ============================================

  /// Scale for pressed state
  static const double pressedScale = 0.96;

  /// Scale for hover state
  static const double hoverScale = 1.02;

  /// Offset for slide-in animations
  static const Offset slideInOffset = Offset(0, 20);

  /// Offset for slide-out animations
  static const Offset slideOutOffset = Offset(0, -10);

  /// Horizontal slide offset
  static const Offset slideHorizontalOffset = Offset(30, 0);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Calculate stagger delay for item at index
  static Duration staggerDelayFor(int index, {Duration? baseDelay}) {
    return (baseDelay ?? staggerDelay) * index;
  }

  /// Standard fade + slide up animation
  static Widget fadeSlideIn({
    required Widget child,
    required Animation<double> animation,
    Offset? beginOffset,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: enter,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset ?? const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: enter,
        )),
        child: child,
      ),
    );
  }

  /// Standard scale animation for buttons
  static Widget scaleOnTap({
    required Widget child,
    required bool isPressed,
  }) {
    return AnimatedScale(
      scale: isPressed ? pressedScale : 1.0,
      duration: instant,
      curve: defaultCurve,
      child: child,
    );
  }
}

/// Extension for easier animation building
extension AnimationExtensions on Animation<double> {
  /// Apply curve to animation
  Animation<double> curved([Curve curve = AppAnimations.defaultCurve]) {
    return CurvedAnimation(parent: this, curve: curve);
  }
}

/// Mixin for staggered list animations
mixin StaggeredAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late List<AnimationController> _staggerControllers;

  void initStaggeredAnimations(int itemCount) {
    _staggerControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        vsync: this,
        duration: AppAnimations.normal,
      ),
    );

    // Start staggered animations
    for (var i = 0; i < _staggerControllers.length; i++) {
      Future.delayed(AppAnimations.staggerDelayFor(i), () {
        if (mounted) {
          _staggerControllers[i].forward();
        }
      });
    }
  }

  Animation<double> getStaggerAnimation(int index) {
    return _staggerControllers[index];
  }

  void disposeStaggeredAnimations() {
    for (final controller in _staggerControllers) {
      controller.dispose();
    }
  }
}
